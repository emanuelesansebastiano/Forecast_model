function [ difference ] = timeevaluator_sec( init_time )
%------------------------------------------------------------------------%
%timeevaluator_sec - timegap evaluator 
%(minimum complexity is equal to 1)
%
% Author, date:
%   -Emanuele Sansebastiano, January 2015
%........................................................................%
%
% Input data:
%   - initial clock time
%      
% Output:
%   - Time difference in seconds
%
% Comments:
%   - According to the position in the previous equation there are:
%      sec; min; hours; days.
%   ! Check you are not using this clock on changing month midnight !
%   
%------------------------------------------------------------------------%

current_time = clock;
difference = (current_time(6)-init_time(6)) + (current_time(5)-init_time(5))*60 + (current_time(4)-init_time(4))*60*60 + (current_time(3)-init_time(3))*60*60*24;

if difference < 0
    error('Something is wrong: time value is negative');
end
end

