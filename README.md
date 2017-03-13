
# Exploratory-Summary
SAS code that creates an exploratory summary of a dataset.  Especially effective for large data files.

READ ME for Exploratory Summary Project

by A. Brignole Feb - March, 2017

New technologies have made the acquisition, storage, and availability of electronic data commonplace. Publicly accessible databases and datafiles often consist of several thousands, if not millions or billions of rows for several hundred or thousands of different variables or columns. While acquisition, storage, maintenance, and availability approaches costlessness, the resources to mine and analyze the data has not kept pace. 

As a data analyst myself, I routinely encounter data that consists of millions of rows and hundreds of columns. The first step I typically take after reading in a large datasets is to summarize the data. Many prefer to plot their data. My problem is that scatter plots often appear as large, uninterpretable clouds, and boxplots with several hundreds categories are too difficult to read. Univariate plots, such as histograms, work well, but to sieve through several hundred plots is not efficient.

So, I summarize the data. This permits me to evaluate the dataset for data quality, check for potential outliers, and figure out what variables are present. The program R has the str() function which is one simple way to get an overview of the variable names, variable class, and a few of the values in the dataset. SAS is my standard tool for data analysis. To my knowledge, SAS does not have a comparable function. The STR() function in SAS is unrelated to the function in R: its serves as means for SAS to read special characters. SAS does have equivalent procedures (e.g.: MEANS, FREQ, TABULATE, and SQL) that allow for a similar evaluation of the data.

Which leads me to this project... The code in the Exploratory Summary Project should work on most datasets. The program begins running the CONTENTS procedure. It then checks for missing values. Subsequently, the data is divided into three different types: numeric, date, and character. Each of these is summarized separately. A seven number summary is run for numeric and date data types. For the character data types, a summary consisting of the most frequent and least frequent values are shown. Variables with fewer than 20 values are also summarized with frequency procedure.

This project certainly has areas where it could be improved. SAS has other date formats which weren't considered here. I expect that the program may be customized according to desired specifications.

Hopefully, you may find some use for this code as well.

Regards,
Andrew

