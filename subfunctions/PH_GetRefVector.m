function matRefVector = PH_GetRefVector(matCartPoints)
	%PH_GetRefVector Summary of this function goes here
	%   Detailed explanation goes here
	
	r0 = mean(matCartPoints,1);
	xyz = bsxfun(@minus,matCartPoints,r0);
	[~,~,V] = svd(xyz,0);
	histology_probe_direction = V(:,1);
	
	probe_eval_points = [-1000,1000];
	probe_line_endpoints = bsxfun(@plus,bsxfun(@times,probe_eval_points',histology_probe_direction'),r0);
	
	%always pointing down
	if probe_line_endpoints(1,3) > probe_line_endpoints(2,3)
		probe_line_endpoints = probe_line_endpoints([2 1],:);
	end
	
	% Place the probe on the histology best-fit axis
	probe_ref_top = probe_line_endpoints(1,:);
	probe_ref_bottom = probe_line_endpoints(2,:);
	matRefVector = [probe_ref_top;probe_ref_bottom];
	
end

