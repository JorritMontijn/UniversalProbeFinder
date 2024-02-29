function PH_UndoDiscardCategs(hObject,eventdata,varargin)
	%PH_UndoDiscardCategs Summary of this function goes here
	%   PH_UndoDiscardCategs(hObject,varargin)
	
	%get data
	sGUI = guidata(hObject);
	sGUI = guidata(sGUI.handles.hMain);
	%get current category and set all others to ShowMaskPF=false
	if isfield(sGUI,'sClusters') && isfield(sGUI.sClusters,'Clust')
		%get active categ
		sClusters = sGUI.sClusters;
		%set show mask to all true
		try
			for i=1:numel(sClusters.Clust)
				sClusters.Clust(i).ShowMaskPF = true;
			end
		catch
		end
		
		%update data
		sGUI.sClusters = sClusters;
		guidata(sGUI.handles.hMain,sGUI);
		
		%redraw
		PH_PlotProbeEphys(sGUI.handles.hMain,eventdata);
	end
end

