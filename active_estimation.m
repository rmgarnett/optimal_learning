initialize;

load data/ripple_vectors
load data/people
load data/hostile

data = get_pca(5, normalized_eigenvectors, normalized_eigenvalues);
data = data(people, :);
num_observations = size(data, 1);

responses = hostile(:);
responses(responses == 0) = -1;
actual_proportion = mean(responses == 1);

in_train = false(num_observations, 1);
in_train(1) = true;

log_input_scale_prior_mean = -1;
log_input_scale_prior_variance = 0.5;

log_output_scale_prior_mean = 0;
log_output_scale_prior_variance = 1;

latent_prior_mean_prior_mean = 0;
latent_prior_mean_prior_variance = 0.5;

hypersamples.prior_means = ...
     [latent_prior_mean_prior_mean ...
      log_input_scale_prior_mean ...
      log_output_scale_prior_mean];

hypersamples.prior_variances = ...
     [latent_prior_mean_prior_variance ...
      log_input_scale_prior_variance ...
      log_output_scale_prior_variance];

hypersamples.values = find_ccd_points(hypersamples.prior_means, ...
                                      hypersamples.prior_variances);

hypersamples.mean_ind = 1;
hypersamples.covariance_ind = 2:3;
hypersamples.likelihood_ind = [];

hyperparameters.lik = hypersamples.values(1, hypersamples.likelihood_ind);
hyperparameters.mean = hypersamples.values(1, hypersamples.mean_ind);
hyperparameters.cov = hypersamples.values(1, hypersamples.covariance_ind);

inference_method = @infEP;
mean_function = @meanConst;
covariance_function = @covSEiso;
likelihood = @likErf;

[~, inference_method, mean_function, covariance_function, likelihood] = ...
    check_gp_arguments(hyperparameters, inference_method, ...
                       mean_function, covariance_function, likelihood, ...
                       data, responses);

num_evaluations = 2; %floor(num_observations / 2000);
num_f_samples = 1000;

[estimated_proportion proportion_variance] = ...
  random_sampling_estimate(data, responses, in_train, ...
    num_evaluations, inference_method, mean_function, ...
    covariance_function, likelihood, hypersamples, num_f_samples);

disp(['random sampling: ' num2str(estimated_proportion) ...
      ' +/- ' num2str(sqrt(proportion_variance)) ...
      ', actual: ' num2str(actual_proportion)]);

[estimated_proportion proportion_variance] = ...
  uncertainty_sampling_estimate(data, responses, in_train, ...
    num_evaluations, inference_method, mean_function, ...
    covariance_function, likelihood, hypersamples, num_f_samples);

disp(['uncertainty sampling: ' num2str(estimated_proportion) ...
      ' +/- ' num2str(sqrt(proportion_variance)) ...
      ', actual: ' num2str(actual_proportion)]);

[estimated_proportion proportion_variance] = ...
  optimal_sampling_estimate(data, responses, in_train, ...
    num_evaluations, inference_method, mean_function, ...
    covariance_function, likelihood, hypersamples, num_f_samples);

disp(['optimal sampling: ' num2str(estimated_proportion) ...
      ' +/- ' num2str(sqrt(proportion_variance)) ...
      ', actual: ' num2str(actual_proportion)]);
