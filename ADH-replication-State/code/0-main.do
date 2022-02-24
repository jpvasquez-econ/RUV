* Main file ADH (2013) replication at the State Level

/*
* Prepare the raw CBP 1980
do clean_cbp_1980

* Prepare the raw CBP 1990
do clean_cbp_1990

* Prepare the raw CBP 2000
do clean_cbp_2000

* Append CBP datasets
do append_cbp
*/

* using David Dorn's data for employment shares
do append_jp

* Change directory
cap cd "../../code"

* Calculates the import changes to USA and other rich countries from China 
* by sector and year

do import_chg

* Calculate ten-year equivalent percentage change in working age population by 
* state and year 
do calculate_log_chg_workage_pop

* Create IPW and its instrument
do create_ipw_and_instrument

* Aggregate main controls at the state level and merge
do aggregate_main_controls

* Run regressions of interest
do reg_of_interest_adh
