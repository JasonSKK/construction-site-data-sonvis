// Svoronos Kanavas Iason -- trucks function & synth patch
// LiU Apr. 2022 -- construction site data SonVis

SynthDef(\truck, {
    |freq = 440, amp = 0.5|
    var sig, env, out, rel;
	sig = VarSaw.ar(freq);
	rel = LinLin.kr(freq,100,1975.5332050195,0.1,0.6); // last note of lydian collection
    env = Env.perc(0.0, rel).kr(doneAction:2);
    out = sig  * amp * env * LinLin.kr(freq,100,1975.5332050195,0.05,0.3) * 0.5;
	out = Splay.ar(out);
    Out.ar(~busTrucks,Pan2.ar(out,0))
}).add;
//Synth(\truck,[\freq,~mapToScale.value(400)]);

//i=Synth(\wss2,[\freq,50*detune]);

~playTrucks = {
	|num=0| // trucks: max value in column = 9, min value in column = 0
	var detune,bw,freq;
	detune=num.linlin(0,9,1,1.11); // min=0,max=9 to 1 and 1.9 detune
	bw=num.linexp(0.0,9,10,400);
	freq=detune*50;
	freq=LinLin.kr(num,0,9,100,1975.5332050195); // last note from lydian collection
	fork{
			Synth(\truck,[\freq,~mapToScale.value(freq)]);
	};
	~last=freq;
};

// plays on initialisation start 
~playTrucks.value(9); // test numer of trucks 

("truck functions & synth loaded").postln;
