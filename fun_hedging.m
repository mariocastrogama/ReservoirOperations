function [OF] = fun_hedging(x)
% 
% Gupta, Hoshin V.; Kling, Harald; Yilmaz, Koray K.; Martinez, Guillermo F.
% (2009) Decomposition of the mean squared error and NSE performance criteria:
% Implications for improving hydrological modelling.
% Journal of Hydrology 377(2009)80–91.
% DOI: 10.1016/j.jhydrol.2009.08.003 
%

  global maxfuneval
  global nfuneval
  global FlagPlot   
  
  if ~exist('nfuneval','var')
    nfuneval = 1; 
  else
    nfuneval = nfuneval + 1;
  end
  
  total_time = tic;
  % Hedging and Carryover parameters
  n_TS     = x( 1:12); % exponent n > 1
  theta_TS = x(13:24); % proportion of Benefit release [0, 1.0) to enforce SOR use 1.0

  % Demand required each month --> t
  Dt_TS    = x(25:36);

  % Storage required at end of period --> t+1
  Srt_TS   = x(37:48);

  % useful Volume of reservoir
  K        = 139.658;

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
  
  % Volumes observed [Mm3]
  Vol_TS_obs   = data(:,10)/1e6;
  
  % Elevation [m]
  Elev_TS      = zeros(ntimes,1);

  % Area [Mm2]
  Area_TS      = zeros(ntimes,1);

  % Volume in current storage [Mm3]
  Vol_TS    = zeros(ntimes+1,1); % one more for t = 0
  % Initial Reservoir Volume [Mm3]
  Vo        = data(1,10)/1e6;
  Vol_TS(1) = Vo; % Known from Observed TS

  % Results of hedging Available Water, Release, Spill, Water Balance
  eta_TS       = zeros(ntimes,1);
  ADIt_TS      = zeros(ntimes,1);
  ADFt_TS      = zeros(ntimes,1);
  mRCO_TS      = zeros(ntimes,1);

  ADt_TS       = zeros(ntimes,1);
  Rt_TS        = zeros(ntimes,1);
  Spt_TS       = zeros(ntimes,1);
  WB_TS        = zeros(ntimes,1);

  % Main loop
  for t = 1:ntimes
    % Estimate values for current month
    curr_month = data(t,2);
    Dt    = Dt_TS(curr_month);
    Srt   = Srt_TS(curr_month);
    n     = n_TS(curr_month); 
    theta = theta_TS(curr_month);

    % Estimate hedging values
    [eta,Hedg_type,ADIt,ADFt,mRCO] = hedging_type(n,theta,Dt,Srt);
%     Hedg_type;
    eta_TS(t)  = eta;
    ADIt_TS(t) = ADIt;
    ADFt_TS(t) = ADFt;
    mRCO_TS(t) = mRCO;
    
    % Update current Reservoir status (Elevation , Area, Evaporation)
    Elev_TS(t)  = polyval(V2E,Vol_TS(t));
    Area_TS(t)  = polyval(E2A,Elev_TS(t));
    Evap_TS2(t) = (Evap_TS(t)/1000)*Area_TS(t);

    % Estimate Available Water
    ADt          = Vol_TS(t) + Qin_TS(t) - Evap_TS2(t);
    ADt_TS(t)   = ADt;
    
    % Calculate hedging release at time t
    Rt          = cal_hedging_Rt(Hedg_type,ADt,ADIt,ADFt,Dt,mRCO);
    Rt_TS(t)    = Rt;

    % Update Volume --> t+1 Or possible Spill --> t
    if (ADt - Rt) <= K % No Spill
      Vol_TS(t+1) = ADt - Rt;
      Spt_TS(t)   = 0.0;
    else
      Vol_TS(t+1) = K; % Spill!
      Spt_TS(t)   = (ADt - Rt) - K;
    end
    WB_TS(t) = ADt - Vol_TS(t+1) - Rt - Spt_TS(t);
  end % t
  % figure(3) 
  % plot(WB_TS)
  % max(WB_TS)
   
  % Performance criteria for calibration
  sigma_sim = std(Vol_TS(1:end-1))
  nu_sim    = mean(Vol_TS(1:end-1))
  sigma_obs = std(Vol_TS_obs)
  nu_obs    = mean(Vol_TS_obs)
  
  % For KGE according to Gupta et al. (2009)
  alpha     = sigma_sim/sigma_obs;
  beta      = nu_sim/nu_obs;             % for ED estimation
  betan     = (nu_sim-nu_obs)/sigma_obs; % for NSE estimation
  r         = corr(Vol_TS(1:end-1),Vol_TS_obs);
  
  %   min_alpha = abs(alpha-1);
  %   min_beta  = abs(betan-1);
  
  % Maximize NSE --> 1.0 (depends only on betan)
%   NSE = 2*alpha*r - alpha^2 - betan^2;
  
  % Minimize RMSE--> 0.0
%   MSE = sum((Vol_TS(1:end-1)-Vol_TS_obs).^2)/ntimes;
  
  % Maximize KGE --> 1.0 (depends of beta not of betan)
%   ED  = ((r-1)^2 + (alpha-1)^2 + (beta-1)^2).^0.5;
%   KGE = 1 - ED;
  
  % Return the objectives (-max{OF} = min{OF})
  % OF  = [MSE, -r, -NSE, -KGE];%, min_beta, min_alpha];
  OF = [alpha, r, betan, beta];
  
  % Simulation time
  total_time = toc(total_time);
  
  if mod(nfuneval,maxfuneval/10) == 0
    disp(['feval : ', sprintf('%06d',nfuneval), ', ',sprintf('%6.1f',toc)]);
  end
  %% Plot the results
  if (FlagPlot == 1)
    figure;
%     set(gcf,'Position',[59 1 1542 833]);
    set(gcf,'Position',[1 30 1600 805]);
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
    ylabel('[A] Volumen [Mm^{3}] - \itS_{t} ');
    legend('Sim','Obs','location','NE');
    grid on;
    subplot(2,1,2)
    for imonth = 1:12
      xmonth = find(data(:,2)== imonth);
      icolor = [0.2+0.6*(imonth-0.5)/12, abs(imonth-6.5)/6, (12.5-imonth)/12];
      
      % order the Available water for the month
      [ADt_TS_month, new_order] = sort(ADt_TS(xmonth));
      
      % Rearrange Release and Spill according to new_order of ADt_TS
      Rt_TS_month  = Rt_TS(xmonth);
      Rt_TS_month  = Rt_TS_month(new_order);
      Spt_TS_month = Spt_TS(xmonth);
      Spt_TS_month = Spt_TS_month(new_order);
      
      plot(ADt_TS_month,Rt_TS_month+Spt_TS_month,'o-',...
        'MarkerFaceColor',1-icolor,...
        'MarkerEdgeColor',1-icolor,...
        'color',icolor); hold on;
    end
    set(gca,'Position',[0.05 0.08 0.923 0.41]);
    maxRel = max(Rt_TS+Spt_TS);
    set(gca,'ylim',[0 1.05*(max(Dt_TS))]);% ceil(max(maxRel,1.2*max(Dt_TS)))]);
    set(gca,'Fontname','Times');
    set(gca,'Fontweight','Bold');
    set(gca,'Fontsize',14);
    xlabel('Agua Disponible [Mm^{3}] - \itAD_t');
    ylabel('[B] Descarga [Mm^{3}] - \itR_{t}');
    legend({'Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dec'},'location','NW');
    grid on;
  end
end