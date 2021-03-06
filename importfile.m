function [Date,Time,Open] = importfile(filename, startRow, endRow)
%IMPORTFILE1 Import numeric data from a text file as column vectors.
%   [DATE,TIME,OPEN,HIGH,LOW,CLOSE,VOLUME,OPENINT] = IMPORTFILE1(FILENAME)
%   Reads data from text file FILENAME for the default selection.
%
%   [DATE,TIME,OPEN,HIGH,LOW,CLOSE,VOLUME,OPENINT] = IMPORTFILE1(FILENAME,
%   STARTROW, ENDROW) Reads data from rows STARTROW through ENDROW of text
%   file FILENAME.
%
% Example:
%   [Date,Time,Open,High,Low,Close,Volume,OpenInt] = importfile1('rbs.uk.txt',2, 918);
%
%    See also TEXTSCAN.

% Auto-generated by MATLAB on 2018/03/18 13:30:34

%% Initialize variables.
delimiter = ',';
if nargin<=2
    startRow = 2;
    endRow = inf;
end

%% Format for each line of text:
%   column1: datetimes (%{yyyy-MM-dd}D)
%	column2: datetimes (%{HH:mm:ss}D)
%   column3: double (%f)
%	column4: double (%f)
%   column5: double (%f)
%	column6: double (%f)
%   column7: double (%f)
%	column8: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%{yyyy-MM-dd}D%{HH:mm:ss}D%f%f%f%f%f%f%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines', startRow(1)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines', startRow(block)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Allocate imported array to column variable names
Date = dataArray{:, 1};
Time = dataArray{:, 2};
Open = dataArray{:, 3};
High = dataArray{:, 4};
Low = dataArray{:, 5};
Close = dataArray{:, 6};
Volume = dataArray{:, 7};
OpenInt = dataArray{:, 8};

% For code requiring serial dates (datenum) instead of datetime, uncomment
% the following line(s) below to return the imported dates as datenum(s).

% Date=datenum(Date);
% Time=datenum(Time);


