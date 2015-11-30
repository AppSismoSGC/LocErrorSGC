function [Tout,xpos,zpos] = fdtt_calculate(xsrc,zsrc,V,h);
%
% FDTT_CALCULATE
% 
% Routine to calculate the travel time for a source 
% at XSRC and depth ZSRC, given a velocity model 
% described in matrix V(nz,nx). Spatial sampling is 
% dx=dz=h
% Note that the velocity model first index is depth (z)
% and second index is horizontal. 
%
% Call:
% [Tout,xpos,zpos] = fdtt_calculate(xsrc,zsrc,V,h);
%
% Algorithm: 
% Algorithm uses a finite-difference travel time calculation
% by solving the Eikonal equation (Vidale, 1988) and with 
% wavefront tracking (Qin et al., 1991). Additional care is 
% taken to include possible refraction by calculating all
% possible travel-times and choosing the fastest one at 
% each step. 
%
% INPUT
% xsrc      - horizontal source position.
% zsrc      - Depth of the source
% V(nz,nx)  - Velocity model matrix
% h         - spatial sampling. 
% 
% OUTPUT 
% Tout      - Travel time matrix.
% 
% OPTIONAL OUTPUT
% xpos      - x axis in correct units (km)
% zpos      - depth axis in correct units (km)
% 

%--------------------------------------------------------
% Display Begining

disp('Finite difference travel time Calculator')
%--------------------------------------------------------
% Matrix indices

zside = [1  0 -1   0];
xside = [0  1  0  -1];

%--------------------------------------------------------
% Boundary conditions

nbc   = 2;

%--------------------------------------------------------
% Check sizes and source location

nz    = size(V,1);
nx    = size(V,2);
ngrid = nx*nz;

xpos = [0:size(V,2)-1]*h;
zpos = [0:size(V,1)-1]*h;

if (xsrc<0 | xsrc>max(xpos))
   error('X source position is out of range')
end
if (zsrc<0 | zsrc>max(zpos))
   error('Z source position is out of range')
end


%--------------------------------------------------------
% Create slowness matrix, with # boundary bins = nbc

S(1:nz+2*nbc,1:nx+2*nbc)     = 0.;
S(1+nbc:nz+nbc,1+nbc:nx+nbc) = 1./V;
for i = 1:nbc
   S(i,:)     = S(nbc+1,:) ;
   S(:,i)     = S(  :  ,nbc+1);
   S(end-(i-1),    :    )     = S(end-nbc,:) ;
   S(    :    ,end-(i-1))     = S(  :  ,end-nbc);
end

%--------------------------------------------------------
% Prepare TT and wavefront matrix

t0 = 0;
T(1:nz+4, 1:nx+4) = NaN;
twave(1:nz+4,1:nx+4) = -1;
twave(1:nbc,:) = 1; twave(end-(nbc-1):end,:) = 1;
twave(:,1:nbc) = 1; twave(:,end-(nbc-1):end) = 1;

%--------------------------------------------------------
% Source location (add absorving boundaries)

zsrc = zsrc+nbc*h+h;
xsrc = xsrc+nbc*h+h;
z0   = zsrc/h;
x0   = xsrc/h;
iz0   = round(z0);
ix0   = round(x0);
xloc = [iz0 ix0];

%--------------------------------------------------------
% Calculate travel time around source location

dist = sqrt(abs(iz0*h-zsrc)^2 + abs(ix0*h-xsrc)^2);
T(iz0,ix0) =  dist*(S(iz0,ix0));
mz = iz0;
mx = ix0;
m0 = T(iz0,ix0);

for i = 1:4
   znew = iz0 + zside(i);
   xnew = ix0 + xside(i);

   dist = sqrt(abs(znew*h-zsrc)^2 + abs(xnew*h-xsrc)^2);
   Tnew = dist*(S(iz0,ix0)+S(znew,xnew))/2;
   T(znew,xnew) = Tnew;

   [mz,mx,m0] = fd_add2sort(znew,xnew,Tnew,mz,mx,m0);
end
twave(mz(1),mx(1)) = 1;
mz = mz(2:end);
mx = mx(2:end);
m0 = m0(2:end);

%-------------------------------------------------
% Calculate travel time around point of interest

for k_m = 1:2*ngrid

   if (length(m0)==0) 
      break
   end

   %-------------------------------------------------
   % Calculate travel time around point of interest
   icnt = 0;
   for i = 1:4
      znew = mz(1) + zside(i);
      xnew = mx(1) + xside(i);

      if (twave(znew,xnew)==1) continue; end
      if (T(znew,xnew)>=0) continue; end

      S2 = S(znew-1:znew+1,xnew-1:xnew+1);
      T2 = T(znew-1:znew+1,xnew-1:xnew+1);
      S2 = reshape(S2,[1,9]);
      T2 = reshape(T2,[1,9]);

      Tnew         = fdtt_point(S2,T2,h);
      icnt = icnt + 1; 
      Tsave(:,icnt)   = [znew,xnew,Tnew]; 

      [mz,mx,m0] = fd_add2sort(znew,xnew,Tnew,mz,mx,m0);

   end

   %---------------------------------------------------------
   % Save travel time matrix & track wavefront

   for i = 1:icnt
      T(Tsave(1,i),Tsave(2,i)) = Tsave(3,i);
   end
   twave(mz(1),mx(1)) = 1;

   if (length(m0)==0) break; end

   mz = mz(2:end);
   mx = mx(2:end);
   m0 = m0(2:end);

   continue

   %-----------------------------------------------------
   % Display and plot
   if (mod(k_m,round(ngrid/20))==0)
      disp(['Loop ',num2str(k_m)])
   end
   if (mod(k_m,round(ngrid/10))==0)
      figure
      contour(T,[0:2:100])
      axis equal
   end

end

Tout = T(1+nbc:nz+nbc,1+nbc:nx+nbc);


