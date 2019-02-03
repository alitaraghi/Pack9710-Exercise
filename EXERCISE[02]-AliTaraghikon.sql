/*
جواب تمرین 02
SQL Server پرس و جو از پایگاه داده
pack 97/10
نام و نام خانوادگی : علی نرقی کن
*/

USE AdventureWorks2016


/*1   ارزش و تعداد موجودی کالای موجود در هر انبار را در گزارشی تولید کنید. (ارزش هر کالا را بر اساس ستون
محاسبه کنید) Production.Product در ListPrice
*/
SELECT src1.Name,src2.[TOTAL QUANTITY],src1.[TOTAL QUANTITY VALUE]
FROM
(
SELECT Name,SUM([Quantity Value]) 'TOTAL QUANTITY VALUE'
FROM
(SELECT lo.Name, p.ListPrice, pin.ProductID, Quantity , pin.LocationID,(ListPrice*Quantity)'Quantity Value' FROM Production.ProductInventory pin 
INNER JOIN Production.Product p ON pin.ProductID=p.ProductID 
INNER JOIN Production.Location Lo ON pin.LocationID=lo.LocationID)src
GROUP BY Name
)src1
INNER JOIN
(
SELECT Name,SUM(Quantity) 'TOTAL QUANTITY'
FROM
(SELECT lo.Name, p.ListPrice, pin.ProductID, Quantity , pin.LocationID,(ListPrice*Quantity)'Quantity Value' FROM Production.ProductInventory pin 
INNER JOIN Production.Product p ON pin.ProductID=p.ProductID 
INNER JOIN Production.Location Lo ON pin.LocationID=lo.LocationID)src
GROUP BY Name
)src2
ON src1.Name=src2.Name
------------------------------------------------------------------------------
/*
۲- گزارشی تولید کنید که نشان دهد در هر انبار شرکت چند درصد از تعداد کالاهای موجود(نسبت به کل تعداد
کالاهای انبار)، مربوط به کدام دسته بندی محصولات است.
*/

-----------

SELECT src1.Name,src1.[CATEGORY NAME] ,(FORMAT([Category Quantity]*100/[TOTAL QUANTITY],'###,##')+'%')'Percent'

 FROM
(SELECT NAME, src1.[CATEGORY NAME], SUM(src1.Quantity)'Category Quantity'
FROM
(

SELECT  lo.Name,pc.Name'CATEGORY NAME',pin.ProductID,pin.LocationID,pin.Quantity FROM Production.ProductInventory pin
INNER JOIN Production.Product p ON pin.ProductID=p.ProductID
INNER JOIN Production.ProductSubcategory psc ON psc.ProductSubcategoryID=p.ProductSubcategoryID
INNER JOIN Production.ProductCategory pc ON pc.ProductCategoryID=psc.ProductCategoryID
INNER JOIN Production.Location lo ON lo.LocationID=pin.LocationID
)src1
GROUP BY  NAME, src1.[CATEGORY NAME]
)src1
INNER JOIN 
(
SELECT NAME,SUM(src.[Category Quantity])'TOTAL QUANTITY'
FROM(
SELECT NAME, src1.[CATEGORY NAME], SUM(src1.Quantity)'Category Quantity'
FROM
(
SELECT  lo.Name,pc.Name'CATEGORY NAME',pin.ProductID,pin.LocationID,pin.Quantity FROM Production.ProductInventory pin
INNER JOIN Production.Product p ON pin.ProductID=p.ProductID
INNER JOIN Production.ProductSubcategory psc ON psc.ProductSubcategoryID=p.ProductSubcategoryID
INNER JOIN Production.ProductCategory pc ON pc.ProductCategoryID=psc.ProductCategoryID
INNER JOIN Production.Location lo ON lo.LocationID=pin.LocationID
)src1
GROUP BY  NAME, src1.[CATEGORY NAME]
)src
GROUP BY NAME
)src2
ON src1.Name=src2.Name
/*
۳- گزارشی تهیه کنید که حاوی لیست کالاهایی باشد که یکی از شروط زیر را دارند
تعداد آنها در کل انبار های (مجموع موجودی کالا در همه انبار ها) شرکت کمتر یا مساوی حداقل 
امن است
*/
SELECT p.Name'PRODUCT NAME',src.[Product Total Quantity],(N'حداقل موجودی')'Type Of Quantity'--,src.SafetyStockLevel
FROM
(
SELECT  pin.ProductID,SUM (pin.Quantity)'Product Total Quantity',p.SafetyStockLevel
FROM Production.ProductInventory pin
INNER JOIN Production.Product p ON p.ProductID=pin.ProductID

GROUP BY p.SafetyStockLevel, pin.ProductID
) src
INNER JOIN Production.Product p ON p.ProductID=src.ProductID 
WHERE [Product Total Quantity]<=src.SafetyStockLevel
/*
تعداد آنها ۱۰۰ تا بیشتر از حداقل امن است 

*/
SELECT p.Name'PRODUCT NAME',src.[Product Total Quantity],(N'موجودی نزدیک به حداقل')'Type Of Quantity'--,src.SafetyStockLevel
FROM
(
SELECT  pin.ProductID,SUM (pin.Quantity)'Product Total Quantity',p.SafetyStockLevel
FROM Production.ProductInventory pin
INNER JOIN Production.Product p ON p.ProductID=pin.ProductID

GROUP BY p.SafetyStockLevel, pin.ProductID
) src
INNER JOIN Production.Product p ON p.ProductID=src.ProductID 
WHERE [Product Total Quantity]>=src.SafetyStockLevel+100

----------------------------------------------------------
/*
۴- به گزارش فوق ستونی اضافه کنید که مشخص کند تعداد کالا کمتر مساوی حداقل امن است یا هنوز ۱۰۰ تا
بیشتر است. ( این ستون یکی از دو مقدار “حداقل موجودی” یا “موجودی نزدیک به حداقل” را داشته باشد)
*/

SELECT p.Name'Product NAME',src.[Product Total Quantity],
CASE
WHEN src.[Product Total Quantity]<src.SafetyStockLevel THEN N'حداقل موجودی'
WHEN src.[Product Total Quantity]>src.SafetyStockLevel+100 THEN N'موجودی نزدیک به حداقل'
ELSE N'ناموجود'
END'PRODUCT TYPE'
FROM
(
SELECT  pin.ProductID,SUM (pin.Quantity)'Product Total Quantity',p.SafetyStockLevel
FROM Production.ProductInventory pin
INNER JOIN Production.Product p ON p.ProductID=pin.ProductID

GROUP BY p.SafetyStockLevel, pin.ProductID
) src
INNER JOIN Production.Product p ON p.ProductID=src.ProductID


--------------------------------------------------
----۵- سفارشی به مشخصات زیر دریافت کردیم آیا امکان تحویل آن در زمان ۲ روز از زمان سفارش وجود دارد؟
SELECT src.ProductID,src.[Product Total Quantity],
CASE
WHEN pro>0 THEN N'امکان تحویل دارد'
ELSE N'امکان نحویل ندارد'
END'Delivery'
FROM
(SELECT*,case
when src.ProductID=514 then [Product Total Quantity]-300
when src.ProductID=517 then [Product Total Quantity]-20
when src.ProductID=524 then [Product Total Quantity]-100
when src.ProductID=766 then [Product Total Quantity]-70
when src.ProductID=776 then [Product Total Quantity]-12
when src.ProductID=780 then [Product Total Quantity]-30
end'pro'
FROM
(SELECT  pin.ProductID,SUM (pin.Quantity)'Product Total Quantity',p.SafetyStockLevel
FROM Production.ProductInventory pin
INNER JOIN Production.Product p ON p.ProductID=pin.ProductID
GROUP BY p.SafetyStockLevel, pin.ProductID)src
where src.ProductID IN (766,776,780,517,514,524)
)SRC
----------------------------------
---------۶- چه کالاهایی از بین کالاهای فوق قابلیت تحویل در زمان ۲ روز را دارند؟

----باتوجه به نتیجه تمام کالاها امکان تحویل دارند

SELECT src.ProductID,src.[Product Total Quantity],
CASE
WHEN pro>0 THEN N'امکان تحویل دارد'
ELSE N'امکان نحویل ندارد'
END'Delivery'
FROM
(SELECT*,case
when src.ProductID=514 then [Product Total Quantity]-300
when src.ProductID=517 then [Product Total Quantity]-20
when src.ProductID=524 then [Product Total Quantity]-100
when src.ProductID=766 then [Product Total Quantity]-70
when src.ProductID=776 then [Product Total Quantity]-12
when src.ProductID=780 then [Product Total Quantity]-30
end'pro'
FROM
(SELECT  pin.ProductID,SUM (pin.Quantity)'Product Total Quantity',p.SafetyStockLevel
FROM Production.ProductInventory pin
INNER JOIN Production.Product p ON p.ProductID=pin.ProductID
GROUP BY p.SafetyStockLevel, pin.ProductID)src
where src.ProductID IN (766,776,780,517,514,524)
)SRC

select * from Production.Product



------با تشکر و آرزوی موفقیت روز افزون
