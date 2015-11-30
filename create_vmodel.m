
% 
% Test code to create a FD grid for the Colombia
% velocity model. 
%

clear
close all

%------------------------------------------------
% Read Parameter file (fd_vmod.pf)

[S,vcnt] = read_pf('fd_vmod.pf');
if (vcnt~=7)
   error(['Parameter file: # of parameters ',num2str(vcnt)])
end

vmod    = char(S(1));
vmod2   = [vmod];
dz      = str2num(char(S(2)));
zmax    = str2num(char(S(3)));
xmax    = str2num(char(S(4)));
zsrc1   = str2num(char(S(5)));
zsrc2   = str2num(char(S(6)));
zsrc3   = str2num(char(S(7)));
zsrc    = [zsrc1:zsrc2:zsrc3];

disp(['File to be saved ',vmod2])



%----------------------------------------------------------
% Velocity Model

vp_vs = 1.78;
z   = [0.00  4.00 25.00 32.00 40.00 100.00 200.00  ];
Vp  = [4.80  6.60  7.00  8.0   8.10   8.20   8.30  ];
Vs  = Vp/1.78;

%-----------------------------------------------
% Flattening Transformation

[zp_f,vp_f] = flatten_1d(z,Vp);
[zs_f,vs_f] = flatten_1d(z,Vs);

Vpmat = fd_vmod_create(zp_f,vp_f,dz,zmax,xmax);
Vsmat = fd_vmod_create(zs_f,vs_f,dz,zmax,xmax);

% Create P travel time curves

nz = length(zsrc);
tt.z = zsrc;
figure
for i = 1:nz

   [T,xpos,zpos] = fdtt_calculate(0,zsrc(i),Vpmat,dz);
   Ts            = fdtt_calculate(0,zsrc(i),Vsmat,dz);

   tt.x       = xpos(1:2:end);
   tt.t(:,i)  = T(1,1:2:end);
   tt.ts(:,i) = Ts(1,1:2:end);

%   if (mod(i,6)==0)
%      subplot(3,1,(i-1)/6+1)
%      imagesc(xpos,zpos,T)
%      axis equal
%      axis tight
%   end
end
%-------------------------------
% Add final info to structure

tt.zmod = z;
tt.Vp   = Vp;
tt.Vs   = Vs;
if (exist('rho')==1)
   tt.rho  = rho;
end

figure
plot(tt.x,tt.t,'r')
hold on
plot(tt.x,tt.ts,'b')
hold off

%-----------------------------
% Save file

save(vmod2,'tt')
