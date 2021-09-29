****
* Append all data from geo 1990 and geo 2013 maps
****

#delim; 
use "${weather_data}/Processed data/Weather_geoinpoly_USA.dta", clear;
duplicates drop smsa, force;
keep smsa;
gen choice = 1;
save "${weather_data}/Processed data/smsa_choice.dta", replace;


use "${weather_data}/Processed data/Weather_geoinpoly_2013_USA.dta", clear;
duplicates drop smsa, force;
keep smsa;
append using "${weather_data}/Processed data/smsa_choice.dta";
bysort smsa: egen choice_m = max(choice);
replace choice = choice_m;
drop choice_m;
replace choice = 2 if choice==.;
save "${weather_data}/Processed data/smsa_choice.dta", replace;


use  "${weather_data}/Processed data/Weather_centroid_USA.dta", clear;
duplicates drop smsa, force;
keep smsa;
append using "${weather_data}/Processed data/smsa_choice.dta";
bysort smsa: egen choice_m = max(choice);
replace choice = choice_m;
drop choice_m;
replace choice = 3 if choice==.;
save "${weather_data}/Processed data/smsa_choice.dta", replace;


use  "${weather_data}/Processed data/Weather_centroid_2013_USA.dta", clear;
duplicates drop smsa, force;
keep smsa;
append using "${weather_data}/Processed data/smsa_choice.dta";
bysort smsa: egen choice_m = max(choice);
replace choice = choice_m;
drop choice_m;
replace choice = 4 if choice==.;
save "${weather_data}/Processed data/smsa_choice.dta", replace;


use  "${weather_data}/Processed data/Weather_centroid_FIPS_USA.dta", clear;
duplicates drop smsa, force;
keep smsa;
append using "${weather_data}/Processed data/smsa_choice.dta";
bysort smsa: egen choice_m = max(choice);
replace choice = choice_m;
drop choice_m;
replace choice = 5 if choice==.;
save "${weather_data}/Processed data/smsa_choice.dta", replace;


duplicates drop smsa choice, force;
save "${weather_data}/Processed data/smsa_choice.dta", replace;




use "${weather_data}/Processed data/Weather_geoinpoly_USA.dta", clear;
merge m:1 smsa using "${weather_data}/Processed data/smsa_choice.dta";
keep if choice == 1;
save "${weather_data}/Processed data/Temp_1.dta", replace;

use "${weather_data}/Processed data/Weather_geoinpoly_2013_USA.dta", clear;
merge m:1 smsa using "${weather_data}/Processed data/smsa_choice.dta";
keep if choice == 2;
save "${weather_data}/Processed data/Temp_2.dta", replace;

use  "${weather_data}/Processed data/Weather_centroid_USA.dta", clear;
merge m:1 smsa using "${weather_data}/Processed data/smsa_choice.dta";
keep if choice == 3;
save "${weather_data}/Processed data/Temp_3.dta", replace;

use  "${weather_data}/Processed data/Weather_centroid_2013_USA.dta", clear;
merge m:1 smsa using "${weather_data}/Processed data/smsa_choice.dta";
keep if choice == 4;
save "${weather_data}/Processed data/Temp_4.dta", replace;


use  "${weather_data}/Processed data/Weather_centroid_FIPS_USA.dta", clear;
merge m:1 smsa using "${weather_data}/Processed data/smsa_choice.dta";
keep if choice == 5;


append using "${weather_data}/Processed data/Temp_1.dta" "${weather_data}/Processed data/Temp_2.dta" 
"${weather_data}/Processed data/Temp_3.dta"
"${weather_data}/Processed data/Temp_4.dta"
;

erase "${weather_data}/Processed data/Temp_1.dta";
erase "${weather_data}/Processed data/Temp_2.dta";
erase "${weather_data}/Processed data/Temp_3.dta";
erase "${weather_data}/Processed data/Temp_4.dta";


compress;
save "${weather_data}/Processed data/Weather_daily_SMSA.dta", replace;


#delim;
use "${weather_data}/Processed data/Weather_daily_SMSA.dta", clear;

drop if smsa==.;
gen Day_TEMP = (SMSA_tmax+SMSA_tmin)/2*9/5+32;
gen Day_PREC = SMSA_precip;

#delim;
global temps " "20" "30" "40" "50" "60" "70" "80" "90" ";
foreach j in $temps {;
gen Day_`j' = (Day_TEMP<=`j');
};

gen Day_90_p = Day_TEMP>90 & Day_TEMP!=.;
replace Day_90 = Day_90 - Day_80;
replace Day_80 = Day_80 - Day_70;
replace Day_70 = Day_70 - Day_60;
replace Day_60 = Day_60 - Day_50;
replace Day_50 = Day_50 - Day_40;
replace Day_40 = Day_40 - Day_30;
replace Day_30 = Day_30 - Day_20;


gen year_12 = Year;

#delim;
local i = 1;
while `i'<=11 {;
gen year_`i' = Year if Month<=`i' & Month!=.;
replace year_`i' = Year+1 if Month>`i' & Month!=.;
local i = `i'+1;
};

#delim;
gen C = 1;
gen C_PREC = ( Day_PREC !=. );
gen C_TEMP = ( Day_TEMP !=. );

#delim;
gen No_month = 31 if Month == 1; replace No_month = 28 if Month == 2; replace No_month = 31 if Month == 3; replace No_month = 30 if Month == 4; replace No_month = 31 if Month == 5; replace No_month = 30 if Month == 6;
replace No_month = 31 if Month == 7; replace No_month = 31 if Month == 8; replace No_month = 30 if Month == 9; replace No_month = 31 if Month == 10; replace No_month = 30 if Month == 11; replace No_month = 31 if Month == 12;


gen cldd = Day_TEMP - 65;
gen htdd = cldd*(-1)*(cldd<0);
replace cldd = 0 if cldd<0;


#delim;
local i = 1;
while `i'<=12 {;
global temps " "20" "30" "40" "50" "60" "70" "80" "90" "90_p" ";
bysort smsa year_`i': egen C_PREC_`i' = sum(C_PREC);
bysort smsa year_`i': egen C_TEMP_`i' = sum(C_TEMP);
foreach j in $temps {;
bysort smsa year_`i': egen total_`j'_`i' = sum(Day_`j');
replace total_`j'_`i' = total_`j'_`i'/C_TEMP_`i' * 365;
};
bysort smsa year_`i': egen total_prec_`i' = sum(Day_PREC);
bysort smsa year_`i': egen total_htdd_`i' = sum(htdd);
bysort smsa year_`i': egen total_cldd_`i' = sum(cldd);
replace total_htdd_`i' = total_htdd_`i'/C_TEMP_`i' * 365;
replace total_cldd_`i' = total_cldd_`i'/C_TEMP_`i' * 365;
replace total_prec_`i' = total_prec_`i'/C_PREC_`i' * 365;
di `i';
local i = `i' + 1;
};

sum C_TEMP_* C_PREC_*;

#delim;
gen total_90_p = total_90_p_1 if Month==1;
gen total_90 = total_90_1 if Month==1;
gen total_80 = total_80_1 if Month==1;
gen total_70 = total_70_1 if Month==1;
gen total_60 = total_60_1 if Month==1;
gen total_50 = total_50_1 if Month==1;
gen total_40 = total_40_1 if Month==1;
gen total_30 = total_30_1 if Month==1;
gen total_20 = total_20_1 if Month==1;

#delim;
gen total_htdd = total_htdd_1 if Month==1;
gen total_cldd = total_cldd_1 if Month==1;
gen total_prec = total_prec_1 if Month==1;

#delim;
local i = 2;
while `i'<=12 {;
replace total_90_p = total_90_p_`i' if Month==`i';
replace total_90 = total_90_`i' if Month==`i';
replace total_80 = total_80_`i' if Month==`i';
replace total_70 = total_70_`i' if Month==`i';
replace total_60 = total_60_`i' if Month==`i';
replace total_50 = total_50_`i' if Month==`i';
replace total_40 = total_40_`i' if Month==`i';
replace total_30 = total_30_`i' if Month==`i';
replace total_20 = total_20_`i' if Month==`i';
replace total_htdd = total_htdd_`i' if Month==`i';
replace total_cldd = total_cldd_`i' if Month==`i';
replace total_prec = total_prec_`i' if Month==`i';
local i = `i'+1;
};

#delim;
keep smsa Month Year  total_*dd total_20 total_30 total_40 total_50 total_60 total_70 total_80 total_90 total_90_p total_prec;
duplicates drop smsa Month Year, force;

#delim;
egen sumR = rowtotal(total_20 total_30 total_40 total_50 total_60 total_70 total_80 total_90 total_90_p); 
sum sumR, detail;

egen ID_smsa = group(smsa Month);

#delim;
drop if ID_smsa==.;
xtset ID_smsa Year, yearly;

#delim;
local i = 1;
while `i'<=20 {;
gen total_htdd_L`i' = L`i'.total_htdd;
gen total_cldd_L`i' = L`i'.total_cldd;
gen total_prec_L`i' = L`i'.total_prec;
gen total_20_L`i' = L`i'.total_20;
gen total_30_L`i' = L`i'.total_30;
gen total_40_L`i' = L`i'.total_40;
gen total_50_L`i' = L`i'.total_50;
gen total_60_L`i' = L`i'.total_60;
gen total_70_L`i' = L`i'.total_70;
gen total_80_L`i' = L`i'.total_80;
gen total_90_L`i' = L`i'.total_90;
gen total_90_p_L`i' = L`i'.total_90_p;
local i = `i' +1;
};

keep smsa Year Month total*;

rename Year year;
rename Month month;

save "${weather_data}/Processed data/Weather_annual_SMSA.dta", replace;

erase "${weather_data}/Processed data/Weather_daily_SMSA.dta";


****;
* MISSING CODE (NOT CONTINENTAL USA);
****;
*3320 Honolulu;

