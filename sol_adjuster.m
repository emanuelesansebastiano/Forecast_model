function [ matrix_adjusted ] = sol_adjuster(matrix2adjust)
%------------------------------------------------------------------------%
%sol_adjuster - converts all the negative values of to zero.  
%
% Author, date:
%   -Emanuele Sansebastiano, December 2016
%........................................................................%
%
% Input data:
%   - matrix to adjust (matrix2adjust)        dim m x n
%
% Output:
%   - matrix adjusted                         dim m x n
%
%------------------------------------------------------------------------%

%% Function input control
%none input control

%% Algorithms and solution

m = size(matrix2adjust,1);
n = size(matrix2adjust,2);

matrix_adjusted = matrix2adjust;

for i = 1 : m
    for j = 1 : n
        if matrix2adjust(i,j) < 0
            matrix_adjusted(i,j) = 0;
        else
            matrix_adjusted(i,j) = matrix2adjust(i,j);
        end
    end
end
