// Svoronos Kanavas Iason -- Particle Sonification patch
// LiU Apr. 2022 -- construction site sonification

d=(); // create dictionary for min max values

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
		pm_10min = rawList_minmax[2][1][0]; // pm_10 min
		pm_10max = rawList_minmax[2][1][1]; // pm_10 max
		pm_25min = rawList_minmax[3][1][0]; // pm_25 min
		pm_25max = rawList_minmax[3][1][1]; // pm_10 max

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
d;
"/Users/jsk/Coding/LiU/constructionSightSonification/src/scale_exp.scd".standardizePath.load;
// incoming osc msg
OSCdef(\incoming,
	{
		| msg, freq  | 
		var temperature, humidity, pm_10, pm_25, // unmapped values
		temperatureMap, humidityMap, pm_10Map, pm_25Map; // mapped values
		
		// post 
		msg.postln;
		
		// write incoming values to variables
		temperature = msg[2];
		humidity = msg[3];
		pm_25 = msg[4];
		pm_10 = msg[5];
		

		// --- START --- linear mapping
		temperatureMap = temperature.linlin(d.temperatureMin,d.temperatureMax,0.0,1.0);
		humidityMap = humidity.linlin(d.humidityMin,d.humidityMax,0.0,1.0);
		pm_25Map = pm_25.linlin(d.pm_25min,d.pm_25max,0.0,1.0);
		pm_10Map = pm_10.linlin(d.pm_10min,d.pm_10max,0.0,1.0);
		// pm_25Map = pm_25.linexp(d.pm_25min,d.pm_25max,1e-2,1.0); 
		// ---- END ---- linear mapping 
		//(50+(pm_25Map*400)).postln;
		//Synth("test",[\freq,pm_25Map.linlin(0.0,60.2,1.0,10.0)*500]);
		// x.set(\freq,pm_25Map*1000*50); // SinOscFB 
		// single sinewave
		pm_10Map =pm_10Map.linexp(0.0,1.0,261.6255653006,7902.1328200779);
		pm_10Map.postln;
		pm_10Map = ~mapToScale.value(pm_10Map);
		play{
			Gendy4.ar(minfreq:pm_10Map, maxfreq:pm_10Map)!2*
			//SinOsc.ar(pm_10Map)*
		Env.perc(0.0,1.1,curve:-8).kr(doneAction:2)};
		/*play{
		SinOsc.ar(
			(pm_25Map*1000)*50)* Env.perc(0.0,0.1,curve:-8).kr(doneAction:2)};*/
		
	}, '/pysc' // osc address 
);

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
