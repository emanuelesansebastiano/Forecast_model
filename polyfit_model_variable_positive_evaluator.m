function [ solution ] = polyfit_model_variable_positive_evaluator(matrix_data, matrix_data_size, matrix_data_train, n_sol)
%------------------------------------------------------------------------%
%polyfit_model_variable_positive_evaluator - choose the polymonial function to fit every dataset 
% This function do not allowed stricly negative forecasts
% (minimum grade is equal to 1)
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
%   - Use the 'polyfit' function for every data set (variable grade)
%   - This compare all the possible grades automatically.
%   - The lower polynomial grade among the ones having the lowest MASE is choosen to compute the forecast
%
% Output:
%   - Best grade for every dataset
%   - Forecast solutions
%
%------------------------------------------------------------------------%

%% Function input control
size_data = size(matrix_data);
size_temp1 = size(matrix_data_size);
size_temp2 = size(matrix_data_train);
if (size_data(2) ~= size_temp1(2)) + (size_data(2) ~= size_temp2(2)) > 0
   error('Number of columns of the inputs do not match');
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
best_grade_4column = zeros(n_set_data,1);

% Every column has different size. So a different polynomial grade 
perc_print = 0;
for y = 1 : n_set_data
    
    % initialization
    definitive.grade = 0;
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
    clear temp_sequence_values train_sequence_values test_sequence_values train_sequence_time test_sequence_time
    temp_sequence_values = matrix_data(1:n_train_val,y);
    
    train_sequence_values = matrix_data(1:n_train_val,y);
    train_sequence_time = sequence_generator(n_train_val,1,1,'+')';
    
    test_sequence_values = matrix_data(n_train_val+1:n_data_val,y);
    test_sequence_time = sequence_generator(n_data_val-n_train_val,1,n_train_val+1,'+');
   
    % to avoid overdimensionated models'
    polymodel_max = 10;
    if n_train_val <= polymodel_max
        max_numb_model = n_train_val;
    else
        max_numb_model = polymodel_max;
    end
    % test all the possible grade to choose the best
    for n = 1 : max_numb_model
        clear grade_test
        grade_test = n;
        
        % model test
        clear P size_model_attemp
        P = polyfit(train_sequence_time, train_sequence_values, grade_test);
        %y(t) = P(q)x(t)
        size_model_attempt = size(P);
            
        % test complexity output/input
        if size_model_attempt(2) -1 ~= grade_test
            error('Something in the ''polyfit'' function went wrong at the iteration %d', y);
        end
       
        % generation of the solution for the single column to have MASE
        size_res_test = n_data_val - n_train_val;
        clear sol; sol = polyval(P, test_sequence_time);
%        sol = abs(sol);
        
        if  size(sol,2) ~= size_res_test
            error('The number of test forecast forecast solutions does not correspond to the expected one');
        end
        
        for j = 1 : size_res_test
            temp_sequence_values(n_train_val + j) = sol(j);
            temp_sol_matrix(j,y) = sol(j);
        end
       
        % MASE of a sigle set
        clear temp_eval
        temp_eval = model_eval(train_sequence_values(:), size_res_test, test_sequence_values(:), temp_sol_matrix(:,y)); 
        MASE_dataset = temp_eval.MASE;
        
         % to avoid negative solutions
         if find(find(sol < 0,1))
             MASE_dataset = Inf;
         end
            
        if MASE_dataset < definitive.MASE
            definitive.grade = grade_test;
            definitive.MASE = MASE_dataset;
        end
    end
    best_grade_4column(y) = definitive.grade;
end

% control to check there are no errors in the polynomial grade
if find(best_grade_4column == 0)
   error('Some of the dataset model has 0 as polynomial grade');
end

%-------------------------------------------------------------------------%
% solution: best complexity abs array
best_grade_array = best_grade_4column;
clear best_grade_4column

% solution: forecast generation
temp_sol_matrix = zeros(n_sol,n_set_data);
for y = 1 : n_set_data
    % for every loop a different sequence is considered
    clear n_dataset 
    n_dataset = matrix_data_size(y);
    
    % single sequence values initialization
    clear temp_sequence_values
    temp_sequence_values = matrix_data(1:n_dataset,y);
    whole_sequence_time = sequence_generator(n_dataset,1,1,'+')';
    grade = best_grade_array(y);
    
    % best model
    clear P size_model
    P = polyfit(whole_sequence_time, temp_sequence_values, grade);
    %y(t) = P(q)x(t)
    size_model = size(P);
        
    % test grade output/input
    if size_model(2) -1 ~= grade
        error('Something in the ''polyfit'' function went wrong at the iteration %d during the forecast generation', y);
    end
    
    % generation of the solution for the single dataset (column)
    solution_size = n_sol;
    solution_sequence_time = sequence_generator(solution_size,1,n_dataset+1,'+');
    clear sol; sol = polyval(P, solution_sequence_time);
    %sol = abs(sol);
    
    if size(sol,2) ~= solution_size
        error('The number of solution forecast solutions does not correspond to the expected one');
    end
            
    for j = 1 : solution_size
        temp_sequence_values(n_train_val + j) = sol(j);
        temp_sol_matrix(j,y) = sol(j);
    end 
end

%Adjust negative values to zero
forecast_matrix = sol_adjuster(temp_sol_matrix);
clear temp_sol_matrix

% solution structure definition
solution.best_grade_array = best_grade_array; 
solution.forecast_matrix = forecast_matrix;

end

