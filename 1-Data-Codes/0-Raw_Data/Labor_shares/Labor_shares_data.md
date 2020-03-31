### Constructing "Labor Shares"

We need to compute the share of value added in gross output the 50 for US states.  We can obtain data on sectoral and regional value added for the US from the Bureau of Economic Analysis (BEA). The final output would a matrix 50 $\times$ 14 with the shares of value added in gross output for each state, for each sector. Let's focus on the year 2000.

- Value added for each of the 50 U.S. states and 14 sectors can be obtained from the Bureau of Economic Analysis (BEA) by subtracting taxes and subsidies from GDP data 
- Gross outputs for each region $i$ is just $Y_{i,k}= \sum_j X_{ij,k}$ 
- In a few cases, gross output might be smaller than value added (probably due to some small discrepancies between trade and production data, etc). In such cases, just constrain value added to be equal to gross output. 
