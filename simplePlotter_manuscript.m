function simplePlotter_manuscript(radGrid_O,radGrid_X, dimensions, general_struct, slices, path) 
% Produces plots of the generated model for specified elevation
% slices 
%
% Inputs:
% radGrid    - the previously generated model
% dimensions - structure containing size of the model
% UT         - time and date for which the model was generated
%
% Optional Inputs:
% slices     - Elevation slices for which the plots will be produced,
%              can be passed as either a single integer or an array
%              of integers.
% path       - the path of the Cassiope track, used to plot the path
%              over the model. Must be in grid units not lat/lon/alt.
%              To convert use the function transformPath
    
    
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
    
    if nargin < 4 % neither optional inputs are passed, so set them
                  % to default values 
        slices = [100, 200, 250]; 
        path.lat = [];
        path.lon = [];        
    elseif nargin < 5 % path was not passed set to default    
        path.lat = [];
        path.lon = [];
    end
        

    radGrid=radGrid_O+radGrid_X;
    
    dimensions.size = dimensions.spacing;
    spacingLon = ((dimensions.range(4) - dimensions.range(3))/ ...
                  dimensions.size(2));
    degLon = (dimensions.size(2) *  spacingLon);

    spacingLat = ((dimensions.range(2) - dimensions.range(1))/ ...
                  dimensions.size(1));
    degLon = (dimensions.size(1) *  spacingLon);
    
    spacingAlt=(dimensions.range(6)-dimensions.range(5))/dimensions.spacing(3);
    
    % radGrid(radGrid > 1) = nan; 
    radGrid(radGrid == 0) = nan;
    
    
    [lat_grid,lon_grid,alt_grid]=meshgrid(linspace(dimensions.range(1),dimensions.range(2),dimensions.size(1)), ...
        linspace(dimensions.range(3),dimensions.range(4),dimensions.size(2)),linspace(dimensions.range(5),dimensions.range(6),dimensions.size(3)));
    
    
    
    %quick hardcoded routine to plot a line showing the great circle path
    %of the center of beam 7
    
    az_0=21.48+zeros(1,500);
    az_0_l=21.48-4+zeros(1,500);
    az_0_r=21.48+4+zeros(1,500);
    el_0=30+zeros(1,500);
    sr_=linspace(0,2000,500);
    
    wgs84 = wgs84Ellipsoid;
    wgs84.LengthUnit='kilometer';
    [lat_gc,lon_gc,alt_gc]=aer2geodetic(az_0,el_0,sr_,52.16,-106.52,0.494,wgs84);
    [lat_gc_l,lon_gc_l,alt_gc_l]=aer2geodetic(az_0_l,el_0,sr_,52.16,-106.52,0.494,wgs84);
    [lat_gc_r,lon_gc_r,alt_gc_r]=aer2geodetic(az_0_r,el_0,sr_,52.16,-106.52,0.494,wgs84);

    %load up spacecraft tracks
    fn_0804='dat/04-August-2017/DARN_pulses_out_04082017.h5';
    rri_dat0804.glat=transpose(h5read(fn_0804,'/pulse_glat'));
    rri_dat0804.glon=transpose(h5read(fn_0804,'/pulse_glon'));
    rri_dat0804.alt_=transpose(h5read(fn_0804,'/pulse_alt'));

    fn_0805='dat/05-August-2017/DARN_pulses_out_05082017.h5';
    rri_dat0805.glat=transpose(h5read(fn_0805,'/pulse_glat'));
    rri_dat0805.glon=transpose(h5read(fn_0805,'/pulse_glon'));
    rri_dat0805.alt_=transpose(h5read(fn_0805,'/pulse_alt'));

    fn_0806='dat/06-August-2017/DARN_pulses_out_06082017.h5';
    rri_dat0806.glat=transpose(h5read(fn_0806,'/pulse_glat'));
    rri_dat0806.glon=transpose(h5read(fn_0806,'/pulse_glon'));
    rri_dat0806.alt_=transpose(h5read(fn_0806,'/pulse_alt'));

    fn_0807='dat/07-August-2017/DARN_pulses_out_07082017.h5';
    rri_dat0807.glat=transpose(h5read(fn_0807,'/pulse_glat'));
    rri_dat0807.glon=transpose(h5read(fn_0807,'/pulse_glon'));
    rri_dat0807.alt_=transpose(h5read(fn_0807,'/pulse_alt'));

    fn_0808='dat/08-August-2017/DARN_pulses_out_08082017.h5';
    rri_dat0808.glat=transpose(h5read(fn_0808,'/pulse_glat'));
    rri_dat0808.glon=transpose(h5read(fn_0808,'/pulse_glon'));
    rri_dat0808.alt_=transpose(h5read(fn_0808,'/pulse_alt'));

    
    
    
    for slice = slices
        
        
        
        figure(1)
       % clf % clears figure so the figure doesn't pop up and
            % become the focused windowed

        pos = get(gcf, 'Position');

        set(gcf, 'Position', [pos(1) pos(2) width*100, height*100],'Visible','on'); %<- Set size
        
        set(gca, 'FontSize', fsz, 'LineWidth', alw); %<- Set properties
            
        colormap viridis
        
        sliceVar = round(slice/((dimensions.range(6)-dimensions.range(5))/dimensions.spacing(3)));

        hold on

        h = pcolor(squeeze(lon_grid(:,:,sliceVar)),squeeze(lat_grid(:,:,sliceVar)),log10(radGrid(:,:,sliceVar))');
       
        shading interp
       
        p_gc=plot(lon_gc,lat_gc,'-m','Linewidth',lw,'DisplayName','Beam 7');
        %p_gc_l=plot(lon_gc_l,lat_gc_l,'--k','Linewidth',2);
        %p_gc_r=plot(lon_gc_r,lat_gc_r,'--k','Linewidth',2);
           
        xlim([-126 -86]);
        ylim([35 75]);
   
        ax_=gca; 
        
        ax_.YGrid='on';
        ax_.XGrid='on';
        ax_.Layer='top';
        ax_.Box='on';

        b = colorbar;
        caxis([-20 -5])
        %titleString = strrep(['at a Height of SLICE km DATE ' ...
        %                    'VAR-UT'],'VAR',num2str(num));
        
       % titleString = strrep(titleString,'SLICE', ...
                             %num2str(slice));
       % titleString = strrep(titleString, 'DATE', dateFile);
       % title({['Modelled SuperDARN Saskatoon Beam 7 Radiation ' ...
       %         'at 11MHz'], titleString}, 'FontSize', fsz)
        
       title({'August 8, 2017 17:25 UT','Modelled Saskatoon SuperDARN at 375 km altitude','Beam 7 Poynting Flux at 11.2 MHz'}, 'FontSize', fsz)       
        
        colorTitleHandle = get(b,'Title');
        titleString = 'log_{10}(\mu W/m^{2})';
        set(colorTitleHandle ,'String',titleString);

      %  plot(rri_dat0804.glon(45,1:100:end),rri_dat0804.glat(45,1:100:end),'k','LineWidth',lw);
      %  text(rri_dat0804.glon(45,1)+1,rri_dat0804.glat(45,1),{'Aug. 4'},'FontSize',fsz-9);

      %  plot(rri_dat0805.glon(45,1:100:end),rri_dat0805.glat(45,1:100:end),'k','LineWidth',lw);
      %  text(rri_dat0805.glon(45,1)+1,rri_dat0805.glat(45,1),{'Aug. 5'},'FontSize',fsz-9);

      %  plot(rri_dat0806.glon(45,1:100:end),rri_dat0806.glat(45,1:100:end),'k','LineWidth',lw);
      %  text(rri_dat0806.glon(45,1)+1,rri_dat0806.glat(45,1),{'Aug. 6'},'FontSize',fsz-9);

      %  plot(rri_dat0807.glon(45,1:100:end),rri_dat0807.glat(45,1:100:end),'k','LineWidth',lw);
      %  text(rri_dat0807.glon(45,1)+1,rri_dat0807.glat(45,1),{'Aug. 7'},'FontSize',fsz-9);

        plot(rri_dat0808.glon(45,1:100:end),rri_dat0808.glat(45,1:100:end),'k','LineWidth',lw);
      %  text(rri_dat0808.glon(45,1)+1,rri_dat0808.glat(45,1),{'Aug. 8'},'FontSize',fsz-9);

        
     %   xticks(4:10*round(1/spacingLon):dimensions.size(2));
     %   yticks(4:5*round(1/spacingLat):dimensions.size(1));
     %   xticklabels(dimensions.range(3):10:dimensions.range(4));
     %   yticklabels(dimensions.range(1):5:dimensions.range(2));
        xlabel("Geographic Longitude, ^\circ", 'FontSize', fsz)
        ylabel("Geographic Latitude, ^\circ", 'FontSize', fsz)
        
        legend([p_gc(1)]);
        
        set(h, 'edgecolor', 'none');
        set(gcf, 'InvertHardcopy', 'on');
        set(gcf, 'PaperUnits', 'inches');
        set(gcf, 'Color', 'w');
        
    end
    
    set(gcf,'InvertHardcopy','on');
    set(gcf,'PaperUnits', 'inches');
    papersize = get(gcf, 'PaperSize');
    left = (papersize(1)- width)/2;
    bottom = (papersize(2)- height)/2;
    myfiguresize = [left, bottom, width, height];
    set(gcf,'PaperPosition', myfiguresize);

    %printing the figure out to file
    fn_=strcat('Aug8_SuperDARN_Saskatoon_Beam7_model_bears_v2_new_375.png');
    print(fn_,'-dpng','-r300')     
    
    %plot an altitude vs. latitude along origin meridian
    
    figure(2)
       % clf % clears figure so the figure doesn't pop up and
            % become the focused windowed

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
        
       
       % p = pcolor(squeeze(sum(log10(radGrid(:,:,:,1))),2)');
       
        shading interp
        
 
        ax_=gca; 
        
        ax_.YGrid='on';
        ax_.XGrid='on';
        ax_.Layer='top';
        
        ax_.Box='on';

        title({'August 8, 2017 17:25 UT','Modelled Saskatoon SuperDARN at -106^\circ longitude','Beam 7 Poynting Flux at 11.2 MHz'}, 'FontSize', fsz)       

        %titleString = strrep(['at a Height of SLICE km DATE ' ...
                           % 'VAR-UT'],'VAR',num2str(num));
        
        %titleString = strrep(titleString,'SLICE', ...
                             %num2str(slice));
        %titleString = strrep(titleString, 'DATE', dateFile);

       % colorTitleHandle = get(b,'Title');
        
       % titleString = 'log_{10}(\mu W/m^{2})';
       % set(colorTitleHandle ,'String',titleString);

        
        %xticks(4:10*round(1/spacingLon):dimensions.size(2));
        %xticklabels(dimensions.range(3):10:dimensions.range(4));
        %xlabel("Geographic Longitude, ^\circ", 'FontSize', fsz);
        
       % xticks(4:5*round(1/spacingLat):dimensions.size(1));
       % xticklabels(dimensions.range(1):5:dimensions.range(2));
        xlabel("Geographic Latitude, ^\circ", 'FontSize', fsz);
       
       % yticks(4:round(100/spacingAlt):dimensions.size(3));
       % yticklabels(dimensions.range(5):100:dimensions.range(6))       
        ylabel("Altitude, km", 'FontSize', fsz);
        
        xlim([35 75]);
        ylim([50 500]);
        
        b = colorbar;
        caxis([-20 -5])
        ax_cb=gca;
        b.Label.String='log_{10}(\mu W/m^{2})';
        
        %plot(rri_dat0804.glat(45,1:100:end),rri_dat0804.alt_(45,1:100:end),'k','LineWidth',lw);
        %text(rri_dat0808.glat(45,1),rri_dat0808.alt_(45,1)-40,{'Aug. 4'},'Color','k','FontSize',fsz-9,'HorizontalAlignment','left');

        %plot(rri_dat0805.glat(45,1:100:end),rri_dat0805.alt_(45,1:100:end),'k','LineWidth',lw);
        %text(rri_dat0808.glat(45,1),rri_dat0808.alt_(45,1)-30,{'Aug. 5'},'Color','k','FontSize',fsz-9,'HorizontalAlignment','left');

        %plot(rri_dat0806.glat(45,1:100:end),rri_dat0806.alt_(45,1:100:end),'k','LineWidth',lw);
        %text(rri_dat0808.glat(45,1),rri_dat0808.alt_(45,1)-20,{'Aug. 6'},'Color','k','FontSize',fsz-9,'HorizontalAlignment','left');

        %plot(rri_dat0807.glat(45,1:100:end),rri_dat0807.alt_(45,1:100:end),'k','LineWidth',lw);
        %text(rri_dat0808.glat(45,1),rri_dat0808.alt_(45,1)-10,{'Aug. 7'},'Color','k','FontSize',fsz-9,'HorizontalAlignment','left');

        plot(rri_dat0808.glat(45,1:100:end),rri_dat0808.alt_(45,1:100:end),'k','LineWidth',lw);
        %text(rri_dat0808.glat(45,1),rri_dat0808.alt_(45,1),{'Aug. 8'},'Color','k','FontSize',fsz-9,'HorizontalAlignment','left');

        p_gc=plot(lat_gc,alt_gc,'-m','Linewidth',lw,'DisplayName','Beam 7');
        
        legend([p_gc(1)]);
        
        
        
        set(gcf,'InvertHardcopy','on');
        set(gcf,'PaperUnits', 'inches');
        papersize = get(gcf, 'PaperSize');
        left = (papersize(1)- width)/2;
        bottom = (papersize(2)- height)/2;
        myfiguresize = [left, bottom, width, height];
        set(gcf,'PaperPosition', myfiguresize);

    %printing the figure out to file
        fn_=strcat('Aug8_SuperDARN_Saskatoon_Beam7_model_elevs_v2_new.png');
        print(fn_,'-dpng','-r300')     
    
        
       % hold on
       % plot(path.lon, path.lat, 'r.')
        hold off
        
        
        
        
       figure(3)
       % clf % clears figure so the figure doesn't pop up and
            % become the focused windowed

        pos = get(gcf, 'Position');

        set(gcf, 'Position', [pos(1) pos(2) width*100, height*100],'Visible','on'); %<- Set size
        
        set(gca, 'FontSize', fsz, 'LineWidth', alw); %<- Set properties
            
        colormap viridis
        
        sliceVar = round(slice/((dimensions.range(6)-dimensions.range(5))/dimensions.spacing(3)));

        hold on

        meds_temp=linspace(dimensions.range(3),dimensions.range(4),dimensions.spacing(2));
        meridVar = find(abs(meds_temp-(dimensions.origin(2)+10))<abs((dimensions.range(3)-dimensions.range(4))/dimensions.spacing(2)));
        meridVar=meridVar(1);
        
        %p = pcolor(log10(squeeze(radGrid(:,meridVar,:,1)))');
         q= contourf(log10(radGrid(:,:,sliceVar)),10);
       % p = pcolor(squeeze(sum(log10(radGrid(:,:,:,1))),2)');
       
        shading interp
    
        ax_=gca; 
        
        ax_.YGrid='on';
        ax_.XGrid='on';
        ax_.Layer='top';
        
        ax_.Box='on';

        b = colorbar;
        caxis([-20 -5])
        titleString = strrep(['at a Height of SLICE km DATE ' ...
                            'VAR-UT'],'VAR',num2str(num));
        
        titleString = strrep(titleString,'SLICE', ...
                             num2str(slice));
        titleString = strrep(titleString, 'DATE', dateFile);
        title({['Modelled Saskatoon SuperDARN Beam 7 Radiation ' ...
                'at 11MHz'], titleString}, 'FontSize', fsz)
        colorTitleHandle = get(b,'Title');
        titleString = 'log_{10}(\mu W/m^{2})';
        set(colorTitleHandle ,'String',titleString);
    
        
        xticks(4:10*round(1/spacingLon):dimensions.size(2));
        xticklabels(dimensions.range(3):10:dimensions.range(4));
        xlabel("Geographic Longitude, ^\circ", 'FontSize', fsz);
        
        yticks(4:5*round(1/spacingLat):dimensions.size(1));
        yticklabels(dimensions.range(1):5:dimensions.range(2));
        ylabel("Geographic Latitude, ^\circ", 'FontSize', fsz);
       
        %yticks(4:round(100/spacingAlt):dimensions.size(3));
        %yticklabels(dimensions.range(5):100:dimensions.range(6));
        
        %ylabel("Altitude, km", 'FontSize', fsz);
        
        
        set(h, 'edgecolor', 'none');
        set(gcf, 'InvertHardcopy', 'on');
        set(gcf, 'PaperUnits', 'inches');
        set(gcf, 'Color', 'w');
        
      %  hold on
       % plot(path.lon, path.lat, 'r.')
        hold off

