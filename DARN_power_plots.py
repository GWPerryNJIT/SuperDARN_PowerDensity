#DARN power plots
#Created: March, 2021 by Gareth Perry

#Purpose of the script is to ingest SuperDARN .fitacf files and plot some parameters for the Ruzic Rays manuscript

import os
os.chdir('/Users/perry/GitHub/SuperDARN_PowerDensity')

import numpy as np 
import h5py
import datetime,time
import bz2

from scipy import signal,interpolate
from pymap3d.vincenty import vreckon

import matplotlib.pyplot as plt

import pydarnio


fitacf_file0804='/Users/perry/Downloads/20170804.1856.03.sas.fitacf.bz2'
fitacf_file0805='/Users/perry/Downloads/20170805.1832.03.sas.fitacf.bz2'
fitacf_file0806='/Users/perry/Downloads/20170806.1809.03.sas.fitacf.bz2'
fitacf_file0807='/Users/perry/Downloads/20170807.1745.03.sas.fitacf.bz2'
fitacf_file0808='/Users/perry/Downloads/20170808.1722.03.sas.fitacf.bz2'

with bz2.open(fitacf_file0804) as fp:
	fitacf_stream=fp.read()

reader_0804=pydarnio.SDarnRead(fitacf_stream,True)
records_0804=reader_0804.read_fitacf()
pl_0804=np.zeros((75,len(records_0804)))
elv_0804=np.zeros((75,len(records_0804)))
w_l_0804=np.zeros((75,len(records_0804)))



with bz2.open(fitacf_file0805) as fp:
	fitacf_stream=fp.read()

reader_0805=pydarnio.SDarnRead(fitacf_stream,True)
records_0805=reader_0805.read_fitacf()
pl_0805=np.zeros((75,len(records_0805)))
w_l_0805=np.zeros((75,len(records_0804)))


with bz2.open(fitacf_file0806) as fp:
	fitacf_stream=fp.read()

reader_0806=pydarnio.SDarnRead(fitacf_stream,True)
records_0806=reader_0806.read_fitacf()
pl_0806=np.zeros((75,len(records_0806)))
w_l_0806=np.zeros((75,len(records_0804)))


with bz2.open(fitacf_file0807) as fp:
	fitacf_stream=fp.read()

reader_0807=pydarnio.SDarnRead(fitacf_stream,True)
records_0807=reader_0807.read_fitacf()
pl_0807=np.zeros((75,len(records_0807)))
w_l_0807=np.zeros((75,len(records_0804)))


with bz2.open(fitacf_file0808) as fp:
	fitacf_stream=fp.read()

reader_0808=pydarnio.SDarnRead(fitacf_stream,True)
records_0808=reader_0808.read_fitacf()
pl_0808=np.zeros((75,len(records_0808)))
w_l_0808=np.zeros((75,len(records_0804)))


ii=1
while ii<len(records_0804):
	pl_0804[records_0804[ii]['slist'],ii]=records_0804[ii]['p_l'] #fitacf only keeps values of parameters when a good fit is achieved
	elv_0804[records_0804[ii]['slist'],ii]=records_0804[ii]['elv']
	w_l_0804[records_0804[ii]['slist'],ii]=records_0804[ii]['w_l']
	ii+=1


ii=1
while ii<len(records_0805):
	if 'p_l' in records_0805[ii]:
		pl_0805[records_0805[ii]['slist'],ii]=records_0805[ii]['p_l'] #fitacf only keeps values of parameters when a good fit is achieved
		w_l_0805[records_0805[ii]['slist'],ii]=records_0805[ii]['w_l']
	ii+=1


ii=1
while ii<len(records_0806):
	if 'p_l' in records_0806[ii]:
		pl_0806[records_0806[ii]['slist'],ii]=records_0806[ii]['p_l'] #fitacf only keeps values of parameters when a good fit is achieved
		w_l_0806[records_0806[ii]['slist'],ii]=records_0806[ii]['w_l']
	ii+=1

ii=1
while ii<len(records_0807):
	if 'p_l' in records_0807[ii]:
		pl_0807[records_0807[ii]['slist'],ii]=records_0807[ii]['p_l'] #fitacf only keeps values of parameters when a good fit is achieved
		w_l_0807[records_0807[ii]['slist'],ii]=records_0807[ii]['w_l']
	ii+=1

ii=1
while ii<len(records_0808):
	if 'p_l' in records_0808[ii]:
		pl_0808[records_0808[ii]['slist'],ii]=records_0808[ii]['p_l'] #fitacf only keeps values of parameters when a good fit is achieved
		w_l_0808[records_0808[ii]['slist'],ii]=records_0808[ii]['w_l']
	ii+=1


pl_0804_avg=np.sum(pl_0804,1)/len(records_0804)
elv_0804_avg=np.sum(elv_0804,1)/len(records_0804)
w_l_0804_avg=np.sum(w_l_0804,1)/len(records_0804)

pl_0805_avg=np.sum(pl_0805,1)/len(records_0805)
w_l_0805_avg=np.sum(w_l_0805,1)/len(records_0805)

pl_0806_avg=np.sum(pl_0806,1)/len(records_0806)
w_l_0806_avg=np.sum(w_l_0806,1)/len(records_0806)

pl_0807_avg=np.sum(pl_0807,1)/len(records_0807)
w_l_0807_avg=np.sum(w_l_0807,1)/len(records_0807)

pl_0808_avg=np.sum(pl_0808,1)/len(records_0808)
w_l_0808_avg=np.sum(w_l_0808,1)/len(records_0808)

#import pdb; pdb.set_trace()

#Chisham virtual height model
Re_=6371 #radius of Earth

glat_=np.zeros(75)
glon_=np.zeros(75)

grngs_=np.arange(75)*45+180
vh_=np.zeros(len(grngs_))

#first bit of group ranges < 790 km
A_1=108.974
B_1=0.0191271
C_1=6.68283E-5

ind_1=np.where(grngs_<790)

vh_[ind_1]=A_1+B_1*grngs_[ind_1]+C_1*grngs_[ind_1]**2

#second bit of group ranges < 2130 km
A_2=384.416
B_2=-0.178640
C_2=1.81405E-4

ind_2=np.where((grngs_<2130) & (grngs_>=790))

vh_[ind_2]=A_2+B_2*grngs_[ind_2]+C_1*grngs_[ind_2]**2

#last bit of group ranges < 2130 km
A_3=1098.28
B_3=-0.354557
C_3=9.39961E-5

ind_3=np.where(grngs_>2130)

vh_[ind_3]=A_3+B_3*grngs_[ind_3]+C_3*grngs_[ind_3]**2

ground_range=Re_*np.arccos((Re_**2+(Re_+vh_)**2-grngs_**2)/(2*Re_*(Re_+vh_)));


#using pymap3d reckon to determine goegraphic latitudes
jj=0
while jj<len(ground_range):
	glat_[jj],glon_[jj]=vreckon(52.16,-106.53,ground_range[jj]*1E3,21.48)
	jj+=1


fig=plt.figure(figsize=(10,6),dpi=200)
ax = fig.gca()


ax.plot(glat_,pl_0804_avg,'r',label='Aug. 04',lw=2)
ax.plot(glat_,pl_0805_avg,'k',label='Aug. 05',lw=2)
ax.plot(glat_,pl_0806_avg,'b',label='Aug. 06',lw=2)
ax.plot(glat_,pl_0807_avg,'m',label='Aug. 07',lw=2)
ax.plot(glat_,pl_0808_avg,'y',label='Aug. 08',lw=2)

ax.legend()
ax.set_xlabel('Geographic Latitude, $^\circ$',fontsize=14)
ax.set_ylabel('SNR, dB',fontsize=14)
ax.set_title('Time Average of Saskatoon SuperDARN Echo SNR Power',fontsize=14)
ax.grid(True)

ax.set_xticks(np.arange(52,74,step=2))
ax.set_xlim(52,72)

plt.savefig('RRI_model_compare_SDARN_pw.png')


fig=plt.figure(figsize=(10,6),dpi=200)
ax = fig.gca()


ax.plot(glat_,w_l_0804_avg,label='Aug. 04',lw=2)
ax.plot(glat_,w_l_0805_avg,label='Aug. 05',lw=2)
ax.plot(glat_,w_l_0806_avg,label='Aug. 06',lw=2)
ax.plot(glat_,w_l_0807_avg,label='Aug. 07',lw=2)
ax.plot(glat_,w_l_0808_avg,label='Aug. 08',lw=2)

ax.legend()
ax.set_xlabel('Geographic Latitude, $^\circ$',fontsize=14)
ax.set_ylabel('Spectral Width, m/s',fontsize=14)
ax.set_title('Time Average of Saskatoon SuperDARN Echo Spectral Width',fontsize=14)
ax.grid(True)

ax.set_xticks(np.arange(52,74,step=2))
ax.set_xlim(52,72)

plt.savefig('RRI_model_compare_SDARN_wl.png')


import pdb; pdb.set_trace()


