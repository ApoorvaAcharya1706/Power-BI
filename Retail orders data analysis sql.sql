CREATE TABLE df_orders(
	[order_id] int primary key,
	[order_date] date,
	[ship_mode] varchar(20),
	[segment] varchar(20),
	[country] varchar(20),
	[city] varchar(20),
	[state] varchar(20),
	[postal_code] varchar(20),
	[region] varchar(20),
	[category] varchar(20),
	[sub_category] varchar(20),
	[product_id] varchar(50),
	[quantity] int,
	[discount] decimal(7,2),
	[sale_price] decimal(7,2),
	[profit] decimal(7,2))


SELECT * FROM df_orders

--Find top 10 highest revenue generating products

SELECT top 10 product_id, sum(sale_price) AS sales
FROM df_orders
GROUP BY product_id
ORDER BY sales DESC


--Find top 5 highest selling products in each region

WITH cte AS (
SELECT region, product_id, sum(quantity) AS sales
FROM df_orders
GROUP BY region, product_id)

SELECT * 
FROM (
SELECT *, row_number() OVER(PARTITION BY region ORDER BY sales DESC) AS rn
FROM cte) A
WHERE rn<=5


--Find month over month growth comparision for 2022 and 2023 sales(Eg: Jan 2022 vs Jan 2023)

WITH cte AS (
SELECT YEAR(order_date) AS order_year, MONTH(order_date) AS order_month, SUM(sale_price)  AS sales
FROM df_orders
GROUP BY YEAR(order_date), MONTH(order_date)
)

SELECT  order_month, 
		SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
		SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY order_month
ORDER BY order_month


--For each category which month had highest sales


WITH cte AS(
SELECT category, FORMAT(order_date, 'yyyyMM') AS order_year_month, SUM(sale_price) AS sales
FROM df_orders
GROUP BY category, FORMAT(order_date, 'yyyyMM'))

SELECT *
FROM (
SELECT *, row_number() OVER(PARTITION BY category ORDER BY sales DESC) AS rn
FROM cte) C
WHERE rn=1


--Which sub category has the highest growth by profit percentage in 2023 compare to 2022

WITH cte AS(
SELECT sub_category, YEAR(order_date) as order_year, SUM(sale_price) as sales
FROM df_orders
GROUP BY sub_category, YEAR(order_date))

, cte2 AS(
SELECT  sub_category, 
		SUM(CASE WHEN order_year =2022 THEN sales ELSE 0 END) AS sales_2022,
		SUM(CASE WHEN order_year =2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY sub_category)

SELECT top 1 *, (sales_2023 - sales_2022)*100/sales_2022 AS GrowthByProfit
FROM cte2
ORDER BY GrowthByProfit DESC








