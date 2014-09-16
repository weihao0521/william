/****************************************************************************************/
/*


/*      STAT2131:  SAS Code for 9/9/13
/*
/****************************************************************************************/


/****************************************************************************************/
/*
/*      Topics Overview:
/*              I) 	Libraries and storage
/*              II) The DATA step
/*                      a) CARDS: imputing your own data
/*                      b) SET: from another SAS file
/*                      c) From a text file (or other source)
/*              III)PROC GPLOT
/*              IV)	PROC REG
/*              V) 	DATA setp for finding power
/*              VI) DATA setp to visualize Fisher transfromation
/*              VII) PROC CORR
/*
/*
/****************************************************************************************/

/****************************************************************************************/
/*
/*      I) Libraries and storage:
/*      See the SAS Help and Documentation section 'Introduction to DATA Step Processing'
/*
/*  SAS thinks interms of rectangular data sets.  These data sets are used not only as data
/*  which is to be analyzed but results from analyzes such as p-values and fitted values are
/*  also stored as data sets.
/*
/*      Creating libraries tells SAS where to look for and where to put data sets. The LIBNAME command
/*      to create a library. */

libname STAT2131 'C:\Users\WEZ63\Downloads';

/*  The Explorer to the left can be used to visualize the libraries.  Note that there is a library
/*  `Work'.  This is a temporary library and any work in this library will be lost when the session
/*  is closed.


/****************************************************************************************/
/*
/*      II) The DATA Step
/*      See the SAS Help and Documentation section 'Introduction to DATA Step Processing'
/*
/*      The DATA step imports, organizes, and manipulates data sets.
/*

/*      II a) CARDS: inputting data by hand */

data STAT2131.pg_steam; /* Creates the file `pg_steam.sas' in the library `STAT2131'*/
input seq month steam fat glycerin wind cday opday frezday temp starts;  /* The variables we are creating */
cards;
1       1       10.98   5.20    0.61    7.4     31      20      22      35.3    4
2       2       11.13   5.12    0.64    8.0     29      20      25      29.7    5
3       3       12.51   6.19    0.78    7.4     31      23      17      30.8    4
4       4       8.40    3.89    0.49    7.5     30      20      22      58.8    4
5       5       9.27    6.28    0.84    5.5     31      21      0       61.4    5
6       6       8.73    5.76    0.74    8.9     30      22      0       71.3    4
7       7       6.36    3.45    0.42    4.1     31      11      0       74.4    2
8       8       8.50    6.57    0.87    4.1     31      23      0       76.7    5
9       9       7.82    5.69    0.75    4.1     30      21      0       70.7    4
10      10      9.14    6.14    0.76    4.5     31      20      0       57.5    5
11      11      8.24    4.84    0.65    10.3 	  30 		  20      11      46.4    4
12      12      12.19   4.88    0.62    6.9     31      21      12      28.9    4
13      1       11.88   6.03    0.79    6.6     31      21      25      28.1    5
14      2       9.57    4.55    0.60    7.3     28      19      18      39.1    5
15      3       10.94   5.71    0.70    8.1     31      23      5       46.8    4
16      4       9.58    5.67    0.74    8.4     30      20      7       48.5    4
17      5       10.09   6.72    0.85    6.1     31      22      0       59.3    6
18      6       8.11    4.95    0.67    4.9     30      22      0       70.0    4
19      7       6.83    4.62    0.45    4.6     31      11      0       70.0    3
20      8       8.88    6.60    0.95    3.7     31      23      0       74.5    4
21      9       7.68    5.01    0.64    4.7     30      20      0       72.1    4
22      10      8.47    5.68    0.75    5.3     31      21      1       58.1    6
23      11      8.86    5.28    0.70    6.2     30      20      14      44.6    4
24      12      10.36   5.36    0.67    6.8     31      20      22      33.4    4
25      1       11.08   5.87    0.70    7.5     31      22      28      28.6    5
;
run;

/* II c) Use file->import data drop-down or see `proc import'
/*       experiment with file `steam_text.txt              */
data pg_steam; /*No libname places file in Work*/

infile 'C:\Users\WEZ63\Downloads\steam_text.txt' delimiter=' ';
input seq month steam fat glycerin wind cday opday frezday temp starts;
run;

/* II b) SET: From another .sas file */
data pg_steam2;                 
set STAT2131.pg_steam;
wind2 = wind * wind;                    /*Can manipulate data*/
run;



/****************************************************************************************/
/****************************************************************************************/
/*
/*      III) Proc GPLOT
/*      SAS's proc for high-resolution plotting
*/
/****************************************************************************************/
/****************************************************************************************/
symbol1 color=red                       /* Color of the maker*/
        /*interpol=join*/               /* Connect the markers*/
        value=dot                       /* Marker symbol*/
        height=1;                       /* Marker size*/
symbol2 color=blue
        /*interpol=join*/
        value=star
        height=2;
 proc gplot data=pg_steam2;
   plot steam*temp=1 ;
   plot  steam*glycerin = 1 / haxis=.3 to 1.1 by .1  /*set the x-axis*/
                              vaxis=5 to 14 by 1;    /*set the y-axis*/
   plot steam*month=2;
   plot steam*wind=2;
run;


/****************************************************************************************/
/****************************************************************************************/
/*
/*      IV) Proc REG
/*      SAS's most basic proc that can fit the linear regression model.
*/
/****************************************************************************************/
/****************************************************************************************/
ods rtf FILE = 'model1.RTF';  /* write the output in an rtf file, can be edited in word. */
ods SELECT ALL; 

proc reg data=pg_steam;
model steam=temp;
run;

ods rtf close;

proc reg data=pg_steam2 alpha=.01;
model steam=temp / clb cli clm; /*get ci for the coefficient, prediction intervals, and ci for the regression function*/
plot steam*temp;                                /*plot fitted line and observed data*/
run;

proc reg data=pg_steam2;
model steam=glycerin / noint; /*removing the intercept*/
run;

proc reg data=pg_steam2;
model steam=wind2;
test Intercept + 60*wind2=9 ; /* Testing a Linear Combination*/
run;

proc reg data=pg_steam2;
model steam=temp;
print COVB;                 /* Print the var-cov matrix of the regression parameters*/
run;
quit;

proc reg data=pg_steam2 OUTEST=STAT2131.pars ;
model steam=temp;
output out=STAT2131.out  p = steampred STDI=stdpred STDP=stdmean;
run;
quit;

proc print data = STAT2131.out; run;


/****************************************************************************************/
/****************************************************************************************/
/*
/*      V) Computing power in a data set
*/
/****************************************************************************************/
/****************************************************************************************/
data STAT2131.power;
cutval = tinv(.975,23);
sigma2 =  2.5;
beta =   9;
Omega =   .38;
delta = beta / sqrt(sigma2/Omega);
powerhigh = 1 - CDF('t', cutval, 23, delta);
powerlow = CDF('t', -cutval, 23, delta);
power = powerhigh + powerlow;
run;
proc print data=STAT2131.power; run;



/****************************************************************************************/
/****************************************************************************************/
/*
/*    VI) Visualizing Fisher Transformation
*/
/****************************************************************************************/
/****************************************************************************************/
data fish;
do rho=-.999 to .999 by .01;
	z = .5*log( (1+rho)/(1-rho));
	output;
end;
run;


symbol color=blue
        interpol=join
        value=none;
 proc gplot data=fish;
   plot z*rho ;
run;

/****************************************************************************************/
/****************************************************************************************/
/*
/*    VII) Proc CORR
/*      Used to preform correlation analysis
*/
/****************************************************************************************/
/****************************************************************************************/

proc corr data=pg_steam2 pearson spearman fisher(BIASADJ=no) ; /*remove the bias correction for fisher's Z*/
var steam temp  ;
run;


