// Svoronos Kanavas Iason -- Parameter Receiver patch
// LiU Apr. 2022 -- construction site sonification

OSCdef(\parameterReceiver,{
	| msg |
	var id;
	[\parameterReceiver, msg[1]].postln;
	id = msg[1].asSymbol;
	switch (id,
		\pm10_synth, {
			if(p.gatePM10 == 1, {p.gatePM10 = 0},{p.gatePM10 = 1}); // binary switch 0-1
			x.busOut.set(\gatePM10, p.gatePM10); // set gate of pm synth to 0 or 1
		},
		\pm25_synth, {
			if(p.gatePM25 == 1, {p.gatePM25 = 0},{p.gatePM25 = 1});
			x.busOut.set(\gatePM25, p.gatePM25);
		},
		\noise_synth, { 
			if(p.gateNoise == 1, {p.gateNoise = 0},{p.gateNoise = 1});
			x.busOut.set(\gateNoise, p.gateNoise);
		},
		\humid_synth, { 
			if(p.revGate == 1, {p.revGate = 0},{p.revGate = 1});
			x.busOut.set(\revGate, p.revGate);
		},
	);
},'/synths');

OSCdef(\start_end_receiver,{
	| msg |
	var id;
	id = msg[1].asInteger;
	switch (id,
		0, { 
			x.busOut.set(\masterGate, 0);
			"Master gate OFF".postln;
		},
		1, {
			x.busOut.set(\masterGate, 1);
			"Master gate ON".postln;
		};
	);
},'/startEnd');
