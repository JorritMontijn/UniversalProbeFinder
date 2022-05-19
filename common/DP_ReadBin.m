function [matDataArray,intFeof] = DP_ReadBin(intSamp0, intReadSamps, sMeta, strFile, strPath, strClass,vecReadCh)
	%DP_ReadBin Reads SpikeGLX binary file
	%   [matDataArray,intFeof] = DP_ReadBin(intSamp0, intReadSamps, sMeta, strFile, strPath, strClass,vecReadCh)
	%
	%Read intReadSamps timepoints from the binary file, starting at
	%timepoint offset intSamp0.
	%
	%Set strClass to your preferred output class (default is int16)
	%Specify a vector of channels to read by suppling vecReadCh. Channels
	%are specified with starting index 1; e.g., if you have 385 channels,
	%and you only wish to read the first channel, set vecReadCh to 1 (and
	%not to 0)
	%
	%Outputs:
	% - matDataArray; data matrix of size [numel(vecReadCh),intReadSamps].
	%Note that intReadSamps returned is the lesser of: [intReadSamps,
	%timepoints available].
	% - intFeof; end-of-file indicator to check if the entire file was read
	%
	%Version 1.0
	%xxxx-xx-xx; Created by Bill Karsh.
	%Version 2.0
	%2021-06-28; Updated by Jorrit Montijn, based on ReadBin() by Bill
	%Karsh. Changes include: single-channel and multi-channel reads, e.g.
	%to load only the synchronization channel
	
	%%
	%{
	intSamp0=-inf
	intReadSamps=inf
	sMeta,
	strFile=[strFile,strExt]
	strPath,
	strClass=[]
	vecReadCh=intSyncCh
	%}
	%% check inputs
	if ~exist('strClass','var') || isempty(strClass)
		strClass = 'int16';
	end
	
	intChanNum = str2double(sMeta.nSavedChans);
	if ~exist('vecReadCh','var') || isempty(vecReadCh)
		vecReadCh = 1:intChanNum;
	end
	
	%% pre-allocate
	intFileSamps = str2double(sMeta.fileSizeBytes) / (2 * intChanNum);
	intSamp0 = max(intSamp0, 0);
	intReadSamps = min(intReadSamps, intFileSamps - intSamp0);
	intTotSize = intReadSamps*2*intChanNum;
	vecSizeA = [intChanNum, intReadSamps];
	
	strFile = fullpath(strPath, strFile);
	ptrFile = fopen(strFile, 'rb');
	intStatus = fseek(ptrFile, intSamp0 * 2 * intChanNum, 'bof');
	if intStatus == -1 %try again once
		intStatus = fseek(ptrFile, intSamp0 * 2 * intChanNum, 'bof');
		if intStatus  == -1
			error([mfilename 'E:ReadError'],sprintf('Cannot read file "%s"',strFile));
		end
	end
	
	%% read
	try
		if numel(vecReadCh) == intChanNum
			%read everything
			matDataArray = fread(ptrFile, vecSizeA, sprintf('int16=>%s',strClass));
		elseif numel(vecReadCh) == 1 %read single channel
			%move pointer to correct channel
			intStatus=fseek(ptrFile,(vecReadCh-1)*2,'cof');
			matDataArray = [1, intReadSamps];
			%read samples from 1 channel while skipping all others; should be
			%faster than read-all-and-discard, but it doesn't actually seem to
			%make much difference
			hTic=tic;
			intSampsPerRead = 10000;
			vecStartSamp = 1:intSampsPerRead:intReadSamps;
			for intStartSamp=vecStartSamp
				intSampsPerRead = min(intReadSamps-intSamp0-intStartSamp+1,intSampsPerRead);
				matDataArrayTemp = fread(ptrFile, [1,intSampsPerRead], sprintf('int16=>%s',strClass),2*(intChanNum-1));
				matDataArray(1,(intStartSamp:(intStartSamp+intSampsPerRead-1))) = matDataArrayTemp(1,:);
				if toc(hTic) > 5
					fprintf('Reading channel %d; sample %d/%d (%.1f%%) [%s]\n',vecReadCh,intStartSamp,intReadSamps,(intStartSamp/intReadSamps)*100,getTime());
					hTic=tic;
					%ftell(fid)
				end
			end
		else
			%read specific channels
			matDataArray = [numel(vecReadCh), intReadSamps];
			hTic=tic;
			%read increments of 1000, then discard anything not needed
			intSampsPerRead = 1000;
			vecStartSamp = 1:intSampsPerRead:intReadSamps;
			for intStartSamp=vecStartSamp
				intSampsPerRead = min(intReadSamps-intSamp0-intStartSamp+1,intSampsPerRead);
				matDataArrayTemp = fread(ptrFile, [intChanNum,intSampsPerRead], sprintf('int16=>%s',strClass));
				matDataArray(:,(intStartSamp:(intStartSamp+intSampsPerRead-1))) = matDataArrayTemp(vecReadCh,:);
				if toc(hTic) > 5
					fprintf('Reading sample %d/%d (%.1f%%) [%s]\n',intStartSamp,intReadSamps,(intStartSamp/intReadSamps)*100,getTime());
					hTic=tic;
					%ftell(fid)
				end
			end
		end
		%close file
		intFeof=feof(ptrFile);
		fclose(ptrFile);
	catch ME
		%close file and show error
		intFeof=-1;
		fclose(ptrFile);
		rethrow(ME);
	end
end