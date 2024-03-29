% Name:
%     saveRadGrid
%
% Author:
%     Kyle Ruzic
%   
%
% Date:
%     ca: August 2018
%
% Purpose:
%
% Save a generated radar power grid array to a file.

% Inputs:
%
%   radGrid - array containing calculated power density esitmates, along
%   with number of ray and ray k-vector infromation.
%
%    dimensions - A structure containing the dimensions for which the model
%                  will be produced, it should be in this form:
%                  
%                  dimensions.range = [minLat, maxLat, minLon, maxLon, minAlt, maxAlt]; 
%                  dimensions.spacing = [numLat, numLon, numAlt];
%
%     UT - 5x1 array containing UTC date and time - year, month, day, hour, minute
%   
%     angleSpacing - launched ray increments
%
%     OX_mode - porpagation mode identifier.
%
%  Outputs: A .mat file containing the inputs.
%


function saveRadGrid(radGrid, dimensions, UT,angleSpacing,OX_mode)

    
    date = UT;
    date(6) = 0;
    time = UT(4);
    dateFile = datestr(date, 'dd-mmmm-yyyy')
    
    myFolder = ['dat'];
    dateFolder = fullfile(myFolder, dateFile);
    
    if ~isdir(myFolder)
        [status, msg, msgID] = mkdir('dat');
        if ~status            
            msg
            return
        end
    end    
    if ~isdir(dateFolder)
        [status, msg, msgID] = mkdir(strrep('dat/dateFile', 'dateFile', dateFile));
        if ~status
            msg
            return
        end 
    end
    
    radGridString = strrep('rad-grid_angleSpacing_spacing_DATE-NUMUT_OX_mode.mat','DATE', ...
                           dateFile);
    radGridString = strrep(radGridString, 'NUM', num2str(time));
    radGridString = strrep(radGridString, 'angleSpacing', num2str(angleSpacing));

    if OX_mode==1 radGridString=strrep(radGridString,'OX_mode','O'); elseif OX_mode==-1 radGridString=strrep(radGridString,'OX_mode','X'); ...
    else radGridString=strrep(radGridString,'OX_mode','no_mag'); end;

    radGridPath = fullfile(dateFolder, radGridString);
    save(radGridPath, 'radGrid','dimensions','UT','angleSpacing','OX_mode', '-v7.3'); 
