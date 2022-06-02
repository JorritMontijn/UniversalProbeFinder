function b = modx(a,m)
	%modx Modulo, where mod(n*m,m) gives m instead of 0
	%   See mod()
	b = mod(a,m);
	b(b==0)=m;
end

