#! /bin/bash

# Small script to run whenever I make a change

# Move sensitive data out of the folder
mv email.yaml server_email.yaml ..

# Commit
git add -A && git commit

# Move the sensitive data back
mv ../email.yaml ../server_email.yaml .
