function [rnorm,gradf] = fgradient(fun,m0,params); 

%
% Calculate the norm and if requested the gradient of a 
% user defined function for a model m0.
%
% The misfit function (L1, L2) is called using cg_misfit
%
% Use:
%     [rnorm,gradf] = fgradient(fun,m0,params);
%
% fun		User defined function
% m0(nmod)  	vector of model parameters [m(1),m(2),...m(nmod)]
% params	structure with needed parameters
%
% rnorm		Norm of the misfit		
% gradf		Gradient of misfit for each model dimension
%
% Options (based on PARAMS structure)
% L2, L1 norms can be used 
%
% calls fmisfit
%
%&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
% German A. Prieto
% EAPS, MIT
% Sept 30, 2014
%&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

%--------------------------------------------------
% Read PARAMS data structure and validate
%--------------------------------------------------
if (isfield(params,'check')==0) 
   params = check_struct_cg(params);
end
if (params.check ~= 1)
   error('Error - loc_gradient Parameter Check')
end

%---------------------------------------------------
% Calculate the misfit using fun
%---------------------------------------------------

rnorm = fmisfit(fun,m0,params);

if (nargout==1)
   return
end

%---------------------------------------------------
% If requested, calculate gradient
%---------------------------------------------------

h = params.h;


for j = 1:params.nmod

   m1 = m0;
   %------------------------------------------
   % + dh
   %------------------------------------------
   m1(j) = m0(j) + 0.5*h;
   rnormp = fmisfit(fun,m1,params);

   %------------------------------------------
   % - dh
   %------------------------------------------
   m1(j) = m0(j) - 0.5*h;
   rnormm = fmisfit(fun,m1,params);

   %------------------------------------------
   % Calculate gradient
   %------------------------------------------
   if (rnormm>1e14)
      gradf(j)    = (rnormp-rnorm)/0.5*h;
   elseif (rnormp>1e14)
      gradf(j)    = (rnorm-rnormm)/0.5*h;
   else
      gradf(j)    = (rnormp-rnormm)/h;
   end
end

gradf    = gradf';

return



