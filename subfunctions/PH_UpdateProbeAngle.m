function gui_data = PH_UpdateProbeAngle(hMain,angle_change)
	error update this bit
	% Get guidata
	gui_data = guidata(hMain);
	%angle_change = [-10 0]
	
	%get location
	probe_vector_ccf = PH_GetProbeVector(hMain);
	
	% get old angle
	vecRefVector = probe_vector_ccf(1,:) - probe_vector_ccf(2,:);
	[azimuth,elevation,r] = cart2sph(vecRefVector(1),vecRefVector(2),vecRefVector(3));%ML, AP,depth (DV)
	%elevation=ML angle (z/y), azimuth=AP angle
	%x=ML,
	%y=DV (depth)
	%z=AP
	
	%calculate new angle
	dblInverterML = double(vecRefVector(2) < 0)*2-1;
	dblAngleAP = rad2deg(azimuth) + 90 + angle_change(1);
	dblAngleML = rad2deg(elevation) + 0 + angle_change(2)*dblInverterML;
	dblProbeL = r;
	
	%get new vector
	[x,y,z] = sph2cart(deg2rad(dblAngleAP-90),deg2rad(dblAngleML),dblProbeL);
	vecNewRefVector = [x y z];
	new_probe_vector_ccf = [vecNewRefVector + probe_vector_ccf(2,:); probe_vector_ccf(2,:)];
	
	%check
	vecRefVector2 = new_probe_vector_ccf(1,:) - new_probe_vector_ccf(2,:);
	[azimuth,elevation,r] = cart2sph(vecRefVector2(1),vecRefVector2(2),vecRefVector2(3));%ML, AP,depth (DV)
	dblAngleAP2 = rad2deg(azimuth) + 90;
	dblAngleML2 = rad2deg(elevation);
	
	%update angle
	gui_data.probe_angle = mod([dblAngleAP2 dblAngleML2]+180,360)-180;
	guidata(hMain,gui_data);
	
	%update probe location
	PH_SetProbeLocation(hMain,new_probe_vector_ccf);
end

