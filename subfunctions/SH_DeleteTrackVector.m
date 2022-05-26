function SH_DeleteTrackVector(hObject,eventdata,hLine)
	%get data
	sGUI = guidata(hObject);
	
	%find object
	for intClick=1:numel(sGUI.sSliceData.Slice(sGUI.intCurrIm).TrackClick)
		if sGUI.sSliceData.Slice(sGUI.intCurrIm).TrackClick(intClick).hLine == hLine
			delete(sGUI.sSliceData.Slice(sGUI.intCurrIm).TrackClick(intClick).hLine);
			delete(sGUI.sSliceData.Slice(sGUI.intCurrIm).TrackClick(intClick).hScatter);
			sGUI.sSliceData.Slice(sGUI.intCurrIm).TrackClick(intClick) = [];
			break;
		end
	end
	
	%update data
	guidata(hObject,sGUI);
end