function vecLocationBrainIntersection = PH_GetBrainIntersection(probe_vector_cart,av)
	
	%calculate ref vector from probe vector
	r0 = mean(probe_vector_cart,1);
	xyz = bsxfun(@minus,probe_vector_cart,r0);
	[~,~,V] = svd(xyz,0);
	histology_probe_direction = V(:,1);
	
	probe_eval_points = [-1000 1000];
	probe_end_relative = bsxfun(@times,probe_eval_points,histology_probe_direction);
	probe_line_endpoints = bsxfun(@plus,probe_end_relative',r0);
	
	% Place the probe on the histology best-fit axis
	probe_ref_top = probe_line_endpoints(1,[1,2,3]);
	probe_ref_bottom = probe_line_endpoints(2,[1,2,3]);
	probe_ref_vector = [probe_ref_top;probe_ref_bottom];
	
	%get locations along probe
	trajectory_n_coords = sqrt(sum(diff(probe_ref_vector,[],1).^2));
	[trajectory_xcoords,trajectory_ycoords,trajectory_zcoords] = deal( ...
		linspace(probe_ref_vector(1,1),probe_ref_vector(2,1),trajectory_n_coords), ...
		linspace(probe_ref_vector(1,2),probe_ref_vector(2,2),trajectory_n_coords), ...
		linspace(probe_ref_vector(1,3),probe_ref_vector(2,3),trajectory_n_coords));
	%limit to atlas size
	vecSizeAtlas = size(av);
	trajectory_xcoords(trajectory_xcoords<1) = 1;
	trajectory_ycoords(trajectory_ycoords<1) = 1;
	trajectory_zcoords(trajectory_zcoords<1) = 1;
	trajectory_xcoords(trajectory_xcoords>vecSizeAtlas(1)) = vecSizeAtlas(1);
	trajectory_ycoords(trajectory_ycoords>vecSizeAtlas(2)) = vecSizeAtlas(2);
	trajectory_zcoords(trajectory_zcoords>vecSizeAtlas(3)) = vecSizeAtlas(3);
	
	%get areas
	trajectory_area_ids = single(av(sub2ind(vecSizeAtlas,round(trajectory_xcoords),round(trajectory_ycoords),round(trajectory_zcoords))));
	if diff(probe_vector_cart(:,1)) <= 0
		trajectory_brain_idx = find(trajectory_area_ids > 1,1,'last');
	else
		trajectory_brain_idx = find(trajectory_area_ids > 1,1,'first');
	end
	vecLocationBrainIntersection = ...
		[trajectory_xcoords(trajectory_brain_idx),trajectory_ycoords(trajectory_brain_idx),trajectory_zcoords(trajectory_brain_idx)]';
end