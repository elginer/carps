#! /bin/bash

rm -rf doc

mv -n email.yaml server_email.yaml .. && \
mv -n .key ../carps_key
