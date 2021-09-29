


cd "${weather_data}/Boundaries/From FIPS codes/centroid"
spshape2dta "Centroid_FIPS", replace



***
*MISSING MSA PATCH
***

clear
import excel "${weather_data}/Boundaries/Code for missing MSA.xls", sheet("Patch") firstrow
drop CBSACode
duplicates drop FIPS smsa, force
destring *, replace
keep FIPS smsa
keep if FIPS!=.
save "${weather_data}/Boundaries/Patch_FIPS.dta", replace
****




clear
import delimited "${weather_data}/Boundaries/From FIPS codes/centroid/Centroid_FIPS.csv"

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


keep st co name longitude latitude

save  "${weather_data}/Boundaries/From FIPS codes/centroid/Centroid_FIPS_data.dta", replace


global yr = 1979
while $yr <= 2013 {


clear
import delimited "${weather_data}/Cropped data/tmax_${yr}_cropped.csv"
save "${weather_data}/Cropped data/Temp_FIPS_1.dta", replace

clear
import delimited "${weather_data}/Cropped data/tmin_${yr}_cropped.csv"
save "${weather_data}/Cropped data//Temp_FIPS_2.dta", replace

clear
import delimited "${weather_data}/Cropped data/precip_${yr}_cropped.csv"

merge 1:1 longitude latitude time using "${weather_data}/Cropped data/Temp_FIPS_1.dta"
drop _merge
merge 1:1 longitude latitude time using "${weather_data}/Cropped data/Temp_FIPS_2.dta"
drop _merge

replace longitude = longitude - 360

joinby longitude latitude using "${weather_data}/Boundaries/From FIPS codes/centroid/Centroid_FIPS_data.dta"

replace time = subinstr(time,"T00:00:00","",1)
compress

gen FIPS = st * 1000 + co
keep time latitude longitude precip tmax tmin FIPS

save  "${weather_data}/Weather_${yr}_mun_FIPS.dta", replace 

global yr = $yr +1
}

erase "${weather_data}/Cropped data/Temp_FIPS_1.dta"
erase "${weather_data}/Cropped data/Temp_FIPS_2.dta"



use "${weather_data}/Weather_1979_mun_FIPS.dta"

global yr = 1980
while $yr <= 2013 {
append using "${weather_data}/Weather_${yr}_mun_FIPS.dta"
erase "${weather_data}/Weather_${yr}_mun_FIPS.dta"
global yr = $yr +1
}


save  "${weather_data}/Processed data/Weather_centroid_FIPS_USA.dta", replace 

erase "${weather_data}/Weather_1979_mun_FIPS.dta"



clear
use "${weather_data}/Processed data/Weather_centroid_FIPS_USA.dta"
joinby FIPS using "${weather_data}/Boundaries/Patch_FIPS.dta"

gen date = date(time,"YMD")

gen Year = year(date)
gen Month = month(date)
gen Day = day(date)


count
bysort smsa Day Month Year: egen SMSA_tmax = mean(tmax)
bysort smsa Day Month Year: egen SMSA_tmin = mean(tmin)
bysort smsa Day Month Year: egen SMSA_precip = mean(precip)


duplicates drop smsa Day Month Year, force
drop FIPS

keep date Year Month Day SMSA_precip SMSA_tmin SMSA_tmax smsa
compress

save  "${weather_data}/Processed data/Weather_centroid_FIPS_USA.dta", replace
