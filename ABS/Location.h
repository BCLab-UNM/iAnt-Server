class Location
{
 public:

  Location()
    {
      p1 = 0;
      p2 = 0;
      p1_time_updated = 0;
      p2_time_updated = 0;
      ant_status = 0;
      carrying = 0;
      food = 0;
      nseeds = 0;
      nest = false;
      pen_down = false;
    }

  float p1;  // indicates the end of a trail
  float p2;  // pheromone that ants follow
  int p1_time_updated; // time X-marks-the-spot pheromone was updated at this location
  int p2_time_updated; // time pheromones were updated at this location

  int ant_status; // 0 = no ant, 1 = traveling ant, 2 = ant carrying food; 3 = searching ant
  int carrying; // food type ant is carrying: 0 = no food; # = foot item of distribution #
  int food; // 0 = no food; # = food item of distribution #
  int nseeds; // number of seeds at this location
  bool nest;
  bool pen_down; // false = ant not laying a trail; true = ant laying a trail

 private:
  
};
