------------------Joins-------------------------------------
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

----------------------Left Joins---------------------------------

/*Productos sin subcategoría*/
SELECT p.ProductID,
       p.name AS Producto,
       ps.Name AS Subcategoria
FROM Production.Product AS p
left JOIN Production.ProductSubcategory AS ps 
ON p.ProductSubcategoryID = ps.ProductSubcategoryID
where ps.Name is null


/*Quieres listar TODOS los productos,
y si tienen subcategoría, mostrar solo las que se llamen 'Bikes'.*/

SELECT p.ProductID,
       p.name AS Producto,
       ps.Name AS Subcategoria
FROM Production.Product AS p
 left JOIN Production.ProductSubcategory AS ps 
 ON p.ProductSubcategoryID = ps.ProductSubcategoryID and ps.Name like '%Bikes%'
 --on p.ProductSubcategoryID = ps.name "Bikes
--where ps.Name is null

select top 5 * from  Sales.SalesOrderHeader
select top 5 * from Sales.Customer


----------------------JOIN + GROUP BY + HAVING---------------------------------

/*Quieres obtener todos los clientes, y:
Mostrar cuántas órdenes tiene cada uno
Incluir clientes sin órdenes
Mostrar 0 cuando no tengan órdenes*/

select c.CustomerID ,
        count (so.SalesOrderID) as TotalOrden
from Sales.Customer as c
left Join Sales.SalesOrderHeader as so
on c.CustomerID = so.CustomerID 
group by c.CustomerID

/*Mostrar solo clientes con MÁS de 5 órdenes*/

select c.CustomerID ,
        count (so.SalesOrderID) as TotalOrden
from Sales.Customer as c
left Join Sales.SalesOrderHeader as so
on c.CustomerID = so.CustomerID 
group by c.CustomerID
having count (so.SalesOrderID) >5


----------------------------------------------JOINs (nivel entrevista)---------------------------------------------------------------------

/*Muestra:
ProductID
Nombre del producto
Total de unidades vendidas
*/

select p.ProductID,
       p.name,
      coalesce( sum (so.OrderQty),0) as totalUnidadesVendidas
from Production.Product as p
 left join Sales.SalesOrderDetail as so
on p.ProductID = so.ProductID
group by p.ProductID,
         p.Name

/*Obtén solo los productos que no tienen ninguna venta*/
select p.ProductID,
       p.name,
   coalesce(sum(so.OrderQty),0) as totalUnidadesVendidas --coalesce reemplaza con 0 el null
from Production.Product as p
 left join Sales.SalesOrderDetail as so
on p.ProductID = so.ProductID
group by p.ProductID,
         p.Name
having sum(so.OrderQty) is null

/*Productos con ventas mayores a 100 unidades*/
select p.name,
       coalesce( sum (so.OrderQty),0) as totalUnidadesVendidas
from Production.Product as p
  join Sales.SalesOrderDetail as so
on p.ProductID = so.ProductID
group by p.ProductID,
         p.Name
having sum(so.OrderQty) >  100

/*Corrige esta query para que NO pierda productos sin ventas:*/

SELECT 
    p.Name,
    SUM(od.OrderQty) AS TotalVendido
FROM Production.Product p
LEFT JOIN Sales.SalesOrderDetail od
    ON p.ProductID = od.ProductID
WHERE od.OrderQty > 5
GROUP BY p.Name;


