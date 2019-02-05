/*
جواب تمرین  03 
SQL Server پرس و جو از پایگاه داده
pack 97/10
نام و نام خانوادگی : علی نرقی کن
*/

USE AdventureWorksLT2016


/*
1. Show the first name and the email address of customer with CompanyName 'Bike
World'
*/

SELECT FirstName, EmailAddress ,CompanyName
FROM SalesLT.Customer
WHERE CompanyName LIKE'%Bike World%'

/*
2. Show the CompanyName for all customers with an address in City 'Dallas'.
*/
SELECT  c.CompanyName --,c.CustomerID,ad.City,c.FirstName,c.LastName,c.rowguid
 FROM SalesLT.Customer c
INNER JOIN SalesLT.CustomerAddress ca ON c.CustomerID=ca.CustomerID
INNER JOIN SalesLT.Address ad ON ca.AddressID=ad.AddressID
WHERE ad.City='Dallas'

/*
3. How many items with ListPrice more than $1000 have been sold?
*/
SELECT COUNT(*) 'SUM OF SOLD Pproducts with more than $1000 listprice'
FROM SalesLT.SalesOrderDetail 
WHERE ProductID IN (SELECT ProductID FROM SalesLT.Product WHERE ListPrice>1000) 

/*
4. Give the CompanyName of those customers with orders over $100000. Include the
subtotal plus tax plus freight.
 */
 SELECT CompanyName
 FROM SalesLT.Customer
 WHERE CustomerID IN
 (select CustomerID--,SUM(SubTotal+TaxAmt+Freight)'subtotal1'
 from SalesLT.SalesOrderHeader
 GROUP BY CustomerID
 HAVING SUM(SubTotal+TaxAmt+Freight)>100000)
 /*
 5. Find the number of left racing socks ('Racing Socks, L') ordered by CompanyName
'Riding Cycles'
 */

 SELECT sum(orderqty)'number of left racing socks'
FROM SalesLT.Customer caw
INNER JOIN SalesLT.SalesOrderHeader soh ON caw.customerid = soh.customerid
INNER JOIN SalesLT.SalesOrderDetail sod ON soh.salesorderid = sod.salesorderid
INNER JOIN SalesLT.Product paw ON sod.productid = paw.productid
WHERE caw.companyname IN ('Riding Cycles')
	AND paw.NAME IN ('Racing Socks, L')

/*
6. A "Single Item Order" is a customer order where only one item is ordered. Show the
SalesOrderID and the UnitPrice for every Single Item Order.
7. Where did the racing socks go? List the product name and the CompanyName for all
Customers who ordered ProductModel 'Racing Socks'.
*/
SELECT SalesOrderID
	,UnitPrice--,OrderQty
FROM SalesLT.SalesOrderDetail 
WHERE OrderQty = 1
ORDER BY SalesOrderID
	,UnitPrice

/*
7. Where did the racing socks go? List the product name and the CompanyName for all
Customers who ordered ProductModel 'Racing Socks'.
*/
SELECT pm.NAME'Product Model',pro.Name'Product Name'
	,cus.CompanyName
FROM SalesLT.Customer cus
INNER JOIN SalesLT.SalesOrderHeader soh ON cus.CustomerID = soh.CustomerID
INNER JOIN SalesLT.SalesOrderDetail sod ON soh.salesorderid = sod.SalesOrderID
INNER JOIN SalesLT.Product pro ON sod.productid = pro.ProductID
INNER JOIN SalesLT.ProductModel pm ON pro.ProductModelID = pm.ProductModelID
WHERE pm.NAME IN ('Racing Socks')
GROUP BY pm.NAME,cus.CompanyName,pro.Name
/*
8. Show the product description for culture 'fr' for product with ProductID 736
*/
SELECT pd.Description
FROM SalesLT.Product p
INNER JOIN SalesLT.ProductModel pm ON p.ProductModelID = pm.ProductModelID
INNER JOIN SalesLT.ProductModelProductDescription pmpd ON pm.ProductModelID = pmpd.ProductModelID
INNER JOIN SalesLT.ProductDescription pd ON pmpd.ProductDescriptionID = pd.ProductDescriptionID
WHERE pmpd.culture IN ('fr')
AND p.ProductID IN (736)

/*
9. Use the SubTotal value in SaleOrderHeader to list orders from the largest to the smallest.
For each order show the CompanyName and the SubTotal and the total weight of the order.
*/
SELECT cus.CompanyName
	,soh.subtotal
	,totalweight
FROM SalesLT.Customer cus
INNER JOIN SalesLT.SalesOrderHeader soh ON cus.CustomerID = soh.CustomerID
INNER JOIN (
	SELECT sod.SalesOrderID
		,SUM( p.Weight * sod.OrderQty) totalweight
	FROM SalesLT.SalesOrderDetail sod
	INNER JOIN SalesLT.Product p ON sod.ProductID = p.ProductID
	GROUP BY sod.SalesOrderID
	) src ON soh.SalesOrderID = src.SalesOrderID
ORDER BY soh.SubTotal DESC

/*
10. How many products in ProductCategory 'Cranksets' have been sold to an address in
'London'?
*/
SELECT SUM(orderqty) 'SUM' 
FROM SalesLT.Customer cus
INNER JOIN SalesLT.CustomerAddress ca ON cus.CustomerID = ca.CustomerID
INNER JOIN SalesLT.Address ad ON ca.AddressID = ad.AddressID
INNER JOIN SalesLT.SalesOrderHeader soh ON  cus.CustomerID = soh.CustomerID
INNER JOIN SalesLT.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN SalesLT.Product p ON sod.ProductID = p.ProductID
INNER JOIN SalesLT.ProductCategory pc ON p.ProductCategoryID = pc.ProductCategoryID
WHERE pc.NAME IN ('Cranksets')
	AND ad.City IN ('London')


/*
11. For every customer with a 'Main Office' in Dallas show AddressLine1 of the 'Main Office' and
AddressLine1 of the 'Shipping' address - if there is no shipping address leave it blank. Use
one row per customer.
*/
SELECT cus.CustomerID,
	cmo.mainoffice mainoffice,ISNULL(csa.shippingaddress,'BLANK')'Shipping Address'
FROM SalesLT.Customer cus
INNER JOIN (
	SELECT ca.CustomerID
		,ad.AddressLine1 mainoffice
	FROM SalesLT.CustomerAddress ca
	INNER JOIN SalesLT.Address ad ON ca.addressid = ad.AddressID
	WHERE ca.AddressType IN ('Main Office')
		AND ad.City IN ('Dallas')
	) cmo ON cus.CustomerID = cmo.CustomerID
LEFT JOIN (
	SELECT ca.CustomerID
		,ad.AddressLine1 shippingaddress
	FROM SalesLT.CustomerAddress ca
	INNER JOIN SalesLT.Address ad ON ca.addressid = ad.AddressID
	WHERE ca.addresstype IN ('Shipping')
		AND ad.City IN ('Dallas')
	) csa ON cmo.CustomerID = csa.CustomerID

/*
12. For each order show the SalesOrderID and SubTotal calculated three ways:
A) From the SalesOrderHeader
B) Sum of OrderQty*UnitPrice
C) Sum of OrderQty*ListPrice
*/	
SELECT soh.SalesOrderID
	,a.SubTotal
	,b.subtotal
	,c.subtotal
FROM SalesLT.SalesOrderHeader soh
INNER JOIN (
	SELECT salesorderid
		,subtotal
	FROM SalesLT.SalesOrderHeader
	) a ON soh.SalesOrderID = a.SalesOrderID
INNER JOIN (
	SELECT SalesOrderID
		,SUM(orderqty * unitprice) Subtotal
	FROM SalesLT.SalesOrderDetail
	GROUP BY SalesOrderID
	) b ON a.SalesOrderID = b.SalesOrderID
INNER JOIN (
	SELECT sod.SalesOrderID
		,SUM(sod.orderqty * p.ListPrice) Subtotal
	FROM SalesLT.SalesOrderDetail sod
	INNER JOIN SalesLT.Product p ON sod.productid = p.ProductID
	GROUP BY sod.SalesOrderID
	) c ON b.SalesOrderID = c.SalesOrderID

/*
13. Show the best selling item by value.
*/
SELECT TOP 1 WITH TIES ProductID, sum(LineTotal)'best selling item'
FROM SalesLT.SalesOrderDetail
GROUP BY ProductID
ORDER BY sum(LineTotal) DESC

/*
14.Show how many orders are in the following ranges (in $):
RANGE Num Orders Total Value
0- 99
100- 999
1000-9999
10000-
*/
SELECT src.[Total Value], COUNT(src.SalesOrderID)'AMOUNT' FROM(
SELECT SalesOrderID, CASE 
WHEN TotalDue>=10000 THEN '>10000'
WHEn TotalDue>=1000 THEN '1000-9999'
WHEN TotalDue>=100 THEN '100-999'
WHEN TotalDue>0 THEN '0-99'
END 'Total Value'
 FROM SalesLT.SalesOrderHeader
 )src
 GROUP BY [Total Value] 
 



------با تشکر و آرزوی موفقیت روز افزون

