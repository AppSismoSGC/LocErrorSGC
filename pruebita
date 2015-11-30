#!/bin/csh
set gridsize = 0.1

if($gridsize == 1) then
set size = -I1.0/1.0
else if($gridsize == 0.5) then
set size = -I0.5/0.5
else if($gridsize == 0.1) then
set size = -I0.001/0.002
endif
set comment = Prueba
set gregion = -0.27/0.27/-0.27/0.27
set xshift = -X4.5
set yshift = -Y4.0
set scale = -D15.5/5.5/9.0/0.5 #locX/locY/height/width
set filename = diffs_out.dat
set prof = (1 8 16)

echo $prof

awk '$4 == 1 {print $2*0.00899928, $3*0.00899928, $5}' $filename > fileh_1.xyz
awk '$4 == 8 {print $2*0.00899928, $3*0.00899928, $5}' $filename > fileh_8.xyz
awk '$4 == 16 {print $2*0.00899928, $3*0.00899928, $5}' $filename > fileh_16.xyz
#awk '$4 == 20 {print $2*0.00899928, $3*0.00899928, $5}' $filename > fileh_20.xyz

awk '$4 == 1 {print $2*0.00899928, $3*0.00899928, $6}' $filename > filev_1.xyz
awk '$4 == 8 {print $2*0.00899928, $3*0.00899928, $6}' $filename > filev_8.xyz
awk '$4 == 16 {print $2*0.00899928, $3*0.00899928, $6}' $filename > filev_16.xyz
#awk '$4 == 20 {print $2*0.00899928, $3*0.00899928, $6}' $filename > filev_20.xyz

###################################HORIZONTAL##############################################
echo GREGION $gregion
foreach dp ($prof)
echo titulo | pstext -R-0.27/0.27/-0.27/0.37 -J -F+cTL  >> horiz_$dp.ps
surface fileh_$dp.xyz -Lld -Lud -V -R$gregion $size -Ghoriz_$dp.grd > surface_$dp.out
psbasemap -R -J -Ba0.1/a0.1 -K >> horiz_$dp.ps
grd2cpt horiz_$dp.grd -Cno_green -D -S0.0/5.0/0.2  > crust_$dp.cpt
grdimage horiz_$dp.grd $xshift $yshift -JM13.5 -R$gregion -Ccrust_$dp.cpt -K >! horiz_$dp.ps
pscoast -R -J  -Df -Ba0.083334/a0.083334 -N1 -W -O -K -P >> horiz_$dp.ps
#awk '{print $2*0.00899928, $3*0.00899928}' aro.dat | psxy -R -J -O -K -Sc0.01 -G20/5/100 -W0.1 -L >> horiz_$dp.ps
awk '{print $2*0.00899928, $3*0.00899928}' station.dat | psxy -R -J -O -K -St0.5 -G200/5/0 -W0.1 -L >> horiz_$dp.ps
grdcontour horiz_$dp.grd -J -Ccrust_$dp.cpt -W0.16 -A+f5p -R$gregion -O -K >> horiz_$dp.ps
psscale   $scale -Ccrust_$dp.cpt  -B30:'Error Horizontal (km)':m -O -K -Y0.2>> horiz_$dp.ps

pstext -R-0.27/0.27/-0.27/0.37 -J -O -F+f20p  <<END>> horiz_$dp.ps
-0.1 0.32 Z=$dp km 
END

ps2pdf14 horiz_$dp.ps
end
##########################################################################################
#####################################VERTICAL#############################################
##########################################################################################
echo GREGION $gregion
foreach dp ($prof)
surface filev_$dp.xyz -Lld -Lud -V -R$gregion $size -Gverti_$dp.grd > surface_$dp.out
psbasemap -R -J -Ba0.1/a0.1 -K >> verti_$dp.ps
grd2cpt verti_$dp.grd -Cno_green -D -S0.0/5.0/0.2  > crust_$dp.cpt
grdimage verti_$dp.grd $xshift $yshift -JM13.5 -R$gregion -Ccrust_$dp.cpt -K >! verti_$dp.ps
pscoast -R -J  -Df -Ba0.083334/a0.083334 -N1 -W -O -K -P >> verti_$dp.ps
#awk '{print $2*0.00899928, $3*0.00899928}' aro.dat | psxy -R -J -O -K -Sc0.01 -G2/5/100 -W0.1 -L >> verti_$dp.ps
awk '{print $2*0.00899928, $3*0.00899928}' station.dat | psxy -R -J -O -K -St0.5 -G200/5/0 -W0.1 -L >> verti_$dp.ps
grdcontour verti_$dp.grd -J -Ccrust_$dp.cpt -W0.16 -A+f5p -R$gregion -O -K >> verti_$dp.ps
psscale   $scale -Ccrust_$dp.cpt  -B30:'Error Vertical (km)':m -O -K -Y0.2>> verti_$dp.ps

pstext -R-0.27/0.27/-0.27/0.37 -J -O -F+f20p  <<END>> verti_$dp.ps
0.0 0.32 Z=$dp km 
END



ps2pdf14 verti_$dp.ps
end
##########################################################################################
#evince *.pdf &
