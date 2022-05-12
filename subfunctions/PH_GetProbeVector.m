function probe_vector_cart = PH_GetProbeVector(hMain)
	
	% Get guidata
	sGUI = guidata(hMain);
	
	%get probe location
	probe_vector_cart = nan(2,3);
	probe_vector_cart(:,1) = sGUI.handles.probe_vector_cart.XData;
	probe_vector_cart(:,2) = sGUI.handles.probe_vector_cart.YData;
	probe_vector_cart(:,3) = sGUI.handles.probe_vector_cart.ZData;
end