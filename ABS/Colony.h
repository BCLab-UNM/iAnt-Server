class Colony
{
 public:
  Colony()
    {
	decay_rate = 0.0;
	trail_drop_rate = 0.0;

	walk_drop_rate = 0.0;

	search_giveup_rate = 0.0;

	dir_dev_const = 1.0;
	dir_dev_coeff1 = 0.0;
	dir_time_pow1 = 0.0;
	dir_dev_coeff2 = 0.0;
	dir_time_pow2 = 0.0;

	dense_thresh = 0.0;
	dense_sens = 0.0;
	dense_const = 0.0;

	dense_thresh_patch = 0.0;
	dense_const_patch = 0.0;

	dense_thresh_influence = 0.0;
	dense_const_influence = 0.0;

	prop_active = 0.0;
	decay_rate_return = 0.0;
	activate_sensitivity = 0.0;

	seeds_collected = 0.0;
	ant_time_out = 0.0;
	fitness = 0.0;
    }


  float decay_rate; // evolvable parameter: pheromone decay_rate, grid[i][j].p2 *= (1-decay_rate);
  float trail_drop_rate; // evolvable parameter: probability that an ant following a trail will stop walking and start searching, if rand()%1000/1000.0f < drop_rate

  float search_giveup_rate; // evolvable parameter: probability each time step that a searching ant will give up and return to nest.

  float walk_drop_rate; // evolvable parameter: probability that a traveling ant will stop traveling and start searching, if rand()%1000/1000.0f < drop_rate

  float dir_dev_const; // evolvable parameter: weakness of correlation in correlated random walk search
  float dir_dev_coeff1; // evolvable parameter: coefficient for change in directional deviation with search time. high values, e.g. 1.0, indicate more turning early in search.  low values, e.g., -1.0, indicate less turning early in search.
  float dir_time_pow1; // evolvable parameter: float d_theta = sto.Normal(0,(colonies[col_count].dir_dev_coeff1*pow(ants[ant_count].search_time,colonies[col_count].dir_time_pow1))+(colonies[col_count].dir_dev_coeff2/pow(ants[ant_count].search_time,colonies[col_count].dir_time_pow2))+colonies[col_count].dir_dev_const);
  float dir_dev_coeff2; // evolvable parameter: coefficient for change in directional deviation with search time. high values, e.g. 1.0, indicate more turning early in search.  low values, e.g., -1.0, indicate less turning early in search.
  float dir_time_pow2; // evolvable parameter: float d_theta = sto.Normal(0,(colonies[col_count].dir_dev_coeff1*pow(ants[ant_count].search_time,colonies[col_count].dir_time_pow1))+(colonies[col_count].dir_dev_coeff2/pow(ants[ant_count].search_time,colonies[col_count].dir_time_pow2))+colonies[col_count].dir_dev_const);

  float dense_thresh; // evolvable parameter: density_count/dense_thresh is the threshold for deciding to lay a trail
  float dense_sens; // evolvable parameter: sensitivity of the decision to lay a trail.  rand()%dense_sens/((float) dense_sens)
  float dense_const; // evolvable parameter: sensitivity of the decision to lay a trail.  rand()%dense_sens/((float) dense_sens)

  float dense_thresh_patch; // evolvable parameter: density_count/dense_thresh is the threshold for deciding to return to patch
  float dense_const_patch; // evolvable parameter: sensitivity of the decision to return to patch.  rand()%dense_sens/((float) dense_sens)

  float dense_thresh_influence; // evolvable parameter: density_count/dense_thresh is the threshold for deciding to be influenced by pheromones at nest if any present
  float dense_const_influence; // evolvable parameter: sensitivity of the decision to be influenced by pheromones at nest if any present.  rand()%dense_sens/((float) dense_sens)

  float prop_active; //evolvable parameter: proportion of foragers active at model init
  float decay_rate_return; // evolvable parameter: decay rate of return "pheromone"
  float activate_sensitivity; // responsiveness of idle foragers to return of incoming, recruiting foragers.  0.0 is no response.

  float seeds_collected; // selection heuristic: count of all seeds returned to nest
  float ant_time_out; // selection heuristic: count of time steps ants have spent outside nest
  float fitness; // selection heuristic.

 private:
};
