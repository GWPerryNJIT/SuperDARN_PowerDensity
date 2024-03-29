%RRI_pharlap_compare.m
%Created by: Gareth Perry, January, 2019
%Updated January, 2020 to ingest Python script generated RRI pulse
%information, replacing IDL script.

%Purpose of the script is to compare RRI data of received power to predicted power at that point with Kyle Ruzic's Pharlap-based prediction

%ingest RRI data file


function [RRI_pwr,ray_power,glat_,glon_,alt_]=RRI_pharlap_compare_new(radGrid_O,radGrid_X,dimensions,iono_grid,iono_grid_parms);


%for printing the images (code borrowed from https://dgleich.github.io/hq-matlab-figs/)
width = 12;     % Width in inches
height = 6.75;    % Height in inches
alw = 1;    % AxesLineWidth
fsz = 14;      % Fontsize
lw = 2;      % LineWidth
msz = 4;       % MarkerSize
%---------------------

close all

fn_='dat/08-August-2017/DARN_pulses_out_08082017.h5';

rri_dat.glat=transpose(h5read(fn_,'/pulse_glat'));
rri_dat.glon=transpose(h5read(fn_,'/pulse_glon'));
rri_dat.alt_=transpose(h5read(fn_,'/pulse_alt'));

rri_dat.pitch=transpose(h5read(fn_,'/pulse_pitch'));
rri_dat.yaw=transpose(h5read(fn_,'/pulse_yaw'));
rri_dat.roll=transpose(h5read(fn_,'/pulse_roll'));

rri_dat.vt1_rf_s_f=transpose(h5read(fn_,'/pulse_d1_mvolts'));
rri_dat.vt2_rf_s_f=transpose(h5read(fn_,'/pulse_d2_mvolts'));

rri_dat.met_=transpose(h5read(fn_,'/pulse_met'));

%lats/lons/alts of the model
lats_=linspace(dimensions.range(1),dimensions.range(2),dimensions.spacing(1));
lons_=linspace(dimensions.range(3),dimensions.range(4),dimensions.spacing(2));
alts_=linspace(dimensions.range(5),dimensions.range(6),dimensions.spacing(3));

sat_lat_rng=[min(rri_dat.glat(:)),max(rri_dat.glat(:))];
sat_lon_rng=[min(rri_dat.glon(:)),max(rri_dat.glon(:))];
sat_alt_rng=[min(rri_dat.alt_(:)),max(rri_dat.alt_(:))];

%model bin indices corresponding to the satellite track boundaries
[lats_d_min,lats_id_min]=min(abs(sat_lat_rng(1)-lats_));
[lats_d_max,lats_id_max]=min(abs(sat_lat_rng(2)-lats_));

[lons_d_min,lons_id_min]=min(abs(sat_lon_rng(1)-lons_));
[lons_d_max,lons_id_max]=min(abs(sat_lon_rng(2)-lons_));

[alts_d_min,alts_id_min]=min(abs(sat_alt_rng(1)-alts_));
[alts_d_max,alts_id_max]=min(abs(sat_alt_rng(2)-alts_));

%the narrowed lat/lon/alt ranges
lats_nar=lats_(lats_id_min-10:lats_id_max+10);
lons_nar=lons_(lons_id_min-10:lons_id_max+10);
alts_nar=alts_(alts_id_min-10:alts_id_max+10);

[lons_grid,lats_grid,alts_grid]=meshgrid(lons_nar,lats_nar,alts_nar);

%the narrowed radGrid power array for the interpolant
radGrid_O_pwr_nar=squeeze(radGrid_O(lats_id_min-10:lats_id_max+10,lons_id_min-10:lons_id_max+10,alts_id_min-10:alts_id_max+10,1));
radGrid_X_pwr_nar=squeeze(radGrid_X(lats_id_min-10:lats_id_max+10,lons_id_min-10:lons_id_max+10,alts_id_min-10:alts_id_max+10,1));

%the narrowed ray normal k-vectors
k1_O_nar=squeeze(radGrid_O(lats_id_min-10:lats_id_max+10,lons_id_min-10:lons_id_max+10,alts_id_min-10:alts_id_max+10,3));
k2_O_nar=squeeze(radGrid_O(lats_id_min-10:lats_id_max+10,lons_id_min-10:lons_id_max+10,alts_id_min-10:alts_id_max+10,4));
k3_O_nar=squeeze(radGrid_O(lats_id_min-10:lats_id_max+10,lons_id_min-10:lons_id_max+10,alts_id_min-10:alts_id_max+10,5));

k1_X_nar=squeeze(radGrid_X(lats_id_min-10:lats_id_max+10,lons_id_min-10:lons_id_max+10,alts_id_min-10:alts_id_max+10,3));
k2_X_nar=squeeze(radGrid_X(lats_id_min-10:lats_id_max+10,lons_id_min-10:lons_id_max+10,alts_id_min-10:alts_id_max+10,4));
k3_X_nar=squeeze(radGrid_X(lats_id_min-10:lats_id_max+10,lons_id_min-10:lons_id_max+10,alts_id_min-10:alts_id_max+10,5));

%the radGrid narrowed power interpolant
radGrid_O_P_int=scatteredInterpolant(lons_grid(:),lats_grid(:),alts_grid(:),radGrid_O_pwr_nar(:));
radGrid_X_P_int=scatteredInterpolant(lons_grid(:),lats_grid(:),alts_grid(:),radGrid_X_pwr_nar(:));

%the k-vectors may be full of NaN, try to interpolate them out.
k1_O_nar=fillmissing(k1_O_nar,'pchip',1);
k2_O_nar=fillmissing(k2_O_nar,'pchip',1);
k3_O_nar=fillmissing(k3_O_nar,'pchip',1);

k1_X_nar=fillmissing(k1_X_nar,'pchip',1);
k2_X_nar=fillmissing(k2_X_nar,'pchip',1);
k3_X_nar=fillmissing(k3_X_nar,'pchip',1);

%the narrowed ray normal k-vectors interpolants
k1_O_nar_int=scatteredInterpolant(lons_grid(:),lats_grid(:),alts_grid(:),k1_O_nar(:));
k2_O_nar_int=scatteredInterpolant(lons_grid(:),lats_grid(:),alts_grid(:),k2_O_nar(:));
k3_O_nar_int=scatteredInterpolant(lons_grid(:),lats_grid(:),alts_grid(:),k3_O_nar(:));

k1_X_nar_int=scatteredInterpolant(lons_grid(:),lats_grid(:),alts_grid(:),k1_X_nar(:));
k2_X_nar_int=scatteredInterpolant(lons_grid(:),lats_grid(:),alts_grid(:),k2_X_nar(:));
k3_X_nar_int=scatteredInterpolant(lons_grid(:),lats_grid(:),alts_grid(:),k3_X_nar(:));


%the radGrid power interpolated values along the track
RRI_O_ph_pwr=radGrid_O_P_int(double(rri_dat.glon(45,:)),double(rri_dat.glat(45,:)),double(rri_dat.alt_(45,:)));
RRI_X_ph_pwr=radGrid_X_P_int(double(rri_dat.glon(45,:)),double(rri_dat.glat(45,:)),double(rri_dat.alt_(45,:)));

%permitivity along the spacecraft track

[pf_lons_grid,pf_lats_grid,pf_alts_grid]=meshgrid(iono_grid_parms(4)+[0:iono_grid_parms(6)-1]*iono_grid_parms(5),iono_grid_parms(1)+[0:iono_grid_parms(3)-1]*iono_grid_parms(2),iono_grid_parms(7)+[0:iono_grid_parms(9)-1]*iono_grid_parms(8));

iono_pf_int=scatteredInterpolant(pf_lons_grid(:),pf_lats_grid(:),pf_alts_grid(:),iono_grid(:));

epsilon_=1-(iono_pf_int(double(rri_dat.glon(45,:)),double(rri_dat.glat(45,:)),double(rri_dat.alt_(45,:)))).^2./11.^2;


%the ray normal k-vectors interpolated values along the spacecraft track
k1_O_ph=k1_O_nar_int(double(rri_dat.glon(45,:)),double(rri_dat.glat(45,:)),double(rri_dat.alt_(45,:)));
k2_O_ph=k2_O_nar_int(double(rri_dat.glon(45,:)),double(rri_dat.glat(45,:)),double(rri_dat.alt_(45,:)));
k3_O_ph=k3_O_nar_int(double(rri_dat.glon(45,:)),double(rri_dat.glat(45,:)),double(rri_dat.alt_(45,:)));

k1_X_ph=k1_X_nar_int(double(rri_dat.glon(45,:)),double(rri_dat.glat(45,:)),double(rri_dat.alt_(45,:)));
k2_X_ph=k2_X_nar_int(double(rri_dat.glon(45,:)),double(rri_dat.glat(45,:)),double(rri_dat.alt_(45,:)));
k3_X_ph=k3_X_nar_int(double(rri_dat.glon(45,:)),double(rri_dat.glat(45,:)),double(rri_dat.alt_(45,:)));

%the RRI pointing direction along the track, in ECEF coordinates - the same coordinates as the ray normal k-vectors
rri_point_all=rri_point_ecef(rri_dat.glat(45,:)',rri_dat.glon(45,:)',rri_dat.alt_(45,:)',rri_dat.yaw(45,:)',rri_dat.pitch(45,:)',rri_dat.roll(45,:)',rri_dat.met_(45,:)');

%calculate the dot product between the ray normals and RRI's pointing vector
rri_point=squeeze(rri_point_all(1,:,:));

rri_O_k_dot=dot(rri_point,[k1_O_ph;k2_O_ph;k3_O_ph]);
rri_X_k_dot=dot(rri_point,[k1_X_ph;k2_X_ph;k3_X_ph]);

%turning NaN to O so that addition can take place
RRI_O_ph_pwr(find(isnan(RRI_O_ph_pwr)))=0;
RRI_X_ph_pwr(find(isnan(RRI_X_ph_pwr)))=0;

RRI_ph_pwr=RRI_O_ph_pwr.*abs(rri_O_k_dot)+RRI_X_ph_pwr.*abs(rri_X_k_dot);
RRI_ph_pwr_no_correct=RRI_O_ph_pwr+RRI_X_ph_pwr;


figure(1)
pos = get(gcf, 'Position');
set(gcf, 'Position', [pos(1) pos(2) width*100, height*100],'Visible','on'); %<- Set size
set(gca, 'FontSize', fsz, 'LineWidth', alw); %<- Set properties

p1a=plot(rri_dat.glat(45,:),movmedian(sqrt(rri_dat.vt1_rf_s_f(45,:).^2+rri_dat.vt2_rf_s_f(45,:).^2),100,'omitnan'),'r','LineWidth',2,'DisplayName','RRI Data');

hold on

p1b=plot(rri_dat.glat(45,:),sqrt(RRI_O_ph_pwr.*9.*abs(rri_O_k_dot)*1./epsilon_./3E8./8.85E-12)*1E3+sqrt(RRI_X_ph_pwr.*9.*abs(rri_X_k_dot)*1./epsilon_./3E8./8.85E-12)*1E3,'-k','LineWidth',2,'DisplayName','Model');

xlabel('Geographic Latitude, \circ')
ylabel('Voltage, mV')

lg1=legend([p1a,p1b]);
set(lg1,'FontSize',fsz);

grid on


title({'08 August, 2017 17:23:14 - 17:27:11 UT Saskatoon SuperDARN'})

set(gca,'FontSize',fsz,'LineWidth',lw,'XMinorTick',true,'YMinorTick',true);


% Here we preserve the size of the image when we save it.
set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);

%printing the figure out to file
fn_=strcat('08-August-2017_RRI_pharlap_compare-lat-voltage_112_R1215_v2.png');
print(fn_,'-dpng','-r300')



figure(2)
pos = get(gcf, 'Position');
set(gcf, 'Position', [pos(1) pos(2) width*100, height*100],'Visible','on'); %<- Set size
set(gca, 'FontSize', fsz, 'LineWidth', alw); %<- Set properties

p1a=plot(rri_dat.glon(45,:),movmedian(sqrt(rri_dat.vt1_rf_s_f(45,:).^2+rri_dat.vt2_rf_s_f(45,:).^2),100,'omitnan'),'r','LineWidth',2,'DisplayName','RRI Data');
hold on

p1b=plot(rri_dat.glon(45,:),sqrt(RRI_O_ph_pwr.*9.*abs(rri_O_k_dot)*1./epsilon_./3E8./8.85E-12)*1E3+sqrt(RRI_X_ph_pwr.*9.*abs(rri_X_k_dot)*1./epsilon_./3E8./8.85E-12)*1E3,'-k','LineWidth',2,'DisplayName','Model');

xlabel('Geographic Longitude, \circ')
ylabel('Voltage, mV')

lg1=legend([p1a,p1b]);
set(lg1,'FontSize',fsz);

grid on

title({'08 August, 2017 17:23:14 - 17:27:11 UT Saskatoon SuperDARN'})

set(gca,'FontSize',fsz,'LineWidth',lw,'XMinorTick',true,'YMinorTick',true);

% Here we preserve the size of the image when we save it.
set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);

%printing the figure out to file
fn_=strcat('08-August-2017_RRI_pharlap_compare-lon-voltage_112_R1215_v2.png');
print(fn_,'-dpng','-r300')

figure(3)
pos = get(gcf, 'Position');
set(gcf, 'Position', [pos(1) pos(2) width*100, height*100],'Visible','on'); %<- Set size
set(gca, 'FontSize', fsz, 'LineWidth', alw); %<- Set properties

p1a=plot(rri_dat.alt_(45,:),movmedian(sqrt(rri_dat.vt1_rf_s_f(45,:).^2+rri_dat.vt2_rf_s_f(45,:).^2),100,'omitnan'),'r','LineWidth',2,'DisplayName','RRI Data');
hold on

p1b=plot(rri_dat.alt_(45,:),sqrt(RRI_O_ph_pwr.*9.*abs(rri_O_k_dot)*1./epsilon_./3E8./8.85E-12)*1E3+sqrt(RRI_X_ph_pwr.*9.*abs(rri_X_k_dot)*1./epsilon_./3E8./8.85E-12)*1E3,'-k','LineWidth',2,'DisplayName','Model');

xlabel('Altitude, km')
ylabel('Voltage, mV')

lg1=legend([p1a,p1b]);
set(lg1,'FontSize',fsz);

grid on

title({'08 August, 2017 17:23:14 - 17:27:11 UT Saskatoon SuperDARN','R12 = 60'})

set(gca,'FontSize',fsz,'LineWidth',lw,'XMinorTick',true,'YMinorTick',true);


% Here we preserve the size of the image when we save it.
set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);

%printing the figure out to file
fn_=strcat('08-August-2017_RRI_pharlap_compare-alt-voltage_112_R1260.png');
print(fn_,'-dpng','-r300')


clear g



