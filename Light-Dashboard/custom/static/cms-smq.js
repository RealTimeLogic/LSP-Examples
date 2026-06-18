(function (window, document) {
  "use strict";

  const brokerTid = 1;
  const smq = SMQ.Client("/SMQ/", { cleanstart: true });
  const routes = new Map();
  let connected = false;
  let hasConnected = false;
  let currentScope = null;
  let connectionGeneration = 0;

  function formatError(error) {
    if (error instanceof Error) {
      return error.message;
    }
    return String(error || "SMQ RPC failed");
  }

  function routeKey(topic, subtopic) {
    return `${topic}\u001f${subtopic || ""}`;
  }

  function routeHasHandlers(route) {
    return route.handlers.size > 0;
  }

  function topicHasHandlers(topic) {
    return Array.from(routes.values()).some((route) => {
      return route.topic === topic && routeHasHandlers(route);
    });
  }

  function subscribeRoute(route) {
    if (route.subscribedGeneration === connectionGeneration) {
      return;
    }

    const settings = {
      datatype: route.datatype,
      onmsg(message, ptid, tid, subtid) {
        route.handlers.forEach((handler) => {
          handler(message, ptid, tid, subtid);
        });
      }
    };

    if (route.subtopic) {
      smq.subscribe(route.topic, route.subtopic, settings);
    } else {
      smq.subscribe(route.topic, settings);
    }
    route.subscribedGeneration = connectionGeneration;
  }

  function ensureRoute(topic, subtopic, datatype, handler, scope) {
    const key = routeKey(topic, subtopic);
    let route = routes.get(key);

    if (!route) {
      route = {
        topic,
        subtopic,
        datatype: datatype || "json",
        handlers: new Map(),
        subscribedGeneration: -1
      };
      routes.set(key, route);
    }

    route.handlers.set(scope.id, handler);
    scope.routes.add(key);
    subscribeRoute(route);
  }

  function cleanupScope(scope) {
    if (!scope || !scope.active) {
      return;
    }

    failPendingRpc(scope, new Error("Page unloaded before SMQ RPC response"));
    scope.active = false;
    scope.cleanups.forEach((cleanup) => cleanup());

    scope.routes.forEach((key) => {
      const route = routes.get(key);
      if (!route) {
        return;
      }

      route.handlers.delete(scope.id);
      if (!routeHasHandlers(route)) {
        routes.delete(key);
        if (route.topic !== "self" && !topicHasHandlers(route.topic)) {
          smq.unsubscribe(route.topic);
        }
      }
    });

    if (currentScope === scope) {
      currentScope = null;
    }
  }

  function failPendingRpc(scope, error) {
    if (!scope || !scope.rpcPending || scope.rpcPending.size === 0) {
      return;
    }

    scope.rpcPending.forEach((pending) => {
      pending.reject(error);
    });
    scope.rpcPending.clear();
  }

  function handleRpcResponse(scope, response) {
    if (!response || !Object.prototype.hasOwnProperty.call(response, "id")) {
      return;
    }

    const pending = scope.rpcPending.get(response.id);
    if (!pending) {
      return;
    }

    scope.rpcPending.delete(response.id);
    if (response.err) {
      pending.reject(new Error(formatError(response.err)));
    } else {
      pending.resolve(response.rsp);
    }
  }

  function callRpc(scope, methodName, args) {
    if (!scope.active) {
      return Promise.reject(new Error("Page scope is no longer active"));
    }

    const id = `${scope.id}:${++scope.rpcCounter}`;
    const payload = {
      id,
      name: methodName,
      args
    };

    return new Promise((resolve, reject) => {
      scope.rpcPending.set(id, { resolve, reject });
      try {
        window.cmsSmq.sendToBroker("$RpcReq", payload);
      } catch (error) {
        scope.rpcPending.delete(id);
        reject(error);
      }
    });
  }

  function readyScope(scope) {
    if (!scope || !scope.active || scope.readyCallbacks.length === 0) {
      return;
    }

    const readyGeneration = connectionGeneration;
    smq.subscribe("$cmsReady", {
      onack(accepted) {
        if (!accepted || !scope.active || readyGeneration !== connectionGeneration) {
          return;
        }
        scope.readyCallbacks.forEach((callback) => callback(smq));
      }
    });
  }

  function reconnectScope(scope) {
    if (!scope || !scope.active) {
      return;
    }

    scope.routes.forEach((key) => {
      const route = routes.get(key);
      if (route && routeHasHandlers(route)) {
        subscribeRoute(route);
      }
    });
    readyScope(scope);
  }

  function onConnect() {
    connected = true;
    if (hasConnected) {
      connectionGeneration += 1;
      reconnectScope(currentScope);
    } else {
      hasConnected = true;
    }
  }

  smq.onconnect = onConnect;
  smq.onreconnect = onConnect;
  smq.onclose = function (message, canreconnect) {
    connected = false;
    failPendingRpc(currentScope, new Error(message || "SMQ disconnected"));
    if (canreconnect) {
      return 3000;
    }
    return undefined;
  };

  window.cmsSmq = {
    brokerTid,
    client: smq,

    isConnected() {
      return connected;
    },

    sendToBroker(messageName, payload) {
      smq.pubjson(payload || {}, brokerTid, messageName);
    },

    sendToPeer(peerTid, messageName, payload) {
      smq.pubjson(payload || {}, peerTid, messageName);
    },

    publishEvent(eventName, payload) {
      smq.pubjson(payload || {}, eventName);
    },

    mountPage(name, init) {
      const scope = {
        id: `${name}:${Date.now()}:${Math.random()}`,
        name,
        active: true,
        cleanups: [],
        routes: new Set(),
        readyCallbacks: [],
        rpcPending: new Map(),
        rpcCounter: 0,

        onCleanup(cleanup) {
          scope.cleanups.push(cleanup);
        },

        onReady(callback) {
          scope.readyCallbacks.push(callback);
        },

        subscribeToEvent(eventName, handler, datatype) {
          ensureRoute(eventName, null, datatype, handler, scope);
        },

        subscribeToDirectMessage(messageName, handler, datatype) {
          ensureRoute("self", messageName, datatype, handler, scope);
        },

        sendToBroker(messageName, payload) {
          window.cmsSmq.sendToBroker(messageName, payload);
        },

        sendToPeer(peerTid, messageName, payload) {
          window.cmsSmq.sendToPeer(peerTid, messageName, payload);
        },

        publishEvent(eventName, payload) {
          window.cmsSmq.publishEvent(eventName, payload);
        },

        callRpc(methodName, ...args) {
          return callRpc(scope, methodName, args);
        },

        rpc: new Proxy({}, {
          get(target, property) {
            if (typeof property !== "string") {
              return undefined;
            }
            return (...args) => callRpc(scope, property, args);
          }
        }),

        failPendingRpc(error) {
          failPendingRpc(scope, error);
        }
      };

      cleanupScope(currentScope);
      currentScope = scope;
      ensureRoute("self", "$RpcResp", "json", (response) => {
        handleRpcResponse(scope, response);
      }, scope);
      init(scope);
      readyScope(scope);

      return () => cleanupScope(scope);
    },

    cleanupPage() {
      cleanupScope(currentScope);
    }
  };

  function installHtmxCleanupHandler() {
    document.body.addEventListener("htmx:beforeSwap", (event) => {
      if (event.detail && event.detail.target && event.detail.target.id === "main") {
        window.cmsSmq.cleanupPage();
      }
    });
  }

  if (document.body) {
    installHtmxCleanupHandler();
  } else {
    document.addEventListener("DOMContentLoaded", installHtmxCleanupHandler, { once: true });
  }
}(this, this.document));
