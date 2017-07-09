function PlotAxisAtOrigin(x,y)
%PlotAxisAtOrigin Plot 2D axes through the origin
%   This is a 2D version of Plot3AxisAtOrigin written by Michael Robbins
%   File exchange ID: 3245. 
%
%   Have hun! 
%
%   Example:
%   x = -2*pi:pi/10:2*pi;
%   y = sin(x);
%   PlotAxisAtOrigin(x,y)
%

% PLOT
if nargin == 2 
  plot(x,y);
  hold on;
else
  display('   Not 2D Data set !');
end;

% GET TICKS
X = get(gca,'Xtick');
Y = get(gca,'Ytick');

% GET LABELS
XL = get(gca,'XtickLabel');
YL = get(gca,'YtickLabel');

% GET OFFSETS
Xoff = diff(get(gca,'XLim'))./100;
Yoff = diff(get(gca,'YLim'))./100;
Doff = min(Xoff,Yoff);

% DRAW AXIS LINEs
plot(get(gca,'XLim'),[0 0],'k');
plot([0 0],get(gca,'YLim'),'k');

% Plot new ticks  
for i=1:length(X)
  plot([X(i) X(i)],[0 Doff],'-k');
end
for i=1:length(Y)
  plot([-Doff, 0],[Y(i) Y(i)],'-k');
end;

% ADD LABELS
% set(gca,'xticklabel',XL);
% set(gca,'yticklabel',YL);
text(X,zeros(size(X))-2*Doff,XL,'FontSize',14,'FontName','Cambria','Fontweight','Bold');
text(zeros(size(Y))-Doff,Y,YL,'FontSize',14,'FontName','Cambria','Fontweight','Bold',...
  'HorizontalAlignment','right');

box off;
% axis square;
axis off;
set(gcf,'color','w');
end