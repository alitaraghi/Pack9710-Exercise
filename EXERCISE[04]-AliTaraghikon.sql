/*
جواب تمرین  04 
SQL Server پرس و جو از پایگاه داده
pack 97/10
نام و نام خانوادگی : علی نرقی کن
*/

USE AdventureWorks2016


/*
۱. در بین ۱۰ محصولی که بیشترین مجموع فروش را دارند کدام یک بیشترین تعداد فروش را دارد
*/
SELECT TOP(1) ts.ProductID,ts.[Total Sales],SUM(OrderQty)'Total Order Qty'
FROM
(SELECT TOP(10)  ProductID,SUM(LineTotal) 'Total Sales'
                    FROM Sales.SalesOrderDetail
                    GROUP BY ProductID
					ORDER BY [Total Sales] DESC
					 )  ts
 LEFT OUTER JOIN Sales.SalesOrderDetail sod ON ts.ProductID=sod.ProductID 
 GROUP BY ts.ProductID,ts.[Total Sales]  
 ORDER BY  [Total Order Qty]  DESC 
 
 /*
2. محصول بدست آمده در سوال ۱ را نمایش دهید Category  اطللاعات
 */
 SELECT src.ProductID, pc.* FROM Production.ProductCategory pc
 INNER JOIN Production.ProductSubcategory psc ON pc.ProductCategoryID=psc.ProductCategoryID
 INNER JOIN  Production.Product p ON p.ProductSubcategoryID=psc.ProductSubcategoryID
 INNER JOIN ( SELECT TOP(1) ts.ProductID,ts.[Total Sales],SUM(OrderQty)'Total Order Qty'
                       FROM
                              (SELECT TOP(10)  ProductID,SUM(LineTotal)'Total Sales'
                               FROM Sales.SalesOrderDetail
                               GROUP BY ProductID
					           ORDER BY [Total Sales] DESC
					           )  ts
                               LEFT OUTER JOIN Sales.SalesOrderDetail sod ON ts.ProductID=sod.ProductID 
                               GROUP BY ts.ProductID,ts.[Total Sales]  
                               ORDER BY  [Total Order Qty]  DESC)src 
							   ON src.ProductID=p.ProductID

/* 3.
چند درصد از مجموع فروش شرکت راشامل میشود (Category)  گزارشی تهیه کنید که هر یک دسته بندی ها
*/

SELECT CONVERT(varchar,SUM(src.LineTotal)/(SELECT SUM(LineTotal) FROM Sales.SalesOrderDetail )*100)+'%' 'Percentage of category sales',src.Name
FROM
    (
      SELECT sod.ProductID,LineTotal,pc.Name 
      FROM Sales.SalesOrderDetail sod
      LEFT JOIN Production.Product p ON sod.ProductID=p.ProductID
      LEFT JOIN Production.ProductSubcategory psc ON psc.ProductSubcategoryID=p.ProductSubcategoryID
      LEFT JOIN Production.ProductCategory pc ON pc.ProductCategoryID=psc.ProductCategoryID
     )src
GROUP BY src.Name

/*4.
را نشان دهد به ازای هر دسته بندی یک محصول (Category )  گزارشی تهیه کنید که پر فروش ترین محصول در هر دسته بندی
*/

      SELECT TOP(1) WITH TIES  src.ProductID,src.Name'Category Name' ,SUM(src.LineTotal)'Total Sales'
	  FROM
	  (   
      SELECT sod.ProductID,LineTotal,pc.Name 
      FROM Sales.SalesOrderDetail sod
      INNER JOIN Production.Product p ON sod.ProductID=p.ProductID
      INNER JOIN Production.ProductSubcategory psc ON psc.ProductSubcategoryID=p.ProductSubcategoryID
      INNER JOIN Production.ProductCategory pc ON pc.ProductCategoryID=psc.ProductCategoryID
	  
	  )src
	  GROUP BY src.ProductID,src.Name
	  ORDER BY DENSE_RANK() OVER(PARTITION BY Name ORDER BY Name,SUM(src.LineTotal) DESC)

/*
۵. گزارشی تهیه کنید که نشان دهد برترین بازاریاب شرکت از نظر مجموع فروش، در هر دسته بندی به
نسبت کل فروش خودش چند درصد فروش داشته.
*/
SELECT src1.[Sales Person],[Category Name],CONVERT(varchar, [Total of sold in category]/[Total of Sales Person]*100)+'%' 'Percent of sold in categories'
FROM
(
SELECT TOP (1)SUM(src.LineTotal)'Total of Sales Person',[Sales Person]
FROM
(
SELECT sod.ProductID,LineTotal,pc.Name'Category Name',sod.SalesOrderID,ISNULL(soh.SalesPersonID,0)'Sales Person'
      FROM Sales.SalesOrderDetail sod
      INNER JOIN Production.Product p ON sod.ProductID=p.ProductID
      INNER JOIN Production.ProductSubcategory psc ON psc.ProductSubcategoryID=p.ProductSubcategoryID
      INNER JOIN Production.ProductCategory pc ON pc.ProductCategoryID=psc.ProductCategoryID
	  INNER JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID=soh.SalesOrderID
	  
)src
GROUP BY [Sales Person])src1	  
INNER JOIN 
(
SELECT SUM(src.LineTotal)'Total of sold in category',[Sales Person],[Category Name]
FROM(
SELECT sod.ProductID,LineTotal,pc.Name'Category Name',sod.SalesOrderID,ISNULL(soh.SalesPersonID,0)'Sales Person'
      FROM Sales.SalesOrderDetail sod
      INNER JOIN Production.Product p ON sod.ProductID=p.ProductID
      INNER JOIN Production.ProductSubcategory psc ON psc.ProductSubcategoryID=p.ProductSubcategoryID
      INNER JOIN Production.ProductCategory pc ON pc.ProductCategoryID=psc.ProductCategoryID
	  INNER JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID=soh.SalesOrderID
	 )src 
GROUP BY [Sales Person],[Category Name]
)src2
ON src1.[Sales Person]=src2.[Sales Person]

/*6
بهترین مشتری شرکت از نظر مجموع خرید از محصولات کدام دسته بندی بیشترین خرید را
داشته؟
*/
SELECT TOP(1) src1.CustomerId,src1.[Category Name],src1.[SUM OF LineTotal]
FROM
(
SELECT SUM(LineTotal)'SUM OF LineTotal',pc.Name'Category Name',soh.CustomerID'CustomerId'
      FROM Sales.SalesOrderDetail sod
      INNER JOIN Production.Product p ON sod.ProductID=p.ProductID
      INNER JOIN Production.ProductSubcategory psc ON psc.ProductSubcategoryID=p.ProductSubcategoryID
      INNER JOIN Production.ProductCategory pc ON pc.ProductCategoryID=psc.ProductCategoryID
	  INNER JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID=soh.SalesOrderID
	  GROUP BY pc.Name,soh.CustomerID
	  )src1
	  INNER JOIN
	  (
SELECT TOP(1) WITH TIES SUM(src.LineTotal)'Total bought' ,CustomerID
FROM(
SELECT sod.SalesOrderID,soh.CustomerID,sod.LineTotal FROM Sales.SalesOrderDetail sod
INNER JOIN Sales.SalesOrderHeader soh ON soh.SalesOrderID=sod.SalesOrderID
)src
GROUP BY CustomerID
ORDER BY [Total bought] DESC

       )src2 ON src1.CustomerId=src2.CustomerID   
	   ORDER BY [SUM OF LineTotal] DESC

/* 7
کدام محصولات کمترین فروش تعدادی را داشته اند ( ۱۰ رتبه اول )، در گزارشی نشان دهید که هر
دسته بندی چند درصد از این محصولات کم فروش را در خود دارد.
*/
SELECT src.[Category Name],SUM(src.[Percentage of product])'Percent of Category'
FROM

(
SELECT pc.Name'Category Name' ,src.ProductID,CONVERT(float, (src.[Sum Of OrderQty])/CONVERT(float,src.[Total Qty]))*100 'Percentage of product'
FROM
(

SELECT TOP(10) ProductID,SUM(OrderQty)'Sum Of OrderQty' ,
(SELECT SUM([Sum Of OrderQty]) FROM (SELECT TOP(10) ProductID,SUM(OrderQty)'Sum Of OrderQty' 
FROM Sales.SalesOrderDetail
GROUP BY ProductID Order BY [Sum Of OrderQty])src)'Total Qty'

FROM Sales.SalesOrderDetail
GROUP BY ProductID Order BY [Sum Of OrderQty]
)src
INNER JOIN Production.Product p ON p.ProductID=src.ProductID
INNER JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID=psc.ProductSubcategoryID
INNER JOIN Production.ProductCategory pc ON psc.ProductCategoryID=pc.ProductCategoryID
)src
GROUP BY src.[Category Name]

------با تشکر و آرزوی موفقیت روز افزون

