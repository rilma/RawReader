function [header,system_header,radar_header,process_header] = read_jro_longheader(filename)
%
% This routine reads the header structures from the Jicamarca 
% data files (eg. d2003080000.r) and summarizes all the information
% in a new header structure used by the other routines.
%
% This function is a simplified version of "read_longheader.m"
%   R. Ilma ( January 2007 )
%   Jicamarca Radio Observatory, Lima, Peru
%

fid = fopen(filename,'r','ieee-le');

% Getting fileinfo
lenstr = length(filename);
year = str2num(filename(lenstr-11:lenstr-8));
doy = str2num(filename(lenstr-7:lenstr-5));
set = str2num(filename(lenstr-4:lenstr-2));

% Reading First Header
first_header = read_jro_sheader(fid);
dtime = first_header.ltime+first_header.msec/1e3;

lheader_length = first_header.length;
sheader_length = 24;

% Reading the System Header
HeaderLength = fread(fid,1,'uint32');
NumSamples = fread(fid,1,'uint32');
NumProfiles = fread(fid,1,'uint32');
NumChannels = fread(fid,1,'uint32');
ADCResolution = fread(fid,1,'uint32');
PCDIOBusWidth = fread(fid,1,'uint32');
system_header = struct('HeaderLength',HeaderLength,...
	'NumSamples',NumSamples,...
	'NumProfiles',NumSamples,...
	'NumChannels',NumChannels,...
	'ADCResolution',ADCResolution,...
	'PCDIOBusWidth',PCDIOBusWidth);

% Reading the Radar Controller Header
HeaderLength = fread(fid,1,'uint32');
ExpType = fread(fid,1,'uint32');
NTx = fread(fid,1,'uint32');
Ipp = fread(fid,1,'float32');
TxA = fread(fid,1,'float32');
TxB = fread(fid,1,'float32');
NumWindows = fread(fid,1,'uint32');
NumTaus = fread(fid,1,'uint32');
CodeType = fread(fid,1,'uint32');
Line6Function = fread(fid,1,'uint32');
Line5Function = fread(fid,1,'uint32');
Clock = round(fread(fid,1,'float32')*1000)/1000;
PrePulseBefore = fread(fid,1,'uint32');
PrePulseAfter = fread(fid,1,'uint32');
RangeIpp = fscanf(fid,'%20c',1);
RangeTxA = fscanf(fid,'%20c',1);
RangeTxB = fscanf(fid,'%20c',1);
WindowInfo = struct('h0',0,'dh',0,'NSa',0);
WindowInfo = repmat(WindowInfo,NumWindows);
for iw = 1:NumWindows
	WindowInfo(iw).h0 = fread(fid,1,'float32');
	WindowInfo(iw).dh = fread(fid,1,'float32');
	WindowInfo(iw).NSa = fread(fid,1,'int32');
end
Taus = fread(fid,NumTaus,'float32');
NumCodes = fread(fid,1,'int32');
NumBauds = fread(fid,1,'int32');
Codes = fread(fid,[32*ceil(NumBauds/32.),NumCodes],'ubit1');

radar_header = struct('HeaderLength',HeaderLength,...
	'ExpType',ExpType,...
	'NTx',NTx,...
	'Ipp',Ipp,...
	'TxA',TxA,...
	'TxB',TxB,...
	'NumWindows',NumWindows,...
	'NumTaus',NumTaus,...
	'Taus',Taus,...
	'CodeType',CodeType,...
	'Line6Function',Line6Function,...
	'Line5Function',Line5Function,...
	'Clock',Clock,...
	'PrePulseBefore',PrePulseBefore,...
	'PrePulseAfter',PrePulseAfter,...
	'RangeIpp',RangeIpp,...
	'RangeTxA',RangeTxA,...
	'RangeTxB',RangeTxB,...
	'WindowInfo',WindowInfo,...
	'NumCodes',NumCodes,...
	'NumBauds',NumBauds,...
	'Codes',Codes);

fseek(fid,sheader_length+system_header.HeaderLength+radar_header.HeaderLength,'bof');

% Reading the Processing Header
HeaderLength = fread(fid,1,'uint32');
DataType = fread(fid,1,'uint32');
SizeOfDataBlock = fread(fid,1,'uint32');
ProfilesperBlock = fread(fid,1,'uint32');
DataBlocksperFile = fread(fid,1,'uint32');
DataWindows = fread(fid,1,'uint32');
ProcessFlags = fread(fid,1,'uint32');
CoherentIntegrations = fread(fid,1,'uint32');
IncoherentIntegrations = fread(fid,1,'uint32');
TotalSpectra = fread(fid,1,'uint32');
WindowInfo = struct('h0',0,'dh',0,'NSa',0);
WindowInfo = repmat(WindowInfo,NumWindows);
for iw = 1:NumWindows
	WindowInfo(iw).h0 = fread(fid,1,'float32');
	WindowInfo(iw).dh = fread(fid,1,'float32');
	WindowInfo(iw).NSa = fread(fid,1,'int32');
end
SpectraCombinations = fread(fid,[2,TotalSpectra],'int8');

process_header = struct('HeaderLength',HeaderLength,...
	'DataType',DataType,...
	'SizeOfDataBlock',SizeOfDataBlock,...
	'ProfilesperBlock',ProfilesperBlock,...
	'DataBlocksperFile',DataBlocksperFile,...
	'DataWindows',DataWindows,...
	'ProcessFlags',ProcessFlags,...
	'CoherentIntegrations',CoherentIntegrations,...
	'IncoherentIntegrations',IncoherentIntegrations,...
	'TotalSpectra',TotalSpectra,...
	'WindowInfo',WindowInfo,...
	'SpectraCombinations',SpectraCombinations);

 if process_header.DataType~=0,
 	num_chan = length(find((SpectraCombinations(:,1)-SpectraCombinations(:,2))==0));
 else, num_chan = system_header.NumChannels; end;

% Getting the data type.
% 0:Int8, 1:Int16, 2:Int32, 3:Int64, 4:Float, 5: Double
data_type = round(log(max(mod(round(process_header.ProcessFlags/2^6),2^6),1))/log(2));

fclose(fid);

% Summary Header
header = struct('lheader_length',lheader_length,...
	'sheader_length',sheader_length,...
	'year',year,...
	'doy',doy,...
	'set',set,...
	'startime',dtime,...
	'stoptime',0,...
	'ipp',radar_header.Ipp,...
	'pw',radar_header.TxA,...
	'txa',radar_header.TxA,...
	'txb',radar_header.TxB,...
	'num_hei',sum(process_header.WindowInfo(:).NSa),...
	'num_win',process_header.DataWindows,...
	'first_height',process_header.WindowInfo(:).h0,...
	'spacing',process_header.WindowInfo(:).dh,...
	'samples_win',process_header.WindowInfo(:).NSa,...
	'num_chan',num_chan,...
	'num_pairs',max((process_header.TotalSpectra-num_chan),0),...
	'num_prof',process_header.ProfilesperBlock,...
	'num_coh',max(process_header.CoherentIntegrations,1),...
	'num_incoh',max(process_header.IncoherentIntegrations,1),...
	'bytes_block',process_header.SizeOfDataBlock+sheader_length,...
	'blocks_file',process_header.DataBlocksperFile,...
	'bytes_file',0,...
	'data_type',data_type,...
	'code',Codes,...
	'taus',Taus,...
	'switchan',0);

header.bytes_file = header.bytes_block*header.blocks_file + header.lheader_length - header.sheader_length;
