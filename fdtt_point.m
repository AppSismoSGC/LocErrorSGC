function [ttime] = fdtt_point(s,tt,h)

%
% Solve the finite difference travel time calculation 
% for a single point
%
% Input
% s  - slowness
% tt - travel time
%

ttime = NaN;
%--------------------------------------
% find of no travel time is available

if (all(tt)< 0)
   return
end

%----------------------------------------------
% Loop over all possible calculations

% 2D plane wave
d1(:,1) = [1 2 3 5];
d1(:,2) = [1 4 7 5];
d1(:,3) = [3 6 9 5];
d1(:,4) = [7 8 9 5];

d2(:,1) = [1 2 4 5];
d2(:,2) = [7 4 8 5];
d2(:,3) = [9 8 6 5];
d2(:,4) = [3 6 2 5];

tcnt = 0;

%tt
for i = 1:4
%4 %2:2:8   % loop over 4 sides
   i1 = i*2;
%   [i i1 tt(i1)]
%   disp('Here')

   % 1D case
   tcnt = tcnt + 1;
   t1   = tt(i1) + h*(s(i1)+s(5))/2;
   t_est(tcnt) = t1;
   % 3 point plane wave case
   tcnt = tcnt + 1;
   tloc = d1(:,i);
   savg = mean(s(tloc)); 
   t2 = tt(tloc(2)) + sqrt((h*savg)^2-0.25*(tt(tloc(3))-tt(tloc(1)))^2);
   t_est(tcnt) = t2;
   % 3 point triangle case
   tcnt = tcnt + 1;
   tloc = d2(:,i);
   savg = mean(s(tloc)); 
   t3 = tt(tloc(1)) + sqrt(2*(h*savg)^2-(tt(tloc(2))-tt(tloc(3)))^2);
   t_est(tcnt) = t3;

end
%t_est
ttime = min(t_est);

%d1

return

iloc = find(tt>=0);
nloc = length(iloc);

%--------------------------------------
% Find if only one point is available

if (nloc == 1)
   for i = 1:4 
      i1 = i*2;
      ttime(i1) = tt(i1) + h*(s(i1)+s(5))/2;
   end
   ttime = min(ttime);
   return
end

if (nloc == 2)
   for i = 2:2:8
      if (tt(i)>=0)
         ttime = tt(i) + h*(s(i)+s(5))/2;
         return
      end
   end
   return
end

display('No solve found')


