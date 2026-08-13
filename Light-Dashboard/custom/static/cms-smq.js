(function (window, document) {
  "use strict";

  const brokerTid = 1;
  const rpcTimeoutMs = 10000;
  const smq = SMQ.Client(SMQ.wsURL("/SMQ/"), { cleanstart: true });
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
    if (!connected) {
      return;
    }

    if (route.subscribedGeneration === connectionGeneration) {
      return;
    }

    const settings = {
      datatype: route.datatype,
      onack(accepted) {
        if (!accepted) {
          emit("cms:smq-subscribe-error", {
            topic: route.topic,
            subtopic: route.subtopic || null
          });
        }
      },
      onmsg(message, ptid, tid, subtid) {
        route.handlers.forEach((handler) => {
          try {
            handler(message, ptid, tid, subtid);
          } catch (error) {
            console.error("SMQ page handler failed", error);
          }
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
    scope.cleanups.forEach((cleanup) => {
      try {
        cleanup();
      } catch (error) {
        console.error("SMQ page cleanup failed", error);
      }
    });

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
      window.clearTimeout(pending.timer);
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
    window.clearTimeout(pending.timer);
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
    if (!connected) {
      return Promise.reject(new Error("SMQ is not connected"));
    }

    const id = `${scope.id}:${++scope.rpcCounter}`;
    const payload = {
      id,
      name: methodName,
      args
    };

    return new Promise((resolve, reject) => {
      const timer = window.setTimeout(() => {
        scope.rpcPending.delete(id);
        reject(new Error(`SMQ RPC timed out: ${methodName}`));
      }, rpcTimeoutMs);
      scope.rpcPending.set(id, { resolve, reject, timer });
      try {
        window.cmsSmq.sendToBroker("$RpcReq", payload);
      } catch (error) {
        scope.rpcPending.delete(id);
        window.clearTimeout(timer);
        reject(error);
      }
    });
  }

  function readyScope(scope) {
    if (!connected || !scope || !scope.active || scope.readyCallbacks.length === 0) {
      return;
    }

    const readyGeneration = connectionGeneration;
    smq.subscribe("$cmsReady", {
      onack(accepted) {
        if (!accepted) {
          emit("cms:smq-subscribe-error", { topic: "$cmsReady", subtopic: null });
          return;
        }
        if (!scope.active || readyGeneration !== connectionGeneration) {
          return;
        }
        scope.readyCallbacks.forEach((callback) => {
          try {
            callback(smq);
          } catch (error) {
            console.error("SMQ page readiness callback failed", error);
          }
        });
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

  function emit(name, detail) {
    document.dispatchEvent(new CustomEvent(name, { detail: detail || {} }));
  }

  function onConnect() {
    connected = true;
    if (hasConnected) {
      connectionGeneration += 1;
    } else {
      hasConnected = true;
    }
    reconnectScope(currentScope);
    emit("cms:smq-connect", {
      generation: connectionGeneration,
      reconnect: connectionGeneration > 0
    });
  }

  smq.onconnect = onConnect;
  smq.onreconnect = onConnect;
  smq.onclose = function (message, canreconnect) {
    connected = false;
    failPendingRpc(currentScope, new Error(message || "SMQ disconnected"));
    emit("cms:smq-close", {
      message: message || "SMQ disconnected",
      canReconnect: Boolean(canreconnect)
    });
    if (canreconnect) {
      return 3000;
    }
    return undefined;
  };

  window.cmsSmq = {
    brokerTid,
    rpcTimeoutMs,
    client: smq,

    isConnected() {
      return connected;
    },

    sendToBroker(messageName, payload) {
      smq.pubjson(payload === undefined ? {} : payload, brokerTid, messageName);
    },

    sendToPeer(peerTid, messageName, payload) {
      smq.pubjson(payload === undefined ? {} : payload, peerTid, messageName);
    },

    publishEvent(eventName, payload) {
      smq.pubjson(payload === undefined ? {} : payload, eventName);
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
