
----------------------Windows Function----------------------------
------------------------------------------------------------------
-- group by
select Color, sum(ListPrice) as TotalPrecio
from Production.Product
group by Color;

--WF
select ProductID,
       Name,
       Color,
       sum(ListPrice) over (partition by Color) as TotalPrecioPorColor
from Production.Product;

/*Ejemplo 1: SUM() OVER() (el más importante)
 Total de unidades vendidas por producto, sin perder detalle*/

 select SalesOrderID,
       ProductID,
       OrderQty,
       sum(OrderQty) over (partition by ProductID) as TotalPorProducto
from Sales.SalesOrderDetail ;

/*ROW_NUMBER() (muy de entrevista)
Asigna un número a cada fila.*/

select ProductID,
       Name,
       ListPrice,
       row_number() over (order by ListPrice desc) as Numero
from Production.Product;

/*PARTITION BY + ROW_NUMBER()
 Ranking por grupo*/

 select Color,
       Name,
       ListPrice,
       row_number() over (
           partition by Color
           order by ListPrice desc
       ) as RankingPorColor
from Production.Product;


--------------------------------Ejercicios (nivel principiante)----------------
-------------------------------------------------------------------------------

--Ejercicio 1
    /*Para cada producto, mostrar:
    ProductID
    Name
    ListPrice
    Precio promedio de todos los productos */

select
ProductID,
name,
avg(ListPrice)over () as PrecioPromedioProducto
from Production.Product;

--Ejercicio 2
    /*Ranking de clientes por gasto total
    Queremos obtener un ranking de los clientes según su gasto (SUM(TotalDue)), usando ROW_NUMBER() o RANK().
    - Calculamos el gasto total por cliente.
    - Usamos una función de ventana para asignar un ranking.
    - Mostramos el Top 10 clientes con mayor gasto.*/

   
 with ranking as (
 select 
    CustomerID,
    sum(totalDue) as GastoTotal  
 from sales.SalesOrderHeader
 group by CustomerID
 )
 select 
    r.CustomerID,
   r.GastoTotal  ,
    rank() over (order by r.GastoTotal desc) as ran
    from ranking as r
    join sales.customer c 
    on r.CustomerID = c.CustomerId
    order by ran
    offset 0 rows fetch next 10 rows only --offset indica que arrancamos desde el 0 y fetch next, hasta los 10 resultados. " es como el limit"

--Ejercicio 3 
    /*obtener el Top‑3 empleados con mayor salario en cada departamento*/
    WITH RankedEmployees AS (
    SELECT 
        d.Name AS Department,
        e.BusinessEntityID,
        p.FirstName,
        p.LastName,
        e.JobTitle,
        eph.Rate,
        RANK() OVER (PARTITION BY d.Name ORDER BY eph.Rate DESC) AS RankNum
    FROM HumanResources.Employee AS e
    JOIN HumanResources.EmployeeDepartmentHistory AS edh
        ON e.BusinessEntityID = edh.BusinessEntityID
    JOIN HumanResources.Department AS d
        ON edh.DepartmentID = d.DepartmentID
    JOIN Person.Person AS p
        ON e.BusinessEntityID = p.BusinessEntityID
    JOIN HumanResources.EmployeePayHistory AS eph
        ON e.BusinessEntityID = eph.BusinessEntityID
    WHERE edh.EndDate IS NULL
      AND eph.RateChangeDate = (
          SELECT MAX(RateChangeDate)
          FROM HumanResources.EmployeePayHistory
          WHERE BusinessEntityID = e.BusinessEntityID
      )
)
SELECT *
FROM RankedEmployees
WHERE RankNum <= 3
ORDER BY Department, RankNum;

-- Ejercicio 4
    /*Top‑5 clientes por monto de compras*/


with Customers as (
select 
    c.customerid,
    p.FirstName,
    p.LastName,
   sum(so.TotalDue) montoTotal,
   rank() over (order by sum(so.TotalDue) desc) as monto-- usamos order by, para ordenar de mayor a menor y el rank para asigna un numero de order segun order by
from Sales.SalesOrderHeader so
join Sales.Customer c
on so.customerid = c.customerid
join Person.Person p
on c.PersonID = p.BusinessEntityID
group by 
     c.customerid,
    p.FirstName,
    p.LastName
)
select *
from Customers
WHERE monto <= 5

--Ejercicio 5
    /*Top‑3 productos más vendidos por categoría */

with MasVendidos as (
    select 
       sum(so.OrderQty) as totalVendidos,
       dense_rank () over (
            partition by ps.name
            order by sum(so.OrderQty) desc 
            ) as ranking ,
        ps.Name as categoria,
         p.Name as producto
    from Sales.SalesOrderDetail so
    join production.Product p
    on so.ProductID = p.ProductID
    join production.ProductSubcategory ps
    on p.productSubcategoryID = ps.productSubcategoryID
    group by 
        ps.name,
         p.Name 
       )
    select *
        from 
        MasVendidos
    where ranking < = 3

-- ejercicio 6
    /*Esto es muy útil para análisis tipo segmentación de clientes/productos, porque puedes 
    identificar no solo el top y bottom, sino también los rangos intermedios (ejemplo: en este caso son 4, se divide en porcentaje
    de 25% el 1 es el 25% top y el ultimo 25% es el mas bajo).*/

WITH Cuartiles AS (
    SELECT 
        ps.Name AS categoria,
        p.Name AS producto,
        SUM(so.OrderQty) AS totalVendidos,
        NTILE(4) OVER ( -- aqui estamos usando este comando que hace que se divida por filas en grupos iguales, en este caso 4, se puede por muchos mas
            PARTITION BY ps.Name
            ORDER BY SUM(so.OrderQty) DESC
        ) AS cuartil
    FROM Sales.SalesOrderDetail so
    JOIN Production.Product p
        ON so.ProductID = p.ProductID
    JOIN Production.ProductSubcategory ps
        ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    GROUP BY ps.Name, p.Name
)
SELECT *
FROM Cuartiles
ORDER BY categoria, cuartil, totalVendidos DESC;




   select top 2 *
   from   Sales.SalesOrderDetail 

   select top 2 *
   from  production.Product

    select top 2 *
   from production.ProductSubcategory