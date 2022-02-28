%gain_plotter.m
%Created by Gareth Perry, February 2021
%
%Purpose of the script is to ingest SuperDARN Saskatoon gain pattern
%informaiton and produce publication quality plots of that information.

%for printing the images (code borrowed from https://dgleich.github.io/hq-matlab-figs/)
width = 12;     % Width in inches
height = 6.75;    % Height in inches
alw = 1;    % AxesLineWidth
fsz = 18;      % Fontsize
lw = 2;      % LineWidth
msz = 4;       % MarkerSiz
%---------------------

gain_dat=getGain('SuperDARN_sas_11-20MHz_beam07.dat');

elevs_=[15 30 45 60];
cols_=colormap(viridis(numel(elevs_)));


%fixed elevation

figure(1)
pos = get(gcf, 'Position');
set(gcf, 'Position', [pos(1) pos(2) width*100, height*100],'Visible','on'); %<- Set size
set(gca, 'FontSize', fsz, 'LineWidth', alw); %<- Set properties

bears_=deg2rad([0:359]+(23.1));

for ii=[1:numel(elevs_)]
    start = round(elevs_(ii))+182;
    finish = 360*181-(180-(round(elevs_(ii))));
    interval = 181; % gets line number for gain file according to current elevation angle 

    gain_(1) = gain_dat(round(elevs_(ii)+1),4);
    gain_(2:360) = gain_dat(start:interval:finish,4);
    gain_(361)=gain_(1);
    gain_=fliplr(gain_); %correcting for opposite sense of bearing in gain pattern simulations
    
    p1=polarplot([bears_,bears_(1)],gain_,'Color',cols_(ii,:),'DisplayName',string(elevs_(ii))+' ^\circ','LineWidth',lw); 
    rlim([-35 30])
    thetaticks([0 21.48 90 180 270])
    thetaticklabels({'0^\circ','21.48^\circ','90^\circ','180^\circ','270^\circ'});
    rticks([0 10 20 30])
    rticklabels({'0','10','20','30'});
    
    hold on
end

hold off;

lg1=legend;
lg1.Title.String='Elevation Angles';
set(gca,'ThetaZeroLocation','top','Thetadir','Clockwise','FontSize',fsz,'RAxisLocation',315,'Rcolor','black','ThetaColor','black','GridAlpha',1);
title(gca,{'Saskatoon SuperDARN Beam 7 Gain Pattern at 11.2 MHz', 'Geographic Bearing'});

set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);

%printing the figure out to file
fn_=strcat('SuperDARN_Saskatoon_Beam7_Bearing_112.png');
print(fn_,'-dpng','-r300')


%fixed bearing

figure(2)
pos = get(gcf, 'Position');
set(gcf, 'Position', [pos(1) pos(2) width*100, height*100],'Visible','on'); %<- Set size
set(gca, 'FontSize', fsz, 'LineWidth', alw); %<- Set properties


bears_=[2];

for ii=[1:numel(bears_)]
    gain_elev(1:181) = fliplr(gain_dat(bears_(ii)*181+1:bears_(ii)*181+181,4));
    gain_elev(find(gain_elev<-35))=NaN;
    p2=polarplot(deg2rad([0:180]),gain_elev,'Color',[0.4,0.4,0.4],'DisplayName','21.48^\circ','LineWidth',lw); 
    rlim([-35 30])
    thetalim([0 180])
    thetaticks([0 30 60 90 120 150 180])
    thetaticklabels({'0^\circ','30^\circ','60^\circ','90^\circ','120^\circ','150^\circ','180^\circ'});
    rticks([0 10 20 30])
    rticklabels({'0','10','20','30'});
    
    hold on
end

hold off;

set(gca,'FontSize',fsz,'Rcolor','black','ThetaColor','black','GridAlpha',1);
title(gca,{'Saskatoon SuperDARN Beam 7 Gain Pattern at 11.2 MHz', 'Elevation'});

set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);

%printing the figure out to file
fn_=strcat('SuperDARN_Saskatoon_Beam7_Elevation_112_v2.png');
print(fn_,'-dpng','-r300')


%%%%FIGURE 3%%%
%plotting received power vs bearing, elevation wrt saskatoon

%load up spacecraft tracks
fn_0804='dat/04-August-2017/DARN_pulses_out_04082017.h5';
rri_dat0804.glat=transpose(h5read(fn_0804,'/pulse_glat'));
rri_dat0804.glon=transpose(h5read(fn_0804,'/pulse_glon'));
rri_dat0804.alt_=transpose(h5read(fn_0804,'/pulse_alt'));
rri_dat0804.vt1_rf_s_f=transpose(h5read(fn_0804,'/pulse_d1_mvolts'));
rri_dat0804.vt2_rf_s_f=transpose(h5read(fn_0804,'/pulse_d2_mvolts'));
rri_dat0804.vt_tot=sqrt(rri_dat0804.vt1_rf_s_f.^2+rri_dat0804.vt2_rf_s_f.^2);

fn_0805='dat/05-August-2017/DARN_pulses_out_05082017.h5'; 
rri_dat0805.glat=transpose(h5read(fn_0805,'/pulse_glat'));
rri_dat0805.glon=transpose(h5read(fn_0805,'/pulse_glon'));
rri_dat0805.alt_=transpose(h5read(fn_0805,'/pulse_alt'));
rri_dat0805.vt1_rf_s_f=transpose(h5read(fn_0805,'/pulse_d1_mvolts'));
rri_dat0805.vt2_rf_s_f=transpose(h5read(fn_0805,'/pulse_d2_mvolts'));
rri_dat0805.vt_tot=sqrt(rri_dat0805.vt1_rf_s_f.^2+rri_dat0805.vt2_rf_s_f.^2);

fn_0806='dat/06-August-2017/DARN_pulses_out_06082017.h5';
rri_dat0806.glat=transpose(h5read(fn_0806,'/pulse_glat'));
rri_dat0806.glon=transpose(h5read(fn_0806,'/pulse_glon'));
rri_dat0806.alt_=transpose(h5read(fn_0806,'/pulse_alt'));
rri_dat0806.vt1_rf_s_f=transpose(h5read(fn_0806,'/pulse_d1_mvolts'));
rri_dat0806.vt2_rf_s_f=transpose(h5read(fn_0806,'/pulse_d2_mvolts'));
rri_dat0806.vt_tot=sqrt(rri_dat0806.vt1_rf_s_f.^2+rri_dat0806.vt2_rf_s_f.^2);

fn_0807='dat/07-August-2017/DARN_pulses_out_07082017.h5';
rri_dat0807.glat=transpose(h5read(fn_0807,'/pulse_glat'));
rri_dat0807.glon=transpose(h5read(fn_0807,'/pulse_glon'));
rri_dat0807.alt_=transpose(h5read(fn_0807,'/pulse_alt'));
rri_dat0807.vt1_rf_s_f=transpose(h5read(fn_0807,'/pulse_d1_mvolts'));
rri_dat0807.vt2_rf_s_f=transpose(h5read(fn_0807,'/pulse_d2_mvolts'));
rri_dat0807.vt_tot=sqrt(rri_dat0807.vt1_rf_s_f.^2+rri_dat0807.vt2_rf_s_f.^2);

fn_0808='dat/08-August-2017/DARN_pulses_out_08082017.h5';
rri_dat0808.glat=transpose(h5read(fn_0808,'/pulse_glat'));
rri_dat0808.glon=transpose(h5read(fn_0808,'/pulse_glon'));
rri_dat0808.alt_=transpose(h5read(fn_0808,'/pulse_alt'));
rri_dat0808.vt1_rf_s_f=transpose(h5read(fn_0808,'/pulse_d1_mvolts'));
rri_dat0808.vt2_rf_s_f=transpose(h5read(fn_0808,'/pulse_d2_mvolts'));
rri_dat0808.vt_tot=sqrt(rri_dat0808.vt1_rf_s_f.^2+rri_dat0808.vt2_rf_s_f.^2);

%[52.16,-106.52,0.494];
wgs84 = wgs84Ellipsoid;
wgs84.LengthUnit='kilometer';

[az_0804,elev_0804,sr_0804]=geodetic2aer(rri_dat0804.glat(45,:),rri_dat0804.glon(45,:),rri_dat0804.alt_(45,:),zeros(1,length(rri_dat0804.glat(45,:)))+52.16, ...
    zeros(1,length(rri_dat0804.glat(45,:)))-106.52,zeros(1,length(rri_dat0804.glat(45,:)))+0.494,wgs84);

az_id_temp=find(az_0804>90 & az_0804<270);
elev_0804(az_id_temp)=abs(elev_0804(az_id_temp)-max(elev_0804))+max(elev_0804);%stiched together


[az_0805,elev_0805,sr_0805]=geodetic2aer(rri_dat0805.glat(45,:),rri_dat0805.glon(45,:),rri_dat0805.alt_(45,:),zeros(1,length(rri_dat0805.glat(45,:)))+52.16, ...
    zeros(1,length(rri_dat0805.glat(45,:)))-106.52,zeros(1,length(rri_dat0805.glat(45,:)))+0.494,wgs84);

[az_0806,elev_0806,sr_0806]=geodetic2aer(rri_dat0806.glat(45,:),rri_dat0806.glon(45,:),rri_dat0806.alt_(45,:),zeros(1,length(rri_dat0806.glat(45,:)))+52.16, ...
    zeros(1,length(rri_dat0806.glat(45,:)))-106.52,zeros(1,length(rri_dat0806.glat(45,:)))+0.494,wgs84);

[az_0807,elev_0807,sr_0807]=geodetic2aer(rri_dat0807.glat(45,:),rri_dat0807.glon(45,:),rri_dat0807.alt_(45,:),zeros(1,length(rri_dat0807.glat(45,:)))+52.16, ...
    zeros(1,length(rri_dat0807.glat(45,:)))-106.52,zeros(1,length(rri_dat0807.glat(45,:)))+0.494,wgs84);

[az_0808,elev_0808,sr_0808]=geodetic2aer(rri_dat0808.glat(45,:),rri_dat0808.glon(45,:),rri_dat0808.alt_(45,:),zeros(1,length(rri_dat0808.glat(45,:)))+52.16, ...
    zeros(1,length(rri_dat0808.glat(45,:)))-106.52,zeros(1,length(rri_dat0808.glat(45,:)))+0.494,wgs84);


figure(3) %fixed elevation
pos = get(gcf, 'Position');
set(gcf, 'Position', [pos(1) pos(2) width*100, height*100],'Visible','on'); %<- Set size
set(gca, 'FontSize', fsz, 'LineWidth', alw); %<- Set properties

%bears_=deg2rad([359:-1:0]+23.1);
bears_=deg2rad([0:359]+(23.1));

for ii=2
    start = round(elevs_(ii))+182;
    finish = 360*181-(180-(round(elevs_(ii))));
    interval = 181; % gets line number for gain file according to current elevation angle 

    gain_(1) = gain_dat(round(elevs_(ii)+1),4);
    gain_(2:360) = gain_dat(start:interval:finish,4);
    gain_(361)=gain_(1);
    gain_=fliplr(gain_); %correcting for opposite sense of bearing in gain pattern simulations
    
    p1=polarplot([bears_,bears_(1)],gain_,'Color',[0.2,0.4,0.4],'DisplayName',string(elevs_(ii))+' ^\circ Elevation','LineWidth',lw); 
    rlim([-35 30])
    thetaticks([0 21.48 90 180 270])
    thetaticklabels({'0^\circ','21.48^\circ','90^\circ','180^\circ','270^\circ'});
    rticks([0 10 20 30])
    rticklabels({'0','10','20','30'});
    
    hold on
end

%temp_=20*log10(movmedian(rri_dat0804.vt_tot(45,:),100,'omitnan'));
temp_=movmedian(rri_dat0804.vt_tot(45,:),100,'omitnan')./max(movmedian(rri_dat0804.vt_tot(45,:),100,'omitnan'));
prri_04=polarplot(deg2rad(az_0804),20*log10(temp_)+25,'r','LineWidth',lw,'DisplayName','Aug. 4');

%temp_=20*log10(movmedian(rri_dat0805.vt_tot(45,:),100,'omitnan'));
temp_=movmedian(rri_dat0805.vt_tot(45,:),100,'omitnan')./max(movmedian(rri_dat0805.vt_tot(45,:),100,'omitnan'));
prri_05=polarplot(deg2rad(az_0805),20*log10(temp_)+25,'k','LineWidth',lw,'DisplayName','Aug. 5');

%temp_=20*log10(movmedian(rri_dat0806.vt_tot(45,:),100,'omitnan'));
temp_=movmedian(rri_dat0806.vt_tot(45,:),100,'omitnan')./max(movmedian(rri_dat0806.vt_tot(45,:),100,'omitnan'));
prri_06=polarplot(deg2rad(az_0806),20*log10(temp_)+25,'b','LineWidth',lw,'DisplayName','Aug. 6');

%temp_=20*log10(movmedian(rri_dat0807.vt_tot(45,:),100,'omitnan'));
temp_=movmedian(rri_dat0807.vt_tot(45,:),100,'omitnan')./max(movmedian(rri_dat0807.vt_tot(45,:),100,'omitnan'));
prri_07=polarplot(deg2rad(az_0807),20*log10(temp_)+25,'m','LineWidth',lw,'DisplayName','Aug. 7');

%temp_=20*log10(movmedian(rri_dat0808.vt_tot(45,:),100,'omitnan'));
temp_=movmedian(rri_dat0808.vt_tot(45,:),100,'omitnan')./max(movmedian(rri_dat0808.vt_tot(45,:),100,'omitnan'));
prri_08=polarplot(deg2rad(az_0808),20*log10(temp_)+25,'y','LineWidth',lw,'DisplayName','Aug. 8');

uistack(p1,'top');

lg1=legend;
%lg1.Title.String='Normalized Power Angles';
set(gca,'ThetaZeroLocation','top','Thetadir','Clockwise','FontSize',fsz,'RAxisLocation',315,'Rcolor','black','ThetaColor','black');
title(gca,{'Saskatoon SuperDARN Beam 7 Gain Pattern vs RRI at 11.2 MHz', 'Geographic Bearing'});

hold off

set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);

%printing the figure out to file
fn_=strcat('SuperDARN_Saskatoon_Beam7_Bearing_112_compare_v2.png');
print(fn_,'-dpng','-r300')

%figure 4%
figure(4) %fixed bearing 
pos = get(gcf, 'Position');
set(gcf, 'Position', [pos(1) pos(2) width*100, height*100],'Visible','on'); %<- Set size
set(gca, 'FontSize', fsz, 'LineWidth', alw); %<- Set properties


bears_=[2];

for ii=[1:numel(bears_)]
    gain_elev(1:181) = fliplr(gain_dat(bears_(ii)*181+1:bears_(ii)*181+181,4));
    gain_elev(find(gain_elev<-35))=NaN;
    p2=polarplot(deg2rad([0:180]),gain_elev,'Color',[0.4,0.4,0.4],'DisplayName','21.48^\circ','LineWidth',lw); 
    rlim([-35 30])
    thetalim([0 180])
    thetaticks([0 30 60 90 120 150 180])
    thetaticklabels({'0^\circ','30^\circ','60^\circ','90^\circ','120^\circ','150^\circ','180^\circ'});
    rticks([0 10 20 30])
    rticklabels({'0','10','20','30'});
    
    hold on
end


%temp_=20*log10(movmedian(rri_dat0804.vt_tot(45,:),100,'omitnan'));
temp_=movmedian(rri_dat0804.vt_tot(45,:),100,'omitnan')./max(movmedian(rri_dat0804.vt_tot(45,:),100,'omitnan'));
prri_04=polarplot(deg2rad(elev_0804),20*log10(temp_)+25,'r','LineWidth',lw,'DisplayName','Aug. 4');

%temp_=20*log10(movmedian(rri_dat0805.vt_tot(45,:),100,'omitnan'));
temp_=movmedian(rri_dat0805.vt_tot(45,:),100,'omitnan')./max(movmedian(rri_dat0805.vt_tot(45,:),100,'omitnan'));
prri_05=polarplot(deg2rad(elev_0805),20*log10(temp_)+25,'k','LineWidth',lw,'DisplayName','Aug. 5');

%temp_=20*log10(movmedian(rri_dat0806.vt_tot(45,:),100,'omitnan'));
temp_=movmedian(rri_dat0806.vt_tot(45,:),100,'omitnan')./max(movmedian(rri_dat0806.vt_tot(45,:),100,'omitnan'));
prri_06=polarplot(deg2rad(elev_0806),20*log10(temp_)+25,'b','LineWidth',lw,'DisplayName','Aug. 6');

%temp_=20*log10(movmedian(rri_dat0807.vt_tot(45,:),100,'omitnan'));
temp_=movmedian(rri_dat0807.vt_tot(45,:),100,'omitnan')./max(movmedian(rri_dat0807.vt_tot(45,:),100,'omitnan'));
prri_07=polarplot(deg2rad(elev_0807),20*log10(temp_)+25,'m','LineWidth',lw,'DisplayName','Aug. 7');

%temp_=20*log10(movmedian(rri_dat0808.vt_tot(45,:),100,'omitnan'));
temp_=movmedian(rri_dat0808.vt_tot(45,:),100,'omitnan')./max(movmedian(rri_dat0808.vt_tot(45,:),100,'omitnan'));
prri_08=polarplot(deg2rad(elev_0808),20*log10(temp_)+25,'y','LineWidth',lw);

uistack(p2,'top');

hold off;

%lg2=legend;
%lg2.Title.String='Bearing Angles';
set(gca,'FontSize',fsz,'Rcolor','black','ThetaColor','black');
title(gca,{'Saskatoon SuperDARN Beam 7 Gain Pattern vs RRI at 11.2 MHz', 'Elevation'});

set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);

%printing the figure out to file
fn_=strcat('SuperDARN_Saskatoon_Beam7_Elevation_112_compare_v2.png');
print(fn_,'-dpng','-r300')

