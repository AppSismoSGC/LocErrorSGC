function Vmat = fd_vmod_create(z,V,dz,zmax,xmax)

%
% FD_VMOD_CREATE
%
% Create finite difference grid for a 1D layered
% model described by Z and VEL vectors. 
% As a default, a linear monotonic velocity between 
% the models layer boundaries is calculated. 
% 
% Call
% Vmat = fd_vmod_create(z,V,dz,zmax,xmax)
%
% INPUT
% z(nlay)     - Depth to top of layer
% V(nlay)     - Velocity of layer
% dz          - desired sampling of the velocity model
%               dz = dx. 
% zmax        - maximum depth of the FD grid
% xmax        - maximum horizontal distance of FD grid
%
% OUTPUT
% Vmat        - Matrix with FD grid, that can be used by 
%               finite-difference travel time calculator. 
%

%-----------------------------------------------------
% Define sizes and matrices. 

if (z(1) ~= 0)
   error('First layer must be at Z=0')
end

nlay = length(z);
nv   = length(V);

if (nlay~=nv)
   error('Sizes of V and z are not the same')
end

%-----------------------------------------------------
% Create the depth, and horizontal vectors
depth = [0:dz:zmax];
X     = [0:dz:xmax];
ndep  = length(depth);
nx    = length(X);

Vvec(1:ndep) = V(end);

%-----------------------------------------------------
% For 1D Constant model

if (nv == 1)
   Vmat(1:ndep,1:nx) = V;
   return
end

%-----------------------------------------------------
% Linear interpolation
for i = 1:nlay-1
   Z2          = [z(i) z(i+1)];
   Vel         = [V(i) V(i+1)];
   iloc        = find(depth>=z(i) & depth<=z(i+1));
   Vstep       = interp1(Z2,Vel,depth(iloc));
   Vvec(iloc)  = Vstep;
end

%-----------------------------------------------------
% Generate the replicate matrix

Vmat = repmat(Vvec',[1 nx]);

%-----------------------------------------------------
%plot staircase

icnt = 0;
for i = 1:length(z)-1
   icnt = icnt + 1;
   z2(icnt) = z(i);
   V2(icnt) = V(i);
   icnt = icnt + 1;
   z2(icnt) = z(i+1);
   V2(icnt) = V(i);
end
icnt = icnt + 1;
z2(icnt) = z(end);
V2(icnt) = V(end);
icnt = icnt + 1;
z2(icnt) = zmax;
V2(icnt) = V(end);


figure
plot(V2,z2)
hold on
plot(Vvec,depth,'r')
xlim([0 max(V)*1.2])
ylim([-1 max(z)*1.4]);
set(gca,'YDir','Reverse')
hold off

figure
imagesc(X,depth,Vmat)

