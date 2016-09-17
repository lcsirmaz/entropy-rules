/* outer.c */
/* create the STL file which is the outer approximation of the
 *  3D core of the 4-variable entropy region from the result
 *  of the MOLP problem generated by the utility outer.pl
 *
 * Copyright(2016) Laszlo Csirmaz, Central European University, Budapest
 *
 * This program is free, open-source software. You may redistribute it
 * and/or modify under the terms of the GNU General Public License (GPL).
 *
 * There is ABSOLUTELY NO WARRANTY, use at your own risk.
 ***********************************************************************/

/* The only input is the XXX.res file which contains points as
V  19/167 6/167 38/167
V  45/79 0 4/79
V  0.14310382041874 0.053960716598316 0.19296352255558
   The three numbers correspond to beta,gamma,delta values,
   and alpha=1.0-beta-gamma-delta.
   The (x,y,z) point is inside a regular tetrahedron with 
   weights alpha/beta/gamma/delta at the four vertices.
   The edge of the tetrahedron is TEDGE, and its height is
   multiplied by THEIGHT.

   It invokes routines from hull.c to create the triangles
   of the upper envelope of the points.
*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "hull.h"	/* upper envelope routines */

/*=============================================================*/
/* edge size of the tetrahedron, and the height multiplier */
#define TEDGE		100.0
#define THEIGHT		1.7
/*=============================================================*/
/* parsing the XXX.res file */
#define LINELEN		128	/* maximum length of a line */
static FILE *handle=NULL;	/* result file handle */
static char line[LINELEN+10];	/* next line from the file */

int nextline(void)
{int i,sp,ch;
    if(handle==NULL) return 0;
    i=0;sp=0; memset(line,0,LINELEN+1);
    while((ch=getc(handle))>=0){
        if(ch=='\n'){ if(i<=0){sp=0;i=0;continue;} return 1; }
        if(i<0) continue; // skip this line
        if(i==0 && sp==0){
            if(ch=='V'){ sp=1; }
            else {i=-1; }
            continue;
        }
        if(ch==' '||ch=='\t'){ sp=1; continue; }
        if(ch<0x20 || ch>126) continue; // ignore
        if(sp && i>0 && i<LINELEN){ line[i]=' ';i++; }
        sp=0; if(i<LINELEN){line[i]=ch;i++; }
    } /* EOF */
    if(i>0) return 1;
    fclose(handle); handle=NULL;
    return 0;
}
/* check if str[] starts with a (floating) number. If yes, store
   its value in *v, and return the length of the matching part. */
static int parse_num(char *str, double *v)
{int i; char *s;
    if(!*str) return 0; // no more input
    for(i=0,s=str;('0'<=*s && *s<='9')|| *s=='+'||*s=='-'
        ||*s=='.'||*s=='e';i++,s++);
    if(i==0) return -1; // syntax error
    if(sscanf(str,"%lf",v)!=1) return -1; // syntax error
    return i;
}
/* check if str[] starts with number or number/number. If yes,
   store the value in *v and return the length of the matchin part. */
static int parse_real(char *str,double *v)
{int i,ret; double d;
    i=0; while(*str==' '){str++;i++; }
    ret=parse_num(str,v);
    if(ret<=0) return ret; // 0 or -1
    i+=ret; str+=ret;
    if(*str=='/'){
        str++;i++; d=*v;
        ret=parse_num(str,v);
        if(ret<=0) return -1; // syntax error
        i+=ret; *v = d/(*v);
    }
    return i;
}
/* store three real numbers from the line to the given array */
static void parseline(double *to /*0..2*/)
{char *str; int i,ret;
    str=line;
    for(i=0;i<3;i++,to++){
        ret=parse_real(str,to);
        if(ret<0){ //error
           fprintf(stderr,"Error parsing input line\n%s\n",line);
           exit(1);
        }
        str+=ret;
    }
    if(*str){ // extra characters at the end
        fprintf(stderr,"Extra characters at the end of line\n%s\n",line);
        exit(1);
    }
}
/* initialize reading lines from input */
void init_reading(const char *fname)
{   handle=fopen(fname,"r");
    if(!handle){ fprintf(stderr,"Cannot open file %s for reading\n",fname); exit(1); }
}
/* to read all lines from the input file, do the following:
    init_reading(fname);
    while(nextline(){
        double data[3];
        parseline(&data[0]);
        ... work with data[0], data[1], data[2] ...
    }
*/
/*=============================================================*/

/* main routine
   arguments: <input.res> <output.stl>
*/
int main(int argc,char *argv[])
{double x,y,z; double d[4]; int cnt;
    if(argc!=3){
        printf("usage: <input.res> <output.stl>\n");
        return 1;
    }
    init_reading(argv[1]); cnt=0;
    while(nextline()){
        parseline(&d[0]);
#define beta	d[0]
#define gamma	d[1]
#define delta	d[2]
#define alpha	d[3]
        alpha=1.0-beta-gamma-delta;
        // beta*(0,0,0) + gamma*(1,0,0)+
        // delta*(1/2,r3/2,0) + alpha*(1/2,r3/6,r6/3)
        x=TEDGE*gamma + (TEDGE*0.5)*delta + (TEDGE*0.5)*alpha;
        y=(TEDGE*sqrt(3.0)*0.5)*delta + (TEDGE*sqrt(3.0)/6.0)*alpha;
        z=(THEIGHT*TEDGE*sqrt(6.0)/3.0)*alpha;
        // and pass it to the convex hull algorithm
        next_point(x,y,z);
        cnt++;
#undef alpha
#undef beta
#undef gamma
#undef delta        
    }
    next_point( 0.0,0.0,0.0); // beta
    next_point(TEDGE,0.0,0.0); // gamma
    next_point( TEDGE*0.5,TEDGE*sqrt(3.0)/2.0,0.0); // delta
    printf("data is read, number of points=%d\n",cnt);
    if(cnt<3) return 1;
    make_convex_hull();
    print_STL(argv[2],1);
    return 0;
}

/* EOF */

