
cd "${weather_data}/Boundaries/ma99_90_shp"
spshape2dta "ma99_90", replace

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


geoinpoly latitude longitude using "${weather_data}/Boundaries/ma99_90_shp/ma99_90_shp.dta"

replace time = subinstr(time,"T00:00:00","",1)
compress



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

save  "${weather_data}/Processed data/Weather_geoinpoly_USA.dta", replace 

erase "${weather_data}/Weather_1979_mun.dta"



use  "${weather_data}/Processed data/Weather_geoinpoly_USA.dta", clear
merge m:1 _ID using "${weather_data}/Boundaries/ma99_90_shp/ma99_90.dta", gen(m_ID)
keep if m_ID==3
keep date Year Month Day MSA*
rename MSA smsa
destring smsa, replace
compress 
bysort smsa Year Month Day: egen SMSA_tmax = mean(MSA_tmax)
bysort smsa Year Month Day: egen SMSA_tmin = mean(MSA_tmin)
bysort smsa Year Month Day: egen SMSA_precip = mean(MSA_precip)
keep SMSA_precip SMSA_tmax SMSA_tmin smsa date Year Month Day
duplicates drop SMSA_precip SMSA_tmax SMSA_tmin smsa date Year Month Day, force
duplicates drop Year Month Day smsa, force
save  "${weather_data}/Processed data/Weather_geoinpoly_USA.dta", replace 




****
* WITH CENTROIDS
****

clear
import delimited "${weather_data}/Boundaries/ma99_90_shp/centroid/Centroid_MSA_as_GIS.csv"

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


keep ma99_90_id msa name longitude latitude

save  "${weather_data}/Boundaries/ma99_90_shp/centroid/Centroid_MSA_data.dta", replace


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

joinby longitude latitude using "${weather_data}/Boundaries/ma99_90_shp/centroid/Centroid_MSA_data.dta"

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

save  "${weather_data}/Processed data/Weather_centroid_USA.dta", replace 

erase "${weather_data}/Weather_1979_mun.dta"




use  "${weather_data}/Processed data/Weather_centroid_USA.dta", clear
replace time = subinstr(time,"T00:00:00","",1)
gen date = date(time,"YMD")
gen Year = year(date)
gen Month = month(date)
gen Day = day(date)

** note that some smsa have several centroids **
bysort msa Year Month Day: egen SMSA_tmax = mean(tmax)
bysort msa Year Month Day: egen SMSA_tmin = mean(tmin)
bysort msa Year Month Day: egen SMSA_precip = mean(precip)

keep SMSA_precip SMSA_tmax SMSA_tmin msa date Year Month Day

duplicates drop SMSA_precip SMSA_tmax SMSA_tmin msa date Year Month Day, force
duplicates drop Year Month Day msa, force

compress
rename msa smsa 
save  "${weather_data}/Processed data/Weather_centroid_USA.dta", replace
