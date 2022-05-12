function vecBregmaVector = PH_SphVec2BregmaVec(vecSphereVector,vecLocBrainIntersect,sAtlas)
	%PH_SphVec2BregmaVec Calculates bregma-centered Paxinos coordinates of brain entry, probe depth
	%						in microns and ML and AP angles in degrees
	%   vecBregmaVector = PH_SphVec2BregmaVec(vecSphereVector,vecLocBrainIntersect,sAtlas)
	%
	%In Paxinos coordinates, coordinates relative to bregma (bregma - X) mean that -AP is posterior,
	%+AP is anterior, -DV is dorsal, +DV is ventral
	%
	%bregma vector is 6-element vector: [ML AP ML-deg AP-deg depth length], with ML and AP being brain
	%entry coordinates relative to bregma in microns, ML-deg and AP-deg the probe angles in degrees,
	%and depth is the depth in microns of the tip of the probe from the brain entry point. Note that
	%the DV coordinates of the tip in the bregma-vector system are therefore inferred from the other
	%parameters. The sixth element is the length of the probe in microns.
	
	%brain entry
	vecBregmaVector = nan(1,6);
	vecBregmaVector(1:2) = (sAtlas.Bregma(1:2) - flat(vecLocBrainIntersect(1:2))') .* sAtlas.VoxelSize(1:2);
	vecBregmaVector(2) = -vecBregmaVector(2);
	%ML angle
	if mod(vecSphereVector(4),360) > 180
		vecBregmaVector(3) = mod(vecSphereVector(4),360) - 360;
	else
		vecBregmaVector(3) = mod(vecSphereVector(4),360);
	end
	%AP angle
	if mod(vecSphereVector(5),360) > 180
		vecBregmaVector(4) = mod(vecSphereVector(5),360) - 360;
	else
		vecBregmaVector(4) = mod(vecSphereVector(5),360);
	end
	
	%depth
	vecD = vecLocBrainIntersect(:)' - vecSphereVector(1:3);
	[azimuth,elevation,dblDepth] = cart2sph(vecD(3),vecD(2),vecD(1));%ML, AP,depth (DV)
	vecBregmaVector(5) = dblDepth * sAtlas.VoxelSize(end); %only valid if voxels are isometric
	vecBregmaVector(6) = vecSphereVector(6) * sAtlas.VoxelSize(end); %only valid if voxels are isometric
end

