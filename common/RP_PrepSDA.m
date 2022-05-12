function sAtlas = RP_PrepSDA(tv,av,st)
	
	%% get variables
	%st table variables:
	% #    IDX:   Zero-based index
	% #    -R-:   Red color component (0..255)
	% #    -G-:   Green color component (0..255)
	% #    -B-:   Blue color component (0..255)
	% #    -A-:   Label transparency (0.00 .. 1.00)
	% #    VIS:   Label visibility (0 or 1)
	% #    IDX:   Label mesh visibility (0 or 1)
	% #  LABEL:   Label description
	
	%% new
	%transform names to acronyms
	cellRemove = {', unspecified',' of ',' the ',' and ','(pre)'};
	acronym = st.Var8;
	%remove words
	for i=1:numel(cellRemove)
		acronym = strrep(acronym,cellRemove{i},' ');
	end
	%find start of words
	startIndex = regexpi(acronym,'(\w+|,{1}|\d+)');
	for i=1:numel(startIndex)
		acronym{i} = upper(acronym{i}(startIndex{i}));
	end
	
	%define misc variables
	%[ML,AP,DV] with dimensions 512 x 1024 x 512). The midline seems to be around ML=244
	
	%define misc variables
	%bregma in [AP,DV,ML]; c = 653, h = 440, s = 246
	vecBregma = [246,653,440];% bregma in SDA; [ML,AP,DV]
	vecVoxelSize = [39 39 39];
	
	%rat brain grid
	%sLoad = load('brainGridData.mat');
	%matBrainGrid = sLoad.brainGridData;
	matEdge = av>0;
	intCurvesPerDim = 16;
	dblMinSize = 1000;
	matLines = getTrace3D(matEdge,intCurvesPerDim,dblMinSize);
	
	%reduce lines
	vecNan = find(isnan(matLines(:,1)));
	vecEndCurves = vecNan-1;
	vecStartCurves = [1;vecNan(1:(end-1))+1];
	intReduceBy = 10;
	matLinesReduced = nan(ceil(size(matLines,1)/intReduceBy) + numel(vecStartCurves)*3,3);
	intEntry = 1;
	for intCurveIdx=1:numel(vecEndCurves)
		vecUseVertices = unique([vecStartCurves(intCurveIdx):intReduceBy:vecEndCurves(intCurveIdx) vecEndCurves(intCurveIdx)]);
		intAddNum = numel(vecUseVertices);
		matLinesReduced(intEntry:(intEntry+intAddNum-1),:) = matLines(vecUseVertices,:);
		intEntry = intEntry + intAddNum + 1;
	end
	matLinesReduced(intEntry:end,:) = [];
	
	%color map
	cmap=[st.Var2 st.Var3 st.Var4]./255;
	
	%transform av values
	av = av+1; %first id must be 1, not 0
	vecAvUnique = unique(av);
	cmap_mod = ones(max(vecAvUnique),3);
	cmap_mod(vecAvUnique,:) = cmap;
	
	%create new table
	st_mod = table('Size',[max(vecAvUnique),4],'VariableTypes',{'double','string','string','double'},'VariableNames',{'id','name','acronym','parent_structure_id'});
	st_mod.id(vecAvUnique) = st.Var1+1;
	st_mod.name(vecAvUnique) = st.Var8;
	st_mod.acronym(vecAvUnique) = acronym;
	st_mod.parent_structure_id(vecAvUnique) = st_mod.id(vecAvUnique);
	
	%% compile outputs
	sAtlas = struct;
	sAtlas.av = av;
	sAtlas.tv = tv;
	sAtlas.st = st_mod;
	sAtlas.Bregma = vecBregma;
	sAtlas.VoxelSize = vecVoxelSize;
	sAtlas.BrainMesh = matLinesReduced;
	sAtlas.ColorMap = cmap_mod;
	sAtlas.Type = 'Sprague-Dawley-Rat';
end