% Name:
%     powerCalc_phase
%
% Author:
%     Kyle Ruzic
%     Re-written by Gareth Perry, January 2019, and simplified.
%
% Date:
%     August 21st 2018
%
% Purpose:
%
%     Generates ray trace model given time and date inputs, which are
%     used to load a previously generated ionosphere. The model is
%     produced by tracing lots of rays then binning their power which
%     is calculated according to P = (P_in * G)/(N * R^2)
%
%     Where,

%     P_in is the power of the radar
%     G is the gain pattern of the radar that is dependent on the
%     initial bearing and elevation angles of the ray
%     N is the total number of rays traced and
%     R is the geometric distance of the point of the ray  
%
%     Phase calculations are also computed according to the
%     superposition principle, which is implemented by converting
%     the phase path of each point along the ray to a phase angle,
%     then amplitude of the point is computed by taking the cosine
%     of the phase angle times the root of the power. When the
%     model is finished computing, each bin is then squared to
%     convert the amplitude to a magnitude of power 
%
%     
% Inputs:
%     ray        - structure of rays that were traced using the pharlap
%                  ray tracing algorithm, these need to be the
%                  ray_path_data output of the pharlap routine
%                  'raytrace_3d_sp'
%
%     radGrid   - (i*j*k,5) grid of power values, on first call of
%                  model generation to this function these values
%                  should all be zero.  The second dimesion keeps count of
%                  the number of rays in the bin.
%
%     init_ray   - structure containing information regarding initial
%                  conditions of the ray
%         
%         .elevs     - (1 x N) array of initial elevations for rays,
%                      where N is the number of rays traced
%         .ray_bears - (1 x N) array of initial bearing angles for
%                      rays
%         .freq      - (1 x N) array of initial frequencies of rays
%
%     gain       - a slice of the gain pattern taken at an elevation
%                  angle, this is done to lower the amount of data
%                  that needs to be held in memory, currently
%                  rayCaller handles this by using this function,
%                  powerCalc_phase, only with rays that all have the
%                  same elevation angle. Changing this will
%                  cause errors, but not prevent the program from
%                  running. So be sure not to do it without also
%                  changing how the gain is applied to the ray 
%
%     dimensions - A structure containing the dimensions for which the model
%                  will be produced, it should be in this form:
%                  
%                  dimensions.range = [minLat, maxLat, minLon, maxLon, minAlt, maxAlt]; 
%                  dimensions.spacing = [numLat, numLon, numAlt];
%         .range     - Contains the ranges for which the model will
%                      be generated        
%         .spacing   - more aptly named size, contains sizes of
%                      each dimension
%
% Output: 
%
%      radGrid - array with power information, ray count, and ray
%      k-vectors


function radGrid = powerCalc_phase_new(ray, radGrid, gain, dimensions)

powerMultiplier = (750)*10.^(gain/10); % converting from dBi to linear
                                          % SuperDARN Saskatoon has a power output of 750 W 
    
%initialiazing arrays                                      
lat_bins=linspace(dimensions.range(1),dimensions.range(2),dimensions.spacing(1));
lon_bins=linspace(dimensions.range(3),dimensions.range(4),dimensions.spacing(2));
alt_bins=linspace(dimensions.range(5),dimensions.range(6),dimensions.spacing(3));


for i = 1:length(ray)
       
    %calculating power along the rauy 
    power_=(powerMultiplier(floor(mod(ray(i).initial_bearing-(21.48),360)) + 1)) .* (ray(i).group_range*1e3).^(-2)/4/pi; %corrected by Gareth 10/29/2021 (geometric_distance became group_range)
        
    %now accounting for absorption
    absorption_c=ray(i).absorption; %cumulative absorption, coverted to linear
        
    %accounting for absorption in the power calculation
    power_final=10.^(log10(power_)-absorption_c./10);
            
    amplitude=sqrt(power_final);
        
    ray(i).phase_path = ray(i).phase_path*1e3;
    
    phase = mod((ray(i).phase_path*(ray(i).frequency*1e6)*(2*pi))/(3e8),2*pi);  % computes phase given phase path
       
	%%%%BINNING******	
	%discretize each ray in lat/lon/alt
	d1_=discretize(ray(i).lat,lat_bins);
	d2_=discretize(ray(i).lon,lon_bins);
	d3_=discretize(ray(i).height,alt_bins);

	%NaN out and eliminate from consideration any altitudes that are outside of the pre-defined grid
	d1_m=d1_(~isnan(d3_));
	d2_m=d2_(~isnan(d3_));
	d3_m=d3_(~isnan(d3_));

	amp_=amplitude(~isnan(d3_)).*cos(phase(~isnan(d3_)));
	lat_=ray(i).lat(~isnan(d3_));
	lon_=ray(i).lon(~isnan(d3_));
	alt_=ray(i).height(~isnan(d3_));

    [k1,k2,k3]=ray_unit_vector_ecef(ray(i)); %ray k-vectors in ECEF coordinates
	
	%eliminating information outside of the desired grid boundaries
	k1_m=k1(~isnan(d3_));
	k2_m=k2(~isnan(d3_));
	k3_m=k3(~isnan(d3_));

	%account for instances of multiple ray points per bin -- average them out
	%loop through each row and determine which rows ahead of it are similar.  If similar, average them out.
    
	bins_=[d1_m',d2_m',d3_m']; %create an array with the bin information to be evaluated later

	amp_avg=amp_;
	
	%in preparation for averaging the multiple k-vector points in the bin
	k1_avg=k1_m;
	k2_avg=k2_m;
	k3_avg=k3_m;

    jj=1;
	count=0;

	%using a while loop to figure out which bins are repeats and averaging their associated amplitudes out
	while 1;
	 
        pp=1;

        while ((jj+pp)<numel(d3_m) & isequal([d1_m(jj),d2_m(jj),d3_m(jj)],[d1_m(jj+pp),d2_m(jj+pp),d3_m(jj+pp)])); pp=pp+1; end;
	 
            if (jj+pp)>=numel(d3_m)

                amp_avg(jj:end)=mean(amp_(jj:end),'omitnan'); %at the end of the bins
	 
                k1_avg(jj:end)=mean(k1_m(jj:end),'omitnan'); %averaging out the k-vectors
                k2_avg(jj:end)=mean(k2_m(jj:end),'omitnan');
                k3_avg(jj:end)=mean(k3_m(jj:end),'omitnan');
	  
                jj=numel(d3_m);
                
                break;

            else  
	
                amp_avg(jj:jj+pp-1)=mean(amp_(jj:jj+pp-1),'omitnan');%having determined all similar bins, average out the amplitudes of multiple ray points in each bin
         
                k1_avg(jj:jj+pp-1)=mean(k1_m(jj:jj+pp-1),'omitnan'); %averaging out the k-vectors
                k2_avg(jj:jj+pp-1)=mean(k2_m(jj:jj+pp-1),'omitnan');
                k3_avg(jj:jj+pp-1)=mean(k3_m(jj:jj+pp-1),'omitnan');

                 jj=jj+pp;
            end;
	
        count=count+1;

        end; %jj loop

	%re-normalize the k-vectors
	k1_avg_rn=k1_avg./sqrt(k1_avg.^2+k2_avg.^2+k3_avg.^2);
	k2_avg_rn=k2_avg./sqrt(k1_avg.^2+k2_avg.^2+k3_avg.^2);
	k3_avg_rn=k3_avg./sqrt(k1_avg.^2+k2_avg.^2+k3_avg.^2);

	%then assign the data to the radGrid array
	
	%what are the indices of the unique bins
	[C_,ia_,ic_]=unique(bins_,'rows');

	%haven't figured out a slick array assignment here so reverting to for loop
	if numel(ia_)>0  %if there are any ray points then assign them otherwise loop through

        for zz=1:numel(ia_)

            if isnan(C_(zz,1)) | isnan(C_(zz,2)) | isnan(C_(zz,3)); continue; end; %if there's a NAN entry, skip this iteration

            radGrid(C_(zz,1),C_(zz,2),C_(zz,3),1)=radGrid(C_(zz,1),C_(zz,2),C_(zz,3),1)+amp_avg(ia_(zz)); %assigning ray amplitude
	
            radGrid(C_(zz,1),C_(zz,2),C_(zz,3),2)=radGrid(C_(zz,1),C_(zz,2),C_(zz,3),2)+1; %ray count
	
            radGrid(C_(zz,1),C_(zz,2),C_(zz,3),3)=radGrid(C_(zz,1),C_(zz,2),C_(zz,3),3)+k1_avg_rn(ia_(zz)); %ray normalized k-vector
            
            radGrid(C_(zz,1),C_(zz,2),C_(zz,3),4)=radGrid(C_(zz,1),C_(zz,2),C_(zz,3),4)+k2_avg_rn(ia_(zz)); %ray normalized k-vector
	  
            radGrid(C_(zz,1),C_(zz,2),C_(zz,3),5)=radGrid(C_(zz,1),C_(zz,2),C_(zz,3),5)+k3_avg_rn(ia_(zz)); %ray normalized k-vector
	 
        end; 
	end
end % i loop
	

clear ray

