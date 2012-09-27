/* 
 * AntBot GA
 * By Kenneth
 *
 * Bjorn had to change it to make it play nicely with Objective-C.
 * Here's what Bjorn changed:
 *   - Removed most if not all cout's (for now).
 *   - This file is no longer the program entry point,
 *     so 'int main(argc,argv)' was changed to 'NSArray* mainLoop()',
 *     allowing other classes to call the GA whenever needed.
 *     The extension was changed from cpp to mm, as we are now introducing
 *     Objective-C types, making it Objective-C++ (.mm).
 *   - 'const float pi' was causing some problems, so I had to
 *     comment it out ('cannot redefine pi with a different type').
 *   - At the end of mainLoop, I return the average of all the colony 
 *     parameters in an NSArray.
 *     You'll see floats named the parameter name suffixed with '_sum',
 *     and a loop that sums up all of the parameters.  I then create an
 *     NSArray with each element equal to the sum'd parameter divided by
 *     the number of colonies (yielding the average optimal parameter).
 *     This array now contains the 'optimal' parameters and is returned.
 */

/* #ifdef __APPLE__
 #include <OpenGL/OpenGL.h>
 #include <GLUT/glut.h>
 #else
 #include <GL/glut.h>
 #endif */

#include "Location.h"
#include "Ant.h"
#include "Colony.h"

#import <Cocoa/Cocoa.h>

#define RANDOM_GENERATOR TRandomMersenne
#include "stocc/stocc.h"

#include "stocc/mersenne.cpp"	// code for random number generator
#include "stocc/stoc1.cpp"	// random library source code
#include "stocc/userintf.cpp"	// define system specific user interface


#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <iostream>

using namespace std;

void run ();
// void main_display();
// void main_handleResize(int w, int h);

static int update_count = 0;

int pixel_width = 1000;
int pixel_height = 1000;
int subpixel_width = 500;
int subpixel_height = 512;

int main_window;
int instance_window;
int progress_window;

const int n_colonies = 200;
const int n_generations = 100;
const int n_evals = 8;
const int n_steps = 13500 / 2;
const int n_ants = 6;
const float ant_time_out_cost = 0.0000;

const bool recruit = true;	// Turns pheromones on/off
const bool patch = true;	// Turns site fidelity on/off

int search_delay = 4;		// time steps between a searching ant's move.  0 is move on every time step.
int return_delay = 0;		// time steps between a returning ant's move.  0 is move on every time step.
int crossover_rate = 10;	// Percent chance for crossover.  50 is complete shuffling.  0 or 100 is no crossover

const int clumpradius = 2;
const int n_food_red = 8;	// one pile
const int n_food_orange = 8;	// two piles
const int n_food_green = 8;	// four piles
const int n_food_purple = 0;	// 64 piles -- not part of the AntBot setup
const int n_food_blue = 8;	// random
const int num_each_clump = 6676 / 32;	// 6676/256; // 118/32; // 128/32; 6676/32
const int n_food_background = 256 * (100 - num_each_clump) * 0;	// random
int count_food_red = 0;
int count_food_orange = 0;
int count_food_green = 0;
int count_food_blue = 0;
const int grid_height = 768;	//106; //177; //200; //768;  //each grid cell is 10x10 cm
const int grid_width = 768;	//106; //177; //200; //768;
const int nestx = grid_width / 2;
const int nesty = grid_height / 2;
//const float pi = 3.14159;
int count_food1;
int count_food2;
int pherminx = nestx;
int phermaxx = nestx;
int pherminy = nesty;
int phermaxy = nesty;
float deposit_rate_p2 = 0.1;
float saturation_p1 = 1.0;
float saturation_p2 = 1.0;
int smell_range = 1;
float return_pheromone = 0.0;

int sumdx = 0;
int sumdy = 0;

// Standard grid to use across all colonies in a generation
Location gen_grid[grid_width][grid_height];
// Grid to use for each colony within a generation
Location grid[grid_width][grid_height];
Colony colonies[n_colonies];
int col_count;
Ant ants[n_ants];

StochasticLib1 sto ((int)time (NULL));

NSArray*
mainLoop ()
{
    //output settings for this run
    /*cout << "Density patch recruit antbots natural rfid multi-eval run" << endl;
     cout << "Recruit: " << recruit << endl;
     cout << "Patch: " << patch << endl;
     cout << "Grid height: " << grid_height << endl;
     cout << "Grid width: " << grid_width << endl;
     cout << "Red clump size: " << n_food_red << endl;
     cout << "Orange clump size: " << n_food_orange << endl;
     cout << "Green clump size: " << n_food_green << endl;
     cout << "Purple clump size: " << n_food_purple << endl;
     cout << "Clump number: " << num_each_clump << endl;
     cout << "Random seeds: " << n_food_blue * num_each_clump << endl;
     cout << "Background food: 256*" << n_food_background / 256 << endl;
     cout << "Colony size: " << n_ants << endl;
     cout << "Time steps: " << n_steps << endl;
     cout << "Number of evals: " << n_evals << endl;
     cout << "Number of colonies: " << n_colonies << endl;
     cout << "Seeds cost per time outside nest: " << ant_time_out_cost << endl;*/
    
    srand ((int)time (NULL));
    
    // Initialize first generation of colonies
    for (col_count = 0; col_count < n_colonies; col_count++)
    {
        // Mutation to create a normal distribution around above starting values
        colonies[col_count].decay_rate +=
        sto.Normal (0, colonies[col_count].decay_rate * 0.3);
        if (colonies[col_count].decay_rate < 0.0f)
            colonies[col_count].decay_rate = 0;
        colonies[col_count].search_giveup_rate +=
        sto.Normal (0, colonies[col_count].search_giveup_rate * 0.3);
        if (colonies[col_count].search_giveup_rate < 0.0f)
            colonies[col_count].search_giveup_rate = 0;
        colonies[col_count].trail_drop_rate +=
        sto.Normal (0, colonies[col_count].trail_drop_rate * 0.3);
        if (colonies[col_count].trail_drop_rate < 0.0f)
            colonies[col_count].trail_drop_rate = 0;
        //              colonies[col_count].walk_drop_rate += sto.Normal(0,colonies[col_count].walk_drop_rate*0.3);
        //              if (colonies[col_count].walk_drop_rate < 0.0f) colonies[col_count].walk_drop_rate = 0;
        colonies[col_count].dir_dev_const +=
        sto.Normal (0, colonies[col_count].dir_dev_const * 0.1);
        if (colonies[col_count].dir_dev_const < 0.0f)
            colonies[col_count].dir_dev_const = 0;
        //              colonies[col_count].dir_dev_coeff1 += sto.Normal(0,0.2+(abs(colonies[col_count].dir_dev_coeff1*0.1)));
        //              if (colonies[col_count].dir_dev_coeff1 < 0.0f) colonies[col_count].dir_dev_coeff1 = 0;
        //              colonies[col_count].dir_time_pow1 += sto.Normal(0,colonies[col_count].dir_time_pow1*0.4);
        //              if (colonies[col_count].dir_time_pow1 < 0.0f) colonies[col_count].dir_time_pow1 = 0;
        //              colonies[col_count].dir_dev_coeff2 += sto.Normal(0,0.2+(abs(colonies[col_count].dir_dev_coeff2*0.1)));
        //              if (colonies[col_count].dir_dev_coeff2 < 0.0f) colonies[col_count].dir_dev_coeff2 = 0;
        //              colonies[col_count].dir_time_pow2 += sto.Normal(0,colonies[col_count].dir_time_pow2*0.4);
        //              if (colonies[col_count].dir_time_pow2 < 0.0f) colonies[col_count].dir_time_pow2 = 0;
        //              colonies[col_count].dense_sens += sto.Normal(0,1);
        //              if (colonies[col_count].dense_sens < 1) colonies[col_count].dense_sens = 1;
        //              colonies[col_count].dense_thresh += sto.Normal(0,colonies[col_count].dense_thresh*0.4);
        //              if (colonies[col_count].dense_thresh < 1.0f) colonies[col_count].dense_thresh = 1.0;
        //              colonies[col_count].dense_const += sto.Normal(0,colonies[col_count].dense_const*0.4);
        colonies[col_count].prop_active = 1.0;	// setting prop_active to one for now, and turning off mutation.
        
        // ...Or, random starting values
        colonies[col_count].decay_rate = rand () % 20000 / 1000000.0f;
        colonies[col_count].walk_drop_rate = rand () % 20000 / 1000000.0f;
        colonies[col_count].search_giveup_rate = rand () % 10000 / 1000000.0f;
        colonies[col_count].trail_drop_rate = rand () % 20000 / 1000000.0f;
        colonies[col_count].dir_dev_const = rand () % 314 / 100.0f;
        //              colonies[col_count].dir_dev_coeff1 = rand()%314/100.0f;
        //              colonies[col_count].dir_time_pow1 = rand()%100/100.0f;
        colonies[col_count].dir_dev_coeff2 = rand () % 314 / 100.0f;
        colonies[col_count].dir_time_pow2 = rand () % 200 / 1000.0f;
        //              colonies[col_count].dense_sens = rand()%9+1;
        if (recruit)
        {
            colonies[col_count].dense_thresh = rand () % 80 / 10.0f;
            colonies[col_count].dense_const = rand () % 200 / 100.0f - 1;
        }
        else
        {
            colonies[col_count].dense_thresh = 1.0;
            colonies[col_count].dense_const = -9.0;
        }
        if (patch)
        {
            colonies[col_count].dense_thresh_patch = rand () % 80 / 10.0f;
            colonies[col_count].dense_const_patch = rand () % 200 / 100.0f - 1;
        }
        else
        {
            colonies[col_count].dense_thresh_patch = 1.0;
            colonies[col_count].dense_const_patch = -9.0;
        }
        colonies[col_count].dense_thresh_influence = rand () % 80 / 10.0f;
        colonies[col_count].dense_const_influence = rand () % 200 / 100.0f - 1;
        //              colonies[col_count].prop_active = rand()%100/100.0f;
        colonies[col_count].activate_sensitivity = rand () % 100 / 100.0f;
        colonies[col_count].decay_rate_return = rand () % 500 / 1000.0f;
        
        // Specification of starting values for parameters, if desired
        /*		colonies[col_count].decay_rate = 0.00131909;
         colonies[col_count].trail_drop_rate = 0.00103382;
         colonies[col_count].walk_drop_rate = 0.00141963;
         colonies[col_count].dir_dev_const = 0.0253045;
         colonies[col_count].dir_dev_coeff1 = 0.0;
         colonies[col_count].dir_time_pow1 = 0.0;
         colonies[col_count].dir_dev_coeff2 = 2.542501;
         colonies[col_count].dir_time_pow2 = 0.224648;
         //		colonies[col_count].dense_sens = 0;
         colonies[col_count].dense_thresh = 3.28275;
         colonies[col_count].dense_const = -.5159983;
         colonies[col_count].dense_thresh_patch = 1.0;
         colonies[col_count].dense_const_patch = -0.109913;
         colonies[col_count].prop_active = 0.1;
         colonies[col_count].activate_sensitivity = 1.0;
         colonies[col_count].decay_rate_return = 0.01; */
        
    }
    
    // Initialize glut 
    // Leave this off for GA run in the interest of speed.  Can un-comment all glut-related code to see the model running, but it will only show the first colony of the first generation
    //      glutInit( &argc, argv );
    //      glutInitDisplayMode( GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH );
    //      glutInitWindowSize(pixel_width, pixel_height);
    
    
    // GA MAIN LOOP
    /*cout <<
     "generation\tmeanseeds\tdecay_rate\twalk_drop_rate\tsearch_giveup_rate\ttrail_drop_rate\tdir_const\tdir_coeff2\tdir_time2\tdense_thresh\tdense_const\tdense_thresh_patch\tdense_const_patch\tdense_thresh_infl\tdense_const_infl\tprop_active\tactivate_sensitivity\tdecay_rate_return\tmean seeds\tbest"
     << endl;*/
    for (int gen_count = 0; gen_count < n_generations; gen_count++)
    {
        for (int eval_count = 0; eval_count < n_evals; eval_count++)
        {
            // Clean up grid for new evalution
            for (int x = 0; x < grid_width; x++)
            {
                for (int y = 0; y < grid_width; y++)
                {
                    gen_grid[x][y].p1 = 0;
                    gen_grid[x][y].p2 = 0;
                    gen_grid[x][y].ant_status = 0;
                    gen_grid[x][y].carrying = 0;
                    gen_grid[x][y].food = 0;
                    gen_grid[x][y].nest = false;
                    gen_grid[x][y].pen_down = false;
                }
            }
            
            // Place nest entrance
            gen_grid[nestx][nesty].nest = true;
            
            int locations[4 * num_each_clump][2];
            int food_count = 0;
            int tempradius = clumpradius;
            int rad_count = 0;
            for (int clump_count = 1; clump_count <= num_each_clump;
                 clump_count++)
            {
                int clumpx;
                int clumpy;
                int overlap = 1;
                // Place red food -- one big pile
                while (overlap == 1)
                {
                    clumpx =
                    rand () % (grid_width - clumpradius * 2) + clumpradius;
                    clumpy =
                    rand () % (grid_height - clumpradius * 2) + clumpradius;
                    overlap = 0;
                    int clumpcheck = 0;
                    while (clumpcheck < (4 * clump_count - 4))
                    {
                        
                        if (sqrt
                            (pow (clumpx - locations[clumpcheck][0], 2) +
                             pow (clumpy - locations[clumpcheck][1],
                                  2)) < clumpradius * 2)
                            overlap = 1;
                        clumpcheck++;
                    }
                    
                }
                locations[4 * clump_count - 4][0] = clumpx;
                locations[4 * clump_count - 4][1] = clumpy;
                food_count = 0;
                while (food_count < n_food_red)
                {
                    if (rad_count > n_food_red * 4)
                    {
                        tempradius++;
                        rad_count = 0;
                    }
                    int randx =
                    rand () % (tempradius * 2) + clumpx - tempradius;
                    int randy =
                    rand () % (tempradius * 2) + clumpy - tempradius;
                    float seeddist =
                    sqrt (pow (clumpx - randx, 2) + pow (clumpy - randy, 2));
                    if (randx < 0 || randx > grid_width || randy < 0
                        || randy > grid_height)
                    {
                        continue;
                    }
                    else if ((gen_grid[randx][randy].food == 0) &
                             (seeddist < tempradius))
                    {
                        gen_grid[randx][randy].food = 1;
                        food_count++;
                    }
                    rad_count++;
                }
                // Place orange food -- two piles
                for (int i = 0; i < 2; i++)
                {
                    int overlap = 1;
                    while (overlap == 1)
                    {
                        clumpx =
                        rand () % (grid_width - clumpradius * 2) +
                        clumpradius;
                        clumpy =
                        rand () % (grid_height - clumpradius * 2) +
                        clumpradius;
                        overlap = 0;
                        int clumpcheck = 0;
                        while (clumpcheck < (4 * clump_count - 3))
                        {
                            if (sqrt
                                (pow (clumpx - locations[clumpcheck][0], 2) +
                                 pow (clumpy - locations[clumpcheck][1],
                                      2)) < clumpradius * 2)
                                overlap = 1;
                            clumpcheck++;
                        }
                    }
                    locations[4 * clump_count - 3][0] = clumpx;
                    locations[4 * clump_count - 3][1] = clumpy;
                    food_count = 0;
                    tempradius = clumpradius;
                    rad_count = 0;
                    while (food_count < n_food_orange / 2)
                    {
                        if (rad_count > n_food_orange * 4)
                        {
                            tempradius++;
                            rad_count = 0;
                        }
                        int randx =
                        rand () % (tempradius * 2) + clumpx - tempradius;
                        int randy =
                        rand () % (tempradius * 2) + clumpy - tempradius;
                        float clumpdist =
                        sqrt (pow (clumpx - randx, 2) +
                              pow (clumpy - randy, 2));
                        if (randx < 0 || randx > grid_width || randy < 0
                            || randy > grid_height)
                        {
                            continue;
                        }
                        else if ((gen_grid[randx][randy].food == 0) &
                                 (clumpdist < tempradius))
                        {
                            gen_grid[randx][randy].food = 2;
                            food_count++;
                        }
                        rad_count++;
                    }
                }
                
                
                // Place green food -- four piles
                for (int i = 0; i < 4; i++)
                {
                    int overlap = 1;
                    while (overlap == 1)
                    {
                        clumpx =
                        rand () % (grid_width - clumpradius * 2) +
                        clumpradius;
                        clumpy =
                        rand () % (grid_height - clumpradius * 2) +
                        clumpradius;
                        overlap = 0;
                        int clumpcheck = 0;
                        while (clumpcheck < (4 * clump_count - 2))
                        {
                            if (sqrt
                                (pow (clumpx - locations[clumpcheck][0], 2) +
                                 pow (clumpy - locations[clumpcheck][1],
                                      2)) < clumpradius * 2)
                                overlap = 1;
                            clumpcheck++;
                        }
                    }
                    locations[4 * clump_count - 2][0] = clumpx;
                    locations[4 * clump_count - 2][1] = clumpy;
                    food_count = 0;
                    tempradius = clumpradius;
                    rad_count = 0;
                    while (food_count < n_food_green / 4)
                    {
                        if (rad_count > n_food_green * 4)
                        {
                            tempradius++;
                            rad_count = 0;
                        }
                        int randx =
                        rand () % (tempradius * 2) + clumpx - tempradius;
                        int randy =
                        rand () % (tempradius * 2) + clumpy - tempradius;
                        float clumpdist =
                        sqrt (pow (clumpx - randx, 2) +
                              pow (clumpy - randy, 2));
                        if (randx < 0 || randx > grid_width || randy < 0
                            || randy > grid_height)
                        {
                            continue;
                        }
                        else if ((gen_grid[randx][randy].food == 0) &
                                 (clumpdist < tempradius))
                        {
                            gen_grid[randx][randy].food = 3;
                            food_count++;
                        }
                        rad_count++;
                    }
                }
                
                
                // Place purple food
                for (int i = 0; i < 64; i++)
                {
                    int overlap = 1;
                    while (overlap == 1)
                    {
                        clumpx =
                        rand () % (grid_width - clumpradius * 2) +
                        clumpradius;
                        clumpy =
                        rand () % (grid_height - clumpradius * 2) +
                        clumpradius;
                        overlap = 0;
                        int clumpcheck = 0;
                        while (clumpcheck < (4 * clump_count - 1))
                        {
                            if (sqrt
                                (pow (clumpx - locations[clumpcheck][0], 2) +
                                 pow (clumpy - locations[clumpcheck][1],
                                      2)) < clumpradius * 2)
                                overlap = 1;
                            clumpcheck++;
                        }
                    }
                    locations[4 * clump_count - 1][0] = clumpx;
                    locations[4 * clump_count - 1][1] = clumpy;
                    food_count = 0;
                    tempradius = clumpradius;
                    rad_count = 0;
                    while (food_count < n_food_purple / 64)
                    {
                        if (rad_count > n_food_purple * 4)
                        {
                            tempradius++;
                            rad_count = 0;
                        }
                        int randx =
                        rand () % (tempradius * 2) + clumpx - tempradius;
                        int randy =
                        rand () % (tempradius * 2) + clumpy - tempradius;
                        float clumpdist =
                        sqrt (pow (clumpx - randx, 2) +
                              pow (clumpy - randy, 2));
                        if (randx < 0 || randx > grid_width || randy < 0
                            || randy > grid_height)
                        {
                            continue;
                        }
                        else if ((gen_grid[randx][randy].food == 0) &
                                 (clumpdist < tempradius))
                        {
                            gen_grid[randx][randy].food = 4;
                            food_count++;
                        }
                        rad_count++;
                    }
                }
                
                
                // Place blue food -- random scattering of food
                food_count = 0;
                while (food_count < n_food_blue)
                {
                    int randx = rand () % grid_width;
                    int randy = rand () % grid_height;
                    if (gen_grid[randx][randy].food == 0)
                    {
                        gen_grid[randx][randy].food = 5;
                        food_count++;
                    }
                }
            }
            
            // Place background food
            food_count = 0;
            while (food_count <= n_food_background)
            {
                int randx = rand () % grid_width;
                int randy = rand () % grid_height;
                if (gen_grid[randx][randy].food == 0)
                {
                    // cout << "Food added" << endl;
                    gen_grid[randx][randy].food = 5;
                    food_count++;
                }
            }
            
            // Evaluation Loop
            for (col_count = 0; col_count < n_colonies; col_count++)
            {
                // Reset grid for next colony
                return_pheromone = 0.0;
                for (int x = 0; x < grid_width; x++)
                {
                    for (int y = 0; y < grid_width; y++)
                    {
                        grid[x][y].p1 = gen_grid[x][y].p1;
                        grid[x][y].p2 = gen_grid[x][y].p2;
                        grid[x][y].ant_status = gen_grid[x][y].ant_status;
                        grid[x][y].carrying = gen_grid[x][y].carrying;
                        grid[x][y].food = gen_grid[x][y].food;
                        grid[x][y].nest = gen_grid[x][y].nest;
                        grid[x][y].pen_down = gen_grid[x][y].pen_down;
                    }
                }
                
                // Clean up ants
                int n_active_ants =
                ceil (n_ants * colonies[col_count].prop_active);
                for (int i = 0; i < n_ants; i++)
                {
                    ants[i].x = nestx;
                    ants[i].y = nesty;
                    ants[i].search_time = 0;
                    ants[i].prevx = -1;
                    ants[i].prevy = -1;
                    ants[i].ant_status = 4;
                    ants[i].carrying = 0;
                    ants[i].pen_down = false;
                    ants[i].prev_pher_scent = 0.0f;
                    ants[i].direction = rand () % 360;
                    if (i < n_active_ants)
                    {
                        ants[i].ant_status = 4;
                        ants[i].direction = rand () % 360;
                    }
                    else
                    {
                        ants[i].ant_status = 0;
                    }
                }
                
                
                // Run evalution for n_steps time steps
                update_count = 0;
                while (update_count < n_steps)
                {
                    run ();
                    //                                      cout << "." << endl;
                }
                // GRAPHICS OFF FOR GA
                // Create the main outer window
                //                      int generation = gen_count+1;
                //                      int colony_number = col_count+1;
                /*				main_window = glutCreateWindow("Colony Evaluation");
                 // main_window = glutCreateWindow(strcat("Colony Evaluation: Generation ",strcat((char) generation,strcat(", Colony ",(char) colony_number))));
                 
                 glutDisplayFunc(main_display);
                 glutReshapeFunc(main_handleResize);
                 // End create outer window
                 
                 //gluOrtho2D(0, 1000, 1000, 0);
                 glEnable(GL_DEPTH_TEST); // To make GL draw items behind others when necessary
                 
                 //gluOrtho2D(0, 1000, 1000, 0);
                 glEnable(GL_DEPTH_TEST); // To make GL draw items behind others when necessary
                 
                 glutIdleFunc(run);
                 
                 // Specify the root model calculation function
                 glutMainLoop();
                 
                 // Close the main outer window
                 // glutDestroyWindow(main_window);
                 */
                // End Evaluation Loop
                // Adjust seeds_collected (fitness) for amount of time ants spent outside nest.
                colonies[col_count].seeds_collected -=
                colonies[col_count].ant_time_out * ant_time_out_cost;
            }
        }
        // Populate next generation
        Colony new_colonies[n_colonies];
        for (int i = 0; i < n_colonies; i++)
        {
            int parent1;
            int parent2;
            int candidate1;
            int candidate2;
            // 1st parent candidates
            candidate1 = rand () % n_colonies;
            candidate2 = rand () % n_colonies;
            while (candidate1 == candidate2)
                candidate2 = rand () % n_colonies;
            if (colonies[candidate1].seeds_collected >
                colonies[candidate2].seeds_collected)
            {
                parent1 = candidate1;
            }
            else
            {
                parent1 = candidate2;
            }
            // 2nd parent candidates
            candidate1 = rand () % n_colonies;
            candidate2 = rand () % n_colonies;
            while (candidate1 == candidate2)
                candidate2 = rand () % n_colonies;
            if (colonies[candidate1].seeds_collected >
                colonies[candidate2].seeds_collected)
            {
                parent2 = candidate1;
            }
            else
            {
                parent2 = candidate2;
            }
            
            // Independent assortment of decay_rate parameter
            if (rand () % 100 < crossover_rate)
            {
                new_colonies[i].decay_rate = colonies[parent1].decay_rate;
            }
            else
            {
                new_colonies[i].decay_rate = colonies[parent2].decay_rate;
            }
            
            // Independent assortment of walk_drop_rate parameter
            if (rand () % 100 < crossover_rate)
            {
                new_colonies[i].walk_drop_rate =
                colonies[parent1].walk_drop_rate;
            }
            else
            {
                new_colonies[i].walk_drop_rate =
                colonies[parent2].walk_drop_rate;
            }
            
            // Independent assortment of search_giveup_rate parameter
            if (rand () % 100 < crossover_rate)
            {
                new_colonies[i].search_giveup_rate =
                colonies[parent1].search_giveup_rate;
            }
            else
            {
                new_colonies[i].search_giveup_rate =
                colonies[parent2].search_giveup_rate;
            }
            
            // Independent assortment of trail_drop_rate parameter
            if (rand () % 100 < crossover_rate)
            {
                new_colonies[i].trail_drop_rate =
                colonies[parent1].trail_drop_rate;
            }
            else
            {
                new_colonies[i].trail_drop_rate =
                colonies[parent2].trail_drop_rate;
            }
            
            // Independent assortment of dir_dev_const parameter
            if (rand () % 100 < crossover_rate)
            {
                new_colonies[i].dir_dev_const = colonies[parent1].dir_dev_const;
            }
            else
            {
                new_colonies[i].dir_dev_const = colonies[parent2].dir_dev_const;
            }
            
            // Independent assortment of dir_dev_coeff1 parameter
            if (rand () % 100 < crossover_rate)
            {
                new_colonies[i].dir_dev_coeff1 =
                colonies[parent1].dir_dev_coeff1;
            }
            else
            {
                new_colonies[i].dir_dev_coeff1 =
                colonies[parent2].dir_dev_coeff1;
            }
            
            // Independent assortment of dir_time_pow1 parameter
            if (rand () % 100 < crossover_rate)
            {
                new_colonies[i].dir_time_pow1 = colonies[parent1].dir_time_pow1;
            }
            else
            {
                new_colonies[i].dir_time_pow1 = colonies[parent2].dir_time_pow1;
            }
            
            // Independent assortment of dir_dev_coeff2 parameter
            if (rand () % 100 < crossover_rate)
            {
                new_colonies[i].dir_dev_coeff2 =
                colonies[parent1].dir_dev_coeff2;
            }
            else
            {
                new_colonies[i].dir_dev_coeff2 =
                colonies[parent2].dir_dev_coeff2;
            }
            
            // Independent assortment of dir_time_pow2 parameter
            if (rand () % 100 < crossover_rate)
            {
                new_colonies[i].dir_time_pow2 = colonies[parent1].dir_time_pow2;
            }
            else
            {
                new_colonies[i].dir_time_pow2 = colonies[parent2].dir_time_pow2;
            }
            
            // Independent assortment of dense_sens parameter
            if (rand () % 100 < crossover_rate)
            {
                new_colonies[i].dense_sens = colonies[parent1].dense_sens;
            }
            else
            {
                new_colonies[i].dense_sens = colonies[parent2].dense_sens;
            }
            // Independent assortment of dense_thresh parameter
            if (rand () % 100 < crossover_rate)
            {
                new_colonies[i].dense_thresh = colonies[parent1].dense_thresh;
            }
            else
            {
                new_colonies[i].dense_thresh = colonies[parent2].dense_thresh;
            }
            // Independent assortment of dense_const parameter
            if (rand () % 100 < crossover_rate)
            {
                new_colonies[i].dense_const = colonies[parent1].dense_const;
            }
            else
            {
                new_colonies[i].dense_const = colonies[parent2].dense_const;
            }
            // Independent assortment of dense_const_patch parameter
            if (rand () % 100 < crossover_rate)
            {
                new_colonies[i].dense_const_patch =
                colonies[parent1].dense_const_patch;
            }
            else
            {
                new_colonies[i].dense_const_patch =
                colonies[parent2].dense_const_patch;
            }
            // Independent assortment of dense_thresh_patch parameter
            if (rand () % 100 < crossover_rate)
            {
                new_colonies[i].dense_thresh_patch =
                colonies[parent1].dense_thresh_patch;
            }
            else
            {
                new_colonies[i].dense_thresh_patch =
                colonies[parent2].dense_thresh_patch;
            }
            
            // Independent assortment of dense_const_influence parameter
            if (rand () % 100 < crossover_rate)
            {
                new_colonies[i].dense_const_influence =
                colonies[parent1].dense_const_influence;
            }
            else
            {
                new_colonies[i].dense_const_influence =
                colonies[parent2].dense_const_influence;
            }
            // Independent assortment of dense_thresh_influence parameter
            if (rand () % 100 < crossover_rate)
            {
                new_colonies[i].dense_thresh_influence =
                colonies[parent1].dense_thresh_influence;
            }
            else
            {
                new_colonies[i].dense_thresh_influence =
                colonies[parent2].dense_thresh_influence;
            }
            
            // Independent assortment of prop_active parameter
            if (rand () % 100 < crossover_rate)
            {
                new_colonies[i].prop_active = colonies[parent1].prop_active;
            }
            else
            {
                new_colonies[i].prop_active = colonies[parent2].prop_active;
            }
            // Independent assortment of activate_sensitivity parameter
            if (rand () % 100 < crossover_rate)
            {
                new_colonies[i].activate_sensitivity =
                colonies[parent1].activate_sensitivity;
            }
            else
            {
                new_colonies[i].activate_sensitivity =
                colonies[parent2].activate_sensitivity;
            }
            // Independent assortment of decay_rate_return parameter
            if (rand () % 100 < crossover_rate)
            {
                new_colonies[i].decay_rate_return =
                colonies[parent1].decay_rate_return;
            }
            else
            {
                new_colonies[i].decay_rate_return =
                colonies[parent2].decay_rate_return;
            }
            
            // Random mutation
            if (rand () % 10 == 0)
            {
                new_colonies[i].decay_rate +=
                sto.Normal (0, new_colonies[i].decay_rate * 0.05);
                if (new_colonies[i].decay_rate < 0.0f)
                    new_colonies[i].decay_rate = 0;
                if (new_colonies[i].decay_rate > 1.0f)
                    new_colonies[i].decay_rate = 1.0f;
            }
            // Random mutation
            if (rand () % 10 == 0)
            {
                new_colonies[i].walk_drop_rate +=
                sto.Normal (0, new_colonies[i].walk_drop_rate * 0.05);
                if (new_colonies[i].walk_drop_rate < 0.0f)
                    new_colonies[i].walk_drop_rate = 0;
                if (new_colonies[i].walk_drop_rate > 1.0f)
                    new_colonies[i].walk_drop_rate = 1.0f;
            }
            // Random mutation
            if (rand () % 10 == 0)
            {
                new_colonies[i].search_giveup_rate +=
                sto.Normal (0, new_colonies[i].search_giveup_rate * 0.05);
                if (new_colonies[i].search_giveup_rate < 0.0f)
                    new_colonies[i].search_giveup_rate = 0;
                if (new_colonies[i].search_giveup_rate > 1.0f)
                    new_colonies[i].search_giveup_rate = 1.0f;
            }
            // Random mutation
            if (rand () % 10 == 0)
            {
                new_colonies[i].trail_drop_rate +=
                sto.Normal (0, new_colonies[i].trail_drop_rate * .05);
                if (new_colonies[i].trail_drop_rate < 0.0f)
                    new_colonies[i].trail_drop_rate = 0;
                if (new_colonies[i].trail_drop_rate > 1.0f)
                    new_colonies[i].trail_drop_rate = 1.0f;
            }
            // Random mutation
            if (rand () % 10 == 0)
            {
                new_colonies[i].dir_dev_const +=
                sto.Normal (0,
                            0.001 +
                            fabs (new_colonies[i].dir_dev_const * .05));
                if (new_colonies[i].dir_dev_const < 0.0f)
                    new_colonies[i].dir_dev_const = 0;
            }
            // Random mutation
            if (rand () % 10 == 0)
            {
                new_colonies[i].dir_dev_coeff2 +=
                sto.Normal (0,
                            0.001 +
                            fabs (new_colonies[i].dir_dev_coeff2 * .05));
                if (new_colonies[i].dir_dev_coeff2 < 0.0f)
                    new_colonies[i].dir_dev_coeff2 = 0;
            }
            // Random mutation
            if (rand () % 10 == 0)
            {
                new_colonies[i].dir_time_pow2 +=
                sto.Normal (0,
                            0.001 +
                            fabs (new_colonies[i].dir_time_pow2 * .05));
                if (new_colonies[i].dir_time_pow2 < 0.0f)
                    new_colonies[i].dir_time_pow2 = 0;
            }
            // Random mutation
            if (recruit)
            {
                if (rand () % 10 == 0)
                {
                    new_colonies[i].dense_thresh +=
                    sto.Normal (0,
                                0.001 +
                                fabs (new_colonies[i].dense_thresh * .05));
                }
                if (rand () % 10 == 0)
                {
                    new_colonies[i].dense_const +=
                    sto.Normal (0,
                                0.001 +
                                fabs (new_colonies[i].dense_const * .05));
                }
            }
            if (patch)
            {
                if (rand () % 10 == 0)
                {
                    new_colonies[i].dense_const_patch +=
                    sto.Normal (0,
                                0.001 +
                                fabs (new_colonies[i].dense_const_patch *
                                      .05));
                }
                if (rand () % 10 == 0)
                {
                    new_colonies[i].dense_thresh_patch +=
                    sto.Normal (0,
                                0.001 +
                                fabs (new_colonies[i].dense_thresh_patch *
                                      .05));
                }
            }
            if (rand () % 10 == 0)
            {
                new_colonies[i].dense_const_influence +=
                sto.Normal (0,
                            0.001 +
                            fabs (new_colonies[i].dense_const_influence *
                                  .05));
            }
            if (rand () % 10 == 0)
            {
                new_colonies[i].dense_thresh_influence +=
                sto.Normal (0,
                            0.001 +
                            fabs (new_colonies[i].dense_thresh_influence *
                                  .05));
            }
            /*		Not bothering with this for the AntBots
             if (rand()%10 == 0)
             {
             new_colonies[i].prop_active += sto.Normal(0,0.001+fabs(new_colonies[i].prop_active*.05));
             if (new_colonies[i].prop_active < 0.0001f) new_colonies[i].prop_active = 0.001;
             if (new_colonies[i].prop_active > 1.0f) new_colonies[i].prop_active = 1.0;
             } */
            if (rand () % 10 == 0)
            {
                new_colonies[i].activate_sensitivity +=
                sto.Normal (0,
                            0.001 +
                            fabs (new_colonies[i].activate_sensitivity *
                                  .05));
                if (new_colonies[i].activate_sensitivity < 0.0f)
                    new_colonies[i].activate_sensitivity = 0.0;
            }
            if (rand () % 10 == 0)
            {
                new_colonies[i].decay_rate_return +=
                sto.Normal (0,
                            0.001 +
                            fabs (new_colonies[i].decay_rate_return * .05));
                if (new_colonies[i].decay_rate_return < 0.0f)
                    new_colonies[i].decay_rate_return = 0.0;
                if (new_colonies[i].decay_rate_return > 1.0f)
                    new_colonies[i].decay_rate_return = 1.0;
            }
            
        }
        
        // Set next generation of colonies, and obtain means for previous generation
        float sum_seeds = 0;
        int best_seeds = 0;
        float sum_decay = 0;
        float sum_walk_drop = 0;
        float sum_search_giveup = 0;
        float sum_trail_drop = 0;
        float sum_dir_dev_const = 0;
        float sum_dir_dev_coeff1 = 0;
        float sum_dir_time_pow1 = 0;
        float sum_dir_dev_coeff2 = 0;
        float sum_dir_time_pow2 = 0;
        float sum_dense_sens = 0;
        float sum_dense_thresh = 0;
        float sum_dense_const = 0;
        float sum_dense_thresh_patch = 0;
        float sum_dense_const_patch = 0;
        float sum_dense_thresh_influence = 0;
        float sum_dense_const_influence = 0;
        float sum_prop_active = 0;
        float sum_activate_sensitivity = 0;
        float sum_decay_rate_return = 0;
        //      cout << "colony\tdecay_rate\twalk_drop_rate\ttrail_drop_rate\tdir_const\tdir_coeff2\tdir_time2\tdense_thresh\tdense_const\tmean seeds\tbest" << endl;
        for (int i = 0; i < n_colonies; i++)
        {
            //              cout << i << "\t" << colonies[i].decay_rate << "\t" << colonies[i].walk_drop_rate << "\t" << colonies[i].trail_drop_rate << "\t" << colonies[i].dir_dev_const << "\t" << colonies[i].dir_dev_coeff2 << "\t" << colonies[i].dir_time_pow2 << "\t" << colonies[i].dense_thresh << "\t" << colonies[i].dense_const << "\t" << colonies[i].seeds_collected << endl;
            
            //              cout << "Seeds collected: " << colonies[i].seeds_collected << endl;
            sum_seeds += colonies[i].seeds_collected;
            if (colonies[i].seeds_collected > best_seeds)
                best_seeds = colonies[i].seeds_collected;
            sum_decay += colonies[i].decay_rate;
            sum_search_giveup += colonies[i].search_giveup_rate;
            sum_dir_dev_const += colonies[i].dir_dev_const;
            sum_dir_dev_coeff1 += colonies[i].dir_dev_coeff1;
            sum_dir_time_pow1 += colonies[i].dir_time_pow1;
            sum_dir_dev_coeff2 += colonies[i].dir_dev_coeff2;
            sum_dir_time_pow2 += colonies[i].dir_time_pow2;
            sum_dense_sens += colonies[i].dense_sens;
            sum_dense_thresh += colonies[i].dense_thresh;
            sum_dense_const += colonies[i].dense_const;
            sum_dense_thresh_patch += colonies[i].dense_thresh_patch;
            sum_dense_const_patch += colonies[i].dense_const_patch;
            sum_dense_thresh_influence += colonies[i].dense_thresh_influence;
            sum_dense_const_influence += colonies[i].dense_const_influence;
            sum_prop_active += colonies[i].prop_active;
            sum_activate_sensitivity += colonies[i].activate_sensitivity;
            sum_decay_rate_return += colonies[i].decay_rate_return;
            
            
            sum_walk_drop += colonies[i].walk_drop_rate;
            sum_trail_drop += colonies[i].trail_drop_rate;
            
            colonies[i].decay_rate = new_colonies[i].decay_rate;
            new_colonies[i].decay_rate = 0;
            colonies[i].walk_drop_rate = new_colonies[i].walk_drop_rate;
            colonies[i].search_giveup_rate = new_colonies[i].search_giveup_rate;
            colonies[i].trail_drop_rate = new_colonies[i].trail_drop_rate;
            colonies[i].dir_dev_const = new_colonies[i].dir_dev_const;
            colonies[i].dir_dev_coeff1 = new_colonies[i].dir_dev_coeff1;
            colonies[i].dir_time_pow1 = new_colonies[i].dir_time_pow1;
            colonies[i].dir_dev_coeff2 = new_colonies[i].dir_dev_coeff2;
            colonies[i].dir_time_pow2 = new_colonies[i].dir_time_pow2;
            colonies[i].dense_sens = new_colonies[i].dense_sens;
            colonies[i].dense_thresh = new_colonies[i].dense_thresh;
            colonies[i].dense_const = new_colonies[i].dense_const;
            colonies[i].dense_thresh_patch = new_colonies[i].dense_thresh_patch;
            colonies[i].dense_const_patch = new_colonies[i].dense_const_patch;
            colonies[i].dense_thresh_influence =
            new_colonies[i].dense_thresh_influence;
            colonies[i].dense_const_influence =
            new_colonies[i].dense_const_influence;
            colonies[i].prop_active = new_colonies[i].prop_active;
            colonies[i].activate_sensitivity =
            new_colonies[i].activate_sensitivity;
            colonies[i].decay_rate_return = new_colonies[i].decay_rate_return;
            
            new_colonies[i].dir_dev_const = 0;
            colonies[i].seeds_collected = 0;
        }
        
        NSLog(@"Done with generation %d",gen_count);
        //      cout << "generation\tdecay_rate\twalk_drop_rate\ttrail_drop_rate\tdir_const\tdir_coeff2\tdir_time2\tdense_thresh\tdense_const\tmean seeds\tbest" << endl;
        /*cout << gen_count << "\t";
         cout << sum_seeds / n_colonies << "\t";
         cout << sum_decay / n_colonies << "\t";
         cout << sum_walk_drop / n_colonies << "\t";
         cout << sum_search_giveup / n_colonies << "\t";
         cout << sum_trail_drop / n_colonies << "\t";
         cout << sum_dir_dev_const / n_colonies << "\t";
         cout << sum_dir_dev_coeff2 / n_colonies << "\t";
         cout << sum_dir_time_pow2 / n_colonies << "\t";
         cout << sum_dense_thresh / n_colonies << "\t";
         cout << sum_dense_const / n_colonies << "\t";
         cout << sum_dense_thresh_patch / n_colonies << "\t";
         cout << sum_dense_const_patch / n_colonies << "\t";
         cout << sum_dense_thresh_influence / n_colonies << "\t";
         cout << sum_dense_const_influence / n_colonies << "\t";
         cout << sum_prop_active / n_colonies << "\t";
         cout << sum_activate_sensitivity / n_colonies << "\t";
         cout << sum_decay_rate_return / n_colonies << "\t";
         cout << sum_seeds / n_colonies << "\t";
         cout << best_seeds << endl;*/
        
        
        // End GA Main Loop
    }
    
    // OUTPUT PARAMETERS FOR FINAL GENERATION!
    /*cout << "Parameters for final generation:" << endl;
     cout <<
     "colony\tdecay_rate\twalk_drop_rate\tsearch_giveup_rate\ttrail_drop_rate\tdir_const\tdir_coeff2\tdir_time_pow2\tdense_thresh\tdense_const\tdense_thresh_patch\tdense_const_patch\tdense_thresh_infl\tdense_const_infl\tprop_active\tactivate_sensitivity\tdecay_rate_return"
     << endl;*/
    
    float decay_rate_sum=0.f,
    walk_drop_rate_sum=0.f,
    trail_drop_rate_sum=0.f,
    dir_dev_const_sum=0.f,
    dir_dev_coeff2_sum=0.f,
    dir_time_pow2_sum=0.f,
    dense_thresh_sum=0.f,
    dense_const_sum=0.f,
    dense_thresh_patch_sum=0.f,
    dense_const_patch_sum=0.f,
    dense_thresh_influence_sum=0.f,
    dense_const_influence_sum=0.f,
    prop_active_sum=0.f,
    activate_sensitivity_sum=0.f,
    decay_rate_return_sum=0.f;
    
    for (int i = 0; i < n_colonies; i++)
    {
        /*cout << i << "\t" << colonies[i].decay_rate << "\t" << colonies[i].
         walk_drop_rate << "\t" << colonies[i].
         search_giveup_rate << "\t" << colonies[i].
         trail_drop_rate << "\t" << colonies[i].
         dir_dev_const << "\t" << colonies[i].
         dir_dev_coeff2 << "\t" << colonies[i].
         dir_time_pow2 << "\t" << colonies[i].
         dense_thresh << "\t" << colonies[i].
         dense_const << "\t" << colonies[i].
         dense_thresh_patch << "\t" << colonies[i].
         dense_const_patch << "\t" << colonies[i].
         dense_thresh_influence << "\t" << colonies[i].
         dense_const_influence << "\t" << colonies[i].
         prop_active << "\t" << colonies[i].
         activate_sensitivity << "\t" << colonies[i].decay_rate_return << endl;*/
        
        decay_rate_sum+=colonies[i].decay_rate;
        walk_drop_rate_sum+=colonies[i].walk_drop_rate;
        trail_drop_rate_sum+=colonies[i].trail_drop_rate;
        dir_dev_const_sum+=colonies[i].dir_dev_const;
        dir_dev_coeff2_sum+=colonies[i].dir_dev_coeff2;
        dir_time_pow2_sum+=colonies[i].dir_time_pow2;
        dense_thresh_sum+=colonies[i].dense_thresh;
        dense_const_sum+=colonies[i].dense_const;
        dense_thresh_patch_sum+=colonies[i].dense_thresh_patch;
        dense_const_patch_sum+=colonies[i].dense_const_patch;
        dense_thresh_influence_sum+=colonies[i].dense_thresh_influence;
        dense_const_influence_sum+=colonies[i].dense_const_influence;
        prop_active_sum+=colonies[i].prop_active;
        activate_sensitivity_sum+=colonies[i].activate_sensitivity;
        decay_rate_return_sum+=colonies[i].decay_rate_return;
    }
    
    float n_colonies_float=(float)n_colonies;
    
    //Average all colonies to obtain one set of parameters for the robots:
    NSArray* arr = [[NSArray alloc] initWithObjects:
                    [NSNumber numberWithFloat:decay_rate_sum/n_colonies_float],
                    [NSNumber numberWithFloat:walk_drop_rate_sum/n_colonies_float],
                    [NSNumber numberWithFloat:trail_drop_rate_sum/n_colonies_float],
                    [NSNumber numberWithFloat:dir_dev_const_sum/n_colonies_float],
                    [NSNumber numberWithFloat:dir_dev_coeff2_sum/n_colonies_float],
                    [NSNumber numberWithFloat:dir_time_pow2_sum/n_colonies_float],
                    [NSNumber numberWithFloat:dense_thresh_sum/n_colonies_float],
                    [NSNumber numberWithFloat:dense_const_sum/n_colonies_float],
                    [NSNumber numberWithFloat:dense_thresh_patch_sum/n_colonies_float],
                    [NSNumber numberWithFloat:dense_const_patch_sum/n_colonies_float],
                    [NSNumber numberWithFloat:dense_thresh_influence_sum/n_colonies_float],
                    [NSNumber numberWithFloat:dense_const_influence_sum/n_colonies_float],
                    [NSNumber numberWithFloat:prop_active_sum/n_colonies_float],
                    [NSNumber numberWithFloat:activate_sensitivity_sum/n_colonies_float],
                    [NSNumber numberWithFloat:decay_rate_return_sum/n_colonies_float],
                    nil];
    return arr;
}

/* GLUT stuff turned off for GA
 void main_display()
 {
 // return;
 glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
 glMatrixMode( GL_MODELVIEW );
 glLoadIdentity();
 glTranslatef(-1.0, -1.0, 0.0);
 
 for ( int i = 0; i < grid_width; i++ )
 {
 glTranslatef(2.0f/grid_width, 0.0, 0.0);
 for ( int j = 0; j < grid_height; j++ )
 {	
 glTranslatef(0.0, 2.0f/grid_height, 0.0);
 
 if ( grid[i][j].nest == true ) glColor4f(1.0, 1.0, 0.0, 1.0); 
 else if ( grid[i][j].food > 0 )
 switch (grid[i][j].food)
 {
 case 1: glColor4f(1.0, 0.0, 0.0, 1.0); break;
 case 2: glColor4f(1.0, 0.65, 0.0, 1.0); break;
 case 3: glColor4f(0.0, 1.0, 0.0, 1.0); break;
 case 4: glColor4f(1.0, 0.0, 1.0, 1.0); break;
 case 5: glColor4f(0.0, 0.0, 1.0, 1.0); break;
 case 6: glColor4f(0.0, 0.0, 1.0, 1.0); break;
 }
 else 
 switch (grid[i][j].ant_status)
 {
 case 0:
 //cout << grid[i][j].p1 << endl;
 if (grid[i][j].p2 != 0.0f) 
 glColor4f(0.0, grid[i][j].p2, 0.0, 0.5); 
 else continue;
 break;
 case 1: glColor4f(1.0, 1.0, 1.0, 1.0); break;
 case 2: glColor4f(1.0, 0.0, 1.0, 1.0); break;
 case 3: glColor4f(0.0, 1.0, 1.0, 1.0); break;
 case 4: glColor4f(0.0, 1.0, 0.0, 1.0); break;
 }
 
 glBegin(GL_QUADS);
 glVertex3f(-1.0f/grid_width, 1.0f/grid_height, 0.0f);				// Top Left
 glVertex3f( 1.0f/grid_width, 1.0f/grid_height, 0.0f);				// Top Right
 glVertex3f( 1.0f/grid_width,-1.0f/grid_height, 0.0f);				// Bottom Right
 glVertex3f(-1.0f/grid_width,-1.0f/grid_height, 0.0f);                         // Bottom Left
 glEnd();
 }
 glTranslatef(0.0, -2.0f, 0.0);
 }
 // Make sure changes appear onscreen
 glutSwapBuffers();
 }
 
 
 
 void main_handleResize(int w, int h)
 {
 }
 */

void
run ()
{
    
    update_count++;
    
    //decay return_pheromone
    return_pheromone *= (1 - colonies[col_count].decay_rate_return);
    
    // Update ants
    for (int ant_count = 0; ant_count < n_ants; ant_count++)
    {
        if (ants[ant_count].ant_status != 0)
            colonies[col_count].ant_time_out++;
        
        // Update pheromones
        if (ants[ant_count].pen_down == true)
        {
            grid[ants[ant_count].x][ants[ant_count].y].p2 =
            grid[ants[ant_count].x][ants[ant_count].y].p2 + deposit_rate_p2;
            grid[ants[ant_count].x][ants[ant_count].y].p2_time_updated =
            update_count;
        }
        // Searching ants pick up food
        if (ants[ant_count].rfidx >= 0 && ants[ant_count].rfidx < grid_width
            && ants[ant_count].rfidy >= 0
            && ants[ant_count].rfidy < grid_height)
        {
            if ((ants[ant_count].ant_status == 3)
                && grid[ants[ant_count].rfidx][ants[ant_count].rfidy].food > 0)
            {
                grid[ants[ant_count].x][ants[ant_count].y].ant_status =
                ants[ant_count].ant_status = 2;
                ants[ant_count].prevx = ants[ant_count].prevy =
                ants[ant_count].search_time = -1;
                ants[ant_count].since_move = 0;
                ants[ant_count].carrying =
                grid[ants[ant_count].rfidx][ants[ant_count].rfidy].food;
                grid[ants[ant_count].rfidx][ants[ant_count].rfidy].food = 0;
                grid[ants[ant_count].rfidx][ants[ant_count].rfidy].ant_status =
                0;
                ants[ant_count].rfidx = ants[ant_count].rfidy = -1;
                
                int density_count = 0;
                //  Scan for seeds in the neighborhood
                for (int k = -smell_range; k <= smell_range; k++)
                {
                    if (ants[ant_count].x + k < 0
                        || ants[ant_count].x + k >= grid_width)
                        continue;
                    for (int l = -smell_range; l <= smell_range; l++)
                    {
                        if (ants[ant_count].y + l < 0
                            || ants[ant_count].y + l >= grid_height)
                        {
                            continue;
                        }
                        if (grid[ants[ant_count].x + k][ants[ant_count].y + l].
                            food > 0)
                        {
                            density_count++;
                        }
                    }
                }
                
                if (rand () % 100 / 100.0f <=
                    (density_count / colonies[col_count].dense_thresh +
                     colonies[col_count].dense_const))
                {		// Lay a trail
                    ants[ant_count].pen_down = true;
                    grid[ants[ant_count].x][ants[ant_count].y].p1 += 20;
                }
                if (rand () % 100 / 100.0f >=
                    (density_count /
                     colonies[col_count].dense_thresh_influence +
                     colonies[col_count].dense_const_influence))
                {		// Will follow pheromone trails from the nest if any exist
                    ants[ant_count].influenceable = true;
                }
                if (rand () % 100 / 100.0f <=
                    (density_count / colonies[col_count].dense_thresh_patch +
                     colonies[col_count].dense_const_patch))
                {		// Return to the patch if not following a trail
                    ants[ant_count].return_x = ants[ant_count].x;
                    ants[ant_count].return_y = ants[ant_count].y;
                }
                else
                {		// Just go back to nest and pick a random direction to walk if not following a trail
                    ants[ant_count].return_x = ants[ant_count].return_y = -1;
                }
                
                /* SIMPLIFIED DECISION TREE -- non-GA-selected
                 if ((recruit == true) && (density_count >= 2))
                 {  // Lay a trail
                 ants[ant_count].pen_down = true;
                 grid[ants[ant_count].x][ants[ant_count].y].p1 += 20;
                 }
                 if ((recruit == true) && (density_count < 2))
                 {  // Will follow pheromone trails from the nest if any exist
                 ants[ant_count].influenceable = true;
                 }
                 if ((patch == true) && (density_count >= 0)) // bots always return to patch if not following a trail!
                 {  // Return to the patch
                 ants[ant_count].return_x = ants[ant_count].x;
                 ants[ant_count].return_y = ants[ant_count].y;
                 }
                 else { // Just go back to nest and pick a random direction to walk, or follow a trail if any exist
                 ants[ant_count].return_x = ants[ant_count].return_y = -1;
                 }
                 */
                
            }
        }
        // Arrive at nest
        if (ants[ant_count].ant_status == 2
            && grid[ants[ant_count].x][ants[ant_count].y].nest == true)
        {
            ants[ant_count].prevx = ants[ant_count].prevy = -1;
            if (ants[ant_count].carrying > 0)
            {
                colonies[col_count].seeds_collected++;
                
                // Activate ants in the nest proportional to return_pheromone at nest entrance
                // Pheromone trails present around nest?
                float sum_pheromone = 0.0f;
                for (int k = -1; k <= 1; k++)
                {
                    int i_k = ants[ant_count].x + k;
                    if (i_k < 0 || i_k >= grid_width)
                        continue;
                    for (int l = -1; l <= 1; l++)
                    {
                        // Skip ourselves
                        if (l == 0 && k == 0)
                            continue;
                        int j_l = ants[ant_count].y + l;
                        if (j_l < 0 || j_l >= grid_height)
                            continue;
                        if (sqrt
                            (pow (ants[ant_count].x - nestx, 2) +
                             pow (ants[ant_count].y - nesty,
                                  2)) - sqrt (pow (i_k - nestx,
                                                   2) + pow (j_l - nesty,
                                                             2)) <= 0)
                        {
                            // Sum pheromones within 1 square of nest -- adjust pheromone strength as the square of distance from current location
                            sum_pheromone +=
                            grid[i_k][j_l].p2 /
                            pow (sqrt
                                 (pow (ants[ant_count].x - i_k, 2) +
                                  pow (ants[ant_count].y - j_l, 2)), 2);
                        }
                    }
                }
                // but only if arriving ant is recruiting
                if (ants[ant_count].pen_down == true)
                {
                    return_pheromone += 1;
                    for (int n = 0; n < n_ants; n++)
                    {
                        if ((ants[n].ant_status == 0)
                            && (rand () % (1000) / (1000.0f) <
                                (return_pheromone *
                                 colonies[col_count].activate_sensitivity) /
                                (n_ants)))
                        {
                            if (sum_pheromone > 0.0)
                            {
                                grid[ants[n].x][ants[n].y].ant_status = ants[n].ant_status = 1;	// Ant in nest sets out to follow a pheromone trail
                            }
                            else
                            {
                                grid[ants[n].x][ants[n].y].ant_status =
                                ants[n].ant_status = 4;
                                ants[n].direction = rand () % 360;
                            }
                        }
                    }
                }
                
            }
            if (ants[ant_count].carrying > 0)
            {
                switch (ants[ant_count].carrying)
                {
                    case 1:
                        count_food_red++;
                        break;
                    case 2:
                        count_food_orange++;
                        break;
                    case 3:
                        count_food_green++;
                        break;
                    case 4:
                        count_food_blue++;
                        break;
                }
                
            }
            
            // Pheromone trails present around nest?
            float sum_pheromone = 0.0f;
            for (int k = -1; k <= 1; k++)
            {
                int i_k = ants[ant_count].x + k;
                if (i_k < 0 || i_k >= grid_width)
                    continue;
                for (int l = -1; l <= 1; l++)
                {
                    // Skip ourselves
                    if (l == 0 && k == 0)
                        continue;
                    int j_l = ants[ant_count].y + l;
                    if (j_l < 0 || j_l >= grid_height)
                        continue;
                    if (sqrt
                        (pow (ants[ant_count].x - nestx, 2) +
                         pow (ants[ant_count].y - nesty,
                              2)) - sqrt (pow (i_k - nestx,
                                               2) + pow (j_l - nesty, 2)) <= 0)
                    {
                        // Sum pheromones within 1 square of nest -- adjust pheromone strength as the square of distance from current location
                        sum_pheromone +=
                        grid[i_k][j_l].p2 /
                        pow (sqrt
                             (pow (ants[ant_count].x - i_k, 2) +
                              pow (ants[ant_count].y - j_l, 2)), 2);
                    }
                }
            }
            
            grid[ants[ant_count].x][ants[ant_count].y].ant_status =
            ants[ant_count].ant_status = 1;
            
            if ((sum_pheromone > 0) & (ants[ant_count].influenceable == true))
            {
                // Ant will follow a trail leading from nest
                grid[ants[ant_count].x][ants[ant_count].y].ant_status =
                ants[ant_count].ant_status = 1;
            }
            else if ((ants[ant_count].return_x != -1) &
                     (ants[ant_count].return_y != -1))
            {
                // Ant will return to patch
                grid[ants[ant_count].x][ants[ant_count].y].ant_status =
                ants[ant_count].ant_status = 5;
            }
            else
            {
                // Ants choose a direction to start walking
                grid[ants[ant_count].x][ants[ant_count].y].ant_status =
                ants[ant_count].ant_status = 4;
                ants[ant_count].direction = rand () % 360;
            }
            
            ants[ant_count].pen_down = false;
            ants[ant_count].influenceable = false;
            ants[ant_count].carrying = 0;
        }
        // Move ants
        // Ants following a trail
        if (ants[ant_count].ant_status == 1)
        {
            bool move_accepted = false;
            //int reason = 0;
            // Follow trail if one exists
            // Find the out-bound cell with greatest pheromone and sum of pheromone weight on all such cells
            float back_pheromone = 0.0f;
            float sum_pheromone = 0.0f;
            float most_pheromone = 0.0f;
            for (int k = -1; k <= 1; k++)
            {
                int i_k = ants[ant_count].x + k;
                if (i_k < 0 || i_k >= grid_width)
                    continue;
                
                for (int l = -1; l <= 1; l++)
                {
                    // Skip ourselves
                    if (l == 0 && k == 0)
                        continue;
                    int j_l = ants[ant_count].y + l;
                    if (j_l < 0 || j_l >= grid_height)
                        continue;
                    
                    if (sqrt
                        (pow (ants[ant_count].x - nestx, 2) +
                         pow (ants[ant_count].y - nesty,
                              2)) - sqrt (pow (i_k - nestx,
                                               2) + pow (j_l - nesty, 2)) <= 0)
                    {
                        
                        if (grid[i_k][j_l].p2 > 0)
                        {
                            grid[i_k][j_l].p2 *=
                            pow ((1 - colonies[col_count].decay_rate),
                                 (update_count -
                                  grid[i_k][j_l].p2_time_updated));
                            grid[i_k][j_l].p2_time_updated = update_count;
                            
                            if (grid[i_k][j_l].p2 < 0.001f)
                            {
                                grid[i_k][j_l].p2 = 0;
                            }
                        }
                        
                        // Sum pheromones within smell_range squares away from nest -- adjust pheromone strength as the square of distance from current location
                        sum_pheromone += grid[i_k][j_l].p2;
                        // Get highest pheromone on any adjacent out-bound square
                        if (grid[i_k][j_l].p2 > most_pheromone
                            && grid[i_k][j_l].p2 > 0.0f)
                        {
                            most_pheromone = grid[i_k][j_l].p2;
                        }
                    }
                    else
                    {
                        // Sum pheromones within smell_range squares in direction of nest -- adjust pheromone strength as the square of distance from current location
                        back_pheromone +=
                        grid[i_k][j_l].p2 /
                        pow (sqrt
                             (pow (ants[ant_count].x - i_k, 2) +
                              pow (ants[ant_count].y - j_l, 2)), 2);
                    }
                    
                }
            }
            
            
            // Drop off trail probabilistically in proportion to the degree of trail weakening in outbound moves as compared to backward moves
            // ...but only if the ant isn't in the nest or within smelling range of it!
            // ...and only if the ant is in a spot where a trail ends (i.e. p1 > 0.0)
            if ((rand () % 1000 / 1000.0f >
                 sum_pheromone /
                 back_pheromone) & (sqrt (pow (ants[ant_count].x - nestx, 2) +
                                          pow (ants[ant_count].y - nesty,
                                               2)) > sqrt (2 * pow (smell_range,
                                                                    2))) &
                (grid[ants[ant_count].x][ants[ant_count].y].p1 > 0.0))
            {
                // Traveling ant drops off the pheromone trail and begins searching
                grid[ants[ant_count].x][ants[ant_count].y].ant_status =
                ants[ant_count].ant_status = 3;
                ants[ant_count].search_time = 0;
                //reason = 1;
            }
            
            // Drop off the trail if no more pheromone on out-bound cells (trail has evaporated)
            else if (sum_pheromone <= 0.0f)
            {
                grid[ants[ant_count].x][ants[ant_count].y].ant_status =
                ants[ant_count].ant_status = 3;
                ants[ant_count].search_time = -1;
                //reason = 2;
            }
            
            // ants have a small probability of dropping off the trail each time step
            else if (rand () % 10000 / 10000.0f <
                     colonies[col_count].trail_drop_rate)
            {
                // Traveling ant drops off the pheromone trail and begins searching
                grid[ants[ant_count].x][ants[ant_count].y].ant_status =
                ants[ant_count].ant_status = 3;
                ants[ant_count].prevx = ants[ant_count].prevy = -1;
                ants[ant_count].search_time = -1;
                //reason = 3;
            }
            
            else
            {
                // Random, accept a move with probability proportional to the ratio of the
                // pheromone on the square to be moved to and the adjacent square with the
                // highest amount of pheromone
                int new_x = -1, new_y = -1;
                while (!move_accepted)
                {
                    
                    new_x = ants[ant_count].x + rand () % 3 - 1;
                    new_y = ants[ant_count].y + rand () % 3 - 1;
                    if ((new_x < 0) || (new_x >= grid_width) || (new_y < 0)
                        || (new_y >= grid_height))
                        continue;
                    // Disregard possible moves that take out-bound ant closer to nest
                    if (sqrt
                        (pow (ants[ant_count].x - nestx, 2) +
                         pow (ants[ant_count].y - nesty,
                              2)) - sqrt (pow (new_x - nestx,
                                               2) + pow (new_y - nesty, 2)) > 0)
                        continue;
                    if ((most_pheromone <= 0.0f)
                        || (rand () % 100 / 100.0f <
                            grid[new_x][new_y].p2 / most_pheromone))
                    {
                        move_accepted = true;
                    }
                }
                
                grid[ants[ant_count].x][ants[ant_count].y].ant_status = 0;
                ants[ant_count].x = new_x;
                ants[ant_count].y = new_y;
                grid[new_x][new_y].ant_status = ants[ant_count].ant_status;
                ants[ant_count].prev_pher_scent = sum_pheromone;
            }
        }
        
        // Ants returning to last successful patch
        if (ants[ant_count].ant_status == 5)
        {
            if ((ants[ant_count].return_x == -1
                 && ants[ant_count].return_y == -1)
                || (ants[ant_count].x == ants[ant_count].return_x
                    && ants[ant_count].y == ants[ant_count].return_y))
            {
                ants[ant_count].ant_status = 3;
                ants[ant_count].search_time = 0;
                ants[ant_count].search_direction = rand () % 360 - 180;
                int newdx = round (cos (ants[ant_count].search_direction));
                int newdy = round (sin (ants[ant_count].search_direction));
                if (ants[ant_count].x + newdx >= 0
                    && ants[ant_count].x + newdx < grid_width
                    && ants[ant_count].y + newdy >= 0
                    && ants[ant_count].y + newdy < grid_height)
                {
                    ants[ant_count].rfidx = ants[ant_count].x + newdx;	// place rfid/qr reader in front of ant
                    ants[ant_count].rfidy = ants[ant_count].y + newdy;
                    grid[ants[ant_count].rfidx][ants[ant_count].rfidy].
                    ant_status = 9;
                }
            }
            else
            {
                
                // Find the adjacent square that decreases euclidean distance to patch the most
                float most_distance = 0.0f;
                for (int k = -1; k < 2; k++)
                {
                    int i_k = ants[ant_count].x + k;
                    if (i_k < 0 || i_k >= grid_width)
                        continue;
                    
                    for (int l = -1; l < 2; l++)
                    {
                        // Skip ourselves
                        if (l == 0 && k == 0)
                            continue;
                        int j_l = ants[ant_count].y + l;
                        if (j_l < 0 || j_l >= grid_height)
                            continue;
                        
                        // Distance
                        if (sqrt
                            (pow
                             (ants[ant_count].x - ants[ant_count].return_x,
                              2) + pow (ants[ant_count].y -
                                        ants[ant_count].return_y,
                                        2)) - sqrt (pow (i_k -
                                                         ants[ant_count].
                                                         return_x,
                                                         2) + pow (j_l -
                                                                   ants
                                                                   [ant_count].
                                                                   return_y,
                                                                   2)) >
                            most_distance)
                        {
                            most_distance =
                            sqrt (pow
                                  (ants[ant_count].x -
                                   ants[ant_count].return_x,
                                   2) + pow (ants[ant_count].y -
                                             ants[ant_count].return_y,
                                             2)) - sqrt (pow (i_k -
                                                              ants[ant_count].
                                                              return_x,
                                                              2) + pow (j_l -
                                                                        ants
                                                                        [ant_count].
                                                                        return_y,
                                                                        2));
                            //
                        }
                    }
                }
                // Random, accept a move with probability proportional to the ratio of the
                // distance of the square to be moved to and the adjacent square with the
                // greatest decrease in distance from the patch
                int new_x = -1, new_y = -1;
                bool move_accepted = false;
                while (!move_accepted)
                {
                    new_x = ants[ant_count].x + rand () % 3 - 1;
                    new_y = ants[ant_count].y + rand () % 3 - 1;
                    if ((most_distance <= 0.0f)
                        || rand () % 100 / 100.0f <
                        (sqrt
                         (pow (ants[ant_count].x - ants[ant_count].return_x, 2)
                          + pow (ants[ant_count].y - ants[ant_count].return_y,
                                 2)) - sqrt (pow (new_x -
                                                  ants[ant_count].return_x,
                                                  2) + pow (new_y -
                                                            ants[ant_count].
                                                            return_y,
                                                            2))) /
                        most_distance)
                    {
                        move_accepted = true;
                    }
                }
                if (new_x < 0 || new_x >= grid_width || new_y < 0
                    || new_y >= grid_height)
                    continue;
                grid[ants[ant_count].x][ants[ant_count].y].ant_status = 0;
                grid[new_x][new_y].ant_status = ants[ant_count].ant_status;
                ants[ant_count].x = new_x;
                ants[ant_count].y = new_y;
            }
            
        }
        
        // Traveling ants, out-bound from nest but not following a trail
        if (ants[ant_count].ant_status == 4)
        {
            if ((rand () % 10000 / 10000.0f <
                 colonies[col_count].walk_drop_rate))
            {
                ants[ant_count].ant_status = 3;
                ants[ant_count].search_time = -1;
                ants[ant_count].search_direction = 360.0;
                int newdx = round (cos (ants[ant_count].search_direction));
                int newdy = round (sin (ants[ant_count].search_direction));
                if (ants[ant_count].x + newdx >= 0
                    && ants[ant_count].x + newdx < grid_width
                    && ants[ant_count].y + newdy >= 0
                    && ants[ant_count].y + newdy < grid_height)
                {
                    ants[ant_count].rfidx = ants[ant_count].x + newdx;	// place rfid reader behind ant
                    ants[ant_count].rfidy = ants[ant_count].y + newdy;
                    grid[ants[ant_count].rfidx][ants[ant_count].rfidy].
                    ant_status = 9;
                }
                continue;
            }
            float idealx;		// Optimal X and Y move given the ant's chosen direction
            float idealy;		// Move may not be possible (i.e., not on the grid) but the ant will try to get as close as possible
            if (fabs (sin (ants[ant_count].direction * pi / 180)) >
                fabs (cos (ants[ant_count].direction * pi / 180)))
            {
                idealx =
                ants[ant_count].x +
                50 * (cos (ants[ant_count].direction * pi / 180) /
                      fabs (sin (ants[ant_count].direction * pi / 180)));
                idealy =
                ants[ant_count].y +
                50 * (sin (ants[ant_count].direction * pi / 180) /
                      fabs (sin (ants[ant_count].direction * pi / 180)));
            }
            else
            {
                idealx =
                ants[ant_count].x +
                50 * (cos (ants[ant_count].direction * pi / 180) /
                      fabs (cos (ants[ant_count].direction * pi / 180)));
                idealy =
                ants[ant_count].y +
                50 * (sin (ants[ant_count].direction * pi / 180) /
                      fabs (cos (ants[ant_count].direction * pi / 180)));
            }
            
            
            // Find the move that would decrease distance to the ideal move the most
            float most_distance = 0.0f;
            for (int k = -1; k < 2; k++)
            {
                int i_k = ants[ant_count].x + k;
                if (i_k < 0 || i_k >= grid_width)
                    continue;
                
                for (int l = -1; l < 2; l++)
                {
                    // Skip ourselves
                    if (l == 0 && k == 0)
                        continue;
                    int j_l = ants[ant_count].y + l;
                    if (j_l < 0 || j_l >= grid_height)
                        continue;
                    
                    // Distance
                    if (sqrt
                        (pow (ants[ant_count].x - idealx, 2) +
                         pow (ants[ant_count].y - idealy,
                              2)) - sqrt (pow (i_k - idealx,
                                               2) + pow (j_l - idealy,
                                                         2)) > most_distance)
                    {
                        most_distance =
                        sqrt (pow (ants[ant_count].x - idealx, 2) +
                              pow (ants[ant_count].y - idealy,
                                   2)) - sqrt (pow (i_k - idealx,
                                                    2) + pow (j_l - idealy,
                                                              2));
                        
                    }
                }
            }
            // Random, accept a move with probability proportional to the ratio of the
            // distance of the square to be moved to and the adjacent square with the
            // greatest decrease in distance from the ideal move
            int new_x = -1, new_y = -1;
            bool move_accepted = false;
            while (!move_accepted)
            {
                new_x = ants[ant_count].x + rand () % 3 - 1;
                new_y = ants[ant_count].y + rand () % 3 - 1;
                //Skip ourselves
                if ((new_x == ants[ant_count].x) & (new_y == ants[ant_count].y))
                    continue;
                if ((most_distance <= 0.0f)
                    || rand () % 100 / 100.0f <
                    (sqrt
                     (pow (ants[ant_count].x - idealx, 2) +
                      pow (ants[ant_count].y - idealy,
                           2)) - sqrt (pow (new_x - idealx,
                                            2) + pow (new_y - idealy,
                                                      2))) / most_distance)
                {
                    move_accepted = true;
                }
            }
            if (new_x < 0 || new_x >= grid_width || new_y < 0
                || new_y >= grid_height)
            {
                ants[ant_count].ant_status = 3;
                ants[ant_count].search_time = -1;
                continue;
            }
            
            grid[ants[ant_count].x][ants[ant_count].y].ant_status = 0;
            grid[new_x][new_y].ant_status = ants[ant_count].ant_status;
            ants[ant_count].x = new_x;
            ants[ant_count].y = new_y;
            
            
        }
        
        // Searching ants
        if (ants[ant_count].ant_status == 3)
        {
            if (ants[ant_count].since_move < search_delay)
                ants[ant_count].since_move++;
            else
            {
                // Searching ants smell food in adjacent squares.  If an ant smells food in an adjacent square
                // where no other ant is present (the food is available for pickup) the ant will move to one of
                // these squares; otherwise selects a square at random.
                
                // CODE FOR ALLOWING SEARCHING ANTS TO SMELL AND MOVE TO FOOD IN ADJACENT SQUARES -- off for the AntBots
                int food_count = 0;
                /*		      for ( int k = -1; k < 2; k++ )
                 {
                 for ( int l = -1; l < 2; l++ )
                 {
                 if ( ants[ant_count].x+k < grid_width && ants[ant_count].x+k >= 0 && ants[ant_count].y+l < grid_height && ants[ant_count].y+l >= 0 )
                 {
                 if ( grid[ants[ant_count].x+k][ants[ant_count].y+l].food > 0 & grid[ants[ant_count].x+k][ants[ant_count].y+l].ant_status == 0 ) food_count++;
                 }  
                 }
                 } */
                int new_x = -1, new_y = -1;
                int search_loop = 0;
                bool found_a_seed = false;
                bool move_accepted = false;
                float new_direction;
                while (!move_accepted && ants[ant_count].ant_status == 3)
                {
                    search_loop++;
                    if (((ants[ant_count].search_direction == 360.0))
                        || (ants[ant_count].x == 0) || (ants[ant_count].y == 0)
                        || (ants[ant_count].x == grid_width - 1)
                        || (ants[ant_count].y == grid_height - 1)
                        || (food_count > 0))
                    {
                        ants[ant_count].search_direction =
                        (rand () % 360) - 180;
                    }
                    
                    float d_theta;
                    if (ants[ant_count].search_time >= 0.0)
                    {
                        d_theta =
                        sto.Normal (0,
                                    ((colonies[col_count].dir_dev_coeff1 *
                                      pow (ants[ant_count].search_time,
                                           colonies[col_count].
                                           dir_time_pow1)) +
                                     (colonies[col_count].dir_dev_coeff2 /
                                      pow (ants[ant_count].search_time,
                                           colonies[col_count].
                                           dir_time_pow2)) +
                                     colonies[col_count].dir_dev_const));
                    }
                    else
                        d_theta =
                        sto.Normal (0, colonies[col_count].dir_dev_const);
                    if (update_count % 3 == 0)
                    {		// ants pick a new direction only every 30 cm, like the antbots.
                        new_direction =
                        ants[ant_count].search_direction + d_theta;
                        if (ants[ant_count].search_time >= 0.0)
                            ants[ant_count].search_time++;
                    }
                    else
                    {
                        new_direction = ants[ant_count].search_direction;
                    }
                    int newdx = round (cos (new_direction));
                    int newdy = round (sin (new_direction));
                    new_x = ants[ant_count].x + newdx;
                    new_y = ants[ant_count].y + newdy;
                    
                    if ((new_x < 0) || (new_x >= grid_width) || (new_y < 0)
                        || (new_y >= grid_height))
                        continue;
                    if ((new_x == ants[ant_count].x) & (new_y ==
                                                        ants[ant_count].y))
                        continue;
                    // CODE FOR MOVING TO FOOD IN ADJACENT SQUARE
                    if (food_count > 0)
                    {
                        
                        if (grid[new_x][new_y].food > 0
                            && grid[new_x][new_y].ant_status == 0)
                        {
                            move_accepted = true;
                        }
                        else
                            continue;
                    }
                    else
                        if (rand () % 10000 / 10000.0f <
                            colonies[col_count].search_giveup_rate)
                        {
                            // Ants that do not smell food probabilistically give up searching and begin to return to the nest
                            ants[ant_count].prevx = ants[ant_count].prevy = -1;
                            ants[ant_count].search_direction = 360.0;
                            ants[ant_count].ant_status = 2;
                            if (ants[ant_count].rfidx >= 0
                                && ants[ant_count].rfidx < grid_width
                                && ants[ant_count].rfidy >= 0
                                && ants[ant_count].rfidy < grid_height)
                            {
                                grid[ants[ant_count].rfidx][ants[ant_count].rfidy].
                                ant_status = 0;
                            }
                            ants[ant_count].rfidx = ants[ant_count].rfidy = -1;
                            // Will pick a random spot to search if no pheromone trails at nest.
                            ants[ant_count].ant_status = 4;
                            // Will follow pheromone trails from the nest if any exist
                            ants[ant_count].influenceable = true;
                            continue;
                        }
                        else
                        {
                            move_accepted = true;
                        }
                    
                }
                if (ants[ant_count].ant_status == 3)
                {
                    // ant turns in the direction it intends to travel, RFID/QR reader rotates in front of it
                    float rfid_direction = ants[ant_count].search_direction;
                    int newdx = round (cos (rfid_direction));
                    int newdy = round (sin (rfid_direction));
                    if (ants[ant_count].x + newdx >= 0
                        && ants[ant_count].x + newdx < grid_width
                        && ants[ant_count].y + newdy >= 0
                        && ants[ant_count].y + newdy < grid_height)
                    {
                        if (ants[ant_count].rfidx >= 0
                            && ants[ant_count].rfidx < grid_width
                            && ants[ant_count].rfidy >= 0
                            && ants[ant_count].rfidy < grid_height)
                        {
                            grid[ants[ant_count].rfidx][ants[ant_count].rfidy].
                            ant_status = 0;
                        }
                        ants[ant_count].rfidx = ants[ant_count].x + newdx;	// place rfid reader behind ant
                        ants[ant_count].rfidy = ants[ant_count].y + newdy;
                        if (grid[ants[ant_count].rfidx][ants[ant_count].rfidy].
                            food > 0)
                        {
                            found_a_seed = true;
                        }
                    }
                    
                    // if the RFID reader has not passed over a seed then move the ant to its new location.
                    if (found_a_seed == false)
                    {
                        sumdx += new_x - ants[ant_count].x;
                        sumdy += new_y - ants[ant_count].y;
                        grid[ants[ant_count].x][ants[ant_count].y].ant_status =
                        0;
                        if (ants[ant_count].rfidx >= 0
                            && ants[ant_count].rfidx < grid_width
                            && ants[ant_count].rfidy >= 0
                            && ants[ant_count].rfidy < grid_height)
                        {
                            grid[ants[ant_count].rfidx][ants[ant_count].rfidy].
                            ant_status = 0;
                        }
                        ants[ant_count].x = new_x;
                        ants[ant_count].y = new_y;
                        ants[ant_count].search_direction = new_direction;
                        
                        ants[ant_count].rfidx = ants[ant_count].x + newdx;	// place rfid reader in front of ant again
                        ants[ant_count].rfidy = ants[ant_count].y + newdy;
                        if (ants[ant_count].rfidx >= 0
                            && ants[ant_count].rfidx < grid_width
                            && ants[ant_count].rfidy >= 0
                            && ants[ant_count].rfidy < grid_height)
                        {
                            grid[ants[ant_count].rfidx][ants[ant_count].rfidy].
                            ant_status = 9;
                        }
                        grid[new_x][new_y].ant_status =
                        ants[ant_count].ant_status;
                        
                        ants[ant_count].since_move = 0;
                    }
                }
            }
        }
        // Return to the nest
        else if (ants[ant_count].ant_status == 2)
        {
            // Find the adjacent square that decreases euclidean distance to nest the most
            if ((ants[ant_count].carrying != 0)
                && (ants[ant_count].since_move < return_delay))
            {
                ants[ant_count].since_move++;
            }
            else
            {
                
                float most_distance = 0.0f;
                for (int k = -1; k < 2; k++)
                {
                    int i_k = ants[ant_count].x + k;
                    if (i_k < 0 || i_k >= grid_width)
                        continue;
                    
                    for (int l = -1; l < 2; l++)
                    {
                        // Skip ourselves
                        if (l == 0 && k == 0)
                            continue;
                        int j_l = ants[ant_count].y + l;
                        if (j_l < 0 || j_l >= grid_height)
                            continue;
                        
                        // Distance
                        if (sqrt
                            (pow (ants[ant_count].x - nestx, 2) +
                             pow (ants[ant_count].y - nesty,
                                  2)) - sqrt (pow (i_k - nestx,
                                                   2) + pow (j_l - nesty,
                                                             2)) >
                            most_distance)
                        {
                            most_distance =
                            sqrt (pow (ants[ant_count].x - nestx, 2) +
                                  pow (ants[ant_count].y - nesty,
                                       2)) - sqrt (pow (i_k - nestx,
                                                        2) + pow (j_l - nesty,
                                                                  2));
                            //
                        }
                    }
                }
                // Random, accept a move with probability proportional to the ratio of the
                // distance of the square to be moved to and the adjacent square with the
                // greatest decrease in distance from the nest
                int new_x = -1, new_y = -1;
                bool move_accepted = false;
                while (!move_accepted)
                {
                    //                      cout << "...moving?" << endl;
                    new_x = ants[ant_count].x + rand () % 3 - 1;
                    new_y = ants[ant_count].y + rand () % 3 - 1;
                    if (new_x < 0 || new_x >= grid_width || new_y < 0
                        || new_y >= grid_height)
                        continue;
                    if ((most_distance <= 0.0f)
                        || rand () % 100 / 100.0f <
                        (sqrt
                         (pow (ants[ant_count].x - nestx, 2) +
                          pow (ants[ant_count].y - nesty,
                               2)) - sqrt (pow (new_x - nestx,
                                                2) + pow (new_y - nesty,
                                                          2))) / most_distance)
                    {
                        move_accepted = true;
                    }
                }
                grid[ants[ant_count].x][ants[ant_count].y].ant_status = 0;
                grid[new_x][new_y].ant_status = ants[ant_count].ant_status;
                ants[ant_count].x = new_x;
                ants[ant_count].y = new_y;
                
                ants[ant_count].since_move = 0;
            }
        }
    }
    
    // if ( update_count%4 == 0 ) glutPostRedisplay(); // Force a screen redraw
    
}
