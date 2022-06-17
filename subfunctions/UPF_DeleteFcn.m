function UPF_DeleteFcn(hObject,varargin)
	
	global sUPF_ChooseGui;
	sUPF_ChooseGui = [];
	
	try
		delete(hObject);
	catch
	end
end