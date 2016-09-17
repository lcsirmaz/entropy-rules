/* hull.c */
/* generate the upper envelope of a set of points
 *
 * Copyright(2016) Laszlo Csirmaz, Central European University, Budapest
 *
 * This program is free, open-source software. You may redistribute it
 * and/or modify under the terms of the GNU General Public License (GPL).
 *
 * There is ABSOLUTELY NO WARRANTY, use at your own risk.
 ***********************************************************************/

#include "hull.h"
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

/*-----------------------------------------------------------------------*/
/* assert */
void my_assert(const char *expr,int line){
    fprintf(stderr,"Assertion \"%s\" in line %d failed\n",expr,line);
    exit(7);
}
#define xassert(expr) \
    ((void)((expr) || (my_assert(#expr,__LINE__),1)))

inline static void *xalloc(size_t size){
void *res = malloc(size);
    xassert(res!=NULL); return res;
}

/*-----------------------------------------------------------------------*/
/*
  The convex upper envelope of points (xi,yi,zi), zi>=0, are created
  iteratively. The faces are triangles; they are stored in the doubly
  linked list FACE. Each node contains three points (vertices) and 
  the face equation as
       double mx,my,mz,m;
  where the face is "visible" from the point (x,y,z) if 
  (x,y,z)*(mx,my,mz) < m.

  Vertices of the 2D convex hull of the projection of the upper 
  envelope to the (x,y) plane (z=0) are stored in the CONV structure.
  It is circularly linked in positive order; contains the point,
  the equation of the line, and the EDGE of which it is adjacent.

  Edges of the convex hull are stored in the EDGE structure. Each EDGE
  has one or two adjacent facets in adjface[0] and adjface[1]. When 
  adjface[1]==NULL, the edge is on the fringe, and the "fringe" field
  points to the corresponding CONV entry. EDGE also contains the two
  points, and flags whether it will be deleted at the end of the
  iteration.

  When a new point P is added then P_VERTEX is the "horizon" as the
  convex envelope is seen from P. It starts and ends at fringe points;
  and is build up going through all edges of the envelope. If exactly
  one of the two faces adjacent to the edge are visible from P, then
  the edge is on the horizon.
*/

typedef struct _POINT_ {    /* points with coordinates x,y,z; z>=0 */
    double x,y,z;
} POINT;

typedef struct _LINE_ {     /* plane line equation */
    double x,y,m;		/* x*l.x + y*l.y + l.m = 0 */
} LINE;

typedef struct _HORIZON_ { /* horizon as seen from the new point */
    struct _HORIZON_ *next;     /* simple linked list */
    POINT *P;			/* the point */
    struct _EDGE_ *e1,*e2;	/* edges getting out from here */
    struct _HORIZON_ *v1,*v2;	/* other vertices of the edges */
} HORIZON;

typedef struct _FACE_ {   /* face structure */
    struct _FACE_ *prev, *next; /* doubly linked list */
    double mx,my,mz,m;          /* visible if (x,y,z)*(mx,my,mz) < m */
    int visible;
    POINT *b1,*b2,*b3;          /* vertices of this face */
} FACE;

typedef struct _EDGE_ {   /* edge in the convex hull */
    struct _EDGE_ *prev, *next;
    FACE *adjface[2];		/* at most two adjacent faces */
    POINT *x,*y;		/* two endpoints */
    struct _CONV_ *fringe;	/* if it is on the fringe, NULL otherwise */
    int to_be_deleted;		/* to be deleted */
    int no_fringe;		/* it won't be on the fringe at the next round */
} EDGE;

typedef struct _CONV_ {   /* 2D convex hull of the (xy) projection */
    struct _CONV_ *prev, *next;	/* circular list in positive order */
    POINT *P;			/* coordinates of the point */
    LINE l;			/* line connecting to the next point */
    EDGE *edge;			/* edge of the convex hull from here to the next point */
} CONV;

static HORIZON *horizon=NULL, *horizonfree=NULL;
static FACE *faces=NULL, *facesfree=NULL; 
static CONV *conv=NULL, *convfree=NULL;
static EDGE *edges=NULL, *edgesfree=NULL;

/*-----------------------------------------------------------------------*/
/* something is zero if it is between -H_EPS and H_EPS */
#define H_EPS	5e-9
/* allocate each block in multiplies of this number */
#define ASIZE	500

inline static void free_horizon(void) /* empty the horizon */
{HORIZON *p,*pp;
    p=horizon; while(p){
        pp=p->next;
        p->next=horizonfree; horizonfree=p;
        p=pp;
    }
    horizon=NULL;
}

/* check if this point is on the horizon; if not, add */
static HORIZON *get_in_horizon(POINT *Pt) // get_vertex_to()
{HORIZON *p; int i;
    p=horizon;
    while(p){
        if(p->P == Pt) return p; /* found */
        p=p->next;
    } /* find an empty node */
    p=horizonfree; if(!p){
        horizonfree=xalloc(ASIZE*sizeof(HORIZON));
        for(i=0;i<ASIZE-1;i++){horizonfree[i].next=&(horizonfree[i+1]);}
        horizonfree[ASIZE-1].next=NULL;
        p=horizonfree;
    }
    horizonfree=p->next;
    p->P=Pt;
    p->e1=NULL; p->e2=NULL; p->v1=NULL; p->v2=NULL;
    p->next=horizon; horizon=p;
    return p;
}

inline static void delete_face(FACE *f)
{FACE *prevf;
    prevf=f->prev;
    if(prevf){ /* not the first one */
        prevf->next=f->next; if(f->next){f->next->prev=prevf; }
    } else { /* first one */
        xassert(faces==f);
        faces=f->next; if(faces)faces->prev=NULL;
    }
    f->next=facesfree; facesfree=f; f->visible=-1;
}

/* create a face from three points on it */
static FACE *create_face(POINT *p1, POINT *p2, POINT *p3)
{FACE *face; int i;
    face=facesfree; if(face==NULL){
        facesfree=xalloc(ASIZE*sizeof(FACE));
        for(i=0;i<ASIZE-1;i++){facesfree[i].next=&(facesfree[i+1]); facesfree[i].visible=-1;}
        facesfree[ASIZE-1].next=NULL;
        face=facesfree;
    }
    facesfree=face->next;
    if(faces) faces->prev=face; /* insert to the front */
    face->next=faces; face->prev=NULL; faces=face;
    face->b1=p1; face->b2=p2; face->b3=p3;
    face->visible=0;
    face->mx=(p3->z-p2->z)*(p3->y-p1->y) - (p3->z-p1->z)*(p3->y-p2->y);
    face->my=(p3->z-p1->z)*(p3->x-p2->x) - (p3->z-p2->z)*(p3->x-p1->x);
    face->mz=(p3->x-p1->x)*(p3->y-p2->y) - (p3->x-p2->x)*(p3->y-p1->y);
    face->m= face->mx*p1->x + face->my*p1->y + face->mz*p1->z;
    return face;
}

/* free the given CONV block */
inline static void free_conv(CONV *v){
    v->next=convfree; convfree=v;
}

/* get the next CONV block */
static CONV *get_next_conv(void)
{CONV *n; int i;
    n=convfree; if(n==NULL){
        convfree=xalloc(ASIZE*sizeof(CONV));
        for(i=0;i<ASIZE-1;i++){convfree[i].next=&(convfree[i+1]);}
        convfree[ASIZE-1].next=NULL;
        n=convfree;
    }
    convfree=n->next; n->next=NULL; n->prev=NULL;
    return n;
}

inline static void delete_edge(EDGE *e)
{EDGE *preve;
    preve=e->prev; if(preve){
        preve->next=e->next; if(e->next){e->next->prev=preve; }
    } else {/* first */
        xassert(edges==e);
        edges=e->next; if(edges)edges->prev=NULL;
    }
    e->next=edgesfree; edgesfree=e;
}

static EDGE *create_edge(POINT *p1, POINT *p2)
{EDGE *e; int i;
    e=edgesfree; if(e==NULL){
         edgesfree=xalloc(ASIZE*sizeof(EDGE));
         for(i=0;i<ASIZE-1;i++){edgesfree[i].next= &(edgesfree[i+1]); }
         edgesfree[ASIZE-1].next=NULL;
         e=edgesfree;
    }
    edgesfree=e->next;
    if(edges) edges->prev=e;
    e->next=edges; e->prev=NULL; edges=e;
    e->x=p1; e->y=p2;
    e->fringe=NULL;
    e->to_be_deleted=0; e->no_fringe=0; e->adjface[0]=e->adjface[1]=NULL;
    return e;
}

/*-----------------------------------------------------------------------*/

/* point P is on which side of the line l */
static inline double online(POINT *P, LINE l){
    return P->x*l.x + P->y*l.y + l.m;
}

/* compute the line from -> to, and store its equation in from */
static inline void draw_line(CONV *from, CONV *to){
    from->l.x=to->P->y - from->P->y;
    from->l.y=from->P->x - to->P->x;
    from->l.m = from->P->y*to->P->x - from->P->x*to->P->y;
}

/* check the COMV chain */
static void check_conv_chain(void)
{CONV *from;
    xassert(online(conv->prev->P,conv->l) >-H_EPS );
    for(from=conv->next; conv!=from; from=from->next){
        xassert(online(from->prev->P,from->l) > -H_EPS );
    }
}

/* mark all faces visible form the point P */
static inline void mark_visible_faces(POINT *P)
{FACE *f;
    f=faces; while(f){
        f->visible = (P->x*f->mx+P->y*f->my+P->z*f->mz) < f->m-H_EPS;
        f=f->next;
    }
}

/* delete faces in which the delete_face flag is set */
static inline void clean_up_visible_faces(void)
{FACE *f,*ff;
    f=faces; while(f){
        ff=f->next; if(f->visible){
            xassert(f->visible>0);
            delete_face(f);
        }
        f=ff;
    }
}

/*-----------------------------------------------------------------------*/

/* add the edge to the horizon */
static void add_to_horizon(EDGE *edge)
{HORIZON *p1, *p2;
    p1=get_in_horizon(edge->x); p2=get_in_horizon(edge->y);
    if(p1->e1==NULL){ p1->e1=edge; p1->v1=p2; }
    else if(p1->e2==NULL){ p1->e2=edge; p1->v2=p2; }
    else xassert(p1!=p1); /* impossible */
    if(p2->e1==NULL){ p2->e1=edge; p2->v1=p1; }
    else if(p2->e2==NULL){ p2->e2=edge; p2->v2=p1; }
    else xassert(p2!=p2);
}

/* faces which are visible from the new point P has been marked. Go over all
   edges and check its two faces. If one is visible and the other is not,
   it is on the "horizon"; collect these edges by calling add_to_horizon().
   If both faces are visible, set the edge's "to_be_deleted" flag. */
static void process_edges(void)
{EDGE *e; int visiblefaces;
    free_horizon(); /* make sure the horizon list is empty */
    e=edges;
    while(e){
        if(e->adjface[1]){ /* internal edge */
            visiblefaces=0;
            xassert(e->adjface[0]->visible>=0); /* face has been deleted */
            xassert(e->adjface[1]->visible>=0);
            if(e->adjface[0]->visible) visiblefaces++;
            if(e->adjface[1]->visible) visiblefaces++;
            if(visiblefaces==2) e->to_be_deleted=1;
            else if(visiblefaces==1) add_to_horizon(e); /* to be processed */
        } else if(e->no_fringe) { /* external edge, will go away */
            xassert(e->adjface[0]->visible>=0);
            if(e->adjface[0]->visible) e->to_be_deleted=1;
            else add_to_horizon(e); /* (e,P) is a new face */
        } else { /* external edge, remains */
            xassert(e->adjface[0]->visible>=0);
            if(e->adjface[0]->visible) add_to_horizon(e);
        }
        e=e->next;
    }
}

static void clean_up_edges(void)
{EDGE *e, *ee;
    e=edges;
    while(e){
        ee=e->next;
        if(e->to_be_deleted){delete_edge(e);}
        else xassert( (e->adjface[1]==NULL) != (e->fringe==NULL) );
        e=ee;
    }
}

/*-----------------------------------------------------------------------*/
/* add new faces: go through the path which starts at "from" and ends
   at "to"; create all new faces and new edges which are adjacent to 
   the new point P. */
static void add_new_faces(CONV *from, CONV *to, POINT *P)
{HORIZON *p1, *p2; EDGE *epfrom, *ep1, *ep2, *e; FACE *face;
CONV *v,*vv;
    p1=get_in_horizon(from->P); /* only one such a vertex */
    xassert( p1->e1!=NULL); xassert(p1->e2==NULL);
    p2=p1->v1; e=p1->e1; /* p2: next vertex in the horizon */
    /* create new edge connecting P and p1->P */
    epfrom = ep1 = create_edge(P,p1->P);
    while(p2){ /* go over the horizon */
        ep2=create_edge(P,p2->P); /* should be a new edge */
        face=create_face(p1->P, P, p2->P);
        if(ep1->adjface[0]) ep1->adjface[1]=face; else ep1->adjface[0]=face;
        ep2->adjface[0]=face;
        /* add this face to the edge "e" as well */
        if(e->adjface[0] && e->adjface[0]->visible){e->adjface[0]=face; }
        else if(e->adjface[1] && e->adjface[1]->visible){e->adjface[1]=face; }
        else if(e->adjface[0]==NULL) xassert(e->adjface[0]!=NULL);
        else if(e->adjface[1]==NULL) e->adjface[1]=face;
        else xassert(e->adjface[1]==NULL);
        if(p2->v1==p1){ /* move to p2->v2 */
            p1=p2; p2=p1->v2; e=p1->e2; ep1=ep2;
        } else if(p2->v2==p1){ /* move to p2->v1 */
            p1=p2; p2=p1->v1; e=p1->e1; ep1=ep2;
        } else xassert(p2!=p2);
    }
    xassert(p1->P == to->P);
    /* adjust fringe edges as well */
    /* free intermediate vertices; revoke no_fringe flag */
    from->edge->no_fringe=0; from->edge->fringe=NULL;
    v=from->next; while(v!=to){
        vv=v; v=v->next; vv->edge->no_fringe=0; vv->edge->fringe=NULL;
        free_conv(vv);
    }
    v=get_next_conv(); from->next=v; v->prev=from; v->next=to; to->prev=v;
    v->P=P;
    draw_line(from,v); draw_line(v,to);
    epfrom->fringe=from; ep1->fringe=v;
    from->edge=epfrom; v->edge=ep1;
}

/*-----------------------------------------------------------------------*/
/* add point P to the convex hull. Find points "from" and "to" on the
   CONV curve which is seen from (P.x,P.y). If P is inside CONV or just
   on it, then return.
   Mark all faces visible from P.
   Create the "horizon" starting at "from" end endig at "to" going 
   through edges which have one of their faces visible and the other
   not visible. Create new faces through P and edges in the horizon. */
static void add_point(POINT *P)
{CONV *from, *to, *v; double d;
    if(online(P,conv->l)>H_EPS){
        for(from=conv->next; from!=conv && online(P,from->l)>H_EPS; from=from->next);
        if(from==conv){ /* P is inside CONV, thus below the envelope */
            return; /* nothing to do */
        }
        for(to=from->next; online(P,to->l)<=H_EPS; to=to->next);
        // (P, (from-1)) >0, (P,from) <=0; (P,to-1) <=0, (P,to) > 0
    } else {
        for(to=conv->next;to!=conv && online(P,to->l)<=H_EPS; to=to->next);
        xassert(to != conv);
        for(from=conv;online(P,from->prev->l)<=H_EPS; from=from->prev);
        // (P,to-1)<=0; (P,to)>0 (P,from)<=0; (P,from-1)>0
    }
    /* (P,from-1)>0, (P,from)<=0, (P,to-1)<=0, (P,to)>0 */
    if(from->next==to && online(P,from->l)>-H_EPS){
        return;
    }
    if(from->next==to->prev && online(P,from->l)>-H_EPS && online(P,from->next->l)>-H_EPS){
        /* P and from->next->P are the same */
        return;
    }
    /* mark faces on the convex hull which are visible from P, they will be deleted */
    mark_visible_faces(P);
    /* now move ahead with "from" until P is still on the same line
       and the face adjacent to the edge is not visible */
    while((d=online(P,from->l))<H_EPS && d>-H_EPS && !from->edge->adjface[0]->visible) from=from->next;
    /* move backward "to" until the same condition */
    while((d=online(P,to->prev->l))<H_EPS && d>-H_EPS && !to->prev->edge->adjface[0]->visible) to=to->prev;
    xassert(from!=to);
    conv=from; /* reset the origin to this point, this remains on the list */
    /* edges from-->to will be internal edges thus can vanish.
       edges to-->from will be external edges with from -> P -> to */
    /* mark internal edges which will be deleted from the CONV list */
    for(v=from;v!=to;v=v->next){ v->edge->no_fringe=1; }
    /* go over edges of the convex hull and figure out who stays: */
    process_edges();
    /* add all new faces and adjust the convex hull: */
    add_new_faces(from,to,P);
    /* clean up all stuff; faces marked as visible are deleted: */
    clean_up_visible_faces();
    clean_up_edges();
}

/*=======================================================================*/

#define PT_BLOCK_SIZE	500	/* number of points in a single block */

typedef struct _PT_BLOCK_ {
    struct _PT_BLOCK_ *next;	/* lined list of pot blocks */
    POINT P[PT_BLOCK_SIZE];
} PT_BLOCK;

static POINT **points=NULL;
static PT_BLOCK *pt_block=NULL;
static int pt_blocksize=PT_BLOCK_SIZE;

/* Add a point; check that z>=0 */
void next_point(double x, double y, double z)
{PT_BLOCK *block;
    if(pt_blocksize==PT_BLOCK_SIZE){
        block=xalloc(sizeof(PT_BLOCK));
        block->next=pt_block; pt_block=block;
        pt_blocksize=0;
    }
    xassert(z>=0.0);
    pt_block->P[pt_blocksize].x=x;
    pt_block->P[pt_blocksize].y=y;
    pt_block->P[pt_blocksize].z=z;
    pt_blocksize++;
}
/* sorting function for qsort */
static int qcmp( const void *a, const void *b) /* reverse order */
{double c;
    c=(*(const POINT**)a)->z - (*(const POINT**)b)->z;
    return c<0.0 ? +1 : c>0.0 ? -1 : 0;
}

/* sort the points, return the total of points */
static int sort_points(void)
{int n,i; PT_BLOCK *pb;
    n=pt_blocksize;
    for(pb=pt_block; pb->next; pb=pb->next) n+=PT_BLOCK_SIZE;
    points = xalloc(n*sizeof( POINT *));
    for(n=0;n<pt_blocksize;n++) points[n]=&(pt_block->P[n]);
    pb=pt_block; while(pb->next){
        pb=pb->next;
        for(i=0;i<PT_BLOCK_SIZE;i++,n++) points[n]=&(pb->P[i]);
    }
    qsort(points,n,sizeof(points[0]),qcmp);
    return n;
}

/*=======================================================================*/
/* Points are ordered according to their height (z coordinate), and
   are stored in points[0..sorted_length-1]. Form the initial triangle
   from the three highest points in points[0], point[1], points[2].
   Complain if they do not form a triangle. Add other points in 
   decreasing height. */
void make_convex_hull(void)
{CONV *a,*b,*c; /* first three points */
 int k,sorted_length;
 FACE *face; EDGE *ab,*bc,*ca;
    sorted_length=sort_points();
    xassert(sorted_length>=3);
    a=get_next_conv(); b=get_next_conv(); c=get_next_conv();
    a->next=b; b->next=c; c->next=a;
    a->prev=c; c->prev=b; b->prev=a;
    a->P=points[0]; b->P=points[1]; c->P=points[2];
    draw_line(a,b); draw_line(b,c); draw_line(c,a);
    if(online(c->P,a->l)<-H_EPS){
       a->P=points[1]; b->P=points[0];c->P=points[2];
       draw_line(a,b); draw_line(b,c); draw_line(c,a);
    }
    xassert(online(c->P,a->l)>H_EPS); /* they must form a triangle */
    conv=a;
    face=create_face(a->P,b->P,c->P);
    ab=create_edge(a->P,b->P);
    ab->adjface[0]=face; ab->fringe=a;
    bc=create_edge(b->P,c->P);
    bc->adjface[0]=face; bc->fringe=b;
    ca=create_edge(c->P,a->P);
    ca->adjface[0]=face; ca->fringe=c;
    a->edge=ab; b->edge=bc; c->edge=ca;
    /* just sanity check */
    check_conv_chain();
    /* this was the initial setting */
    for(k=3;k<sorted_length;k++){
         add_point(points[k]);
         check_conv_chain(); /* just sanity check, can be omitted */
    }
}

/*=======================================================================*/
/* save the convex hull to an STL file. Add a triangulation of the 
   bottom if requested */
/* format of an stl file:
   header: 80 byte (empty)
   uint32: number ot triangles
   for each triangle:
   float[3] :: normal
   float[3]: first
   float[3] second
   float[3] third
   uint16 : 0
*/
static FILE *STL=NULL;
struct { float normal[3]; float x[3]; float y[3]; float z[3];
         char dummy[2]; } __attribute__((packed)) stldata;
struct { char header[80]; int length;} __attribute__((packed)) stlheader;

static void open_STL(char *filename, int total)
{int i;
    STL=fopen(filename,"wb");
    xassert(STL!=NULL);
    stlheader.length=total;
    for(i=0;i<80;i++)stlheader.header[i]=0;
    fwrite(&stlheader,sizeof(stlheader),1,STL);
    stldata.dummy[0]=stldata.dummy[1]=0;
    stldata.normal[0]=stldata.normal[1]=stldata.normal[2]=0;
}

static void close_STL(void){
    if(STL==NULL) return;
    fclose(STL); STL=NULL;
}

static void print_triangle(POINT *a, POINT *b, POINT *c)
{   if(STL==NULL) return;
    stldata.x[0]=a->x; stldata.x[1]=a->y; stldata.x[2]=a->z;
    stldata.y[0]=b->x; stldata.y[1]=b->y; stldata.y[2]=b->z;
    stldata.z[0]=c->x; stldata.z[1]=c->y; stldata.z[2]=c->z;
    fwrite(&stldata,1,sizeof(stldata),STL);
}

void print_STL(char *filename, int add_bottom)
{FACE *f; int total=0; CONV *from;
    if(add_bottom){
        for(from=conv->next; conv!=from; from=from->next) total++;
        xassert(total>=2);
        total--;
    }
    for(f=faces;f;f=f->next) total++;
    open_STL(filename,total);
    for(f=faces;f;f=f->next){
        print_triangle(f->b1,f->b2,f->b3);
    }
    if(add_bottom){
        for(from=conv->next;from->next!=conv; from=from->next){
           print_triangle(from->P,conv->P,from->next->P);
        }
    }
    close_STL();
}
/* EOF */

