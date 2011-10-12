function [estimated_proportions proportion_variances in_train] = ...
      iterative_surveying_variance_target(data, responses, in_train, ...
          utility_function, proportion_estimation_function, ...
          variance_target, options)
  
  if (nargin < 7)
    verbose = false;
    actual_proportion = 0;
  else
    if (~ismember(options, 'verbose'))
      verbose = false;
    end
    if (~ismember(options, 'actual_proportion'))
      actual_proportion = 0;
    end
  end

  estimated_proportions = [];
  proportion_variances = [];

  num_evaluations = 1;
  while ((num_evaluations == 1) || ...
         (proportion_variances(end) > variance_target))
    if (verbose)
      tic;
    end
    
    utilities = utility_function(data(in_train, :), responses(in_train), ...
                                 data(~in_train, :));
    [best_utility best_ind] = max(utilities);

    test_ind = find(~in_train);
    in_train(test_ind(best_ind)) = true;

    [estimated_proportion proportion_variance] = ...
        proportion_estimation_function(data(in_train, :), ...
            responses(in_train), data(~in_train, :));
    
    num_train = nnz(in_train);
    num_test = nnz(~in_train);

    this_mean = num_train / (num_train + num_test) * (mean(responses(in_train) == 1)) + ...
                num_test  / (num_train + num_test) * estimated_proportion;
    this_variance = (num_test / (num_train + num_test))^2 * proportion_variance;

    estimated_proportions(end + 1) = this_mean;
    proportion_variances(end + 1) = this_variance;

    if (verbose)
      elapsed = toc;
      to_print = ['point ' num2str(num_evaluations) ...
                  ', utility: ' num2str(best_utility) ...
                  ', distribution (' num2str(nnz(responses(in_train) == 1)) ...
                  ' / ' num2str(num_evaluations) ...
                  '), current estimate: ' num2str(estimated_proportions(num_evaluations) * 100) '%' ...
                  ' +/- ' num2str(sqrt(proportion_variances(num_evaluations)) * 100) '%'];
      if (actual_propotion > 0)
        [alpha beta] = moment_matched_beta(this_mean, this_variance);
        log_likelihood = log(normpdf(actual_proportion, alpha, beta));
        to_print = [to_print ', log likelihood: ' num2str(log_likelihood)];
      end
      
      to_print = [to_print ', took: ' num2str(elapsed) 's.'];
      disp(to_print);
    end

    num_evaluations = num_evaluations + 1;
  end

end
