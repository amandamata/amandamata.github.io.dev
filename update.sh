#!/bin/bash

git pull

if [ -d "public" ]; then
  cd public
  git pull
  cd ..
fi