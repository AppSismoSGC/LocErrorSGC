function iout = synthetic_read %(run_file)
%
% Driver program to create synthetic dataset of 
% earthquake travel times. 
%
% Generates observed arrival times for earthquakes
% at given depths
%
%
% Velocity Model needs to be defined. 
% Station distributio needs to be defined.
% Earthquake locations TDB
%
%
% Right now, it is assumed this is a planar grid
% model, so planar location (not lat/lon) are used. 
%

close all
iout = -1;

%----------------------------------------------------------
% Reading Parameters

rfile = 'synthetic.pf';
disp('----- Running Synthetic Algorithm -----')
disp(['Parameter File    ',rfile])

%----------------------------------------------------------
% Reading Parameter File

[S,vcnt] = read_pf(rfile);
if (vcnt<6)
   error(['Parameter file: # of parameters ',num2str(vcnt)])
end

vcnt

vmod    = char(S(1));
sfile   = char(S(2));
efile   = char(S(3));
ofile   = char(S(4));
sig     = str2num(char(S(5)));
nrep    = str2num(char(S(6)));  % number of repeats with different random noise
% Depths
j = vcnt-7+1
for i = 1:j
   k = i+7-1;
   [i k]
   qdepths(i) = str2num(char(S(k)));
end
ndepth = length(qdepths);

disp(['Velocity Model    ',vmod])
disp(['Station File      ',sfile])
disp(['Event File        ',efile])
disp(['Output tt file    ',ofile])
disp(['Travel time sigma ',num2str(sig)])
disp(['# sources per pnt ',num2str(nrep)])
disp(['# depth layers    ',num2str(ndepth)])
disp(['Source Depths     ',num2str(qdepths)])
disp('')

[usta,xsta,ysta,esta]    = textread(sfile,'%s%f%f%f');

%----------------------------------------------------------
% Define Stations

[usta,ia] = unique(usta);
xsta  = xsta(ia);
ysta  = ysta(ia);
esta  = esta(ia);
nsta  = length(usta);

disp(['# of stations     ',num2str(nsta)])

%----------------------------------------------------------
% Load velocity model

global tt_table

ttravel = load(vmod);
tt_table = ttravel.tt;
clear ttravel

%----------------------------------------------------------
% Source locations, reading an X,Y file

evs = load(efile);

x    = evs(:,1);
y    = evs(:,2);
gcnt = length(x);

%----------------------------------------------------------
% Create predicted arrival time file

fid2 = fopen(ofile,'w+');
fid3 = fopen('real_loc.dat','w+');

%----------------------------------------------------------
% Compute all arrival times

evid  = 0;
for i0 = 1:ndepth
   for i = 1:gcnt
      qx    = x(i);
      qy    = y(i);
      qtime = 10.;
      qdep  = qdepths(i0);

      m0 = [qx qy qdep qtime]';

      clear params
      params.data   = zeros(nsta*2,1);
      params.sigma  = sig;
      params.nmod   = 4;
      params.xsta   = [xsta; xsta];
      params.ysta   = [ysta; ysta];
      params.selev  = [esta; esta];
      for k = 1:nsta
         params.iphase(k,1)       = {'P'};
         params.iphase(nsta+k,1) = {'S'};
      end
      params.nobs   = length(params.data);
      params.norm   = 1;
      params.h      = 1e-7;
      params.sta    = [usta; usta];

      if (isfield(params,'check')==0) 
         params = check_struct_cg(params);
      end
      if (params.check ~= 1)
         error('Error - CG_LOCATION Parameter Check')
      end

      atime = pred_atime(m0,params);

      %-------------------------------------
      % Create nrep realizations
      for k = 1:nrep
         otime = atime + randn(size(atime))*sig;
         evid = evid+1;
         fprintf(fid3,'%-8i %12.4f %12.4f %12.4f \n', ...
                      evid,qx,qy,qdep);
         % Write travel times file
         for j = 1:params.nobs
            fprintf(fid2,'%-8i %-5s %12.4f %-2s %10.3f\n', ...
                      evid,char(params.sta(j)),otime(j),...
                      char(params.iphase(j)),sig);   
         end
      end % end repeat points
   end    % end sources
end       % end depths

fclose(fid2);
fclose(fid3);

locs = load('real_loc.dat');

% Plot stations
figure
scatter3(locs(:,2),locs(:,3),-locs(:,4),[],locs(:,4),'o','filled')
hold on
scatter3(xsta,ysta,zeros(size(xsta)),[],'r','filled','^')
xlim([-50 50])
ylim([-50 50])
hold on
hold off

return





