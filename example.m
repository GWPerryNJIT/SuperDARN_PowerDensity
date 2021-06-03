% Purpose:
%     Example of a control script for running the model from start to finish. This
%     is intended to be a basic use example, more information
%     regarding the functions used in this example can be found in
%     their respective files.
%
% Author:
%     Kyle Ruzic
%
% Date:
%     August 30th 2018


% general_struct - structure that contains general information that is used for ray tracing
%                 
%     .UT                - 5x1 array containing UTC date and time - year, month,
%                          day, hour, minute
%     .speed_of_light    - speed of light
%     .re                - radius of the Earth
%     .R12               - R12 index (monthly average solar spot number)
%     .origin_lat        - origin latitude of rays to be
%                          traced, this should be the location
%                          of the radar. 
%     .origin_long       - origin longitude
%     .origin_ht         - origin height
%     .gain_dat          - gain pattern of radar 

for ii=1 %looping through and doing a whole day

general_struct.UT = [2017 08 05 18 35]; % UT - [year month day hour minute]
general_struct.speed_of_light = 2.99792458e8; % m/s
general_struct.re = 6376000; 
general_struct.R12 =15.0;
general_struct.origin_lat = 52.16; %geographic latitude of origin (Saskatoon)
general_struct.origin_long = -106.52; %geographic latitude of origin (Saskatoon)
general_struct.origin_ht = 0.0; %altitude of origin (Saskatoon)
general_struct.gain_dat = load('SuperDARN_sas_11-20MHz_beam07.dat'); %modeled gain pattern 


% Set up regional constraints over which model generates the power density profile 
%
%     .range   - [minLat, maxLat, minLon, maxLon, minAlt, maxAlt]
%     .spacing - [numLatBins, numLonBins, numAltBins], the dimensions of
%                the model

dimensions.origin=[52.16,-106.52,0.494]; %origin lat, lon, alt -- origin of the transmitter

dimensions.range=[30,80,-155,-55,50,1550]; %dimensions of the ionosphere and IGRF grid, which are the same

dimensions.spacing = [200, 400, 200]; %number of bins for the radar power binning routines

% Use PHARLAP's internal routines to tenerate and then save ionospheric grid, and general information structure

iono_struct = gen_iono_ns(general_struct,dimensions); %generate the plasma density and IGRF information

saveIonoGrid(iono_struct, general_struct); %save the generated data for future reference


%Ray tracing O-mode (OX_mode=1)
radGrid_O = rayCaller_ns(dimensions, iono_struct, general_struct,0.25,1);
saveRadGrid(radGrid_O, dimensions, general_struct.UT,0.25,1); % saving generated radar grid

%Ray tracing X-mode (OX_mode=-1)
radGrid_X = rayCaller_ns(dimensions, iono_struct, general_struct,0.25,-1); 
saveRadGrid(radGrid_X, dimensions, general_struct.UT,0.25,-1); 

% Create plots of the generated model
%simplePlotter(radGrid, dimensions, UT)


end% for loop

