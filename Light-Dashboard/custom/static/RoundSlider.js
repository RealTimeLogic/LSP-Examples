$(function() {
  //SMQ Doc: https://realtimelogic.com/ba/doc/en/JavaScript/SMQ.html 
  var smq = SMQ.Client("/SMQ/"); // Connect to /SMQ/index.lsp
  let running=true;
  let active=true;

  smq.onclose=function(message,canreconnect) {
    if(!running) return;
    console.log("SMQ disconnected");
    if(canreconnect) return 3000;
  };

  //SMQ callback for data sent to the topic "slider" and "self"
  function onSmqMsg(d,ptid) {
    if(ptid != smq.gettid()) { //Ignore messages from 'self'
      active=true;
      $("#Slider").roundSlider("option", "value", Math.floor(d.angle * 100 / 180));
      active=false;
    }
  }
  
  smq.subscribe("self",{datatype:"json",onmsg:onSmqMsg});
  smq.subscribe("slider",{datatype:"json",onmsg:onSmqMsg});

  function onChange (e) {
    if(!active)
      smq.pubjson({angle:Math.floor(e.value * 180 / 100)}, "slider");
  }

  $("#Slider").roundSlider({
    animation:false,
    sliderType: "min-range",
    radius: 130,
    showTooltip: false,
    width: 16,
    value: 0,
    handleSize: 0,
    handleShape: "square",
    circleShape: "half-top",
    change: onChange,
    tooltipFormat: onChange
  });
  active=false;

  $('body').on('htmx:beforeSwap', function (event) {
    running=false;
    const target = event.originalEvent.detail.target; // Access native event detail via jQuery
    if (target && target.id === 'main') {
      console.log('WebSocket fragment is about to be unloaded, stopping SMQ');
      smq.disconnect();
    }
  });
});
