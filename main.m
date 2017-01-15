%------------------------------------------------------------------------%
% Author: Emanuele Sansebastiano
% Subject: Cognitive Process
% Date: November 2016
% 
% Project pourpose:
% The aim of this code is predicting the future trend of a bounch of data.
% In this case we try to forecast the future touristic values taken from
% the file called “tourism_data.csv” and we will use as reference solution
% the data extract from the file called “example.csv”. 
% We will compare many forecast model thanks to the mean absolute scaled 
% error (MASE).
%
%------------------------------------------------------------------------%

clear all

%% Reading data from file and adjust them

correct_solution = xlsread('forecast_values.csv');
input_data = xlsread('tourism_data.csv');
temp1 = size(correct_solution); temp2 = size(input_data);
if temp1(2) ~= temp2(2)
    error('The file chosen do not have the same number of columns!');
end
solution_size = temp1;
input_size = temp2;
n_des_forecast_val = solution_size(1);
clear temp1 temp2 solution_size

%% Adjusting data

temp_input_data = NaN(input_size(1), input_size(2));
n_avail_numb = NaN(1, input_size(2));

for y1 = 1 : input_size(2)
    NaN_counter = 0;
   for y2 = 1 : input_size(1)
      if isnan(input_data(y2, y1))
          NaN_counter = NaN_counter +1;
      end
   end
   
   n_avail_numb(1, y1) = input_size(1) - NaN_counter;
   
   for y2 = 1 : n_avail_numb(1, y1)
      temp_input_data(y2, y1) = input_data(NaN_counter+y2, y1);
   end
end

input_data = temp_input_data;

%% Separation: train-data and test data
train_perc = 70; test_perc = 100 - train_perc;

n_train_numb = round(n_avail_numb*(train_perc/100)); 
n_test_numb = n_avail_numb - n_train_numb;

if find(n_train_numb + n_test_numb - n_avail_numb > 0) + find(n_test_numb == 0) + find(n_train_numb <= 2) > 0 
    error('There is some error in the train/test set definition')
end

clear y1 y2 NaN_counter temp_input_data

% 'n_avail_numb' represents the number of available number for every column
% 'n_train_numb' represents the train numbers available for every column
% 'n_test_numb' represents the test numbers available for every column
% 'input_data' is the input data file (previous record)
% 'correct_solution' is the solution expected
% 'n_des_forecast_val' is the number of forecast solutions 

%% Forecast models
fprintf('\nAverage forecast starts...\n'); init_time = clock();
f_avarage = forecast_average(input_data, n_avail_numb, n_des_forecast_val);
time_f_average = timeevaluator_sec(init_time);
clear data_eval; data_eval = model_eval(input_data, n_avail_numb, correct_solution, f_avarage);
i = 1; f_model(i).time = time_f_average; f_model(i).mod_name = 'forecast_average'; 
f_model(i).forecast = f_avarage; f_model(i).MASE = data_eval.MASE; f_model(i).meanMASE = mean(data_eval.MASE);

fprintf('\nWeighted average forecast starts...\n'); init_time = clock();
f_avarage_weighted = forecast_weighted_average(input_data, n_avail_numb, n_des_forecast_val);
time_f_average_weighted = timeevaluator_sec(init_time);
clear data_eval; data_eval = model_eval(input_data, n_avail_numb, correct_solution, f_avarage_weighted);
i = i+1; f_model(i).time = time_f_average_weighted; f_model(i).mod_name = 'forecast_weighted_average';
f_model(i).forecast = f_avarage_weighted; f_model(i).MASE = data_eval.MASE; f_model(i).meanMASE = mean(data_eval.MASE);

fprintf('\nPolyfit variable forecast starts...\n'); init_time = clock();
poly_var_solution = polyfit_model_variable_evaluator(input_data, n_avail_numb, n_train_numb, n_des_forecast_val);
time_poly_var_solution = timeevaluator_sec(init_time);
clear data_eval; data_eval = model_eval(input_data, n_avail_numb, correct_solution, poly_var_solution.forecast_matrix);
i = i+1; f_model(i).time = time_poly_var_solution; f_model(i).mod_name = 'polyfit_model_variable_evaluator'; 
f_model(i).forecast = poly_var_solution; f_model(i).MASE = data_eval.MASE; f_model(i).meanMASE = mean(data_eval.MASE);

fprintf('\nPolyfit variable strictly positive forecast starts...\n'); init_time = clock();
poly_var_pos_solution = polyfit_model_variable_positive_evaluator(input_data, n_avail_numb, n_train_numb, n_des_forecast_val);
time_poly_var_pos_solution = timeevaluator_sec(init_time);
clear data_eval; data_eval = model_eval(input_data, n_avail_numb, correct_solution, poly_var_pos_solution.forecast_matrix);
i = i+1; f_model(i).time = time_poly_var_pos_solution; f_model(i).mod_name = 'polyfit_model_variable_positive_evaluator'; 
f_model(i).forecast = poly_var_pos_solution; f_model(i).MASE = data_eval.MASE; f_model(i).meanMASE = mean(data_eval.MASE);

fprintf('\nAR percentage forecast starts...\n'); init_time = clock();
ar_perc_solution = ar_model_perc_evaluator(input_data, n_avail_numb, n_train_numb, n_des_forecast_val);
time_ar_perc_solution = timeevaluator_sec(init_time);
clear data_eval; data_eval = model_eval(input_data, n_avail_numb, correct_solution, ar_perc_solution.forecast_matrix);
i = i+1; f_model(i).time = time_ar_perc_solution; f_model(i).mod_name = 'ar_model_perc_evaluator'; 
f_model(i).forecast = ar_perc_solution; f_model(i).MASE = data_eval.MASE; f_model(i).meanMASE = mean(data_eval.MASE);

fprintf('\nAR common forecast starts...\n'); init_time = clock();
ar_comm_solution = ar_model_best_common_evaluator(input_data, n_avail_numb, n_train_numb, n_des_forecast_val);
time_ar_comm_solution = timeevaluator_sec(init_time);
clear data_eval; data_eval = model_eval(input_data, n_avail_numb, correct_solution, ar_comm_solution.forecast_matrix);
i = i+1; f_model(i).time = time_ar_comm_solution; f_model(i).mod_name = 'ar_model_best_common_evaluator'; 
f_model(i).forecast = ar_comm_solution; f_model(i).MASE = data_eval.MASE; f_model(i).meanMASE = mean(data_eval.MASE);

fprintf('\nAR variable forecast starts...\n'); init_time = clock();
ar_var_solution = ar_model_variable_evaluator(input_data, n_avail_numb, n_train_numb, n_des_forecast_val);
time_ar_var_solution = timeevaluator_sec(init_time);
clear data_eval; data_eval = model_eval(input_data, n_avail_numb, correct_solution, ar_var_solution.forecast_matrix);
i = i+1; f_model(i).time = time_ar_var_solution; f_model(i).mod_name = 'ar_model_variable_evaluator'; 
f_model(i).forecast = ar_var_solution; f_model(i).MASE = data_eval.MASE; f_model(i).meanMASE = mean(data_eval.MASE);

fprintf('\nARMA variable forecast starts...\n'); init_time = clock();
arma_var_solution = arma_model_variable_evaluator(input_data, n_avail_numb, n_train_numb, n_des_forecast_val);
time_arma_var_solution = timeevaluator_sec(init_time);
clear data_eval; data_eval = model_eval(input_data, n_avail_numb, correct_solution, arma_var_solution.forecast_matrix);
i = i+1; f_model(i).time = time_arma_var_solution; f_model(i).mod_name = 'arma_model_variable_evaluator'; 
f_model(i).forecast = arma_var_solution; f_model(i).MASE = data_eval.MASE; f_model(i).meanMASE = mean(data_eval.MASE);

save('data_forecast');

%% Best Model Evaluation
n_model = size(f_model,2);

swap = 1;
while(swap == 1)
    swap = 0;
    for i = 1 : n_model-1
        if f_model(i).meanMASE > f_model(i+1).meanMASE
            temp = f_model(i+1);
            f_model(i+1) = f_model(i);
            f_model(i) = temp;
            clear temp
            swap = 1;
        end
    end
end

clear i swap init_time data_eval
save('data_forecast');

fprintf('\nFINISHED!\nThe best model is: %s\n', f_model(1).mod_name);
