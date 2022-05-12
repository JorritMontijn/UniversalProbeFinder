function [dblMedian,intMedianIndex] = median(varargin)
	%median Overloaded median function with 2nd value index output
	%   [dblMedian,intMedianIndex] = median(x,dim,flag)
	dblMedian = med(varargin{:});
	if nargout > 1
		[dummy,intMedianIndex] = min(abs(varargin{1} - dblMedian));
	end
end
function y = med(x,dim,flag)
	if isstring(x)
		error(message('MATLAB:median:wrongInput'));
	end
	
	if isempty(x) % Not checking nanflag in this case
		if nargin == 1 || (nargin >= 2 && (ischar(dim) || isstring(dim)))
			
			% The output size for [] is a special case when DIM is not given.
			if isequal(x,[])
				if isinteger(x) || islogical(x)
					y = zeros('like',x);
				else
					y = nan('like',x);
				end
				return;
			end
			
			if nargin == 2 && isAllFlag(dim)
				dim = 1:ndims(x);
			else
				% Determine first nonsingleton dimension
				dim = find(size(x)~=1,1);
			end
			
		end
		
		s = size(x);
		if max(dim)>length(s)
			s(end+1:max(dim)) = 1;
		end
		s(dim) = 1;                  % Set size to 1 along dimensions
		if isinteger(x) || islogical(x)
			y = zeros(s,'like',x);
		else
			y = nan(s,'like',x);
		end
		
		return;
	end
	
	omitnan = false;
	dimSet = true;
	if nargin == 1
		dimSet = false;
	elseif nargin == 2
		dimSet = (~ischar(dim) && ~(isstring(dim) && isscalar(dim))) || isAllFlag(dim);
		if ~dimSet
			flag = dim;
		end
	end
	
	sz = size(x);
	if dimSet
		if isnumeric(dim) || islogical(dim)
			if isempty(dim) || ~isvector(dim)
				error(message('MATLAB:getdimarg:invalidDim'));
			else
				if ~isreal(dim) || any(floor(dim) ~= ceil(dim)) || any(dim < 1) || any(~isfinite(dim))
					error(message('MATLAB:getdimarg:invalidDim'));
				end
				if ~isscalar(dim) && ~all(diff(sort(dim)))
					error(message('MATLAB:getdimarg:vecDimsMustBeUniquePositiveIntegers'));
				end
			end
			dim = reshape(dim, 1, []);
		elseif isAllFlag(dim)
			x = x(:);
			dim = 1;
			sz = size(x);
		else
			error(message('MATLAB:getdimarg:invalidDim'));
		end
		
		if all(dim > numel(sz))
			y = x;
			return;
		end
	end
	
	if nargin == 2 && dimSet == false || nargin == 3
		if isstring(flag)
			flag = char(flag);
		end
		len = max(length(flag), 1);
		
		if ~isrow(flag)
			if nargin == 2
				error(message('MATLAB:median:unknownOption'));
			else
				error(message('MATLAB:median:unknownFlag'));
			end
		end
		
		s = strncmpi(flag, {'omitnan', 'includenan'}, len);
		
		if ~any(s)
			if nargin == 2
				error(message('MATLAB:median:unknownOption'));
			else
				error(message('MATLAB:median:unknownFlag'));
			end
		end
		
		omitnan = s(1);
	end
	
	if isvector(x) && (~dimSet || (isscalar(dim) && sz(dim) > 1))
		% If input is a vector, calculate single value of output.
		if isreal(x) && ~issparse(x) && isnumeric(x) && ~isobject(x) % Utilize internal fast median
			if isrow(x)
				x = x.';
			end
			y = matlab.internal.math.columnmedian(x,omitnan);
		else
			x = sort(x);
			nCompare = length(x);
			if isnan(x(nCompare))        % Check last index for NaN
				if omitnan
					nCompare = find(~isnan(x), 1, 'last');
					if isempty(nCompare)
						y = nan('like',x([])); % using x([]) so that y is always real
						return;
					end
				else
					y = nan('like',x([])); % using x([]) so that y is always real
					return;
				end
			end
			half = floor(nCompare/2);
			y = x(half+1);
			if 2*half == nCompare        % Average if even number of elements
				y = meanof(x(half),y);
			end
		end
	else
		if ~dimSet              % Determine first nonsingleton dimension
			dim = find(sz ~= 1,1);
		else
			dim = min(dim, ndims(x)+1);
			sz(end+1:max(dim)) = 1;
		end
		
		sizey = sz;
		sizey(dim) = 1;
		
		% Reshape and permute x into a matrix of size prod(sz(dim)) x (numel(x) / prod(sz(dim)))
		tf = false(size(sizey));
		tf(dim) = true;
		perm = [find(tf), find(~tf)];
		x = permute(x, perm);
		x = reshape(x, [prod(sz(dim)), prod(sizey)]);
		
		if isreal(x) && ~issparse(x) && isnumeric(x) && ~isobject(x) % Utilize internal fast median
			y = matlab.internal.math.columnmedian(x,omitnan);
		else
			% Sort along columns
			x = sort(x, 1);
			if ~omitnan || all(~isnan(x(end, :)))
				% Use vectorized method with column indexing.  Reshape at end to
				% appropriate dimension.
				nCompare = size(x,1);          % Number of elements used to generate a median
				half = floor(nCompare/2);    % Midway point, used for median calculation
				
				y = x(half+1,:);
				if 2*half == nCompare
					y = meanof(x(half,:),y);
				end
				
				if isfloat(x)
					y(isnan(x(nCompare,:))) = NaN;   % Check last index for NaN
				end
			else
				% Get median of the non-NaN values in each column.
				y = nan(1, size(x, 2), 'like', x([])); % using x([]) so that y is always real
				
				% Number of non-NaN values in each column
				n = sum(~isnan(x), 1);
				
				% Deal with all columns that have an odd number of valid values
				oddCols = find((n>0) & rem(n,2)==1);
				oddIdxs = sub2ind(size(x), (n(oddCols)+1)/2, oddCols);
				y(oddCols) = x(oddIdxs);
				
				% Deal with all columns that have an even number of valid values
				evenCols = find((n>0) & rem(n,2)==0);
				evenIdxs = sub2ind(size(x), n(evenCols)/2, evenCols);
				y(evenCols) = meanof( x(evenIdxs), x(evenIdxs+1) );
			end
		end
		% Reshape and permute back
		y = reshape(y, sizey);
	end
end
%============================

function c = meanof(a,b)
	% MEANOF the mean of A and B with B > A
	%    MEANOF calculates the mean of A and B. It uses different formula
	%    in order to avoid overflow in floating point arithmetic.
	if islogical(a)
		c = a | b;
	else
		if isinteger(a)
			% Swap integers such that ABS(B) > ABS(A), for correct rounding
			ind = b < 0;
			temp = a(ind);
			a(ind) = b(ind);
			b(ind) = temp;
		end
		c = a + (b-a)/2;
		k = (sign(a) ~= sign(b)) | isinf(a) | isinf(b);
		c(k) = (a(k)+b(k))/2;
	end
end
%==========================
function tf = isAllFlag(dim)
	tf = ((ischar(dim) && isrow(dim)) || ...
		(isstring(dim) && isscalar(dim) && (strlength(dim) > 0))) && ...
		strncmpi(dim,'all',max(strlength(dim), 1));
end
