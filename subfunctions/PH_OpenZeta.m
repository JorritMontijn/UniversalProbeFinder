function sZetaResp = PH_OpenZeta(sClusters,strPath)
	%pre-allocate
	sZetaResp = struct;
	
	%ask what to load
	[strZetaFile,strZetaPath] = uigetfile(strPath,'Select event time, ZETA or Acquipix file');
	if isempty(strZetaFile) || strZetaFile(1) == 0,return;end
		
	%load
	sLoad = load(fullpath(strZetaPath,strZetaFile));
	
	%determine file type
	if isfield(sLoad,'vecZetaP') && isfield(sLoad,'vecDepth')
		%native
		vecDepth = sLoad.vecDepth;
		vecZetaP = sLoad.vecZetaP;
	elseif isfield(sLoad,'sSynthData')
		%acquipix synthesis
		sSynthData = sLoad.sSynthData;
		vecDepth = cell2vec({sSynthData.sCluster.Depth});
		vecZetaP = cellfun(@min,{sSynthData.sCluster.ZetaP});
	elseif isfield(sLoad,'sAP') && isfield(sLoad.sAP,'sCluster')
		%acquipix aggregate
		sCluster = sLoad.sAP.sCluster;
		vecDepth = cell2vec({sCluster.Depth});
		vecZetaP = cellfun(@min,{sCluster.ZetaP});
	elseif isfield(sLoad,'structEP') && (isfield(sLoad.structEP,'ActOnNI') || isfield(sLoad.structEP,'ActOnSecs'))
		%acquipix stimulus file
		if isfield(sLoad.structEP,'ActOnNI')
			vecEventOn = sLoad.structEP.ActOnNI;
		else
			vecEventOn = sLoad.structEP.ActOnSecs;
		end
		
		%calculate zeta
		if exist('zetatest','file')
			vecDepth = sClusters.vecDepth;
			intNumN = numel(vecDepth);
			vecZetaP = nan(1,intNumN);
			hWaitbar = waitbar(0,'Preparing to calculate zeta...','Name','ZETA progress');
			try
				for intN = 1:intNumN
					vecZetaP(intN) = zetatest(sClusters.cellSpikes{intN},vecEventOn);
					waitbar((intN-1)/intNumN,hWaitbar,sprintf('Calculating zeta-responsiveness for %d/%d',intN,intNumN));
				end
				delete(hWaitbar);
				
			catch ME
				waitbar((intN-1)/intNumN,hWaitbar,sprintf('Error: %s',ME.message));
				rethrow(ME);
			end
			%save file
			[strZetaFile,strZetaPath] = PH_SaveZeta(vecDepth,vecZetaP,strZetaPath);
			
		else
			errordlg('Please download the zetatest repository from https://github.com/JorritMontijn/zetatest and ensure you add the folders to the matlab path','ZETA repository not found');
		end
	else
		%file not recognized
		vecDepth = sClusters.vecDepth;
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
					error([mfilename ':WrongVariableType'],'Please save your event onset times as a single array to a .mat file and try again');
				else
					vecEventOn = varIn;
				end
				%calculate zeta
				intNumN = numel(vecDepth);
				vecZetaP = nan(1,intNumN);
				hWaitbar = waitbar(0,'Preparing to calculate zeta...','Name','ZETA progress');
				try
					for intN = 1:intNumN
						vecZetaP(intN) = zetatest(sClusters.cellSpikes{intN},vecEventOn);
						waitbar((intN-1)/intNumN,hWaitbar,sprintf('Calculating zeta-responsiveness for %d/%d',intN,intNumN));
					end
					delete(hWaitbar);
					
					%save file
					[strZetaFile,strZetaPath] = PH_SaveZeta(vecDepth,vecZetaP,strZetaPath);
				catch ME
					waitbar((intN-1)/intNumN,hWaitbar,sprintf('Error: %s',ME.message));
					rethrow(ME);
				end
			end
		end
	end
	
	%save
	sZetaResp.name = strZetaFile;
	sZetaResp.folder = strZetaPath;
	sZetaResp.vecDepth = vecDepth;
	sZetaResp.vecZetaP = vecZetaP;
end