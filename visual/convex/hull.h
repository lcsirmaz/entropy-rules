/* generate the upper envelope of a set of points */
/* the upper envelope is created for points (x,y,z) with z>=0.
   The result is printed as an STL file. The bottom is closed
   if the second argument is given. It might cross the envelope
   except when the bottom is a trianlge (which is the case
   in our applications) */

/* add point (x,y,z) as the convex hull. z>=0.0 */
void next_point(double x,double y, double z);
/* create the upper envelope */
void make_convex_hull(void);
/* and print it as an STL file with or without the bottom */
void print_STL(char *filename, int add_bottom);

/* EOF */

