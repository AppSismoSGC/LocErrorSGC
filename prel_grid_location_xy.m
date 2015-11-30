function [qx,qy,qdep,qtime,rnorm] = ...
          prel_grid_location_xy(ttravel,eq_loc)

%
% PREL_GRID_LOCATION
%
% Preliminary EQ location based on a simple 
% grid walk search to find an initial location for
% CG location after. 
% It is assumed that all phases are associated 
% to a single event.
% This code does the location in the XY planar 
% coordinate system. 
%

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

nrec = length(atime);

%-------------------------------------------
% Create Station ID and lat/lon

[sta1,ia,ic] = unique(sta);
xsta1    = xsta(ia);
ysta1    = ysta(ia);
selev1   = selev(ia);
ista     = ic;

%-------------------------------------------
% Quick Grid search location
% First step with broad sampling,
% second with smaller sampling
%

zmin   = 1;
zmax   = max(ttravel.z);

xmax   =  50;
xmin   = -50;

zstep  = 5;
xstep  = 10;

xhat = 0; yhat = 0; zhat = 5;

rbest = 1e15;
for iwalk = 1:1000

   if (xstep<2) break; end
   xgrid = [xhat xhat+xstep xhat-xstep ...
                 xhat       xhat       ...
                 xhat xhat];
   ygrid = [yhat yhat       yhat       ...
                 yhat+xstep yhat-xstep ...
                 yhat yhat]; 
   zgrid = [zhat zhat       zhat       ...
                 zhat       zhat       ...
                 zhat+zstep zhat-zstep ];

   iloc = find(xgrid>=xmin & xgrid<=xmax & ...
               ygrid>=xmin & ygrid<=xmax & ...
               zgrid>=zmin & zgrid<=zmax  ); 
   xgrid = xgrid(iloc);
   ygrid = ygrid(iloc);
   zgrid = zgrid(iloc);

%   [xgrid' ygrid' zgrid']

   clear rnorm

   for igrid = 1:length(zgrid)
      depth = zgrid(igrid);
      hdist = sqrt((xgrid(igrid)-xsta).^2+(ygrid(igrid)-ysta).^2); 

      clear tau resid
      kcnt = 0;
      for k = 1:nrec  
         ttau = read_tt_table(hdist(k),depth,ttravel,iphase(k));
         if (isnan(ttau)==1) continue; end
         kcnt = kcnt + 1;
         tau(kcnt)   = ttau;
         resid(kcnt) = atime(k)-tau(kcnt);
      end
      if (kcnt == 0) 
         rnorm(igrid) = 1e15;
         continue; 
      end
      torig(igrid) = mean(resid);
      resid        = resid-torig(igrid); % remove origin time
      %rnorm = sum(abs(resid).^2); 
      rnorm(igrid) = sum(abs(resid)); 
   end

   %---------------------------------
   % Save the best location point

   [rbest,ibest] = min(rnorm);
   if (ibest==1)
      zstep = zstep/1.5;
      xstep = xstep/2;
      xhat  = xgrid(ibest);
      yhat  = ygrid(ibest);
      zhat  = zgrid(ibest);
      that  = torig(ibest);
   else
      xhat  = xgrid(ibest);
      yhat  = ygrid(ibest);
      zhat  = zgrid(ibest);
      that  = torig(ibest);
   end

end

qx    = xhat;
qy    = yhat;
qdep  = zhat;
qtime = that;
rnorm = rbest;

return



