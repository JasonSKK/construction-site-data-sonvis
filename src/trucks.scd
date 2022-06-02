// Svoronos Kanavas Iason -- trucks function & synth patch
// LiU Apr. 2022 -- construction site sonification

/*  // OLD METHOD, cranky, μανιβέλα φουλ βασικά αλλά ντάξ
// truck data processing
~tracksRaw=FileReader.read((~path+/+"fake_passage_time.csv").standardizePath);
~tracksTempDate = ~tracksRaw[2][0].split($;)[0]; // date 
~tracksTempTime = ~tracksRaw[2][1].split($;)[0]; // time
~tracksAmount = ~tracksRaw[2][1].split($;)[1]; // count
~tracksTempDateTime = ~tracksTempDate+~tracksTempTime; // compare this string with the current if same then play trucks if not there was no date in the truck data

~truckCountFunc = {|inputCount| // compare the truck date with the current datetime, if same then play trucks if not just ignore
	~tracksTempDate = ~tracksRaw[inputCount][0].split($;)[0]; // date 
	~tracksTempTime = ~tracksRaw[inputCount][1].split($;)[0]; // time
	~tracksAmount = ~tracksRaw[inputCount][1].split($;)[1]; // count
	~tracksTempDateTime = ~tracksTempDate+~tracksTempTime; 
};
*/

SynthDef("truck", {
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
	detune=num.linlin(0,9,1,1.9); // min=0,max=9 to 1 and 1.9 detune
	bw=num.linexp(0.0,9,10,400);
	freq=detune*50;
	freq=LinLin.kr(num,0,9,100,1975.5332050195); // last note from lydian collection
	fork{
		//num.do{
			Synth(\truck,[\freq,~mapToScale.value(freq)]);
			
			//Synth(\wss2,[\freq,freq,\last,~last]);
			//i.set(\freq,detune*100);
			//play{
				//Pan2.ar(Gendy4.ar(minfreq:50*detune,maxfreq:120*detune))*Env.perc(0.0,0.1).kr(doneAction:2);
					//Gammatone.ar(
					//	WhiteNoise.ar(1),Rand(300,300*detune),bw)*100,
					//Line.kr(1,-1,1)).clip2(0.01)*EnvGen.kr(Env.adsr(0.0,0.0,1.0,0.1),Line.kr(1,0,0.01),doneAction:2);
			//	};
		//0.02.wait;
		//};
	};
	~last=freq;
};

//
//
~playTrucks.value(9); // test numer of trucks 

("truck functions & synth loaded").postln;

// play{
// 	Out.ar(0,Pan2.ar(
// 		Env.perc(0.0,3).kr(doneAction:2)*
// 		LPF.ar(
// 		LFSaw.ar(LFSaw.ar(50)*XLine.kr(6500,400,1,doneAction:0)*0.1),400)*1,
// 		pos:Line.kr(1,-1,1)).clip2(0.4))
// };
// 
// s.record("/Users/jsk/Desktop/truck.wav");



/* ----- OTHER SYNTHS ----
g = Buffer.alloc(s, 512, 1, { |buf| var ar = Array.fill(8, {1.0.rand.round(0.001).postln}); buf.sine1Msg(ar)});//El.Guitar
//b = Buffer.alloc(s, 512, 1, { |buf| var ar = Array.fill(10, {654.rand.postln}); buf.sine2Msg(ar,[1,0,1,0,1,1])});//Bellish
(
SynthDef("wss2", {
    |freq = 440, amp = 0.5,trig=1,last=0|
    var sig, env, out;//Bufnum->Before__SoundOfAnLFSaw-Controls____LFNoiseAsLFO(Phase)&&UnCommentForAVariation
	freq=EnvGen.kr(Env([last,freq],[1]),gate:trig);
    sig = Shaper.ar(g.bufnum, LFSaw.ar(freq, LFNoise2.kr(1).range(0.0, 1.0), /*SinOsc.kr(Line.kr(1, 12, 1, 0.1))*/));
    env = Env.perc(0.003, 0.6).kr(doneAction:2);//Amp_Env
    out = sig  * amp;
    out = (out * 0.5) + DelayC.ar(out, 0.2, Rand(0.05, 0.3), 2*pi.reciprocal, out);//SomeDelay
    Out.ar([0,1], GVerb.ar(out, 100, pi*pi, 0.28 , 0.5, pi**2.5, pi.reciprocal, 0.5, 0.3) * env * 0.5)
}).add//________TwoChanReverb___...Arguments..._Multiply env__After Reverb_ifNot->>it Clicks
);
*/