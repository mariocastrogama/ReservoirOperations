function [Rt] = cal_hedging_Rt(Hedging_type,ADt,ADIt,ADFt,Dt,mRCO)
% function [Rt] = cal_hedging_Rt(Hedging_type,ADt,ADIt,ADFt,Dt,mRCO)  
% estimate the optimal release Rt based on 
% the water availability ADt and the Demand Dt
%
% Output:
% Rt  : Reservoir Release
%
% Input 
% Hedging_type : For hedging --> 'Type I' or 'Type II', For SOR --> 'SOR'
% ADt          : Avaialable water inreservoir at time t
% ADIt         : Available initial water at time t (hedging)
% ADFt         : Available final water at time t (hedging)
% Dt           : Required demand at time t
% mRCO         : Slope of hedging (if there is hedging)
%
%

  if ADt <= ADIt % Under requirement
    switch Hedging_type
      case 'Type I'
        Rt = ADt;
      case 'Type II'
        Rt = 0;
      case 'SOR'
        Rt = ADt;
    end
  elseif (ADt <= ADFt) % Hedging
    switch Hedging_type
      case 'Type I'
        Rt = mRCO*ADt + ADIt*(1-mRCO);
      case 'Type II'
        Rt = mRCO*(ADt - ADIt);
      case 'SOR'
        if ADt < Dt
          Rt = ADt;
        else
          Rt = Dt;
        end
    end
  else % No hedging, full delivery of Demand
      Rt = Dt;
  end  
end