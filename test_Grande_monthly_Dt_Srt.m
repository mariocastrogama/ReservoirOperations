clc;
clear;
close all;
fclose all;
format long g;

% Hedging and Carryover parameters
n_TS     = 3.0000*ones(1,12); % exponent n > 1
theta_TS = 0.2000*ones(1,12); % proportion of Benefit release [0, 1.0]

% Demand required
Dt_TS    = [3.00, 2.00, 2.50, 4.00, 1.00, 2.00, 4.00, 3.00, 2.00, 1.00, 2.00, 2.00];

% Storage required at end of period
Srt_TS   = [70.0, 50.0, 60.0, 90.0, 90.0, 80.0, 70.0, 90.0, 80.0, 60.0, 50.0, 70.0];

% useful Volume of reservoir
K        = 149.658;

% load time series 
data   = load('IN_Grande_TS.dat');
ntimes = size(data,1);

% Curves of reservoir
% Elevation vs Volume : Elevation = f(Volume^2)
V2E = [-0.000187	0.132624	0.092380];
% Area vs Elevation : Area = f(Elevation^2)
E2A = [ 0.007563	0.354194	5.129535];
% Vtest = 100; Etest = polyval(V2E,Vtest); Atest = polyval(E2A,Etest);

% Incoming flow [Mm3]
Qin_TS       = data(:,9);

% Evaporation [mm/d] - Known
Evap_TS      = data(:,11);

% Evaporation [Mm3] - Function of Reservoir surface area
Evap_TS2     = zeros(ntimes,1);

% Elevation [m]
Elev_TS      = zeros(ntimes,1);

% Area [Mm2]
Area_TS      = zeros(ntimes,1);

% Volume in current storage [Mm3]
Vol_TS    = zeros(ntimes+1,1); % one more for t = 0
% Initial Reservoir Volume [Mm3]
Vo           = data(1,10)/1e6;
Vol_TS(1) = Vo; % Known from Observed TS

% Results of hedging Available Water, Release, Spill, Water Balance
ADt_TS       = zeros(ntimes,1);
Rt_TS        = zeros(ntimes,1);
Spt_TS       = zeros(ntimes,1);
WB_TS        = zeros(ntimes,1);

tic;
for t = 1:ntimes
  % Estimate values for current month
  curr_month = data(t,2);
  Dt    = Dt_TS(curr_month);
  Srt   = Srt_TS(curr_month);
  n     = n_TS(curr_month); 
  theta = theta_TS(curr_month);
  
  % Estimate hedging values
  [eta,Hedg_type,ADIt,ADFt,mRCO] = hedging_type(n,theta,Dt,Srt);
  
  % Update current Reservoir status (Elevation , Area, Evaporation)
  Elev_TS(t)  = polyval(V2E,Vol_TS(t));
  Area_TS(t)  = polyval(E2A,Elev_TS(t));
  Evap_TS2(t) = (Evap_TS(t)/1000)*Area_TS(t);
  
  % Estimate Available Water
  ADt          = Vol_TS(t) + Qin_TS(t) - Evap_TS2(t);
  ADt_TS(t)   = ADt;
  % Calculate hedging
  [Rt]         = cal_hedging_Rt(Hedg_type,ADt,ADIt,ADFt,Dt,mRCO);
  Rt_TS(t)    = Rt;
  
  % Update Volume --> t+1 Or possible Spill --> t
  if (ADt - Rt) <= K % No Spill
    Vol_TS(t+1) = ADt - Rt;
    Spt_TS(t)   = 0.0;
  else
    Vol_TS(t+1) = K; % Spill!
    Spt_TS(t)   = (ADt - Rt) - K;
  end
end % t
toc
r = corr(Vol_TS(1:end-1),data(:,10)/1e6)
RMSE = sum([Vol_TS(1:end-1)-data(:,10)/1e6].^2)/ntimes
OF = [-r, RMSE]
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
plot(ADt_TS(1:end),Rt_TS+Spt_TS,'.');
set(gca,'Position',[0.05 0.08 0.923 0.41]);
set(gca,'ylim',[0 ceil(max(Dt_TS))]);
% set(gca,'ytick',0:10:150);
% set(gca,'xtick',2002:1:2016);
set(gca,'Fontname','Times');
set(gca,'Fontweight','Bold');
set(gca,'Fontsize',14);
xlabel('[Mm^{3}] \itAD_t');
ylabel('Release [Mm^{3}]    \itR_{t} ');
legend('Sim','location','NE');
grid on;