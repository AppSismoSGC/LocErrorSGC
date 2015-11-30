function alpha = line_search(fun,params,m1,p2)

%-----------------------------------------------------
% Perform line search for argmin(f(m1 +alpha*p2 ))
%-----------------------------------------------------
%
%  Perform a line search for a minima, using a golden
%  search algorithm. 
%
%  alpha - line_search(fun,params,m1,p2)
%  INPUT
%    fun    - External function, predicted values
%    params - Structure with parameters needed
%    m1     - Initial model
%    p2     - Step direction to take.  
%  OUTPUT
%    alpha  - Step size to take in direction p2
%
%
%  The stopping criteria is based on the size of the 
%  region of interest, using tolerance defined in the
%  code. 
%  Alpha values can range from alpha = [1e-11, 5], and
%  the calling routine ought to check whether the 
%  limits are reached and scale the problem. 
%  This is important in particular for CG methods, which 
%  have the problem of a poor scaling of the step size
%  that ought to be taken. BFGS methods suffer less. 
%
% CALLS:
% fgradient 	function to calculate the misfit
% 		between observed and predicted data
%


%----------------------------------------------------
% Search alpha using a Grid Walk
%-----------------------------------------------------

tol = 0.00001;

[rnorm0,grad0]   = fgradient(fun,m1,params);

xmin   =  0.0;
xmax   =  5.0;
xstep  =  5.0;

%---------------------------------------------------------------------
% Golden search algorithm

phi = (-1 +sqrt(5))/2;

alp(1)  = 1e-15; %0.0;
malpha  = m1 + alp(1) * p2;
f(1)    = fgradient(fun,malpha,params);
rnorm0  = f(1);

for i = 1:50
   alp(2)  = xstep;
   malpha  = m1 + alp(2) * p2;
   f(2)    = fgradient(fun,malpha,params);

   % Check that values do not exceed function threshold
   if (f(2)>5*f(1))
      xstep = xstep/2;
      continue
   else
      break
   end
end

alp(3)  =  alp(2) + phi*(alp(1)-alp(2));
malpha  = m1 + alp(3) * p2;
f(3)    = fgradient(fun,malpha,params);

alp(4)  = alp(1) + phi*(alp(2)-alp(1));
malpha  = m1 + alp(4) * p2;
f(4)    = fgradient(fun,malpha,params);

for igold = 1:40

   if (f(3)<f(4)) 
      alp(2)  = alp(4);
      f(2)    = f(4);
      alp(4)  = alp(3);
      f(4)    = f(3);
      alp(3)  =  alp(2) + phi*(alp(1)-alp(2));
      malpha  = m1 + alp(3) * p2;
      f(3)    = fgradient(fun,malpha,params);
   else
      alp(1)  = alp(3);
      f(1)    = f(3);
      alp(3)  = alp(4);
      f(3)    = f(4);
      alp(4)  =  alp(1) + phi*(alp(2)-alp(1));
      malpha  = m1 + alp(4) * p2;
      f(4)    = fgradient(fun,malpha,params);
   end

   sc1 = abs(f(3)-f(1));
   sc2 = tol*(abs(f(2))+abs(alp(4)));

   % First tries can be out of bounds, avoid stoping here
   if (igold < 8) continue; end

   % Stop criteria
   if (sc1<sc2) 
      break
   end
   
end

[rnorm,i] = min(f);
alpha = alp(i);

return


