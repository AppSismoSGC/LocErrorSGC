function [rnorm,res] = fmisfit(fun,m0,params);

%---------------------------------------------------
% Call user-defined function

dhat  = fun(m0,params);

%--------------------------------------------------------------------
% Calculate residual

ri   = (dhat-params.data)./params.sigma;

for i = 1:length(dhat)
   if (dhat(i)<m0(end))
      ri(i) = 1e15;
   end 
end
if (params.norm==2)
   rnorm  = sqrt(sum(abs(ri).^2));
elseif (params.norm==1) 
   rnorm  = sum(abs(ri));
end
% Check values being not NaNs
if (rnorm==0)
   rnorm = 1e15;
end
%----------------------------------------------------------
% Return unweighted residuals

if (nargout==2)
   res      = (dhat-params.data);    %(dhat-params.data);
end

return
