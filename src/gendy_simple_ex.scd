// =====================================================================
// SuperCollider Workspace
// =====================================================================
x=();
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
//:
x.left = play{|freq=130|
	var amp, sig, cp, minScale, maxScale;
	minScale=130.8127826503;
	maxScale=261.6255653006;
	freq=Amplitude.kr(freq,0.1,1);
	amp = LinLin.kr(freq,minScale,maxScale,0.1,1.0);
	cp = freq.linlin(minScale,maxScale,10,200);
	sig = CombC.ar(
		SinOscFB.ar(freq*
		Gendy2.ar(
			freq:freq,
			minfreq:freq,
			maxfreq:freq,
			initCPs:cp,
			add:amp),feedback:amp)*amp*0.1,0.2,4/freq);
	sig = sig + LPF.ar(GrayNoise.ar(0.001),LFNoise1.ar(0.5).range(1000,20000));
	sig = Pan2.ar(sig, pos:-0.8);
	//*amp*0.1);
	//Out.ar(~bus1,sig);	//sig = BPF.ar(sig,freq);
};

x.right = play{|freq=261|
	var amp, sig, cp, fRaw, minScale, maxScale;
	minScale=261.6255653006;
	maxScale=523.2511306012;
	fRaw=freq;
	freq=Amplitude.kr(freq,0.1,1);
	amp = LinLin.kr(freq,minScale,maxScale,0.1,1.0);
	cp = freq.linlin(minScale,maxScale,10,200);
	sig = CombN.ar(
		SinOscFB.ar(freq*
			Gendy5.ar(
				freq:freq,
				minfreq:freq,
				maxfreq:freq,
				initCPs:cp,
				add:amp),feedback:amp)*amp*0.1,0.2,4/freq);
	sig = sig + LPF.ar(GrayNoise.ar(0.001),LFNoise1.ar(0.5).range(1000,20000));
	sig = Pan2.ar(sig,pos:0.8);
		
	//Out.ar(~bus2,sig);
	//sig = BPF.ar(sig,freq);
};

x.right.set(\freq,261)

//:
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



//:
x.left.set(\freq,509);
s.meter