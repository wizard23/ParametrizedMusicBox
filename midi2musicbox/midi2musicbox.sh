#!/usr/bin/env bash
set -o nounset
set -o errexit

midi="${1:-$(1>&2 echo 'Error: no midi file provided'; exit 1)}"

if ! [ -d venv ]; then
	python3 -m venv venv
	. venv/bin/activate
	pip3 install -r requirements.txt
fi

. venv/bin/activate

python3 midi2notes.py $midi
