set_circle_experiment_discrete_parameters;

all_purely_random_estimated_proportions = zeros(num_experiments, 1);
all_random_estimated_proportions = zeros(num_evaluations, num_experiments);
all_uncertainty_estimated_proportions = zeros(num_evaluations, num_experiments);
all_battleship_estimated_proportions = zeros(num_evaluations, num_experiments);
all_optimal_estimated_proportions = zeros(num_evaluations, num_experiments);

all_random_proportion_variances = zeros(num_evaluations, num_experiments);
all_uncertainty_proportion_variances = zeros(num_evaluations, num_experiments);
all_battleship_proportion_variances = zeros(num_evaluations, num_experiments);
all_optimal_proportion_variances = zeros(num_evaluations, num_experiments);

num_points_chosen = num_evaluations + 1;

random_points_chosen = zeros(num_points_chosen * num_experiments, dimension);
uncertainty_points_chosen = zeros(num_points_chosen * num_experiments, dimension);
battleship_points_chosen = zeros(num_points_chosen * num_experiments, dimension);
optimal_points_chosen = zeros(num_points_chosen * num_experiments, dimension);

random_likelihoods = zeros(num_experiments, 1);
uncertainty_likelihoods = zeros(num_experiments, 1);
battleship_likelihoods = zeros(num_experiments, 1);
optimal_likelihoods = zeros(num_experiments, 1);

for experiment = 1:num_experiments

  load([results_directory '/' num2str(experiment)]);

  all_purely_random_estimated_proportions(experiment) = ...
      purely_random_estimated_proportion;
  all_random_estimated_proportions(:, experiment) = random_estimated_proportions;
  all_uncertainty_estimated_proportions(:, experiment) = uncertainty_estimated_proportions;
  all_battleship_estimated_proportions(:, experiment) = battleship_estimated_proportions;
  all_optimal_estimated_proportions(:, experiment) = optimal_estimated_proportions;

  all_random_proportion_variances(:, experiment) = random_proportion_variances;
  all_uncertainty_proportion_variances(:, experiment) = uncertainty_proportion_variances;
  all_battleship_proportion_variances(:, experiment) = battleship_proportion_variances;
  all_optimal_proportion_variances(:, experiment) = optimal_proportion_variances;

  points_range = (1 + (experiment - 1) * num_points_chosen):(experiment ...
          * num_points_chosen);

  random_points_chosen(points_range, :) = data(random_chosen, :);
  uncertainty_points_chosen(points_range, :) = data(uncertainty_chosen, :);
  battleship_points_chosen(points_range, :) = data(battleship_chosen, :);
  optimal_points_chosen(points_range, :) = data(optimal_chosen, :);
  
  random_likelihoods(experiment) = random_likelihood;
  uncertainty_likelihoods(experiment) = uncertainty_likelihood;
  battleship_likelihoods(experiment) = battleship_likelihood;
  optimal_likelihoods(experiment) = optimal_likelihood;

end

num_kde_grid_points = 300;
lower_bound = -0.25;
upper_bound = 1.25;

x = linspace(lower_bound, upper_bound, num_kde_grid_points);
y = linspace(lower_bound, upper_bound, num_kde_grid_points);

[xx yy] = meshgrid(x, y);

kde_parameters.N = num_kde_grid_points;
kde_parameters.x = xx(:);
kde_parameters.y = yy(:);
kde_parameters.h = 0.1;

random_distribution = gkde2(random_points_chosen, kde_parameters);
uncertainty_distribution = gkde2(uncertainty_points_chosen, kde_parameters);
battleship_distribution = gkde2(battleship_points_chosen, kde_parameters);
optimal_distribution = gkde2(optimal_points_chosen, kde_parameters);

figure(1);
set(gcf, 'color', 'white');

in_square_index = (xx >= 0) & (xx <= 1) & (yy >= 0) & (yy <= 1);
side_length = sqrt(nnz(in_square_index));

lower_bound = 0;
upper_bound = 1;

subplot(2, 2, 1);
imagesc([lower_bound upper_bound], [lower_bound upper_bound], ...
        reshape(random_distribution.pdf(in_square_index), side_length, ...
                side_length));
axis square;
axis off;
subplot(2, 2, 2);
imagesc([lower_bound upper_bound], [lower_bound upper_bound], ...
        reshape(uncertainty_distribution.pdf(in_square_index), ...
                side_length, side_length));
axis square;
axis off;
subplot(2, 2, 3);
imagesc([lower_bound upper_bound], [lower_bound upper_bound], ...
        reshape(battleship_distribution.pdf(in_square_index), ...
                side_length, side_length));
axis square;
axis off;
subplot(2, 2, 4);
imagesc([lower_bound upper_bound], [lower_bound upper_bound], ...
        reshape(optimal_distribution.pdf(in_square_index), side_length, ...
                side_length));
axis square;
axis off;