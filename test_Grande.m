clc;
clear;
close all;
fclose all;
format long g;

% Hedging and Carryover parameters
n     = 3;     % exponent n > 1
theta = 0.2000; % proportion of Benefit release [0, 1.0]

% Demand required
Dt    = 3.00;

% Storage required at end of period
Srt   = 70.0;

% useful Volume of reservoir
K     = 149.658;

% load time series 
data   = load('IN_Grande_TS.dat');
ntimes = size(data,1);

% Curves of reservoir
% Elevation vs Volume : Elevation = f(Volume^2)
V2E = [-0.000187	0.132624	0.092380];
% Area vs Elevation : Area = f(Elevation^2)
E2A = [ 0.007563	0.354194	5.129535];
Vtest = 100;
Etest = polyval(V2E,Vtest);
Atest = polyval(E2A,Etest);

[eta,Hedg_type,ADIt,ADFt,mRCO] = hedging_type(n,theta,Dt,Srt);

% Initial Reservoir Volume [Mm3]
Vo           = data(1,10)/1e6;

% Incoming flow [Mm3]
Qin_TS       = data(:,9);

% Evaporation [mm/d]
Evap_TS      = data(:,11);

% Evaporation [Mm3]
Evap_TS2     = zeros(ntimes,1);

Elev_TS      = zeros(ntimes,1);
Area_TS      = zeros(ntimes,1);
Vol_TS    = zeros(ntimes+1,1);
Vol_TS(1) = Vo;

ADt_TS       = zeros(ntimes,1);
Rt_TS        = zeros(ntimes,1);
Spt_TS       = zeros(ntimes,1);
WB_TS        = zeros(ntimes,1);

tic;
for it = 1:ntimes
  Elev_TS(it)  = polyval(V2E,Vol_TS(it));
  Area_TS(it)  = polyval(E2A,Elev_TS(it));
  Evap_TS2(it) = (Evap_TS(it)/1000)*Area_TS(it);
  
  ADt_TS(it)   = Vol_TS(it) + Qin_TS(it) - Evap_TS2(it);
  [Rt]         = cal_hedging_Rt(Hedg_type,ADt_TS(it),ADIt,ADFt,Dt,mRCO);
  Rt_TS(it)    = Rt;
  if (ADt_TS(it) - Rt) < K
    Vol_TS(it+1) = ADt_TS(it) - Rt;
    Spt_TS(it)      = 0.0;
  else
    Vol_TS(it+1) = K;
    Spt_TS(it)      = (ADt_TS(it) - Rt) - K;
  end
end
toc
corr(Vol_TS(1:end-1),data(:,10)/1e6)
%%
figure(1)
set(gcf,'Position',[59 1 1542 833]);
set(gcf,'Color',[1 1 1]);
subplot(2,1,1)
plot(data(:,7),Vol_TS(1:end-1),data(:,7),data(:,10)/1e6,'linewidth',2);
set(gca,'Position',[0.05 0.56 0.923 0.42]);
set(gca,'ylim',[0 150]);
set(gca,'ytick',0:10:150);
set(gca,'xtick',2002:1:2016);
set(gca,'Fontname','Times');
set(gca,'Fontweight','Bold');
set(gca,'Fontsize',14);
xlabel('Year');
ylabel('Volume [Mm^{3}]    \itS_{t} ');
legend('Sim','Obs','location','NE');
grid on;
subplot(2,1,2)
semilogx(ADt_TS(1:end),Rt_TS,'.');
set(gca,'Position',[0.05 0.08 0.923 0.41]);
set(gca,'ylim',[0 ceil(Dt)]);
% set(gca,'ytick',0:10:150);
% set(gca,'xtick',2002:1:2016);
set(gca,'Fontname','Times');
set(gca,'Fontweight','Bold');
set(gca,'Fontsize',14);
xlabel('[Mm^{3}] \itAD_t');
ylabel('Volume [Mm^{3}]    \itS_{t} ');
legend('Sim','location','NE');
grid on;