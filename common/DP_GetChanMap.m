function sChanMap = DP_GetChanMap(varFileLocationOrMetaStruct,dblChannelDistMicrons)
	%DP_GetChanMap Retrieve and parse IMEC Neuropixels channel map from meta file or structure
	%   sChanMap = DP_GetChanMap(varFileLocationOrMetaStruct,dblChannelDistMicrons)
	%
	%Inputs:
	% - varFileLocationOrMetaStruct can be a file location or meta structure
	% - dblChannelDistMicrons (optional; default: 20) supplied the inter-channel distance for
	%		snsChanMap entries that do not save the location in microns. Not used for snsGeomMap
	%
	%Note: avoid confusion about the direction of X, Y, Z, I've named the lateral (sideways)
	%direction along the probe "X" and the parallel (long) direction "D" for depth, as you're
	%usually not inserting a probe sideways into the brain, this should be rather unambiguous...
	%
	%Note 2: this function supports both snsChanMap and snsGeomMap entries
	%
	%Output structure:
	%sChanMap.Header.Probe = probe type (string)
	%sChanMap.Header.NumShanks = number of shanks
	%sChanMap.Header.NumX = number of X positions (Npx 1.0 only)
	%sChanMap.Header.NumD = number of depth positions (Npx 1.0 only)
	%sChanMap.Header.ShankSpacing = number of shanks
	%sChanMap.Header.ShankWidth = dblShankWidth; %number of shanks
	%sChanMap.S = vecShank; %shank number
	%sChanMap.X = vecX_microns; %lateral position of electrode in microns
	%sChanMap.D = vecD_microns; %depth position of electrode in microns
	%sChanMap.U = vecUseCh; %used flag
	%sChanMap.ChanMapRaw = matChanMap; %raw data for all channels
	%
	%Version history:
	%1.0 - 21 Feb 2024
	%	Created by Jorrit Montijn
	
	%check if channel distance is supplied
	if ~exist('dblChannelDistMicrons','var') || isempty(dblChannelDistMicrons)
		dblChannelDistMicrons = 20; %for Npx 1.0 distance is 20 microns
	elseif (~isnumeric(dblChannelDistMicrons)) || isnan(dblChannelDistMicrons)
		error([mfilename ':InputError'],'dblChannelDistMicrons is not numeric');
	end
	
	%check if input is struct
	if isstruct(varFileLocationOrMetaStruct)
		sMeta = varFileLocationOrMetaStruct;
	elseif exist(varFileLocationOrMetaStruct,'file')
		sMeta = DP_ReadMeta(varFileLocationOrMetaStruct);
	else
		error([mfilename ':InputError'],'Input is not a valid Imec meta file or meta struct');
	end
	
	%extract chan map
	if isfield(sMeta,'snsGeomMap')
		%split entries by parentheses and remove leading/lagging chars
		cellEntries=cellfun(@(x) x(2:(end-1)),regexp(sMeta.snsGeomMap,'\(.*?\)','match'),'UniformOutput',false);
		%assign header values
		strHeader = 'NP1000,1,0,70';%cellEntries{1};
		cellHeader = strsplit(strHeader,',');
		strProbe = cellHeader{1};
		[intNumShanks,dblShankSpacing,dblShankWidth] = struct('h', cellfun(@str2double,cellHeader(2:end),'uniformoutput',false)).h;
		
		%parse channel entries by splitting by colons and transforming to a numeric matrix
		matChanMap = cell2mat(cellfun(@(x) cellfun(@str2double,x),cellfun(@strsplit,cellEntries(2:end),cellfill(':',[1 numel(cellEntries)-1]),'UniformOutput',false)','UniformOutput',false));
		vecShank = matChanMap(:,1);
		vecX_microns = matChanMap(:,2);
		vecD_microns = matChanMap(:,3);
		vecUseCh = matChanMap(:,4);
		
		%add entries ot present in snsGeomMap
		intNumX = nan;
		intNumD = nan;
	elseif isfield(sMeta,'snsShankMap')
		%split entries by parentheses and remove leading/lagging chars
		cellEntries=cellfun(@(x) x(2:(end-1)),regexp(sMeta.snsShankMap,'\(.*?\)','match'),'UniformOutput',false);
		%assign header values
		[intNumShanks,intNumX,intNumD] = struct('h', cellfun(@str2double,strsplit(cellEntries{1},','),'uniformoutput',false)).h;
		dblShankSpacing = nan;
		dblShankWidth = nan;
		strProbe = 'Unknown';
		
		%parse channel entries by splitting by colons and transforming to a numeric matrix
		matChanMap = cell2mat(cellfun(@(x) cellfun(@str2double,x),cellfun(@strsplit,cellEntries(2:end),cellfill(':',[1 numel(cellEntries)-1]),'UniformOutput',false)','UniformOutput',false));
		vecShank = matChanMap(:,1);
		vecX = matChanMap(:,2);
		vecD = matChanMap(:,3);
		vecUseCh = matChanMap(:,4);
		
		%transform to microns
		vecX_microns = vecX.*dblChannelDistMicrons;
		vecD_microns = vecD.*dblChannelDistMicrons;
	else
		
	end
	
	%combine data
	sChanMap = struct;
	sChanMap.Header.Probe = strProbe; %probe type (string)
	sChanMap.Header.NumShanks = intNumShanks; %number of shanks
	sChanMap.Header.NumX = intNumX; %number of shanks
	sChanMap.Header.NumD = intNumD; %number of shanks
	sChanMap.Header.ShankSpacing = dblShankSpacing; %number of shanks
	sChanMap.Header.ShankWidth = dblShankWidth; %number of shanks
	sChanMap.S = vecShank; %shank number
	sChanMap.X = vecX_microns; %lateral position of electrode in microns
	sChanMap.D = vecD_microns; %depth position of electrode in microns
	sChanMap.U = vecUseCh; %used flag
	sChanMap.ChanMapRaw = matChanMap; %raw data for all channels
end


