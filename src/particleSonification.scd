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
	pm_25min, pm_25max,
	dbmin, dbmax;
	
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
			],
			[\db,
				~minmax.value("df_out/particles_processed.csv",
					//"sommargagata_dev_11_temp_pm_30s.csv"
					"db")];
		];
		1.wait;
		temperatureMin = rawList_minmax[0][1][0]; // temp min 
		temperatureMax = rawList_minmax[0][1][1]; // temp max
		humidityMin = rawList_minmax[1][1][0];  // hum min
		humidityMax = rawList_minmax[1][1][1]; // hum max
		pm_10min = rawList_minmax[3][1][0]; // pm_10 min
		pm_10max = rawList_minmax[3][1][1]; // pm_10 max
		pm_25min = rawList_minmax[2][1][0]; // pm_25 min
		pm_25max = rawList_minmax[2][1][1]; // pm_25 max
		dbmin = rawList_minmax[4][1][0]; // db min
		dbmax = rawList_minmax[4][1][1]; // db max

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
		d.dbmin=dbmin;
		d.dbmax=dbmax;
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
		pm_10Map01, pm_25Map01, // linear mapping product: 0 to 1
		pm_10MapFreq, pm_25MapFreq, // freq mapping
		pm_10MapAmp, pm_25MapAmp, // amp mapping
		minScaleLow, maxScaleLow, minScaleHi, maxScaleHi, // scale mapping min max playing octave for synths
		db, dbMap01, dbRound, dbRoundMap; // db unmapped and mapped 0-1
		
		// post 
		// msg.postln;
		
		// write incoming values to variables
		temperature = msg[2];
		humidity = msg[3];
		pm_25 = msg[4];
		pm_10 = msg[5];
		db = msg[6];
		
		// --- START --- linear mapping
		temperatureMap = temperature.linlin(d.temperatureMin,d.temperatureMax,0.0,1.0);
		humidityMap = humidity.linlin(d.humidityMin,d.humidityMax,0.0,1.0);
		pm_10Map01 = pm_10.linlin(d.pm_10min,d.pm_10max,0.0,1.0); // big particles
		pm_25Map01 = pm_25.linlin(d.pm_25min,d.pm_25max,0.0,1.0); // small particles
		dbMap01 = db.linlin(d.dbmin,d.dbmax,0.0,1.0);
		// ---- END ---- linear mapping 

		// --- START --- map to lydian scale
		minScaleLow = 130.8127826503; // low synth panned left
		maxScaleLow = 261.6255653006; 
		minScaleHi = 261.6255653006; // hi synth panned right
		maxScaleHi = 523.2511306012;

		
		// map within range
		pm_10Map = pm_10Map01.linexp(
			0.0,1.0,minScaleLow,maxScaleLow);//261.6255653006,523.2511306012); // 3rd octave Lydian
		pm_25Map = pm_25Map01.linexp(
			0.0,1.0,minScaleHi,maxScaleHi);//1046.5022612024,1975.5332050195); // 5th octave Lydian

		
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

		
		// detuning  -- fix it
		if((pm_10-8).isPositive == true,{ pm_10MapFreq = pm_10MapFreq+[
			pm_10.linlin(d.pm_10min,d.pm_10max,5, 10),
			pm_10.linlin(d.pm_10min,d.pm_10max,5, 10)].choose});

		// pm10 to gendy -- panned left 
		x.pm10synth.set(
			\freq, pm_10MapFreq, // mapped to scale frequency
			\minScale, minScaleLow, // for mapping within synth
			\maxScale, maxScaleLow, 
			\relSmoothing, pm_10Map01.lag(0.2), // smooth relese to highlight trends
			\pan, -0.9,
		); 
		// pm25 to gendy -- panned right
		x.pm25synth.set(
			\freq, pm_25MapFreq,
			\minScale, minScaleHi,
			\maxScale, maxScaleHi,
			\relSmoothing, pm_25Map01.lag(0.2),
			\pan, 0.9,
		);


		// --- WARNINGS ---
		if(pm_10 > 40){ // if exceeds a level pm10 big particles
			var warning_values10_freq, amp_wv10, rel_wv10, pan_wv10,
			mixingValue, mixingValueOposite; // factor for mixing gendys 
			warning_values10_freq = ~mapToScale.value(pm_10MapFreq*4); // warning frequency values
			amp_wv10 = pm_10Map01.linlin(0.0,1.0,0.1,0.4); // amplitude mapping
			rel_wv10 = pm_10Map01.linlin(0.0,1.0,1,5.0); // env release mapping
			mixingValue = pm_10Map01; // determines amount: mix gendy4 and gendy2 (G4:close to 12, G2:)
			pan_wv10 = LinLin.kr(pm_10Map01,0.0,1.0,-1.0,-0.5); // pan 4 pm10 warning
			mixingValueOposite = LinLin.kr(pm_10Map01, 0.0, 1.0, 1.0, 0.0);
			Synth(\warning_pm10, [ // warning values synth
				\freq, warning_values10_freq,
				\amp, amp_wv10, // amplitude, louder for higher/dangerous values
				\rel, rel_wv10, // envelope release
				\pan, pan_wv10, // panned left (this is pm_10Map01 but inverted and ranged)
				\pm10_upwards, mixingValue,
				\pm10_downwards, mixingValueOposite,
			]);
			pm_10.postln; // post exceeding value
		};

		if(pm_25 > 12){ // if exceeds a level pm25 small particles
			var warning_values25_freq, amp_wv25, rel_wv25, pan_wv25,
			mixingValue, mixingValueOposite; // factor for mixing gendys 
			warning_values25_freq = ~mapToScale.value(pm_25MapFreq*4); // warning frequency values
			amp_wv25 = pm_25Map01.linlin(0.0,1.0,0.1,0.4); // amplitude mapping
			rel_wv25 = pm_25Map01.linlin(0.0,1.0,1,5.0); // env release mapping
			mixingValue = pm_25Map01; // determines amount: mix gendy4 and gendy2 (G4:close to 12, G2:)
			pan_wv25 = LinLin.kr(pm_25Map01,0.0,1.0,1.0,0.5); // pan 4 pm25 warning
			mixingValueOposite = LinLin.kr(pm_25Map01, 0.0, 1.0, 1.0, 0.0);
			Synth(\warning_pm25, [ // warning values synth
				\freq, warning_values25_freq,
				\amp, amp_wv25, // amplitude, louder for higher/dangerous values
				\rel, rel_wv25, // envelope release
				\pan, pan_wv25, // panned left (this is pm_25Map01 but inverted and ranged)
				\pm25_upwards, mixingValue,
				\pm25_downwards, mixingValueOposite,
			]);
			pm_25.postln; // post exceeding value
		};

		// --- Noise Levels --- db

		// smooth below 68 and drilling above
		//dbRound = db.round(68); // 68 is the acceptable city noise
		//case{ db > 68} {
		//dbRoundMap = (dbRound - db).abs;
		//dbRoundMap = dbRoundMap.linlin(0.0,d.dbmax-68,10.0,20)}
		//{ db < 68 } { dbRoundMap = 0}; // add to 68 to reach new val
		//[db,dbRoundMap].postln;

		x.noiseSynthDB.set(\modf,20*dbMap01);//,dbRoundMap);
		x.noiseSynthDB.set(\depth,0.0);
		x.noiseSynthDB.set(\depth2,1.0);
		x.noiseSynthDB.set(\amp,dbMap01.linlin(0.0,1.0,0.05,0.3));
		x.noiseSynthDB.set(\lpfCutoff,dbMap01.linlin(0.0,1.0,3000,18000));
		//x.noiseSynthDB.set(\depth,0.5+dbMap01*2);
		//x.noiseSynthDB.set(\depth2,0.0+dbMap01); // depth2 = depth.neg
		x.noiseSynthDB.set(\freq,120+((500)*dbMap01));

					
	}, '/pysc' // osc address 
);

(~path++"/synthDefs.scd").standardizePath.load;
//:
//s.meter
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
