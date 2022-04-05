// Svoronos Kanavas Iason -- Particle Sonification patch
// LiU Apr. 2022 -- construction site sonification

// configure network address
// ~n = NetAddr("10.253.228.207", 57120);

OSCdef(\incoming,
	{
		| msg, freq  | 
		var temp;
		// post 
		msg.postln;
		play{
			SinOsc.ar(
				msg[4].linlin(
					1.8999999761581, 2.0, 400, 1000)) * Env.perc(0.01,0.05).kr(doneAction:2)}
				
	}, '/pysc' // osc address 
);
