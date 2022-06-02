function SH_HeaderClick(hObject,eventdata,intIm)
	
	sGUI = guidata(hObject);
	if intIm < 1 || intIm > numel(sGUI.sSliceData.Slice) || sGUI.intCurrIm == intIm
		%ignore
	else
		sGUI.intCurrIm = intIm;
		%update data
		guidata(sGUI.handles.hMain, sGUI);
		%plot images
		if strcmp(sGUI.name,'SliceFinder')
			SF_PlotIms(sGUI.handles.hMain);
		else
			SH_PlotPrepIms(sGUI.handles.hMain);
		end
	end
end