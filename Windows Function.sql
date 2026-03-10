
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
    offset 0 rows fetch next 10 rows only



   select top 5 *
   from sales.SalesOrderHeader
