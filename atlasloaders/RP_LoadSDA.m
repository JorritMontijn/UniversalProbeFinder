function [tv,av,st] = RP_LoadSDA(strSpragueDawleyAtlasPath)
	%Sprague Dawley rat brain, downloadable at https://www.nitrc.org/projects/whs-sd-atlas
	%F:\Data\Ratlas
	%imagesc(squeeze(av(250,:,:))) = sagital slice (dorsal is right (x-high); posterior is down (y-low))
	%imagesc(squeeze(av(:,500,:))) = coronal slice (dorsal is right (x-high); y=M/L, midline is 244)
	%imagesc(squeeze(av(:,:,250))) = axial slice (anterior is right (x-high); y=M/L, midline is 244)
	%av = [ML AP DV]; 512 x 1024 x 512
	%table variables:
	% #    IDX:   Zero-based index
	% #    -R-:   Red color component (0..255)
	% #    -G-:   Green color component (0..255)
	% #    -B-:   Blue color component (0..255)
	% #    -A-:   Label transparency (0.00 .. 1.00)
	% #    VIS:   Label visibility (0 or 1)
	% #    IDX:   Label mesh visibility (0 or 1)
	% #  LABEL:   Label description
	
	try
		hMsg = msgbox('Loading Sprague Dawley rat brain Atlas, please wait...','Loading SDA');
		tv = niftiread(fullpath(strSpragueDawleyAtlasPath,'WHS_SD_rat_T2star_v1.01.nii')); %has lots of signal outside brain
		av = niftiread(fullpath(strSpragueDawleyAtlasPath,'WHS_SD_rat_atlas_v4.nii')); %annotated volume
		st = readtable(fullpath(strSpragueDawleyAtlasPath,'WHS_SD_rat_atlas_v4.label'),'filetype','text',...
			'Delimiter', '\t ', 'MultipleDelimsAsOne', true, 'HeaderLines', 14);
		close(hMsg);
	catch ME
		close(hMsg);
		tv=[];
		av=[];
		st=[];
		strStack = sprintf('Error in %s (Line %d)',ME.stack(1).name,ME.stack(1).line);
		errordlg(sprintf('%s\n%s',ME.message,strStack),'SD Atlas load error')
		return;
	end
end