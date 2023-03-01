# ReadMe

We used ACS 1 year samples to replicate the ADH13 regression for the 2006-2020 period. For each year we used the reference year and the two neighbor years (e.g 2007 data is taken from pooled 2006-2008 ACS. We used ADH21 replication package code for presenting the graphs of coefficients through time. The outcome variables characterizing the labor market are simple and ten-year equivalent decadal changes of employment in manufacture, non-manuf employment, unemployment, and NILF. The outcomes are calculated as a share of working-age population. Following ADH13, people living in institutional quarters and unpaid family members were dropped. We then created downward nominal wage rigidity measures to interact the effects of China's trade shock on unemployment.

# Raw data

-   **right2work.dta:** Right-to-work laws by state were taken from [here](https://nrtwc.org/facts/state-right-to-work-timeline-2016/).

-   ACS data was taken from [here](https://usa.ipums.org/usa): We pooled the 2005-2021 ACS 1-year samples for people between 16 and 64 years of age. The name of this file is **ipums_2005_2021.dta** in the data file. A codebook file is available in **ipums_2005_2021_query.txt**. This document contains the query requested from the IPUMS USA webpage. A login is necessary to download the data. After an account is created, data can be downloaded from the "Select Data" window. The dataset was downloaded as a .dta for STATA.

-   **workfile_china.dta:** data taken from the replication package of ADH13, from the dta folder. This file contains the data to replicate the main results of the paper.

-   David Dorn's crosswalk files from PUMAs to CZ taken from his [webpage](https://www.ddorn.net/). The files are named **cw_puma2000_czone.dta** and **cw_puma2010_czone.dta.**

-   **CPS 1986-1990:** data taken from IPUMS CPS [webpage](https://cps.ipums.org/cps/). The file name is *cps_86_90.dta* The query if available in the file *cps86_90_query.txt*. We followed Yoon Joo Jo (2021) on the data processing procedures.

-   **Merged Outgoing Rotation Groups: 86-90:** this files are taken from [NBER](https://www.nber.org/research/data/current-population-survey-cps-merged-outgoing-rotation-group-earnings-data) webpage, from the "Stata dta files" link. This files are merged to the CPS to obtain hourly wage allocation flag variable.

-   **Jo_state_level_dnwr.dta**: dataset provided by Ms. Yoon Joo Jo from her paper "Establishing downward nominal wage rigidity through cyclical changes in the wage distribution" (2022)

# Codes

-   **1-ipums_acs.do** This dofile takes as an input the pooled 2005-2021 ACS 1-year samples, subsets 3-year samples, creates intermediate variables, and then merges the information to ADH2013's dataset workfile_china.dta.

-   **2-coef_graphs_decadal.do:** This code creates the outcome variables for manufacturing, non-manufacturing, nilf, and unemployment working population ratios. It then creates the coefficient graphs (figure 1 of technote1.pdf) for the period from 2006 to 2020. Outcome changes are in a ten-year equivalent form.

-   **3-cps1990_rigmeasures.do:** creates year-over-year wage change rigidity measures from the CPS 1986-1990 database following Joo-Jo,Y.(2022)

-   **4-yjj_rigidity_measures.do:** creates year-over-year wage changes rigidity measures from the CPS database of Joo-Jo,Y.(2022). Variables were constructed using the period from 1997 to 2000.

-   **5-dnwr_figures.do:** creates and saves the figures for the rigidity measures coefficient graphs.

-   **6-dnwr_tables.do:** creates and saves the tables of the rigidity measures pdf file.

-   **subfile_ind1990dd:** This dofile was taken from David Dorn's data [webpage](https://www.ddorn.net/data.htm). It recodes the ind1990 variable into ind1990dd. This crosswalk code helps replicate the classification of employment into manufacture and non-manufacture.
