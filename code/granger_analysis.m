function granger_analysis

addpath(genpath('C:\Users\motrenko\Documents\MATLAB\mvgc_v1.0\'));
addpath(genpath('C:\Users\motrenko\Documents\Projects\BrainConnectivity\brainstorm_db\Protocol01\data\'));

% Get data:
subject = 'Subject01\LINE_M_45';
[data, time] = get_data_for_granger_analysis(subject);

early_ts = data(:, time <= 0.2);
late_ts = data(:, time >= 0.35 & time <= 0.55);

X = early_ts;

% Parameters

regmode = 'OLS'; % VAR model estimation regression mode ('OLS', 'LWR' or empty for default)
model = 'AIC';   % model order to use ('actual', 'AIC', 'BIC' or supplied numerical value)
max_order = 20;  % maximum model order for model order estimation

% select_model_order(X, regmode, model, max_order);

model_order = 10; % From Izyurov
n_roi = size(data, 1);
roi_pairs = combntns(1:n_roi, 2);
connections = zeros(n_roi);
for pair = roi_pairs'
    [~, ~, sig] = run_gce(X(pair, :), model_order, regmode);
    connections(pair(1), pair(2)) = sig(1, 2);
    connections(pair(2), pair(1)) = sig(2, 1);
end    
% gce_long(X, model_order, regmode);


end


function gce_long(X, morder, regmode)

% Calculate VAR model; return residuals E too, since we need them later for
% statistical routines.

ptic('\n*** tsdata_to_var... ');
[A,SIG,E] = tsdata_to_var(X, morder,regmode);
ptoc;

% Check for failed regression

assert(~isbad(A),'VAR estimation failed');

% Now calculate autocovariance according to the VAR model, to as many lags
% as it takes to decay to below the numerical tolerance level, or to acmaxlags
% lags if specified (i.e. non-empty).

ptic('*** var_to_autocov... ');
[G,info] = var_to_autocov(A, SIG, acmaxlags);
ptoc;

% Report and check for errors.

var_info(info,true); % report results (and bail out on error)

% Empirical autocovariance

GE = tsdata_to_autocov(X,info.aclags);

figure(2); clf;
plot_autocov(cat(4,G,GE),{'model','data'},1/fs,[],true,acorr);

% Spectral analysis

ptic('*** autocov_to_cpsd... ');
[S,fres] = autocov_to_cpsd(G,fres); % for model
ptoc;

ptic('*** tsdata_to_cpsd... ');
SE = tsdata_to_cpsd(X,fres,specm);  % from data (empirical)
ptoc;

% plot (auto-)spectra

figure(3); clf;
plot_cpsd(cat(4,S,SE),{'model','data'},fs,[],true);

% VAR stats tests

% Check that residuals are white (Durbin-Watson test).

[dw,dwpval] = whiteness(X,E);
fprintf('\nDurbin-Watson statistics =\n'); disp(dw);
dwsig = significance(dwpval,alpha,mhtc); % significance adjusted for multiple hypotheses
notwhite = find(dwsig);
if isempty(notwhite)
    fprintf('all residuals are white by Durbin-Watson test at significance %g\n',alpha);
else
    fprintf(2,'WARNING: autocorrelated residuals at significance %g for variable(s): %s\n',alpha,num2str(notwhite));
end

% Check R^2 stats.

[~,RSQADJ] = rsquared(X,E);
fprintf('\nRSQ (adjusted) =\n'); disp(RSQADJ);
rsqthreshold = 0.3; % like GCCA
badqsq = find(RSQADJ < rsqthreshold);
if isempty(badqsq)
    fprintf('adjusted r-squares OK: > %g%% of variance is accounted for by the model\n',100*rsqthreshold);
else
    fprintf(2,'WARNING: low adjusted r-square values (< %g) for variable(s): %s\n',rsqthreshold,num2str(badqsq));
end

% Check model consistency (ie. proportion of correlation structure of the data
% accounted for by the model).

cons = 100*consistency(X,E); % percent
fprintf('\nmodel consistency = %.0f%%\n',cons);
consthreshold = 80;          % like GCCA
if cons > consthreshold
    fprintf('consistency OK: > %g%%\n',consthreshold);
else
    fprintf(2,'WARNING: low consistency (< %g%%)\n',consthreshold);
end

end

function morder = select_model_order(X, regmode, morder, momax)

% regmode - VAR model estimation regression mode ('OLS', 'LWR' or empty for default)
% model  - model order to use ('actual', 'AIC', 'BIC' or supplied numerical value)
% max_order   - maximum model order for model order estimation

% Calculate information criteria up to specified maximum model order.

ptic('\n*** tsdata_to_infocrit\n');
[AIC,BIC] = tsdata_to_infocrit(X, momax, regmode);
ptoc('*** tsdata_to_infocrit took ');

[~,bmo_AIC] = min(AIC);
[~,bmo_BIC] = min(BIC);

% Plot information criteria.

figure(1); clf;
plot((1:momax)',[AIC BIC]);
legend('AIC','BIC');


fprintf('\nbest model order (AIC) = %d\n',bmo_AIC);
fprintf('best model order (BIC) = %d\n',bmo_BIC);


% Select model order

if  strcmpi(morder,'AIC')
    morder = bmo_AIC;
    fprintf('\nusing AIC best model order = %d\n',morder);
elseif strcmpi(morder,'BIC')
    morder = bmo_BIC;
    fprintf('\nusing BIC best model order = %d\n',morder);
else
    fprintf('\nusing specified model order = %d\n',morder);
end


end

function [F, pval, sig] = run_gce(X, morder, regmode)
% Granger causality estimation

icregmode = 'LWR';  % information criteria regression mode ('OLS', 'LWR' or empty for default)
acmaxlags = 1000;   % maximum autocovariance lags (empty for automatic calculation)

tstat     = '';     % statistical test for MVGC:  'F' for Granger's F-test (default) or 'chi2' for Geweke's chi2 test
alpha     = 0.01;   % significance level for significance test
mhtc      = 'FDR';  % multiple hypothesis test correction (see routine 'significance')

fs        = 1000;    % sample rate (Hz)
fres      = [];     % frequency resolution (empty for automatic calculation)

seed      = 0;      % random seed (0 for unseeded)


% Calculate time-domain pairwise-conditional causalities. Return VAR parameters
% so we can check VAR.

ptic('\n*** GCCA_tsdata_to_pwcgc... ');
[F,A,SIG] = GCCA_tsdata_to_pwcgc(X, morder,regmode); % use same model order for reduced as for full regressions
ptoc;

% Check for failed (full) regression

assert(~isbad(A),'VAR estimation failed');

% Check for failed GC calculation

assert(~isbad(F,false),'GC calculation failed');

% Check VAR parameters (but don't bail out on error - GCCA mode is quite forgiving!)

rho = var_specrad(A);
fprintf('\nspectral radius = %f\n',rho);
if rho >= 1,       fprintf(2,'WARNING: unstable VAR (unit root)\n'); end
if ~isposdef(SIG), fprintf(2,'WARNING: residuals covariance matrix not positive-definite\n'); end

% Significance test using theoretical null distribution, adjusting for multiple
% hypotheses.

[nvars, nobs, ntrials] = size(X);
pval = mvgc_pval(F,morder,nobs,ntrials,1,1,nvars-2,tstat);
sig  = significance(pval,alpha,mhtc);

% Plot time-domain causal graph, p-values and significance.

% figure(2); clf;
% subplot(1,3,1);
% plot_pw(F);
% title('Pairwise-conditional GC');
% subplot(1,3,2);
% plot_pw(pval);
% title('p-values');
% subplot(1,3,3);
% plot_pw(sig);
% title(['Significant at p = ' num2str(alpha)])



end