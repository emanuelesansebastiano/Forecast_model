function [ MASE_RMASE_MAPSE  ] = model_eval(input_data, n2use4column, solution_reference, solution_test)
%------------------------------------------------------------------------%
%model_eval - various evaluation values
%
% Author, date:
%   -Emanuele Sansebastiano, December 2016
%........................................................................%
%
% Input data:
%   - matrix of the input data (input_data)
%   - array of the number of values to consider for each column (n2use4column)
%   - matrix of the correct solution to refer (solution_reference)
%   - matrix of the solution to test (solution_test)
%      
% Algorithm:
%   - MASE; RMASE; MAPSE
%
%------------------------------------------------------------------------%

%% Function input control
size_correct = size(solution_reference);
size_test = size(solution_test);
if size_correct ~= size_test
   error('The input size is different');
end
if find([size(input_data,2), size(n2use4column,2)] ~= size_test(2))
   error('Not all the input lenghts are equal');
end

%% Algorithms and solution
forcast_val = size_correct(1); set_numb = size_correct(2);


%uncomment to test the solution tester algorithms reported below
%solution_test = 2000 * ones(forcast_val,set_numb);

%computation of various errors 
%initialization
simple_err = zeros(forcast_val,set_numb);
simple_err_sum = zeros(forcast_val,set_numb);
perc_err = zeros(forcast_val,set_numb);
MAE_err = zeros(1,set_numb);
MAPE_err = zeros(1,set_numb);
sMAPE_err = zeros(1,set_numb);
RMSE_err = zeros(1,set_numb);
Q_err = zeros(1,set_numb);
Q_perc_err = zeros(1,set_numb);
MASE_err = zeros(1,set_numb);
RMASE_err = zeros(1,set_numb);
MAPSE_err = zeros(1,set_numb);

for y1 = 1 : set_numb
   for y2 = 1 : forcast_val
       %simple error
       simple_err(y2,y1) = solution_reference(y2,y1) - solution_test(y2,y1);
       simple_err_sum(y2,y1) = solution_reference(y2,y1) + solution_test(y2,y1);
       
       %percentage error
       perc_err(y2,y1) = 100 * (simple_err(y2,y1)/solution_reference(y2,y1)); 
   end
    %Mean absolute error: MAE
    MAE_err(y1) = mean(abs(simple_err(:,y1)));
    
    %Mean absolute percentage error: MAPE
    MAPE_err(y1) = mean(abs(perc_err(:,y1)));
    
    %sMAPE
    sMAPE_err(y1) = mean(200 * abs(simple_err(:,y1))./simple_err_sum(:,y1));
    
    %Root mean squared error: RMSE
    RMSE_err(y1) = sqrt(mean(simple_err(:,y1).^2));
   
    %scaled error: Q_err
    initial_val = 1; 
    temp_num = n2use4column(y1);
    temp_val = 0;
    for y2 = (initial_val +1) : temp_num
        temp_val = temp_val + abs(input_data(y2,y1) - input_data(y2-1,y1));
    end
    temp_val = temp_val/(temp_num - initial_val);
    Q_err(y1) = temp_val;
    
    %scaled percentage error: Q_perc_err
    initial_val = 1; 
    temp_num = n2use4column(y1);
    temp_val = 0;
    for y2 = (initial_val +1) : temp_num
        temp_val = temp_val + abs(100 * (input_data(y2,y1) - input_data(y2-1,y1))/input_data(y2,y1));
    end
    temp_val = temp_val/(temp_num - initial_val);
    Q_perc_err(y1) = temp_val;

    %Mean absolute scaled error: MASE = MAE/Q_err
    MASE_err(y1) = MAE_err(y1)/Q_err(y1);
    
    %Root mean absolute scaled error: RMASE = RMSE/Q_err
    RMASE_err(y1) = RMSE_err(y1)/Q_err(y1);
    
    %Mean absolute percentage scaled error: MAPSE = MASE/Q_perc_err
    MAPSE_err(y1) = MAPE_err(y1)/Q_perc_err(y1);
end

MASE_RMASE_MAPSE.MASE  = MASE_err;
MASE_RMASE_MAPSE.RMASE = RMASE_err;
MASE_RMASE_MAPSE.MAPSE = MAPSE_err;

%General mean error values
%mean_MAE_err = mean(MAE_err(:));
%mean_MAPE_err = mean(MAPE_err(:));
%mean_sMAPE_err = mean(sMAPE_err(:));
%mean_RMSE_err = mean(RMSE_err(:));
%mean_Q_err = mean(Q_err(:));
%mean_Q_perc_err = mean(Q_perc_err(:));
mean_MASE_err = mean(MASE_err(:));
mean_RMASE_err = mean(RMASE_err(:));
mean_MAPSE_err = mean(MAPSE_err(:));

clear y1 y2 initial_val temp_num temp_val

%figure(1)
%hold on
%plot(MAE_err, '-y')
%plot(MAPE_err, '-r')
%plot(sMAPE_err, '-g')
%plot(RMSE_err, '-b')
%plot(Q_err, '--k')
%plot(Q_perc_err, '--r')
%plot(MASE_err, '-k')
%plot(RMASE_err, '-g')
%plot(MAPSE_err, '-r')

end

