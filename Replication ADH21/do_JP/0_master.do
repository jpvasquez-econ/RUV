/*******************************************************************************

	MASTER DO-FILE FOR
	On the persistence of the China Shock
	
*******************************************************************************/

* PRELIMINARIES

* Set paths
cd "/Users/renelivas/Dropbox/China-Robustness/Brookings-Drafts/Brookings/Replication"
global data		"data"
global do		"do"
global output	"output"

* Packages
ssc install ssaggregate
ssc install blindschemes
set scheme plotplainblind
ssc install spmap
ssc install shp2dta
ssc install mif2dta
ssc install maptile
maptile_install using "http://files.michaelstepner.com/geo_cz1990.zip"
net install grc1leg, from("http://www.stata.com/users/vwiggins/") 

* Log file
cap log close
log using "log.smcl", replace

*******************************************************************************
* FIGURES AND TABLES
*******************************************************************************

* Figures 1 and 2
do "${do}/1_bpea_analysis_agg_trade.do"

* Figure 3
do "${do}/2_bpea_analysis_seasia.do"

* Figures 4 and 6
do "${do}/3_map_2000-2019.do"

* Figures 5, 7, 8, 9, 10, A3, A4, A7, A8, and A9
* Tables 1, A1, and A2
do "${do}/4_jorda_annual.do"

* Figure 11
do "${do}/5_bpea_SIC12.do"

* Figure 12
do "${do}/6_coal.do"

* Figure 13
do "${do}/7_great_rec.do"

* Figure 14
* Table A4
do "${do}/8_welfare_impacts.do"

* Figure A1
do "${do}/9_pretrends_cz.do"

* Figure A2
do "${do}/10_BHJ_annual.do"

* Figures A5 and A6
* Table A3
do "${do}/11_ACS_annual.do"

*******************************************************************************

log close
