function [znew,xnew,Tnew] = fd_add2sort(z,x,T,zold,xold,Told)

%
% FD_ADD2SORT
% 
% call
% [znew,xnew,Tnew] = fd_add2sort(z,x,T,zold,xold,Told)
%
% Reorganize vector Told in ascending order, and move the
% index zold,xold vectors accordingly.
% It simply adds a new value T, at positions z and x, into T 
%
% INPUTS
%    z     - integer position in matrix T(z,x)
%    x     - integer position in matrix T(z,x)
%    T     - travel time at point (x,z)
%    zold  - vector with previous values
%    xold  - vector with previous values
%    Told  - vector with previous values
%
% OUTPUTS
%    znew, xnew, Tnew
%	vectors with new values added in the right position
%

nt = length(Told);
if (T>Told(nt))
   znew =  [zold z];
   xnew =  [xold x];
   Tnew =  [Told T];
   return
else
   for j = nt-1:-1:1
      if (T>Told(j))
         znew = [zold(1:j) z zold(j+1:nt)];
         xnew = [xold(1:j) x xold(j+1:nt)];
         Tnew = [Told(1:j) T Told(j+1:nt)];
         break
      end
   end
end

return

