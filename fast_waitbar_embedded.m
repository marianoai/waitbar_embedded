function fast_waitbar_embedded(x,x_max,ax, varargin)
    if ~mod(x, max(1,floor(x_max/100))) || (x==x_max)
%         disp([round(x/x_max*100),x,x_max]);
        waitbar_embedded(x/x_max,ax, varargin{:});
    end
end
