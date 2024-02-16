
function createSmqRpc(smq) {
    let idCounter=0;
    let callbacks={} // saved RPC callbacks: key=id, val=promise
    let subscribed=false;
    function subscribe() {
	smq.subscribe("self", "$RpcResp", {datatype:"json",onmsg:(pl) => {
	    let promise=callbacks[pl.id];
	    if(promise) {
		delete callbacks[pl.id]; // Release
		if(pl.err) promise.reject(new Error(pl.err));
		else promise.resolve(pl.rsp);
	    }
	    else {
		console.error(`SMQ RPC: promise (callback) not found for id '${pl.id}'`);
	    }
	}});
    };
    return {
	proxy: new Proxy({}, {
	    get(target, prop, receiver) {
		// Return a function that, when called, returns a Promise
		if( ! subscribed ) {
		    subscribe();
		    subscribed=true;
		};
		return (...args) => {
		    return new Promise((resolve, reject) => {
			// Assemble payload
			const pl = {
			    id: ++idCounter,
			    name: prop,
			    args: args
			};
			callbacks[idCounter]={resolve:resolve,reject:reject};
			smq.pubjson(pl, 1, "$RpcReq"); // Publish to etid 1, the server.
		    });
		};
	    }
	}),
	disconnect: function(report) {
	    if(false != report) {
		for(let id in callbacks) {
		    let promise=callbacks[id];
		    promise.reject("disconnected");
		}
	    }
	    callbacks={};
	    subscribed=false;
	}
    };
};
