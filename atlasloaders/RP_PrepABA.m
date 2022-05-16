function sAtlas = RP_PrepABA(tv_accf,av_accf,st)
	%RP_PrepABA Prepares Allen Brain mouse Atlas
	%syntax: sAtlas = RP_PrepABA(tv_accf,av_accf,st)
	%	Input:
	%	- (tv_accf,av_accf,st): outputs of RP_LoadABA()
	%
	%	Output: sAtlas, containing fields:
	%	- av: axes-modified annotated volume
	%	- tv: axes-modified template volume
	%	- st: structure tree [1327×22 table]
	%	- Bregma: location of bregma in modified coordinates
	%	- VoxelSize: size of a single entry in microns [10 10 10]
	%	- BrainMesh: mesh of brain outline [23382×3 double]
	%	- ColorMap: color map for brain areas [1327×3 double]
	%
	%Note on axes:
	%Coordinates are av(x,y,z) where [x=ML y=AP z=DV], using the atlas's Bregma in the native atlas
	%grid entry indices as origin where (x,y,z)=(0,0,0). The native ABA coordinate system is
	%different,
	% - probe coordinates are transformed to microns and the origin (x=0,y=0,z=0) is bregma
	% - the location of the "probe" is the location of the _tip_ relative to bregma
	% - low ML (-x) is left of bregma, high ML (+x) is right of bregma
	% - low AP is posterior (i.e., -y in AP coordinates is posterior to bregma)
	% - low DV is ventral (i.e., -z w.r.t. lambda is ventral and inside of the brain, while
	% - Note that this is not the native Allen Brain CCF coordinates, as those do not make any sense.
	% - the probe has two angles: ML and AP where (0;0) degrees is a vertical insertion
	%
	%
	%The ABA CCF coordinates are (x=-AP,y=-DV,z=-ML)
	%imagesc(squeeze(av(x,:,:))) is coronal slice (-ML by -DV, where DV=0 is dorsal, and DV=max is ventral)
	%imagesc(squeeze(av(:,y,:))) is axial slice (-ML by -AP, where AP=0 is anterior, AP=max is posterior)
	%imagesc(squeeze(av(:,:,z))) is saggital slice (-DV by -AP, DV=0 is dorsal; AP=0 is anterior)
	%
	%Paxinos coordinates are (x=ML,y=AP,z=DV)
	%imagesc(squeeze(av(x,:,:))) is saggital slice (AP by DV, AP=0 is posterior, and DV=0 is ventral)
	%imagesc(squeeze(av(:,y,:))) is coronal slice (ML by DV, where DV=0 is ventral, and DV=max is dorsal)
	%imagesc(squeeze(av(:,:,z))) is axial slice (ML by AP, AP=0 is posterior, and AP=max is anterior)
	%
	%In Paxinos coordinates, coordinates relative to bregma (bregma - X) mean that -AP is posterior,
	%+AP is anterior, -DV is dorsal, +DV is ventral, -ML is left, +ML is right
	%
	%To transform ABA CCF to Paxinos, we therefore do the following:
	%av = permute(av_accf(end:-1:1,end:-1:1,:), [3 1 2]);
	
	%% get variables
	%define misc variables
	vecBregma_accf = [540,0,570];% bregma in accf; [AP,DV,ML]
	vecVoxelSize_accf = [10 10 10];% bregma in accf; [AP,DV,ML]
	
	%brain grid
	%sLoad = load(fullfile(fileparts(mfilename('fullpath')), 'brainGridData.mat'));
	sLoad = load('brainGridData.mat');
	matBrainMesh_accf = sLoad.brainGridData;
	%remove zeros
	matBrainMesh_accf = double(matBrainMesh_accf);
	matBrainMesh_accf(sum(matBrainMesh_accf,2)==0,:) = NaN;
	
	%color map
	%sLoad = load(fullfile(fileparts(mfilename('fullpath')), 'allen_ccf_colormap_2017.mat'));
	sLoad = load('allen_ccf_colormap_2017.mat');
	cmap=sLoad.cmap;
	
	%% transform atlas coordinates
	av = permute(av_accf(end:-1:1,end:-1:1,end:-1:1), [3 1 2]);
	tv = permute(tv_accf(end:-1:1,end:-1:1,end:-1:1), [3 1 2]);
	vecBregmaInv = size(av_accf) - vecBregma_accf;
	vecBregma = vecBregmaInv([3 1 2]);
	matBrainMeshRev = matBrainMesh_accf(:,[2 1 3]);
	matBrainMesh = bsxfun(@minus,size(av),matBrainMeshRev);
	vecVoxelSize = vecVoxelSize_accf([3 1 2]);
	
	%% compile outputs
	sAtlas = struct;
	sAtlas.av = av;
	sAtlas.tv = tv;
	sAtlas.st = st;
	sAtlas.Bregma = vecBregma;
	sAtlas.VoxelSize = vecVoxelSize;
	sAtlas.BrainMesh = matBrainMesh; %transform to coordinates in microns?
	sAtlas.ColorMap = cmap;
	sAtlas.Type = 'Allen-CCF-Mouse';
end