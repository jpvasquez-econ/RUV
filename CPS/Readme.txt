This file documents the extraction process of the data file called cps_panel. 
-The main input is the database in panel format: cps_panel.
-The Dofile cleaning_data generates the next outputs:
1-clean_data
2-data_base_14
3-data_base_15
4-data_base_weights (main output)
5- weights4
6-weights5
----------------------------------------------------------------------------------------
The Current Population Survey (CPS) is a monthly survey with a 4-8-4 sample methodology:|
----------------------------------------------------------------------------------------
-An individual is tracked for 4 months, rested for 8, and tracked again for 4 months. 
-Matching individuals across more than 2 months is a difficult task due to the non-existence of a unique household ID. 
-Some instructions on how to create longitudinal data can be found at:
https://www.nber.org/research/data/current-population-survey-cps-supplements
https://boreas.urban.org/documentation/input/Concepts%20and%20Procedures/CPSMatchingSurveys.php


-For this reason, the IPUMS CPS project is currently in charge of generating the data and generating the match between the data.
To obtain the panel, the following steps must be followed:
1-Login to IPUMS CPS site:
https://cps.ipums.org/cps/
2-Create and account at the register option. 
3-Go to data->browse and select data
4-Select the samples:
-It is important to select the cross-sectional format and unselect the ASEC supplement. 
-Go to the monthly based section and select the desired months of each year.
5-Click the submit sample selections. 
6-Start the select variable process:
-Household
-Person
-The most important variables are those related to technical properties like the weights and the linking variables. 
-The variable mish is important because it identified the month in a survey at a household level.
-The core variables selected for the creation of the base were: 
year, month, hwtfinl, mish, cpsid, age, sex, race, popstat, bpl, statefip, ind, wtfinl, cpsidp cpsidv, nativity, labforce. 
7-Go to view cart and create the data extract.
8-Download the data extract in a dta format.
-------------------------------------
Data dictionary:                    |
-------------------------------------
The information about the variables available in each sample, together with variable codes, descriptions, and discussions of universes and comparability issues can be found here:
https://cps.ipums.org/cps-action/variables/group
The linking variables:
cpsid: A unique identifier at a household level
cpsidp: A unique identifier at a personal level
cpsidv: An alternative unique identifier for the person across months.
The explanation of the identifier creation, harmonization, and the linking process documentation can be found here:
https://cps.ipums.org/cps/cps_linking_documentation.shtml

-------------------------------------
The data cleaning process:           |
-------------------------------------
Despite the high-quality standards followed by IPUMS, there are some false positive problems that need to be reviewed. 
The hit rate is approximately 70% from year to year, which decreases as more years are added to the sample.
-The Dofile document tries to identify and evaluate as many false positives as possible. 
-It also recodes variables like the IDs in a better format. 
-Robustness checks are made by: sex, race, nativity, popstat, age, bpl. 

The most cumbersome step is the harmonization of sectors between the variable coded as ind and the NAICS classification.
The variable ind presents a desegregated classification between industries. 
The harmonized variable between CPS and NAICS is available after 2000.

The NAICS industry classification can be accessed from this link:
https://www2.census.gov/programs-surveys/cps/methodology/Industry%20Codes.pdf

The CPS industry classification can be accessed from here 1992-2002:
https://cps.ipums.org/cps/codes/ind_19922002_codes.shtml

The dictionary to append both clasifications can be found here:
https://usa.ipums.org/usa/volii/indtoindnaics18.shtml

It is important to aggregate the sectors after that in the 14 NAICS categories. 
Considerations:
sector==0 if unemployed or out of labor force. 
sector==14 is agriculture
The others sectors are explained at this paper:
https://jpvasquez-econ.github.io/files/NK_trade.pdf
Appendix B2. 
------------------------
   Creating weights    |
-----------------------
The final process is documented in the do.file. 
The main interest is to calculate the shares of people migrating from sector A to B at a determined time of the survey. 
It is important to keep only observations between 25 and 65 years. 
The two main shares are calculated taking into consideration the observed sector at moment t=1 vs t=4 and t=5 vs t=8
-Strategy:
-Define the origin sector in t=1 and the destination in t=4, same for t=5 and t=8
-create clean_data.dta with interest variables: id month mish statefip ind sector sector_origin at t=1, t=4, t=5 and t=8 and sector_destination at  t=1, t=4, t=5 and t=8.
-generate the sum of the weights at every interest period, first for people migration at t=1 to t=4 and then for t=5 to t=8
-generate the share14 and share58
-This process will result in the creation of two specific weights databases:
-weights4
-weights8
-The final step is merging the databases to the clean_data in order to fullfil the weights for every-observation into the database. 
-The final base is called data_base_weights= merge(weights4, weights8) to clean_data.dta



-----------------------
Longitudinal data set  |
-----------------------      
The data set called clean_data_yearly.dta presents a longitudinal match of the march records between years. 
The compared years are: 
-97 vs 98
-98 vs 99 
-99 vs 00
-00 vs 01 
-01 vs 02 
The records of the March supplement were used for this linking:
The Annual Social and Economic Supplement (ASEC) of the CPS is unique among CPS data files even if it is the most popular of the CPS data. 
The ASEC includes all March Basic Monthly Survey respondents as well as oversamples from other months (see more information on oversamples).

The variables stayed the same but the linking process varies. 
The original dataset is presented in a wide format. 
The Do called longitudinal_cleaning documents the main robustness checks of the sample and the reshaping process into a long variable. 
The wtfinl_long represents the final longitudinal weight for that sample. 
The wfinl_period represents the weight for that record in the given period. 
Every individual must have at most 2 records in the survey and at leat 1, therefore the file represents and unbalanced panel. 
The rest of the variables stayed the same. 

