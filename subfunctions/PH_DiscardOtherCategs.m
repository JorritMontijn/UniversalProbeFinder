function PH_DiscardOtherCategs(hObject,eventdata,varargin)
	%PH_DiscardOtherCategs Summary of this function goes here
	%   PH_DiscardOtherCategs(hObject,eventdata,varargin)
	
	%get data
	sGUI = guidata(hObject);
	sGUI = guidata(sGUI.handles.hMain);
	%get current category and set all others to ShowMaskPF=false
	if isfield(sGUI,'sClusters') && isfield(sGUI.sClusters,'Clust')
		
		%get active categ
		sClusters = sGUI.sClusters;
		strShowCateg = sGUI.handles.ptrButtonShowCateg.String{sGUI.handles.ptrButtonShowCateg.Value};
		if strcmp(strShowCateg,'all')
			return %cannot remove all clusters
		else
			%% show cluster data
			strCategProp = sGUI.handles.ptrButtonCategProp.String{sGUI.handles.ptrButtonCategProp.Value};
			strCategField = PH_GetClusterField(sClusters.Clust,strCategProp);
			vecDepth = [sClusters.Clust.Depth];
			if isfield(sClusters.Clust,strCategField)
				varColorProperty = {sClusters.Clust.(strCategField)};
			else
				varColorProperty = ones(size(vecDepth));
			end
			
			%transform color property to numeric
			indIsnumeric = cellfun(@(x) isnumeric(x) | islogical(x),varColorProperty);
			if all(indIsnumeric)
				boolColorIsNumeric = true;
				vecColorProperty = cell2vec(varColorProperty);
			else
				boolColorIsNumeric = false;
				varColorProperty(indIsnumeric) = cellfun(@num2str,varColorProperty(indIsnumeric),'uniformoutput',false);
				[vecColorProperty,cellCategories] = val2idx(varColorProperty);
			end
			
			%set mask
			if strcmp(strShowCateg,'all')
				indHideCells = true(size(vecDepth));
			elseif boolColorIsNumeric
				indHideCells = vecColorProperty==str2double(strShowCateg);
			else
				indHideCells = strcmpi(varColorProperty,strShowCateg);
			end
			if isempty(indHideCells)
				indHideCells = true(size(vecDepth));
			end
			indShowCells = ~indHideCells;
			
			%get current mask
			for i=1:numel(sClusters.Clust)
				%set show masks
				if ~isfield(sClusters.Clust(i),'ShowMaskPF') || isempty(sClusters.Clust(i).ShowMaskPF)
					sClusters.Clust(i).ShowMaskPF = true;
				end
				boolOldMask = sClusters.Clust(i).ShowMaskPF;
				boolNewMask = indShowCells(i);
				sClusters.Clust(i).ShowMaskPF = boolOldMask & boolNewMask;
			end
			
			%update data
			sGUI.sClusters = sClusters;
			guidata(sGUI.handles.hMain,sGUI);
			
			%redraw
			PH_PlotProbeEphys(sGUI.handles.hMain,eventdata);
		end
	else
		return; %do nothing
	end
	
end

