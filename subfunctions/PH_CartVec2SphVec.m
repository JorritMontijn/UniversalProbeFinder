function vecSphereVector = PH_CartVec2SphVec(matCartVector)
	%PH_CartVec2SphVec Transforms 2-point cartesian vector to 1-point spherical vector
	%   vecSphereVector = PH_CartVec2SphVec(matCartVector)
	%
	%matCartVector = [x1 y1 z1; x2 y2 z2], where [x1 y1 z1] is probe tip
	%vecSphereVector = [x1 y1 z1 deg-ML deg-AP length]
	
	%get dx,dy,dz
	vecRefVector = matCartVector(2,:) - matCartVector(1,:);
	%calculate angle
	[azimuth,elevation,r] = cart2sph(vecRefVector(3),vecRefVector(2),vecRefVector(1));%ML, AP,depth (DV)
	
	%extract angles in degrees
	dblAngleAP = rad2deg(azimuth);
	dblAngleML = rad2deg(elevation);
	if dblAngleAP < -90 && dblAngleML > 0
		dblAngleAP = dblAngleAP + 180;
		dblAngleML = 180 -dblAngleML;
	elseif dblAngleAP < -90 && dblAngleML < 0
		dblAngleAP = dblAngleAP + 180;
		dblAngleML = -dblAngleML - 180;
	elseif dblAngleAP > 90 && dblAngleML > 0
		dblAngleAP = dblAngleAP - 180;
		dblAngleML = -dblAngleML + 180;
	elseif dblAngleAP > 90 && dblAngleML < 0
		dblAngleAP = dblAngleAP - 180;
		dblAngleML = -dblAngleML - 180;
	end
	vecSphereVector = [matCartVector(1,:) dblAngleML -dblAngleAP r];
end

