function atime = pred_atime(m0,params)

%
% PRED_ATIME
% 
% Code to predict arrival times for various 
% phases at multiple stations, using the 
% tt_table that should be a global variable.
%
% INPUT
% x	 - X source position
% y 	 - Y source position
% z	 - Depth of the source
% xsta	 - Station x location
% ysta	 - Station y location
% iphase - Phase ('P', or 'S')
%
% OUTPUT
% tau    - predicted travel times at all stations
%
%---------------------------------------------------

global tt_table

% Initial model parameters
x  = m0(1); 
y  = m0(2); 
z  = m0(3); 
t0 = m0(4);

% Station and Phases
xsta   = params.xsta; 
ysta   = params.ysta; 
iphase = params.iphase; 
nrec   = length(xsta);

% Calculate distance
x_d = sqrt((x-xsta).^2+(y-ysta).^2); 

tau(1:nrec,1)=0;
for k = 1:nrec
   tau(k,1) = read_tt_table(x_d(k),z,tt_table,iphase(k));
end 
atime = tau+t0;

return
