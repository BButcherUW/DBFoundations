--*************************************************************************--
-- Title: Assignment06
-- Author: BButcher
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,BButcher,Created File
-- 2025-03-01,BButcher,Wrote script
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_BButcher')
	 Begin 
	  Alter Database [Assignment06DB_BButcher] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_BButcher;
	 End
	Create Database Assignment06DB_BButcher;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_BButcher;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
/*
-- Vewing Column names in table
Select * From Categories
Select * From Products
Select * From Employees
Select * From Inventories;
GO

-- Updating Select statement to have column names
Select CategoryID, CategoryName From Categories
Select ProductID, ProductName, CategoryID, UnitPrice From Products
Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From Employees
Select InventoryID, InventoryDate, EmployeeID, ProductID, [Count] From Inventories;
GO
*/

GO
Create View [dbo].[vCategories]
With Schemabinding
AS
	Select CategoryID, CategoryName
	From dbo.Categories;
GO

Create View [dbo].[vProducts]
With Schemabinding
AS
	Select ProductID, ProductName, CategoryID, UnitPrice
	From dbo.Products;
GO

Create View [dbo].[vInventories]
With Schemabinding
AS
	Select InventoryID, InventoryDate, EmployeeID, ProductID, [Count]
	From dbo.Inventories;
GO

Create View [dbo].[vEmployees]
With Schemabinding
AS
	Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
	From dbo.Employees;
GO

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Deny Select On Catagories to Public
Grant Select On vCategories to Public
GO
Deny Select On Products to Public
Grant Select On vProducts to Public
GO
Deny Select On Employees to Public
Grant Select On vEmployess to Public
GO
Deny Select On Inventories to Public
Grant Select On vInventories to Public
GO

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!
/*
-- Finding columns
Select * From vCategories
Select * From vProducts;
GO
-- Narrowing to desired columns
Select CategoryName
From vCategories
Select ProductName, UnitPrice
From vProducts;
GO
-- Joining info
Select CategoryName, ProductName, UnitPrice
From vCategories as C
	Join vProducts as P
	On C.CategoryID = P.CategoryID;
GO
-- Ordering Info
Select CategoryName, ProductName, UnitPrice
From vCategories as C
	Join vProducts as P
	 On C.CategoryID = P.CategoryID
	Order By CategoryName, ProductName;
GO
*/

-- Creating View
Create View [dbo].[vProductsByCategories]
AS
	Select Top 1000000
		CategoryName,
		ProductName,
		UnitPrice
	From vCategories as C
		Join vProducts as P
		On C.CategoryID = P.CategoryID
	Order By CategoryName, ProductName;
GO


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!
/*
-- Finding columns
Select * From vProducts
Select * From vInventories;
GO
-- Narrowing to desired columns
Select ProductName
From vProducts
Select [Count], InventoryDate
From vInventories;
GO
--Joining
Select ProductName, InventoryDate, [Count]
From vProducts as P
	Join vInventories as I
	On P.ProductID = I.ProductID;
GO
-- Ordering Info
Select ProductName, InventoryDate, [Count]
From vProducts as P
	Join vInventories as I
	 On P.ProductID = I.ProductID
Order By ProductName, InventoryDate, [Count];
GO
*/
-- Creating View
Create View [dbo].[vInventoriesByProductsByDates]
AS
	Select Top 1000000
		ProductName,
		InventoryDate,
		[Count]
	From vProducts as P
		Join vInventories as I
		 On P.ProductID = I.ProductID
	Order By ProductName, InventoryDate, [Count];
GO


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth
/*
-- Finding columns
Select * From vInventories
Select * From vEmployees;
GO
-- Narrowing to desired columns
Select InventoryDate
From vInventories
Select EmployeeFirstName, EmployeeLastName
From vEmployees;
GO
-- Outcome wants employee name as one column, combining names
Select InventoryDate
From vInventories
Select Concat (EmployeeFirstName,' ',EmployeeLastName) as EmployeeName
From vEmployees;
GO
--Joining
Select Distinct InventoryDate, Concat (EmployeeFirstName,' ',EmployeeLastName) as EmployeeName
From vInventories as I
Join vEmployees as E
On I.EmployeeID = E.EmployeeID;
GO
-- Ordering Info
Select Distinct Top 1000000 InventoryDate, Concat (EmployeeFirstName,' ',EmployeeLastName) as EmployeeName
From vInventories as I
	Join vEmployees as E
	 On I.EmployeeID = E.EmployeeID
Group By InventoryDate, EmployeeFirstName, EmployeeLastName
GO
*/

--Creating View
Create View [dbo].[vInventoriesByEmployeesByDates]
AS
	Select Distinct Top 1000000
		InventoryDate,
		Concat (EmployeeFirstName,' ',EmployeeLastName) as EmployeeName
	From vInventories as I
		Join vEmployees as E
		On I.EmployeeID = E.EmployeeID
	Group By InventoryDate, EmployeeFirstName, EmployeeLastName
GO

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!
/*
-- Finding columns
Select * From vCategories
Select * From vProducts
Select * From vInventories;
GO
-- Narrowing to desired columns
Select CategoryName 
From vCategories
Select ProductName 
From vProducts
Select InventoryDate, [Count] 
From vInventories;
GO
--Joining
Select CategoryName, ProductName, InventoryDate, [Count]
	From vCategories as C
	Join vProducts as P
	ON C.CategoryID = P.CategoryID
	Join vInventories as I
	On P.ProductID = I.ProductID;
GO
--Ordering Info
Select CategoryName, ProductName, InventoryDate, [Count]
	From vCategories as C
	Join vProducts as P
	 ON C.CategoryID = P.CategoryID
	Join vInventories as I
	 On P.ProductID = I.ProductID
Order By CategoryName, ProductName, InventoryDate, [Count];
GO
*/


--Creating View
Create View [dbo].[vInventoriesByProductsByCategories]
AS
	Select Top 1000000
		CategoryName,
		ProductName,
		InventoryDate,
		[Count]
		From vCategories as C
		Join vProducts as P
		 ON C.CategoryID = P.CategoryID
		Join vInventories as I
		 On P.ProductID = I.ProductID
	Order By CategoryName, ProductName, InventoryDate, [Count];
GO

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!
/*
-- Finding columns
Select * From vCategories
Select * From vProducts
Select * From vInventories
Select * From vEmployees;
GO
-- Narrowing to desired columns
Select CategoryName 
From vCategories
Select ProductName 
From vProducts
Select InventoryDate, [Count] 
From vInventories
Select Concat (EmployeeFirstName,' ',EmployeeLastName) as EmployeeName
From vEmployees;
GO
-- Joining
Select CategoryName, ProductName, InventoryDate, [Count], Concat (EmployeeFirstName,' ',EmployeeLastName) as EmployeeName
	From vCategories as C
	Join vProducts as P
	 On C.CategoryID = P.CategoryID
	Join vInventories as I
	 On P.ProductID = I.ProductID
	Join vEmployees as E
	 On I.EmployeeID = E.EmployeeID;
GO
-- Ordering Info
Select CategoryName, ProductName, InventoryDate, [Count], Concat (EmployeeFirstName,' ',EmployeeLastName) as EmployeeName
	From Categories as C
	Join Products as P
	 On C.CategoryID = P.CategoryID
	Join Inventories as I
	 On P.ProductID = I.ProductID
	Join Employees as E
	 On I.EmployeeID = E.EmployeeID
Order By InventoryDate, CategoryName, ProductName, EmployeeName;
*/

--Creating View
Create View [dbo].[vInventoriesByProductsByEmployees]
AS
	Select Top 1000000
		CategoryName,
		ProductName,
		InventoryDate,
		[Count],
		Concat (EmployeeFirstName,' ',EmployeeLastName) as EmployeeName
		From vCategories as C
		Join vProducts as P
		 On C.CategoryID = P.CategoryID
		Join vInventories as I
		 On P.ProductID = I.ProductID
		Join vEmployees as E
		 On I.EmployeeID = E.EmployeeID
	Order By InventoryDate, CategoryName, ProductName, EmployeeName;
GO

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
/*
-- Creating Subquery
Select ProductID
From vProducts
Where ProductName In ('Chai', 'Chang')
--Taking Select Statement from Question 7 and adding Subquery
Select CategoryName, ProductName, InventoryDate, [Count], Concat (EmployeeFirstName,' ',EmployeeLastName) as EmployeeName
	From vCategories as C
	Join vProducts as P
	 On C.CategoryID = P.CategoryID
	Join vInventories as I
	 On P.ProductID = I.ProductID
	Join vEmployees as E
	 On I.EmployeeID = E.EmployeeID
Where I.ProductID In (Select ProductID From vProducts Where ProductName In ('Chai', 'Chang'))
Order By InventoryDate, CategoryName, ProductName, EmployeeName;
GO
*/
--Creating View
Create View [dbo].[vInventoriesForChaiAndChangByEmployees]
AS
	Select Top 1000000 
		CategoryName,
		ProductName,
		InventoryDate,
		[Count],
		Concat (EmployeeFirstName,' ',EmployeeLastName) as EmployeeName
		From vCategories as C
		Join vProducts as P
		 On C.CategoryID = P.CategoryID
		Join vInventories as I
		 On P.ProductID = I.ProductID
		Join vEmployees as E
		 On I.EmployeeID = E.EmployeeID
	Where I.ProductID In (Select ProductID From vProducts Where ProductName In ('Chai', 'Chang'))
	Order By InventoryDate, CategoryName, ProductName, EmployeeName;
GO


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!
/*
Select * From Employees;
GO
-- Joining Info & Ordering
Select Concat (M.EmployeeFirstName,' ',M.EmployeeLastName) as ManagerName,
	Concat (E.EmployeeFirstName,' ',E.EmployeeLastName) as EmployeeName
	From vEmployees as M
	Join vEmployees as E
	 On M.EmployeeID = E.ManagerID
Order By ManagerName, EmployeeName
GO
*/
--Creating View
Create View [dbo].[vEmployeesByManager]
AS
	Select Top 1000000 
		Concat (M.EmployeeFirstName,' ',M.EmployeeLastName) as ManagerName,
		Concat (E.EmployeeFirstName,' ',E.EmployeeLastName) as EmployeeName
		From vEmployees as M
		Join vEmployees as E
		 On M.EmployeeID = E.ManagerID
	Order By ManagerName, EmployeeName;
GO

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.
/*
-- Finding columns names, while using statement from Question 7 as it already joined all tables
Select *
	From vCategories as C
	Join vProducts as P
	 On C.CategoryID = P.CategoryID
	Join vInventories as I
	 On P.ProductID = I.ProductID
	Join vEmployees as E
	 On I.EmployeeID = E.EmployeeID

-- Inserting Column names and adding Manager to Join
Select C.CategoryID, CategoryName, P.ProductID, ProductName, UnitPrice, I.InventoryID, InventoryDate, [Count], E.EmployeeID,
	Concat (E.EmployeeFirstName,' ',E.EmployeeLastName) as EmployeeName,
	Concat (M.EmployeeFirstName,' ',M.EmployeeLastName) as ManagerName
	From vCategories as C
	Join vProducts as P
	 On C.CategoryID = P.CategoryID
	Join vInventories as I
	 On P.ProductID = I.ProductID
	Join vEmployees as E
	 On I.EmployeeID = E.EmployeeID
	Join vEmployees as M
	 On M.EmployeeID = E.ManagerID
Order By CategoryID, ProductID, I.InventoryID, E.EmployeeID;
GO
*/
-- Creating View
Create View [dbo].[vInventoriesByProductsByCategoriesByEmployees]
AS
	Select Top 1000000 
		C.CategoryID,
		C.CategoryName,
		P.ProductID,
		P.ProductName,
		P.UnitPrice,
		I.InventoryID,
		I.InventoryDate,
		I.[Count],
		E.EmployeeID,
		Concat (E.EmployeeFirstName,' ',E.EmployeeLastName) as EmployeeName,
		Concat (M.EmployeeFirstName,' ',M.EmployeeLastName) as ManagerName
		From vCategories as C
		Join vProducts as P
		 On C.CategoryID = P.CategoryID
		Join vInventories as I
		 On P.ProductID = I.ProductID
		Join vEmployees as E
		 On I.EmployeeID = E.EmployeeID
		Join vEmployees as M
		 On M.EmployeeID = E.ManagerID
	Order By CategoryID, ProductID, I.InventoryID, E.EmployeeID;
GO

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/