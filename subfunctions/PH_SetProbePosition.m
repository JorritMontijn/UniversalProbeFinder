function PH_SetProbePosition(hMain)
	
	%get gui data
	sGUI = guidata(hMain);
	
	% Prompt for location
	prompt_text = { ...
		'ML position (\mum from bregma)', ...
		'AP position (\mum from bregma)', ...
		'ML angle (deg)', ....
		'AP angle (deg)',...
		'Depth of probe (\mum from brain entry)', ...
		'Length of probe (\mum)', ...
		};
	
	cellInput = inputdlg(prompt_text,'Set probe position in Paxinos coordinates',1);
	if isempty(cellInput)
		return
	end
	
	%transform input
	if isempty(cellInput{end})
		cellInput{end} = '3840';
	end
	if isempty(cellInput{end-1})
		cellInput{end-1} = cellInput{end};
	end
	cellInput(cellfun(@isempty,cellInput)) = {'0'};
	vecBregmaVector = cellfun(@str2num,cellInput)';
	vecSphereVector = PH_BregmaVec2SphVec(vecBregmaVector,sGUI.sAtlas);
	
	% set new location
	PH_UpdateProbeCoordinates(hMain,vecSphereVector)
end

