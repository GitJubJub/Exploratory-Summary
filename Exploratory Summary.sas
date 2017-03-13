
	/***********************************************************************/
	/* SAS Code for an Exploratory Summary of Datasets                     */
	/*                                                                     */
	/*  SAS is a great tool for working with large datasets. The program   */
	/* R has a convenient function (str) which gives a bird's eye view     */
	/* of a dataset.  This SAS Program gives a similar type of view for    */
	/* users when reviewing a dataset.                                     */
	/*                                                                     */
	/* The code check the data for missing values.  It also separates the  */
	/* data into three different types:  Date, Numeric and Character.      */
	/* It summarizes the Date and Numeric values with a seven number       */
	/* summary (Min, Max, IQs, Median, Mean and SD).  For character        */
	/* it lists the top 6 and lowest 3 by frequency.  When there are ties  */
	/* it sorts the character values by value name.                        */
	/*                                                                     */
	/* A Warning is read to the SAS log when a SQL query is cut short      */
	/*  due to the number of observations.                                 */
	/*                                                                     */
	/*                                    - A. Brignole  Feb & Mar, 2017   */
	/*                                                                     */
	/***********************************************************************/


options mprint mlogic;


%let dataset = statdata.ameshousing3;


ods output position = vars;


proc contents data = &dataset varnum; 

	title "Metadata Output for the Dataset &dataset";

run;


data DateVars Numvars Charvars Allvars 

	(drop = CharVarN DateVarN NumVarN); 
	
	set vars end = last;
	
	lent = length(variable);
	
	if Type = 'Char' then do;
	
		output Charvars;
		
		CharVarN + 1;
		
	end;

	else if substr(Format,1, 4) in ('DATE')
	
		OR substr(Format, 1, 2)  in ('DD', 'DT', 'MM', 'MO', 'YY') 
		
		OR substr(Format, 1, 7) ='WORDDAT' then do;
		
			output DateVars;
		
			DateVarN + 1;
		
	end;
	
	else if Type = 'Num' then do;
	
		output NumVars;
		
		NumVarN + 1;
	
	end;
	
	else do;
		
		output Charvars;
		
		CharVarN + 1;
	
	end;
	
	call symput (compress('var'||_n_),variable);
	
	output allvars;
	
	if last then do;
	
		call symput('allvarn', _n_);
		
		call symput('CharVarN', CharVarN);
		
		call symput ('DateVarN', DateVarN);
		
		call symput ('NumVarN', NumVarN);
	
	end;

run;


proc sql noprint; 
	
	select max(len) as MaxLen, max(lent) as VarNmLen
	
	into :MxVarNmLen, :VarNmLen
	
	from allvars;
	
quit;

%let Maxlen = %trim(&MxVarNmLen);


%let Nmlen = %trim(%eval(&VarNmLen + 2));


%put &allvarn;


%macro VarsCheck;
	

%do i = 1 %to &allvarn;


	proc sql;
	
		create table MissingVar&i as
	
		select "&&&var&i" as Variable,
		
			count(*) as Lines,
		
			n("&&&var&i"n) as Present label = 'Values Present',
		
			nmiss("&&&var&i"n) as Missing label = 'Values Missing',
		
			count(distinct "&&&var&i"n) as Values label = 'Unique Values'
		
		from &dataset;
		
	quit;
	

	%if &i = 1 %then %do;

		
		data VarsCheck; 
			
			set MissingVar&i; 
		
		run;


	%end;
	
	
	%if &i > 1 %then %do;
	
	
		data VarsCheck; 
		
			set VarsCheck MissingVar&i; 
		
		run;
	
	
	%end;


%end;


%mend;


%VarsCheck;

	
data VarsFlagged; 

	set VarsCheck;

	if Lines = Missing then Flag = '***';

	else if Missing > 0 then Flag = '*';
	
run;


proc print data = VarsFlagged label;
		
	title 'Variables Without Values';
		
	where Flag = '***';
	
run;

	
proc print data = VarsFlagged label;
		
	title 'Variables With and Without Values';
	
run;


proc sql noprint;

	select variable
	
	into :NumVars separated by ' '
	
	from NumVars;
	
	select variable 
	
	into :CharVars separated by ' '
	
	from CharVars;
	
	select variable
	
	into :DateVars separated by ' '
	
	from DateVars;

quit;

%macro NumericSum;

	%if &NumVarN > 0 %then %do;

	
		proc means data = &dataset n nmiss Min Q1 Median Q3 Max Mean Std;
			
			title "Summary of Numeric Values In the Dataset &dataset";
		
			var &NumVars;
		
		run;


	%end;


	%if &DateVarN > 0 %then %do;

		proc tabulate data=&dataset; 
		
		title "Summary of Date Values in the Dataset &dataset";
		
		var &DateVars; 
		
		table &DateVars, n nmiss (Min Q1 median Q3 Max Mean Std)*format=mmddyy10. range*format = comma.; 
		
		run; 
		

	%end;


%mend;


%NumericSum;


%macro CharSum;


%if &CharVarN > 0 %then %do;
		

	%do i = 1 %to &CharVarN; 

		
%let CharVarName = %scan(&CharVars, &i);

	
%put &CharVarName;


		data Charible;
		
			set VarsFlagged;
			
			where variable = "&CharVarName";
			
			call symput ('Values', Values);
			
		run;


		proc sql outobs = 6; 
		
			create table TopFive as
			
			select &CharVarName as Values, 
			
				count(&charVarName) as Count,
			
				"&CharVarName" as Variable,
				
				"High" as Rank
				
			from &dataset
			
			group by 1
			
			order by Count desc;
			
		quit;
		
		
		proc sql outobs = 3; 
		
			create table LowerThree as
			
			select &CharVarName as Values,
			
				count(&CharVarName) as Count,
				
				"&CharVarName" as Variable,
				
				"Low" as Rank
			
			from &dataset
			
			group by 1
			
			order by Count, Values;
			
		quit;


		%if &i = 1 %then %do;
			

			data Appended;
			
				length Values $&MaxLen.. ;
				
				length Variable $&NmLen.. ;
			 
				set TopFive LowerThree;		
			
			run;

		
		%end;

		
		%if &i > 1 %then %do;

		
			data Appended;
			
				set Appended TopFive LowerThree;
				
				ValuesNo = compress(Values||' - ('||input(Count,comma18.)||')');
				
			run;

			
		%end;


		data Named (drop = LagRank No);
		
			set Appended;
				
				LagRank = lag(Rank);
				
				if Rank = LagRank or LagRank = '' then No + 1;
				
				else No = 1;	
			
				RankNo = compress(Rank!!No);

				if compress(Values) = '' then Values = '**Missing**';

		run;


	%end;


	proc sort data = Named out = NoDups nodupkey; 
	
		by Variable Values; 
		
	run;


	proc sort data = NoDups; 

		by Variable RankNo;
	
	run;


	proc transpose data = NoDups out = Transposed (drop = _label_ _name_);
		
		by Variable;
		
		var Values Count;
		
		id RankNo;
	
	run;
	
	
	data CharPrePrint (drop = lagVar); set Transposed;
	
		lagVar = lag(Variable);
		
		if Variable = lagVar then Variable = 'N_'||trim(Variable);
	
	run;
	
	
	proc print data = CharPrePrint label noobs;
	
		title "Summary of Top and Low Frequency Variables in &dataset";
		
	run;
	

	proc sql noprint; 
	
		select count(*) 
		
		into :DistinctN
		
		from VarsFlagged
		
		where Values between 1 and 20 
		
			AND variable in (select variable from CharVars);

			
		select variable
			
		into :distinctive separated by ' '
			
		from VarsFlagged 
			
		where values between 1 and 20
			
			AND variable in (select variable from CharVars);

	quit;
		

	%if &DistinctN > 0 %then %do;
	
	
		proc freq data = &dataset order = freq ;
		
				title "Summary of Distinctive Character Variables in Dataset &dataset";
			
				tables &Distinctive / nocum;
				
		run;


	%end;


%end;


%mend;


%CharSum;



