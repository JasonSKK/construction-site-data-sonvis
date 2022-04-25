// consider -bc of ancient greek scale kationtes, to apply this in the sonification -- so more particles lower note instead of higher-

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
	corrFreqValue.postln;
};

// ~mapToScale.value(500); // test
// test
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


// smallest value // ~mapToScale.value(0.0) 
// greater value // ~mapToScale.value(1000000000.0)
