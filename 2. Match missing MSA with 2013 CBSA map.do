

***
*MISSING MSA PATCH
***

clear
import excel "${weather_data}/Boundaries/Code for missing MSA.xls", sheet("Patch") firstrow
rename CBSACode cbsa
keep if cbsa!=""
drop FIPS
duplicates drop cbsa smsa, force
destring *, replace
keep cbsa smsa
save "${weather_data}/Boundaries/Patch_cbsa.dta", replace

***
*GEOINPOLY 2013 CBSA
***



cd "${weather_data}/Boundaries/cb_2013_us_cbsa_500k"
spshape2dta "cb_2013_us_cbsa_500k", replace

global yr = 1979
while $yr <= 2013 {


clear
import delimited "${weather_data}/Cropped data/tmax_${yr}_cropped.csv"

save "${weather_data}/Cropped data/Temp_1.dta", replace
clear
import delimited "${weather_data}/Cropped data/tmin_${yr}_cropped.csv"
save "${weather_data}/Cropped data//Temp_2.dta", replace
clear
import delimited "${weather_data}/Cropped data/precip_${yr}_cropped.csv"

merge 1:1 longitude latitude time using "${weather_data}/Cropped data/Temp_1.dta"
drop _merge
merge 1:1 longitude latitude time using "${weather_data}/Cropped data/Temp_2.dta"
drop _merge

replace longitude = longitude - 360


geoinpoly latitude longitude using "${weather_data}/Boundaries/cb_2013_us_cbsa_500k/cb_2013_us_cbsa_500k_shp.dta"

replace time = subinstr(time,"T00:00:00","",1)
compress



** keep only province level values
bysort time _ID: egen MSA_tmax = mean(tmax)
bysort time _ID: egen MSA_tmin = mean(tmin)
bysort time _ID: egen MSA_precip = mean(precip)
duplicates drop time _ID, force

keep time _ID MSA*

gen date = date(time,"YMD")

gen Year = year(date)
gen Month = month(date)
gen Day = day(date)

save  "${weather_data}/Weather_${yr}_mun.dta", replace 

global yr = $yr +1
}

erase "${weather_data}/Cropped data/Temp_1.dta"
erase "${weather_data}/Cropped data/Temp_2.dta"


use "${weather_data}/Weather_1979_mun.dta"

global yr = 1980
while $yr <= 2013 {
append using "${weather_data}/Weather_${yr}_mun.dta"
erase "${weather_data}/Weather_${yr}_mun.dta"
global yr = $yr +1
}

merge m:1 _ID using "${weather_data}/Boundaries/cb_2013_us_cbsa_500k/cb_2013_us_cbsa_500k.dta", gen(m_ID)
keep if m_ID==3

keep MSA_tmax MSA_tmin MSA_precip date Year Month Day GEOID NAME

save  "${weather_data}/Processed data/Weather_geoinpoly_2013_USA.dta", replace 


erase "${weather_data}/Weather_1979_mun.dta"


clear
use "${weather_data}/Processed data/Weather_geoinpoly_2013_USA.dta"
rename GEOID cbsa
destring cbsa, replace
joinby cbsa using "${weather_data}/Boundaries/Patch_cbsa.dta"

count
bysort smsa Day Month Year: egen SMSA_tmax = mean(MSA_tmax)
bysort smsa Day Month Year: egen SMSA_tmin = mean(MSA_tmin)
bysort smsa Day Month Year: egen SMSA_precip = mean(MSA_precip)

duplicates drop smsa Day Month Year, force
drop cbsa

keep date Year Month Day SMSA_precip SMSA_tmin SMSA_tmax smsa
compress

save  "${weather_data}/Processed data/Weather_geoinpoly_2013_USA.dta", replace



****
* CENTROID 2013 CBSA
****



cd "${weather_data}/Boundaries/cb_2013_us_cbsa_500k/centroid"
spshape2dta "Centroid_MSA_2013", replace


use Centroid_MSA_2013_shp, clear

rename _X x
rename _Y y

*replace x = x + 360
gen x_dec = abs(x) - int(abs(x))
gen longitude = int(x) + 0.25 if x_dec<0.5 & x>=0
replace longitude = int(x) + 0.75 if x_dec>=0.5  & x>=0
replace longitude = int(x) - 0.25 if x_dec<0.5 & x<0
replace longitude = int(x) - 0.75 if x_dec>=0.5  & x<0

gen y_dec = abs(y) - int(abs(y))
gen latitude = int(y) + 0.25 if y_dec<0.5 & y>=0
replace latitude = int(y) + 0.75 if y_dec>=0.5  & y>=0
replace latitude = int(y) - 0.25 if y_dec<0.5 & y<0
replace latitude = int(y) - 0.75 if y_dec>=0.5  & y<0

merge 1:1 _ID using "Centroid_MSA_2013.dta"

destring GEOID, replace

keep longitude latitude GEOID

save  "Centroid_MSA_2013_data.dta", replace


global yr = 1979
while $yr <= 2013 {


clear
import delimited "${weather_data}/Cropped data/tmax_${yr}_cropped.csv"
save "${weather_data}/Cropped data/Temp_1.dta", replace

clear
import delimited "${weather_data}/Cropped data/tmin_${yr}_cropped.csv"
save "${weather_data}/Cropped data//Temp_2.dta", replace

clear
import delimited "${weather_data}/Cropped data/precip_${yr}_cropped.csv"

merge 1:1 longitude latitude time using "${weather_data}/Cropped data/Temp_1.dta"
drop _merge
merge 1:1 longitude latitude time using "${weather_data}/Cropped data/Temp_2.dta"
drop _merge

replace longitude = longitude - 360

joinby longitude latitude using "Centroid_MSA_2013_data.dta"

replace time = subinstr(time,"T00:00:00","",1)
compress

save  "${weather_data}/Weather_${yr}_mun.dta", replace 

global yr = $yr +1
}

erase "${weather_data}/Cropped data/Temp_1.dta"
erase "${weather_data}/Cropped data/Temp_2.dta"



use "${weather_data}/Weather_1979_mun.dta"

global yr = 1980
while $yr <= 2013 {
append using "${weather_data}/Weather_${yr}_mun.dta"
erase "${weather_data}/Weather_${yr}_mun.dta"
global yr = $yr +1
}

save  "${weather_data}/Processed data/Weather_centroid_2013_USA.dta", replace 

erase "${weather_data}/Weather_1979_mun.dta"


use  "${weather_data}/Processed data/Weather_centroid_2013_USA.dta", replace 
gen date = date(time,"YMD")
gen Year = year(date)
gen Month = month(date)
gen Day = day(date)

rename GEOID cbsa
destring cbsa, replace
joinby cbsa using "${weather_data}/Boundaries/Patch_cbsa.dta"


bysort smsa Year Month Day: egen SMSA_tmax = mean(tmax)
bysort smsa Year Month Day: egen SMSA_tmin = mean(tmin)
bysort smsa Year Month Day: egen SMSA_precip = mean(precip)

keep SMSA_precip SMSA_tmax SMSA_tmin smsa date Year Month Day

duplicates drop SMSA_precip SMSA_tmax SMSA_tmin smsa date Year Month Day, force
duplicates drop Year Month Day smsa, force

compress

save  "${weather_data}/Processed data/Weather_centroid_2013_USA.dta", replace

