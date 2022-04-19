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
1000.do{
	x.set(\freq,rrand(500, 1800));
	0.04.wait;
}
}
//:
x = SynthDef(\test, {
	| freq = 500 |
	var sig, env;
	//sig = SinOscFB.ar(
	//freq.lag(0.2) * SinOscFB.ar(freq/(500*(1/freq)))!2
	//);
	freq = freq.linlin(500,1800,1,10);
	freq=freq.lag(0.1);
	env = Env.perc(0.02,0.1).kr(gate:Impulse.kr(freq));
	//sig = SinOsc.ar(500*CombN.ar(SinOscFB.ar(500,freq/10),0.2,0.1),freq/10) * env;
	//sig = ;//VarSaw.ar(64+(freq.lag(0.2)*2)) * env;
	//sig = Gendy1.ar(minfreq:freq*50, maxfreq:freq*50) * 0.2;
	//sig = Ringz.ar(sig, 20, 0.01);
	//	sig = LPF.ar(sig, 70);
	//sig = HPF.ar(sig, 20);
	//sig = sig!2;
	//sig = SoftClipAmp.ar(sig, 0.2);
	//sig = sig * LFGauss.ar(0.000155212) * env;
	//sig = CombC.ar(Pulse.ar(44+freq),0.2,0.1/freq);//Gendy5.ar(minfreq:freq*80, maxfreq:freq*80),0.2,0.01)*0.1;
	
	Out.ar(0, sig*0.1!2)
}).play;
//:
play{CombC.ar(WhiteNoise.ar(0.1), 0.2, 0.02)!2*0.1*Env.perc(0.0,0.3).kr(gate:Impulse.kr(2));}

//:
600/(500 * (1/600))















