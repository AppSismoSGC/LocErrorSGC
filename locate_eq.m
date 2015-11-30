function iout = locate_eq(run_file)

%
% Running algorithm for a Conjugate Gradient or
% BFGS location algorithm. 
% It reads the appropriate RUN_FILE in the working 
% folder and locates all events in the database. 
%
% INPUT
% RUN_FILE - points to the name of the running file
%            (default: run_cgloc.dat)
%

iout = -1;

if (nargin<1)
   rfile = 'locate.pf';
else
   rfile = run_file;
end

disp('----- Running Location Algorithm -----')
disp(['Parameter File    ',rfile])

%----------------------------------------------------------
% Read Running file


% FGETS approach
fid = fopen(rfile,'r');
tline = fgets(fid);
tlcnt = 0;
while ischar(tline)
    if (tline(1)~='#')
       tlcnt = tlcnt + 1;
       C = strsplit(tline);
       S(tlcnt) = C(1);
    end
    if (tlcnt >=5) break; end
    tline = fgets(fid);
end
fclose(fid);

if (tlcnt ~=5)
   error('Reading RUNNING File problem')
end

%----------------------------------------------------------
% Reading Parameter File

[S,vcnt] = read_pf(rfile);
if (vcnt~=5)
   error(['Parameter file: # of parameters ',num2str(vcnt)])
end

vmod    = char(S(1));
sfile   = char(S(2));
efile   = char(S(3));
locfile = char(S(4));
Lnorm   = str2num(char(S(5)));
stfile  = ['res_',locfile]; 

disp(['Velocity Model    ',vmod])
disp(['Station File      ',sfile])
disp(['Arrival Time file ',efile])
disp(['Location file     ',locfile])
disp('')
disp(['Using the         ','L',num2str(Lnorm),'-Norm'])
 
[usta,sta_x,sta_y,sta_elev]    = textread(sfile,'%s%f%f%f');
[evid,sta,atime,iphase,sig]    = textread(efile,'%u%s%f%s%f');

%----------------------------------------------------------
% Define Stations

[usta,ia] = unique(usta);
sta_x  = sta_x(ia);
sta_y  = sta_y(ia);
sta_elev = sta_elev(ia);
nsta  = length(usta);

disp(['# of stations     ',num2str(nsta)])

narr  = length(atime);
ista(1:narr,1)  = -1;
xsta(1:narr,1)  = -1;
ysta(1:narr,1)  = -1;
selev(1:narr,1) = -1;
for i = 1:nsta
   iloc = find(strcmp(usta(i),sta)==1);
   if (length(iloc)==0) continue; end
   ista(iloc,1)  = i;
   xsta(iloc,1)  = sta_x(i);
   ysta(iloc,1)  = sta_y(i);
   selev(iloc,1) = sta_elev(i);
end
jloc    = find(ista>0);
ista    = ista(jloc);
xsta    = xsta(jloc);
ysta    = ysta(jloc);
selev   = selev(jloc);
evid    = evid(jloc);
atime   = atime(jloc);
iphase  = iphase(jloc);
sta     = sta(jloc);
sig     = sig(jloc);

clear iloc jloc ia C S tlcnt tline  
clear sfile rfile efile i fid

%----------------------------------------------------------
% Load velocity model

global tt_table

ttravel = load(vmod);
tt_table = ttravel.tt;
clear ttravel

%----------------------------------------------------------
% Locate events

uev   = unique(evid);
nevid = length(uev);

disp(['# of events       ',num2str(nevid)])

fid  = fopen(locfile,'w');
fid2 = fopen(stfile,'w');
tic
for i = 1:nevid

   iloc = find(evid==uev(i));
   if (length(iloc)<3) continue; end

   if (mod(i,floor(nevid/100))==0)
      disp(['Percentage done ',num2str(i/nevid*100,'%5.1f'),'% '])
   end
%----------------------------------------------------------
% Put everything in Location Structure
%----------------------------------------------------------

   clear eq_loc
   eq_loc.evid   = uev(i);
   eq_loc.iphase = iphase(iloc);
   eq_loc.atime  = atime(iloc);
   eq_loc.sigma  = sig(iloc);
%0.1*ones(size(eq_loc.atime));
   eq_loc.selev  = selev(iloc);
   eq_loc.ysta   = ysta(iloc);
   eq_loc.xsta   = xsta(iloc);
   eq_loc.sta    = sta(iloc);
   eq_loc.norm   = Lnorm;
   eq_loc.h      = 1e-7;
   sigma         = eq_loc.sigma;

%----------------------------------------------------------
% Locate the Events
%----------------------------------------------------------

%tic
   [qx1,qy1,qdep1,qtime1,rnorm] = ...
          prel_grid_location_xy(tt_table,eq_loc);


%qx1 = 0; qy1 = 0; qdep1 = 5; qtime1 = 10.;


%toc
   %-------------------------------------------------------
   % NA location
  
%   [qx,qy,qdep,qtime,rnorm] =  ...
%      na_location_xy(@pred_atime,eq_loc, ...
%      qx1,qy1,qdep1,qtime1);
%
%   [qx qy qdep]

   %-------------------------------------------------------
   % BFGS location
%tic
   [qx,qy,qdep,qtime,rnorm,res] =  ...
      bfgs_location_xy(@pred_atime,eq_loc, ...
      qx1,qy1,qdep1,qtime1);
%toc

disp(['Grid location ',num2str(qx1,'%10.2f'),' ',num2str(qy1,'%10.2f'), ...
              ' ',num2str(qdep1,'%10.2f')])
disp(['BFGS location ',num2str(qx,'%10.2f'),' ',num2str(qy,'%10.2f'), ...
              ' ',num2str(qdep,'%10.2f')])

   %-------------------------------------------------------
   % CG location
%tic   
%   [qx,qy,qdep,qtime,rnorm,res] =  ...
%      cg_location_xy(@pred_atime,eq_loc, ...
%      qx1,qy1,qdep1,qtime1);
%toc
   %-------------------------------------------------------
   % Re-weight large outliears (5*sigma) 

   std_accept = 3;
   clear wt
   for i = 1:length(res)
      if (res(i)<5)
         wt(i,1) = 1.; %/max(std_accept,res(i));
      else
         wt(i,1) = 0.0001;
      end
   end
   eq_loc.sigma = eq_loc.sigma./wt;

   %-------------------------------------------------------
   % CG location
%   [qx,qy,qdep,qtime,rnorm,res] =  ...
%      cg_location_xy(@pred_atime,eq_loc, ...
%      qx0,qy0,qdep0,qtime0);

%   [qx0 qy0 qdep0 rnorm0 ; qx qy qdep rnorm]

%----------------------------------------------------------
% Save to Location file
%----------------------------------------------------------

   fprintf(fid,'%-8i %12.4f %12.4f %12.4f %18.4f %9.3f \n',...
           eq_loc.evid,qx,qy,qdep,qtime,rnorm);

   for k = 1:length(eq_loc.sta)
      fprintf(fid2,'%-8i %-5s %-2s %12.4f %12.4f %12.5f %12.5f \n', ...
              eq_loc.evid, char(eq_loc.sta(k)),char(eq_loc.iphase(k)), ...
              sigma(k),res(k),wt(k),res(k)*eq_loc.sigma(k));
   end


end
fclose(fid);
fclose(fid2);

toc

iout = 0;

return

