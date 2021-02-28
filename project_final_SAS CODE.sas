DATA train; 
  set '/home/u50052338/data/abt_sam_beh_train.sas7bdat'; 
RUN; 

%let dataset=train;

DATA valid; 
  set '/home/u50052338/data/abt_sam_beh_valid.sas7bdat'; 
RUN; 

%let dataset=valid;

/*==================================*/
/*===========TASK 1 & 2=============*/
/*==================================*/

/*0. Divide Year and Month from Period Column 
(to know missing data shares in time (by year and by month))*/

proc means data=train n nmiss;
run;

proc means data=valid n nmiss;
run;

/*Train dataset*/
DATA train_new;
set train;
date=input(period, yymmn6.); 
FORMAT date yymmn6.;
year=year(date);
month=month(date); 
run;

DATA train_new;
	set train_new(drop= period);
run;

/*Valid dataset*/
DATA valid_new;
set valid;
date=input(period, yymmn6.); 
FORMAT date yymmn6.;
year=year(date);
month=month(date); 
run;

DATA valid_new;
	set valid_new(drop= period);
run;


/*1. Check status of missing values of Numeric variables*/

/*train summary by variables*/
ods exclude all;  /* suppress display to open ODS destinations */
proc means data=train_new
           nmiss N
           STACKODSOUTPUT;  /* preserve table form of output */
var _numeric_ ;
ods output Summary=sum_1;  /* write statistics to dataset */
run;
ods exclude none;  

proc sql;
create table sum_train as
select Variable, NMiss, N, NMiss/(NMiss+N) as train_pct_missing format=percent7.1
from sum_1
order by train_pct_missing desc, Variable;
quit;

proc sql;
delete from sum_train 
where N < 1323;
quit;

proc print data=sum_train noobs;
title1 'Missing Data Summary';
title2 '(for all numeric variables in Train dataset)';
run;

/*Delete all variables with missing percentage in the range of
97.5%~100% (in train dataset)*/

proc sql;
delete from sum_train 
where N < 1323;
quit;

proc print data=sum_train noobs;
title1 'Missing Data Summary';
title2 '(for all numeric variables in Train dataset with variables having share of missing value less than 97.50%)';
run;


/*valid summary by variables*/
ods exclude all;  /* suppress display to open ODS destinations */
proc means data=valid_new
           nmiss N
           STACKODSOUTPUT;  /* preserve table form of output */
var _numeric_ ;
ods output Summary=sum_2;  /* write statistics to dataset */
run;
ods exclude none;  


proc sql;
create table sum_valid as
select Variable, NMiss, N, NMiss/(NMiss+N) as valid_pct_missing format=percent7.1
from sum_2
order by valid_pct_missing desc, Variable;
quit;


proc print data=sum_valid noobs;
title1 'Missing Data Summary';
title2 '(for all numeric variables in Valid dataset)';
run;

/*Delete all variables with missing percentage in the range of
97.5%~100% (in valid dataset)*/

proc sql;
delete from sum_valid 
where N < 1320;
quit;

proc print data=sum_valid noobs;
title1 'Missing Data Summary';
title2 '(for all numeric variables in Valid dataset with variables having share of missing value less than 97.50%)';
run;


/*Join Train & Valid dataset*/

proc sql;
create table train_valid_join as 
select t.Variable, t.NMiss as trainNMiss, v.NMiss as validNMiss, t.train_pct_missing as train_percent_miss, v.valid_pct_missing as valid_percent_miss
from sum_train t, sum_valid v
where t.Variable = v.Variable;
quit;

proc print data=train_valid_join noobs;
title1 'Missing Data Summary';
title2 '(for all numeric variables in Valid and Train datasets without variables with share of missing values more than 97.5%)';
run;


/* Splitted table by variables with same group of prefix
(act_, ags_, agr_)*/
proc sql;
create table act_variables as
select*
from train_valid_join
where Variable like 'act%';
quit;

proc print data=act_variables noobs;
title1 'Missing Data Summary for Variables start with act_ (describes state at a given point)';
title2 '(for all numeric variables in Valid and Train datasets)';
run;


proc sql;
create table ags_variables as
select*
from train_valid_join
where Variable like 'ags%';
quit;

proc print data=ags_variables noobs;
title1 'Missing Data Summary for Variables start with ags (aggregated information during previous months)';
title2 '(for all numeric variables in Valid and Train datasets)';
run;



proc sql;
create table agr_variables as
select*
from train_valid_join
where Variable like 'agr%';
quit;

proc print data=ags_variables noobs;
title1 'Missing Data Summary for Variables start with agr (aggregated information during previous months)';
title2 '(for all numeric variables in Valid and Train datasets)';
run;


/*example 1 of variable filtering logic*/
/*Compare Missing value shares btw agr_ and ags_ variable
since these 2 variables are similar and we only want one*/
/*Check it out with Task 2 Visualized plot*/


/*example 2 of variable filtering logic*/
/*Variables with Meaning&Insight of missing data pattern*/
/* Splitted table act_Cncr*/
proc sql;
create table act_Cncr as
select*
from act_variables
where Variable like '%Cncr'
order by Variable;
quit;

/*Reorder act_Cncr variables by time(0-36 months ago)*/
data act_Cncr;
set act_Cncr;
month_ago = input(compress(Variable, ,'kd'),best.);
if month_ago=' ' then month_ago=0;
run; 

proc sort data=act_Cncr;
by month_ago; run;

/*Print final report for act_Cncr variables*/
proc print data=act_Cncr noobs;
title1 'Missing Data Summary for act_Cncr ';
title2 '(for all numeric variables in Valid and Train datasets)';
run;


/*Splitted table act_CMax_Days*/
proc sql;
create table act_CMax_Days as
select*
from act_variables
where Variable like '%CMax_Days'
order by Variable;
quit;

/*Reorder act_CMax_Days variables by time(0-36 months ago)*/
data act_CMax_Days;
set act_CMax_Days;
month_ago = input(compress(Variable, ,'kd'),best.);
if month_ago=' ' then month_ago=0;
run; 

proc sort data=act_CMax_Days;
by month_ago; run;

/*Print final report for act_CMax_Days variables*/
proc print data=act_CMax_Days noobs;
title1 'Missing Data Summary for act_CMax_Days ';
title2 '(for all numeric variables in Valid and Train datasets)';
run;

/* Splitted table act_CMin_Days*/
proc sql;
create table act_CMin_Days as
select*
from act_variables
where Variable like '%CMin_Days'
order by Variable;
quit;

/*Reorder act_CMin_Days variables by time(0-36 months ago)*/
data act_CMin_Days;
set act_CMin_Days;
month_ago = input(compress(Variable, ,'kd'),best.);
if month_ago=' ' then month_ago=0;
run;
 
proc sort data=act_CMin_Days;
by month_ago; run;

/* Splitted table act_CMin_Due*/
proc sql;
create table act_CMin_Due as
select*
from act_variables
where Variable like '%CMin_Due'
order by Variable;
quit;

/*Reorder act_CMin_Due variables by time(0-36 months ago)*/
data act_CMin_Due;
set act_CMin_Due;
month_ago = input(compress(Variable, ,'kd'),best.);
if month_ago=' ' then month_ago=0;
run; 
proc sort data=act_CMin_Due;
by month_ago; run;

/* Splitted table act_CMax_Due*/
proc sql;
create table act_CMax_Due as
select*
from act_variables
where Variable like '%CMax_Due'
order by Variable;
quit;

/*Reorder act_CMax_Due variables by time(0-36 months ago)*/
data act_CMax_Due;
set act_CMax_Due;
month_ago = input(compress(Variable, ,'kd'),best.);
if month_ago=' ' then month_ago=0;
run; 
proc sort data=act_CMax_Due;
by month_ago; run;


/*Print final report for act_CMax_Days variables*/
proc print data=act_CMax_Days noobs;
title1 'Missing Data Summary for act_CMax_Days ';
title2 '(for all numeric variables in Valid and Train datasets)';
run;

/*Print final report for act_CMin_Days variables*/

proc print data=act_CMin_Days noobs;
title1 'Missing Data Summary for act_CMin_Days ';
title2 '(for all numeric variables in Valid and Train datasets)';
run;

/*Print final report for act_CMin_Due variables*/

proc print data=act_CMin_Due noobs;
title1 'Missing Data Summary for act_CMin_Due ';
title2 '(for all numeric variables in Valid and Train datasets)';
run;

/*Print final report for act_CMax_Due variables*/

proc print data=act_CMax_Due noobs;
title1 'Missing Data Summary for act_CMax_Due ';
title2 '(for all numeric variables in Valid and Train datasets)';
run;



/*2. Missing value percentage by Year & by Time*/
/*2-1. Missing value percentage by Year*/

ods exclude all;  
proc means data=train_new
           nmiss N
           STACKODSOUTPUT; 
by year;
var _numeric_ ;
ods output Summary=sum_3;  
run;
ods exclude none;  


proc sql;
create table sum_train_3 as
select year, Variable, NMiss/(NMiss+N) as pct_missing format=percent7.1
from sum_3
quit;


proc sort data=sum_train_3;
by Variable; run;

Proc transpose data=sum_train_3 out=newds prefix=pct_missing;
 		BY Variable;
		ID year;
Run; 

DATA newds;
	set newds(drop= _NAME_);
run;

proc print data=newds noobs;
title1 'Missing Data Summary by Year';
title2 '(for all numeric variables in Train dataset)';
run;


/*2-2. Missing value percentage by Month (regardless of year)*/

proc sort data=train_new;
by month; run;

ods exclude all;  
proc means data=train_new
           nmiss N
           STACKODSOUTPUT;
by month;
var _numeric_ ;
ods output Summary=sum_4;
run;
ods exclude none;  


proc sql;
create table sum_train_4 as
select month, Variable, NMiss/(NMiss+N) as pct_missing format=percent7.1
from sum_4
quit;


proc sort data=sum_train_4;
by Variable; 
run;

Proc transpose data=sum_train_4 out=newds1 prefix=pct_missing;
 		BY Variable;
		ID month;
Run; 

DATA newds1;
	set newds1(drop= _NAME_);
run;

proc print data=newds1 noobs;
title1 'Missing Data Summary by Month';
title2 '(for all numeric variables in Train dataset)';
run;


/*3. Check missing values of Character variables
(seems there is no any missing values for chr var)*/
proc freq data = train_new;
  title 'Frequency Count of Character variables';
  tables _char_;
run;

proc freq data = valid_new;
  title 'Frequency Count of Character variables';
  tables _char_;
run;




/*==================================*/
/*===========TASK 3 & 4=============*/
/*==================================*/
/*Visualization part has done via excel*/


/*Train file report (and export result to .xlsx file)*/
ods exclude all;
proc means data=train
N Mean Min Median Q1 Qrange Q3 Max
STACKODSOUTPUT;
var _NUMERIC_;
ods output Summary=QrangeSummary_train;
run;

proc export 
  data=QrangeSummary_train 
  dbms=xlsx 
  outfile="/home/u50052338/data/train_data.xlsx" 
  replace;
run;

/*Valid file report (and export result to .xlsx file)*/
ods exclude all;
proc means data=valid
N Mean Min Median Q1 Qrange Q3 Max
STACKODSOUTPUT;
var _NUMERIC_;
ods output Summary=QrangeSummary_valid;
run;

proc export 
  data=QrangeSummary_valid
  dbms=xlsx 
  outfile="/home/u50052338/data/valid_data.xlsx" 
  replace;
run;



/*==================================*/
/*=============TASK 5===============*/
/*==================================*/

/*Step 0*/
proc means data=train n nmiss;
   var _numeric_;
run;

/* new dataset a*/
data a;
   set train;
   keep
   act_state_12_CMax_Due
act_state_12_CMin_Due
ags12_Skewness_CMin_Due
ags12_Kurtosis_CMax_Due
ags15_Kurtosis_CMin_Due
ags12_Skewness_CMax_Due
ags15_Skewness_CMin_Due
ags18_Kurtosis_CMin_Due
ags15_Kurtosis_CMax_Due
act_state_10_CMax_Days
act_state_10_CMin_Days
ags18_Skewness_CMin_Due
ags21_Kurtosis_CMin_Due
act_state_11_CMax_Due
act_state_11_CMin_Due
ags15_Skewness_CMax_Due
ags24_Kurtosis_CMin_Due
ags18_Kurtosis_CMax_Due
ags21_Skewness_CMin_Due
ags27_Kurtosis_CMin_Due
ags21_Kurtosis_CMax_Due
ags24_Skewness_CMin_Due
ags18_Skewness_CMax_Due
ags30_Kurtosis_CMin_Due
ags24_Kurtosis_CMax_Due
ags27_Skewness_CMin_Due
ags21_Skewness_CMax_Due
ags33_Kurtosis_CMin_Due
ags27_Kurtosis_CMax_Due
ags30_Skewness_CMin_Due
ags24_Skewness_CMax_Due
ags36_Kurtosis_CMin_Due
ags30_Kurtosis_CMax_Due
ags33_Skewness_CMin_Due
ags27_Skewness_CMax_Due
ags33_Kurtosis_CMax_Due
ags36_Skewness_CMin_Due
ags30_Skewness_CMax_Due
ags36_Kurtosis_CMax_Due
act_state_9_CMax_Days
act_state_9_CMin_Days
ags33_Skewness_CMax_Due
ags36_Skewness_CMax_Due
act_state_10_CMax_Due
act_state_10_CMin_Due
ags12_Pctl5_Cncr
ags12_Pctl25_Cncr
ags12_Pctl75_Cncr
ags12_Pctl95_Cncr
ags12_Median_Cncr
ags12_Mean_Cncr
ags12_Max_Cncr
ags12_Min_Cncr
ags12_Sum_Cncr
ags12_Range_Cncr
ags12_Iqr_Cncr
agr3_Skewness_CMax_Days
ags3_Skewness_CMax_Days
agr3_Skewness_CMin_Days
ags3_Skewness_CMin_Days
act_state_8_CMax_Days
act_state_8_CMin_Days
agr9_Pctl5_CMax_Due
agr9_Pctl25_CMax_Due
agr9_Pctl75_CMax_Due
agr9_Pctl95_CMax_Due
agr9_Median_CMax_Due
agr9_Mean_CMax_Due
agr9_Max_CMax_Due
agr9_Min_CMax_Due
agr9_Sum_CMax_Due
agr9_N_CMax_Due
agr9_Nmiss_CMax_Due
agr9_Range_CMax_Due
agr9_Iqr_CMax_Due
agr9_Std_CMax_Due
agr9_Pctl5_CMin_Due
agr9_Pctl25_CMin_Due
agr9_Pctl75_CMin_Due
agr9_Pctl95_CMin_Due
agr9_Median_CMin_Due
agr9_Mean_CMin_Due
agr9_Max_CMin_Due
agr9_Min_CMin_Due
agr9_Sum_CMin_Due
agr9_N_CMin_Due
agr9_Nmiss_CMin_Due
agr9_Range_CMin_Due
agr9_Iqr_CMin_Due
agr9_Std_CMin_Due
act_state_9_CMax_Due
act_state_9_CMin_Due
agr3_Pctl5_CMax_Days
agr3_Pctl25_CMax_Days
agr3_Pctl75_CMax_Days
agr3_Pctl95_CMax_Days
agr3_Median_CMax_Days
agr3_Mean_CMax_Days
agr3_Max_CMax_Days
agr3_Min_CMax_Days
agr3_Sum_CMax_Days
agr3_N_CMax_Days
agr3_Nmiss_CMax_Days
agr3_Range_CMax_Days
agr3_Iqr_CMax_Days
agr3_Std_CMax_Days
agr3_Pctl5_CMin_Days
agr3_Pctl25_CMin_Days
agr3_Pctl75_CMin_Days
agr3_Pctl95_CMin_Days
agr3_Median_CMin_Days
agr3_Mean_CMin_Days
agr3_Max_CMin_Days
agr3_Min_CMin_Days
agr3_Sum_CMin_Days
agr3_N_CMin_Days
agr3_Nmiss_CMin_Days
agr3_Range_CMin_Days
agr3_Iqr_CMin_Days
agr3_Std_CMin_Days
act_state_7_CMax_Days
act_state_7_CMin_Days
act_state_8_CMax_Due
act_state_8_CMin_Due
act_state_6_CMax_Days
act_state_6_CMin_Days
ags15_Pctl5_Cncr
ags15_Pctl25_Cncr
ags15_Pctl75_Cncr
ags15_Pctl95_Cncr
ags15_Median_Cncr
ags15_Mean_Cncr
ags15_Max_Cncr
ags15_Min_Cncr
ags15_Sum_Cncr
ags15_Range_Cncr
ags15_Iqr_Cncr
act_state_7_CMax_Due
act_state_7_CMin_Due
act_state_5_CMax_Days
act_state_5_CMin_Days
agr6_Pctl5_CMax_Due
agr6_Pctl25_CMax_Due
agr6_Pctl75_CMax_Due
agr6_Pctl95_CMax_Due
agr6_Median_CMax_Due
agr6_Mean_CMax_Due
agr6_Max_CMax_Due
agr6_Min_CMax_Due
agr6_Sum_CMax_Due
agr6_N_CMax_Due
agr6_Nmiss_CMax_Due
agr6_Range_CMax_Due
agr6_Iqr_CMax_Due
agr6_Std_CMax_Due
agr6_Pctl5_CMin_Due
agr6_Pctl25_CMin_Due
agr6_Pctl75_CMin_Due
agr6_Pctl95_CMin_Due
agr6_Median_CMin_Due
agr6_Mean_CMin_Due
agr6_Max_CMin_Due
agr6_Min_CMin_Due
agr6_Sum_CMin_Due
agr6_N_CMin_Due
agr6_Nmiss_CMin_Due
agr6_Range_CMin_Due
agr6_Iqr_CMin_Due
agr6_Std_CMin_Due
act_state_6_CMax_Due
act_state_6_CMin_Due
act_state_4_CMax_Days
act_state_4_CMin_Days
ags6_Kurtosis_CMax_Days
ags6_Kurtosis_CMin_Days
ags18_Pctl5_Cncr
ags18_Pctl25_Cncr
ags18_Pctl75_Cncr
ags18_Pctl95_Cncr
ags18_Median_Cncr
ags18_Mean_Cncr
ags18_Max_Cncr
ags18_Min_Cncr
ags18_Sum_Cncr
ags18_Range_Cncr
ags18_Iqr_Cncr
act_state_5_CMax_Due
act_state_5_CMin_Due
act_state_3_CMax_Days
act_state_3_CMin_Days
act_state_2_CMax_Days
act_state_2_CMin_Days
ags9_Kurtosis_CMax_Days
ags9_Kurtosis_CMin_Days
ags12_Kurtosis_CMax_Days
ags12_Kurtosis_CMin_Days
ags15_Kurtosis_CMax_Days
ags15_Kurtosis_CMin_Days
ags18_Kurtosis_CMax_Days
ags18_Kurtosis_CMin_Days
ags21_Kurtosis_CMax_Days
ags21_Kurtosis_CMin_Days
ags24_Kurtosis_CMax_Days
ags24_Kurtosis_CMin_Days
ags27_Kurtosis_CMax_Days
ags27_Kurtosis_CMin_Days
ags30_Kurtosis_CMax_Days
ags30_Kurtosis_CMin_Days
ags33_Kurtosis_CMax_Days
ags33_Kurtosis_CMin_Days
act_state_4_CMax_Due
act_state_4_CMin_Due
ags36_Kurtosis_CMax_Days
ags36_Kurtosis_CMin_Days
default_cus6
act_state_1_CMax_Days
act_CMax_Days
act_state_1_CMin_Days
act_CMin_Days
default_cus9
default_cus12
ags6_Skewness_CMax_Days
ags3_Std_CMax_Days
ags3_Std_CMin_Days
ags6_Skewness_CMin_Days
ags9_Skewness_CMax_Days
ags9_Skewness_CMin_Days
ags12_Skewness_CMax_Days
ags12_Skewness_CMin_Days
ags15_Skewness_CMax_Days
ags15_Skewness_CMin_Days
ags18_Skewness_CMax_Days
ags18_Skewness_CMin_Days
ags21_Skewness_CMax_Days
ags21_Skewness_CMin_Days
ags24_Skewness_CMax_Days
ags24_Skewness_CMin_Days
ags27_Skewness_CMax_Days
ags27_Skewness_CMin_Days
ags30_Skewness_CMax_Days
ags30_Skewness_CMin_Days
ags33_Skewness_CMax_Days
ags33_Skewness_CMin_Days
ags21_Pctl5_Cncr
ags21_Pctl25_Cncr
ags21_Pctl75_Cncr
ags21_Pctl95_Cncr
ags21_Median_Cncr
ags21_Mean_Cncr
ags21_Max_Cncr
ags21_Min_Cncr
ags21_Sum_Cncr
ags21_Range_Cncr
ags21_Iqr_Cncr
ags36_Skewness_CMax_Days
ags36_Skewness_CMin_Days
agr3_Pctl5_CMax_Due
agr3_Pctl25_CMax_Due
agr3_Pctl75_CMax_Due
agr3_Pctl95_CMax_Due
agr3_Median_CMax_Due
agr3_Mean_CMax_Due
agr3_Max_CMax_Due
agr3_Min_CMax_Due
agr3_Sum_CMax_Due
agr3_N_CMax_Due
agr3_Nmiss_CMax_Due
agr3_Range_CMax_Due
agr3_Iqr_CMax_Due
agr3_Std_CMax_Due
agr3_Pctl5_CMin_Due
agr3_Pctl25_CMin_Due
agr3_Pctl75_CMin_Due
agr3_Pctl95_CMin_Due
agr3_Median_CMin_Due
agr3_Mean_CMin_Due
agr3_Max_CMin_Due
agr3_Min_CMin_Due
agr3_Sum_CMin_Due
agr3_N_CMin_Due
agr3_Nmiss_CMin_Due
agr3_Range_CMin_Due
agr3_Iqr_CMin_Due
agr3_Std_CMin_Due
act_state_3_CMax_Due
act_state_3_CMin_Due
default_cus3
ags6_Std_CMax_Days
ags6_Std_CMin_Days
ags9_Std_CMax_Days
ags9_Std_CMin_Days
ags12_Std_CMax_Days
ags12_Std_CMin_Days
ags15_Std_CMax_Days
ags15_Std_CMin_Days
ags18_Std_CMax_Days
ags18_Std_CMin_Days
ags21_Std_CMax_Days
ags21_Std_CMin_Days
ags24_Std_CMax_Days
ags24_Std_CMin_Days
ags27_Std_CMax_Days
ags27_Std_CMin_Days
ags30_Std_CMax_Days
ags30_Std_CMin_Days
ags33_Std_CMax_Days
ags33_Std_CMin_Days
act_state_2_CMax_Due
act_state_2_CMin_Due
ags3_Std_CMax_Due
ags3_Std_CMin_Due
ags36_Std_CMax_Days
ags36_Std_CMin_Days
ags6_Std_CMax_Due
ags6_Std_CMin_Due
ags9_Std_CMax_Due
ags9_Std_CMin_Due
ags12_Std_CMax_Due
ags12_Std_CMin_Due
ags15_Std_CMax_Due
ags15_Std_CMin_Due
ags18_Std_CMax_Due
ags18_Std_CMin_Due
ags21_Std_CMax_Due
ags21_Std_CMin_Due
ags24_Std_CMax_Due
ags24_Std_CMin_Due
ags27_Std_CMax_Due
ags27_Std_CMin_Due
ags30_Std_CMax_Due
ags30_Std_CMin_Due
ags33_Std_CMax_Due
ags33_Std_CMin_Due
ags36_Std_CMax_Due
ags36_Std_CMin_Due
ags24_Pctl5_Cncr
ags24_Pctl25_Cncr
ags24_Pctl75_Cncr
ags24_Pctl95_Cncr
ags24_Median_Cncr
ags24_Mean_Cncr
ags24_Max_Cncr
ags24_Min_Cncr
ags24_Sum_Cncr
ags24_Range_Cncr
ags24_Iqr_Cncr
ags3_Pctl5_CMax_Days
ags3_Pctl25_CMax_Days
ags3_Pctl75_CMax_Days
ags3_Pctl95_CMax_Days
ags3_Median_CMax_Days
ags3_Mean_CMax_Days
ags3_Max_CMax_Days
ags3_Min_CMax_Days
ags3_Sum_CMax_Days
ags3_Range_CMax_Days
ags3_Iqr_CMax_Days
ags3_Pctl5_CMin_Days
ags3_Pctl25_CMin_Days
ags3_Pctl75_CMin_Days
ags3_Pctl95_CMin_Days
ags3_Median_CMin_Days
ags3_Mean_CMin_Days
ags3_Max_CMin_Days
ags3_Min_CMin_Days
ags3_Sum_CMin_Days
ags3_Range_CMin_Days
ags3_Iqr_CMin_Days
act_age
app_income
app_number_of_children
app_spendings
act_cus_seniority
act_cus_n_loans_hist
act_cus_n_statC
act_cus_n_statB
act_cus_n_loans_act
act_cus_pins
act_cus_utl
act_cus_dueutl
act_cus_cc
act_state_1_CMax_Due
act_CMax_Due
act_state_1_CMin_Due
act_CMin_Due
ags3_N_CMax_Days
ags3_Nmiss_CMax_Days
ags3_Pctl5_CMax_Due
ags3_Pctl25_CMax_Due
ags3_Pctl75_CMax_Due
ags3_Pctl95_CMax_Due
ags3_Median_CMax_Due
ags3_Mean_CMax_Due
ags3_Max_CMax_Due
ags3_Min_CMax_Due
ags3_Sum_CMax_Due
ags3_N_CMax_Due
ags3_Nmiss_CMax_Due
ags3_Range_CMax_Due
ags3_Iqr_CMax_Due
ags3_N_CMin_Days
ags3_Nmiss_CMin_Days
ags3_Pctl5_CMin_Due
ags3_Pctl25_CMin_Due
ags3_Pctl75_CMin_Due
ags3_Pctl95_CMin_Due
ags3_Median_CMin_Due
ags3_Mean_CMin_Due
ags3_Max_CMin_Due
ags3_Min_CMin_Due
ags3_Sum_CMin_Due
ags3_N_CMin_Due
ags3_Nmiss_CMin_Due
ags3_Range_CMin_Due
ags3_Iqr_CMin_Due
ags3_N_Cncr
ags3_Nmiss_Cncr
ags6_Pctl5_CMax_Days
ags6_Pctl25_CMax_Days
ags6_Pctl75_CMax_Days
ags6_Pctl95_CMax_Days
ags6_Median_CMax_Days
ags6_Mean_CMax_Days
ags6_Max_CMax_Days
ags6_Min_CMax_Days
ags6_Sum_CMax_Days
ags6_N_CMax_Days
ags6_Nmiss_CMax_Days
ags6_Range_CMax_Days
ags6_Iqr_CMax_Days
ags6_Pctl5_CMax_Due
ags6_Pctl25_CMax_Due
ags6_Pctl75_CMax_Due
ags6_Pctl95_CMax_Due
ags6_Median_CMax_Due
ags6_Mean_CMax_Due
ags6_Max_CMax_Due
ags6_Min_CMax_Due
ags6_Sum_CMax_Due
ags6_N_CMax_Due
ags6_Nmiss_CMax_Due
ags6_Range_CMax_Due
ags6_Iqr_CMax_Due
ags6_Pctl5_CMin_Days
ags6_Pctl25_CMin_Days
ags6_Pctl75_CMin_Days
ags6_Pctl95_CMin_Days
ags6_Median_CMin_Days
ags6_Mean_CMin_Days
ags6_Max_CMin_Days
ags6_Min_CMin_Days
ags6_Sum_CMin_Days
ags6_N_CMin_Days
ags6_Nmiss_CMin_Days
ags6_Range_CMin_Days
ags6_Iqr_CMin_Days
ags6_Pctl5_CMin_Due
ags6_Pctl25_CMin_Due
ags6_Pctl75_CMin_Due
ags6_Pctl95_CMin_Due
ags6_Median_CMin_Due
ags6_Mean_CMin_Due
ags6_Max_CMin_Due
ags6_Min_CMin_Due
ags6_Sum_CMin_Due
ags6_N_CMin_Due
ags6_Nmiss_CMin_Due
ags6_Range_CMin_Due
ags6_Iqr_CMin_Due
ags6_N_Cncr
ags6_Nmiss_Cncr
ags9_Pctl5_CMax_Days
ags9_Pctl25_CMax_Days
ags9_Pctl75_CMax_Days
ags9_Pctl95_CMax_Days
ags9_Median_CMax_Days
ags9_Mean_CMax_Days
ags9_Max_CMax_Days
ags9_Min_CMax_Days
ags9_Sum_CMax_Days
ags9_N_CMax_Days
ags9_Nmiss_CMax_Days
ags9_Range_CMax_Days
ags9_Iqr_CMax_Days
ags9_Pctl5_CMax_Due
ags9_Pctl25_CMax_Due
ags9_Pctl75_CMax_Due
ags9_Pctl95_CMax_Due
ags9_Median_CMax_Due
ags9_Mean_CMax_Due
ags9_Max_CMax_Due
ags9_Min_CMax_Due
ags9_Sum_CMax_Due
ags9_N_CMax_Due
ags9_Nmiss_CMax_Due
ags9_Range_CMax_Due
ags9_Iqr_CMax_Due
ags9_Pctl5_CMin_Days
ags9_Pctl25_CMin_Days
ags9_Pctl75_CMin_Days
ags9_Pctl95_CMin_Days
ags9_Median_CMin_Days
ags9_Mean_CMin_Days
ags9_Max_CMin_Days
ags9_Min_CMin_Days
ags9_Sum_CMin_Days
ags9_N_CMin_Days
ags9_Nmiss_CMin_Days
ags9_Range_CMin_Days
ags9_Iqr_CMin_Days
ags9_Pctl5_CMin_Due
ags9_Pctl25_CMin_Due
ags9_Pctl75_CMin_Due
ags9_Pctl95_CMin_Due
ags9_Median_CMin_Due
ags9_Mean_CMin_Due
ags9_Max_CMin_Due
ags9_Min_CMin_Due
ags9_Sum_CMin_Due
ags9_N_CMin_Due
ags9_Nmiss_CMin_Due
ags9_Range_CMin_Due
ags9_Iqr_CMin_Due
ags9_N_Cncr
ags9_Nmiss_Cncr
ags12_Pctl5_CMax_Days
ags12_Pctl25_CMax_Days
ags12_Pctl75_CMax_Days
ags12_Pctl95_CMax_Days
ags12_Median_CMax_Days
ags12_Mean_CMax_Days
ags12_Max_CMax_Days
ags12_Min_CMax_Days
ags12_Sum_CMax_Days
ags12_N_CMax_Days
ags12_Nmiss_CMax_Days
ags12_Range_CMax_Days
ags12_Iqr_CMax_Days
ags12_Pctl5_CMax_Due
ags12_Pctl25_CMax_Due
ags12_Pctl75_CMax_Due
ags12_Pctl95_CMax_Due
ags12_Median_CMax_Due
ags12_Mean_CMax_Due
ags12_Max_CMax_Due
ags12_Min_CMax_Due
ags12_Sum_CMax_Due
ags12_N_CMax_Due
ags12_Nmiss_CMax_Due
ags12_Range_CMax_Due
ags12_Iqr_CMax_Due
ags12_Pctl5_CMin_Days
ags12_Pctl25_CMin_Days
ags12_Pctl75_CMin_Days
ags12_Pctl95_CMin_Days
ags12_Median_CMin_Days
ags12_Mean_CMin_Days
ags12_Max_CMin_Days
ags12_Min_CMin_Days
ags12_Sum_CMin_Days
ags12_N_CMin_Days
ags12_Nmiss_CMin_Days
ags12_Range_CMin_Days
ags12_Iqr_CMin_Days
ags12_Pctl5_CMin_Due
ags12_Pctl25_CMin_Due
ags12_Pctl75_CMin_Due
ags12_Pctl95_CMin_Due
ags12_Median_CMin_Due
ags12_Mean_CMin_Due
ags12_Max_CMin_Due
ags12_Min_CMin_Due
ags12_Sum_CMin_Due
ags12_N_CMin_Due
ags12_Nmiss_CMin_Due
ags12_Range_CMin_Due
ags12_Iqr_CMin_Due
ags12_N_Cncr
ags12_Nmiss_Cncr
ags15_Pctl5_CMax_Days
ags15_Pctl25_CMax_Days
ags15_Pctl75_CMax_Days
ags15_Pctl95_CMax_Days
ags15_Median_CMax_Days
ags15_Mean_CMax_Days
ags15_Max_CMax_Days
ags15_Min_CMax_Days
ags15_Sum_CMax_Days
ags15_N_CMax_Days
ags15_Nmiss_CMax_Days
ags15_Range_CMax_Days
ags15_Iqr_CMax_Days
ags15_Pctl5_CMax_Due
ags15_Pctl25_CMax_Due
ags15_Pctl75_CMax_Due
ags15_Pctl95_CMax_Due
ags15_Median_CMax_Due
ags15_Mean_CMax_Due
ags15_Max_CMax_Due
ags15_Min_CMax_Due
ags15_Sum_CMax_Due
ags15_N_CMax_Due
ags15_Nmiss_CMax_Due
ags15_Range_CMax_Due
ags15_Iqr_CMax_Due
ags15_Pctl5_CMin_Days
ags15_Pctl25_CMin_Days
ags15_Pctl75_CMin_Days
ags15_Pctl95_CMin_Days
ags15_Median_CMin_Days
ags15_Mean_CMin_Days
ags15_Max_CMin_Days
ags15_Min_CMin_Days
ags15_Sum_CMin_Days
ags15_N_CMin_Days
ags15_Nmiss_CMin_Days
ags15_Range_CMin_Days
ags15_Iqr_CMin_Days
ags15_Pctl5_CMin_Due
ags15_Pctl25_CMin_Due
ags15_Pctl75_CMin_Due
ags15_Pctl95_CMin_Due
ags15_Median_CMin_Due
ags15_Mean_CMin_Due
ags15_Max_CMin_Due
ags15_Min_CMin_Due
ags15_Sum_CMin_Due
ags15_N_CMin_Due
ags15_Nmiss_CMin_Due
ags15_Range_CMin_Due
ags15_Iqr_CMin_Due
ags15_N_Cncr
ags15_Nmiss_Cncr
ags18_Pctl5_CMax_Days
ags18_Pctl25_CMax_Days
ags18_Pctl75_CMax_Days
ags18_Pctl95_CMax_Days
ags18_Median_CMax_Days
ags18_Mean_CMax_Days
ags18_Max_CMax_Days
ags18_Min_CMax_Days
ags18_Sum_CMax_Days
ags18_N_CMax_Days
ags18_Nmiss_CMax_Days
ags18_Range_CMax_Days
ags18_Iqr_CMax_Days
ags18_Pctl5_CMax_Due
ags18_Pctl25_CMax_Due
ags18_Pctl75_CMax_Due
ags18_Pctl95_CMax_Due
ags18_Median_CMax_Due
ags18_Mean_CMax_Due
ags18_Max_CMax_Due
ags18_Min_CMax_Due
ags18_Sum_CMax_Due
ags18_N_CMax_Due
ags18_Nmiss_CMax_Due
ags18_Range_CMax_Due
ags18_Iqr_CMax_Due
ags18_Pctl5_CMin_Days
ags18_Pctl25_CMin_Days
ags18_Pctl75_CMin_Days
ags18_Pctl95_CMin_Days
ags18_Median_CMin_Days
ags18_Mean_CMin_Days
ags18_Max_CMin_Days
ags18_Min_CMin_Days
ags18_Sum_CMin_Days
ags18_N_CMin_Days
ags18_Nmiss_CMin_Days
ags18_Range_CMin_Days
ags18_Iqr_CMin_Days
ags18_Pctl5_CMin_Due
ags18_Pctl25_CMin_Due
ags18_Pctl75_CMin_Due
ags18_Pctl95_CMin_Due
ags18_Median_CMin_Due
ags18_Mean_CMin_Due
ags18_Max_CMin_Due
ags18_Min_CMin_Due
ags18_Sum_CMin_Due
ags18_N_CMin_Due
ags18_Nmiss_CMin_Due
ags18_Range_CMin_Due
ags18_Iqr_CMin_Due
ags18_N_Cncr
ags18_Nmiss_Cncr
ags21_Pctl5_CMax_Days
ags21_Pctl25_CMax_Days
ags21_Pctl75_CMax_Days
ags21_Pctl95_CMax_Days
ags21_Median_CMax_Days
ags21_Mean_CMax_Days
ags21_Max_CMax_Days
ags21_Min_CMax_Days
ags21_Sum_CMax_Days
ags21_N_CMax_Days
ags21_Nmiss_CMax_Days
ags21_Range_CMax_Days
ags21_Iqr_CMax_Days
ags21_Pctl5_CMax_Due
ags21_Pctl25_CMax_Due
ags21_Pctl75_CMax_Due
ags21_Pctl95_CMax_Due
ags21_Median_CMax_Due
ags21_Mean_CMax_Due
ags21_Max_CMax_Due
ags21_Min_CMax_Due
ags21_Sum_CMax_Due
ags21_N_CMax_Due
ags21_Nmiss_CMax_Due
ags21_Range_CMax_Due
ags21_Iqr_CMax_Due
ags21_Pctl5_CMin_Days
ags21_Pctl25_CMin_Days
ags21_Pctl75_CMin_Days
ags21_Pctl95_CMin_Days
ags21_Median_CMin_Days
ags21_Mean_CMin_Days
ags21_Max_CMin_Days
ags21_Min_CMin_Days
ags21_Sum_CMin_Days
ags21_N_CMin_Days
ags21_Nmiss_CMin_Days
ags21_Range_CMin_Days
ags21_Iqr_CMin_Days
ags21_Pctl5_CMin_Due
ags21_Pctl25_CMin_Due
ags21_Pctl75_CMin_Due
ags21_Pctl95_CMin_Due
ags21_Median_CMin_Due
ags21_Mean_CMin_Due
ags21_Max_CMin_Due
ags21_Min_CMin_Due
ags21_Sum_CMin_Due
ags21_N_CMin_Due
ags21_Nmiss_CMin_Due
ags21_Range_CMin_Due
ags21_Iqr_CMin_Due
ags21_N_Cncr
ags21_Nmiss_Cncr
ags24_Pctl5_CMax_Days
ags24_Pctl25_CMax_Days
ags24_Pctl75_CMax_Days
ags24_Pctl95_CMax_Days
ags24_Median_CMax_Days
ags24_Mean_CMax_Days
ags24_Max_CMax_Days
ags24_Min_CMax_Days
ags24_Sum_CMax_Days
ags24_N_CMax_Days
ags24_Nmiss_CMax_Days
ags24_Range_CMax_Days
ags24_Iqr_CMax_Days
ags24_Pctl5_CMax_Due
ags24_Pctl25_CMax_Due
ags24_Pctl75_CMax_Due
ags24_Pctl95_CMax_Due
ags24_Median_CMax_Due
ags24_Mean_CMax_Due
ags24_Max_CMax_Due
ags24_Min_CMax_Due
ags24_Sum_CMax_Due
ags24_N_CMax_Due
ags24_Nmiss_CMax_Due
ags24_Range_CMax_Due
ags24_Iqr_CMax_Due
ags24_Pctl5_CMin_Days
ags24_Pctl25_CMin_Days
ags24_Pctl75_CMin_Days
ags24_Pctl95_CMin_Days
ags24_Median_CMin_Days
ags24_Mean_CMin_Days
ags24_Max_CMin_Days
ags24_Min_CMin_Days
ags24_Sum_CMin_Days
ags24_N_CMin_Days
ags24_Nmiss_CMin_Days
ags24_Range_CMin_Days
ags24_Iqr_CMin_Days
ags24_Pctl5_CMin_Due
ags24_Pctl25_CMin_Due
ags24_Pctl75_CMin_Due
ags24_Pctl95_CMin_Due
ags24_Median_CMin_Due
ags24_Mean_CMin_Due
ags24_Max_CMin_Due
ags24_Min_CMin_Due
ags24_Sum_CMin_Due
ags24_N_CMin_Due
ags24_Nmiss_CMin_Due
ags24_Range_CMin_Due
ags24_Iqr_CMin_Due
ags24_N_Cncr
ags24_Nmiss_Cncr
ags27_Pctl5_CMax_Days
ags27_Pctl25_CMax_Days
ags27_Pctl75_CMax_Days
ags27_Pctl95_CMax_Days
ags27_Median_CMax_Days
ags27_Mean_CMax_Days
ags27_Max_CMax_Days
ags27_Min_CMax_Days
ags27_Sum_CMax_Days
ags27_N_CMax_Days
ags27_Nmiss_CMax_Days
ags27_Range_CMax_Days
ags27_Iqr_CMax_Days
ags27_Pctl5_CMax_Due
ags27_Pctl25_CMax_Due
ags27_Pctl75_CMax_Due
ags27_Pctl95_CMax_Due
ags27_Median_CMax_Due
ags27_Mean_CMax_Due
ags27_Max_CMax_Due
ags27_Min_CMax_Due
ags27_Sum_CMax_Due
ags27_N_CMax_Due
ags27_Nmiss_CMax_Due
ags27_Range_CMax_Due
ags27_Iqr_CMax_Due
ags27_Pctl5_CMin_Days
ags27_Pctl25_CMin_Days
ags27_Pctl75_CMin_Days
ags27_Pctl95_CMin_Days
ags27_Median_CMin_Days
ags27_Mean_CMin_Days
ags27_Max_CMin_Days
ags27_Min_CMin_Days
ags27_Sum_CMin_Days
ags27_N_CMin_Days
ags27_Nmiss_CMin_Days
ags27_Range_CMin_Days
ags27_Iqr_CMin_Days
ags27_Pctl5_CMin_Due
ags27_Pctl25_CMin_Due
ags27_Pctl75_CMin_Due
ags27_Pctl95_CMin_Due
ags27_Median_CMin_Due
ags27_Mean_CMin_Due
ags27_Max_CMin_Due
ags27_Min_CMin_Due
ags27_Sum_CMin_Due
ags27_N_CMin_Due
ags27_Nmiss_CMin_Due
ags27_Range_CMin_Due
ags27_Iqr_CMin_Due
ags27_Pctl5_Cncr
ags27_Pctl25_Cncr
ags27_Pctl75_Cncr
ags27_Pctl95_Cncr
ags27_Median_Cncr
ags27_Mean_Cncr
ags27_Max_Cncr
ags27_Min_Cncr
ags27_Sum_Cncr
ags27_N_Cncr
ags27_Nmiss_Cncr
ags27_Range_Cncr
ags27_Iqr_Cncr
ags30_Pctl5_CMax_Days
ags30_Pctl25_CMax_Days
ags30_Pctl75_CMax_Days
ags30_Pctl95_CMax_Days
ags30_Median_CMax_Days
ags30_Mean_CMax_Days
ags30_Max_CMax_Days
ags30_Min_CMax_Days
ags30_Sum_CMax_Days
ags30_N_CMax_Days
ags30_Nmiss_CMax_Days
ags30_Range_CMax_Days
ags30_Iqr_CMax_Days
ags30_Pctl5_CMax_Due
ags30_Pctl25_CMax_Due
ags30_Pctl75_CMax_Due
ags30_Pctl95_CMax_Due
ags30_Median_CMax_Due
ags30_Mean_CMax_Due
ags30_Max_CMax_Due
ags30_Min_CMax_Due
ags30_Sum_CMax_Due
ags30_N_CMax_Due
ags30_Nmiss_CMax_Due
ags30_Range_CMax_Due
ags30_Iqr_CMax_Due
ags30_Pctl5_CMin_Days
ags30_Pctl25_CMin_Days
ags30_Pctl75_CMin_Days
ags30_Pctl95_CMin_Days
ags30_Median_CMin_Days
ags30_Mean_CMin_Days
ags30_Max_CMin_Days
ags30_Min_CMin_Days
ags30_Sum_CMin_Days
ags30_N_CMin_Days
ags30_Nmiss_CMin_Days
ags30_Range_CMin_Days
ags30_Iqr_CMin_Days
ags30_Pctl5_CMin_Due
ags30_Pctl25_CMin_Due
ags30_Pctl75_CMin_Due
ags30_Pctl95_CMin_Due
ags30_Median_CMin_Due
ags30_Mean_CMin_Due
ags30_Max_CMin_Due
ags30_Min_CMin_Due
ags30_Sum_CMin_Due
ags30_N_CMin_Due
ags30_Nmiss_CMin_Due
ags30_Range_CMin_Due
ags30_Iqr_CMin_Due
ags30_Pctl5_Cncr
ags30_Pctl25_Cncr
ags30_Pctl75_Cncr
ags30_Pctl95_Cncr
ags30_Median_Cncr
ags30_Mean_Cncr
ags30_Max_Cncr
ags30_Min_Cncr
ags30_Sum_Cncr
ags30_N_Cncr
ags30_Nmiss_Cncr
ags30_Range_Cncr
ags30_Iqr_Cncr
ags33_Pctl5_CMax_Days
ags33_Pctl25_CMax_Days
ags33_Pctl75_CMax_Days
ags33_Pctl95_CMax_Days
ags33_Median_CMax_Days
ags33_Mean_CMax_Days
ags33_Max_CMax_Days
ags33_Min_CMax_Days
ags33_Sum_CMax_Days
ags33_N_CMax_Days
ags33_Nmiss_CMax_Days
ags33_Range_CMax_Days
ags33_Iqr_CMax_Days
ags33_Pctl5_CMax_Due
ags33_Pctl25_CMax_Due
ags33_Pctl75_CMax_Due
ags33_Pctl95_CMax_Due
ags33_Median_CMax_Due
ags33_Mean_CMax_Due
ags33_Max_CMax_Due
ags33_Min_CMax_Due
ags33_Sum_CMax_Due
ags33_N_CMax_Due
ags33_Nmiss_CMax_Due
ags33_Range_CMax_Due
ags33_Iqr_CMax_Due
ags33_Pctl5_CMin_Days
ags33_Pctl25_CMin_Days
ags33_Pctl75_CMin_Days
ags33_Pctl95_CMin_Days
ags33_Median_CMin_Days
ags33_Mean_CMin_Days
ags33_Max_CMin_Days
ags33_Min_CMin_Days
ags33_Sum_CMin_Days
ags33_N_CMin_Days
ags33_Nmiss_CMin_Days
ags33_Range_CMin_Days
ags33_Iqr_CMin_Days
ags33_Pctl5_CMin_Due
ags33_Pctl25_CMin_Due
ags33_Pctl75_CMin_Due
ags33_Pctl95_CMin_Due
ags33_Median_CMin_Due
ags33_Mean_CMin_Due
ags33_Max_CMin_Due
ags33_Min_CMin_Due
ags33_Sum_CMin_Due
ags33_N_CMin_Due
ags33_Nmiss_CMin_Due
ags33_Range_CMin_Due
ags33_Iqr_CMin_Due
ags33_Pctl5_Cncr
ags33_Pctl25_Cncr
ags33_Pctl75_Cncr
ags33_Pctl95_Cncr
ags33_Median_Cncr
ags33_Mean_Cncr
ags33_Max_Cncr
ags33_Min_Cncr
ags33_Sum_Cncr
ags33_N_Cncr
ags33_Nmiss_Cncr
ags33_Range_Cncr
ags33_Iqr_Cncr
ags36_Pctl5_CMax_Days
ags36_Pctl25_CMax_Days
ags36_Pctl75_CMax_Days
ags36_Pctl95_CMax_Days
ags36_Median_CMax_Days
ags36_Mean_CMax_Days
ags36_Max_CMax_Days
ags36_Min_CMax_Days
ags36_Sum_CMax_Days
ags36_N_CMax_Days
ags36_Nmiss_CMax_Days
ags36_Range_CMax_Days
ags36_Iqr_CMax_Days
ags36_Pctl5_CMax_Due
ags36_Pctl25_CMax_Due
ags36_Pctl75_CMax_Due
ags36_Pctl95_CMax_Due
ags36_Median_CMax_Due
ags36_Mean_CMax_Due
ags36_Max_CMax_Due
ags36_Min_CMax_Due
ags36_Sum_CMax_Due
ags36_N_CMax_Due
ags36_Nmiss_CMax_Due
ags36_Range_CMax_Due
ags36_Iqr_CMax_Due
ags36_Pctl5_CMin_Days
ags36_Pctl25_CMin_Days
ags36_Pctl75_CMin_Days
ags36_Pctl95_CMin_Days
ags36_Median_CMin_Days
ags36_Mean_CMin_Days
ags36_Max_CMin_Days
ags36_Min_CMin_Days
ags36_Sum_CMin_Days
ags36_N_CMin_Days
ags36_Nmiss_CMin_Days
ags36_Range_CMin_Days
ags36_Iqr_CMin_Days
ags36_Pctl5_CMin_Due
ags36_Pctl25_CMin_Due
ags36_Pctl75_CMin_Due
ags36_Pctl95_CMin_Due
ags36_Median_CMin_Due
ags36_Mean_CMin_Due
ags36_Max_CMin_Due
ags36_Min_CMin_Due
ags36_Sum_CMin_Due
ags36_N_CMin_Due
ags36_Nmiss_CMin_Due
ags36_Range_CMin_Due
ags36_Iqr_CMin_Due
ags36_Pctl5_Cncr
ags36_Pctl25_Cncr
ags36_Pctl75_Cncr
ags36_Pctl95_Cncr
ags36_Median_Cncr
ags36_Mean_Cncr
ags36_Max_Cncr
ags36_Min_Cncr
ags36_Sum_Cncr
ags36_N_Cncr
ags36_Nmiss_Cncr
ags36_Range_Cncr
ags36_Iqr_Cncr
ags3_n_cus_arrears_days
ags3_n_cus_good_days
ags3_n_cus_arrears
act3_n_cind_arrears
act3_Cncr_taken
ags3_Csev_work
act3_Ciev_work
ags3_Csev_health
act3_Ciev_health
ags3_Csev_family
act3_Ciev_family
ags3_Csev_home
act3_Ciev_home
ags3_Csev_all
act3_Ciev_all
ags6_n_cus_arrears_days
ags6_n_cus_good_days
ags6_n_cus_arrears
act6_n_cind_arrears
act6_Cncr_taken
ags6_Csev_work
act6_Ciev_work
ags6_Csev_health
act6_Ciev_health
ags6_Csev_family
act6_Ciev_family
ags6_Csev_home
act6_Ciev_home
ags6_Csev_all
act6_Ciev_all
ags9_n_cus_arrears_days
ags9_n_cus_good_days
ags9_n_cus_arrears
act9_n_cind_arrears
act9_Cncr_taken
ags9_Csev_work
act9_Ciev_work
ags9_Csev_health
act9_Ciev_health
ags9_Csev_family
act9_Ciev_family
ags9_Csev_home
act9_Ciev_home
ags9_Csev_all
act9_Ciev_all
ags12_n_cus_arrears_days
ags12_n_cus_good_days
ags12_n_cus_arrears
act12_n_cind_arrears
act12_Cncr_taken
ags12_Csev_work
act12_Ciev_work
ags12_Csev_health
act12_Ciev_health
ags12_Csev_family
act12_Ciev_family
ags12_Csev_home
act12_Ciev_home
ags12_Csev_all
act12_Ciev_all
ags15_n_cus_arrears_days
ags15_n_cus_good_days
ags15_n_cus_arrears
act15_n_cind_arrears
act15_Cncr_taken
ags15_Csev_work
act15_Ciev_work
ags15_Csev_health
act15_Ciev_health
ags15_Csev_family
act15_Ciev_family
ags15_Csev_home
act15_Ciev_home
ags15_Csev_all
act15_Ciev_all
ags18_n_cus_arrears_days
ags18_n_cus_good_days
ags18_n_cus_arrears
act18_n_cind_arrears
act18_Cncr_taken
ags18_Csev_work
act18_Ciev_work
ags18_Csev_health
act18_Ciev_health
ags18_Csev_family
act18_Ciev_family
ags18_Csev_home
act18_Ciev_home
ags18_Csev_all
act18_Ciev_all
ags21_n_cus_arrears_days
ags21_n_cus_good_days
ags21_n_cus_arrears
act21_n_cind_arrears
act21_Cncr_taken
ags21_Csev_work
act21_Ciev_work
ags21_Csev_health
act21_Ciev_health
ags21_Csev_family
act21_Ciev_family
ags21_Csev_home
act21_Ciev_home
ags21_Csev_all
act21_Ciev_all
ags24_n_cus_arrears_days
ags24_n_cus_good_days
ags24_n_cus_arrears
act24_n_cind_arrears
act24_Cncr_taken
ags24_Csev_work
act24_Ciev_work
ags24_Csev_health
act24_Ciev_health
ags24_Csev_family
act24_Ciev_family
ags24_Csev_home
act24_Ciev_home
ags24_Csev_all
act24_Ciev_all
ags27_n_cus_arrears_days
ags27_n_cus_good_days
ags27_n_cus_arrears
act27_n_cind_arrears
act27_Cncr_taken
ags27_Csev_work
act27_Ciev_work
ags27_Csev_health
act27_Ciev_health
ags27_Csev_family
act27_Ciev_family
ags27_Csev_home
act27_Ciev_home
ags27_Csev_all
act27_Ciev_all
ags30_n_cus_arrears_days
ags30_n_cus_good_days
ags30_n_cus_arrears
act30_n_cind_arrears
act30_Cncr_taken
ags30_Csev_work
act30_Ciev_work
ags30_Csev_health
act30_Ciev_health
ags30_Csev_family
act30_Ciev_family
ags30_Csev_home
act30_Ciev_home
ags30_Csev_all
act30_Ciev_all
ags33_n_cus_arrears_days
ags33_n_cus_good_days
ags33_n_cus_arrears
act33_n_cind_arrears
act33_Cncr_taken
ags33_Csev_work
act33_Ciev_work
ags33_Csev_health
act33_Ciev_health
ags33_Csev_family
act33_Ciev_family
ags33_Csev_home
act33_Ciev_home
ags33_Csev_all
act33_Ciev_all
ags36_n_cus_arrears_days
ags36_n_cus_good_days
ags36_n_cus_arrears
act36_n_cind_arrears
act36_Cncr_taken
ags36_Csev_work
act36_Ciev_work
ags36_Csev_health
act36_Ciev_health
ags36_Csev_family
act36_Ciev_family
ags36_Csev_home
act36_Ciev_home
ags36_Csev_all
act36_Ciev_all
act_cus_loan_number;
run;

/* Correlation*/
proc corr data=a;
   var _numeric_;
   with default_cus12;
run;

ods graphics on;

proc corr data=a;
   var act_CMax_Due act_state_1_CMax_Due act_cus_dueutl act_CMin_Due act_state_1_CMin_Due;
run;


proc corr data= a;
   var agr3_Pctl75_CMax_Due
       agr3_Pctl95_CMax_Due
       agr3_Mean_CMax_Due
       agr3_Max_CMax_Due
       agr3_Sum_CMax_Due
       agr3_Pctl75_CMin_Due
       agr3_Pctl95_CMin_Due
       agr3_Mean_CMin_Due
       agr3_Max_CMin_Due
       agr3_Sum_CMin_Due;
run;


proc corr data= a;
   var  ags3_Pctl75_CMax_Due
        ags3_Pctl95_CMax_Due
        ags3_Mean_CMax_Due
        ags3_Max_CMax_Due
        ags3_Sum_CMax_Due
        ags3_Pctl75_CMin_Due
        ags3_Pctl95_CMin_Due
        ags3_Mean_CMin_Due
        ags3_Max_CMin_Due
        ags3_Sum_CMin_Due
        ags3_n_cus_arrears;
run;

/* Plot*/
proc corr data= a 
plots(MAXPOINTS=none)=scatter;
   var act_CMax_Due agr3_Mean_CMax_Due ags3_Mean_CMax_Due;
   with default_cus12;
run;

