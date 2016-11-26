function [newdata,fid,dtime,volt] = read_jro_rawdata(fid,header,startime,stoptime)
%
% This function reads each data block of rawdata files (eg.
% d2003078000.dat)
%
% Inputs:
%   fid: file id number.
%	header: header information.
%	startime,stoptime: interval time
%
% Outputs:
%   newdata: flag 0(no data)|1(data available)
%   fid: file id
%	dtime: local time in seconds
%	volt: complex voltage
%
% This function is a simplified vesion of "read_rawdata.m"
%       R. Ilma ( January 2007 )
%       
%

pos = ftell(fid);

% If there is no more data in the actual file change to another data file
fseek(fid,0,'eof'); filesize = ftell(fid);
 newdata = (pos+header.bytes_block <= filesize);

fseek(fid,pos,'bof');

% Getting short_header information
sheader = read_jro_sheader(fid);
dtime = sheader.ltime+sheader.msec/1e3;

% Reading complex voltages
fseek(fid,pos+sheader.length,'bof');
data_length = header.num_chan*header.num_hei*header.num_prof;

% Getting the data type. 0:Int8, 1:Int16, 2:Int32, 3:Int64
% 4:Float, 5:Double
switch header.data_type
	case 1
		volt = fread(fid,[2,data_length],'int16');
	case 2
		volt = fread(fid,[2,data_length],'int32');
	case 3
		volt = fread(fid,[2,data_length],'int64');
	case 4
		volt = fread(fid,[2,data_length],'float32');
	case 5
		volt = fread(fid,[2,data_length],'float64');
	otherwise
		volt = fread(fid,[2,data_length],'int8');
end

volt = reshape(complex(volt(1,:),volt(2,:)),[header.num_chan/(1+(header.switchan>0)),header.num_hei,header.num_prof*(1+(header.switchan>0))]);

volt = permute(volt,[3,2,1]);
