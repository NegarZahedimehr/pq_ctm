#!/bin/sh

rm -f shared/*_state.tsv
cp shared/ctm_tmp.tsv shared/ctm_state.tsv

cd ../point-q/sim_1/cc
python3 Simulation.py

