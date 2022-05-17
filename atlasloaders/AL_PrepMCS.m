function sAtlas = AL_PrepMCS(strCharmSarmAtlasPath)
	%AL_PrepMCS Prepares CHARM/SARM NMT_v2.0_sym macaque brain Atlas
	%syntax: sAtlas = AL_PrepMCS(strCharmSarmAtlasPath)
	%	Input:
	%	- strCharmSarmAtlasPath: path to atlas files
	%
	%	Output: sAtlas, containing fields:
	%	- av: axes-modified annotated volume
	%	- tv: axes-modified template volume
	%	- st: structure tree
	%	- Bregma: location of bregma in modified coordinates
	%	- VoxelSize: size of a single entry in microns
	%	- BrainMesh: mesh of brain outline
	%	- ColorMap: color map for brain areas
	%
	%downloadable at https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/nonhuman/macaque_tempatl/template_nmtv2.html#nh-macaque-template-nmtv2
	%
	
	%imagesc(squeeze(tv(128,:,:))) = sagital slice (dorsal is x-high; posterior is y-low)
	%imagesc(squeeze(tv(:,156,:))) = coronal slice (dorsal is x-high; y=M/L, midline is 128.5)
	%imagesc(squeeze(tv(:,:,100))) = axial slice (anterior is x-high; y=M/L, midline is 128.5)
	%av = [ML AP DV]; 256 x 312 x 200
	
	%% load
	try
		%msg
		hMsg = msgbox('Loading CHARM/SARM macaque brain Atlas, please wait...','Loading MCS');
		
		%load brain mask
		strFile = ['NMT_v2.0_sym' filesep 'NMT_v2.0_sym_brainmask.nii'];
		strTarget = fullpath(strCharmSarmAtlasPath,strFile);
		if ~exist(strTarget,'file') && exist([strTarget '.gz'],'file'),gunzip([strTarget '.gz']);end %extract if gzipped
		matBrainMask = niftiread(strTarget); %annotated cortex
		
		%load charm
		strFile = ['NMT_v2.0_sym' filesep 'CHARM_in_NMT_v2.0_sym.nii'];
		strTarget = fullpath(strCharmSarmAtlasPath,strFile);
		if ~exist(strTarget,'file') && exist([strTarget '.gz'],'file'),gunzip([strTarget '.gz']);end %extract if gzipped
		avCharm = niftiread(strTarget); %annotated cortex
		avCharm = avCharm(:,:,:,1,end);
		vecSizeAvCharm = size(avCharm);
		vecUniqueCharm = unique(avCharm(:));
		
		%load sarm
		strFile = ['NMT_v2.0_sym' filesep 'SARM_in_NMT_v2.0_sym.nii'];
		strTarget = fullpath(strCharmSarmAtlasPath,strFile);
		if ~exist(strTarget,'file') && exist([strTarget '.gz'],'file'),gunzip([strTarget '.gz']);end %extract if gzipped
		avSarm = niftiread(strTarget); %annotated cortex
		avSarm = avSarm(:,:,:,1,end);
		vecSizeAvSarm = size(avSarm);
		vecUniqueSarm = unique(avSarm(:));
		
		%tables_CHARM
		strFile = ['tables_CHARM' filesep 'CHARM_key_table.csv'];
		strTarget = fullpath(strCharmSarmAtlasPath,strFile);
		sCharm = loadcsv(strTarget,',');
		cellTable = sCharm.Level6;
		vecIdxCharm = cellfun(@(x) str2double(getFlankedBy(x,'',':')),cellTable);
		cellNameCharm = cellfun(@(x) getFlankedBy(x,': ',' ('),cellTable,'uniformoutput',false);
		cellAcroCharm = cellfun(@(x) getFlankedBy(x,'(',')'),cellTable,'uniformoutput',false);
		
		%tables_SARM
		strFile = ['tables_SARM' filesep 'SARM_key_table.csv'];
		strTarget = fullpath(strCharmSarmAtlasPath,strFile);
		sSarm = loadcsv(strTarget,',');
		cellTable = sSarm.Level6;
		vecIdxSarm = cellfun(@(x) str2double(getFlankedBy(x,'',':')),cellTable);
		cellNameSarm = cellfun(@(x) getFlankedBy(x,': ',' ('),cellTable,'uniformoutput',false);
		cellAcroSarm = cellfun(@(x) getFlankedBy(x,'(',')'),cellTable,'uniformoutput',false);
		
		%color map
		strFile = ['tables_CHARM' filesep 'hue_CHARM_cmap.pal'];
		strTarget = fullpath(strCharmSarmAtlasPath,strFile);
		sMap = loadcsv(strTarget);
		matColorMapCharm = cell2mat(cellfun(@(x) [hex2dec(x(2:3)) hex2dec(x(4:5)) hex2dec(x(6:7))] ,sMap.Hue_CHARM_v1_3,'UniformOutput' ,false));
		
		%template volume
		strFile = ['NMT_v2.0_sym' filesep 'NMT_v2.0_sym.nii'];
		strTarget = fullpath(strCharmSarmAtlasPath,strFile);
		if ~exist(strTarget,'file') && exist([strTarget '.gz'],'file'),gunzip([strTarget '.gz']);end %extract if gzipped
		tv = niftiread(strTarget); %template volume
		
	catch ME
		close(hMsg);
		sAtlas = [];
		strStack = sprintf('Error in %s (Line %d)',ME.stack(1).name,ME.stack(1).line);
		errordlg(sprintf('%s\n%s',ME.message,strStack),'MCS Atlas load error')
		return;
	end
	
	%% transform
	%unify charm&sarm
	av = ones(size(avCharm),class(avCharm));
	intTotNum = numel(vecUniqueSarm) + numel(vecUniqueCharm);
	st = table('Size',[intTotNum,6],...
		'VariableTypes',{'double','double','double','string','string','double'},...
		'VariableNames',{'id','idCHARM','idSARM','name','acronym','parent_structure_id'});
	st.id(:) = 1:intTotNum;
	cmap = zeros(intTotNum,3);
	%charm
	vecCharm = 1:numel(vecUniqueCharm);
	st.idCHARM(vecCharm) = vecUniqueCharm;
	for intIdx=1:numel(vecIdxCharm)
		%add charm entry to table
		intIdxCharm = vecIdxCharm(intIdx);
		intEntry = find(vecUniqueCharm==intIdxCharm,1);
		if isempty(intEntry),continue;end
		st.name(intEntry) = cellNameCharm{intIdx};
		st.acronym(intEntry) = cellAcroCharm{intIdx};
		st.parent_structure_id(intEntry) = vecUniqueCharm(intEntry); %does not support multiple levels yet
		
		%add charm entry to unified av
		av(avCharm==intIdxCharm) = intEntry;
		
		%add color map entry
		cmap(intEntry,:) = matColorMapCharm(intIdxCharm+1,:);
	end
	
	%sarm
	vecSarm = (numel(vecUniqueCharm)+1):intTotNum;
	st.idSARM(vecSarm) = vecUniqueSarm;
	for intIdx=1:numel(vecIdxCharm)
		%add sarm entry to table
		intIdxSarm = vecIdxCharm(intIdx);
		intEntry = find(vecUniqueSarm==intIdxSarm,1);
		if isempty(intEntry),continue;end
		intNewEntry = numel(vecUniqueCharm)+intEntry;
		st.name(intNewEntry) = cellNameSarm{intIdx};
		st.acronym(intNewEntry) = cellAcroSarm{intIdx};
		st.parent_structure_id(intNewEntry) = vecUniqueSarm(intEntry); %does not support multiple levels yet
		
		%add charm entry to unified av
		av(avSarm==intIdxSarm) = intNewEntry;
		
		%add color map entry
		cmap(intEntry,:) = matColorMapCharm(intIdxCharm,:);
	end
	
	%compute brain mesh
	intCurvesPerDim = 12;
	dblMinSize = 100;
	matBrainMesh = getTrace3D(matBrainMask,intCurvesPerDim,dblMinSize);
	
	%voxel size
	vecVoxelSize = [250 250 250]; %microns
	
	%bregma
	vecBregma = [128.5 168 190]; %ML, AP, DV
	
	%% compile outputs
	sAtlas = struct;
	sAtlas.av = av;
	sAtlas.tv = tv;
	sAtlas.st = st;
	sAtlas.Bregma = vecBregma;
	sAtlas.VoxelSize = vecVoxelSize;
	sAtlas.BrainMesh = matBrainMesh;
	sAtlas.ColorMap = cmap/255;
	sAtlas.Type = 'CHARM-SARM-Macaque_NMT_v2_sym';
	
	%% close msg
	close(hMsg);
end