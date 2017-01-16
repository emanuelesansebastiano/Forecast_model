function [ solution ] = ar_model_perc_evaluator(matrix_data, matrix_data_size, matrix_data_train, n_sol)
%------------------------------------------------------------------------%
%ar_model_perc_evaluator - choose the best complexity percentage 
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
%   - Use the AR -least square- model trying 10 possible grades of complexity
%   - This function compare them automatically using the test set
%   - The lower percentage complexity among the ones having the lowest MASE
%
% Output:
%   - Best percentage complexity                   dim 1 x n_dataset
%   - Best absolute complexity for every column    dim 1 x n_dataset
%   - Forecast solutions                           dim n_sol x n_dataset
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
definitive.complexity_perc = 0;
definitive.MASE_int = Inf;

% 'n' is the tested complexity of the model in percentage
% Every column has different size. Max complexity = half number of values,
% using the least square approach.
max_n = 5;
for n = 1 : 0.5 : max_n
    fprintf('Model complexity percentage = %d%% is working...\nMax percentage analized: %d%%\n', n*10, max_n*10);
    
    MASE_vector = zeros(1,n_set_data);
    for y = 1 : n_set_data
        
        % for every loop a different sequence is considered
        clear n_train_val n_data_val 
        n_train_val = matrix_data_train(y);
        n_data_val = matrix_data_size(y);
        
        % I subtract 0.1 to avoid: 'round(17/2) = 9'
        clear complexity_test
        complexity_test = round((n/10) * (n_train_val-0.1));
        if complexity_test < 1
            complexity_test = 1;
        end
        
        % single sequence values initialization
        clear temp_sequence_values train_sequence_values test_sequence_values
        temp_sequence_values = matrix_data(1:n_train_val,y);
        train_sequence_values = matrix_data(1:n_train_val,y);
        test_sequence_values = matrix_data(n_train_val+1:n_data_val,y);
        
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
        MASE_vector(y) = temp_eval.MASE;
    end
    % integral evaluation
    MASE_integral = descrete_integral(MASE_vector,1)/(n_set_data -1);
    MASE_average = mean(MASE_vector)
    
    if MASE_integral < definitive.MASE_int
        definitive.complexity_perc = n;
        definitive.MASE_int = MASE_integral;
    end
    
    % uncomment to have a feedback
    % plot(MASE_vector)
    % MASE_vector
end

%-------------------------------------------------------------------------%
% solution: best complexity percentage
best_complexity_percentage = definitive.complexity_perc;
clear definitive.complexity_perc

% solution: best complexity abs array
best_complexity_array = zeros(1,n_set_data);
n = best_complexity_percentage;
for y = 1 : n_set_data
    
    n_train_val = matrix_data_train(y);
    % I subtract 0.1 to avoid: 'round(17/2) = 9'
    clear complexity_test
    complexity_test = round((n/10) * (n_train_val-0.1));
    if complexity_test < 1
        complexity_test = 1;
    end
    best_complexity_array(y) = complexity_test;
end

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

%Adjust negative values to zero
forecast_matrix = sol_adjuster(temp_sol_matrix);
clear temp_sol_matrix

% solution structure definition 
solution.best_complexity_percentage = best_complexity_percentage;
solution.best_complexity_array = best_complexity_array;
solution.forecast_matrix = forecast_matrix;
    
end

