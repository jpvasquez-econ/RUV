# US state-country trade database 	

The following steps detail how to obtain, download and create the US state-country trade database for the years 2002-2019 (imports as of 2008) with a 3 NAICS digit precision:

- Enter the [USA Trade Online](http://usatrade.census.gov/) website, register, log in and then click ACCESS DATA. At this point, the main page for extracting data will appear with the data selection options. 
- Choose **State Export Data (Origin of Movement)**: NAICS. Now, on the left side of the webpage the main sections to complete will appear, specifically: measures, state, commodity, country and time. 
- The measure of interest is Total Exports Value ($US). Select the first eleven states ranging from All states to Florida (11 states). Then, in Commodity section, select the check in the second column on the upper part; this will select all 3 digit NAICS categories but not their subsections; do not select the All commodities option. Within the country section select the check next to World Total and then unselect World Total itself. Finally, for the time section, select the check that belongs to the first column of the upper section; this will select all years but not their month subdivision.
- Generate the report through the option (REPORT) that resides on the left side of the WELCOME (NAME) sign.
- Download the data using the down green arrow option and choose to do it using a comma separated csv file. 
- Repeat the past steps but selecting the following 11 states on the list, specifically: Georgia-Maryland (11), Massachusetts-New Mexico (11), New York-South Dakota (11) and Tennessee-unknown (11). There is no need to exit the webpage to gather the next 11 states' information, just modify them in the State section. 
- Rename each downloaded file as State Exports by NAICS Commodities-i.csv,  $i\in \{1,2,3,4,5\}$       
- In order to proceed with the import data download choose the Data Source Selection option on the upper side.
- Choose **State Import Data (State of Destination)**: NAICS.
- The process is fairly similar with some exceptions. In measures, choose Customs Value (Gen) ($US).
- Rename each downloaded file as State Imports by NAICS Commodities-i.csv,  $ i\in \{1,2,3,4,5\}$ 

