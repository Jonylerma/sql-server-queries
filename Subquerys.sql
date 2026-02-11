
-------------------------Ejercicios SQL MID-----------------------

-----------------------/*Joins complejos*/------------------------


/*- Lista todos los empleados (HumanResources.Employee) junto con su información personal (Person.Person).
- Incluye también aquellos empleados que no tengan ventas registradas en Sales.SalesPerson (usa LEFT JOIN).*/

select 
e.BusinessEntityID,
p.FirstName,
p.MiddleName,
p.LastName,
sp.SalesQuota as venta
from HumanResources.Employee as e
join Person.Person as p
on e.BusinessEntityID = p.BusinessEntityID
left join sales.SalesPerson as sp
on e.BusinessEntityID = sp.BusinessEntityID
 -- mezcla de Join y Left join

select top 1000 * from HumanResources.Employee

select top 10 * from Person.Person

select top 10 * from sales.SalesPerson

-----------------------------/Subquerys/----------------------------

SELECT AVG(SubTotal) as promedio 
FROM Sales.SalesOrderHeader;

SELECT CustomerID, SUM(SubTotal) AS TotalCompras
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
HAVING SUM(SubTotal) > (
    SELECT AVG(SubTotal) 
    FROM Sales.SalesOrderHeader);


--Ejercicio Clientes con compras mayores al promedio

select
AVG (subtotal) as promedioVenta
 FROM Sales.SalesOrderHeader  -- con este query sacamos el promedio total de las ventas como primer paso
--Esto te devuelve un solo número. Ese valor lo vamos a usar como referencia.
--Ahora agrupamos por cliente para ver cuánto ha comprado cada uno

SELECT CustomerID, 
SUM(SubTotal) AS TotalCompras
FROM Sales.SalesOrderHeader
GROUP BY CustomerID;

--****Comparar contra el promedio usando un subquery****
--- Usamos HAVING para filtrar solo los clientes que superan ese promedio

 SELECT CustomerID, 
SUM(SubTotal) AS TotalCompras
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
having sum(subtotal) > (
select
AVG (subtotal) as promedioVenta
 FROM Sales.SalesOrderHeader)
 /*
•   El subquery  devuelve un único valor escalar.
• 	La consulta principal compara el total de cada cliente contra ese valor.
• 	Resultado: solo aparecen los clientes que gastaron más que el promedio.
*/

--Encuentra el Top 5 clientes con mayor monto total de compras.”


SELECT TOP 5
    c.CustomerID,
    p.FirstName,
    p.LastName,
    SUM(so.SubTotal) AS totalCompras
FROM Sales.Customer c
JOIN Person.Person p
    ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader so
    ON c.CustomerID = so.CustomerID
GROUP BY c.CustomerID, p.FirstName, p.LastName
ORDER BY totalCompras DESC;

/*- los productos (ProductID, Name)
- Solo aquellos cuyo precio de lista (ListPrice) sea mayor al precio promedio de todos los productos.*/

--práctica con  subquery en la cláusula WHERE

select ProductID,
Name,
ListPrice
from 
Production.Product
where ListPrice > (select avg(ListPrice)
from Production.Product) 

/*- calcula el precio promedio por cada categoría de producto, además el número de productos en esa categoría. */
--práctica con  subquery en la cláusula FROM

select *
from 
(select ProductSubcategoryID,
avg(ListPrice) as 
promedio, count (*) as cantidad
from Production.Product 
group by  ProductSubcategoryID)  as AvgTable

-- mostrar el nombre de la subcategoría junto con el promedio de precio y la cantidad de productos.
--Practica Subquery con Join
select *
from 
(select p.ProductSubcategoryID,
ps.name,
avg(p.ListPrice) as promedio,
count (*) as cantidad
from Production.Product p
JOIN  Production.ProductSubcategory ps
on p.ProductSubcategoryID = ps.ProductSubcategoryID
group by  p.ProductSubcategoryID,ps.Name)  as AvgTable

