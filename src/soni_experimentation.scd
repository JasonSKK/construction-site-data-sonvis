// =====================================================================
// SuperCollider Workspace
// =====================================================================

play{Gendy1.ar(0,0,0,minfreq:200,maxfreq:200) * Env.perc(0.0,0.1,curve:-8).kr(doneAction:2)}



b = Wavetable.chebyFill(513, [0.3, -0.8, 1.1])
b = Buffer.alloc(s, 512, 1, {arg buf; buf.sine1Msg(1.0/[1,2,3,4,5,6,7,8,9,10])});
x = { COsc.ar(b.bufnum, 60, 0.0, SinOscFB.ar(666,0.8))*0.1!2}.play

x = {|freq=500| COsc.ar(b.bufnum, freq/10, 0.8, SinOscFB.ar((freq/10)*(0.01*(freq)),0.8*(freq.linlin(300,700,0.0,1.2))))*0.1!2}.play

x.set(\freq,1300)

50.sqrt