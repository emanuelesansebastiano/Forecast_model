function [ solution ] = ar_model_variable_evaluator(matrix_data, matrix_data_size, matrix_data_train, n_sol)
%------------------------------------------------------------------------%
%ar_model_variable_evaluator - choose the best complexity for every dataset 
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
%   - Use the AR -least square- for every data set (variable complexity)
%   - This function compare them automatically using the test set
%   - The lower complexity among the ones having the lowest MASE for every data set
%
% Output:
%   - Best complexity for every dataset   dim 1 x n_dataset
%   - Forecast solutions                  dim n_sol x n_dataset
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
best_complexity_4column = zeros(n_set_data,1);

% Every column has different size. So a different grade of complexity 
% Max complexity = half number of values,
% using the least square approach.
perc_print = 0;

for y = 1 : n_set_data
    
    % initialization
    definitive.complexity = 0;
    definitive.MASE = Inf;

    if y >= n_set_data*perc_print/10
        fprintf('Work in progress: %d%% done...\n', 100*perc_print/10);
        perc_print = perc_print +1;
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
   
    % I subtract 0.1 to avoid: 'round(17/2) = 9'
    max_numb_model = round((n_train_val -0.1)/2);
    % test all the possible complexity to choose the best
    for n = 1 : max_numb_model
        clear complexity_test
        complexity_test = n;
        
        % model test
        clear model_attempt size_model_attemp IDdata
        IDdata = iddata(temp_sequence_values,[],1);
        model_attempt = ar(IDdata, complexity_test,'ls');
        %A(q) y(t) = [B(q)/F(q)] u(t-nk) + [C(q)/D(q)] e(t)
        [A,B,C,D,E,F] = polydata(model_attempt);
        size_model_attempt = size(A);
            
        % test complexity output/input
        if size_model_attempt(2) -1 ~= complexity_test
            error('Something in the ''ar'' function went wrong at the iteration %d', y);
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
            definitive.complexity = complexity_test;
            definitive.MASE = MASE_dataset;
        end
    end
    best_complexity_4column(y) = definitive.complexity;
end

% control to check there are no errors in the complexity array
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
    clear temp_sequence_values
    temp_sequence_values = matrix_data(1:n_dataset,y);
    complexity = best_complexity_array(y);
    
    % best model
    clear model size_model IDdata
    IDdata = iddata(temp_sequence_values,[],1);
    model = ar(IDdata, complexity,'ls');
    %A(q) y(t) = [B(q)/F(q)] u(t-nk) + [C(q)/D(q)] e(t)
    [A,B,C,D,E,F] = polydata(model);
    size_model = size(A);
        
    % test complexity output/input
    if size_model(2) -1 ~= complexity
        error('Something in the ''ar'' function went wrong at the iteration %d during the forecast generation', y);
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

