#!/bin/bash
sudo apt-get -yqq update
sudo apt-get install -y build-essential git python python-pip
git clone https://github.com/adafruit/micropython.git
make -C micropython/mpy-cross
export PATH=$PATH:$PWD/micropython/mpy-cross/
sudo pip install shyaml
