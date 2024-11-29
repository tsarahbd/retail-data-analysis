CREATE TABLE sales_data (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sale_date DATE,
    region VARCHAR(100),
    product VARCHAR(100),
    sales_amount DECIMAL(10, 2)
);

-- check the table from dataframe import 
SELECT * FROM sales_data LIMIT 10;

-- identifying missing values
SELECT * FROM sales_data
WHERE sale_date IS NULL OR region IS NULL OR product IS NULL OR sales_amount IS NULL;

-- deleting rows
DELETE FROM sales_data
WHERE sale_date IS NULL OR region IS NULL;

DELETE FROM sales_data
WHERE product IS NULL;

-- updating with default values
UPDATE sales_data
SET sales_amount = 0
WHERE sales_amount IS NULL;

-- format date
UPDATE sales_data
SET sale_date = str_to_date(sale_date, '%m/%d/%Y');

-- extract year and month
ALTER TABLE sales_data
ADD COLUMN year INT,
ADD COLUMN month INT;

UPDATE sales_data
SET year = YEAR(sale_date),
	month = MONTH(sale_date);
    
-- formatting the sales amount
ALTER TABLE sales_data
MODIFY sales_amount DECIMAL(10,2);
    
-- aggregate monthly sales
SELECT
	year,
    month,
    SUM(sales_amount) AS total_sales
FROM sales_data
GROUP BY year, month
ORDER BY year, month;

-- Highest Regional Sales of Products By Month
WITH MonthlyProductSales AS (
	SELECT
		year,
        month,
        product,
        region,
        SUM(sales_amount) AS total_sales
	FROM
		sales_data
	GROUP BY
		year, month, product, region
),
TopCountryPerProduct AS (
	SELECT
		year,
        month, 
        product,
        region,
        total_sales,
        RANK() OVER (PARTITION BY year, month, product ORDER BY total_sales DESC) AS ranking
	FROM
		MonthlyProductSales
)
SELECT
	year,
    month,
    product,
    region,
    total_sales
FROM
	TopCountryPerProduct
WHERE
	ranking = 1 or ranking = 2 or ranking = 3
ORDER BY
	year, month, total_sales DESC, product;
