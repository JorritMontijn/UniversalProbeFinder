function boolVersionIsGood = PF_AssertVersion(varargin)
	%PF_AssertVersion Summary of this function goes here
	%   boolVersionIsGood = PF_AssertVersion(varargin)
	if str2double(getFlankedBy(version(),'(R','b)')) < 2019
		boolVersionIsGood = false;
		errordlg('Your MATLAB version is not supported. Please use R2019b through R2022a (or possibly more recent).',...
			'Unsupported Version');
	else
		boolVersionIsGood = true;
	end
end

