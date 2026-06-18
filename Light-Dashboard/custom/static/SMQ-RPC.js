(function (window, document) {
  "use strict";

  const root = document.getElementById("SmqRpcDemo");
  const connectionEl = document.getElementById("RpcConnection");
  const passedEl = document.getElementById("RpcPassed");
  const failedEl = document.getElementById("RpcFailed");
  const logEl = document.getElementById("RpcLog");
  const factorAEl = document.getElementById("RpcFactorA");
  const factorBEl = document.getElementById("RpcFactorB");

  if (!root || !connectionEl || !passedEl || !failedEl || !logEl || !factorAEl || !factorBEl) {
    return;
  }

  let passed = 0;
  let failed = 0;

  function setConnection(text) {
    connectionEl.textContent = text;
  }

  function updateCounters() {
    passedEl.textContent = String(passed);
    failedEl.textContent = String(failed);
  }

  function format(value) {
    if (value instanceof Error) {
      return value.message;
    }

    if (typeof value === "string") {
      return value;
    }

    return JSON.stringify(value, null, 2);
  }

  function log(status, title, detail) {
    const item = document.createElement("li");
    item.className = status;

    const heading = document.createElement("strong");
    heading.textContent = `${status.toUpperCase()} - ${title}`;
    item.appendChild(heading);

    if (detail !== undefined) {
      const pre = document.createElement("pre");
      pre.textContent = format(detail);
      item.appendChild(pre);
    }

    logEl.prepend(item);
  }

  function assert(condition, message, detail) {
    if (!condition) {
      const error = new Error(message);
      error.detail = detail;
      throw error;
    }
  }

  async function record(title, test) {
    try {
      const detail = await test();
      passed += 1;
      log("pass", title, detail);
    } catch (error) {
      failed += 1;
      log("fail", title, error.detail || error);
    } finally {
      updateCounters();
    }
  }

  function requireCmsSmq() {
    assert(window.cmsSmq, "window.cmsSmq is not available");
  }

  function readNumber(input, label) {
    const value = Number(input.value);
    assert(Number.isFinite(value), `${label} must be a number`, input.value);
    return value;
  }

  function install(scope) {
    async function testEcho() {
      const response = await scope.rpc.echo("alpha", { value: 42 }, true);
      assert(Array.isArray(response), "echo response should be an array", response);
      assert(response[0] === "alpha", "echo should preserve string argument", response);
      assert(response[1] && response[1].value === 42, "echo should preserve object argument", response);
      assert(response[2] === true, "echo should preserve boolean argument", response);
      return response;
    }

    async function testMultiply() {
      const response = await scope.rpc.multiply(6, 7);
      assert(response === 42, "multiply(6, 7) should return 42", response);
      return { result: response };
    }

    async function manualMultiply() {
      const a = readNumber(factorAEl, "Multiply value A");
      const b = readNumber(factorBEl, "Multiply value B");
      const response = await scope.rpc.multiply(a, b);
      assert(response === a * b, `multiply(${a}, ${b}) should return ${a * b}`, response);
      return {
        a,
        b,
        result: response
      };
    }

    async function testServerInfo() {
      const response = await scope.rpc.serverInfo();
      assert(response && response.app === "Light Dashboard", "serverInfo should return app name", response);
      assert(response.rpc === true, "serverInfo should confirm RPC support", response);
      return response;
    }

    async function testFailure() {
      try {
        await scope.rpc.failfunc();
      } catch (error) {
        assert(/fails/i.test(error.message), "failfunc should return the expected error", error.message);
        return { error: error.message };
      }
      throw new Error("failfunc should reject");
    }

    async function testMissingMethod() {
      try {
        await scope.rpc.noSuchMethod();
      } catch (error) {
        assert(/not found/i.test(error.message), "missing method should reject with not found", error.message);
        return { error: error.message };
      }
      throw new Error("missing method should reject");
    }

    async function testConcurrent() {
      const responses = await Promise.all([
        scope.rpc.multiply(2, 5),
        scope.rpc.echo("parallel", 3),
        scope.rpc.serverInfo(),
        scope.callRpc("multiply", 9, 9)
      ]);

      assert(responses[0] === 10, "first concurrent multiply should return 10", responses);
      assert(Array.isArray(responses[1]) && responses[1][0] === "parallel", "concurrent echo should match", responses);
      assert(responses[2] && responses[2].rpc === true, "concurrent serverInfo should match", responses);
      assert(responses[3] === 81, "callRpc multiply should return 81", responses);
      return responses;
    }

    async function runAllTests() {
      passed = 0;
      failed = 0;
      logEl.replaceChildren();
      updateCounters();
      await record("RPC echo preserves JSON arguments", testEcho);
      await record("RPC multiply returns a scalar result", testMultiply);
      await record("RPC serverInfo returns broker data", testServerInfo);
      await record("RPC failure rejects the Promise", testFailure);
      await record("Missing RPC method rejects the Promise", testMissingMethod);
      await record("Concurrent RPC calls resolve by correlation ID", testConcurrent);
    }

    function onClick(event) {
      const button = event.target.closest("[data-rpc-action]");
      if (!button) {
        return;
      }

      const action = button.dataset.rpcAction;
      if (action === "echo") {
        record("Manual echo", testEcho);
      } else if (action === "multiply") {
        record("Manual multiply", manualMultiply);
      } else if (action === "serverInfo") {
        record("Manual serverInfo", testServerInfo);
      } else if (action === "failure") {
        record("Manual expected failure", testFailure);
      } else if (action === "runTests") {
        runAllTests();
      }
    }

    root.addEventListener("click", onClick);
    scope.onCleanup(() => root.removeEventListener("click", onClick));
    scope.onReady(() => {
      setConnection(window.cmsSmq.isConnected() ? "connected" : "connecting");
      runAllTests();
    });
  }

  requireCmsSmq();
  window.cmsSmq.mountPage("SMQ RPC", install);
}(this, this.document));
