clc;
hFig = figure('units','pixels','position',[600 400 500 200]);

ax=axes(hFig, 'Units','pix','Position',[20 90 460 16]);
set(ax,'Xtick',[],'Ytick',[],'XLim',[0 1000],'YLim',[0 1000]);
box on;

%% Test waitbar_embedded
tic
N=1000;
h = waitbar_embedded(0,ax,'String',strcat('Palos de la Frontera','-','Embajadores'));
for color = 'g'
% for color= ['c' 'r' 'm' 'b' 'g']
    for i=0:1:N
         waitbar_embedded(i/N,h,'String',strcat('Palos de la Frontera','-','Embajadores'));
%        waitbar_embedded(i/N,h);
%         fast_waitbar_embedded(i, N, h,'String',strcat('Palos de la Frontera','-','Embajadores'));
    end
end
toc
