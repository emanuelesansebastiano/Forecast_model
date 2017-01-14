function [ weight_set ] = weight_func(type, init_perc, fin_perc, lenght_horiz)
%------------------------------------------------------------------------%
%weight_func - weight generator using:
%  quadratic function   'y=A*x^2 + B'
%  linear function      'y=A*x + B'
%
% Author, date:
%   -Emanuele Sansebastiano, December 2016
%........................................................................%
%
% Input data:
%   - type: linear or quadratic ('linear' - 'quadratic')
%   - init_perc: weight of the first value (from 0 - 100)
%   - fin_perc: weight of the last value (from 0 - 100)
%   - lenght_horinz: number of values to weight
%      
% Algorithm:
%   - simple computation
%
%------------------------------------------------------------------------%

%% Function input control
if init_perc < 0 || init_perc > 100
    error('The weight of the initial value is not valid');
end
if fin_perc < 0 || fin_perc > 100
    error('The weight of the last value is not valid');
end
if lenght_horiz < 1 || rem(lenght_horiz,1) ~= 0 
    error('You must insert a integer number of values and greater than 0');
end
if strcmp(type,'linear') == 0 && strcmp(type,'quadratic') == 0
   error('The type of algorithm inserted is not valid; you can enter just ''linear'' or ''quadratic''');
end

%% Algorithms and solution

%initialization
weight_set = zeros(1,lenght_horiz);
first_val = [0, init_perc];
last_val = [lenght_horiz-1, fin_perc];

if strcmp(type,'linear')
    B = first_val(2);
    A = (last_val(2) - B)/last_val(1);
    for y = 1 : lenght_horiz
        weight_set(y) = A*(y-1) + B;
    end
else
    B = first_val(2);
    A = (last_val(2) - B)/(last_val(1))^2;
    for y = 1 : lenght_horiz
        weight_set(y) = A*(y-1)^2 + B;
    end
end

%uncomment to chack the weight path
%plot(weight_set, 'or')

end

