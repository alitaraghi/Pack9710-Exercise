/*
جواب تمرین 01
SQL Server پرس و جو از پایگاه داده
pack 97/10
نام و نام خانوادگی : علی نرقی کن
*/

USE AdventureWorks2016


-----1 بازاریاب با شناسه ۲۸۳ مجموعا چه میزان فروش داشته است؟
SELECT SUM(Subtotal) 'Subtotal of SalesPerson=283'
FROM Sales.SalesOrderHeader
WHERE SalesPersonID=283

------2 بالاترین مبلغ مجموع فاکتور چقدر است و مربوط به کدام بازاریاب است؟

SELECT TOP 1 WITH TIES SalesPersonID,SubTotal
FROM Sales.SalesOrderHeader
ORDER BY SubTotal DESC

-------3 بالاترین مبلغ مجموع فاکتورآنلاین چقدر بوده و مربوط به کدام مشتری است؟

SELECT TOP 1 WITH TIES SalesOrderHeader.CustomerID,SubTotal
FROM Sales.SalesOrderHeader
WHERE OnlineOrderFlag=1
ORDER BY SubTotal DESC

-----4 مجموع موجودی کالای ۳۶۶ در کل انبار ها چقدر است؟
SELECT SUM(Quantity) 'Quantity of Product No.366'
FROM Production.ProductInventory
WHERE ProductID=366

------5 به طور میانگین در هر انبار چه تعداد از کالای ۴۴۴ موجودی داریم؟

SELECT AVG(Quantity)'AVG of Product No.444'
FROM Production.ProductInventory
WHERE ProductID=444

-------6 نام و نام خانوادگی مسن ترین کارمند شرکت چیست؟

SELECT BusinessEntityID, FirstName,MiddleName, LastName
FROM Person.person
WHERE BusinessEntityID IN (
                           SELECT TOP 1 WITH TIES BusinessEntityID
						    FROM HumanResources.Employee 
							ORDER BY BirthDate 
						  )

------7 نام و نام خانوادگی با سابقه ترین فرد شرکت چیست؟
SELECT BusinessEntityID, FirstName,MiddleName, LastName
FROM Person.person
WHERE BusinessEntityID IN (
                           SELECT TOP 1 WITH TIES BusinessEntityID
						    FROM HumanResources.Employee 
							ORDER BY HireDate
							) 
-------8 نام و نام خانوادگی فردی که بیشترین میزان مرخصی استحقاقی را داشته چیست؟

SELECT BusinessEntityID, FirstName,MiddleName, LastName
FROM Person.person
WHERE BusinessEntityID IN (
                           SELECT TOP 1 WITH TIES BusinessEntityID
						    FROM HumanResources.Employee 
							ORDER BY VacationHours DESC
							) 
------9 نام و نام خانوادگی فردی که کمترین میزان مرخصی استعلاجی را داشته چیست؟
SELECT BusinessEntityID, FirstName,MiddleName, LastName
FROM Person.person
WHERE BusinessEntityID IN (
                           SELECT TOP 1 WITH TIES BusinessEntityID
						    FROM HumanResources.Employee 
							ORDER BY SickLeaveHours
							) 
-------10 آمده را در یک گزارش بیاورید Engineer  اسامی افرادی که در عنوان شغلی آنها کلمه

SELECT BusinessEntityID, FirstName,MiddleName, LastName
FROM Person.person
WHERE BusinessEntityID IN (
                           SELECT   BusinessEntityID
						    FROM HumanResources.Employee
							WHERE JobTitle LIKE'%Engineer%'
							 )
-------11 آمده را در یک گزارش بیاوردید Manager یا کلمه Supervisor  اسامی افرادی که در عنوان شغلی آنها کلمه
SELECT BusinessEntityID, FirstName,MiddleName, LastName
FROM Person.person
WHERE BusinessEntityID IN (
                           SELECT   BusinessEntityID
						    FROM HumanResources.Employee
							WHERE JobTitle LIKE '%Supervisor%' OR JobTitle lIKE  '%Manager%' 
							 )
/*
با توجه به اطلاعات فعلی به نظر می رسد امکان نمایش مقادیر جدول دوم در گزارش وجود ندارد
به عنوان مثال نمایش مقدار مرخصی استحقاقی یا استعلاجی و.... در ستونی از گزارش در کنار نام و نام خانوادگی نمیباشد

با تشکر 
*/