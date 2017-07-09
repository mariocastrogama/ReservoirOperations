clc;
clear;
close all;

format long g;

% load data of Inflow to Grande
load('IN_Grande.mat');


prob_quan = 0.00:0.04:1.00;
yest = 0:0.1:16;
alpha_fit = 0.05;
dQmin = 0.00001;
dQaxis = 2;
mo_txt = {'ENE','FEB','MAR','ABR','MAY','JUN','JUL','AGO','SEP','OCT','NOV','DIC'};

%%
% Preset for subplots
%  make_it_tight = false;
%  subtightplot(m, n, p,  [gap_vert, gap_horz],  [marg_bottom, marg_top], [marg_left, marg right],varargin)
make_it_tight = true; 
subplot = @(m,n,p) subtightplot(m, n, p, [0.075, 0.045], [0.065, 0.015], [0.035, 0.015]);
if ~make_it_tight;
  clear subplot;
end
          
h1 = figure(1);
set(gcf,'Color',[1 1 1]);

for ii = 1:12;
  subplot(3,4,ii);
  y = dataset(ii).values*(54/625); % daily flows into 10^6*m3

  [xa] = quantile(y,prob_quan); 
  dataset(ii).ndays    = length(y);
  dataset(ii).min      = min(y)-dQmin;
  dataset(ii).max      = max(y);
  dataset(ii).mean     = mean(y);
  dataset(ii).std      = std(y);
  dataset(ii).quantile = xa;
  
  % Adjust the data to a Gamma pdf of 2 parameters
  [paramhat, paramci] = gamfit(y-dataset(ii).min, alpha_fit);
  % Store the obtained parameters of the pdf
  dataset(ii).paramhat = paramhat;
  dataset(ii).paramci  = paramci;
  % Estimate the cummulative probability for certain values of discharge
  prob_est = gamcdf(yest, paramhat(1), paramhat(2));
  % Estimate the cummulative probability for certain values of discharge
  % for the Confidence Interval of parameters
  prob_CDFest11 = gamcdf(yest, paramci(1,1), paramci(1,2));
  prob_CDFest22 = gamcdf(yest, paramci(2,1), paramci(2,2));
  
  % Plot the obtained values
  % Notice that the values must be shifted by the minimum discharge
  % observed at each month
  % 1) Confidence Interval
  xpatch = [yest+dataset(ii).min, fliplr(yest + dataset(ii).min)];
  ypatch = [prob_CDFest11, fliplr(prob_CDFest22)];
  patch(xpatch, ypatch, [0.8 0.8 0.8]); hold on;
  % 2) Estimated values after adjustment
  plot(yest+dataset(ii).min, prob_est,'r-','linewidth',2); hold on;
  % 3) observed values and its probabilities
  plot(xa, prob_quan,'s','MarkerEdgeColor','k','MarkerFaceColor','w'); hold on;
%   plot(xa, prob_quan,'b-','linewidth',2); hold on;
  km = ceil(max(y)/dQaxis);
  set(gca,'xlim',[0 max(km*dQaxis,16)]);
  set(gca,'xtick',(0:dQaxis:max(km*dQaxis,16)));
  set(gca,'ylim',[0 1.05]);
  set(gca,'ytick',[0.00:0.20:1.00, 1.05]);
  set(gca,'yticklabel',{' 0',0.20:0.20:0.80, '1.0', ' '});
  set(gca,'Fontname','Times');
  set(gca,'Fontweight','Bold');
  set(gca,'Fontsize',12);
  nameCI  = ['I.C. ',sprintf('%3d',(1-alpha_fit)*100),'%'];
  namefit = ['\gamma ( ',sprintf('%3.2f',paramhat(1)),' , ',sprintf('%3.2f',paramhat(2)),' )'];
%   legend({nameCI,namefit,dataset(ii).month},'location','SE','Fontsize',14);
  legend({nameCI,namefit,mo_txt{ii}},'location','SE','Fontsize',14);
  xlabel('Q_{t} [10^{6}m^{3}]');
  ylabel('FDA');
  grid on;
end
