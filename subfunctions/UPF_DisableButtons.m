function UPF_DisableButtons(sUPF_ChooseGui)
	sUPF_ChooseGui.handles.ptrButtonPrepper.Enable = 'off';
	sUPF_ChooseGui.handles.ptrButtonFinder.Enable = 'off';
	sUPF_ChooseGui.handles.ptrButtonProber.Enable = 'off';
	sUPF_ChooseGui.handles.ptrButtonSetter.Enable = 'off';
	drawnow;
end