# Covid19-Analysis---a-SQL-Tutorial

This repository is a notebook showing basic SQL commands and how to apply them in an analysis. My gratitude to @AlexTheAnalyst for dedicating his efforts to show how to execute the steps on his Youtube channel. Link to his Youtube video can be found here: https://youtu.be/qfyynHBFOsM. The dataset of COVID-19 can be found here: https://ourworldindata.org/covid-deaths
However, in this notebook, I’ve made necessary changes in the script to better suit with the SQL Server version at the time I’m writing this repository.
During my analysis, I’ve identified key technical issues that either not existed in Alex’s version by the time he made the video, or there hasn’t anyone explained the cause. I have spent 5 hours figuring out either solutions, causes, or workarounds to these problems. Hopefully anybody who read this can apply to their own or better yet, improve the solutions.

1.	Importing data into SQL Management Studio

A very popular problem that now has the workaround. But any amateur who face this might spend at least 2 hours trying to implement that workaround, not to mention the times it takes to uninstall and reinstall the programs.
A quick description of the issue: Import the excel file into your SQL Management Studio, and you see this message:

“The 'Microsoft.ACE.OLEDB.12.0' provider is not registered on the local machine. (System.Data)”

In other words, it says that Microsoft Access Engine Database 2010 is not in your laptop.

But after installing the program, the message keeps popping up every time. So why is that?
After spending hours reading every post on similar issue, my conclusion is that the import wizard of SQL Management Studio (for now let’s call it SQL interface) is 32 bit, even if the interface is programmed for 64-bit. Hence, you cannot import your 64-bit excel file with the 32-bit wizard.

So how to solve this? 

First, install the required program into your computer. Link to the download is here: https://www.microsoft.com/en-us/download/confirmation.aspx?id=13255

Next, open your Windows Search and look for SQL Server Import and Export Data (64-bit), you’ll be able to import your excel file into the SQL Server.

2.	SQL Server cannot find table

This problem emerges when I tried to change data type using the command ALTER TABLE. Since SQL Server only searches on its default database, it will be unable to locate the table on the database you’re working on.
To solve this, use the command USE <databasename>. This will specify the database for SQL to look into, thus locate your table. You can also use this command to specify the database you want to place your view in.

3.	NULLIF to combat 0 division

Simple math, nothing can be divided by 0. Whenever I create a calculated rate, which the denominator column contains values of 0, SQL will stop generating results, leading to inaccurate calculations.

Hence, NULLIF. NULLIF is a function that generate NULL value to a data cell if it’s equal to a declared value. In my case, I use NULLIF(new_cases,0) to alter the data cell to NULL values whenever there is the value of 0 in that cell.

4.	Difference between BIGINT and INT
   
You’d be surprised to see this one day. Converting a “special” numerical column with nvarchar(225) data type into int, and you’ll see the following message:

“Arithmetic overflow error converting expression to data type int.”

This means your column contains a number too big to contained in an int data type. Remember, int can only contains numbers from -2,147,483,648 to 2,147,483,647, so population number easily bypasses this range.
Which means bigint is the solution. This data type can contain values from -9,223,372,036,854,775,808 to 9,223,372,036,854,775,807. It will cost more memory, sure, but it allows you to make calculation for big numbers.

To do this, either use ALTER TABLE + ALTER COLUMN commands, or include in your SELECT query CAST (your_column as BIGINT), and problem solved! The cast function will alter the data type permanently, so you don’t have to worried about changing the column’s data type again.

Another solution, which I don’t recommend, is to use interactive change. To do this, first click on Tools on the top left bar, then Options, then Designers on the left-hand edge menu. You will find an option that is “Prevent saving changes that requires table re-creation”. Then go back to the database, select the column within table, right-click and choose “Modify”. There you can change the data type to your desire. This option, albeit convenient, risks security as another person sharing the database can change the data type and damage the table as they recreate without notice.

And those are all the issues I’ve found. Hope anyone read this can use this to solve their own problem. Although this notebook is just a revision file for my SQL skills, the dataset of COVID-19 is very interesting with lots to explore. I will delve deeper into this and post my own findings in the future!
