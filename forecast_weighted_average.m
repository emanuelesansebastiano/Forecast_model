function [ solution_set ] = forecast_weighted_average(matrix_data, matrix_data_size, n_forecast)
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
%   - Use the average of all the value in the data set weighting them
%   according to a 'linear' or a 'quadratic' function
%
%------------------------------------------------------------------------%

%% Function input control
size_data = size(matrix_data);
size_temp = size(matrix_data_size);
if size_data(2) ~= size_temp
   error('Number of columns of the dataset and lenght of the array is different');
end
clear size_temp

%% Algorithms and solution
solution_set = zeros(n_forecast,size_data(2));

%weight data definition
horizon = round(sum(matrix_data_size)/size_data(2));
weight_first = 97;
weight_last = 10;
weight_val = weight_func('quadratic', weight_first, weight_last, horizon);

for y1 = 1 : size_data(2)
    temp_matrix_data_array = matrix_data(1:matrix_data_size(y1),y1);
    for y2 = 1 : n_forecast
        shift = y2-1;
        temp_sum = 0;
        y3_max = min([matrix_data_size(y1) horizon]);
        for y3 = 1 : y3_max
            y3_temp = y3_max+1 -y3;
            temp_sum = temp_sum + temp_matrix_data_array(y3_temp+shift)*weight_val(y3_temp); 
        end
        temp_weight_sum = sum(weight_val(1:y3_max));
        temp_aver = temp_sum/temp_weight_sum;
        temp_matrix_data_array(y3_max+1 +shift) = temp_aver;
        
        solution_set(y2,y1) = temp_aver; 
    end
end

%Adjust negative values to zero
solution_set = sol_adjuster(solution_set);

end

