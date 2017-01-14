function [ sequence ] = sequence_generator( numbers, interval, initial_value, sign)
%------------------------------------------------------------------------%
%sequence_generator - sequence generator function
%
% Author, date:
%   -Emanuele Sansebastiano, December 2016
%........................................................................%
%
% Input data:
%   - number of samples (numbers)
%   - interval between samples (interval)
%   - first sample (initial_value)
%   - increase or decrease sequence (sign)
%
% Algorithm:
%   - sequence(1) = initial_value
%   - sequence(y) = sequence(y-1) + (sign) * (interval), for y =2...numbers
%
%------------------------------------------------------------------------%

%% Function input control
if rem(numbers,1) ~= 0 || numbers < 1
   error('The input must be an integer bigger than ''0''');
end
if interval <= 0
   error('The second input (interval) must be strictly positive');
end
if strcmp(sign,'+') == 0 && strcmp(sign,'-') == 0
   error('The input sign can be just ''+'' or ''-''');
end


%% Algorithms and solution

sequence = zeros(1,numbers);
sequence(1) = initial_value;
if strcmp(sign,'+')
    k = 1;
else
    k = -1;
end

for y = 2 : numbers
    sequence(y) = sequence(y-1) + k*interval;
end

