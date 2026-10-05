use HousePrices
go

--------------------------------------------------------------------------
-- Overall price statistics
select count(*) as [total houses],
	cast(avg(price) as decimal(14,2)) as [avg price],
	min(price) as [min price],
	max(price) as [max price],
	cast(stdev(price) as decimal(14,2)) as [std dev]
from dbo.HouseSales
--------------------------------------------------------------------------
-- Price statistics by waterfront status
select case when waterfront = 1 then 'Waterfront' else 'Not waterfront' end as [type],
	count(*) as [count],
	cast(avg(price) as decimal(14,2)) as [avg price],
	min(price) as [min price],
	max(price) as [max price]
from dbo.HouseSales
group by waterfront
order by [avg price] desc
--------------------------------------------------------------------------
-- Price by number of bedrooms
select bedrooms,
	count(*) as [count],
	cast(avg(price) as decimal(14,2)) as [avg price],
	cast(avg(cast(sqft_living as float)) as decimal(10,0)) as [avg sqft_living]
from dbo.HouseSales
group by bedrooms
order by bedrooms
--------------------------------------------------------------------------
-- Price by number of bathrooms
select bathrooms,
	count(*) as [count],
	cast(avg(price) as decimal(14,2)) as [avg price]
from dbo.HouseSales
group by bathrooms
order by bathrooms
--------------------------------------------------------------------------
-- Price by condition rating (1-5)
select condition as [condition (1-5)],
	count(*) as [count],
	cast(avg(price) as decimal(14,2)) as [avg price],
	cast(avg(cast(sqft_living as float)) as decimal(10,0)) as [avg sqft_living]
from dbo.HouseSales
group by condition
order by condition
--------------------------------------------------------------------------
-- Price by view quality rating (0-4)
select [view] as [view rating (0-4)],
	count(*) as [count],
	cast(avg(price) as decimal(14,2)) as [avg price]
from dbo.HouseSales
group by [view]
order by [view]
--------------------------------------------------------------------------
-- Price by number of floors
select floors,
	count(*) as [count],
	cast(avg(price) as decimal(14,2)) as [avg price]
from dbo.HouseSales
group by floors
order by floors
--------------------------------------------------------------------------
-- Living area (sqft) buckets vs price
select
	case
		when sqft_living < 1000 then 'Under 1,000 sqft'
		when sqft_living < 1500 then '1,000 - 1,500 sqft'
		when sqft_living < 2000 then '1,500 - 2,000 sqft'
		when sqft_living < 3000 then '2,000 - 3,000 sqft'
		when sqft_living < 4000 then '3,000 - 4,000 sqft'
		else '4,000+ sqft'
	end as [sqft bucket],
	count(*) as [count],
	cast(avg(price) as decimal(14,2)) as [avg price]
from dbo.HouseSales
group by
	case
		when sqft_living < 1000 then 'Under 1,000 sqft'
		when sqft_living < 1500 then '1,000 - 1,500 sqft'
		when sqft_living < 2000 then '1,500 - 2,000 sqft'
		when sqft_living < 3000 then '2,000 - 3,000 sqft'
		when sqft_living < 4000 then '3,000 - 4,000 sqft'
		else '4,000+ sqft'
	end
order by min(sqft_living)
--------------------------------------------------------------------------
-- House age (at time of sale) vs price
with age_calc as (
	select *, datepart(year, sale_date) - yr_built as house_age
	from dbo.HouseSales
)
select
	case
		when house_age <= 5 then '0 - 5 years'
		when house_age <= 15 then '6 - 15 years'
		when house_age <= 30 then '16 - 30 years'
		when house_age <= 50 then '31 - 50 years'
		else '50+ years'
	end as [age group],
	count(*) as [count],
	cast(avg(price) as decimal(14,2)) as [avg price]
from age_calc
group by
	case
		when house_age <= 5 then '0 - 5 years'
		when house_age <= 15 then '6 - 15 years'
		when house_age <= 30 then '16 - 30 years'
		when house_age <= 50 then '31 - 50 years'
		else '50+ years'
	end
order by min(house_age)
--------------------------------------------------------------------------
-- Renovated vs never renovated
select case when yr_renovated > 0 then 'Renovated' else 'Not renovated' end as [status],
	count(*) as [count],
	cast(avg(price) as decimal(14,2)) as [avg price]
from dbo.HouseSales
group by case when yr_renovated > 0 then 'Renovated' else 'Not renovated' end
order by [avg price] desc
--------------------------------------------------------------------------
-- Price per sqft by city (top 15 by volume), ranked by avg price/sqft
with city_volume as (
	select city, count(*) as cnt
	from dbo.HouseSales
	group by city
)
select h.city,
	count(*) as [count],
	cast(avg(h.price) as decimal(14,2)) as [avg price],
	cast(avg(h.price / nullif(h.sqft_living, 0)) as decimal(10,2)) as [avg price per sqft]
from dbo.HouseSales h
where h.city in (select top 15 city from city_volume order by cnt desc)
group by h.city
order by [avg price per sqft] desc
--------------------------------------------------------------------------
-- Top 20 most expensive houses
select top 20 city, bedrooms, bathrooms, sqft_living, condition, yr_built, price
from dbo.HouseSales
order by price desc
--------------------------------------------------------------------------
-- Top 20 lowest-priced houses
select top 20 city, bedrooms, bathrooms, sqft_living, condition, yr_built, price
from dbo.HouseSales
order by price asc
--------------------------------------------------------------------------
-- Decade built vs price
select
	(yr_built / 10) * 10 as [decade built],
	count(*) as [count],
	cast(avg(price) as decimal(14,2)) as [avg price]
from dbo.HouseSales
group by (yr_built / 10) * 10
order by [decade built]
--------------------------------------------------------------------------
-- Price range distribution
select
	case
		when price < 300000 then 'Under $300K'
		when price < 500000 then '$300K - $500K'
		when price < 750000 then '$500K - $750K'
		when price < 1000000 then '$750K - $1M'
		when price < 2000000 then '$1M - $2M'
		else 'Over $2M'
	end as [price range],
	count(*) as [count],
	cast(count(*) * 100.0 / (select count(*) from dbo.HouseSales) as decimal(5,2)) as [% of total]
from dbo.HouseSales
group by
	case
		when price < 300000 then 'Under $300K'
		when price < 500000 then '$300K - $500K'
		when price < 750000 then '$500K - $750K'
		when price < 1000000 then '$750K - $1M'
		when price < 2000000 then '$1M - $2M'
		else 'Over $2M'
	end
order by min(price)
--------------------------------------------------------------------------
-- View 1: City-level summary
if OBJECT_ID('dbo.city_price_summary', 'V') is not null
	drop view dbo.city_price_summary
go

create view dbo.city_price_summary as
select city,
	count(*) as house_count,
	avg(price) as avg_price,
	min(price) as min_price,
	max(price) as max_price,
	avg(price / nullif(sqft_living, 0)) as avg_price_per_sqft
from dbo.HouseSales
group by city
go

select * from dbo.city_price_summary order by avg_price desc
go

--------------------------------------------------------------------------
-- View 2: High-value property profile (top condition, view, no renovation needed)
if OBJECT_ID('dbo.premium_properties', 'V') is not null
	drop view dbo.premium_properties
go

create view dbo.premium_properties as
select city, bedrooms, bathrooms, sqft_living, condition, [view], waterfront, price
from dbo.HouseSales
where condition >= 4
	and [view] >= 2
	and price > (select avg(price) from dbo.HouseSales)
go

select * from dbo.premium_properties order by price desc
go
--------------------------------------------------------------------------
