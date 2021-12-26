# Data updating		

- The main objective is to construct yearly bilateral trade and mobility matrices until the most recent year possible.
- To do so, we need to update all data sources used before. One of the most important ones was the data from WIOD. The problem is that WIOD stops in 2014. Instead of that, we will use data from the OECD here: https://www.oecd.org/sti/ind/inter-country-input-output-tables.htm (**new download site given by ICIO-OECD team can be seen at the end of file**)
  - The initial goal would be to use this data for the years starting in 2014. But we might have to focus on this data starting in 2000. Let's start with figuring this part out (i.e. see if we can construct the block of the bilateral trade matrix that corresponds to country-country trade and how to proceed here.). No need to produce outputs at the beginning, just to understand what is possible.
  - The next step is to figure out what would happen to the remaining data sources (CFS, etc). 
  - One important aspect is that we would need to do a mapping of the sectors (it might be that the sectors are not the same in WIOD and in the OECD data)
  - Only once we are sure of the data availability we can proceed with the updating of the codes.





#############################################################################################

**ICIO-TiVA.Contact@oecd.org**

Thu, Dec 23, 5:23 PM 

Dear ICIO and TiVA users,

Due to unforeseen and persistent technical problems, the links from the [ICIO web page](http://oe.cd/icio) are not functioning.

To access and download the ICIO tables in CSV, XLS or R format:

\-     go to the “harmonised national Input-Output Tables” OECD.STAT cube: https://stats.oecd.org/Index.aspx?DataSetCode=IOTS_2021

\-     At the top of the page click on “Export”

\-     Choose “Related files”.  Here you should find five zipped files for each format.

We hope this helps.

Many apologies for any inconvenience caused.

Best regards,

The OECD ICIO/TiVA team 