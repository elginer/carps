#! /bin/bash

# Small script to run whenever I make a change

# Move sensitive data out of the folder, commit and move it back
./commit_mode.sh && \
git add -A && git commit && \
./edit_mode.sh
