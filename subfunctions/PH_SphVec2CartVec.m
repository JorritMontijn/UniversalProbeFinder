function matCartVector = PH_SphVec2CartVec(vecSphereVector)
	%PH_SphVec2CartVec Transforms 1-point spherical vector to 2-point cartesian vector
	%   matCartVector = PH_SphVec2CartVec(vecSphereVector)
	%
	%vecSphereVector = [x1 y1 z1 deg-ML deg-AP length]
	%matCartVector = [x1 y1 z1; x2 y2 z2]
	%
	%Azimuth is around ap axis (so ml offset, 0 is from top, -90 is from left -180/+180 is from
	%bottom), elevation is forward/backward (ap offset, 0 is straight, 90 horizontal forward, -90 is
	%horizontal backward)  
	
	%get dx,dy,dz
	[dz,dy,dx] = sph2cart(deg2rad(-vecSphereVector(5)),deg2rad(vecSphereVector(4)),vecSphereVector(6));
	
	%add dx,dy,dz
	matCartVector = [vecSphereVector(1:3);(vecSphereVector(1:3) + [dx,dy,dz])];
end

