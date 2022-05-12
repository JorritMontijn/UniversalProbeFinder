function [strZetaFile,strZetaPath] = PH_SaveZeta(vecDepth,vecZetaP,strPath)
	%pre-allocate
	if ~exist('strZetaPath','var') || isempty(strPath) || strPath(1) == 0
		strPath = cd();
	end
	
	%ask where to save
	strOldPath = cd(strPath);
	[strZetaFile,strZetaPath] = uiputfile('zeta_responsiveness.mat','Save ZETA responsiveness file');
	cd(strOldPath);
	if isempty(strZetaFile) || strZetaFile(1) == 0,return;end
	
	%save
	save(fullpath(strZetaPath,strZetaFile),'vecDepth','vecZetaP')
end