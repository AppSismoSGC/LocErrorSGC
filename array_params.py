#/usr/bin/env python
#
# Rutina para generar archivo con la info importante de los arreglos creados: gaps y radios

import numpy as np

f_stas = open('station.dat', 'r')
stas = f_stas.readlines()
ls_xstas = []
ls_ystas = []
ls_vals_stas_r1 = []
ls_vals_stas_r2 = []
for i in range(len(stas)):
    x0, y0 = 3., 0.
    x = float(stas[i].split()[1])
    y = float(stas[i].split()[2])
    r = np.round(np.sqrt(x**2+y**2), decimals=1)
    if y >= 0:
        theta = np.round(np.arccos((x0*x + y0*y)/(np.sqrt(x0**2+y0**2)*np.sqrt(x**2+y**2)))*180/np.pi)
    else:
        theta = 360. - np.round(np.arccos((x0*x + y0*y)/(np.sqrt(x0**2+y0**2)*np.sqrt(x**2+y**2)))*180/np.pi)
    if i in range(0, 3):
        ls_vals_stas_r1.append([x, y, r, theta])
    else:
        ls_vals_stas_r2.append([x, y, r, theta])
    ls_xstas.append(x)
    ls_ystas.append(y)
#    ls_xstas.append((x-sol_x[1])/sol_x[0])
#    ls_ystas.append((y-sol_y[1])/sol_y[0])

ls_vals_stas_r1.sort(key=lambda x: x[-1])
ls_vals_stas_r2.sort(key=lambda x: x[-1])
ls_gaps_r1 = []
for i in range(len(ls_vals_stas_r1)):
    if not i == len(ls_vals_stas_r1)-1:
        theta1 = ls_vals_stas_r1[i][-1]
        theta2 = ls_vals_stas_r1[i+1][-1]
    else:
        theta1 = ls_vals_stas_r1[i][-1]
        theta2 = ls_vals_stas_r1[0][-1]
    gap = theta2 - theta1
    if gap < 0.:
        gap = gap + 360.
    ls_gaps_r1.append(gap)
ls_gaps_r2 = []
for i in range(len(ls_vals_stas_r2)):
    if not i == len(ls_vals_stas_r2)-1:
        theta1 = ls_vals_stas_r2[i][-1]
        theta2 = ls_vals_stas_r2[i+1][-1]
    else:
        theta1 = ls_vals_stas_r2[i][-1]
        theta2 = ls_vals_stas_r2[0][-1]
    gap = theta2 - theta1
    if gap < 0.:
        gap = gap + 360.
    ls_gaps_r2.append(gap)

r1, r2 = ls_vals_stas_r1[0][2], ls_vals_stas_r2[0][2]
gap1 = max(ls_gaps_r1)
gap2 = max(ls_gaps_r2)

with open('params_arreglo.dat', 'w') as f_par:
    f_par.write('R1     %12.5f  %12.5f\n' % (r1, gap1))
    f_par.write('R2     %12.5f  %12.5f\n' % (r2, gap2))
