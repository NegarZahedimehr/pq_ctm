#!/bin/sh

cp shared/ctm_tmp.tsv shared/ctm_state.tsv

cd ../point-q/sim_1/cc
python Simulation.py

