#!/bin/bash

./gen_rand_st
echo  random stations file created
./gen_events
echo  events file created
#matlab create_COL_FRACK ###Velocity Model 
matlab -nosplash -r "synthetic_create, exit"
echo arrivals file created
./station2hypo station.dat STATION0.HYP
echo STATION0.HYP created
./arrival2nordic arrival.dat
cp gen_locout SFILE
cp update_expect SFILE
cd SFILE
pwd
./update_expect
./gen_locout
cp loc_out.dat ../ ; cd ../
python disp_res
./pruebita

