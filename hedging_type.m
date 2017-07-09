function [eta,Hedging_type,ADIt,ADFt,mRCO] = hedging_type(n,theta,Dt,Srt)
% [eta,Hedging_type,ADIt,ADFt,mRCO] = hedging_type(n,theta,Dt,Srt)
% function to estimate the hedging type depending on the selected rule
%
% Output
% eta          : Inverse weighted target ratio
% Hedging_type : For hedging --> 'Type I' or 'Type II', For SOR --> 'SOR' 
% ADIt         : Available initial water at time t (hedging)
% ADFt         : Available final water at time t (hedging)
% mRCO         : Slope of hedging (if there is hedging)
% 
% Input
% n            :
% theta        : weighting factor of loss function [0, 1]    
% Dt           : Required demand at time t
% Srt          : Required storage at time t+1
%

  % eta = Inverse weighted target ratio   
  eta = (1-theta)/theta*Dt/Srt;
  
  % Determine which type of operation is performed
  if (theta == 1) % Standard operation rule SOR (NO HEDGING)
     Hedging_type = 'SOR';
  else            % Hedging type
    if (eta > 1)
      Hedging_type = 'Type II';
    else % (eta < 1)
      Hedging_type = 'Type I';
    end
    % Available Water Initial
    b    = 1/(n-1);
    tmp1 = max(Dt*(1-eta^b),0);
    tmp2 = max(Srt*(1-(1/eta)^b),0);
    ADIt = max(tmp1,tmp2);
  
    % Available Water Final
    ADFt = Dt + Srt;
  end
  
  % Slope of Hedging
  switch Hedging_type
    case 'Type I'
      mRCO = (Dt-ADIt)/(ADFt - ADIt);
    case 'Type II'
      mRCO = (Dt)/(ADFt - ADIt);
    case 'SOR'
      ADIt = Dt;
      ADFt = Dt;
      mRCO = 0;
  end
end    