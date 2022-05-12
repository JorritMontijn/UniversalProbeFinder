function intProbeIdx = PH_SelectProbeNr(sProbeCoords,sAtlas)
	
	%% generate selection options
	if ~isfield(sProbeCoords,'format') || ~strcmpi(sProbeCoords.format,'ML,AP,DV')
		error([mfilename ':WrongFormat'],'Probe coordinate system is not in Paxinos-format (ML,AP,DV)');
	end
	
	%find probe entry points
	intProbeNum = numel(sProbeCoords.cellPoints);
	cellProbes = cell(1,intProbeNum);
	for intProbe=1:intProbeNum
		%get probe vector from points
		sProbeCoords.intProbeIdx = intProbe;
		[vecSphereVector,vecBrainIntersection,matRefVector] = PH_Points2vec(sProbeCoords,sAtlas);
		if isempty(vecBrainIntersection)
			cellProbes{intProbe} = sprintf('Probe %d, starting at %s',intProbe,'"none"');
		else
			%get area
			vecBrainIntersection = round(vecBrainIntersection);
			intIntersectArea = sAtlas.av(vecBrainIntersection(1),vecBrainIntersection(2),vecBrainIntersection(3));
			cellAreas = string(sAtlas.st.name);
			strArea = cellAreas{intIntersectArea};
			cellProbes{intProbe} = sprintf('Probe %d, starting at %s',intProbe,strArea);
		end
	end
	
	%% get probe nr
	%show probes
	intProbeIdx = listdlg('Name','Select probe','PromptString',sprintf('Select probe # for %s',sProbeCoords.name),...
		'SelectionMode','single','ListString',cellProbes,'ListSize',[400 20*intProbeNum]);
	