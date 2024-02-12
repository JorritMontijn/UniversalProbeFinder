function h=uitext(varargin)
	%Mimic a uicontrol call by creating an axes with centered text object.
	%
	% The input allows all syntax options that uicontrol allows.
	% The output is struct('ax',ax_handle,'txt',txt_handle).
	%
	% All parameters need to be supplied as Name,Value pairs. Below are the
	% parameters that are either ignored or redirected to the axes object. The rest
	% of the parameters are forwarded to the text object.
	%
	% ignored:
	%   Style
	%   VerticalAlignment
	%   HorizontalAlignment
	% redirected to axes:
	%   Position
	%   Units
	%   Parent
	%Deal with the uicontrol(parent,___) syntax.
	
	if mod(nargin,2)==1
		varargin=[{'Parent'},varargin];
	end
	Name=lower({varargin{1:2:end}});
	
	%retrieve alignment parameters
	strVertAlign = 'middle';
	dblTextX = 0.5;
	strHorzAlign = 'center';
	dblTextY = 0.5;
	vert = ismember(Name,'verticalalignment');
	if any(vert)
		strVertAlign = varargin{find(vert)*2};
		if strcmpi(strVertAlign,'top')
			dblTextY = 1;
		elseif strcmpi(strVertAlign,'bottom')
			dblTextY = 0;
		end
	end
	horz = ismember(Name,'horizontalalignment');
	if any(horz)
		strHorzAlign = varargin{find(horz)*2};
		if strcmpi(strHorzAlign,'left')
			dblTextX = 0;
		elseif strcmpi(strHorzAlign,'right')
			dblTextX = 1;
		end
	end
	
	%Ignore some parameters.
	L=ismember(Name,{'style','verticalalignment','horizontalalignment'});
	if any(L)
		L=find(L);
		L=sort([(L*2)-1 L*2]);
		varargin(L)=[];
	end
	%Redirect some parameters to the axes object.
	Name=lower({varargin{1:2:end}});
	L=ismember(Name,{'position','units','parent'});
	if any(L)
		L=find(L);L=sort([(L*2)-1 L*2]);ax_args=varargin(L);varargin(L)=[];
	else
		ax_args={};
	end
	%Create an axes, initialize the text object, and make the axes invisible.
	ax=axes(ax_args{:});axis(ax,[0 1 0 1])
	txt=text(ax,dblTextX,dblTextY,'','VerticalAlignment',strVertAlign,'HorizontalAlignment',strHorzAlign);
	set(ax,'Visible','off')
	%Apply the remaining Name,Value pairs.
	set(txt,varargin{:});
	%Create the ouput struct.
	h=struct('ax',ax,'txt',txt);
end