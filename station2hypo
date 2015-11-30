#!/usr/bin/env python

import numpy as np
import sys

factor =  1.0/111.12

def xy2geograph(X):
    if X == -0:
        X = abs(X)
    #X = np.array(x)
    if X < 0:
	XSign = False
    else:
	XSign = True
    X = factor*X
    X_grad = int(X)
    X_dec = abs(X) - abs(int(X))
    X_min = round(X_dec*60, 2)

    if len(str(X_grad)) == 1:
        Xgrad = '0'+str(X_grad)
    else:
        Xgrad = str(X_grad)
    
    
    if len(str(X_min).split('.')[0]) == 1 and len(str(X_min).split('.')[1]) == 2:
        Xmin = '0'+str(X_min)
    elif len(str(X_min).split('.')[0]) == 2 and len(str(X_min).split('.')[1]) == 1:
        Xmin = str(X_min)+'0'
    elif len(str(X_min).split('.')[0]) == 2 and len(str(X_min).split('.')[1]) == 2:
        Xmin = str(X_min)
    else:
        Xmin = '0'+str(X_min)+'0'
    
    return Xgrad, Xmin, XSign

#print xy2geograph(-20), xy2geograph(20) 


if len(sys.argv)<2:
    print 'no hay parametros de entrada'
    sys.exit()

stations = open(sys.argv[1], 'r').readlines()

Station_Dict={}
for line in stations:
    STA =  line.split()[0]
    Lon, Lon_min, Lon_sign = xy2geograph(float(line.split()[1]))
    Lat, Lat_min, Lat_sign = xy2geograph(float(line.split()[2]))  
    if Lon_sign == False:
        emi_Lon = 'W'
    else:
        emi_Lon = 'E'
    if Lat_sign == False:
        emi_Lat = 'S'
    else:
        emi_Lat = 'N'
    Station_Dict[STA] = [Lon, Lon_min, emi_Lon, Lat, Lat_min, emi_Lat]

print Station_Dict

value = []    
for STA in Station_Dict:
    station = Station_Dict[STA]
    value.append('  '+STA+station[3]+station[4]+station[5]+' '+station[0]+station[1]+station[2]+'   0 0.00\n')

F = open(sys.argv[2], 'r')
contents = F.readlines()
F.close()

for v in value:
    for line in contents:
        if 'RELOC' in line:
            dex = contents.index(line)
            contents.insert(dex+1,v)
            print contents[dex], contents[dex+1], contents[dex-1]

f = open(sys.argv[2], "w")
contents = "".join(contents)
f.write(contents)
f.close()

