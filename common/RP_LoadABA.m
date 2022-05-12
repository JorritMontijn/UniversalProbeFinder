function [tv,av,st] = RP_LoadABA(strAllenCCFPath)
	try
		hMsg = msgbox('Loading Allen Brain Atlas, please wait...','Loading ABA');
		tv = readNPY(fullpath(strAllenCCFPath,'template_volume_10um.npy')); % grey-scale "background signal intensity"
		av = readNPY(fullpath(strAllenCCFPath,'annotation_volume_10um_by_index.npy')); % the number at each pixel labels the area, see note below
		st = PH_loadStructureTree(fullpath(strAllenCCFPath,'structure_tree_safe_2017.csv')); % a table of what all the labels mean
		close(hMsg);
	catch ME
		close(hMsg);
		tv=[];
		av=[];
		st=[];
		strStack = sprintf('Error in %s (Line %d)',ME.stack(1).name,ME.stack(1).line);
		errordlg(sprintf('%s\n%s',ME.message,strStack),'AllenCCF load error')
		return;
	end
end