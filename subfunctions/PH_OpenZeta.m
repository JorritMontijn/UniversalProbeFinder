function [sClusters,boolSuccess] = PH_OpenZeta(sClusters,strPath)
	
	%ask what to load
	boolSuccess = false;
	strText = 'Select event time, ZETA or Acquipix file';
	if ismac; msgbox(strText,'OK');end
	[strZetaFile,strZetaPath] = uigetfile(strPath,strText);
	if isempty(strZetaFile) || strZetaFile(1) == 0,return;end
	
	%load
	sLoad = load(fullpath(strZetaPath,strZetaFile));
	
	%determine file type
	vecZetaP = [];
	if isfield(sLoad,'vecZetaP') && isfield(sLoad,'vecDepth')
		%native
		vecDepth = sLoad.vecDepth;
		vecZetaP = sLoad.vecZetaP;
		vecClusterId = sLoad.vecClusterId;
	elseif isfield(sLoad,'sSynthData')
		%acquipix synthesis
		sSynthData = sLoad.sSynthData;
		vecDepth = [sSynthData.sCluster.Depth];
		vecZetaP = cellfun(@min,{sSynthData.sCluster.ZetaP});
		vecClusterId = [sSynthData.sCluster.IdxClust];
	elseif isfield(sLoad,'sAP') && isfield(sLoad.sAP,'sCluster')
		%acquipix aggregate
		sCluster = sLoad.sAP.sCluster;
		vecDepth = cell2vec({sCluster.Depth});
		vecZetaP = cellfun(@min,{sCluster.ZetaP});
		vecClusterId = [sSynthData.sCluster.IdxClust];
	elseif isfield(sLoad,'structEP') && (isfield(sLoad.structEP,'ActOnNI') || isfield(sLoad.structEP,'ActOnSecs'))
		%acquipix stimulus file
		if isfield(sLoad.structEP,'ActOnNI')
			vecEventOn = sLoad.structEP.ActOnNI;
		else
			vecEventOn = sLoad.structEP.ActOnSecs;
		end
		
		%calculate zeta
		if exist('zetatest','file')
			if isempty(sClusters) || ~isfield(sClusters,'Clust') || ~isfield(sClusters.Clust,'SpikeTimes') || ~isfield(sClusters.Clust,'Depth')
				%save
				msgbox('Cannot compute ZETA without spiking data', 'Error','error');
				return;
			end
			vecDepth = [sClusters.Clust.Depth];
			vecClusterId = [sClusters.Clust.cluster_id];
			intNumN = numel(vecDepth);
			vecZetaP = nan(1,intNumN);
			hWaitbar = waitbar(0,'Preparing to calculate zeta responsiveness...','Name','ZETA progress');
			try
				for intN = 1:intNumN
					vecZetaP(intN) = zetatest(sClusters.Clust(intN).SpikeTimes,vecEventOn);
					waitbar((intN-1)/intNumN,hWaitbar,sprintf('Calculating zeta-responsiveness for %d/%d',intN,intNumN));
				end
				delete(hWaitbar);
				
			catch ME
				waitbar((intN-1)/intNumN,hWaitbar,sprintf('Error: %s',ME.message));
				rethrow(ME);
			end
			%save file
			[strZetaFile,strZetaPath] = PH_SaveZeta(vecDepth,vecZetaP,vecClusterId,strZetaPath);
			
		else
			errordlg('Your repository is corrupt: cannot find zetatest. Please download the zetatest repository from https://github.com/JorritMontijn/zetatest and ensure you add the folders to the matlab path','ZETA repository not found');
		end
	else
		%check data
		if isempty(sClusters) || ~isfield(sClusters,'Clust') || ~isfield(sClusters.Clust,'SpikeTimes') || ~isfield(sClusters.Clust,'Depth')
			%save
			msgbox('Cannot compute ZETA without spiking data', 'Error','error');
			return;
		end
		
		%file not recognized
		vecDepth = sClusters.Clust.Depth;
		vecClusterId = sClusters.Clust.cluster_id;
		vecZetaP = [];
		cellFields = fieldnames(sLoad);
		if numel(cellFields) == 1
			varIn = sLoad.(cellFields{1});
			if numel(varIn) == numel(vecDepth)
				vecZetaP = varIn;
			else
				%ask if this variable is event times
				opts = struct;
				opts.Default = 'Cancel';
				opts.Interpreter = 'none';
				strAns = questdlg(sprintf('Does the variable "%s" contain event (onset) times?',cellFields{1}),'Confirm variable type','Yes','Cancel',opts);
				if ~strcmpi(strAns,'yes')
					return;
				else
					vecEventOn = varIn;
				end
				%calculate zeta
				intNumN = numel(vecDepth);
				vecZetaP = nan(1,intNumN);
				hWaitbar = waitbar(0,'Preparing to calculate zeta...','Name','ZETA progress');
				try
					for intN = 1:intNumN
						vecZetaP(intN) = zetatest(sClusters.Clust(intN).SpikeTimes,vecEventOn);
						waitbar((intN-1)/intNumN,hWaitbar,sprintf('Calculating zeta-responsiveness for %d/%d',intN,intNumN));
					end
					delete(hWaitbar);
					
					%save file
					[strZetaFile,strZetaPath] = PH_SaveZeta(vecDepth,vecZetaP,vecClusterId,strZetaPath);
				catch ME
					waitbar((intN-1)/intNumN,hWaitbar,sprintf('Error: %s',ME.message));
					rethrow(ME);
				end
			end
		end
	end
	
	%check output
	boolSuccess = ~isempty(vecZetaP);
	if ~boolSuccess
		errordlg('Could not load or calculate ZETA responsiveness, please try again.','ZETA values missing');
	else
		%pre-allocate
		sClustZeta = struct;
		sClustZeta(numel(vecZetaP)).cluster_id = 0;
		sClustZeta(numel(vecZetaP)).ZetaP = 0;
		sClustZeta(numel(vecZetaP)).Depth = 0;
		
		%fill
		for i=1:numel(vecZetaP)
			sClustZeta(i).cluster_id = vecClusterId(i);
			sClustZeta(i).ZetaP = vecZetaP(i);
			sClustZeta(i).Depth = vecDepth(i);
		end
		
		%merge
		sClusters.Clust = PH_MergeClusterData(sClusters.Clust,sClustZeta);
	end
	
	%transform p-value to z-score if ZetaP is present
	if isfield(sClusters,'Clust') && isfield(sClusters.Clust,'ZetaP')
		for i=1:numel(sClusters.Clust)
			sClusters.Clust(i).Zeta = -norminv(min(sClusters.Clust(i).ZetaP)/2);
		end
		sClusters.Clust = rmfield(sClusters.Clust,'ZetaP');
	end
end