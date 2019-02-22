%LET ctpath = "/sasprod/crln/sasdata/aetna";
    /* Client-TPA's SAS grid path */
%LET variable = memberid;
    /* Variable to be analyzed */
%LET z = 1;
    /* Number of values to display */

libname ct &ctpath. ACCESS=readonly;

/* Pulls z non-null example
   value for the chosen variable.
   - Will run in < 1 second.
   - Useful for checking a single
     value. */
DATA temp_nonunique
        (KEEP=Variable Example);
    SET ct.Eligibility 
        (KEEP=&variable.
         WHERE=(NOT MISSING(&variable.))
         OBS=&z.)
        ;
    FORMAT
        Variable $32.
        Example $200.
    ;    
    Variable = "&variable.";
    Example = CATS(&variable.);
        /* Converting all values
           to strings makes it
           possible to append
           multiple datasets
           together even when
           they have different
           variable types */
RUN;

/* Pull z unique non-null example
   values for the chosen variable.
   Slower and useful for examining
   a range of distinct values. */

/* Pull z unique non-null example
   values for the chosen variable.
   - Will run in about 10 seconds.
   - Useful for checking a few values
     when detailed frequency data is
     not needed. */
PROC SORT NODUPKEY
    DATA=ct.Eligibility 
        (KEEP=&variable.
         WHERE=(NOT MISSING(&variable.)))
    OUT=temp_sort
    ;
    FORMAT
        Variable $32.
        Example $200.
    ;
    BY &variable.;
RUN;

DATA temp_sort2 (KEEP=Variable Example);
    SET temp_sort (OBS=&z.);
    Variable = "&variable.";
    Example = CATS(&variable.);
        /* Converting all values
           to strings makes it
           possible to append
           multiple datasets
           together even when
           they have different
           variable types */
RUN;

/* Pull all unique example values
   (including NULL) and calculates
   both count and frequency.
   - Will run in about 20 seconds. 
   - Useful for understanding how
     variable frequencies differ
     by client-TPA. */
PROC FREQ
    DATA=ct.Eligibility (KEEP=&variable.);
    TABLE &variable. / OUT=temp_fq MISSING;
RUN;

DATA temp_fq2 (KEEP=Variable Example);
    SET temp_fq;
    FORMAT
        Variable $32.
        Example $2000.
    ;
    Variable = "&variable.";
    Example = CATS(&variable.);
        /* Converting all values
           to strings makes it
           possible to append
           multiple datasets
           together even when
           they have different
           variable types */
RUN;
