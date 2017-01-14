function [ solution ] = arma_model_variable_evaluator(matrix_data, matrix_data_size, matrix_data_train, n_sol)
%------------------------------------------------------------------------%
%arma_model_variable_evaluator - choose the best complexity for every dataset 
%(minimum complexity is equal to 1)
%
% Author, date:
%   -Emanuele Sansebastiano, December 2016
%........................................................................%
%
% Input data:
%   - matrix to train and test the model (matrix_data)
%      Every column is a traning set indipendent by the others
%   - array telling the size of each column (matrix_data_size)
%      Set dimension (column dimension) is not always the same 
%   - array telling the size of each column to train the model (matrix_data_train)
%      Training set dimension (column dimension) is not always the same
%   - number of forecast required (n_sol)
%      
% Algorithm:
%   - Use the ARMA for every data set (variable complexity)
%   - This function compare them automatically using the test set
%   - The lower complexity among the ones having the lowest MASE for every data set
%
% Output:
%   - Best complexity for every dataset [na nb]   dim 2 x n_dataset
%   - Forecast solutions                          dim n_sol x n_dataset
%
%------------------------------------------------------------------------%

%% Function input control
size_data = size(matrix_data);
size_temp1 = size(matrix_data_size);
size_temp2 = size(matrix_data_train);
if (size_data(2) ~= size_temp1(2)) + (size_data(2) ~= size_temp2(2)) > 0
   error('Number of columns of the inputs does not match');
end
for y = 1 : size_data(2)
    if matrix_data_size(1,y) < matrix_data_train(1,y)
        error('The number of values used to train the model must be less the whole amount of data, check the column %d', y );
    end
end
n_set_data = size_data(2); 
clear y size_temp1 size_temp2 size_data


%% Algorithms and solution

% initialization
best_complexity_4column = zeros(2,n_set_data);

% max complexity according to the data dimension; armax function cannot be 
%used to evaluate datast containing less than 5 values
max_comp = [1 5;2 8;3 13]; %;4 17;5 21];

% Every column has different size. So a different grade of complexity 
% Max complexity = half number of values,
% using the least square approach.
perc_print = 0;

for y = 1 : n_set_data
    
    % initialization
    definitive.complexity = [0 0];
    definitive.MASE = Inf;

    if y >= n_set_data*perc_print/10
        fprintf('Work in progress: %d%% done...\n', 100*perc_print/10);
        perc_print = perc_print +0.5;
    end
    
    % for every loop a different sequence is considered
    clear n_train_val n_data_val 
    n_train_val = matrix_data_train(y);
    n_data_val = matrix_data_size(y);
    
    % single sequence values initialization
    clear temp_sequence_values train_sequence_values test_sequence_values
    temp_sequence_values = matrix_data(1:n_train_val,y);
    train_sequence_values = matrix_data(1:n_train_val,y);
    test_sequence_values = matrix_data(n_train_val+1:n_data_val,y);
    
    % max possivle complexity according to the dataset
    if n_train_val <= 4
        error('The ''armax'' function cannot accept a dataset having less than 5 values (iteration number %d)', y);
    end
    clear max_numb_model
    if n_train_val >= max_comp(size(max_comp,1),2)
        max_numb_model = max_comp(size(max_comp,1),1);
    else
        for j = 1 : size(max_comp,1)
            if n_train_val < max_comp(j,2)
                max_numb_model = max_comp(j-1,1);
                break;
            end
        end
        clear j
    end
    % test all the possible na and nc complexity to choose the best
    for na = 1 : max_numb_model
        for nc = 1 : max_numb_model
            clear na_nc_test
            na_nc_test = [na nc];
            
            % model test
            clear model_attempt size_model_attemp IDdata
            IDdata = iddata(temp_sequence_values,[],1);
            model_attempt = armax(IDdata, na_nc_test);
            %A(q) y(t) = [B(q)/F(q)] u(t-nk) + [C(q)/D(q)] e(t)
            [A,B,C,D,E,F] = polydata(model_attempt);
            size_model_attempt_A = size(A);
            size_model_attempt_C = size(C);

            % test complexity output/input
            if size_model_attempt_A(2) -1 ~= na_nc_test(1) || size_model_attempt_C(2) -1 ~= na_nc_test(2)
                error('Something in the ''armax'' function went wrong at the iteration %d', y);
            end

            % generation of the solution for the single column to have MASE
            clear size_res_test soluz 
            size_res_test = n_data_val - n_train_val;
            soluz = forecast(model_attempt,IDdata,size_res_test);
            for j = 1 : size_res_test
                temp_sequence_values(n_train_val + j) = soluz.OutputData(j);
                temp_sol_matrix(j,y) = soluz.OutputData(j);
            end

            % MASE of a sigle set
            clear temp_eval
            temp_eval = model_eval(train_sequence_values(:), size_res_test, test_sequence_values(:), temp_sol_matrix(:,y)); 
            MASE_dataset = temp_eval.MASE;
            if MASE_dataset < definitive.MASE
                definitive.complexity = na_nc_test;
                definitive.MASE = MASE_dataset;
            end
        end
    end
    best_complexity_4column(:,y) = definitive.complexity';
end

% control to check there are no errors in the complexity matrix
if find(best_complexity_4column == 0)
   error('Some of the dataset model has 0 as complexity');
end

%-------------------------------------------------------------------------%
% solution: best complexity abs array
best_complexity_array = best_complexity_4column;
clear best_complexity_4column

% solution: forecast generation
clear temp_sol_matrix;
temp_sol_matrix = zeros(n_sol,n_set_data);
for y = 1 : n_set_data
    % for every loop a different sequence is considered
    clear n_dataset 
    n_dataset = matrix_data_size(y);
    
    % single sequence values initialization
    clear temp_sequence_values na_nc_test
    temp_sequence_values = matrix_data(1:n_dataset,y);
    na_nc_complexity = best_complexity_array(:,y)';
    
    % best model
    clear model size_model IDdata
    IDdata = iddata(temp_sequence_values,[],1);
    model = armax(IDdata, na_nc_complexity);
    %A(q) y(t) = [B(q)/F(q)] u(t-nk) + [C(q)/D(q)] e(t)
    [A,B,C,D,E,F] = polydata(model);
    size_model_A = size(A);
    size_model_C = size(C);
        
    % test complexity output/input
    if size_model_A(2) -1 ~= na_nc_complexity(1) || size_model_C(2) -1 ~= na_nc_complexity(2)
        error('Something in the ''armax'' function went wrong at the iteration %d during the forecast generation', y);
    end
    
    % generation of the solution for the single dataset (column)
    clear solution_size soluz
    solution_size = n_sol;
    soluz = forecast(model,IDdata,solution_size);
    for j = 1 : solution_size
        temp_sequence_values(n_dataset + j) = soluz.OutputData(j);
        temp_sol_matrix(j,y) = soluz.OutputData(j);
    end
    
end
forecast_matrix = temp_sol_matrix;
clear temp_sol_matrix

% solution structure definition
solution.best_complexity_array = best_complexity_array; 
solution.forecast_matrix = forecast_matrix;

end

