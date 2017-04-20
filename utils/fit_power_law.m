function [log_lpin, gamma, z] = fit_power_law(nin, degrees)

eps = 10^(-25);

% Count the number of each degree:
Pin = histcounts(nin, [0.5, degrees + 0.5]); % zero is not included
% fprintf('Non-zero degrees: %0.2f \n', mean(Pin > 0));
Pin = Pin/length(Pin);
Pin(Pin == 0) = eps;

% Fit  log(Pk) = -gamma*log(k + 1) + z:
lm = fitlm(log(degrees + 1), log(Pin)); 
gamma = -lm.Coefficients.Estimate(2);

% Estimate normalization constant z in log(Pk) = -gamma*log(k + 1) + z:
z = log(sum(exp(power_low_pdf(degrees, gamma, 0))));

if gamma <= 0 
    log_lpin = -Inf*ones(size(nin));
else
    log_lpin = power_low_pdf(nin, gamma, z);
end

end


function logp = power_low_pdf(x, gamma, z)

logp = -gamma*log(x + 1) + z;

end