#include "mex.h"
#include "matrix.h"
#include <math.h>
#include <sys/types.h>
#include <unistd.h>

/****************************************************************************/
/* Input arguments                                                          */
/****************************************************************************/
#define IN         prhs[0]

/****************************************************************************/
/* Output arguments                                                         */
/****************************************************************************/
#define OUT        plhs[0]

/****************************************************************************/
/* Macros and misc definitions                                              */
/****************************************************************************/
#define SAMPLE float /* define the type used for data samples */

/****************************************************************************/
/* Function Declarations                                                    */
/****************************************************************************/
static void ibm_to_float(int from[], int to[], int n, int endian, int verbose);

/****************************************************************************/
/* Gateway function and error checking                                      */
/****************************************************************************/
void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
   SAMPLE *output;
   float *pin;
   int xLen;
   
   /*do some error checking*/
   if ( nrhs < 1)
       mexErrMsgTxt("Single argument only");
   
   xLen =  (int) mxGetN(IN)*mxGetM(IN);
   
   
   pin = mxGetData(IN);
   /* do the matlab stuff
    * mexPrintf("N elements in array = %d.\n",xLen);
    * OUT = mxCreateNumericMatrix( (mwSize)xLen,1,mxSINGLE_CLASS,mxREAL);
    * output = mxGetData(OUT); */
   output = 0;
   
   ibm_to_float(pin,pin,xLen,1,0);
   /* do the number crunching
    * a = get_matrix_pointers(xLen, output);
    * py_dist(a, xDim, yDim);
    * release_matrix_pointers(a);*/
}



static void ibm_to_float(int from[], int to[], int n, int endian, int verbose)
/***********************************************************************
ibm_to_float - convert between 32 bit IBM and IEEE floating numbers
************************************************************************
Input::
from		input vector
to		output vector, can be same as input vector
endian		byte order =0 little endian (DEC, PC's)
			    =1 other systems
*************************************************************************
Notes:
Up to 3 bits lost on IEEE -> IBM

Assumes sizeof(int) == sizeof(float) == 4

IBM -> IEEE may overflow or underflow, taken care of by
substituting large number or zero

*************************************************************************
Credits: SEP: Stewart A. Levin,  c.1995
*************************************************************************/

/* See if this fits the bill for your needs - Stew */
/* ibmflt.f -- translated by f2c (version 1995/10/25).
*/
/* Subroutine */
{
    /* Initialized data */

    static int first = 1;

    /* System generated locals */
    int i__1;
    int j,k;

    /* Local variables */
    int   *in;
    float *out;
    int eibm, i__, mhibm;
    static int m1[512];
    static float r1[512];

    unsigned int jj;
    union {
      float rrf;
      int iif;
      unsigned int uuf;
    } cvtmp;
	
    float r_infinity__;
    int et3e;

    if(endian == 0) {
      swab(from,to,n*sizeof(int));
      for(i__ = 0; i__<n; ++i__) {
        j = to[i__];
        k = j<<16;
        to[i__] = k+((j>>16)&65535);
      }
      in = to;
    } else {
      in = from;
    }
    /* Parameter adjustments */
    out = (float *) to;
    --out;
    --in;
    /* Function Body */

    if (first) {
	first = ! first;
	cvtmp.iif = 2139095039;
	r_infinity__ = cvtmp.rrf;
	for (i__ = 0; i__ <= 511; ++i__) {
	    i__1 = i__ & 255;
	    eibm = i__1 >> 1;
	    mhibm = i__ & 1;
	    et3e = (eibm << 2) - 130;
	    if (et3e > 0 && et3e <= 255) {
		i__1 = et3e ^ (i__ & 255);
		m1[i__] = i__1 << 23;
		if (mhibm == 1) {
		    r1[i__] = 0.f;
		} else {
		    i__1 = et3e | (i__ & 256);
		    cvtmp.iif = i__1 << 23;
		    r1[i__] = -(cvtmp.rrf);
		}
	    } else if (et3e <= 0) {
		m1[i__] = i__ << 23;
		r1[i__] = 0.f;
	    } else {
		m1[i__] = i__ << 23;
		if (i__ < 256) {
		    r1[i__] = r_infinity__;
		} else {
		    r1[i__] = -r_infinity__;
		}
	    }
/* L10: */
	}
    }

    for (i__ = 1; i__ <= n; ++i__) {
	cvtmp.iif = in[i__];
/* use 9 high bits for table lookup */
	jj = cvtmp.uuf>>23;
/* fix up exponent */
	cvtmp.iif = m1[jj] ^ cvtmp.iif;
/* fix up mantissa */
	out[i__] = cvtmp.rrf + r1[jj];
/* L20: */
    }
}
