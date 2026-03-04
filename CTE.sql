
-------------------------Ejemplos de CTE'S-----------------------
-----------------------------------------------------------------

/* 1- Ejemplo sencillo de CTE*/
with  AvgTable as
(select p.ProductSubcategoryID,
ps.name,
avg(p.ListPrice) as promedio,
count (*) as cantidad
from Production.Product p
JOIN  Production.ProductSubcategory ps
on p.ProductSubcategoryID = ps.ProductSubcategoryID
group by  p.ProductSubcategoryID,ps.Name) 

select *
from AvgTable  -- se manda llamar con el alias asignado


/* 2- Ejemplo de CTE*/
WITH AvgTable AS (
    SELECT ProductSubcategoryID,
           AVG(ListPrice) AS Promedio
    FROM Production.Product
    GROUP BY ProductSubcategoryID
), -- se realiza la primera operacion y se asigna un alias
SubcategoryStats AS (
    SELECT ps.Name,
           a.Promedio
    FROM AvgTable a
    JOIN Production.ProductSubcategory ps
      ON a.ProductSubcategoryID = ps.ProductSubcategoryID
) -- se hace join con la primera tabala atravez del alias 
SELECT *
FROM SubcategoryStats;  -- se manda llamar con el ultimo alias , ya trae todo el conjunto de los 2


/* 3- Ejemplo  de CTE*/
WITH VentasPorEmpleado AS (
    SELECT 
        SalesPersonID,
        COUNT(SalesOrderID) AS TotalVentas
    FROM Sales.SalesOrderHeader
    WHERE SalesPersonID IS NOT NULL
    GROUP BY SalesPersonID
)
SELECT 
    e.BusinessEntityID,
    p.FirstName,
    p.LastName,
    v.TotalVentas
FROM Sales.SalesPerson AS e
JOIN Person.Person AS p
    ON e.BusinessEntityID = p.BusinessEntityID
JOIN VentasPorEmpleado AS v
    ON e.BusinessEntityID = v.SalesPersonID
ORDER BY v.TotalVentas DESC;


-------------------------Ejercicios de CTE'S-----------------------
-------------------------------------------------------------------

/--1 *obtener un listado de clientes junto con:
- El total de pedidos que han realizado.
- El monto total gastado en esos pedidos.
- mostrar el nombre completo del cliente junto con sus totales.
- Ordena los resultados por el monto total gastado, de mayor a menor
*/

WITH totalesPorCliente AS
  (SELECT customerid,
          COUNT (salesorderid) TotalPedidos,
                sum(Subtotal) TotalGastado
   FROM Sales.SalesOrderHeader
   GROUP BY CustomerID)-- hasta aqui ya sacamos el total de pedidos y el total gastado

SELECT sc.PersonID,
       pp.FirstName,
       pp.LastName,
       tc.TotalPedidos,
       tc.TotalGastado
FROM sales.Customer sc
JOIN person.person pp 
ON sc.PersonID = pp.BusinessEntityID-- unimos con personID y BussinessEntityID
JOIN totalesPorCliente tc  -- se hace join con el Cte
ON tc.CustomerID = sc.CustomerID
ORDER BY tc.TotalGastado DESC-- se hace un orden desc con el campo del Cte creado


--2 /*obtener un listado de productos junto con:
- El número de veces que han sido vendidos.
- El total de ingresos generados por cada producto.
*/

With VentasPorProducto as (
select 
count(salesOrderID) NumeroVentas,
productid,
sum(LineTotal) TotalIngresos
from sales.SalesOrderDetail
group by ProductID
)
select 
vp.ProductID,
p.name,
vp.NumeroVentas,
vp.TotalIngresos
from VentasPorProducto vp
join production.Product  p
on vp.ProductID = p.ProductID
order by vp.TotalIngresos desc 


WITH EmpleadosJerarquia AS (
    -- Anchor member: selecciona al manager raíz (por ejemplo, el CEO)
    SELECT 
        e.BusinessEntityID,
        e.JobTitle,
        e.OrganizationLevel,
        e.OrganizationNode,
        CAST(e.JobTitle AS VARCHAR(MAX)) AS Jerarquia
    FROM HumanResources.Employee e
    WHERE e.OrganizationLevel = 0  -- nivel más alto

    UNION ALL

    -- Recursive member: busca empleados que dependen del anterior
    SELECT 
        e.BusinessEntityID,
        e.JobTitle,
        e.OrganizationLevel,
        e.OrganizationNode,
        CAST(c.Jerarquia + ' -> ' + e.JobTitle AS VARCHAR(MAX)) AS Jerarquia
    FROM HumanResources.Employee e
    JOIN EmpleadosJerarquia c
        ON e.OrganizationNode.GetAncestor(1) = c.OrganizationNode
)
SELECT *
FROM EmpleadosJerarquia
ORDER BY OrganizationLevel;

--3
WITH EmpleadosJerarquia AS (
    -- Anchor member: selecciona al manager raíz (por ejemplo, el CEO)
    SELECT 
        e.BusinessEntityID,
        e.JobTitle,
        e.OrganizationLevel,
        e.OrganizationNode,
        CAST(e.JobTitle AS VARCHAR(MAX)) AS Jerarquia
    FROM HumanResources.Employee e
    WHERE e.OrganizationLevel = 0  -- nivel más alto

    UNION ALL

    -- Recursive member: busca empleados que dependen del anterior
    SELECT 
        e.BusinessEntityID,
        e.JobTitle,
        e.OrganizationLevel,
        e.OrganizationNode,
        CAST(c.Jerarquia + ' -> ' + e.JobTitle AS VARCHAR(MAX)) AS Jerarquia
    FROM HumanResources.Employee e
    JOIN EmpleadosJerarquia c
        ON e.OrganizationNode.GetAncestor(1) = c.OrganizationNode
)
SELECT *
FROM EmpleadosJerarquia
ORDER BY OrganizationLevel;

--4 /* calcule las ventas totales por producto en Sales.SalesOrderDetail.
Luego selecciona los 5 productos más vendidos.
*/

with ventasProducto as (
select 
sum (LineTotal) VentasTotales,
ProductID
from Sales.SalesOrderDetail
group by ProductID
)
select top 5 *
from ventasProducto
order by VentasTotales desc 


--5 /*Cte que cuente cuántas órdenes ha hecho cada cliente en Sales.SalesOrderHeader.
Después selecciona los 10 clientes más activos.
*/

with OrdenXCliente as (
select 
    CustomerID,
    count (SalesOrderID) ordenPorCliente 
from Sales.SalesOrderHeader 
group by CustomerID
) 
select top 10 * 
from OrdenXCliente 
order by ordenPorCliente desc

 --6 /*Muestra los 10 clientes con más órdenes, pero ahora incluye su nombre:*/

 with OrdenXCliente as (
select 
    so.CustomerID,
    count (so.SalesOrderID) ordenPorCliente 
from Sales.SalesOrderHeader so
group by CustomerID
) 
select 
    ox.CustomerID,
    ox.ordenPorCliente,
    p.FirstName + ' ' + p.LastName FullName -- aqui yo concatene el apellido
from OrdenXCliente ox
join person.Person p
on ox.CustomerID = p.BusinessEntityID
order by ordenPorCliente desc


--7 /*calcula el gasto total por cliente */

with CustomerSales as (-- este - calcula el gasto total por cliente usando SUM(TotalDue)

select
    CustomerID,
   sum(TotalDue) TotalSpent
from Sales.SalesOrderHeader
group by CustomerID
), --aqui se crea un segundo Cte
highSenders as ( -- filtra solo los clientes con gasto mayor a 50,000.
select
    CustomerID,
    TotalSpent
    from 
    CustomerSales
    where TotalSpent > 50000

)
select
    CustomerID,
    TotalSpent
 from 
    highSenders
 order by TotalSpent desc

 --8 /*calcula el gasto total por cliente mostrando tambien el nombre del cliente, si es de persona o de empresa */

select top 5 *
from Sales.SalesOrderHeader

select top 5 *
from Sales.SalesOrderHeader