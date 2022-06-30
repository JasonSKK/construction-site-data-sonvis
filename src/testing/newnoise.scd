Resonator.ar(input: particlesSum+sigTrucks, freq: 400, position: 1, resolution: 24, structure: 0.5, brightness: 0.5, damping: 0.4) * 0.1	


//:
SynthDef(\noiseSynth, { | freq = 444, amp = 0.5, modf = 4, atk = 0.02, dec = 0.1, sus = 0.8, rel = 4, room = 100, revtime = 3, damping = 0.1, earlyreflevel = 1.2, spread = 100, gate, depth = 0.1, depth2 = 0.1, lpfCutoff = 6000, pwmWidth = 0.5, t60 = 1.0, wet = 1.0 |
	var l, sig, out, res;
	l = Line.kr(0.01, 0.8, Rand(0.01, 0.04));
	sig = SinOsc.ar(LFDNoise3.ar(l.range(18000, 2) ! 2) * (Rand(1, 2) * 600)) * l.exprange(1, 8);
	sig = sig * LFPulse.kr(modf).range(0,depth2);
	sig = Resonator.ar(input: sig, freq: depth2.linlin(0.0,5.0,5.0,15.0), position: 0.0, resolution: 32, structure: 0.5, brightness: 0.8, damping: 0.5) * 0.1; 
	sig = LPF.ar(sig,lpfCutoff); // 10000
	Out.ar(~busNoise, sig.clip2(0.9));
}).add;

/*| freq = 444, amp = 0.5, modf = 4, atk = 0.02, dec = 0.1, sus = 0.8, rel = 4, room = 100, revtime = 3, damping = 0.1, earlyreflevel = 1.2, spread = 100, gate, depth = 0.8, depth2 = 0.8, lpfCutoff = 6000, pwmWidth = 0.5, t60 = 1.0, wet = 1.0 |*/
//:
// notes
// freq 5-15
// structure 1.0-0.0

//:
	SynthDef(\explosion2, {arg i_out, freq = 200, pan=0.5, amp=0.1;
		var ae,sig,finalsig;
		ae = EnvGen.kr(Env.asr(0, 1, 0.00, 1, 0));
		sig = Impulse.ar(0);
		sig = LPF.ar(FreeVerb2.ar(sig,sig,0.2,0.25,0.1),freq);
		sig = (sig*5000).tanh;
		sig = LPF.ar(sig,8000);
		finalsig = amp*ae*sig;
		DetectSilence.ar(finalsig, doneAction:Done.freeSelf);
		Out.ar(0, finalsig);
	}).play;


