function params = check_struct_cg(p_in);

%
% Algorithm to check the CG PARAMS structure. 
%

%--------------------------------------------------
% Read P_in data structure, check if checked
%--------------------------------------------------
params = p_in;
if (isfield(params,'check')==1)
   if (params.check == 1) 
      return
   end
end

if (isfield(params,'h')==0)
    params.h = 1e-7;
end

if (isfield(params,'sigma')==0)
    error('Error - check_struct_cg SIGMA')
end

if (isfield(params,'data')==0)
    error('Error - check_struct_cg DATA')
end

%--------------------------------------------------
% Check that data vector is a Column vector
%--------------------------------------------------

data = params.data;
if (iscolumn(data)==0)
   data = data';
end
if (size(data,2)>1)
   error('Error - check_struct_cg DATA needs to be vector')
end
nobs = length(data);
params.nobs = nobs;
params.data = data;

%--------------------------------------------------
% Check 1-norm or 2-norm (default) desired
%--------------------------------------------------

params.norm = check_struct_cg_norm(params);

%--------------------------------------------------
% Check the sizes of the vectors
%--------------------------------------------------

sigma = params.sigma;
if (iscolumn(sigma)==0)
   sigma = sigma';
end
if (size(data,2)>1)
   error('Error - check_struct_cg DATA needs to be vector')
end

nsig = length(sigma);
if (nsig==1)
   nsig = params.nobs;
   params.sigma(1:nobs,1) = sigma;
else
   params.sigma = sigma;
end 

%--------------------------------------------------
% Check dimension of observation/model are correct
%--------------------------------------------------

if (length(params.sigma) ~= params.nobs)
   error('Error - check_struct_cg Sigma size')
end

%--------------------------------------------------
% All checks passed
%--------------------------------------------------

params.check = 1;

return

%--------------------------------------------------------------------
% Finished check_struct
%--------------------------------------------------------------------

%********************************************************************
%								    *
%								    *
%								    *
% Additional functions						    *
%								    *
%								    *
%								    *
%********************************************************************

%--------------------------------------------------------------------
% check_struct_cg_norm - Check norm to use
%--------------------------------------------------------------------

function norm = check_struct_cg_norm(params);

%
% Check choice of the type of norm to use.
% If not defined, use L2 norm. 
%

if (isfield(params,'norm')==0) 
   norm = 2;
   return
end
if (params.norm == 2)
   norm = 2;	% L2 norm
elseif (params.norm == 1)
   norm = 1;	% L1 norm
else
   error('CHECK_STRUCT_NORM - L-Norm not accepted')
end 

return

%--------------------------------------------------------------------
% End check_struct_cg_norm 
%--------------------------------------------------------------------







