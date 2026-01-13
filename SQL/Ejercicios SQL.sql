-------------------------------------------------------
/* SQL Basico*/
------------------------------------------------------
/* Muestra los primeros 10 productos con estas columnas:
ProductID
Name
ListPrice */
select  top 10 productid, name, listprice from
Production.Product

/*
Muestra los productos cuyo:ListPrice sea mayor a 500 y menor o igual a 2000
Ordena por ListPrice de mayor a menor.
*/
select  listprice from
Production.Product
where ListPrice > 500
and ListPrice <=2000
order by ListPrice desc

/* Lista los productos que: NO tengan color (Color)
y que sí tengan precio (ListPrice > 0) */
select Color, ListPrice from
Production.Product
where color is null 
and ListPrice > 0

/*Muestra solo:Productos de color Red o Black
Con precio mayor a 1000 */
select color, ListPrice from 
Production.Product
where Color in ( 'red','black')
and ListPrice > 1000

/*Obtén los productos cuyo nombre:
Empiece con “Road”*/
select Name from 
Production.Product
where name like 'Road%'
-------------------------------------------------------
/* Agregaciones*/
-------------------------------------------------------
/*¿Cuántos productos hay por Color?*/
select color, count(*) as total_producto
from 
Production.Product
group by color

--select top 100 * from Production.Product 

/*Muestra:Color,Precio promedio (AVG)
Solo de productos con precio mayor a 0.*/
select color,AVG (ListPrice)  as Precio_prom
from 
Production.Product
where ListPrice > 0
group by Color

/*¿Cuál es el precio máximo y mínimo por ProductSubcategoryID?*/
select ProductSubcategoryID, Max(ListPrice) as PrecioMaximo, min(ListPrice) as PrecioMin
from 
Production.Product
group by ProductSubcategoryID

/*Lista solo los colores que tengan más de 10 productos.*/
select color, count(*) as TotalColores
from 
Production.Product
group by Color
having count (*) > 10

/*¿Cuántos productos No tienen color?*/
select color, count(*) as productosinColor
from 
Production.Product
where color is null
group by Color

-------------------------------------------------------
/* Joins*/
-------------------------------------------------------
/*
Lista:
Nombre del producto
Subcategoría
Categoría
Tablas:
Production.Product
Production.ProductSubcategory
Production.ProductCategory */

SELECT 
    p.Name  AS Producto,
    ps.Name AS Subcategoria,
    pc.Name AS Categoria
FROM Production.Product p
INNER JOIN Production.ProductSubcategory ps
    ON p.ProductSubcategoryID = ps.ProductSubcategoryID
INNER JOIN Production.ProductCategory pc
    ON ps.ProductCategoryID = pc.ProductCategoryID;

  /*Mostrar:
ProductID
Nombre del producto
Nombre de la categoría*/

SELECT 
    p.ProductID ,
    p.Name AS Producto,
    pc.Name AS Categoria
FROM Production.Product p
INNER JOIN Production.ProductSubcategory ps
    ON p.ProductSubcategoryID = ps.ProductSubcategoryID
INNER JOIN Production.ProductCategory pc
    ON ps.ProductCategoryID = pc.ProductCategoryID;


/*Mostrar:
Nombre del producto
Nombre de la subcategoría
Precio (ListPrice)*/

select p.Name as producto,
ps.name as subcategoria,
p.ListPrice
from Production.Product as p
join Production.ProductSubcategory as ps
on p.ProductSubcategoryID = ps.ProductSubcategoryID
order by p.ListPrice desc

select top 5 ProductSubcategoryID,* from  Production.Product
select top 5 * from Production.ProductSubcategory
select top 5 * from Production.ProductCategory

/*Obtén:
ProductID
Name del producto
Name de la subcategoría*/

select p.ProductID,
p.name as Producto,
ps.Name as Subcategoria
from Production.Product as p
join Production.ProductSubcategory as ps
on p.ProductSubcategoryID = ps.ProductSubcategoryID

/*Obten Órdenes con cliente
Lista:
SalesOrderID
Fecha de orden
CustomerID*/

select so.SalesOrderID,
so.OrderDate as Fecha,
c.CustomerID 
from Sales.SalesOrderHeader as so
join Sales.Customer as c
on so.CustomerID = c.CustomerID

/*Productos sin subcategoría*/
SELECT p.ProductID,
       p.name AS Producto,
       ps.Name AS Subcategoria
FROM Production.Product AS p
left JOIN Production.ProductSubcategory AS ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
where ps.Name is null

select top 5 * from  Sales.SalesOrderHeader
select top 5 * from Sales.Customer
