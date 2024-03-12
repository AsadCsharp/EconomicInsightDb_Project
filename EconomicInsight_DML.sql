---------------------DML on EconOmic Insight Project-----------------------
Go
Use EconInsightDB

 --------------------------------INSERT---------------------------------------
		-----------Insert Country -----------
Insert Into Country_(Country_Id, Country_Name, Population_, Area_square_km) 
Values (1, 'Bangladesh', 165158616, 148460.00),
(2, 'India', 1428627663, 3287260.00),
(3, 'Nepal', 30547580, 147180.00),
(4, 'Sri Lanka', 21832143, 65610.00),
(5, 'Maldives', 523787, 300.00),
(6, 'Bhutan', 867775, 38394.00),
(7, 'Myanmar', 54179306, 676578.00),
(8, 'Malaysia', 33871431, 330803.00),
(9, 'Pakistan', 235824862, 881912.00);

select * from Country_;

			-----------Insert Gdp -----------
Insert into Gdp(Gdp_id,Country_Id, Year_, Gdp_value_Billion) Values
(1,1, 2021, 416.3),
(2,1, 2022, 460.2),
(3,1, 2020, 345.0),
(4,2, 2020, 3050.0),
(5,3, 2020, 31.22),
(6,4, 2020, 82.1),
(7,5, 2020, 5.81),
(8,6, 2020, 2.63),
(9,7, 2020, 79.95),
(10,8 ,2020, 358.8),
(11,9, 2020, 307.39);

select * from  Gdp;
				-----------Insert Inflation -----------
Insert into Inflation (Inflation_id,Country_Id, Year_, Inflation_Rate, CPI)
Values 
(1,1, '2020', 5.57, 263.4),
(2,2, '2020', 4.59, 120.4),
(3,3 ,'2020', 3.75, 138.6),
(4,4, '2020', 4.60, 134.8),
(5,5, '2020', 0.10, 100.1),
(6,6 ,'2020', 3.06, 146.3),
(7,7, '2020', 5.89, 204.2),
(8,8 ,'2020', -1.23, 122.1),
(9,9, '2020', 8.90, 142.9);
select * from Inflation;

					-----------Insert Employment -----------
Insert into Employment (Employment_Id,Country_Id, Year_, Employment_Rate, Unemployment_Rate)
Values
(1,1, '2020', '57.40%', '4.20%'),
(2,2, '2020', '38.20%', '6.10%'),
(3,3, '2020', '50.60%', '11.40%'),
(4,4, '2020', '45.30%', '5.70%'),
(5,5, '2020', '68.80%', '4.90%'),
(6,6, '2020', '69.40%', '2.40%'),
(7,7, '2020', '62.50%', '5.10%'),
(8,8, '2020', '69.90%', '4.50%'),
(9,9, '2020', '48.50%', '4.50%');

select * from  Employment;

						-----------Insert Trade -----------
Insert into Trade_(trade_id,Country_Id, Year_, Import_Value_bil, Export_Value_bil) 
Values
(1,1, '2020', 50.53 , 38.67 ),
(2, 2,'2020', 447.57 , 313.59 ),
(3,3, '2020', 10.57 , 1.15),
(4,4, '2020', 16.72 , 10.95 ),
(5,5, '2020', 2.04 , 216),
(6,6 ,'2020', 647 , 530),
(7,7 ,'2020', 16.56 , 15.35 ),
(8,8, '2020', 156.47 , 191.27),
(9,9 ,'2020', 55.37 , 23.14 );

select * from Trade_;
Go
 --------------------- Table Joining -------------------
Select C.Country_Name,gdp.Year_,
GDP.Gdp_value_Billion,
Employment.employment_rate
From Country_ c
Join GDP ON c.Country_Id = GDP.Country_Id
Join Employment ON C.Country_Id = Employment.Country_Id
Where
C.Population_ > 100000000;

--------------------Order BY---------------------
--- Order By Population 
Select i.Country_Id,Country_Name,Population_,Year_,Gdp_value_Billion From Country_ i Join Gdp On gdp.Country_id=i.Country_Id
Where year_ =2020 order By Population_ Desc;


-------------------ROLLUP-----------------------
---To find out Total GDP for each combination of Country_Id and Year_

Select c.Country_Id,Country_name, Year_, Sum(Gdp_value_Billion) As Total_GDP
From Country_ c Join Gdp On gdp.Country_id=c.Country_Id
Group By Rollup ( c.Country_Id,Country_name,Year_);


----------------CUBE--------------------
--To find out Total GDP for each combination of Country_Id and Year_and subtotals fro each indiviaduals and grand total
Select Country_Id, Year_, Sum(Gdp_value_Billion) As Total_GDP
From GDP 
Group By Cube (Country_Id, Year_);

-------------OVER--------------------
Select c.Country_Id,Country_Name, Year_,
    Sum(Gdp_value_Billion) Over (Partition By c.Country_name order By Year_ asc) As CumulativeInflation
From Gdp Join Country_ c On Gdp.Country_Id=c.Country_Id;


 --------------------- EXISTS-------------------
 ----all rows from the Country table where there is at least one matching row in the GDP
Select * From Country_
Where Exists  (
Select Gdp_id
From GDP
Where Gdp_value_Billion>300
);

 --------------------- NOT EXISTS-------------------
  ----all rows from the Country table where there is no matching row in the GDP
Select *
From Country_
Where Not Exists (
Select *
From GDP
);

 --------------------- ANY-------------------
 -- to retrieve any value From subquery, gdp more than 350
Select * From Gdp Join Country_ c On c.Country_Id=Gdp.Country_id
Where Gdp_value_Billion > Any (
Select Gdp_value_Billion
From Gdp
Where Gdp_value_Billion>350
);

 --------------------- ALL-------------------
 ---all rows from the Country table where the Population_ is greater than all Population_ values in the GDP table
Select * From Gdp Join Country_ c On c.Country_Id=Gdp.Country_id
Where Gdp_value_Billion > All (
Select Gdp_value_Billion
From Gdp
Where Gdp_value_Billion>200
);

 ---------------------AGGREGATE FUNCTION----------------

-----------------With GROUPING BY AND HAVING FOR SUMMARIZE DATA-------------------
---To find Total population and average area for countries with a population greater than 100 million
Select Country_Name, Sum(Population_) AS Total_Population, Avg(Area_square_km) AS Average_Area
From Country_
Group By Country_Name
Having Sum(Population_) > 100000000;

 --------------------- Subquery -------------------
 --To Find maximum GDP value and population greater than average
Select Country_Name,Population_,
(Select Max(Gdp_value_Billion) From  GDP Where Country_.Country_Id = GDP.Country_Id) AS Max_Gdp_Value
From Country_
Where 
Population_ > (Select Avg(Population_) From  Country_);

 ---------------------------------UNION------------------------------------------
 ---To find combined set of unique Country_Id and Country_Name.
Select Country_Id, Country_Name From Country_
Union
Select c.Country_Id, Country_Name
From GDP g Join Country_ c ON c.Country_Id=g.Country_Id ;

 

 ------------------------------CTE------------------------------------
 ---To find population greater than 50 million And a rank based on population
With TopCountries As (
Select Country_Name, Population_,
ROW_NUMBER() Over (Order BY Population_ DESC) As Rank_
From Country_
Where 
Population_ > 50000000 )
Select Rank_,Country_Name,Population_ From TopCountries
Where Rank_ <= 5 Order BY Rank_

 ------------------------------Recursive CTE------------------------------------
With Recursive_CTE As (
Select Country_Name,Population_,0 AS Level From Country_
Where Country_Name = 'India'
Union All
Select C.Country_Name,C.Population_,
Rc.Level + 0
From Recursive_CTE rc
Inner Join Country_ C ON Rc.Country_Name = C.Country_Name
)
Select Country_Name,Population_,Level
From Recursive_CTE 

	


