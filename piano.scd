(
// A Piano note SynthDef as a combination of its harmonics
SynthDef(\pianoNote,
	ugenGraphFunc:{ |freq = 261.63, vol = 1, gate = 1|
		var ampls = [3.7, 5.4, 1.2, 1.1, 0.95, 0.6, 0.5, 0.65, 0, 0.1, 0.2];
		var freqs = Array.fill(ampls.size, { |i| freq * (i + 1) });
		var waves = Array.fill(ampls.size, { |i| SinOsc.ar(freqs.at(i),mul: ampls.at(i))});
		var mixedwaves = Mix.ar(waves).range(vol * -1,vol);
		var env = Env.perc(0.09,4,curve: -10);
		var final = mixedwaves * EnvGen.ar(env, gate, doneAction: 2);
		Out.ar(0, [final,final]);
}).add
)

(
// Play one note
Synth(\pianoNote, [\freq, 440]);
)

(
// Play a scale forward, then backward
{ |tempo = 1, notes = 1, vol = 1|
	var cmajor = [
		261.63,293.66,329.63,349.23,392.00,440.00,493.88,523.25
	];

	var clk = TempoClock(tempo * notes);

	var play_tone = { |freq|
		Synth(\pianoNote, [\freq, freq, \vol, vol]);
	};

	var play_forward = {
		cmajor.do({ |f, indx|
			clk.sched(indx, {
				Synth(\pianoNote, [\freq, f])
			});
		})
	};

	var play_backward = {
		cmajor.reverse.do({ |f, indx|
			clk.sched(indx, {
				Synth(\pianoNote, [\freq, f])
			});
		})
	};

	clk.sched(0,play_forward);
	clk.sched(cmajor.size,play_backward);

}.value(5)
)

(
// A random composition using the above SynthDef
// tempo: beats per second
// notes: Number of notes in sequence
// vol: Volume between 0 and 1
{ |tempo = 1, notes = 1, overlap = 0, vol = 1|
	var cmajor = [
		261.63,293.66,329.63,349.23,392.00,440.00,493.88,523.25
	];

	var clk = TempoClock(tempo * notes);

	var play_tone = { |freq|
		Synth(\pianoNote, [\freq, freq, \vol, vol]);
	};

	var play_sequence = { |start_indx, dir|
		if (dir == \up,
			{
				for(0,notes - 1, {|i|
					clk.sched(i,{play_tone.value(cmajor.at(start_indx + i))});
				})

			},
			{
				start_indx = cmajor.size - start_indx - 1;
				for(0,notes - 1, {|i|
					clk.sched(i,{play_tone.value(cmajor.at(start_indx - i))});
				})
			}
		);
	};

	clk.sched(0, {
		var start = (cmajor.size - notes + 1).rand;
		var dir = [\up,\down].choose;

		play_sequence.value(start,dir);
		(tempo * notes) - overlap;
	});

}.value(1,5,2)
)

