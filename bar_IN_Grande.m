clc;
clear;
close all;
fclose all;
format long g;

% load data of Inflow to Grande
load('IN_Grande.mat');

% Figures
h1 = figure(1);
set(gcf,'Color',[1 1 1]);
mo_txt = {'ENE','FEB','MAR','ABR','MAY','JUN','JUL','AGO','SEP','OCT','NOV','DIC'};
estdis = zeros(4,12);
for ii=1:12;
  estdis(1,ii) = max(dataset(ii).values);
  estdis(2,ii) = mean(dataset(ii).values);
  estdis(3,ii) = min(dataset(ii).values);
  estdis(4,ii) = std(dataset(ii).values);
  
  bar(ii,estdis(1,ii),0.95, 'facecolor',[0.70 0.85 1.00]); hold on; 
  bar(ii,estdis(2,ii),0.95,'facecolor',[1.00 0.55 0.35]); hold on; 
  bar(ii,estdis(3,ii),0.95, 'facecolor',[1.00 1.00 0.35]); hold on;
  plot(ii,estdis(2,ii)+estdis(4,ii),'k^', 'markerfacecolor',[0.50 0.90 0.35]); hold on;
  plot(ii,estdis(2,ii)-estdis(4,ii),'kv', 'markerfacecolor',[0.50 0.90 0.35]); hold on; 
end
set(gca,'Position',[0.0575 0.050 0.920 0.915]);
set(gca,'Fontname','Cambria');
set(gca,'Fontsize',14);
set(gca,'Fontweight','Bold');
set(gca,'ylim',[0 175]);
set(gca,'ytick',0:25:175);
set(gca,'xlim',[0.35, 12.65]);
set(gca,'xtick',1:12);
set(gca,'xticklabel',mo_txt);
ylabel('{\itQ_{t}}   [m^{3}/s]')
grid on;
legend({'Máx','\mu_{\itt}','mín','\mu_{\itt} + \sigma_{\itt}','\mu_{\itt} - \sigma_{\itt}'},'Location','NW');