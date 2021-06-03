% Name:
%    simplePlotter
%
% Author:
%     Kyle Ruzic
%
% Date:
%     ca: August 2018
%
% Purpose:
%  Produces plots of the generated model for specified elevation
%
% Inputs:
% radGrid_O    - the previously generated model output, O mode
%
% radGrid_X    - the previously generated model output, X mode
%
% dimensions - structure containing size of the model
% 
% general_struct - contains general information that is used
%                      for ray tracing
%
% Optional Inputs:
%
% slice     - Elevation slice for which the plots will be produced,
%              can be passed as either a single integer or an array
%              of integers.
% path       - the path of the Cassiope track, used to plot the path
%              over the model. Must be in grid units not lat/lon/alt.
%              To convert use the function transformPath
    
function simplePlotter(radGrid_O,radGrid_X, dimensions, general_struct, slice, path) 

    
%for printing the images (code borrowed from https://dgleich.github.io/hq-matlab-figs/)
width = 12;     % Width in inches
height = 6.75;    % Height in inches
alw = 1;    % AxesLineWidth
fsz = 20;      % Fontsize
lw = 2;      % LineWidth
msz = 4;       % MarkerSize
%---------------------

date = general_struct.UT(1:3);
time = general_struct.UT(4);
dateFile = datestr([general_struct.UT,0], 'dd-mmmm-yyyy');
num = time;
    
if nargin < 4 % neither optional inputs are passed, so set them to default values 

    slice = 250; 
    path.lat = [];
    path.lon = [];        

elseif nargin < 5 % path was not passed set to default    

    path.lat = [];
    path.lon = [];
 
end
        
radGrid=radGrid_O+radGrid_X;
    
dimensions.size = dimensions.spacing;

spacingLon = ((dimensions.range(4) - dimensions.range(3))/dimensions.size(2));

degLon = (dimensions.size(2) *  spacingLon);

spacingLat = ((dimensions.range(2) - dimensions.range(1))/dimensions.size(1));
    
degLon = (dimensions.size(1) *  spacingLon);
    
spacingAlt=(dimensions.range(6)-dimensions.range(5))/dimensions.spacing(3);
    
radGrid(radGrid == 0) = nan;
    
    
[lat_grid,lon_grid,alt_grid]=meshgrid(linspace(dimensions.range(1),dimensions.range(2),dimensions.size(1)), ...
    linspace(dimensions.range(3),dimensions.range(4),dimensions.size(2)),linspace(dimensions.range(5),dimensions.range(6),dimensions.size(3)));
    
        
figure(1)
       
pos = get(gcf, 'Position');

set(gcf, 'Position', [pos(1) pos(2) width*100, height*100],'Visible','on'); %<- Set size
        
set(gca, 'FontSize', fsz, 'LineWidth', alw); %<- Set properties
            
colormap viridis
        
sliceVar = round(slice/((dimensions.range(6)-dimensions.range(5))/dimensions.spacing(3)));

hold on

h = pcolor(squeeze(lon_grid(:,:,sliceVar)),squeeze(lat_grid(:,:,sliceVar)),log10(radGrid(:,:,sliceVar))');
       
shading interp
       
xlim([-126 -86]);
ylim([35 75]);
   
ax_=gca;         
ax_.YGrid='on';
ax_.XGrid='on';
ax_.Layer='top';
ax_.Box='on';

b = colorbar;
caxis([-20 -5])

title({'Modelled SuperDARN Saskatoon Power Density Map'}, 'FontSize', fsz)       
        
colorTitleHandle = get(b,'Title');
titleString = 'log_{10}(W/m^{2})';
set(colorTitleHandle ,'String',titleString);

xlabel("Geographic Longitude, ^\circ", 'FontSize', fsz)
ylabel("Geographic Latitude, ^\circ", 'FontSize', fsz)
        
legend([p_gc(1)]);
        
set(h, 'edgecolor', 'none');
set(gcf, 'InvertHardcopy', 'on');
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'Color', 'w');
           
set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);

%printing the figure out to file
fn_=strcat('SuperDARN_Saskatoon_PowerDensity_model_bearings.png');
print(fn_,'-dpng','-r300')     
    
%plot an altitude vs. latitude along origin meridian   
figure(2)
    
pos = get(gcf, 'Position');

set(gcf, 'Position', [pos(1) pos(2) width*100, height*100],'Visible','on'); %<- Set size
        
set(gca, 'FontSize', fsz, 'LineWidth', alw); %<- Set properties
            
colormap viridis
        
sliceVar = round(slice/((dimensions.range(6)-dimensions.range(5))/dimensions.spacing(3)));

hold on

meds_temp=linspace(dimensions.range(3),dimensions.range(4),dimensions.spacing(2));
meridVar = find(abs(meds_temp-(dimensions.origin(2)+10))<abs((dimensions.range(3)-dimensions.range(4))/dimensions.spacing(2)));
meridVar=meridVar(1);
        
p = pcolor(squeeze(lat_grid(meridVar,:,:)),squeeze(alt_grid(meridVar,:,:)),log10(squeeze(radGrid(:,meridVar,:,1))));
               
shading interp
         
ax_=gca; 
ax_.YGrid='on';
ax_.XGrid='on';
ax_.Layer='top';
ax_.Box='on';

title({'Modelled SuperDARN Saskatoon Power Density Map'}, 'FontSize', fsz) 

ylabel("Altitude, km", 'FontSize', fsz);
        
xlim([35 75]);
ylim([50 500]);
        
b = colorbar;
caxis([-20 -5])
ax_cb=gca;
b.Label.String='log_{10}(W/m^{2})';
        
set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);

%printing the figure out to file
fn_=strcat('Aug7_SuperDARN_Saskatoon_Beam7_model_elevations.png');
print(fn_,'-dpng','-r300')     

hold off
 

