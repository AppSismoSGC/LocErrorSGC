function [qx,qy,qdep,qtime,rnorm,res] =  ...
          cg_location_xy(fun, eq_loc, ...
          qx0,qy0,qdep0,qtime0)

%
% BFGS_LOCATION
%
% Earthquake location solver using a Conjugate 
% gradient approach. A preliminary location 
% is required. 
% It is assumed that all phases are associated 
% to a single event.
%

global tt_table;

%----------------------------------------------------------
% Define parameters from structure

sta    = eq_loc.sta;
xsta   = eq_loc.xsta;
ysta   = eq_loc.ysta;
selev  = eq_loc.selev;
atime  = eq_loc.atime;
sigma  = eq_loc.sigma;
iphase = eq_loc.iphase;
Lnorm  = eq_loc.norm;
h      = eq_loc.h;

qx    = -999.99;
qy    = -999.99;
qdep  = -999.99;
qtime = -999.99; 

%-------------------------------------------
% Create Station ID and lat/lon

[sta1,ia,ic] = unique(sta);
xsta1    = xsta(ia);
ysta1    = ysta(ia);
selev1   = selev(ia);
ista     = ic;

%-------------------------------------------
% Generate model and parameter structures

m0 = [qx0 qy0 qdep0 0]';

%-------------------------------------------
% Generate the CG Parameter file

params.data   = atime-qtime0;
params.sigma  = sigma;
params.nmod   = 4;
params.xsta   = xsta;
params.ysta   = ysta;
params.selev  = selev;
params.iphase = iphase;
params.nobs   = length(atime);
params.norm   = Lnorm;
params.h      = h;

if (isfield(params,'check')==0) 
   params = check_struct_cg(params);
end
if (params.check ~= 1)
   error('Error - BFGS_LOCATION Parameter Check')
end

[mhat,rnorm,res,cg_loop,cg_stop] = bfgs_solve(fun,params,m0);

qx    = mhat(1);
qy    = mhat(2);
qdep  = mhat(3);
qtime = mhat(4)+qtime0;

return








