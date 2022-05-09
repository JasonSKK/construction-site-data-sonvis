// =====================================================================
// SuperCollider Workspace
// =====================================================================


play{Mix.fill(10, {SinOsc.ar(Rand(0.8,1.2)*50.midicps)}!10)!2*0.01}

//:
Pbind(
	\dur, 1,
	\freq, Pseq([
		~lydScale[28],
		~lydScale[29],
		~lydScale[30],
		~lydScale[31],
		~lydScale[32],
		~lydScale[33],
		~lydScale[34],
		~lydScale[34],],1
	),
).play
//:	
// 1st oct
[~lydScale[0],~lydScale[7]]
// 2nd oct
[~lydScale[7],~lydScale[14]]
// 3rd oct
[~lydScale[14],~lydScale[21]]
// 4th oct
[~lydScale[21],~lydScale[28]]
// 5th oct
[~lydScale[28],~lydScale[34]]

