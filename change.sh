#! /bin/bash

# Small script to run whenever I make a change

# Move sensitive data out of the folder, commit and move it back
mv -n email.yaml server_email.yaml .. && \
mv -n .key ../carps_key && \
git add -A && git commit && \
mv -n ../email.yaml ../server_email.yaml && \
mv -n ../carps_key .
