
(
SynthDef(\echo, { |delay = 0.5, persist = 3, feedbackFactor = 1|
	var in = LocalIn.ar(2);
	var out = In.ar(0,2) + in;
	var walls = 20;
	var echos = (1..walls).collect({
		AllpassN.ar(out,delay,delay,persist);
	});
	var feedback = Mix.ar(echos)/walls;
	LocalOut.ar(feedback * feedbackFactor);
	Out.ar(0,out + feedback);
}).add
)

(
SynthDef(\beep, {
	var sig = SinOsc.ar(440, mul:EnvGen.kr(Env.perc,doneAction:2));
	Out.ar(0,sig.dup);
}).add
)


Synth(\beep)

x = Synth(\echo);
y = Synth.before(x,\beep);

x.set(\delay,0.5);
x.set(\feedbackFactor,0.9);
x.set(\persist,1);

s.options.memSize;
s.options.memSize = 2 ** 19;
s.reboot;