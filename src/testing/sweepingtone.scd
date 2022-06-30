// =====================================================================
// SuperCollider Workspace
// =====================================================================
fork{
	1000.do{
	var val = rrand(262,600);
		x.set(\trig,1,\st,~prev,\end,val);
		~prev=val;
		val.postln;
		0.04.wait;
		
		//x.set(\trig,0);
		
		
	};
};

//:
~prev=322;
x=play{|st=222,end=144,trig=0|
	Pulse.ar(
		EnvGen.kr(Env([st,end],[0.05]), gate:Pulse.kr(100,0.01),doneAction:0)
	).clip2(0.2)!2*0.1
	
}
//:
x.set(\trig,1,\st,922,\end,555)

//:
{Trig.kr(1)}.plot(1)