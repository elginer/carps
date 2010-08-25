#! /bin/bash

rm doc -rf
rdoc1.9.1 `find -regex '.+\\.rb'`
