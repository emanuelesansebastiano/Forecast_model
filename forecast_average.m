function [ solution_set ] = forecast_average(matrix_data, matrix_data_size, n_forecast)
%------------------------------------------------------------------------%
%forecast_average - forecast model
%
% Author, date:
%   -Emanuele Sansebastiano, December 2016
%........................................................................%
%
% Input data:
%   - matrix to train the model (matrix_data)
%      Every column is a traning set indipendent by the others
%   - array telling the size of each column (matrix_data_size)
%      Training set dimension (column dimension) is not always the same 
%   - number of forecast values required (n_forecast)
%      
% Algorithm:
%   - Use the average of all the value present in the data set
%
%------------------------------------------------------------------------%

%% Function input control
size_data = size(matrix_data);
size_temp = size(matrix_data_size);
if size_data(2) ~= size_temp
   error('Number of columns of the dataset and lenght of the array is different');
end

%% Algorithms and solution
solution_set = zeros(n_forecast,size_data(2));

for y1 = 1 : size_data(2)
    temp_sum = 0;
    for y2 = 1 : matrix_data_size(y1)
        temp_sum = temp_sum + matrix_data(y2,y1); 
    end
    temp_aver = temp_sum/matrix_data_size(y1);
    
    for y2 = 1 : n_forecast
        solution_set(y2,y1) = temp_aver; 
    end
end

%Adjust negative values to zero
solution_set = sol_adjuster(solution_set);

end

