function strFullpath = fullpath(varargin)
	%fullpath Like fullfile but also works for relative network paths
	%   strFullpath = fullpath(varargin)
	
	strLead = varargin{1};
	if ~isempty(strLead) && strLead(1) ~= 0 && ~strcmp(strLead(end),filesep),strLead(end+1)=filesep;end
	sWarn = warning('off','MATLAB:deblank:NonStringInput');
	strFullpath = strcat(strLead,fullfile(varargin{2:end}));
	warning(sWarn);
end

