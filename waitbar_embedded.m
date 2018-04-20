function fout = waitbar_embedded(x,ax, varargin)
%WAITBAR_EMBEDDED displays a waitbar inside to the axes given as parameter or current axes.
%   H = WAITBAR_EMBEDDED(X, AX, property, value, property, value, ...)
%   creates and displays a waitbar of fractional length X.
%   > The handle to the waitbar axes is returned in H.
%   > X should be between 0 and 1.
%   > AX can be supplied as a parameter by handle or unique tag.
%   > Optional arguments property and value allow to set corresponding waitbar properties.
%
%   WAITBAR_EMBEDDED(X) will set the length of the bar in the most recently
%   created axes to the fractional length X.
%
%   WAITBAR_EMBEDDED(X,AX) will set the length of the bar in axes AX
%   to the fractional length X.mod(a,m)
%
%   WAITBAR_EMBEDDED is typically used inside a FOR loop that performs a
%   lengthy computation.
%
%   Example:
%       h = waitbar_embedded(0,'String','Please wait...');
%       for i=1:1000
%           % computation here
%           waitbar_embedded(i/1000,h);
%       end

% Author: Mariano Aránguez
% $Date: 2017/11/22 $

%% Input parameters
if (nargin == 0)
    error(message('MATLAB:waitbar:InvalidArguments'));
elseif (nargin > 0)
    % Must be a numeric value
    if ~isnumeric(x) || ~isscalar(x)
        error(message('MATLAB:waitbar:InvalidFirstInput'));
    elseif ((x < 0) || (x > 1))
        % Throw a warning in this case, clamp it down and keep going
        % this is a behavior change and we want to eventually error out in this scenario,
        % but want to do that gradually
        if (x < 0)
            x = 0;
        elseif (x > 1)
            x = 1;
        end
        % This warning will be enabled when callers no longer send in values
        % outside the allowed range
        % warning('MATLAB:waitbar:invalidValue', '%s\n%s%s', ...
        %    'The first argument must be a numeric value between 0 and 1.',...
        %    'Setting the value to: ', num2str(x));
    end
    
    if (nargin == 1)
        % An axes handle is not provided. Look for one.
        ax = gca;
    elseif (nargin > 1)
        % A waitbar message or handle to an existing waitbar has been provided
        if ischar(ax) || iscellstr(ax)
            param=ax;
            ax = findobj(allchild(0), '-depth',inf, 'tag',ax);
            if isempty(ax)
                % An axes handle is not provided. Look for one.
                varargin = horzcat({param},varargin);
                ax = gca;
            end
        elseif ~isgraphics(ax, 'axes')
            error('MATLAB:waitbar:InvalidInputs', 'Input arguments of type %s not valid.', class(ax))
        end
    end
    
    if isempty(ax)
        % No axes found
        error('MATLAB:waitbar:InvalidArguments', 'No current axes found for the current figure.');
    end
end

%% Body
x = floor(max(0,min(100*x,100))); % Map any value of x to a integer value between 0 and 100
try
    drawWaitbar(varargin{:});
catch ex
    err = MException('MATLAB:waitbar:InvalidArguments','%s',...
        getString(message('MATLAB:waitbar:ImproperArguments')));
    err = err.addCause(ex);
    throw(err);
end
drawnow;

if nargout==1
    fout = ax;
end
    %% Status Bar Drawing Function
    function drawWaitbar(varargin)
        %% axes definition
        if isempty(ax.UserData)
            set(ax,...
                'Units','pix',...
                'XTick',[],...
                'YTick',[],...
                'XLim',[0 100],...
                'YLim',[0 1],...
                'Visible','on',...
                'Box','on',...
                'FontSize',10);
            ax.Title.FontSize = 8;
            ax.Title.FontWeight = 'normal';
            ax.UserData = struct('length',[], 'defaultFaceColor',[]);
        end
        
        bDraw = true;
        if ~isempty(ax.UserData.length)
            bDraw = (ax.UserData.length ~= x);
        end
        
        for k = 10:-1:1
            rc{k} = findobj(allchild(ax), 'flat', 'Type','rectangle', 'Tag',sprintf('rectangle%i', k));
        end
        
        %% drawing waitbar
        if bDraw
            ax.UserData.length = x;
            
            % scale
            px = (ax.XLim(2)-ax.XLim(1))/ax.Position(3); ox = 2*px;
            py = (ax.YLim(2)-ax.YLim(1))/ax.Position(4); oy = 2*py;
            xx = 1 - 2*ox/(ax.XLim(2)-ax.XLim(1));
            yy = 1 - 2*oy/(ax.YLim(2)-ax.YLim(1));

            % rectangle definition
            for k = 10:-1:1
                if isempty(rc{k})
                    rc{k} = rectangle(ax, 'Tag',sprintf('rectangle%i', k), 'EdgeColor','none', 'FaceColor','g');
                end
                rc{k}.Position = [ox,oy,round(100*x/100)*xx,k/length(rc)*yy];
            end
            if isempty(ax.UserData.defaultFaceColor)
                ax.UserData.defaultFaceColor = rc{1}.FaceColor;
            end

            % text inside the rectangle
            txt = findobj(allchild(ax), 'flat', 'Type','text');
            if ~isempty(txt)
                delete(txt);
            end
            texto = '';
            if x
                texto = [num2str(round(100*x/100)),'%'];
            end

            % sombra del texto
            for dx=[-px px]
                for dy=[-py py]
                    text(ax,(ax.XLim(2) - ax.XLim(1))/2 + dx,(ax.YLim(2) - ax.YLim(1))/2 + py + dy,texto,...
                        'HorizontalAlignment','center',...
                        'VerticalAlignment','middle',...
                        'FontSize',ax.Position(4)/2-1,...
                        'FontWeight','bold',...
                        'FontSmoothing','on',...
                        'Color',ax.Color);
                end
            end
            text(ax,(ax.XLim(2) - ax.XLim(1))/2,(ax.YLim(2) - ax.YLim(1))/2 + py,texto,...
                'HorizontalAlignment','center',...
                'VerticalAlignment','middle',...
                'FontSize',ax.Position(4)/2-1,...
                'FontWeight','bold',...
                'FontSmoothing','on',...
                'Color',0.3*[1 1 1]);
       end
        
        
        %% Properties
        if nargin > 0
            % we have optional arguments: property-value pairs
            if rem (nargin, 2 ) ~= 0
                error('MATLAB:waitbar:InvalidOptionalArgsPass',  'Optional initialization arguments must be passed in pairs');
            end
            
            propList = varargin(1:2:end);
            valueList = varargin(2:2:end);

            for ii = 1:length(propList)
                try
                    if isprop(ax.Title, propList{ii})
                        % set the prop/value pair of the axes
                        set(ax.Title, propList{ii}, valueList{ii});
                    elseif isprop(ax, propList{ii})
                        % set the prop/value pair of the axes
                        set(ax, propList{ii}, valueList{ii});
                    elseif isprop(rc{1}, propList{ii})
                        % set the prop/value pair of the rectangle
                        if strcmpi(propList{ii}, 'FaceColor')
                            set(rc{1}, propList{ii}, valueList{ii});
                            if ~isequal(ax.UserData.defaultFaceColor, rc{1}.FaceColor)
                                ax.UserData.defaultFaceColor = rc{1}.FaceColor;
                                bDraw = true;
                            end
                        else
                            for k=1:length(rc)
                                set(rc{k}, propList{ii}, valueList{ii});
                            end
                        end
                    end
                catch
                    fprintf('Warning: could not set property %s with value %s\n', propList{ii}, num2str(valueList{ii}));
                end
            end
        end
        
        %% Add-ons after properties definition
        if bDraw
            % default color
            color = ax.UserData.defaultFaceColor;
            % 3D-Color
            for k=1:length(rc)
                % starting color
                color1 = color + (1-color)*0.25;
                % ending color
                color2 = color * (1-0.25);
                % rectangle color according to its height
                heightRt = rc{k}.Position(4);
                colorRt = color2 + (heightRt - ax.YLim(1)) * (color1 - color2) / (ax.YLim(2)-ax.YLim(1));
                rc{k}.FaceColor = colorRt;
            end
       end
    end    
end

