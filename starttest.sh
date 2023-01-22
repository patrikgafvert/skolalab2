#!/usr/bin/env bash

for file in "output0.json" "output1.json" "output.md" "output.pdf"; do

	if [ -f "$file" ]; then
		rm "$file"
	fi

done

vagrant destroy -f
vagrant up
xdg-open output.pdf
