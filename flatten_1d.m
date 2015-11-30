function [z_f,vel_f] = flatten_1d(z_s,vel_s)

%-------------------------------------------------
% FLATTEN calculates flat earth tranformation.
%
% call [z_f,vel_f] = flatten(z_s,vel_s)
%
% Inputs
%   z_s    =  depth in spherical earth
%   vel_s  =  velocity in spherical earth
% Output
%   z_f    =  depth in flat earth
%   vel_f  =  velocity in flat earth
%
%-------------------------------------------------


R_e = 6371.;
r    = R_e-z_s;

z_f   = -R_e * log(r/R_e);
vel_f = (R_e./r).*vel_s;
      
return


