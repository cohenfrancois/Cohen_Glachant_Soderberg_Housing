#delim;

**********************************************;
* Master do.file to run all programmes of Cohen, Glachant and Soderberg, 2021;
**********************************************;

*** MODIFY THIS FIRST FOLDER TO RUN THE REST OF THE CODE ***;
global folder_replication "/soge-home/staff/smit0148/LSE Research/HOUSING PAPER/FINAL CODE/";

**********************************************;
* links to folders in the replication package;
**********************************************;

global weather_data "${folder_replication}/1. Weather data/";
global AHS_raw_data "${folder_replication}/2. Prepare AHS data/Raw data/";
global AHS_processed_data "${folder_replication}/2. Prepare AHS data/Processed data/";
global other_data "${folder_replication}/Other data/";
global output_home_improvements "${folder_replication}/3. Home improvement model/output/";
global output_utilities "${folder_replication}/4. Utilities model/output/";
global output_simulation "${folder_replication}/5. Climate change simulation/output/";
global output_robustness_invest "${folder_replication}/6. Appendices/Robustness - Home improvements/output/";
global output_robustness_utilities "${folder_replication}/6. Appendices/Robustness - Utilities/output/";
global output_methods "${folder_replication}/6. Appendices/Methodological details/output/";
global logs "${folder_replication}/Logs/";

**********************************************;
* Prepare Weather data;
* Note: all formatted raw data are provided in the replication package;
**********************************************;

* This is done in three steps using linux and windows commands, Excel, Python and Stata;
* Steps I and II are done using windows and linux commands, as well as Excel and python;
* Step III is done with Stata;

** Step I ** CSV formatting of CPC data;
* 1: We download the CPC data with: "Download grids (Windows).bat";
* 2: We then crop the NetCDF files with the CDO command in Linux: "Cropping nc files_USA (Linux cdo).sh";
* 3: The cropped NetCDF files are converted into 4-column CSV files (weather variable, lon, lat, date) using Python;

** Step II ** Centroid of administrative boundaries;
* 1: We have downloaded three maps. 1990 MSA map, 1990 US county map, and 2013 ;
* 2: We calculate the centroid of each polygon in each map with: Centroid_MSA.py, Centroid_MSA_2013.py and Centroid_FIPS.py;
* 3: We either use QGIS to convert the centroid shapefiles to CSV, or the shp2dta command in Stata;

** Step III ** Running Stata programmes with the CPC data in CSV format, and the shapefiles (polygons and centroids);

log using "${logs}/Log weather data.smcl", replace;
do "${folder_replication}/1. Weather data/1. First match with 1990 MSA map.do";
do "${folder_replication}/1. Weather data/2. Match missing MSA with 2013 CBSA map.do";
do "${folder_replication}/1. Weather data/3. Match last AHS codes with 1990 county map.do";
do "${folder_replication}/1. Weather data/4. Produce main weather dataset.do";
log close;

**********************************************;
* Prepare AHS data;
**********************************************;

log using "${logs}/Log AHS data.smcl", replace;
do "${folder_replication}/2. Prepare AHS data/1. Extract home improvement data.do";
do "${folder_replication}/2. Prepare AHS data/2. Extract other housing data.do";
do "${folder_replication}/2. Prepare AHS data/3. Extract data on households.do";
log close;

**********************************************;
* Home Improvement Model;
**********************************************;

log using "${logs}/Log home improvements.smcl", replace;
do "${folder_replication}/3. Home improvement model/1. Home improvement model.do";
do "${folder_replication}/3. Home improvement model/2. Home improvement model_heterogeneity.do";
log close;

**********************************************;
* Utility expenditure model;
**********************************************;

log using "${logs}/Log utility expenditure.smcl", replace;
do "${folder_replication}/4. Utilities model/1. Utilities model short and long term.do";
do "${folder_replication}/4. Utilities model/2. Utilities model short and long term_heterogeneity.do";
log close;

**********************************************;
* Climate change simulation;
**********************************************;

log using "${logs}/Simulation.smcl", replace;
do "${folder_replication}/5. Climate change simulation/Run simulation (with precipitation).do";
do "${folder_replication}/5. Climate change simulation/Run simulation (Cold).do";
do "${folder_replication}/5. Climate change simulation/Run simulation (Hot).do";
do "${folder_replication}/5. Climate change simulation/Run simulation (Rich).do";
do "${folder_replication}/5. Climate change simulation/Run simulation (Poor).do";
** NB: The datasets created by the simulation runs have to be copy-pasted in the Excel files: "Simulation tables.xlsx" 
** for the first do.file, and "Simulation tables_Heterogeneity.xlsx" for the other four;
** Then run;
do "${folder_replication}/5. Climate change simulation/Simulation graphs (appendices).do";
log close;

**********************************************;
* APPENDICES;
**********************************************;

#delim;
log using "${logs}/Log appendices.smcl", replace;
do "${folder_replication}/6. Appendices/Summary statistics/Summary statistics.do";
** Note: Copy-paste output of summary statistics.do into "Summary statistics.xlsx";
do "${folder_replication}/6. Appendices/Methodological details/Discontinuity in 1997.do";
do "${folder_replication}/6. Appendices/Robustness - Home improvements/Home improvement model_2SLS.do";
do "${folder_replication}/6. Appendices/Robustness - Home improvements/Home improvement model_LIML.do";
do "${folder_replication}/6. Appendices/Robustness - Home improvements/AC diffusion.do";
do "${folder_replication}/6. Appendices/Robustness - Home improvements/Figure with precipitations.do";
do "${folder_replication}/6. Appendices/Robustness - Home improvements/High lambda.do";
do "${folder_replication}/6. Appendices/Robustness - Home improvements/Low lambda.do";
do "${folder_replication}/6. Appendices/Robustness - Home improvements/OLS instead of GMM.do";
do "${folder_replication}/6. Appendices/Robustness - Home improvements/With contemporaneous weather variables.do";
do "${folder_replication}/6. Appendices/Robustness - Home improvements/With distributed lags.do";
do "${folder_replication}/6. Appendices/Robustness - Home improvements/With outliers.do";
do "${folder_replication}/6. Appendices/Robustness - Utilities/Utility expenditure with outliers.do";
do "${folder_replication}/6. Appendices/Robustness - Utilities/With 5 obs for the average variables.do";
do "${folder_replication}/6. Appendices/Robustness - Utilities/Withdrawing waves.do";
log close;
