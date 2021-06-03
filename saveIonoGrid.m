% Name:
%     saveIonoGrid
%
% Author:
%     Kyle Ruzic
%
% Date:
%     ca: August, 2018
%
% Purpose: The purpose of the script is to generate a directory in which to
% place the generated ionospheric grid, if one does not already exist, and
% save the generated grid to that directory.
%
%Inputs:
%     iono_struct - structure returned by gen_iono_ns containing generated plasma density
%  and magnetic field grid information
%   
%      general_struct - structure containing other pertinent information, e.g., date, origin, etc.  
% 
%
% Outputs:
%     iono_struct
%         .pf_grid           - 3d grid (height vs lat. vs lon.) of ionospheric plasma
%                                  frequency (MHz)
%         .pf_grid_5         - 3d grid (height vs lat. vs lon.) of ionospheric plasma

function saveIonoGrid(iono_struct, general_struct)
    
    date = general_struct.UT;
    date(6) = 0;
    time = general_struct.UT(4);
    dateFile = datestr(date, 'dd-mmmm-yyyy');
    
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
    
    iono_string = strrep('iono_grid-TIMEUT.mat', 'TIME', num2str(time));
    iono_path = fullfile(dateFolder, iono_string);
    
    gen_string = strrep('gen_struct-TIMEUT.mat', 'TIME', num2str(time));
    gen_path = fullfile(dateFolder, gen_string);

    save(gen_path, '-struct', 'general_struct')
    save(iono_path, '-struct', 'iono_struct')  
