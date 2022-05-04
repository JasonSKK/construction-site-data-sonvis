// Svoronos Kanavas Iason -- Particle Sonification patch
// LiU Apr. 2022 -- construction site sonification

// load lydian scale functions and configuration
("/Users/jsk/Coding/LiU/constructionSightSonification/src/scale_exp.scd".standardizePath).load;

d=(); // create dictionary for min max values

p=(); // synth parameters
// initialise synth parameters
p.relTime=0.1; // synth env release
p.prevFreq=0; // prev freq val played

// configure network address for visualisation
// ~n = NetAddr("10.253.228.207", 57120);

// configure current path
~path = thisProcess.nowExecutingPath.dirname;

// min max values function for columns in file | utilising minmax.py script
~minmax = { // 1st arg: filename | 2nd arg: column name as string
	| file, col |
	var com;
	com =  ("python"+(~path+/+"minmax.py").standardizePath+(~path+/+file)+col).unixCmdGetStdOutLines;
	(~path+/+file).postln;
	// command: python ./minmax.py filename.csv "columnname"
	com = com[3].replace(" ",",").split(","); // replace blank with comma and split it into 2 items as list
	com = com.asString.interpret; // convert it into a string and interpret | output: array
	// com.postln;
};

// run function and store output
~store_minmax = {
	var rawList_minmax, // raw list with min max values
	temperatureMin, temperatureMax,
	humidityMin, humidityMax, 
	pm_10min, pm_10max,
	pm_25min, pm_25max;
	
	fork{ // run script get output write min max to variables
		rawList_minmax = [
			[\temp,
				~minmax.value("df_out/particles_processed.csv",
					//"sommargagata_dev_11_temp_pm_30s.csv" // original dataset
					"temperature")],
			[\humidity,
				~minmax.value("df_out/particles_processed.csv",
					//"sommargagata_dev_11_temp_pm_30s.csv"
					"humidity")],
			[\pm_25,
				~minmax.value("df_out/particles_processed.csv",
					//"sommargagata_dev_11_temp_pm_30s.csv" // original dataset
					"pm_25")],
			[\pm_10,
				~minmax.value("df_out/particles_processed.csv",
					//"sommargagata_dev_11_temp_pm_30s.csv" // original dataset
					"pm_10")
			];
		];
		1.wait;
		temperatureMin = rawList_minmax[0][1][0]; // temp min 
		temperatureMax = rawList_minmax[0][1][1]; // temp max
		humidityMin = rawList_minmax[1][1][0];  // hum min
		humidityMax = rawList_minmax[1][1][1]; // hum max
		pm_10min = rawList_minmax[3][1][0]; // pm_10 min
		pm_10max = rawList_minmax[3][1][1]; // pm_10 max
		pm_25min = rawList_minmax[2][1][0]; // pm_25 min
		pm_25max = rawList_minmax[2][1][1]; // pm_10 max

		// post individually for identification purposes
		// temperatureMin.postln;
		// temperatureMax.postln;
		// humidityMin.postln;
		// humidityMax.postln;
		// pm_10min.postln;
		// pm_10max.postln;
		// pm_25min.postln;
		// pm_25max.postln;
		// rawList_minmax.postln;
		for( // post min max for each col 
			0, rawList_minmax.size, {
				|i| rawList_minmax[i].postln;}); 

		// write to minmax dictionary 
		d.temperatureMin=temperatureMin;
		d.temperatureMax=temperatureMax;
		d.humidityMin=humidityMin;
		d.humidityMax=humidityMax;
		d.pm_10min=pm_10min;
		d.pm_10max=pm_10max;
		d.pm_25min=pm_25min;
		d.pm_25max=pm_25max;
	};
};

~store_minmax.value();
// d; // print min max values

// incoming osc msg
OSCdef(\incoming,
	{
		| msg, freq  | 
		var temperature, humidity, pm_10, pm_25, // unmapped values
		temperatureMap, humidityMap, pm_10Map, pm_25Map, // mapped values
		pm_10MapFreq, pm_25MapFreq, // freq mapping
		pm_10MapAmp, pm_25MapAmp; // amp mapping
		
		// post 
		//msg.postln;
		
		// write incoming values to variables
		temperature = msg[2];
		humidity = msg[3];
		pm_25 = msg[4];
		pm_10 = msg[5];
		pm_25.postln;
		
		// --- START --- linear mapping
		temperatureMap = temperature.linlin(d.temperatureMin,d.temperatureMax,0.0,1.0);
		humidityMap = humidity.linlin(d.humidityMin,d.humidityMax,0.0,1.0);
		pm_10Map = pm_10.linlin(d.pm_10min,d.pm_10max,0.0,1.0); // big particles
		pm_25Map = pm_25.linlin(d.pm_25min,d.pm_25max,0.0,1.0); // small particles
		// ---- END ---- linear mapping 

		// --- START --- map to lydian scale
		// map within range
		pm_10Map = pm_10Map.linexp(
			0.0,1.0,130.8127826503,261.6255653006);//261.6255653006,523.2511306012); // 3rd octave Lydian
		pm_25Map = pm_25Map.linexp(
			0.0,1.0,261.6255653006,523.2511306012);//1046.5022612024,1975.5332050195); // 5th octave Lydian

		
		// map to exact lydian note
		pm_10MapFreq = ~mapToScale.value(pm_10Map);
		pm_25MapFreq = ~mapToScale.value(pm_25Map); 
		
		//[\pm10Lydian,pm_10MapFreq,\pm25Lydian,pm_25MapFreq].postln; // post it for confirming
		// --- END --- map to lydian scale

		// parameter setting: if particles exceed healthy limit
		//if(pm_10 >= 45,{p.relTime=4},{p.relTime=0.15});  // consider maping 
		//if(pm_25 >= 12,{"AAA".postln;},{"OOO"}); 

		//if(pm_10MapFreq != p.prevFreq){ // play only if the mapped value is a different note
		//	p.prevFreq = pm_10MapFreq; // played value, update previous freq 
			//x.set(\freq,pm_10MapFreq);
		//	p.prevFreq = pm_10MapFreq;
			
		//};
		x.left.set(\freq, pm_10MapFreq);
		x.right.set(\freq, pm_25MapFreq);
		//if(pm_10>312){ // if exceeds a level pm10 big particles
		//play{Gendy4.ar(minfreq:pm_10Map,maxfreq:pm_10Map,mul:0.15) * Env.perc(0.04,p.relTime).kr(doneAction:2)!2};};
			
					
	}, '/pysc' // osc address 
);
//:
x=play{|freq, detU=0.0|Mix.fill(10, {SinOsc.ar(Rand(0.999,1.001+LFNoise1.kr(3).range(0.0,9.0+detU))*freq.lag(0.2))}!10)!2*0.01};
x.set(\freq,422,\detU,0.0)


// NOISE LEVELS
play{Mix.fill(10,{SinOsc.ar(60,phase:LFNoise1.ar(MouseX.kr(1.0,10000).lag(0.1).poll).range(0.0,pi))!10})!2*0.01};
//


//x=play{|freq=200|BPF.ar(LFNoise0.ar(500)*Env.adsr().kr(gate:1,doneAction:2),freq)!2};
//Synth("test",[\freq,0.linlin(0.0,60.0,1.0,5.0)*500]);
/*SynthDef(\test, {
	| freq = 500 |
	var sig, env;
	env = Env.perc(0.001,1.5).kr(doneAction:2);//gate:Impulse.kr(freq));
	sig = Gendy2.ar(minfreq:freq, maxfreq:freq);
	sig = sig + OscN.ar(sig);
	sig = BPF.ar(sig,freq,freq.linlin(500,1800,0.001,1.0));
	sig = sig* env;

	Out.ar(0, sig*0.04!2)
}).play;
*/
/*
OSCdef(\start_end_receiver,{
	| msg |
	var id;
	msg[1].postln;
	id = msg[1].asInteger;
	switch (id,
		0, { 
			x.set(\gate, 0);
		},
		1, {
			x.set(\gate, 1);
		};
	);
},'/startEnd');

fork{
	2.wait;
x = play{|freq=500,gate|
	SinOscFB.ar(
		freq*SinOscFB.ar((freq/2)+(freq/freq).log10, freq*0.001),freq*0.001
	)*0.1*EnvGen.kr(Env.adsr(0.0,0.3,1.0),gate:gate)!2
};
}
*/
