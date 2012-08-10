class Ant
{
 public:
  Ant()
    {
      x = 0;
      y = 0;
      rfidx = 0;
      rfidy = 0;
      return_x = -1;
      return_y = -1;
      prevx = -1;
      prevy = -1;
      search_time = -1;
      search_time_counter = 0;
      travel_time_counter = 0;
      return_time_counter = 0;
      ant_status = 4;
      influenceable = false;
      carrying = 0;
      since_move = 0;
      pen_down = false;
      prev_pher = 0.0f;
      prev_pher_scent = 0.0f;
      direction = 0.0f;
      search_direction = 360.0f;
    }

  int x, y;
  int rfidx, rfidy; // ant's rfid reader's x and y coordinates -- rfid reader trails behind antbot as it searches
  int return_x, return_y; // coordinates of last seed found
  int prevx, prevy; // location ant moved from on previous search move.
  int search_time; // time since ant began its search
  int search_time_counter,travel_time_counter,return_time_counter;
  int ant_status; // 0 = no ant; 1 = ant following trail; 2 = ant carrying food; 3 = searching ant; 4 = traveling ant
  bool influenceable; // ant will be influenced by any pheromone trails at nest entrance? true = ants will follow pheromones if present instead of walk at random or return to patch
  int carrying; // food type ant is carrying: 0 = no food; # = foot item of distribution #
  int since_move; // time steps since a searching ant last moved.
  bool pen_down; // false = ant not laying a trail; true = ant laying a trail
  float prev_pher; // Amount of pheromone on previous cell as ant moved along trail.
  float prev_pher_scent; // The out-going sum_pheromone an detected on the previous move by an ant following a trail.
  float direction; // direction an ant who detected no trail at nest is travelling.  value in degrees.
  float search_direction; // direction in degrees that a searching ant moved in the previous time step (ideal direction, not grid direction)

 private:
};
