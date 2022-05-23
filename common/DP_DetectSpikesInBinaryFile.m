function [vecSpikeCh,vecSpikeT,intTotT] = DP_DetectSpikesInBinaryFile(strFilename,sP,vecChanMap)
	%DP_DetectSpikesInBinaryFile Detect spike times in binary (SpikeGLX) file
	%   [vecSpikeCh,vecSpikeT,intTotT] = DP_DetectSpikesInBinaryFile(strFile,sP,vecChanMap)
	%
	%Note: vecSpikeT is in sample numbers, not in seconds. To convert to seconds, use:
	%sMeta = DP_ReadMeta(fullpath(strPath,strMetaFile)); %meta file for your binary
	%vecSpikeSecs = vecSpikeT/str2double(sMeta.imSampRate) + ...
	%	str2double(sMeta.firstSample)/str2double(sMeta.imSampRate); %conversion to seconds
	%
	%Note2: as window edges can induce false positives, this function will not return spikes close
	%to the beginning or end of the recording (default cut-off: ~1/500 * sampling rate)
	
	%load meta data
	[strPath,strFile,strExt] = fileparts(strFilename);
	if ~(strcmp(strExt,'.meta') || strcmp(strExt,'.bin'))
		strFile = strcat(strFile,strExt);
	end
	strMeta = strcat(strFile,'.meta');
	strBin = strcat(strFile,'.bin');
	
	%check they exist
	if ~exist(fullpath(strPath,strMeta),'file')
		error([mfilename ':FileNotFound'],sprintf('File not found: %s at %s',strMeta,strPath));
	end
	if ~exist(fullpath(strPath,strBin),'file')
		error([mfilename ':FileNotFound'],sprintf('File not found: %s at %s',strBin,strPath));
	end
	
	%copy to temp folder
	%doesn't actually speed things up...
	%{
	strTempFolder = PF_getIniVar('strTempDataPath');
	if isempty(strTempFolder) || strTempFolder(1) == 0
		strTempFolder = strPath;
	end
	strBinFile = fullpath(strTempFolder,strBin);
	sDirBin = dir(fullpath(strPath,strBin));
	strFileSizeGB = sprintf('%.2f',sDirBin(1).bytes / 1024^3);
	if ~strcmpi(strTempFolder,strPath)
		hMsg = msgbox(['Copying ' strBin ' (' strFileSizeGB ' GB) to temp folder, this could take a while...'],'Copying data');
		[status,msg,msgID] = copyfile(fullpath(strPath,strBin),strBinFile);
		close(hMsg);
		if status == 0
			errordlg(msg,'Copy error');
			error(msgID,msg);
		end
	end
	%}
	
	%wait bar
	hWaitbar = waitbar(0,'Preparing spike detection','Name',sprintf('Spike detection of %s',strBin));
		
	%find # of samples in file
	strBinFile = fullpath(strPath,strBin);
	sMeta = DP_ReadMeta(fullpath(strPath,strMeta));
	intBytes = str2double(sMeta.fileSizeBytes);
	sDirBin = dir(strBinFile);
	intRealBytes = sDirBin(1).bytes;
	intSavedChans = str2double(sMeta.nSavedChans);
	intFirstSample = str2double(sMeta.firstSample);
	dblSampRate = str2double(sMeta.imSampRate);
	dblT0 = intFirstSample/dblSampRate;
	dblMetaDurSecs = str2double(sMeta.fileTimeSecs);
	dblRealDurSecs = intRealBytes / dblSampRate / intSavedChans / 2;
	if (dblMetaDurSecs-dblRealDurSecs) > 1/dblSampRate
		error([mfilename ':DataMismatch'],sprintf('Real file size and meta data do not match for: %s at %s',strBin,strPath));
	end
	intTotSamples = intBytes / intSavedChans / 2;
	dblTotDur = intTotSamples / dblSampRate;
	
	%get chan map
	if ~exist('vecChanMap','var') || isempty(vecChanMap)
		vecChanMap = 1:intSavedChans;
	end
	%get parameters
	if ~exist('sP','var') || isempty(sP)
		sP = struct;
	end
	intStartT = getOr(sP,'tstart',0);
	intStopT = getOr(sP,'tend',intTotSamples);
	dblHighPassFreq = getOr(sP,'fshigh',150);
	dblSpkTh = getOr(sP,'spkTh',-6);
	intWinEdge = getOr(sP,'winEdge',ceil((dblSampRate*2e-3)/2)*2+1);
	intBuffT = getOr(sP,'NT',65600);
	intCAR = getOr(sP,'CAR',1);
	intType = getOr(sP,'minType',1);
	if isfield(sP,'fslow') && ~isempty(sP.fslow) && sP.fslow<sP.fs/2
		dblLowPassFreq = sP.fslow;
	else
		dblLowPassFreq = [];
	end
	
	%build filter
	if ~isempty(dblLowPassFreq)
		[b, a] = butter(3, [dblHighPassFreq/dblSampRate,dblLowPassFreq/dblSampRate]*2, 'bandpass');
	else
		[b, a] = butter(3, dblHighPassFreq/dblSampRate*2, 'high');
	end
	
	%set class
	if ~exist('strClass','var') || isempty(strClass)
		strClass = 'int16';
	end
	
	%open file
	intSamp0 = max(intStartT, 0);
	ptrFile = fopen(strBinFile, 'rb');
	intStatus = fseek(ptrFile, intSamp0 * 2 * intSavedChans, 'bof');
	if intStatus == -1 %try again once
		intStatus = fseek(ptrFile, intSamp0 * 2 * intSavedChans, 'bof');
		if intStatus  == -1
			error([mfilename 'E:ReadError'],sprintf('Cannot read file "%s"',strBinFile));
		end
	end
	
	%define variables
	vecSpikeCh = zeros(5e4,1, 'uint16');
	vecSpikeT = zeros(5e4,1, 'int64');
	intSpikeCounter = 0;
	
	%get starting times
	intReadSamps = min(intBuffT, intTotSamples - intSamp0);
	vecSizeA = [intSavedChans, intReadSamps];
	vecStartBatches = (1 + intStartT):intBuffT:min(intTotSamples,intStopT);
	intLastBatch = intTotSamples-vecStartBatches(end)-1;
	
	% detect rough spike timings
	matCarryOver = zeros(0,strClass);
	for intBatch=1:numel(vecStartBatches)
		%define start
		intStart = vecStartBatches(intBatch);
		waitbar(intBatch/numel(vecStartBatches),hWaitbar,sprintf('Detecting spikes in batch %d/%d',intBatch,numel(vecStartBatches)));
		
		%crop end if last batch
		if intBatch == numel(vecStartBatches)
			vecSizeA = [intSavedChans, intLastBatch];
		end
		
		%load data
		matDataArray = fread(ptrFile, vecSizeA, sprintf('int16=>%s',strClass));
		
		%reorder to chan map & transfer to gpu
		matDataArray = gpuArray(matDataArray(vecChanMap,:));
		
		%add carry-over to beginning of array
		matBuffer = cat(2,matCarryOver,matDataArray);
		
		%add last two 2*edge to carry-over
		matCarryOver = matDataArray(:,(1+end-intWinEdge*2):end);
		
		% apply filters and median subtraction
		matFiltered = DP_gpufilter(matBuffer, b, a, intCAR);
	
		% very basic threshold crossings calculation
		matFiltered = matFiltered./std(matFiltered,1,1); % standardize each channel ( but don't whiten)
		matMins = DP_FindMins(matFiltered, 30, 1, intType); % get local minima as min value in +/- 30-sample range
		vecSpkInd = find(matFiltered<(matMins+1e-3) & matFiltered<dblSpkTh); % take local minima that cross the negative threshold
		[vecT, vecCh] = ind2sub(size(matFiltered), vecSpkInd); % back to two-dimensional indexing
		
		%remove beginning/end transients
		vecCh(vecT<intWinEdge | vecT>(intBuffT-intWinEdge)) = []; % filtering may create transients at beginning or end. Remove those.
		vecT(vecT<intWinEdge | vecT>(intBuffT-intWinEdge)) = []; % filtering may create transients at beginning or end. Remove those.
		
		%remove offset from carry-over
		if intBatch>1
			intStart = intStart - 2*intWinEdge;
		end
		
		%save time of spike (xi) and channel (xj)
		if intSpikeCounter+numel(vecCh)>numel(vecSpikeCh)
			vecSpikeCh(2*numel(vecSpikeCh)) = 0; % if necessary, extend the variable which holds the spikes
			vecSpikeT(2*numel(vecSpikeT)) = 0; % if necessary, extend the variable which holds the spikes
		end
		vecSpikeCh(intSpikeCounter + [1:numel(vecCh)]) = gather(vecCh); % collect the channel identities for the detected spikes
		vecSpikeT(intSpikeCounter + [1:numel(vecT)]) = (int64(gather(vecT))+intStart); % collect the channel identities for the detected spikes
		
		intSpikeCounter = intSpikeCounter + numel(vecCh);
	end
	delete(hWaitbar);
	
	%calculate outputs
	intTotT = (intBuffT*intBatch + intLastBatch);
	if isempty(intTotT),intTotT=0;end
	vecSpikeCh = vecSpikeCh(1:intSpikeCounter);
	vecSpikeT = vecSpikeT(1:intSpikeCounter);
end

