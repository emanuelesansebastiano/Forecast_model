# Forecast_model
Tourism forecast based on very pour time series (time serie size is not constant). 

Author: Emanuele Sansebastiano

Github page: https://github.com/emanuelesansebastiano

Date: January, 2017


Dataset used: 'tourism_data.csv'

Real forecast solution: 'forecast_values.csv'

Experiment solution (.mat): 'data_forecast.mat'


Project purpose:
This bunch of functions try to forecast tourism values knowing the previous ones. It is basically an Autoregressive system. 
The set is composed by 518 time series having different size (min:7 max:43) and we want a serie of 4 forecast values for every time serie.
Forecast evaluation: Mean absolute scaled error (MASE).

Process description:
The function takes the dataset and performs a dataset division 70% of every single time serie will be used to generate a specific complexity model. Then, the function will evaluate the forecast based on the remaining 30% of the time series, testing every possible (and reasonable) order of complexity. After that, the function will have the best complexity model for every kind of model used (AR, ARMA, etc..). So, it will compare all the model against each other establishing which is the best one using that to generate the best forecast set. 



These set of functions uses many models to try to find the best forecast, in particular:
- Average: 'forecast_average.m'
- Weighted average: 'forecast_weighted_average.m'
- Adjusted Polyfit: 'polyfit_model_variable_positive_evaluator.m'
- Percentage AR: 'ar_model_perc_evaluator'
- Common AR: 'ar_model_best_common_evaluator'
- Variable AR: 'ar_model_variable_evaluator'
- Variable ARMA: 'arma_model_variable_evaluator'

Function to evaluate the precision according to MASE is called: 'model_eval.m'

To use this package just run the function called 'main.m' and wait. Progression is going to be printed on the screen.

ENJOY!!!

