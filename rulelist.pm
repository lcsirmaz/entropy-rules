## list of rules, to be checked ...
##
## rule:
##  ID, from1, from2, to, paste, id1, id2

use strict;

sub rules {

[

[1,"a,a+b,c,d,a,f,g,a+h,i,j", "",
   "a+d,a+b+2d+a+h+i,a+c+d+f+g,d,a+d,f,g,d+a+h,i,j",
   "r=a:bc","ar,br,cr,d","" ],

[101,"a,a+b,c,d+dx+dy,a,f,g,a+h,i,j", "",
   "a+d,a+b+2d+dy+a+h+i,a+c+d+dx+f+g,d+dx+dy,a+d,f,g,d+a+h,i,j",
   "r=a:bc","ar,br,cr,d","" ],

[2,"a,b+h,c,d,a,f,g,h,i,j", "",
   "a+b,2b+h,b+c+h+j,b+d+h+i,a+b,f,g,b+h,i,j",
   "r=c:ab","ar,br,cr,d","" ],
   
[3,"a,a,c,d+h+z,a+e+h+z,f,g,a+h,i,j", "",
   "a+z,2a+d+h+i+2z,a+c+e+f+g+2h+z,d+h+z,a+e+h+z,f,g,a+h+z,i,j",
   "r=a:bc","ar,br,c,dr","" ],
   
[4, "a,a,c,d,e+h,f,g,h,i,j", "",
    "a+e,a+2e,c+e+h+j,d+e+h+i,e+h,f,g,e+h,i,j",
    "r=c:ab","ar,br,c,dr","" ],

[5, "a,a,c,d+h+z,a+h+z+zp,f,g,a+h,i,j",
    "ap,bp,cp,zp,ap,fp,gp,hp,ip,jp",
    "a+ap+z+zp,2a+d+h+i+bp+hp+ip+2z+2zp,a+c+f+g+2h+ap+cp+fp+gp+z+zp,
      d+h+z+zp,a+h+ap+z+zp,f+fp,g+gp,a+h+hp+z+zp,i+ip,j+jp",
    "r=a:bc","ar,br,c,dr","ar,br,cr,d" ],
    
[6, "a,a,c,d,h+z,f,g,h,i,j",
     "ap,hp+z,cp,dp,ap,fp,gp,hp,ip,jp",
     "a+ap+z,a+hp+2z,c+h+j+cp+hp+jp+z,d+h+i+dp+hp+ip+z,
      h+ap+z,f+fp,g+gp,h+hp+z,i+ip,j+jp",
     "r=c:ab","ar,br,c,dr","ar,br,cr,d" ],

[7, "a,b,c,d+j+z,e,f,g+x+z,h,i,j+x+z", "",
    "a+z,a+b+c+f+j+x+2z,-a+b+c+e+j+x+z,d+j+z,e+z,f,g+x,h+j+z,i,x",
    "r=c:ab","a,r,c,d","" ],

[8, "a,h+ap+cp+z,c,d,a,f,g,h,i,j",
    "ap,ap+bp,cp,d+h+dp+jp+z,ep,fp,a+g+z,hp,ip,jp+z",
    "a+ap+z,h+2ap+bp+cp+fp+jp+2z,c+h+j+bp+cp+ep+jp+z,d+h+i+dp+jp+z,
     a+ep+z,f+fp,g,h+hp+jp+z,i+ip,j",
    "r=c:ab","ar,br,cr,d","a,r,c,d" ],

[9, "a,a+b+f+g+z,c,d,e,f,g+g2+z,h,i,j+z", "",
    "a+z,a+b+f+g+2z,c+d+e+f+g+g2+z,a+c+d+f+g+j+z,e+z,f,g2,h+z,i,j",
    "r=a:bc","a,r,c,d","" ],

[10,"a,b,c+x+z,d,e,f,g,h,i+x+z,j+z",  "",
    "a+z,b+d+h+i+x+2z,c+j+x+z,b+d+x+z,e+z,f,g,h+z,i,j",
    "r=a:bc","a,b,r,d","" ],

[11,"a,b,c,d+x,a+d+e,f,g,a,i,j", "",
    "a+d,a+b+2d+i+x,a+c+d+e+f+g,d+x,a+d+e,f,g,a+d,i,j",
    "r=a:bc","ar,br,cr,dr","" ],

[12,"a,a+z,c,d,a+x+z,f,g,a,i,j", "",
    "a+z,a+2z,a+c+j+z,a+d+i+x+z,a+x+z,f,g,a+z,i,j",
    "r=c:ab","ar,br,cr,dr","" ],

[13,"a,a+y+z,c,d,a+z,f,g,a,i,j", "ap,bp,cp,dp,hp+y,fp,gp,hp,ip,jp",
    "a+ap+y+z,a+bp+ip+2y+2z,a+c+j+cp+fp+hp+ip+jp+y+z,
      a+d+i+dp+gp+hp+ip+y+z,a+hp+y+z,f+fp,g+gp,a+hp+y+z,i+ip,j+jp",
    "r=c:ab","ar,br,cr,dr","a,b,c,dr" ],

[14,"a,a+bp+cp+z,c,d,a+ep+fp+z,f,g,a,i,j",
    "ap,bp,cp,a+d+i+jp+z,ep,fp,a+g+i+z,hp,ip,jp+z",
    "a+ap+z,a+ap+bp+cp+fp+jp+2z,a+c+j-ap+bp+cp+ep+jp+z,
     a+d+i+jp+z,a+ep+z,f+fp,g,a+hp+jp+z,i+ip,j",
    "r=c:ab","ar,br,cr,dr","a,r,c,d" ],

[15,"a,a,c,d,h+ap,f,g,h,i,j",
    "ap,bp,cp,a+dp,ap+ep,fp,g+h+gp,hp,ip,jp",
    "a+ap,a+ap+bp+cp+fp+jp,c+h+j+bp+cp+ep+jp,
     d+h+i+dp+gp+jp,h+ap+ep,f+fp,g+gp,h+hp+jp,i+ip,j",
    "r=c:ab","ar,br,c,dr","a,r,c,d" ],

[16,"a,a,c,-a+ap+cp+dp+fp+x,ep+fp+x,f,g,x-w,i,j",
    "ap,ap+bp+fp+x,cp,dp,ep,fp,g+x,hp,ip,jp+w",
    "a+ap+w,a+i+ap+bp+fp+w+x,-a+c+f+g+cp+dp+ep+fp-w+2x,
     -a+ap+cp+dp+fp+jp+x,ep+x,f+fp,g,hp+x,i+ip,j+jp",
   "r=a:bc","ar,br,c,dr","a,r,c,d" ],

[17,"a,h+z,c,d,e,f,g,h,i,j",
    "ap,bp,cp,dp,hp+z,fp,gp,hp,ip,jp",
    "a+ap+z,h+bp+ip+2z,2c+h+j+cp+fp+hp+ip+jp+z,
     2d+h+i+dp+gp+hp+ip+z,e+hp+z,f+fp,g+gp,h+hp+z,i+ip,j+jp",
    "r=c:ab","a,b,cr,d","a,b,c,dr" ],

[18,"a,b,i+bp+cp+z,d,e,ep+z,g,h,i,j",
    "ap,bp,cp,b+jp+z,ep,fp,e+g+z,hp,ip,jp",
    "a+ap+z,a+b+d+g+i+ap+bp+cp+fp+jp+2z,i-ap+bp+cp+ep+jp+z,
     -a+b+d+e+i+jp+z,
     e+ep+z,fp,g,h+i+hp+jp+z,ip,j",
    "r=c:ab","r,b,c,d","a,r,c,d" ],

[19,"a,a,c,d,a+z,f,g,a,i,j",
    "ap,hp+z,cp,dp,ep,fp,gp,hp,ip,jp",
    "a+ap+z,a+hp+2z,a+c+j+2cp+hp+jp+z,a+d+i+2dp+hp+ip+z,
     a+ep+z,f+fp,g+gp,a+hp+z,i+ip,j+jp",
    "r=c:ab","ar,br,cr,dr","a,b,cr,d" ], 

[20,"a,a+b,c,j+x+z,e,f,x,h,i,j+x", "",
    "a+x+z,a+b+x+2z,c+z,j+z,a+c+e+f+j+2x+z,
     b+e+f+j+x,x,h+x+z,i,j",
    "rs=cd:ab","a,d,r,s","" ],

[21,"a,a+b,c,j+w+x,e,f,g+x,h,i,j+x",
    "ap,ap+bp,cp,z,ep,fp,gp+jp-w+z,hp,ip,jp+z",
    "a+ap+x+z,a+b+j+2ap+bp+cp+fp+x+2z,c+bp+cp+ep+jp+z,
     jp+z,a+c+e+f+ep+jp+2x+z,b+e+f+fp+j+x,
     g+gp+j+x,h+j+hp+jp+x+z,i+ip,0",
    "rs=cd:ab","a,d,r,s","a,c,r,s" ],

[22,"a,h+z,c,d,a,f,g,h,i,j",
    "ap,ap+bp,cp,a+jp+z,ep,fp,gp,hp,ip,jp",
    "a+ap+z,h+ap+bp+jp+2z,c+h+j+cp+z,d+h+i+z,
     a+ap+cp+ep+fp+z,f+bp+ep+fp+jp,g+gp+jp,
     h+hp+jp+z,i+ip,j",
    "rs=cd:ab","ac,bc,cr,s","a,d,r,s" ],

[23,"a,a+b+f+g+x,c,d,e,f,g+g2,h,i,j+x","",
    "a+2x,a+b+f+g+3x,c+d+e+f+g+g2+4x,a+c+d+f+g+j+2x,e+3x,
     f+x,g2,h+2x,i,j",
    "r=a:bc;s=a:bdr", "a,r,c,d","" ],

[24,"w+x-x,w+x,c,d,ap+bp+cp+w+x+z,f,g,w+x-x,i,j",
    "ap,ap+bp,cp,g+i+jp+w+x+z,ep,fp,gp+z,hp,ip,jp+z",
    "ap+w+x+z,ap+bp+jp+w+x+x+z,c+j+cp+w+x,d+i+w+x,
     ap+cp+ep+fp+w+x+2z,f+bp+ep+fp+jp+z,g+gp+jp+z,
     hp+jp+w+x+z,i+ip,j",
    "rs=cd:ab","ac,bc,cr,cs","a,d,r,s" ],

[25,"a,b,c,d,h+z,f,g,h,i,j","",
    "a+z,b+z,c+f+h+j,d+g+h+i,h+2z,f+z,g+z,h+z,i,j",
    "rs=cd:ab","a,b,c,dr" ,"" ],

[26,"a,b,c,j+ep+fp+w+x+z,a+e,f,g+w,h,i,j+w+x",
    "ap,ap+bp,cp,z,ep,fp,b+c+gp+jp+w+x+z,hp,ip,jp+z",
    "a+ap+w+z,b+j+2ap+bp+cp+fp+w+2z,c+jp+z,d+bp+cp+ep+jp+x+z,
     2a+c+e+f+ep+jp+2w+x+z,b+e+f+j+gp+w+x,g+j+fp+w,
     h+j+hp+jp+w+z,i+ip,x",
    "rs=cd:ab","a,d,r,s","b,c,r,s" ],

[126,"a,b,c,j+ep+fp+w+x+z,a+e,f,g+w,h,i,j+w+x",
    "ap,ap+bp,cp,z,ep,fp,b+c+gp+jp+w+x+z,hp,ip,jp+z",
    "a+ap+w+z,b+j+2ap+bp+cp+fp+w+2z,c+jp+z,d+bp+cp+ep+jp+x+z,
     2a+c+e+f+ep+jp+2w+x+z,b+e+f+j+gp+w+x,g+j+fp+w,
     h+j+hp+jp+w+z,i,x+ip",
    "rs=cd:ab","a,d,r,s","b,c,r,s" ],

[27,"a,b,c,d+z,e,f,x+z,h,i,x+z","",
    "a+2x+z,a+b+c+f+5x+2z,-a+b+c+e+3x+z,d+x+z,e+2x+z,
     f,0,h+2x+z,i,0",
    "r=c:ab;s=r:ac","a,r,c,d","" ],

[28,"a,b,c,j+gp+hp+ip+z,a+e,f,z,h,i,j+z",
    "ap,bp,cp,dp,b+c+j+hp+z,fp,gp,hp,ip,jp",
    "a+ap+z,b+bp+z,cp+fp+hp+jp,j+dp+gp+hp+ip,
     2a+e+f+j+hp+2z,b+e+f+j+fp+z,gp+z,h+hp+z,i+ip,j+jp",
    "rs=cd:ab","a,d,r,s","a,b,c,dr" ],

[128,"a,b,c,j+gp+hp+ip+z,a+e,f,z,h,i,j+z",
    "ap,bp,cp,dp,b+c+j+hp+z,fp,gp,hp,ip,jp",
    "a+ap+z,b+bp+z,c+cp+fp+hp+jp,j+dp+gp+hp+ip,
     2a+c+e+f+j+hp+2z,b+e+f+j+fp+z,gp+z,h+hp+z,i+ip,j+jp",
    "rs=cd:ab","a,d,r,s","a,b,c,dr" ],

[29,"a,b,x,d,e,f+x,g,h,x,j", "",
    "a+2x,2b+d+e+g+5x,x,b+2d+e+g+3x,e+2x,f,g,h+2x,,j",
    "r=a:bc;s=r:ab","s,b,c,d", "" ],

[30,"a,a+g+x,c,d,e,f+x,g,h,x,j", "",
    "a+2x,a+g+3x,a+2c+d+e+f+2g+3x,a+c+2d+e+f+2g+3x,
     e+f+2x,,g,h+2x,,j",
    "r=a:bc;s=r:ac","s,b,c,d", "" ],

[31,"a,b,c,x,a+x,f,g,a,i,x", "",
    "a+2x,a+b+i+4x,2a+b+2c+2f+2g+4x,c+x,a+2x,b+c+f+g+x,
     a+f+g+x,a+2x,i,0",
    "r=a:bc;s=a:bdr","ar,rs,cr,dr", "" ],

[32,"x+w-w,x+w,c,d,x+w+z,f,g,x+w-w,i,j", "",
    "x+w+z,w+x+w+z,c+j+x+w,d+i+x+w,x+w+2z,f+z,g+z,x+w+z,i,j",
    "rs=cd:ab","ac,bc,cr,cs", "" ],

[33,"a,b,c,d,e,f,x,h,x,x", "",
    "a+2x,b+e+4x,c+f+h+2x,d+x,e+f+h+3x,e+f+x,,h+2x,,0",
    "r=c:ab;s=r:ad","a,b,c,s", "" ],

[34,"a+d-d,a+d-w+x,c+x,d,a+d+x,f,g,a+d-d,x,j", "",
    "a+d+2x,a+d+d+3x,a+d+j+2x,a+d+d+2x,a+d+2x,a+d+f+g+x,a+d+d+f+g-w+2x,a+d+2x,,j",
    "r=c:ab;s=b:adr","rs,br,cr,dr", "" ],

[35,"e+w-w,e+w+x,c,d,e+w,f,g,e+w-w,i,j",
    "bp+wp-wp,bp+wp,cp,dp,bp+wp-x,fp,gp,bp+wp-wp,ip,jp",
    "e+w+bp+wp,e+w+bp+wp+wp,c+bp+wp+cp+jp,d+bp+wp+dp+ip,e+w+w+bp+wp,e+w+f+j+fp,
     e+w+g+i+gp,e+w+bp+wp,i+ip,j+jp",
    "rs=cd:ab","ad,bd,dr,ds","ac,bc,cr,cs" ], 

[36,"a,a+x,c,d,a+z,f,g,a,i,j",
    "ap,bp,cp,dp,hp-x+z,fp,gp,hp,ip,jp",
    "a+ap+z,a+bp+z,c+cp+fp+hp+jp,d+dp+gp+hp+ip,a+hp+2z,
     a+f+j+fp+z,a+g+i+gp+z,a+hp+z,i+ip,j+jp",
    "rs=cd:ab","ad,bd,dr,ds","a,b,c,dr" ],

[37,"a,a+bp+cp+jp+z+zp,c,d,a+ep+fp+zp,f,g,a,i,j",
    "ap,bp,cp,a+d+i+jp+z+zp,ep,fp,a+g+i+zp,hp,ip,jp+zp",
    "a+ap+z+zp,a+bp+jp+2z+zp,c+cp+z,d+z,a+ap+cp+ep+fp+z+2zp,
     a+f+j-ap+bp+ep+fp+jp+zp,a+g+i+jp+zp,a+hp+jp+z+zp,i+ip,j",
    "rs=cd:ab","ad,bd,dr,ds","a,d,r,s" ],
[38,"a,a+x,x-w,d,e,x,g,a,x,j", "",
    "a+2x,2a+d+g+4x,2j+x,a+d+e+3x,a+e+j+3x,,a+d+g-w+2x,a+2x,,j",
    "r=c:ab;s=b:adr","rs,bs,cs,ds","" ],

[39,"a,a+f+x,c,d,e,f,x,h,i,x", "",
    "2a+c+f+2x,3a+2c+3f+5x,a+2c+2d+2e+3f+3x,a+c+d+f+x,a+c+e+f+2x,
     f,,a+c+f+h+2x,i,0",
    "r=a:bc;s=(ar):bc", "a,s,c,d", "" ],

[40,"a,b,x,d,e,f,g,h,x,x", "",
    "a+b+2x,3b+2d+2h+5x,b+3x,b+d+x,b+e+2x,f,g,b+h+2x,0,0",
    "r=a:bc;s=(ar):bc","a,b,s,d", "" ],

[41,"a+x,a+b+g+x,c,d+x,d+x,f,g,a+x,i,j", "",
    "a+b+d+2g+2x,2a+b+2d+4g+i+3x,2a+3b+2c+2d+f+4g+i+5x,
     d+g+x,a+2b+d+2g+i+3x,a+b+c+d+f+g+2x,b+g,a+b+d+2g+2x,i,j",
    "r=a:bc;s=a:bdr","ars,brs,crs,drs", "" ],

[42,"a,a+b+g,c,d+2dp,a+2d+2dp+e,f,g,a,i,j", "",
    "2a+b+2d+2dp+e+g,3a+b+3d+3dp+2e+g+i,4a+3b+2c+4d+5dp+e+f+4g+i,
     a+2d+2dp+e,3a+2b+3d+3dp+e+2g+i,a+b+c+d+2dp+f+g,b+g,2a+b+2d+2dp+e+g,
     i,j",
    "r=a:bc;s=a:bdr", "ars,brs,crs,drs", "" ],

[43,"a,b,c,z,e,f,bp+dp+z,h,i,z",
    "ap,bp,cp,dp,ep,fp,gp,hp,ip,jp",
    "a+ap+z,a+b+c+f+bp+2z,-a+b+c+e+cp+z,dp+z,e+ep+z,f+fp,
     -ap+bp+ep+gp+ip,h+hp+z,i+ip,jp",
    "rs=cd:ab", "a,c,r,s", "ad,b,r,s" ],

];

}

1;





