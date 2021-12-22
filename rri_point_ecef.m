%RRI_point_ECEF.m
%Created by: Gareth Perry, December, 2018
%Purpose of the script is to ingest and IDL save file with the RRI signal
%and ephemeris information, and calculate RRI's pointing direciton in ECEF
%coordinates so that it may be compared to an incident ray in ECEF
%coordinates.


function [RRI_point_ecef]=RRI_point_ECEF(lat_in,lon_in,alt_in,yaw_in,pitch_in,roll_in,met_in);

spheroid=referenceEllipsoid('WGS 84');

[delta_X,delta_Y,delta_Z]=ecefOffset(spheroid,lat_in,lon_in,alt_in*1E3,circshift(lat_in,-1),circshift(lon_in,-1),circshift(alt_in,-1)*1E3);

delta_X=[delta_X(1:end-1);NaN];
delta_Y=[delta_Y(1:end-1);NaN];
delta_Z=[delta_Z(1:end-1);NaN];

delta_T=circshift(met_in,-1)-met_in; %time difference between pulses
delta_T=[delta_T(1:end-1);NaN];

%spacecraft velocities in ECEF
epop_v_X=delta_X./delta_T;
epop_v_Y=delta_Y./delta_T;
epop_v_Z=delta_Z./delta_T;

epop_v_u=[[epop_v_X,epop_v_Y,epop_v_Z]]./sqrt(epop_v_X.^2+epop_v_Y.^2+epop_v_Z.^2); %spacecraft velocity vector

[epop_ecef_x,epop_ecef_y,epop_ecef_z]=geodetic2ecef(spheroid,lat_in,lon_in,alt_in*1E3);

epop_z_u=-[[epop_ecef_x],[epop_ecef_y],[epop_ecef_z]]./sqrt(epop_ecef_x.^2+epop_ecef_y.^2+epop_ecef_z.^2); %spacecraft z-vector

epop_y_u=nan(size(epop_z_u));
epop_x_u=nan(size(epop_z_u));

for pp=1:numel(lat_in) epop_y_u(pp,:)=cross(epop_z_u(pp,:),epop_v_u(pp,:)); epop_x_u(pp,:)=cross(epop_y_u(pp,:),epop_z_u(pp,:)); end;

%rotation matrices
a_=deg2rad(yaw_in);
b_=deg2rad(pitch_in);
g_=deg2rad(roll_in);

Rx_=nan(3,3,numel(a_));
Ry_=nan(3,3,numel(a_));
Rz_=nan(3,3,numel(a_));

RRI_point_rot=nan(3,3,numel(a_)); %the general rotation matrix in ECEF

for ii=1:numel(yaw_in)
Rx_(:,:,ii)=[[1 0 0];[0 cos(g_(ii)) -sin(g_(ii))];[0 sin(g_(ii)) cos(g_(ii))]]; %roll
Ry_(:,:,ii)=[[cos(b_(ii)) 0 sin(b_(ii))];[0 1 0];[-sin(b_(ii)) 0 cos(b_(ii))]]; %pitch
Rz_(:,:,ii)=[[cos(a_(ii)) -sin(a_(ii)) 0];[sin(a_(ii)) cos(a_(ii)) 0];[0 0,1]]; %yaw

RRI_point_rot(:,:,ii)=Rx_(:,:,ii)*Ry_(:,:,ii)*Rz_(:,:,ii); %The rotation matrix

RRI_point_ecef(:,:,ii)=squeeze(RRI_point_rot(:,:,ii))'*[epop_x_u(ii,:);epop_y_u(ii,:);epop_z_u(ii,:)];

end; %ii loop

%RRI_point_ecef=squeeze(RRI_point_ecef(1,1,:));

%to plot the all 3 components of the spacecraft x-axis
%figure(15)
%plot(squeeze(RRI_point_ecef(1,1,:)),'r'); hold on;
%plot(squeeze(RRI_point_ecef(1,2,:)),'b'); 
%plot(squeeze(RRI_point_ecef(1,3,:)),'g'); 

%grid on


