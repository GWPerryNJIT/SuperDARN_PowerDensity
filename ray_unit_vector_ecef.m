%ray_unit_vector_ecef.m
%Created by: Gareth Perry, December, 2018
%Purpose of this short script is to ingest a ray structure from Pharlap and
%return the unit vector of the ray in ECEF coordinates.

function [k1_,k2_,k3_]=ray_unit_vector_ecef(ray_in);

spheroid=referenceEllipsoid('WGS 84');

[ecef_1,ecef_2,ecef_3]=ecefOffset(spheroid,ray_in.lat,ray_in.lon,ray_in.height*1E3,circshift(ray_in.lat,-1),circshift(ray_in.lon,-1),circshift(ray_in.height*1E3,-1));

ecef_1=[ecef_1(1:end-1),NaN];
ecef_2=[ecef_2(1:end-1),NaN];
ecef_3=[ecef_3(1:end-1),NaN];

k1_=ecef_1./sqrt(ecef_1.^2+ecef_2.^2+ecef_3.^2);
k2_=ecef_2./sqrt(ecef_1.^2+ecef_2.^2+ecef_3.^2);
k3_=ecef_3./sqrt(ecef_1.^2+ecef_2.^2+ecef_3.^2);
