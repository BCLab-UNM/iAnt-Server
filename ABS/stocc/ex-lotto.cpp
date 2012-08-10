/*************************** EX-LOTTO.CPP ******************** AgF 2001-11-11 *

   Example of using random library to generate a sequence of integer
   numbers where no number occurs more than once.

   This example generates a Lotto coupon, drawing "select" different
   numbers from the interval from "nmin" to "nmax", inclusive.
*/

#include <time.h>                      // define time()
#include "stocc.h"                     // define random library classes

#ifndef MULTIFILE_PROJECT
// If compiled as a single file then include these cpp files, 
// If compiled as a project then compile and link in these cpp files.
   #include "mersenne.cpp"             // code for random number generator
   #include "stoc1.cpp"                // random library source code
   #include "userintf.cpp"             // define system specific user interface
#endif


int main () {
   // define constants
   const int nmin = 1;                 // set the lowest allowed number
   const int nmax = 36;                // set the highest allowed number
   const int select = 6;               // the number of numbers to draw  

   int32 seed = (int32)time(0);        // generate random seed
   StochasticLib1 sto(seed);           // make instance of random library
   int urn[nmax-nmin+1];               // contains the shuffled numbers
   int i;                              // loop counter

   // Make shuffled list of numbers from nmin to nmax:
   sto.Shuffle(urn, nmin, nmax-nmin+1);

   // output heading text
   printf("Random numbers without duplicates:\n\n");

   // loop to output the first "select" numbers
   for (i = 0; i < select; i++) {
      if (i < nmax-nmin+1) {
         // output number
         printf("%4i    ", urn[i]);
      }
   }

   EndOfProgram();                     // system-specific exit code
   return 0;
}
