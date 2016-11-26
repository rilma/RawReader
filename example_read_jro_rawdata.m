
%
%   Example routine to read a raw data file of Jicamarca Radar
%
%   R. Ilma ( January 2007 )
%   Jicamarca Radio Observatory, Lima, Peru
%

dpath = '/home/rilma/tmp/rawdata/D2006354/';

filetype = 'D*.r';
fname = dir([dpath, filetype]);
my_file = fname(1).name;
header = read_jro_longheader([dpath,my_file]);
fid = fopen([dpath,my_file],'r','ieee-le');
 for j = 1 : header.blocks_file  
  [newdata,fid,tmp_dtime,volt] = ...
      read_jro_rawdata(fid,header,header.startime,header.startime+100);
  [nhx, nhy, nhz] = size(volt);
  disp([num2str(j,'%03d'), ') ', datestr(datenum(1970,1,1) + tmp_dtime/86400)]);
  disp([' # profiles: ',num2str(nhx, '%03d')]);
  disp([' # ranges: ', num2str(nhy, '%03d')]);
  disp([' # channels: ', num2str(nhz, '%03d')]);
 end
fclose('all');
