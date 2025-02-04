Here we present a description of all the raw data files in `1-Data-Codes\`.

Classification tables
===========================================================================================

All the scripts use `0-Raw_Data/regions.csv` and `0-Raw_Data/sectors.csv`: the first .csv is simply a table that lists all of our regions of interest, assigns a number to them, and classifies them in two categories ("country" and "state"); and the second .csv file is a table that creates a correspondence between WIOD sectors, NAICS sectors, and our final sectors.


Flows of goods and services, and exposure measures
===========================================================================================

## Country-country bilateral flows

To construct bilateral flows between countries for all sectors, the first script uses the collection of `0-Raw_Data/WIOD/wiot_.xlsx` files. These files are the 2013 world input-output tables by year, for 2000-2011. They can be downloaded directly from [WIOD's page](https://www.rug.nl/ggdc/valuechain/wiod/wiod-2013-release): just select *WIOT Tables Excel*.

## Data for distances

To construct trade distances, the first script needs coordinates and populations (to weight the distances derived solely from coordinates) for the regions of interest. 

For states, that information is stored in the `0-Raw_Data\Fips` folder, which files are taken from [here](https://transition.fcc.gov/oet/info/maps/census/fips/fips.txt) and [here](https://www.census.gov/geographies/reference-files/time-series/geo/centers-population.2000.html#list-tab-1319302393). 

For countries, that information is stored in the `0-Raw_Data\Population_geography` folder, which files come from:

a) United Nations: Population Division, *Population of Urban Agglomerations with 300,000 Inhabitants or More in 2018, by country, 1950-2035 (thousands)*. Which can be downloaded [here](https://population.un.org/wup/Download/).

b) United Nations: Population Division, *Total Population - Both Sexes. De facto population in a country, area or region as of 1 July of the year indicated. Figures are presented in thousands*. Which can be downloaded [here](https://population.un.org/wpp/Download/Standard/Population/).

c) Republic of Cyprus: Statistical Service, *CENSUS OF POPULATION, HOUSING UNITS AND POPULATION ENUMERATED BY DISTRICT AND URBAN/RURAL AREA (1.10.2021) PRELIMINARY RESULTS, COMPARED TO THE CENSUS OF POPULATION (1.10.2011)*. Which can be downloaded [here](https://www.mof.gov.cy/mof/cystat/statistics.nsf/populationcondition_21main_en/populationcondition_21main_en?OpenForm&sub=1&sel=2).

The final outputs are based mainly on input a), with some information of b) and c). Some countries did not meet the requirement of providing information of at least two cities. For all these special cases (with the exception of Cyprus), b) gives the information needed, since it has the cities' population by sex (we just take the aggregation of male and female); from b) we take the urban agglomeration category when possible to make it comparable with the main UN base we are using. For the specific case of Cyprus, the cities' information comes from the country's Statistical Service; since the population statistics available refer to the provinces (named after the main city in them), and not to the city itself, we take the province's urban population and not the whole province population. 

Finally, all population statistics have to be read in thousands of humans beings.

## US state-country trade database 	

To calculate state-country bilateral flows for all sectors except services, the second script uses a US state-country trade database for the years 2002-2019 (imports as of 2008) with a 3 NAICS digit precision, in the form of the collection of `0-Raw_Data//State-Exports-Imports//State Exports by NAICS Commodities-i.csv` and `0-Raw_Data//State-Exports-Imports//State Imports by NAICS Commodities-i.csv` files. To download them, follow these steps:

- Enter the [USA Trade Online](http://usatrade.census.gov/) website. Register, log in, and then click *ACCESS DATA*. At this point, the main page for extracting data will appear with the data selection options. 
- Choose *State Export Data (Origin of Movement)*: *NAICS*. Now, on the left side of the webpage, the main sections to complete will appear; specifically: measures, state, commodity, country and time. 
- The measure of interest is *Total Exports Value ($US)*. Select the first eleven states ranging from *All states* to Florida. Then, in the commodity section, select the check in the second column on the upper part: this will select all 3 digit NAICS categories but not their subsections. Do not select the **All commodities** option. Within the country section, select the check next to **World Total** and then unselect **World Total itself**. Finally, for the time section, select the check that belongs to the first column of the upper section; this will select all years but not their month subdivision.
- Generate the report through the option **REPORT** that resides on the left side of the **WELCOME (NAME)** sign.
- Download the data using the down green arrow option, and choose to do it using a comma separated csv file. 
- Repeat the past steps but selecting the following 11 states on the list: Georgia-Maryland, Massachusetts-New Mexico, New York-South Dakota, and Tennessee-unknown. There is no need to exit the webpage to gather the next 11 states' information, just modify them in the State section. 
- Rename each downloaded file as `State Exports by NAICS Commodities-i.csv`,  $i\in \{1,2,3,4,5\}$       
- In order to proceed with the import data download, choose the *Data Source Selection* option on the upper side.
- Choose *State Import Data (State of Destination)*: *NAICS*.
- The process is fairly similar with some exceptions. In measures, choose *Customs Value (Gen) ($US)*.
- Rename each downloaded file as `State Imports by NAICS Commodities-i.csv`,  $ i\in \{1,2,3,4,5\}$ 

## State-state trade database

To construct bilateral flows between states for all sectors except services and agriculture, the third script uses Census Bureau's Commodity Flow 
Survey (CFS) for 2002, 2007, and 2012.

-CFS data for 2002 can be found [here](https://www.census.gov/data/tables/2002/econ/cfs/2002-state-tables.html). Specifically,  *Table 14. Shipment Characteristics by Destination and Two-Digit Commodity for State of Origin: 2002*. We simply convert it to .xlsx format (and that is the origin of `0-Raw_Data/CFS/CFS2002mine.xlsx`).
-CFS data for 2007 can be downloaded from [here](https://www2.census.gov/econ2007/CF/sector00/). Specifically, *CF0700A22.zip*. We simply convert the .dta file (inside the zip folder) to .xlsx format (and that is the origin of `0-Raw_Data/CFS/CFS2007.xlsx`). 
-CFS for 2012 can downloaded from [here](https://www2.census.gov/programs-surveys/cfs/data/2012/). Specifically, *CF1200A24.zip*. We simply convert the .dta files (inside the zip folders) to .csv format (and that is the origin of `0-Raw_Data/CFS/CF1200A24.csv`). 
-Those data sets give state-state bilateral trade flows in commodities. It is important to note that each commodity can be associated with more than one NAICS sector, depending on the industry that that commodity was produced in.  
So, to distribute the bilateral flows from the previous three data sets to our 12 manufacturing sectors, script 6 calculates first the proportion of the amount of a commodity associated with a NAICS sector, with respect to the total amount of that commodity. To get those total amounts associated with a NAICS sector, one needs to download *CF0700A18.zip* from [here](https://www2.census.gov/econ2007/CF/sector00/) to distribute for 2002 and 2007, and *CF1200A18.zip* from [here](https://www2.census.gov/programs-surveys/cfs/data/2012/) to distribute for 2012. That is the origin of `0-Raw_Data/CFS/NAICS to CFS Crosswalk.xlsx` and `0-Raw_Data/CFS/CFS_2012_00A18_with_ann.csv`, respectively..

## Revenue by state-industry and expenditure by state
To construct the gravity system for services, script 4 uses BEA's expenditure by state (SAEXP1) and GDP by state and industry (SAGDP2). Due to new estimations, the versions of these data sets that we have used are not available in the main BEA's Regional Accounts page anymore. However, they can still be found as archived releases. To get `0-Raw_Data\Expenditure\SAEXP1_1997_2017_ALL_AREAS_.csv`, download it from [here](https://apps.bea.gov/regional/histdata/releases/1018pce/index.cfm); and to get the collection of `0-Raw_Data\SAGDP\SAGDP2N_ .csv` files, download them from [here](https://apps.bea.gov/regional/histdata/releases/0519gdpstate/index.cfm).

## Agriculture and fish revenue
To construct the gravity system for sector 14, script 5 uses USDA's Agriculture Census data; specifically, *Table 2. Market Value of Agricultural Products Sold Including Landlord's Share and Direct Sales: 2007 and 2002*, which can be downloaded from [here](https://agcensus.library.cornell.edu/census_parts/2007-united-states/); we simply put the data in .csv format to create `0-Raw_Data\Agriculture_Census\data_agriculture.csv`.

For the same purpose, script 5 also uses NOAA's data. To be precise, to create `0-Raw_Data\Agriculture_Census\fish_raw.xlsx`, we join the *U.S domestic landings, by region and by state* tables of each year's (from 2000 to 2007) *Fisheries of the United States Full Report*, which can be found [here](https://www.fisheries.noaa.gov/national/sustainable-fisheries/fisheries-united-states#previous-reports). Then, we process our file running `0-Raw_Data\Agriculture_Census\fish_production.do`, to get a cleaner version as  `0-Raw_Data\Agriculture_Census\data_fish.csv`.

## Data for value added shares

To construct value added shares, script 6 needs BEA's GDP (SAGDP2), subsidies (SAGDP5), and taxes (SAGDP6) by state and industry. Due to new estimations, the versions of these data sets that we have used are not available in the main BEA's Regional Accounts page anymore. However, they can still be found as archived releases. To get the information contained in the collection of `0-Raw_Data\Labor_shares\gdp_state_.csv` files, `0-Raw_Data\Labor_shares\gdp_state_.csv` files, and `0-Raw_Data\Labor_shares\gdp_state_.csv` files, download the .zip folder from [here](https://apps.bea.gov/regional/histdata/releases/0519gdpstate/index.cfm), and select, respectively: `SAGDP2N__ALL_AREAS_1997_2018.csv`, `SAGDP5N__ALL_AREAS_1997_2017.csv`, and `SAGDP6N__ALL_AREAS_1997_2017.csv`.

## Data for labor shares by sectors

To calculate our exposure measures, script 7 needs labor shares by state and sector. We calculate one version of labor shares using Census Bureau's data without person weights. We use the 5 % sample PUMS files of the 2000 Census. These files are available [here](https://www.census.gov/data/datasets/2000/dec/microdata.html). One needs to open the folder *All additional files for the PUMS 5-Percent Dataset* and download the file *PUMS5.txt* within each state's folder. These files are the content of our `0-Raw_Data\CENSUS_2000\PUMS5` folder (look at the penultimate section of this ReadMe file for more detail). However, for Alabama the PUMS5 file (`PUMS5_01.txt`) was incomplete. So we replace it with the corresponding REVISEDPUMS5 file (we rename it as `PUMS5_01.txt` to write an easier loop to import the files in script 7).

We also use other two versions of labor shares using BLS-BEA data and ADH data. The ADH shares are already stored in `1-Intermediate_Processed_Data/state_emp_2000.dta` at this point. However, to get this file, one must first run the scripts of the `0-Raw_Data\ADH_employment` folder first. And to calculate BLS-BEA shares, we use `0-Raw_Data/emp_SAEMP25S_BLS.csv`, which can be accessed from [here](https://apps.bea.gov/iTable/?reqid=70&step=1&acrdn=4#eyJhcHBpZCI6NzAsInN0ZXBzIjpbMSwyOSwyNSwzMSwyNiwyNywzMF0sImRhdGEiOltbIlRhYmxlSWQiLCI0Il0sWyJNYWpvcl9BcmVhIiwiMCJdLFsiU3RhdGUiLFsiMCJdXSxbIkFyZWEiLFsiWFgiXV0sWyJTdGF0aXN0aWMiLFsiLTEiXV0sWyJVbml0X29mX21lYXN1cmUiLCJMZXZlbHMiXSxbIlllYXIiLFsiMjAwMCJdXSxbIlllYXJCZWdpbiIsIi0xIl0sWyJZZWFyX0VuZCIsIi0xIl1dfQ==) (together with [this link]( (https://www.bls.gov/lau/rdscnp16.htm) for sector 0)


Flows (and levels) of workers
===========================================================================================

## Employment allocation in each country and sector for 1999 and 2000

Script 8 computes the employment level for each country and sector for year 1999 and year 2000 using ILO and SEA data. To get the necessary raw data, the steps to follow are:

1. Download ILO estimate country unemployment rates $u$ from [here](https://databank.worldbank.org/World-unemployment-rates/id/c5765b65#), selecting only our years and countries of interest; that is how we get `0-Raw_Data\CENSUS_2000\P_World unemployment rates.xlsx`. 
2. Download ILO estimates for country labor force participation rates $lfp$ from [here](https://rshiny.ilo.org/dataexplorer57/?lang=en&segment=indicator&id=EAP_2WAP_SEX_AGE_RT_A), selecting only "Total" rows and only for our years and countries of interest; that is how we get `0-Raw_Data\CENSUS_2000\EAP_2WAP_SEX_AGE_RT_A-filtered-2023-11-02.csv`.

3. Employment for sectors 1-14 for each country are taken from WIOD's Socio Economic Accounts (SEA). We download SEA's release of July 2014 in Excel format from [here](https://www.rug.nl/ggdc/valuechain/wiod/wiod-2013-release?lang=en). 
The only variable of interest is EMP (number of persons engaged in thousands); after reclassifying it into our 1-14 sectors, we get our `0-Raw_Data\CENSUS_2000\L_1999_2000_countries.csv` file.

## Employment allocation in each state and sector using CBS data

Script 8 calculates the employment allocation in each state and sector for 2000 using CBS data.  To get the necessary raw data, the steps to follow are:

1. Download the employment, unemployment and non-participation levels for each state in year 2000 that CBS published based on the 2000 Decennial Census. The file is entitled *Table 1. Employment Status of the Population 16 Years Old and Over in Households for the United States, States, Counties, and for Puerto Rico: 2000*. Download the revised Excel file; it can be accessed [here](https://www.census.gov/data/tables/2000/dec/phc-t-28.html). That is our `0-Raw_Data\CENSUS_2000\employment_2000.xls`.

2. However, the data from the previous step does not include distribution of workers by sectors. To gather such disaggregation, we use the 5 % sample REVISEDPUMS files of the 2000 Census. These files are available [here](https://www.census.gov/data/datasets/2000/dec/microdata.html). One needs to open the folder *All additional files for the PUMS 5-Percent Dataset* and download the file `REVISEDPUMS5.txt` within each state's folder. Also, note that the variable dictionary for the census data is located in the same link and is entitled `5%_PUMS_record_layout.xls`. Note that each observation is compressed in a single line to save space. Therefore, the variables of interest have to be created using start and stop character positions.  For more information regarding the NAICS industry codes used in the census sample files, see p. 547 [here](https://www.census.gov/prod/cen2000/doc/pums.pdf). The most updated version of the previous NAICS table can be found [here](https://www2.census.gov/programs-surveys/cps/methodology/Industry Codes.pdf). Whenever available, we use NAICS codes instead of Census Industry codes, and then recode them to final sectors.
In the 2000 census sample we only keep observations type "P" (persons) with age in between 25 and 65, and that are employed. Non-participation will be considered an extra sector: sector 0. The "employment" for sector 0 is taken directly as the reported value of non-participants for each state in `0-Raw_Data\CENSUS_2000\employment_2000.xls`; to construct the other 14 sectors, NAICS sectors are recoded into our final sectors and we apply a proportionality rule (using person weights instead of respondents) with respect to the population employment levels by state. 

## Employment allocation in each state and sector using BLS data

Script 8 also computes the employment level for each state and sector for 1999 and 2000 using BLS data. To get the necessary raw data, the steps to follow are:

1. Download BLS' *annual average industry-specific NAICS-Based Quarterly Census of Employment and Wages by state* (for 1999 
and 2000) or, from now on, QCEW, [here](https://www.bls.gov/cew/downloadable-data-files.htm). QCEW datasets take values at the state-level and at the county-level; for each NAICS (sub-)sector we take the values at the state level. That is the content of the `0-Raw_Data\L_1999\Sectors\sector_` and `0-Raw_Data\L_1999\Sectors\sector_` folders.

2. To calculate sector 00, download BLS' *Employment status of the civilian noninstitutional population, Annual Average Series* (for 1999 and 2000) [here](https://www.bls.gov/lau/rdscnp16.htm). The result is our `0-Raw_Data\staadata.xlsx` file.

## Migration flows using ACS, CPS, and IRS data.

Finally, script 9 uses ACS, CPS, and IRS data to calculate migration flows between sectors and states.

The American Community Survey (ACS) Public Use Microdata Sample (PUMS) files provide details of workers' current employment status, sector, and state. It also asks the state in which respondents lived the prior year. However, this survey does not provide information regarding people's employment status and sector in the previous year. 
Therefore, as a second component of our calculations, we use the Current Population Survey (CPS), which provides details of people's employment status, industry sector and state for each month from 1999 to 2007. However, this survey does not provide information regarding movements across states. Thus, we combine both the ACS and the CPS surveys to compute the labor transitions across states and sectors every year. 

Steps to follow:

1. The ACS PUMS csv files can be downloaded from the FTP server in [here](https://www.census.gov/programs-surveys/acs/microdata/access.html). Within the FTP server, open the (1 year ACS) folders for the years 2000-2007 and download the files titled *csv_p{state}.zip*. That is the content of our `0-Raw_Data\ACS\year` folders.There is no need to change the name of the downloaded csv files after decompressing the zip files.
The survey's variable dictionary can be accessed through this [link](https://www2.census.gov/programs-surveys/acs/tech_docs/pums/data_dict/PUMSDataDict06.pdf) and the questionnaire through this other [link](https://www2.census.gov/programs-surveys/acs/methodology/questionnaires/2020/quest20.pdf). It is important to note that the state of origin variable changed its categories in 2003 (this issue is corrected in code). 

2. We only keep observations with age in between 25 and 65, and that are either employed, unemployed or not in the labor force; each observation has a person weight that comes with the survey. Unemployment plus not in the labor force will be considered an extra sector: sector 0 (this is inconsistent with script 8, which only includes non-participants in sector 0; script 8 has the classification we ultimately want to keep: we will correct script 9 in future revision). 
We convert NAICS sectors into the final sectors of our paper. Following CDP (2019) advice, in order to estimate the transitions more precisely, we use not only the annual changes of each year of interest but also the ones from the two following years. Hence, three lists of changes are seen now as annual changes for the year of interest. The current sector, current state, and previous year state are used to compute partial transition matrices with state of origin and destination and destination sector (as we said earlier, there is no information about the sector of origin in the ACS data). 

3. CPS data is stored in `0-Raw_Data/CPS/CPS_NBER/Inputs/cps_panel.dta`. To obtain it, the next steps must be followed:
a) Login to [IPUMS CPS site](https://cps.ipums.org/cps/)
b) Create an account at the *Register* option. 
c) Go to *Data*->*Browse and select data*
d) Select the samples. It is important to select the cross-sectional format and unselect the ASEC supplement. Go to the monthly based section and select the desired months of each year.
e) Click *Submit sample selections*. 
f) Select the variables (for Household and Person): The core variables selected for the creation of the base were: year, serial, month, hwtfinl, cpsid,	asecflag,	mish, numprec, statefip, nfams,	hrhhid,	hrhhid2, hhrespln, pernum, wtfinl,	cpsidv,	cpsidp,	age, sex,	race,	marst, popstat,	bpl, nativity, empstat, labforce,	occ, and ind. 
g) Go to view cart and create the data extract. The variable *mish* is important because it identifies the month in a survey at the household level.
h) Download the data extract in a .dta format.

4. The CPS surveys households in a 4-8-4 format; that is, it interviews the household for 4 consecutive months, gives them an 8 month break and interviews them again for 4 consecutive months. Also, a new household can start the 4-8-4 sequence any month of the year. Since the CPS data comes in a monthly frequency and we are interested in workers' movements across time, we have to match households and individuals across time. Each household ID is a concatenation of 4 variables (see code). However, this ID suffers a simplification in May-2004, which makes automatic matches harder around that period. The necessary adjustment is detailed in the new dictionary and implemented in the code; basically, the new household ID is the previous one with some specific digits taken out. Persons within a household do not have a unique ID, therefore, one is created for them using the household ID and the person's age and gender.

5. We only keep observations with age in between 25 and 65, and that are either employed, unemployed or out of the labor force; each observation has a person weight that comes with the survey (specifically, the one named: *Weight-composited final weight: Person's final composited weight. Used to tabulate BLS's official published labor force statistics*). Again, unemployment plus not in labor force will be considered sector 0 (again, not being consistent with script 8). CPS uses Census industry codes instead of NAICS, so, a different recoding is applied to convert them to the final sectors of interest. Also, the Census industry codes were updated in 2003 and changed positions in the variable dictionary. For more information regarding the Census industry codes changes see [link](https://www.bls.gov/cps/cpsoccind.htm); the old and new codes can be accessed  [here](https://www.nlsinfo.org/sites/nlsinfo.org/files/attachments/12124/NLSY97 1990 Census I and O codes.pdf) and [here](https://www2.census.gov/programs-surveys/cps/methodology/Industry Codes.pdf).

5. We match CPS observations (individuals) across time using the interview number. Each of the first 4 monthly interviews are 12 months apart from the final 4 interviews, and the first four and final four are consecutive in months. We are interested in recording annual changes for each year. That is why worker movements' information is gathered using the following interview matching system: (1,5), (2,6), (3,7) and (4,8). The latter is equivalent to following each individual for twelve months. To avoid double counting, we use only the match of the first and fifth interview: (1,5). The annual change observation is assigned to the respective year of the base month of the change. 
Following CDP (2019) advice, in order to estimate the transitions more precisely, we use not only the annual changes of each year of interest, but also the ones from the two previous and following years. Five lists of changes are seen now as annual changes for the year of interest. These matches, together with each person's information about past and current state and sector make it possible to compute changes in the labor allocation across time. The CPS survey does not account for movements across states and that is why we still need the ACS values. We follow CDP's  assumption that interstates movements ($i$ to $j$) across sectors follow the same pattern that intrastate movements in state $j$ across sectors. 

6. If a diagonal value (same state and sector in origin and destination) is zero, it is recoded as the minimum non-zero diagonal value of that year. 

7. Finally, we use a proportionality rule to make our migration flows sum up (over sectors of origin and destination) to the state-state flows of IRS, which can be downloaded from [here](https://www.irs.gov/statistics/soi-tax-stats-migration-data) (specifically, the .zip folder for County-to-County Migration Data from 1999 to 2000). After running `0-Raw_Data\IRS\1999to2000CountyMigration\process_raw_1999to2000CountyMigration.do` to process the state-state migration flows, we end up with our `0-Raw_Data\IRS\1999to2000CountyMigration\1999to2000flow.dta`.

Note: Raw data not in GitHub
============================================================================================
1) For script 3: `0-Raw_Data/CFS/CF1200A24.csv`  was too heavy, so it was compressed in a .zip folder with the same name; it must be taken out of the folder to run the script.
2) For script 5: the collection of `0-Raw_Data/CENSUS_2000/PUMS5/PUMS5_` .txt files for each US state was too heavy to be uploaded. The same comment applies to script 8 and the collection of `0-Raw_Data/CENSUS_2000/REVISEDPUMS5/REVISEDPUMS5_` .txt files.
3) For script 9: the collection of `0-Raw_Data/ACS/20*/c2ssp**.csv` .txt files for each US state was too heavy to be uploaded.
4) For script 9: `0-Raw_Data/CPS/CPS_NBER/Inputs/cps_panel.dta` was too heavy to be uploaded.
