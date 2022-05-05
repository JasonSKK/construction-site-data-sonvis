// =====================================================================
// SuperCollider Workspace
// =====================================================================
x=();
x.pm10synth;
x.pm25synth;

~bus1=Bus.audio(s,1);
~bus2=Bus.audio(s,2);

SynthDef(\busOut,{
	var sig = In.ar(~bus1);
	var sig2 = In.ar(~bus2);
	var out = Out.ar(0,Balance2.ar(sig,sig2,1));
	//out = K2A.ar(out);
	//Out.ar(0,out);
	out;
}).add;

Synth(\busOut, addAction:\addToTail);

x.pm10synth = play{|freq=130,minScale=130,maxScale=261,relSmoothing=0.01,pan=(-0.9)|
	var amp, sig, cp;
	freq=Amplitude.kr(freq,0.001,relSmoothing); // smoothing 
	amp = LinLin.kr(freq,minScale,maxScale,0.1,1.0); // to amp values
	cp = freq.linlin(minScale,maxScale,10,200); // init cp for gendy
	sig = CombC.ar( // delay line
		in: SinOscFB.ar(freq* 
			Gendy2.ar( // as FM 
				freq:freq,
				minfreq:freq,
				maxfreq:freq,
				initCPs:cp,
				add:amp),
			feedback:amp)*amp*0.1, // feedback SinOscFB
		maxdelaytime:0.2, // delay max
		delaytime:0.5/freq); // delay time
	sig = sig + BPF.ar( // add filtered  noise
		in: WhiteNoise.ar(0.001),
		freq: LFNoise1.ar(0.5).range(2000,12000)+(freq.lag(0.21)*10), // slow cF modulation
		rq: amp.lag(0.1));
	sig = Pan2.ar(sig, pos:pan);
};

x.pm25synth = play{|freq=261,minScale=261,maxScale=523,relSmoothing=0.01,pan=0.9|
	var amp, sig, cp;
	freq=Amplitude.kr(freq,0.001,relSmoothing);
	amp = LinLin.kr(freq,minScale,maxScale,0.1,1.0);
	cp = freq.linlin(minScale,maxScale,10,200);
	sig = CombC.ar( // delay line
		in: SinOscFB.ar(freq*
			Gendy5.ar( // as FM
				freq:freq,
				minfreq:freq,
				maxfreq:freq,
				initCPs:cp,
				add:amp),
			feedback:amp)*amp*0.1, // feedback SinOscFB
		maxdelaytime:0.2, // delay max
		delaytime:0.5/freq); // delay time
	sig = sig + BPF.ar( // add filtered  noise
		in: WhiteNoise.ar(0.001),
		freq: LFNoise1.ar(0.5).range(2000,12000)+(freq.lag(0.21)*10), // slow cF modulation
		rq: amp.lag(0.1));
	sig = tanh(sig);
	sig = Pan2.ar(sig, pos:pan);
};

SynthDef(\warning, {
	| freq, amp, rel, pan, pm10_upwards, pm10_downwards |
	var sig1, sig2, env, out, sum;
	sig1 = Gendy4.ar( // for lower values around 12~
		minfreq: freq,
		maxfreq: freq,
		mul:amp);
	sig2 = Gendy2.ar( // for higher values max 59
		minfreq: freq,
		maxfreq: freq,
		mul:amp);
	sum = Mix([sig1*pm10_downwards,sig2*pm10_upwards]); // G mixed & factor control
	env = Env.perc(0.04, rel).kr(doneAction:2); 
	out = sum * env;
	Out.ar(0, Pan2.ar(out, pan));
}).add;

//x.right.set(\freq,261)
/*
fork{
	var rand1,rand2;
	1000.do{
		//rand1=(200+200.rand).abs;
		//rand2=(400+200.rand).abs;
		rand1=(200+200.rand).abs;
		rand2=(400+200.rand).abs;
		//[rand1,rand2].postln;
		x.left.set(\freq, rand1);
		x.right.set(\freq,rand2);
		0.041.wait;
	}
}



x.left.set(\freq,509);
s.meter
*/