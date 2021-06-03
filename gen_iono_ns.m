% Name:
%     gen_iono_ns (based on an existing Pharlap gen_iono_grid variety of PHARLAP routines)
%
% Author:
%     Kyle Ruzic
%     Gareth Perry (minor cosmestic edits in January, 2019, to simplify the routines)

% Date:
%     August 24th 2018
%
% Purpose:
%     This program is largely
%     based on the beginning of this PHaRLAP example,
%     "ray_test_3d_sp.m" The purpose of this is to generate a IRI
%     ionospheric grid that is used by PHaRLAP to calculate the
%     path of the rays. A version of this also exists that saves
%     the generated ionosphere which allows for it to be easily
%     reloaded to prevent having to regenerate it every time you
%     make a new model for the same date and time. 
%
% Inputs:
%     UT - Vector containing date and time information, must be
%          formatted like [YYYY MM DD HH MM] 
%
% Outputs:
%     iono_struct
%         .pf_grid           - 3d grid (height vs lat. vs lon.) of ionospheric plasma
%                                  frequency (MHz)
%         .pf_grid_5         - 3d grid (height vs lat. vs lon.) of ionospheric plasma
%                                  frequency (MHz) 5 minutes later
%         .collision_freq    - 3d grid (height vs lat. vs lon.) of ionospheric
%                                  collision frequencies
%         .Bx                - 3d grid of x component of geomagnetic field
%         .By                - 3d grid of y component of geomagnetic field
%         .Bz                - 3d grid of z component of geomagnetic field
%         
%         .iono_grid_parms   - 9x1 vector containing the parameters which define the
%                       
%           ionospheric grid :
%           (1) geodetic latitude (degrees) start
%           (2) latitude step (degrees)
%           (3) number of latitudes
%           (4) geodetic longitude (degrees) start
%           (5) lonitude step (degrees)
%           (6) number of longitudes
%           (7) geodetic height (km) start
%           (8) height step (km)
%           (9) number of heights
%
%         .geomag_grid_parms - 9x1 vector containing the parameters which define the
%   
%           geomagnetic grid :
%           (1) geodetic latitude (degrees) start
%           (2) latitude step (degrees)
%           (3) number of latitudes
%           (4) geodetic lonitude (degrees) start
%           (5) lonitude step (degrees)
%           (6) number of longitudes
%           (7) geodetic height (km) start
%           (8) height step (km)
%           (9) number of heights
%


function [iono_struct, general_struct] = gen_iono_ns(general_struct,dimensions)

if ~exist('minute', 'var')
    minute = 0;
end

UT = general_struct.UT;
speed_of_light = 2.99792458e8;
re = 6376000; % Radius of the Earth in m
R12 = general_struct.R12;
origin_lat = dimensions.origin(1);                         
origin_long = dimensions.origin(2);
origin_ht = dimensions.origin(3);
doppler_flag = 1;                           

ht_start = dimensions.range(5);% start height for ionospheric grid (km)
ht_end=dimensions.range(6); % end height for grid
num_ht = 100.0; %the number of heights           
ht_inc = (ht_end-ht_start)./num_ht; % calculated height increment (km)

lat_start =dimensions.range(1); % start geographic latitude     
lat_end=dimensions.range(2);% end geographic latitude
num_lat=100;% number of latitudes
lat_inc =(lat_end-lat_start)./num_lat; % latitude incremement in degrees

lon_start=dimensions.range(3);
lon_end=dimensions.range(4);
num_lon =100;
lon_inc = abs(abs(lon_end)-abs(lon_start))./num_lon;

iono_grid_parms = [lat_start, lat_inc, num_lat, lon_start, lon_inc, num_lon, ...
      ht_start, ht_inc, num_ht];

B_ht_start = ht_start; % start height for geomagnetic grid (km)
B_num_ht = num_ht; % Max that can be used is 201
B_ht_inc = ht_inc; % height increment (km)

B_lat_start = lat_start; % start geographic latitude of the geomagnetic grid
B_num_lat =num_lat; % max value that can be used is 101
B_lat_inc = lat_inc; 

B_lon_start = lon_start;
B_num_lon = num_lon; % max value that can be used is 101
B_lon_inc = lon_inc;

geomag_grid_parms = [B_lat_start, B_lat_inc, B_num_lat, B_lon_start, ...
      B_lon_inc, B_num_lon, B_ht_start, B_ht_inc, B_num_ht];

  
%Generate the plasma density grid using the PHARLAP in-house routine
%gen_iono_grid_3D

fprintf('Generating ionospheric and geomag grids... ')
[iono_pf_grid, iono_pf_grid_5, collision_freq, Bx, By, Bz] = ...
    gen_iono_grid_3d(UT, R12, iono_grid_parms, ...
                     geomag_grid_parms, doppler_flag, 'iri2016');

%Putting the ouputs in a structure, which is returned
iono_struct.pf_grid = iono_pf_grid;
iono_struct.pf_grid_5 = iono_pf_grid_5;
iono_struct.collision_freq = collision_freq;
iono_struct.Bx = Bx;
iono_struct.By = By;
iono_struct.Bz = Bz;
iono_struct.iono_grid_parms = iono_grid_parms;
iono_struct.geomag_grid_parms = geomag_grid_parms;


