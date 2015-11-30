function [mhat,rnorm,res,bf_loop,bf_stop] = bfgs_solve(fun,params_in,m0);

%
% Use conjugate gradients to find best solution for an 
% optimization problem, whether it is linear or nonlinear. 
%
% The code is a general Conjugate Gradient algorithm, that 
% uses a simple call to a user-defined function to calculate
% the residual norm (L1,L2) and the gradient.
%
% This way, a single CG algorithm will be used. 
%
% To allow for ANY user-defined function, the code uses a
% PARAMS structure, which contains all the variables 
% needed to calculate the misfit function. 
% 
% PARAMS Structure Values
%
% REQUIRED:
% PARAMS.data   - The data vector
% PARAMS.sigma  - Standard deviation of observed data points
%                 sigma HAS to be defined.  
%                 It can be a vector, or a single number, code
%                 will generate the vector (if needed). 
% PARAMS.nmod   - Number of model parameters
%
% OPTIONAL
% PARAMS.nobs	- Number of observed data points
% PARAMS.norm   - Norm to use (L1, L2)
% PARAMS.check  - Check validity of PARAMS structure. 
% PARAMS.h      - step size for gradient calculations (h=1e-7)
%
%--------------------------------------------------------------------
% Predefined Variables
%
% iter		maximum number of iterations (1000).
% eps		relative norm stopping criteria
%
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% Algorithm Explained
%
%
% Using the conjugate gradient method.
% First Loop
% 	a) Define initial model m1
% 	b) Calculate step direction dm1 with negative gradient
%	c) Define s1, step to take as s1 = dm1
%	d) Using line search, define alpha = argmin(f(m1+alpha*dm1))
%	e) Generate new model mnew = m1 + alpha*s1
%
% Generate copy of results for next iteration
%	s0  = s1
%	m1  = mnew
%	dm0 = dm1
%
% Rest of Loops
% 	a) Initial model m1, from previous iteration
% 	b) Calculate step direction dm1 with negative gradient
%	c) Calculate beta, using FR, PR methods
%       d) Define step to take as s1 = dm1 + beta*s0
%	e) Using line search, define alpha = argmin(f(m1+alpha*dm1))
%	f) Generate new model mnew = m1 + alpha*s1
%
% Some criteria used
% 	beta: If beta<0, set to beta=0 (reset to steepest descent)
%	No automatic reset specified. 
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
%
%&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
% German A. Prieto
% EAPS, MIT
% February 18, 2015
%&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&



%--------------------------------------------------
% Read PARAMS data structure and validate
%--------------------------------------------------
params = params_in;
if (isfield(params,'check')==0) 
   params = check_struct_cg(params);
end
if (params.check ~= 1)
   error('Error - BFGS_SOLVE Parameter Check')
end

%--------------------------------------------------
% Basic parameters
% iter - max number of CG iterations
% h    - step size for gradient
% eps  - stopping criteria
%--------------------------------------------------

iter  = 100*params.nobs;
h     = params.h;
eps   = 1e-11; 


%--------------------------------------------------
% Define Tolerance, depending on 1-norm, 2-norm
%
% Equation 3.21, 3.22, 3.26, 3.47 in Parker
% Assumes sum of squared residuals is normalized 
% by std
%--------------------------------------------------

tol = (1.0 - 1/(4*params.nobs) + 1/(32*params.nobs^2));
tol = tol*sqrt(params.nobs);
tol = tol/2;
if (params.norm == 1)
   tol = params.nobs*sqrt(2/pi);
   tol = tol/4;
end  

%---------------------------
ndata = params.nobs;
nmod  = length(m0);

rnorm  = 0;
mhat   = m0;
m1     = m0;
mnew   = m1;
dm0    = m1*0;

%----------------------------------------------------------------
% Start CG loops
%----------------------------------------------------------------

I     = eye(nmod);
H0    = I;
invH0 = I;

inew    = 0;
bf_stop = 'loop';
for bf_loop = 1:iter

   %-----------------------------------------------------
   % Gradient of misfit function
   %-----------------------------------------------------


   [rnorm1,grad1] = fgradient(fun,m1,params);
   dm1 = grad1;

   if (bf_loop == 1 | inew == 1)
      dx    = -invH0*dm1;
   else
      Y     = dm1-dm0;
      Yt    = Y';
      S     = m1- m0;
      St    = S';
      yts   = Y'*S;
      if (yts<=0) 
         invH0 = I;
         dx    = -invH0*dm1;
      else
         invH1 = (I-(S*Yt)/yts)*invH0*(I-(Y*St)/yts) + (S*St)/yts;
         dx    = -invH1*dm1;
         invH0 = invH1;
      end
   end

   %-----------------------------------------------------
   % Gradient is zero?
   %-----------------------------------------------------
   if (norm(dx) == 0)
      bf_stop = 'norm of grad';
      break
   end
 
   %-----------------------------------------------------
   % Perform line search for argmin(f(m1 +alpha*dx ))
   %-----------------------------------------------------

   alpha = line_search(fun,params,m1,dx);
   % If step is too small, refresh BFGS
   if (alpha <1e-13 & inew < 2)
      m1     = m1;
      m0     = m0*0;
      dm0    = m0*0;
      invH0  = I;
      inew   = inew + 1;
      mgrid(:,bf_loop) = m1;
      rnorm(bf_loop)   = fgradient(fun,m1,params);
      continue
   end
%   for ialpha = 1:1
%      if (alpha<1e-11)
%         disp('what?')
%         alpha
%         dx  = dx*1e-5
%         alpha = line_search(fun,params,m1,dx);
%      elseif (alpha>=5)
%         disp('what 2?')
%         dx  = dx*1e2;
%         alpha = line_search(fun,params,m1,dx);
%      else
%         break
%      end
%   end
   dm = alpha.*dx;
 
   %-----------------------------------------------------
   % Get next model, check for stop criteria
   %-----------------------------------------------------

   mnew = m1 + dm;

   mgrid(:,bf_loop) = mnew;
   rnorm(bf_loop)   = fgradient(fun,mnew,params);

   if (rnorm(bf_loop) <= tol) % Pass tolerance
      bf_stop = 'Tolerance';
      break
   end
   if (bf_loop>1)
      %----------------------------------------------------
      % dm too small, no more improvement
      if (norm(m1-m0)<eps)
         bf_stop = 'dm too small';
         break
      end
   end

   %-----------------------------------------------------
   % Prepare data for next loop
   %-----------------------------------------------------

   m0     = m1;
   m1     = mnew;
   dm0    = dm1;

end

%-----------------------------------------------------
% Final model for CG iterations
%-----------------------------------------------------

rgrid  = rnorm;

mhat   = mnew;
rnorm  = fgradient(fun,mhat,params);
if (nargout>=3)
   [rnorm,res] = fmisfit(fun,mhat,params);
end


% Plot scatter results
scatter(mgrid(1,:),-mgrid(2,:),[],rgrid,'o','filled')
return




