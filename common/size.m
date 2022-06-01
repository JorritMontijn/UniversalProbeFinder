function varargout = size(A,varargin)
	if nargin == 1
		vecDimsOut = builtin('size',A);
	elseif nargin == 2 && numel(varargin{1}) == 1
		vecDimsOut = builtin('size',A,varargin{1});
	else
		if nargin == 2
			% vector
			vecDims = varargin{1};
		else
			%cell array
			vecDims = cellfun(@(x) x{1},varargin);
		end
		
		vecDimsOut = nan(1,numel(vecDims));
		for intReturnDim=1:numel(vecDims)
			intDim = vecDims(intReturnDim);
			vecDimsOut(intReturnDim) = builtin('size',A,intDim);
		end
	end
	
	%build output
	if nargout == 1
		varargout{1} = vecDimsOut;
	else
		varargout = cell(1,nargout);
		for k = 1:nargout
			varargout{k} = vecDimsOut(k);
		end
	end
end