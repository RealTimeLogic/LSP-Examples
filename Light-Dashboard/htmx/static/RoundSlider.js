$(function() {
  if (window.roundSliderCleanup) {
    window.roundSliderCleanup();
  }

  //SMQ Doc: https://realtimelogic.com/ba/doc/en/JavaScript/SMQ.html
  var smq = SMQ.Client(SMQ.wsURL("/SMQ/"), {cleanstart:true});
  let running=true;
  let active=true;
  let hasConnected=false;
  let connectionGeneration=0;

  function emit(name,detail) {
    document.dispatchEvent(new CustomEvent(name,{detail:detail || {}}));
  }

  function subscriptionAck(topic,subtopic) {
    return function(accepted) {
      if(!accepted) {
        emit("cms:smq-subscribe-error",{topic:topic,subtopic:subtopic || null});
      }
    };
  }

  function subscribeAndRequestState() {
    // Subscribe to one-to-one messages sent directly from the server.
    smq.subscribe("self","slider",{
      datatype:"json",
      onack:subscriptionAck("self","slider"),
      onmsg:onSmqMsg
    });
    // Subscribe to one-to-many slider updates.
    smq.subscribe("slider",{
      datatype:"json",
      onack:subscriptionAck("slider"),
      onmsg:onSmqMsg
    });
    // The final subscription is a barrier: request state only after the
    // response subscription has been processed by the broker.
    smq.subscribe("$roundSliderReady",{onack:function(accepted) {
      if(!accepted) {
        emit("cms:smq-subscribe-error",{topic:"$roundSliderReady",subtopic:null});
      } else if(running) {
        smq.publish("",1,"getSlider");
      }
    }});
  }

  function onConnect() {
    if(hasConnected) connectionGeneration += 1;
    else hasConnected=true;
    subscribeAndRequestState();
    emit("cms:smq-connect",{
      generation:connectionGeneration,
      reconnect:connectionGeneration > 0
    });
  }

  smq.onconnect=onConnect;
  smq.onreconnect=onConnect;

  smq.onclose=function(message,canreconnect) {
    if(!running) return;
    emit("cms:smq-close",{
      message:message || "SMQ disconnected",
      canReconnect:Boolean(canreconnect)
    });
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

  function cleanup() {
    if (!running) return;
    running=false;
    $('body').off('htmx:beforeSwap.roundSlider', beforeSwap);
    smq.disconnect();
    if (window.roundSliderCleanup === cleanup) {
      window.roundSliderCleanup = null;
    }
  }

  function beforeSwap(event) {
    const target = event.originalEvent.detail.target; // Access native event detail via jQuery
    if (target && target.id === 'main') {
      console.log('WebSocket fragment is about to be unloaded, stopping SMQ');
      cleanup();
    }
  }

  window.roundSliderCleanup = cleanup;
  $('body').off('htmx:beforeSwap.roundSlider').on('htmx:beforeSwap.roundSlider', beforeSwap);
});
