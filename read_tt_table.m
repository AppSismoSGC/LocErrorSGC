function [tau] = read_tt_table(x,z,tt,iphase);

%
% Read an already saved travel time table
% for a given velocity model tt. Model is 
% supposed to be a 2D layer model. Can read
% P or S waves
% 
% tau = read_tt_table(x,z,tt,iphase)
% 
% INPUT
% x  - single value of the X source distance. 
% z  - Depth of the source. 
% tt - Structure that contains the travel time table
%      for multiple source depths and X distances. 
%      tt has to be pre-computed using fdtt codes. 
%
% Optional Input
% iphase - Phase to read.
%
% OUTPUT
% tau - calculated travel time for source at (x,z). 
%

tau = -1;


if (x<0 | x>=max(tt.x))
   return
end
if (z<0 | z>=max(tt.z))
   return
end

if (nargin==3)
   iphase='p';
end
if (strcmp(iphase,'S')==1 | strcmp(iphase,'s')==1)
   t = tt.ts;
else
   t = tt.t;
end

%-------------------------------------------------
% Find X position

[xmin,xloc] = min(abs(x-tt.x));
tx1 = sign(x-tt.x(xloc));
x1 = xloc;
x2 = xloc+tx1;

%-------------------------------------------------
% Find Z position
[zmin,zloc] = min(abs(z-tt.z));
tz1 = sign(z-tt.z(zloc));
z1 = zloc;
z2 = zloc+tz1;

%-------------------------------------------------
% Find if both points are gridded
if (tz1==0 & tx1==0)
   tau = t(x1,z1);
   return
end

%-------------------------------------------------
% Find if X, or Z points are gridded
if (tx1==0)
   Zvec = [tt.z(z1) tt.z(z2)];
   Tvec = [t(x1,z1) t(x1,z2)];
   tau = interp1(Zvec,Tvec,z,'spline');
%   tau = interp1(Zvec,Tvec,z);
   return
elseif(tz1==0)
   Xvec = [tt.x(x1) tt.x(x2)];
   Tvec = [t(x1,z1) t(x2,z1)];
   tau = interp1(Xvec,Tvec,x,'spline');
%   tau = interp1(Xvec,Tvec,x);
   return
end


%-------------------------------------------------------------
% Generate Matrices
Xmat = [tt.x(x1) tt.x(x2)       ; tt.x(x1) tt.x(x2)];
Zmat = [tt.z(z1) tt.z(z1)       ; tt.z(z2) tt.z(z2)];
Tmat = [t(x1,z1) t(x2,z1) ; t(x1,z2) t(x2,z2)];

%-------------------------------------------------
% Interpolate

%tau = interp2(Xmat,Zmat,Tmat,x,z,'spline');
tau = interp2(Xmat,Zmat,Tmat,x,z);

return

