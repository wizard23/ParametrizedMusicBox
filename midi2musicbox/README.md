# midi2musicbox

The url referenced in the scad file to generate notes (http://www.wizards23.net/projects/musicbox/musicbox.html) longer exists and isn't available on archive sites after searching. This is a python script to emulate some of the functionality that likely existed there. Simply pass in a (relatively simple) .midi file that features only a melody or simple chords, and it will print out the respective variable values to overwrite in the scad file to have it generate the .midi tune in a physical model to print.
## Usage
`./midi2musicbox.sh <your_song.midi>`
This will create a python virtual environment in this directory (if it doesn't already exist), install the necessary dependencies, and then parse the midi to generate the relevant paramters to be substituted in the scad file.

Example:
```sh
$ ./midi2musicbox.sh september.mid  

MusicCylinderName="september";
pinNrX = 8;
pinNrY = 46;
teethNotes = "F#0A 0B 0C 1C#1D 1E 1F#1";
pins = "XooooooooXooooooooXoooooooooXoooooooXoooooooooooooooooooooooooooooooXoooooooooXooooooooXooXooooooXooooooooooooooooXooooooooooXooooooXooooooooooooooooooooooooooooXooooooooXoooooooooXoooooooooXooooooooXooXooooooXooooooooooooooooooXooooooooXooooooXooooooooooooooooooooooooooooXooooooooXoooooooooXoooooooooXooooooooXoooXooooooXooooooooooooooXooooooooXooooooXooooooXXXXXXXX";
```

overwrite the variables featured in the .scad file with the files in this output and re-render the model to get the .stl of the physical implementation of the song.