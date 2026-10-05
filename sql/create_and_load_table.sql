-- ============================================================
-- House Price Prediction - Table Creation & Data Load
-- Target: SQL Server
-- ============================================================

use master
go

if DB_ID('HousePrices') is null
	create database HousePrices
go

use HousePrices
go

if OBJECT_ID('dbo.HouseSales', 'U') is not null
	drop table dbo.HouseSales
go

create table dbo.HouseSales (
	id int identity(1,1) primary key,
	sale_date date,
	price decimal(14,2),
	bedrooms int,
	bathrooms decimal(4,2),
	sqft_living int,
	sqft_lot int,
	floors decimal(3,1),
	waterfront bit,
	[view] int,
	condition int,
	sqft_above int,
	sqft_basement int,
	yr_built int,
	yr_renovated int,
	street nvarchar(200),
	city nvarchar(100),
	statezip nvarchar(20),
	price_per_sqft decimal(12,2)
)
go

-- ------------------------------------------------------------
-- Load data from the CSV.
-- Update the file path below to wherever modified_data.csv
-- lives on the machine running this script.
-- ------------------------------------------------------------
bulk insert dbo.HouseSales
from 'C:\path\to\modified_data.csv'
with (
	firstrow = 2,
	fieldterminator = ',',
	rowterminator = '0x0a',
	codepage = '65001',
	tablock
)
go

-- Quick sanity check after load
select count(*) as [rows_loaded] from dbo.HouseSales
go

-- Remove invalid rows (price = 0), mirroring the cleaning
-- step performed in the Python notebook
delete from dbo.HouseSales where price = 0
go

select count(*) as [rows_after_cleaning] from dbo.HouseSales
go
