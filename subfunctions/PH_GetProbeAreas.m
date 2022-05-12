function [probe_area_ids,probe_area_boundaries,probe_area_centers] = PH_GetProbeAreas(probe_vector_cart,av)
	%PH_GetProbeAreas Retrieve areas along probe
	%   [probe_area_ids,probe_area_boundaries,probe_area_centers] = PH_GetProbeAreas(probe_vector_cart,av)
	
	% get coords
	probe_n_coords = sqrt(sum(diff(probe_vector_cart,[],1).^2));
	[probe_xcoords,probe_ycoords,probe_zcoords] = deal( ...
		linspace(probe_vector_cart(2,1),probe_vector_cart(1,1),probe_n_coords), ...
		linspace(probe_vector_cart(2,2),probe_vector_cart(1,2),probe_n_coords), ...
		linspace(probe_vector_cart(2,3),probe_vector_cart(1,3),probe_n_coords));
	
	%limit to atlas size
	vecSizeAtlas = size(av);
	probe_xcoords(probe_xcoords<1) = 1;
	probe_ycoords(probe_ycoords<1) = 1;
	probe_zcoords(probe_zcoords<1) = 1;
	probe_xcoords(probe_xcoords>vecSizeAtlas(1)) = vecSizeAtlas(1);
	probe_ycoords(probe_ycoords>vecSizeAtlas(2)) = vecSizeAtlas(2);
	probe_zcoords(probe_zcoords>vecSizeAtlas(3)) = vecSizeAtlas(3);
	
	%get areas
	%vecIDs = sGUI.sAtlas.av(sub2ind(vecSizeAtlas,round(probe_xcoords),round(probe_ycoords),round(probe_zcoords)));
	%matEntries = repmat((1:numel(sGUI.sAtlas.st.id))',[1 numel(vecIDs)]);
	%probe_area_ids = matEntries(vecIDs(:)' == sGUI.sAtlas.st.id(:))';
	probe_area_ids = single(av(sub2ind(vecSizeAtlas,round(probe_xcoords),round(probe_ycoords),round(probe_zcoords))));
	vecBoundaries = [find(~isnan(probe_area_ids),1,'first') find(diff(probe_area_ids) ~= 0) find(~isnan(probe_area_ids),1,'last')];
	probe_area_boundaries = intersect(unique(vecBoundaries),find(~isnan(probe_area_ids))); %remove nans
	probe_area_centers = probe_area_boundaries(1:end-1) + diff(probe_area_boundaries)/2;
end