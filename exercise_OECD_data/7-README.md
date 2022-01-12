# 7-Readme		

Main changes and updates to this code.

- We now use ACS for years: 2015-2019
- We now use CPS for years: 2013-2020
- The employment base vector L_2018 is now computed using Census state population and ACS-2018 for distribution across sectors. Later we add country employment by sector.
- We now compute other L vectors backwards (base/start 2018), and so, we first use mobility matrices that sum to one for each column and only later we compute the standard mu matrices with rowSums=1 
- For country employment by sector we use ILO country employment 2015-2018 and distribute across sectors using WIOD-SEA 2014.
