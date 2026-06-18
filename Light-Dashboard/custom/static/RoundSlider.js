(function (window, document) {
  "use strict";

  function initRoundSlider() {
    const slider = document.getElementById("Slider");
    const gauge = document.querySelector(".slider-gauge");
    const valueOutput = document.getElementById("SliderValue");

    if (!slider || !gauge || !valueOutput) {
      return;
    }

    if (!window.cmsSmq) {
      valueOutput.textContent = "SMQ unavailable";
      slider.disabled = true;
      return;
    }

    let pageScope = null;
    let applyingRemoteValue = false;

    function angleFromPercent(percent) {
      return Math.floor(percent * 180 / 100);
    }

    function percentFromAngle(angle) {
      return Math.floor(angle * 100 / 180);
    }

    function renderPercent(percent) {
      const boundedPercent = Math.max(0, Math.min(100, percent));
      slider.value = String(boundedPercent);
      gauge.style.setProperty("--slider-percent", String(boundedPercent));
      valueOutput.textContent = `${angleFromPercent(boundedPercent)}\u00b0`;
    }

    function applyServerValue(data) {
      if (!data || typeof data.angle !== "number") {
        return;
      }

      applyingRemoteValue = true;
      renderPercent(percentFromAngle(data.angle));
      applyingRemoteValue = false;
    }

    function publishSliderValue() {
      if (applyingRemoteValue || !pageScope) {
        return;
      }

      pageScope.sendToBroker("setSlider", {
        angle: angleFromPercent(Number(slider.value))
      });
    }

    renderPercent(Number(slider.value));
    function handleSliderChange() {
      renderPercent(Number(slider.value));
      publishSliderValue();
    }

    slider.addEventListener("input", handleSliderChange);
    slider.addEventListener("change", handleSliderChange);

    window.cmsSmq.mountPage("RoundSlider", (scope) => {
      pageScope = scope;

      scope.subscribeToDirectMessage("slider", applyServerValue);
      scope.subscribeToEvent("slider", applyServerValue);
      scope.onReady(() => {
        scope.sendToBroker("getSlider", {});
      });
      scope.onCleanup(() => {
        pageScope = null;
      });
    });
  }

  initRoundSlider();
}(this, this.document));
