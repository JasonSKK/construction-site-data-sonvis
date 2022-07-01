// Svoronos Kanavas Iason -- Map to Lydian scale patch
// LiU Apr. 2022 -- construction site data SonVis

~lydScale= Scale.lydian.ratios * 36.midicps * 1; // first octave of lydian scale | Do/C

// lydian scale expansion setup 
{|i=1|
for(1,4){ | array |
	i = i*2; // next octave
	// i.postln; // post ratios
	~lydScale = ~lydScale.addAll(//~lydScale.size, // insert to the next (from last) pos
		Scale.lydian.ratios * 36.midicps*i); // multiply ratios*next_octave_ratio=next_octave
}}.value();
Post << ~lydScale; // post everything 
// ~lydScale[0] // tests

// incomingVal must be mapped to freq according min and max of the lydian Scale
// min: 261.6255653006 | max: 7902.1328200779
~mapToScale = {
	| incomingVal | 
	var corrFreqValue, tempList;
	tempList = (~lydScale - incomingVal).abs;
	corrFreqValue = ~lydScale[tempList.minIndex()];
	// corrFreqValue.postln; // dont post it
};


// for noise levels 
~beatList = [0,2,4,6,8,10,12,14,16,18,20];

// it maps the freq mod values Noise lvls to the list above
~mapToBeat = {
	| incomingVal | 
	var corrFreqValue, tempList;
	tempList = (~beatList - incomingVal).abs;
	corrFreqValue = ~beatList[tempList.minIndex()];
	corrFreqValue.postln; // dont post it
};



("musical scale configuration loaded").postln;

// test
// smallest value // ~mapToScale.value(0.0) 
// greater value // ~mapToScale.value(1000000000.0) 

// more complex test
/*
fork{
	var frequency;
	100.do{
	frequency = rrand(0.0, 60.2);
	frequency =frequency.linlin(0.0,60.2,261.6255653006,7902.1328200779);
	~mapToScale.value(frequency);
	0.04.wait;	
	}}.value()
*/
