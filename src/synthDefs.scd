// pm_25 wavetable bufums
Buffer.freeAll;
b=(); // buffer dictionary
b.wv_noise; // noise oscillator
b.wv_clean; // clean oscillator

x=();
x.pm10synth;
x.pm25synth;

~bus1=Bus.audio(s,2);
~bus2=Bus.audio(s,2);

SynthDef(\busOut,{
	var sig = In.ar(~bus1,2);
	var sig2 = In.ar(~bus2,2);
	var out = Out.ar(0,Balance2.ar(sig,sig2,0.0));
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
	Out.ar(~bus1, sig);
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
	Out.ar(~bus2, sig);
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
	Out.ar(0, Pan2.ar(out, pan));
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
    Out.ar(0, out * env); 
}).add;

// noise levels 
SynthDef(\perc, {
	| freq = 444, amp = 0.5, modf = 4, atk = 0.02, dec = 0.1, sus = 0.8, rel = 4, room = 100, revtime = 3, damping = 0.1, earlyreflevel = 1.2, spread = 100, gate, depth = 0.8, depth2 = 0.8, lpfCutoff = 6000, pwmWidth = 0.5 |
	var sig, env, out;
	sig = SinOsc.ar( // freq modulation
		freq:
		freq * SinOsc.ar( 
			freq: freq,// FM mod freq
			phase: Pulse.ar(freq/1.7619)) * Pulse.ar(modf, pwmWidth).range(depth,depth2.neg)); // RM | PWM
	sig = GVerb.ar( // reverberation
		in: sig,
		roomsize: room,
		revtime: revtime,
		damping: damping,
		spread:spread,
		earlyreflevel:earlyreflevel) * 0.1;
	env = EnvGen.kr( // envelope
		Env.adsr( // adsr
			atk,
			dec,
			sus,
			rel), gate, doneAction:2);
	out = sig * env * amp.lag(0.1);
	out = LPF.ar(out,lpfCutoff.lag(0.1));
	Out.ar(0, out!2);
}).add;

// play perc synth -- noise levels db
x.noiseSynthDB = Synth(\perc, [\amp, 0.02, \depth, 2.5, \depth2, 0, \modf, 0, \gate, 1, \lpfCutoff, 6000]);
//x.noiseSynthDB.set(\freq,221,\depth2,1,\depth,1, \modf,10)

// play last -- it is the bus
Synth(\busOut, addAction:\addToTail);

/*
for the noise
b = Buffer.alloc(s, 512, 1, { |buf| var ar = Array.fill(10, {654.rand.postln}); buf.sine2Msg(ar,[1,0,1,0,1,1])});//Bellish

//:
c = Buffer.alloc(s, 512, 1, { |buf| var ar = Array.fill(8, {1.0.rand.round(0.001).postln}); buf.sine1Msg(ar)});//El.Guitar

//:
SynthDef("wts_rr", {
    | freq = 440, amp = 0.5, mix = 0.3, room = 100 |
    var sig, env, out, sum, sig1, sig2;
    sig1 = Shaper.ar(b.bufnum, SinOsc.ar(freq*LFNoise2.kr(1000).range(0.1, 1.0)), Pulse.ar(LFNoise1.kr(500).range(3,4)));
	sig2 = Shaper.ar(c.bufnum, LFSaw.ar(freq, LFNoise2.kr(1).range(0.0, 1.0)));
	sum = Mix([sig1*0.5,sig2*0.5]);
    env = Env.perc(0.003, pi/2).kr(doneAction:2);
    out = sum  * amp;
    //out = (out * 0.5) + DelayC.ar(out, 0.2, Rand(0.05, 0.3), 2*pi.reciprocal, out);
	out = FreeVerb2.ar(out, out, mix, room);
    Out.ar(0, out * env); 
}).add;
Synth("wts_rr");
//:
Pbind(
    \instrument,
    \wts_rr,
    \dur, Prand([0.5],inf),
    \scale, Scale.minor,
    \root, -2,
    \degree, Pseq([0, 7, 5, 10, 3, 12, 3, 2, 3, 7, 2, 0],inf),
    \octave, Pseq([Pseq([5], 8), Pseq([6],4)],inf)-1,
    \oct, [2,4,6].choose,
    \susTime, Pwhite(0.1, 0.4,inf),
    \amp, Pwhite(0.5, 0.888, inf)* 0.2,
    \tempo, 100/60,
).play

*/
/*
//:

SynthDef("perc", {
	| freq = 444, amp = 0.5, modf = 4, atk = 0.01, dec = 0.4, sus = 0.8, rel = 4, room = 100, revtime = 3, damping = 0.1, earlyreflevel = 1.2, spread = 100, gate, depth = 0.8, depth2 = 0.8 |
	var sig, env, out;
	sig = SinOsc.ar( // freq modulation
		freq:
		freq * SinOsc.ar( 
			freq: // FM mod freq
			freq,
			phase: Pulse.ar(freq/1.7619)) * Pulse.ar(modf).range(depth,depth2.neg)); // RM | PWM
	sig = GVerb.ar( // reverberation
		in: sig,
		roomsize: room,
		revtime: revtime,
		damping: damping,
		spread:spread,
		earlyreflevel:earlyreflevel) * 0.1;
	env = EnvGen.kr( // envelope
		Env.adsr( // adsr
			atk,
			dec,
			sus,
			rel), gate, doneAction:2);
	out = sig * env * amp; 
	Out.ar(0, out);
}).add;
//:
// if constant depth = 1 depth2 =0, modf=0
//:
x = Synth("perc", [\gate, 1, \modf, 2, \freq, 444]);
x.set(\modf,0)
x.set(\depth,1)
x.set(\depth2,0.0)
x.set(\freq,188)
*/