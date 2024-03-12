--Project on EconomicInsight of Countries
Go
Create Database EconInsightDB
on primary
(
Name='EconInsightDB_Data_1',
FileName='C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\EconInsightDB_Data_1.mdf',
Size=25mb,
MaxSize=100mb,
FileGrowth=5%
)

log on
(
Name='EconInsightDB_Log_1',
FileName='C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\EconInsightDB_Log_1.ldf',
Size=2mb,
MaxSize=25mb,
FileGrowth=1%
)

------Use EconInsightDB-----
Use EconInsightDB;

---------Create Table----------
Go
----Country----

Create Table Country_(
Country_Id int primary key,
Country_Name varchar(50),
Population_ int,
Area_square_km int);

-----GDP-------

Create Table Gdp(
Gdp_id int Primary Key,
Country_id int  references Country_(Country_id),
Year_ smallint,
Gdp_value_Billion Float,
 );
 -------Inflation-------

Create Table Inflation(
Inflation_id int primary key,
Country_Id int References Country_(Country_id) ,
Year_ datetime,
inflation_rate Decimal(5, 2),
CPI Decimal(5, 1));

------Employment------

Create Table Employment(
Employment_Id  int,
Country_Id int References Country_(Country_id),
Year_ datetime,
employment_rate varchar(50),
Unemployment_rate varchar(50),
Foreign Key (Country_Id) References Country_(Country_Id));

------Trade-----

Create Table Trade_(
trade_id int primary key ,
Country_Id int References Country_(Country_id),
Year_ smallint,
Import_value_bil Float,
Export_value_bil Float
);

-------------------------AGGREGATE Function------------------
Go
-------COUNT only one cloumn Row------------
Select * from Country_
select Count(Country_Id) As TotalCountries
from Country_;


-------COUNT All Row------------
Select * from Country_
select Count(*) As TotalRows
from Country_;

------AVERAGE ------------
-- retrieving Average of 3 years of Bangladesh
Select * from Gdp
select  Avg(Gdp_value_Billion) As AverageOfBdOf3years
from GDP 
Where Country_id=1

-------Maximum ------------
select * from Country_;
select  Max(Area_square_km) As MaxArea
from Country_;


-------Minimum ------------
select * from Country_;
select Min(Population_) As Min_Population
from Country_;
 --------------------- CAST -------------------
 ----a float and divides by 1,000,000 to get the population in millions
 Select Country_Id, Cast(Population_ As float) / 1000000 As Population_Million
FROM Country_;
----  - --------------------------- FUNCTION-------------------------
          -------------- CASE Function ---------------
-----To find out population based on greater than 1 billion(Large) and 1 million (Small)
Select Country_Name, Population_,
CASe
When Population_ > 1000000000 Then 'Large'
When Population_ > 1000000 Then 'Medium'
Else 'Small'
End As Population_Category
From Country_;
          -------------- IIF and CHOOSE function ---------------
Select Country_Name, Gdp_value_Billion,
iif(GDP_Value_Billion > 1000, 'High', 'Low') As GDP_Status,
Choose(c.Country_Id, 'Bangladesh', 'India', 'Nepal', 'Sri Lanka', 'Maldives', 'Bhutan', 'Myanmar', 'Malaysia', 'Pakistan') AS Country_Name_Choice
From
GDP g Join Country_ c on g.Country_Id=c.Country_Id;
          -------------- COALESCE and ISNULL function ---------------
Select Country_Name, Coalesce (Inflation_Rate, 0) As Inflation_Rate_Coalesce,
Isnull(CPI, 0) As CPI_IsNull
From
Inflation i Join Country_ c on c.Country_Id=i.Country_Id;

  -------------Rank FUNCTION--------------------
 Select Country_Name, Population_, 
ROW_NUMBER() Over (Order By Population_ Desc) As RowNumber, 
RANK() Over (Order By Population_ Desc) As PopulationRank, 
DENSE_RANK() Over (Order By Population_ Desc) As DenseRank, 
NTILE(4) Over (Order By Population_ Desc) As PopulationGroup
From Country_;

  -------------Analytic Function--------------------
Select Country_Name,Population_,
FIRST_VALUE(Country_Name) Over (Order BY Population_ Desc) AS FirstCountry,
LAST_VALUE(Country_Name) Over (Order BY Population_ Desc) AS LastCountry,
LEAD(Country_Name) Over (Order BY Population_ Desc) AS NextCountry,
LAG(Country_Name) Over (Order BY Population_ Desc) AS PreviousCountry,
PERCENT_RANK() Over (Order BY Population_ Desc) AS PercentRank,
CUME_DIST() Over (Order BY Population_ Desc) AS CumulativeDist,
PERCENTILE_CONT(0.5) Within Group (Order BY Population_) Over () AS MedianPopulation,
PERCENTILE_DISC(0.75) Within Group (Order BY Population_) Over () AS Quartile3Population
From Country_;
Go
------------------------- MERGE Insert,Update------------------------
Create Table GdpCopy(
Gdp_id int Primary Key,
Country_id int  references Country_(Country_id),
Year_ smallint,
Gdp_value_Billion Float);

Merge Into GdpCopy As New_gdp
Using gdp As MainGdp
On (New_gdp.Gdp_Id = MainGdp.Gdp_Id)
When Matched Then
    Update Set
        New_gdp.Country_Id = MainGdp.Country_Id,
        New_gdp.Year_ = MainGdp.Year_,
        New_gdp.Gdp_Value_Billion = MainGdp.Gdp_Value_Billion
When Not Matched Then
    Insert (Gdp_Id, Country_Id, Year_, Gdp_Value_Billion)
    Values (MainGdp.Gdp_Id, MainGdp.Country_Id, MainGdp.Year_, MainGdp.Gdp_Value_Billion);

Insert into Gdp(Gdp_id,Country_Id, Year_, Gdp_value_Billion) Values
(12,9, 2031, 4106.3);

Select * from GdpCopy;

  ------------------------------ VIEW ------------------------------------
Create View Vw_RecordsGdp_country
As
Select c.Country_Id,c.Country_Name,Gdp_value_Billion 
from Gdp Join Country_ c 
On c.Country_Id=Gdp.Country_id;
Go
select * from Vw_RecordsGdp_country;
Go
------Insert
Insert into Vw_RecordsGdp_country(Country_Id, Country_Name,Gdp_value_Billion) values (12,'China',584);
Go
-----Alter with  Encryption-------------

Alter View Vw_RecordsGdp_country
With Encryption
As
Select c.Country_Id,c.Country_Name,Gdp_value_Billion 
from Gdp Join Country_ c 
On c.Country_Id=Gdp.Country_id;

Go
select * from Vw_RecordsGdp_country;
Drop VIEW Vw_RecordsGdp_country;
Go
 -------------------------------------------------STORED PROCEDURE ------------------------------------
 ----To Create Stored Procedure on Country without Parameter
 Create Proc SpCountrylists
 AS
 Select * From Country_ ;
  Exec SpCountrylists;
 Go
 --To modify the stored procedure
 Go
 Alter Proc SpCountrylists
 AS
 Select * From Country_ Where Country_Id=1;
  Exec SpCountrylists;
Go
 -----To drop the SpCountrylist
 Drop Proc SpCountrylist
 Go
 ---To Create Stored Procedure on Country with Parameter
 Go
 Create Proc SpCountrylist
 @Country_id int,
 @Country_Name varchar(50)
 AS
 Begin
 Select * From Country_ Where Country_Id=@Country_id;
 Select * From Country_ Where Country_Name=@Country_Name;
 End
  Exec SpCountrylist 1,'Bangladesh'
 --with input Parameter
 Go
 Alter Proc SpCountrylist
 @Country_id int=2,
 @Country_Name varchar(50)='Bangladesh'
 AS
 Begin
 Select * From Country_ Where Country_Id=@Country_id;
 Select * From Country_ Where Country_Name=@Country_Name;
 End
 Exec SpCountrylist
Go
 ----Output Parameter
 Create Proc GetTotalGDP
 @GDP_Value_ varchar(200),
@TotalGDP int Output
As
Begin
Select @GDP_Value_=Sum(Gdp_value_Billion) From Gdp ;
End
Declare @TotalGDPResult int;
Exec @GDP_Value_  @TotalGDP output
Go
Drop Proc GetTotalGDP
 -------------- - User-Defined Function  ------------
 ---Saclar value Function
 -- to create function on the total of import and export value
Go
 Create Function GetTotal
 (@Country_id int)
 Returns int
 AS
 Begin
 Declare @Reasult int;
  Select @Reasult=(Export_value_bil+Import_value_bil) from Trade_ Where Country_Id=@Country_id;
  Return @Reasult
 End
 Go
 Select Country_Id,Export_value_bil,Import_value_bil,dbo.GetTotal(Country_Id) AS Total from Trade_;
 --- single table Function
 GO
Create Function GetCountryData()
Returns TABLE
As
Return
(Select * from Country_ );
Go

Select * from dbo.GetCountryData();

Go
 --Multi value Function
 Create Function GetTotalMulti
 (@Country_id int)
 Returns @Avg Table (Country_id int,Export_value_bil int,Import_value_bil int)
 AS
 Begin
	Insert @Avg 
	Select Country_id,Export_value_bil,Import_value_bil From Trade_ Where country_id=@Country_id
	Return;
 End;
 Go
 Select t.Export_value_bil,t.Import_value_bil from Trade_ t join dbo.GetTotalMulti(2) As Total on total.Country_id=t.Country_Id;
 Go
 --------Triggers--------------
 ----After Insert Triggers
 ----to execute after an INSERT operation on the Country table
 Create Table Audit_Trg (
Country_Id int,
Country_Name varchar(50),
Population_ int,
Area_square_km int);
 Go
Create Trigger Trg_country_insert
On Country_
After Insert
As
Begin
    Insert into Audit_Trg (country_id ,Country_name,Population_,Area_square_km)
    Select country_id,Country_name,Population_,Area_square_km from inserted
End;
Go
insert into Country_ values (10,'p',25,478)
Select * from Audit_Trg;
Select * from Country_

----Insert update Trigger
Go
Create Trigger Trg_country_update
On Country_
After Update
As
Begin
Insert into Audit_Trg (country_id ,Country_name,Population_,Area_square_km)
Select country_id,Country_name,Population_,Area_square_km from inserted;
End;
Go
Update Country_ set country_Name = 'China'  Where Country_id=10
Drop Trigger trg_country_insert
----Atfter Delete Trigger
Go
Create Trigger Trg_country_delete
On Country_
After Delete
As
Begin
Insert into Audit_Trg (country_id ,Country_name,Population_,Area_square_km)
Select country_id,Country_name,Population_,Area_square_km from deleted;
End;
Go
Delete From Country_ Where Country_Id=10
 ----instead of insert triggers---
Go
Create Trigger Trg_country_insteadofInsert
On Country_
Instead of Insert
As
  Begin
     Insert into Audit_Trg (country_id ,Country_name,Population_,Area_square_km)
     Select country_id,Country_name,Population_,Area_square_km from inserted;
  End;
 ----instead of Update triggers---
 Go
Create Trigger Trg_country_insteadofUpdate
On Country_
Instead of Update
As
  Begin
     Update Audit_Trg
	 Set Country_name=inserted.country_name,
	 country_id=inserted.country_id,
	 Population_=inserted.population_,
	 Area_square_km=inserted.Area_square_km
	 From Audit_Trg join inserted
	 on Audit_Trg.country_id=inserted.Country_Id;
  End;

  ----instead of Delete triggers---
 Go
Create Trigger Trg_country_insteadofDelete
On Country_
Instead of DELETE
As
  Begin
  Delete c from Country_  c
  Join Deleted on c.Country_id=deleted.country_id;
  End;
  Go
  -----------Instead of delete with error-----------------
Create Table Gdp_log(
LogId int Identity(1,1) NOT NULL,
BatchId int NULL,
Action varchar(50) NULL);
Go
Create Trigger Gdp_InsteadOfDELETE
On Gdp
Instead of Delete
As
Begin
Declare @Gdp_Id INT
Select @Gdp_Id = DELETED.Gdp_id   
from DELETED

If @Gdp_Id = 2
Begin
RAISERROR('The record cannot be deleted',16 ,1)
ROLLBACK

Insert Into Gdp_log
values(@Gdp_Id, 'Record cannot be deleted.')

End

Else
Begin
Delete  Gdp
Where @Gdp_Id = Gdp_id

Insert into Gdp_log
	Values(@Gdp_Id, 'Instead Of Delete')

End
End

select * from Gdp
select * from Gdp_log
 Delete  Gdp where Gdp_id=2



  -------------------------------------Alter-----------------------------------
  Alter Table Trade_ Add  Total_trade int;
  Alter Table Trade_ drop column Total_trade;

  -----------------------------------Drop-----------------------------------
Drop Table Employment;
Drop Database EconInsightDB;
