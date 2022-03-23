options nocenter nonumber nodate orientation=portrait;

filename in1 'C:\Users\radon\OneDrive\Documents\820\dumping.txt';
filename res 'C:\Users\radon\OneDrive\Documents\820\SAS_Output_HW5_Rachel_Donahue.rtf';

proc format;
     value severf 1='(1) none' 2='(2) slight' 3='(3) moderate';
     value procf  1='Drain' 2 ='25-Rescet' 3='50-Resec' 4='75-Resec';
	 value imp1f 0='None or Slight' 1='Moderate';
	 value imp2f 0='None' 1='Slight or Moderate';
run;

data one;
     infile in1;
     input hosp proc severity count;
	 if (severity=1) then improve=1;
	 else if (severity=2) then improve=2;
	 else if (severity=3) then improve=3;
	 if (improve=3) then improv1=1;
	 else improv1=0;
	 if (improve ge 2) then improv2=1;
	 else improv2=0;
     format improve severf. improv1 imp1f. improv2 imp2f. severity severf. proc procf.;
run;

ods rtf file=res bodytitle style=journal;

proc contents data=one;
run;


/*Question 1*/

/*Verifying the data structure*/

proc sql;
	select hosp, proc, severity, count
	from one;
quit;

proc freq data=one;
	tables proc*improv1 hosp*improv1 /nopercent nocol;
	weight count;
	title1 'Counts for Moderate vs Slight or None';
run;

proc freq data=one;
	tables proc*improv2 hosp*improv2 /nopercent nocol;
	weight count;
	title1 'Counts for Moderate and Slight vs None';
run;

proc freq data=one;
	tables severity*proc severity*hosp / nopercent nocol;
	weight count;
	title1 'Overall Counts';
run;

/*Model*/

proc logistic data=one descending;
	class proc (ref='Drain') / param=ref;
	freq count;
	model severity=hosp proc;
	title1 'Proportional Odds Model';
run;

/*Question 2*/

proc logistic data=one descending;
	class proc (ref='Drain') severity (ref='(1) none') / param=ref;
	freq count;
	model severity=hosp proc / link=glogit;
	title1 'Multinomial Model';
run;


/*Question 3*/

filename in12    'C:\Users\radon\OneDrive\Documents\820\HELPJsat0.csv';

proc import OUT= WORK.zero1 
            DATAFILE= in12
		dbms=CSV;
run; 

data one1;
     set zero1;
     if (substance ne 'missing');
     if (pcs ne .);
     if (mcs ne .);
run;


proc sql;
	select * from one1;
quit;

proc genmod data=one1;
	class homeless (ref='0') female (ref='1') substance (ref='alcohol') 
	raceeth (ref='white')/param=ref;
	model i1=homeless female substance raceeth age pcs mcs/dist=p link=log type3;
	title1 'Poisson Model';
run;

ods rtf close;
quit; 
