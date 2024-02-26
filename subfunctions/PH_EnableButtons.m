function PH_EnableButtons(hObject,varargin)
	%PH_EnableButtons Summary of this function goes here
	%   PH_EnableButtons(hObject,varargin)
	
	%get data
	sGUI = guidata(hObject);
	sGUI = guidata(sGUI.handles.hMain);
	
	%enable buttons
	set(sGUI.handles.ptrButtonLoadZeta,'Enable','on');
	set(sGUI.handles.ptrButtonLoadTsv,'Enable','on');
	set(sGUI.handles.ptrButtonPlotProp,'Enable','on');
	set(sGUI.handles.ptrButtonCategProp,'Enable','on');
	set(sGUI.handles.ptrButtonShowCateg,'Enable','on');
	set(sGUI.handles.ptrButtonExportEphys,'Enable','on');
	set(sGUI.handles.ptrButtonDiscardOtherCateg,'Enable','on');
	set(sGUI.handles.ptrButtonUndoDiscard,'Enable','on');
	
end

