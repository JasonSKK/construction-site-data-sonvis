// Svoronos Kanavas Iason -- Synth patch
// LiU Apr. 2022 -- construction site data SonVis

// pm_25 wavetable bufums
Buffer.freeAll;
b=(); // buffer dictionary
b.wv_noise; // noise oscillator
b.wv_clean; // clean oscillator

x=();
x.pm10synth;
x.pm25synth;
x.noiseSynthDB;
x.busOut;

~busPM10=Bus.audio(s,2); // particle 25 synth
~busPM10Warnings=Bus.audio(s,2); // warning synths
~busPM25=Bus.audio(s,2); // particle 25 synth
~busPM25Warnings=Bus.audio(s,2); // warning synths
~busNoise=Bus.audio(s,2); // bus for Noise
~busHumid=Bus.audio(s,2); // bus for humidity
~busTrucks=Bus.audio(s,2); // bus for trucks

SynthDef(\busOut,{ |gatePM10=1,gatePM25=1,gateNoise=1,gateHumid=1,masterGate=0,wet=1.0,t60=1.0,revGate=1,truckGate=1|
	var sigPM10 = In.ar(~busPM10,2) * gatePM10 * 0.5;
	var sigPM10Warnings = In.ar(~busPM10Warnings,2);
	var sigPM25 = In.ar(~busPM25,2) * gatePM25 * 0.5;
	var sigPM25Warnings = In.ar(~busPM25Warnings,2);
	var sigNoise = In.ar(~busNoise,2) * gateNoise;
	var sigHumid = In.ar(~busHumid,2) * gateHumid;
	var sigTrucks = In.ar(~busTrucks,2) * truckGate;
	var particlesSum = ((sigPM10 + sigPM10Warnings) * gatePM10 ) + ((sigPM25 + sigPM25Warnings) * gatePM25);
	var mix = ((particlesSum*2)+sigNoise+sigTrucks);
	var rev = mix +
	(JPverb.ar(mix,
		t60: t60,  // should be in sec values from 0.1 to 5 (60 theoretically)
		damp: 0.0,
		size: 10*t60,
		earlyDiff: 0.707,
		modDepth: 0.1,
		modFreq: 10,
		low: 1.0, mid: 1.0, high: 1.0,
		lowcut: 500.0, highcut: 1000) * Amplitude.kr(wet,0.4,1.2) /*amount*/ * revGate /*binary*/);
	//var effect= AllpassN.ar(rev,0.02,SinOsc.kr(MouseX.kr(1,),0,0.01,0.01)); //max delay of 20msec 
	var out = Out.ar(0,Limiter.ar(rev) * masterGate);
	//(rev*2+sigNoise) + Resonator.ar(input: particlesSum+sigTrucks, freq: 400, position: 1, resolution: 24, structure: 0.5, brightness: 0.5, damping: 0.4) * 0.1	
}).add;

// pm 10
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
	Out.ar(~busPM10, sig);
};

// pm 25
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
	Out.ar(~busPM25, sig);
};

// pm 10 -- Warnings
SynthDef(\warning_pm10, {
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
	Out.ar(~busPM10Warnings, Pan2.ar(out, pan)); 
}).add;

// pm 25 -- Warnings
b.wv_noise = Buffer.alloc(s, 512, 1, { |buf| var a = Array.fill(10, {625.rand}); buf.sine2Msg(a,[1,0,1,0,1,1])}); // noisy wavetable
b.wv_clean = Buffer.alloc(s, 512, 1, { |buf| var a = (1..30); buf.sine2Msg(a,a)}); // clean wavetable

SynthDef(\warning_pm25, {
    | freq = 440, amp = 0.5, mix = 0.3, room = 100, detuneMin = 1.00, detuneMax = 1.00, pm25_downwards, pm25_upwards, pan, rel |
    var sig, env, out, sum, sig1, sig2;
    sig1 = Shaper.ar(b.wv_clean.bufnum, SinOsc.ar(freq)*LFNoise1.ar(10.0).range(detuneMin, detuneMax)); // clean osc
	sig2 = Shaper.ar(
		bufnum: b.wv_noise.bufnum,
		in: Gendy5.ar(minfreq:freq,maxfreq:freq)) * SinOscFB.ar(1000,1).range(0.0, 1.0); // noisy osc
	sum = (pm25_downwards*sig1)+(pm25_upwards*sig2);//Mix([sig1*0.5,sig2*0.0]);
    env = Env.perc(0.003, rel).kr(doneAction:2);
    out = sum  * amp;
    //out = (out * 0.5) + DelayC.ar(out, 0.2, Rand(0.05, 0.3), 2*pi.reciprocal, out);
	out = Pan2.ar(out, pan);
	//out = FreeVerb2.ar(out, out, mix, room);
    Out.ar(~busPM25Warnings, out * env); 
}).add;

// synth for temperature
/*SynthDef(\tempSynth, {
	|freq=12,gate=1|
	var sig, trig;
	sig = Resonator.ar(
		input: LPF.ar(SinOsc.ar(freq*20),4000),
		freq:50,
		position: 0.001,
		resolution: 24,
		structure: 1.0,
		brightness: 0.4,
		damping:1) * EnvGen.kr(
			Env.adsr(0.0,0.3,0.5,2),
			gate:Line.kr(1,0,0.1),doneAction:2);
	sig = Splay.ar(sig,1)*0.1;
	sig = LPF.ar(sig,4000);
	Out.ar(0,sig.clip2(0.8));
}).add;

// Synth(\tempSynth, [\freq,2]);
*/

fork{ // needs some time to load synth before playing, otherwise it is not audiable
	// noise levels 

	// noise synth
	SynthDef(\noiseSynth, {
		| freq = 444, amp = 0.5, modf = 4, atk = 0.02, dec = 0.1, sus = 0.8, rel = 4, room = 100, revtime = 3, damping = 0.1, earlyreflevel = 1.2, spread = 100, gate, depth = 0.8, depth2 = 0.8, lpfCutoff = 6000, pwmWidth = 0.5, t60 = 1.0, wet = 1.0, pulvar=0 |
		var sig, env, out;
		sig = SinOsc.ar( // freq modulation
			freq:
			freq * SinOsc.ar( 
				freq: freq,// FM mod freq
				phase: Pulse.ar(freq/1.7619)) * (
					Pulse.ar(modf, pwmWidth, pulvar).range(depth,depth2)
					+VarSaw.ar(modf,mul:LinLin.kr(pulvar,0.0,1.0,1.0,0.0)).range(depth*2,(depth2*2).neg))); // RM | PWM
		/*sig = sig + (JPverb.ar(sig,
			t60: t60,  // should be in sec values from 0.1 to 5 (60 theoretically)
			damp: 0.0,
			size: 10,
			earlyDiff: 0.707,
			modDepth: 0.1,
			modFreq: 10,
			low: 1.0, mid: 1.0, high: 1.0,
			lowcut: 500.0, highcut: 1000) * wet);*/
		
		/*sig = GVerb.ar( // reverberation
			in: sig,
			roomsize: room,
			revtime: revtime,
			damping: damping,
			spread:spread,
			earlyreflevel:earlyreflevel) * 0.1;*/
		env = EnvGen.kr( // envelope
			Env.adsr( // adsr
				atk,
				dec,
				sus,
				rel), gate, doneAction:2);
		//sig = Resonator.ar(input: sig, freq: depth2.linlin(0.0,5.0,5.0,25.0), position: 0.0, resolution: 14, structure: 0.5, brightness: 1, damping: 0.3);
		out = sig * env * amp.lag(0.1) * 3.25;
		out = LPF.ar(out,lpfCutoff.lag(0.1)) * 2;
		out = Compander.ar(out, out,
			thresh: 0.1,
			slopeBelow: 1,
			slopeAbove: 0.1,
			clampTime:  0.01,
			relaxTime:  0.01);
		out = out!2;
		out = out.clip2(0.9);
		Splay.ar(out);
		//out = GVerb.ar(out);
		Out.ar(~busNoise, out);
	}).add;
	
	// another noise lvls synth
	/*SynthDef(\noiseSynth, { | freq = 444, amp = 0.5, modf = 4, atk = 0.02, dec = 0.1, sus = 0.8, rel = 4,
		room = 100, revtime = 3, damping = 0.1, earlyreflevel = 1.2, spread = 100, gate, depth = 0.1, depth2 = 0.1,
		lpfCutoff = 6000, pwmWidth = 0.5, t60 = 1.0, wet = 1.0 |
		var l, sig, out, res;
		l = Line.kr(0.00,0.9, Rand(0.01, 0.04));
		sig = SinOsc.ar(LFDNoise3.ar(l.range(10500, 2))*(rrand(1, 2) * 666))*l.exprange(1,8);
		sig = sig * LFPulse.kr(modf).range(depth,depth2);
		sig = Resonator.ar(input: sig, freq: depth2.linlin(0.0,5.0,5.0,15.0), position: 0.0, resolution: 32, structure: 0.5, brightness: 0.8, damping: 0.5) * 0.01; 
		sig = LPF.ar(sig,lpfCutoff).clip2(0.9); // 10000
		sig = sig!2;//Splay.ar(sig!2);
		Out.ar(~busNoise, sig*MouseX.kr(0.0,1.0));
	}).add;*/
	
	s.sync; // sync it so that server manages to load the synthdef before playing it

	// play noise synth -- noise levels db
	x.noiseSynthDB = Synth(\noiseSynth, [\amp, 0.1, \depth, 0, \depth2, 0, \modf, 0.01, \lpfCutoff, 6000, \pulvar, 0, \gate, 1]); // 60 Hz LPF so that it is not audiable in the begining

	s.sync; // sync so that server manages to play the synth before opening its output bus
	// play last -- it is the bus
	x.busOut = Synth(\busOut, addAction:\addToTail); // open master :) 
};


// tests
//x.noiseSynthDB.set(\modf,7,\depth2,0,\depth,0, \pwmWidth, 0.5, \amp,0.01);
//x.busOut.set(\masterGate,1,\wet,0,\t60,0.0);
//x.pm25synth.free;

("synthdefs loaded").postln;