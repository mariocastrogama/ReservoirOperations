clc;
clear;
close all;
fclose all;
format long g;

% load data of Inflow to Grande
load('IN_Grande.mat');

% Preset for subplots
%  make_it_tight = false;
%  subtightplot(m, n, p,  [gap_vert, gap_horz],  [marg_bottom, marg_top], [marg_left, marg right],varargin)
make_it_tight = true; 
subplot = @(m,n,p) subtightplot(m, n, p, [0.055, 0.035], [0.035, 0.035], [0.035, 0.015]);
if ~make_it_tight;  clear subplot;
end
          
h1 = figure(1);
set(gcf,'Color',[1 1 1]);
prob_quan = 0.00:0.01:1.00;
yest = 0:1:170;
alpha_fit = 0.05;

mo_txt = {'ENE','FEB','MAR','ABR','MAY','JUN','JUL','AGO','SEP','OCT','NOV','DIC'};
for ii = 1:12;
  subplot(2,6,ii);
  y = dataset(ii).values*54/625;
  boxplot(y);
%   xlabel(dataset(ii).month);
  set(gca,'Fontname','Times');
  set(gca,'Fontweight','Bold');
  set(gca,'Fontsize',12);
  set(gca,'ylim',[0 16]);
  set(gca,'xticklabel',mo_txt{ii});
  set(gca,'ytick',0:2:16);
  if mod(ii,6)~=1;
    set(gca,'yticklabel','');
  end
  grid on;
end