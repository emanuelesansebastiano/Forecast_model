function [ integral ] = descrete_integral(array2integrate, gap_val)
%------------------------------------------------------------------------%
%descrete_integral - integral function
%
% Author, date:
%   -Emanuele Sansebastiano, December 2016
%........................................................................%
%
% Input data:
%   - array to be integrate (array2integrate)
%   - gap between each value [must be constant] (gap_val)
%      
% Algorithm:
%   - Quadrature rules based on interpolating functions
%      int = sum(gap*(f(b)-f(a))
%
%------------------------------------------------------------------------%

%% Function input control
size_integral = size(array2integrate);
size_gap = size(gap_val);
if (find(find((size_integral) ~= 1),1)) + (find(find((size_integral) == 1),1)) ~= 2
   error('The input array must contain at least 2 numbers and being an array to be integrated');
end
if find(size_gap ~= 1)
    error('The second input of this function must be an integer');
end

clear size_gap

%% Algorithms and solution

temp = find(((size_integral) > 1),1);
n_val = size_integral(temp);
integral = 0;
for y = 1 : n_val-1
    integral = integral + gap_val * (array2integrate(y) + array2integrate(y+1))/2;  
end

end

