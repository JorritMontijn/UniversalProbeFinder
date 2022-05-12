function PH_UpdateSlice(hMain,varargin)
	% Get guidata
	sGUI = guidata(hMain);
	
	% Only update the slice if it's visible
	if strcmp(sGUI.handles.slice_plot(1).Visible,'on')
		
		% Get current position of camera
		curr_campos = campos;
		
		% Get probe vector
		probe_vector_cart = PH_GetProbeVector(hMain);
		probe_tip = probe_vector_cart(1,:);
		probe_base = probe_vector_cart(2,:);
		probe_direction = probe_tip - probe_base;
		
		% Get probe-camera vector
		probe_camera_vector = probe_tip - curr_campos;
		
		% Get the vector to plot the plane in (along with probe vector)
		plot_vector = cross(probe_camera_vector,probe_direction);
		
		% Get the normal vector of the plane
		normal_vector = cross(plot_vector,probe_direction);
		
		% Get the plane offset through the probe
		plane_offset = -(normal_vector*probe_tip');
		
		% Define a plane of points to index
		% (the plane grid is defined based on the which cardinal plan is most
		% orthogonal to the plotted plane. this is janky but it works)
		intSliceDownsample = 3;%3
		[~,intOrthPlane] = max(abs(normal_vector./norm(normal_vector)));
		
		if intOrthPlane == 1
			[plane_y,plane_z] = meshgrid(1:intSliceDownsample:size(sGUI.sAtlas.av,2),1:intSliceDownsample:size(sGUI.sAtlas.av,3));
			plane_x = ...
				(normal_vector(2)*plane_y+normal_vector(3)*plane_z + plane_offset)/ ...
				-normal_vector(1);
			
		elseif intOrthPlane == 2
			[plane_x,plane_z] = meshgrid(1:intSliceDownsample:size(sGUI.sAtlas.av,1),1:intSliceDownsample:size(sGUI.sAtlas.av,3));
			plane_y = ...
				(normal_vector(1)*plane_x+normal_vector(3)*plane_z + plane_offset)/ ...
				-normal_vector(2);
			
		elseif intOrthPlane == 3
			[plane_x,plane_y] = meshgrid(1:intSliceDownsample:size(sGUI.sAtlas.av,1),1:intSliceDownsample:size(sGUI.sAtlas.av,2));
			plane_z = ...
				(normal_vector(1)*plane_x+normal_vector(2)*plane_y + plane_offset)/ ...
				-normal_vector(3);
			
		end
		
		% Get the coordiates on the plane
		x_idx = round(plane_x);
		y_idx = round(plane_y);
		z_idx = round(plane_z);
		
		% Find plane coordinates in bounds with the volume
		use_xd = x_idx > 0 & x_idx < size(sGUI.sAtlas.av,1);
		use_yd = y_idx > 0 & y_idx < size(sGUI.sAtlas.av,2);
		use_zd = z_idx > 0 & z_idx < size(sGUI.sAtlas.av,3);
		use_idx = use_xd & use_yd & use_zd;
		
		curr_slice_idx = sub2ind(size(sGUI.sAtlas.av),x_idx(use_idx),y_idx(use_idx),z_idx(use_idx));
		
		% Find plane coordinates that contain brain
		curr_slice_isbrain = false(size(use_idx));
		curr_slice_isbrain(use_idx) = sGUI.sAtlas.av(curr_slice_idx) > 1;
		
		% Index coordinates in bounds + with brain
		grab_pix_idx = sub2ind(size(sGUI.sAtlas.av),x_idx(curr_slice_isbrain),y_idx(curr_slice_isbrain),z_idx(curr_slice_isbrain));
		
		% Grab pixels from (selected) volume
		curr_slice = nan(size(use_idx));
		if strcmp(sGUI.handles.slice_volume,'tv')
			curr_slice(curr_slice_isbrain) = sGUI.sAtlas.tv(grab_pix_idx);
			colormap(sGUI.handles.axes_atlas,'gray');
			caxis([0,255]);
		elseif strcmp(sGUI.handles.slice_volume, 'av')
			curr_slice(curr_slice_isbrain) = sGUI.sAtlas.av(grab_pix_idx);
			colormap(sGUI.handles.axes_atlas,sGUI.cmap);
			caxis([1,size(sGUI.cmap,1)]);
		end
		
		% Update the slice display
		set(sGUI.handles.slice_plot,'XData',plane_x,'YData',plane_y,'ZData',plane_z,'CData',curr_slice);
		
		% Upload gui_data
		guidata(hMain, sGUI);
		
	end
	
end