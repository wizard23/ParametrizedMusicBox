#!/usr/bin/env python
import mido
import sys
import midi_numbers


def midi_notes2scad_notes(midi_notes):
  return [
    '{0: <2}'.format(
      ( key_note := midi_numbers.number_to_note( midi_note ) )[0]
    ) + str(key_note[1])
  for midi_note in midi_notes
]


def midi_msgs2midi_notes(midi_track):
  return [ msg.note for msg in midi_track if msg.type == "note_on" ]


def get_distinct_midi_notes(midi_track):
  return list({ msg.note for msg in midi_track if msg.type == "note_on" })


def normalize_scad_notes(scad_notes, min_octave):
  """Lowest note should be in octave 0, adjust other octaves relatively"""
  return [ note[:2] + str(int(note[2]) - min_octave) for note in scad_notes ]


midi=mido.MidiFile(sys.argv[1])
midi_track = midi.tracks[1]

distinct_midi_notes            = get_distinct_midi_notes(midi_track)
distinct_scad_notes            = midi_notes2scad_notes(distinct_midi_notes)
min_octave                     = int(min([n[2] for n in distinct_scad_notes]))
normalized_distinct_scad_notes = normalize_scad_notes(distinct_scad_notes, min_octave)
distinct_note_quantity         = len(distinct_midi_notes)

midi_track_dict = [ m.dict() for m in midi_track ]

note_events = [
  { k:m[k] for k in ['note', 'time', 'type'] }
  for m in midi_track_dict if m['type'] in [ "note_on" , "note_off"]
]

absolute_time = 0
for e in note_events:
  absolute_time += e['time']
  e['T'] = absolute_time

note_events = [
  { k:e[k] for k in ['note', 'T'] }
  for e in note_events if e['type'] ==  "note_on"
]

min_ticks_between_notes=0xffffffff
for i in range(1,len(note_events)):
  t_delta = note_events[i]['T'] - note_events[i-1]['T']
  if t_delta < min_ticks_between_notes:
    min_ticks_between_notes = t_delta

for e in note_events:
  e['T'] = round(e['T'] / min_ticks_between_notes)

total_measures = note_events[-1]['T'] + 1
cylinder_rows = [ [0] * distinct_note_quantity for i in range(total_measures) ]

for e in note_events:
  note_index = distinct_midi_notes.index(e['note'])
  cylinder_rows[e['T']][note_index] = 1


# Visually mark end of song with row of all notes
cylinder_rows.append( [1] * distinct_note_quantity)
total_measures += 1


# OpenSCAD file params
pinNrX = distinct_note_quantity
pinNrY = total_measures
teethNotes = "".join(normalized_distinct_scad_notes)
pins = "".join([ "".join(map(lambda n: 'X' if n else 'o', r)) for r in cylinder_rows ])

print(f"""
MusicCylinderName="{midi.filename.split('.mid')[0]}";
pinNrX = {pinNrX};
pinNrY = {pinNrY};
teethNotes = "{teethNotes}";
pins = "{pins}";
""")
