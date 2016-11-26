function sheader = read_jro_sheader(fid)
%
% This function reads the short header of each
% data block from the rawdata files (eg. d2003079000.r)
%
% Based on "read_sheader.m"
%       R. Ilma ( January 2007 )
%   Jicamarca Radio Observatory, Lima, Peru
%

length = fread(fid,1,'uint32');
version = fread(fid,1,'uint16');
datablock = fread(fid,1,'uint32');
ltime = fread(fid,1,'int32');
milsec = fread(fid,1,'uint16');
timezone = fread(fid,1,'int16');
dstflag = fread(fid,1,'int16');
errorCount = fread(fid,1,'uint32');

ltime = ltime - timezone*60;

sheader = struct('length',length, ...
				 'version',version, ...
				 'datablock',datablock, ...
				 'ltime',ltime, ...
				 'msec',milsec, ...
				 'timezone',timezone, ...
				 'dstflag',dstflag, ...
				 'errorCount',0);
return;
