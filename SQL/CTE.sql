
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

--1 
    /*obtener un listado de clientes junto con
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


--2 
    /*obtener un listado de productos junto con:
    - El número de veces que han sido vendidos.
    - El total de ingresos generados por cada producto.*/

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

--4 
    /* calcule las ventas totales por producto en Sales.SalesOrderDetail.
    Luego selecciona los 5 productos más vendidos*/

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


--5
    /*Cte que cuente cuántas órdenes ha hecho cada cliente en Sales.SalesOrderHeader.
    Después selecciona los 10 clientes más activos.*/

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

 --6 
    /*Muestra los 10 clientes con más órdenes, pero ahora incluye su nombre:*/

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


--7 
    /*calcula el gasto total por cliente */

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

 --8 
    /*calcula el gasto total por cliente mostrando tambien el nombre del cliente, si es de persona o de empresa 

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
join sales.customer
    on 
 order by TotalSpent desc 
 
 */

 --9 
    /*- CTE1: Calcula ventas totales por producto (SUM(LineTotal) en Sales.SalesOrderDetail).
    - CTE2: Filtra productos con ventas mayores a 100,000.
    - CTE3: Ordena esos productos y selecciona el Top 10.
    La idea es que veas cómo se pueden encadenar varios CTEs para dividir la lógica en pasos claros, igual que un Data Engineer hace en un pipeline ETL */

with Ventas as (
select 
    productid,
    sum(linetotal) as VentasTotales
from Sales.SalesOrderDetail
group by productid
), --Calcula ventas totales por producto
VentasMayores as(
select 
    productid,
    VentasTotales
  from Ventas
  where  VentasTotales > 100000
) --iltra productos con ventas mayores a 100,000
select top 10
   vm.productid,
   p.name as productName,
    vm.VentasTotales
  from VentasMayores vm
  join production.product as p
  on vm.productid = p.productid
  order by vm.VentasTotales  desc --Ordena los productos y selecciona el Top 10 y usa el join para extraer el nombre del producto


  --10
    /*
    - CTE1 (CustomerSales):Calcula el gasto total por cliente
    - CTE2 (CustomerCategories):
        Clasifica clientes en categorías:
        - High → gasto > 100,000
        - Medium → gasto entre 50,000 y 100,000
        - Low → gasto < 50,000
       - SELECT final:
Muestra cuántos clientes hay en cada categoría */
        
with customersales as (
    select 
        CustomerID,
        sum(totaldue) as GastoTotal
    from Sales.SalesOrderHeader
    group by CustomerID
), --Calcula el gasto total por cliente
CustomerCategorias as(
    select 
        CustomerID,
        GastoTotal,
  case 
        when GastoTotal  > 100000 then 'High'
        when GastoTotal  between 50000 and 100000 then'Medium'
        else 'Low'  
  end as Categoria
from customersales
)--Clasifica clientes en categorías con un "case"
select 
    CustomerID,
    GastoTotal,
    categoria
from CustomerCategorias
order by categoria desc


--11
    /* estadísticas por categoría:*/

WITH CustomerSales AS (
    SELECT 
        CustomerID,
        SUM(TotalDue) AS GastoTotal
    FROM Sales.SalesOrderHeader
    GROUP BY CustomerID
),
CustomerCategorias AS (
    SELECT 
        CustomerID,
        GastoTotal,
        CASE 
            WHEN GastoTotal > 100000 THEN 'High'
            WHEN GastoTotal BETWEEN 50000 AND 100000 THEN 'Medium'
            ELSE 'Low'
        END AS Categoria
    FROM CustomerSales
)
SELECT 
    Categoria,
    COUNT(*) AS NumClientes, ---Número de clientes por categoría.
    AVG(GastoTotal) AS PromedioGasto,--Gasto promedio por categoría
    MAX(GastoTotal) AS MaximoGasto,--Gasto máximo y mínimo por categoría (opcional).
    MIN(GastoTotal) AS MinimoGasto
FROM CustomerCategorias
GROUP BY Categoria
ORDER BY PromedioGasto DESC;


-------------------------------CTE recursivo--------------------------------------
----------------------------------------------------------------------------------


--12
    /*recorrer la tabla HumanResources.Employee para obtener todos los subordinados de un manager específico*/

   WITH OrgHierarchy AS (
    -- Anchor: empleados en el nivel más alto (ej. nivel 0)
    SELECT 
        BusinessEntityID,
        JobTitle,
        OrganizationLevel
    FROM HumanResources.Employee
    WHERE OrganizationLevel = 0

    UNION ALL

    -- Recursive: empleados cuyo nivel es inmediatamente inferior
    SELECT 
        e.BusinessEntityID,
        e.JobTitle,
        e.OrganizationLevel
    FROM HumanResources.Employee e
    INNER JOIN OrgHierarchy oh 
        ON e.OrganizationLevel = oh.OrganizationLevel + 1
)
SELECT * 
FROM OrgHierarchy
ORDER BY OrganizationLevel;

select top 5 *
from HumanResources.Employee

select top 5 *
from Sales.customer