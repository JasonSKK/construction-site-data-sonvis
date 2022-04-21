// =====================================================================
// SuperCollider Workspace
// =====================================================================

play{Gendy1.ar(0,0,0,minfreq:200,maxfreq:200) * Env.perc(0.0,0.1,curve:-8).kr(doneAction:2)}



b = Wavetable.chebyFill(513, [0.3, -0.8, 1.1])
b = Buffer.alloc(s, 512, 1, {arg buf; buf.sine1Msg(1.0/[1,2,3,4,5,6,7,8,9,10])});
x = { COsc.ar(b.bufnum, 60, 0.0, SinOscFB.ar(666,0.8))*0.1!2}.play
//:
x = {
	|freq=500|
	COsc.ar(
		b.bufnum, // bufnum
		freq, // freq
		(freq/freq).log2*2, // beats
		SinOscFB.ar(
			freq/((freq/50).log10), // freq
			0.8*(freq.linlin(300,700,0.0,1.2) // FB
			)))*0.1!2}.play



//:

"bjor_synth".postln;
SynthDef("bjor", {
	| freq = 444, modf = 1000, amp = 0.0, cutoff = 1066, panst = 0, panend = 0|
	var sig, env, out;
	sig =
	Pluck.ar(PinkNoise.ar, Impulse.kr(0), 0.5,
		delaytime: 4/freq, //Lowerfreq more delay - extreme effects
		decaytime: 8,
		coef: 0.1);
	sig = LPF.ar(sig, cutoff);
	sig = sig.wrap2(0.666);
	//env = Env.perc(10, 6, curve:'cubed').kr(doneAction:2);
	env = Env([0, 1, 0], [0.001,0.1], curve:7).kr(doneAction:2);
	out = sig * env * 20;
	Out.ar(0, Pan2.ar(out * amp, Line.kr(panst, panend, 7)));
	//Out.ar(~vbus, out * amp * dbamp(-6))
}).add;
//:
//~amplitudeBus = Bus.audio(s,1);
x = play{|freq=500,gate|
	var sig = SinOscFB.ar(
		freq*SinOscFB.ar((freq/2)+(freq/freq).log10, freq*0.001),freq*0.001
	)*0.1*EnvGen.kr(Env.adsr(0.0,0.3,1.0),gate:gate)!2;
	LPF.ar(sig,freq); 
};
//:
x.set(\gate,1)
x.set(\freq,1030)

//:

x = play{|freq =622|
	var sig = SinOscFB.ar(VarSaw.ar(622).range(freq-50,freq+50), SinOscFB.ar(111).range(0.1,1.0),SinOscFB.ar(0.9).range(0.1,0.9),SinOscFB.ar(222,SinOscFB.ar(1.4,SinOsc.ar(100.4).range(0.7, 0.9))))!2;
	sig = sig * 0.1;
}

//:


//:
fork{
	var frequency;
x = SynthDef(\test, {
	| freq = 500 |
	var sig, env;
	//sig = SinOscFB.ar(
	//freq.lag(0.2) * SinOscFB.ar(freq/(500*(1/freq)))!2
	//);
	//freq = freq.linlin(500,5000,1,10);
	//freq=freq.lag(0.2);
	env = Env.perc(0.001,1.5).kr(doneAction:2);//gate:Impulse.kr(freq));
	//sig = SinOsc.ar(500*CombN.ar(SinOscFB.ar(500,freq/10),0.2,0.1),freq/10) * env;
	//sig = ;//VarSaw.ar(64+(freq.lag(0.2)*2)) * env;

	sig = Gendy4.ar(minfreq:freq, maxfreq:freq);
	//sig = sig + CombN.ar(SinOscFB.ar(60,1,1),0.2,0.01);
	//sig = Saw.ar(freq);
	sig = sig * 10;

	
	//sig = BPF.ar(sig,freq/10,freq.linlin(500,5000,0.01,1.0));
	//sig = Ringz.ar(sig, 20, 0.01);
	//	sig = LPF.ar(sig, 70);
	//sig = SinOsc.ar(freq);
	//sig = BPF.ar(WhiteNoise.ar(),freq,0.01);
	//sig = Shaper.ar(~wt0Buf,SinOsc.ar(60*Shaper.ar(~wt0Buf,SinOsc.ar(500)),SinOsc.ar(666)));
	//sig = SinOsc.ar(1050*SinOsc.ar(50).range(freq,(freq.neg)));
	//freq.poll;
	//sig = sig* env*0.01;
	sig = sig* env;
	//OscN.ar(~wt0Buf,0.5,phase:OscN.ar(~wt0Buf,freq.linlin(1,10,0.5,2.0)));//(10*freq)*COsc.ar(~wt0Buf));//,freq.linlin(1,10,0.0,2.0)));
	//sig = sig * env;
	//sig = HPF.ar(sig, 20);
	//sig = sig!2;
	//sig = SoftClipAmp.ar(sig, 0.2);
	//sig = sig * LFGauss.ar(0.000155212) * env;
	//sig = CombC.ar(Pulse.ar(44+freq),0.2,0.1/freq);//Gendy5.ar(minfreq:freq*80, maxfreq:freq*80),0.2,0.01)*0.1;
	
	Out.ar(0, sig*0.04!2)
}).add;
	0.2.wait;
	100.do{
		//freq = rrand(500, 600);
		frequency = rrand(0.0, 60.2);
		//frequency =frequency.linlin(0.0,60.2,1.0,10.0)*500;
		frequency =frequency.linlin(0.0,60.2,261.6255653006,7902.1328200779);
		frequency = ~mapToScale.value(frequency);
		
		/*if (freq < 600){freq = 500; Synth("test",[\freq,freq])};
		if ((freq < 700) && (freq > 600)){freq = 600;Synth("test",[\freq,freq])};
		if ((freq < 800) && (freq > 700)){freq = 700;Synth("test",[\freq,freq])};
		if ((freq < 900) && (freq > 800)){freq = 800;Synth("test",[\freq,freq])};
		if ((freq < 1000) && (freq > 900)){freq = 900;Synth("test",[\freq,freq])};*/
		//x.set(\freq, freq);
		Synth("test",[\freq,frequency]);

		//Synth("bjor",[\amp,0.1,\freq,frequency]);
		frequency.postln;
		0.04.wait;
		
	}
}
//:

//:
play{CombC.ar(WhiteNoise.ar(0.1), 0.2, 0.02)!2*0.1*Env.perc(0.0,0.3).kr(gate:Impulse.kr(2));}

//:
(1..10)* gauss(1,0.01)
//:
//~wt0 = Signal.chebyFill(512, [0.0,0.2,1.0,0.1,0.5]);
~wt0 = Signal.sineFill(512, [1,2,4,8]);
~wt0Buf = Buffer.loadCollection(s, ~wt0.asWavetable);
~wt0.plot;

//:
Signal.chebyFill(1000, [1]).plot;

// shifted to avoid DC offset when waveshaping a zero signal
Signal.chebyFill(1000, [0, 1], zeroOffset: true).plot;

// normalized sum of (unshifted) Chebyshev polynomials (the default)
Signal.chebyFill(1000, [0, 1, 0, 0, 0, 1], normalize: true, zeroOffset: false).plot;

Signal.chebyFill(1000, [0, 0, 1]).plot;
Signal.chebyFill(1000, [0.3, -0.8, 1.1]).plot;







//:
~wt0 = Env(
	[0.5,0.6,0.1,0.4,1.0,0.0,0.5,0.3]
).asSignal(512);
~wt0Buf = Buffer.loadCollection(s, ~wt0.asWavetable);

x = play{|freq|OscN.ar(~wt0Buf, 200*OscN.ar(~wt0Buf,0.1), mul:0.1*Env.perc(0.0,0.1).kr)!2} 



//:















