
--Ejercicio 1
	/*: ventas totales por producto*/

	select 
*			--estaremos usando la tabla factorders creada en el primer ejercicio
from FactOrders


select 
	Product,
	sum(Quantity) as unidadesVendidas,
	sum (total) as ventatotal
from FactOrders
group by product
order by ventatotal desc

-- Ejercicio 2
	/* reporte de ventas mensuales usando la columna OrderDate de tu tabla FactOrders.*/

	select 
	format(OrderDate, 'yyyy-MM') as Mes, -- este formato de fecha lo deja con año y mes
	sum(Quantity) as unidadesVendidas,
	sum (total) as ventatotal
from FactOrders
group by format(OrderDate, 'yyyy-MM')
order by Mes desc

--Ventas por producto y mes


	select 
	product,
	format(OrderDate, 'yyyy-MM') as Mes, -- este formato de fecha lo deja con año y mes
	sum(Quantity) as unidadesVendidas,
	sum (total) as ventatotal
from FactOrders
group by format(OrderDate, 'yyyy-MM'),product
order by Mes ,ventatotal desc

-- Ejercicio 3
	/*calcular el Top‑3 productos por mes*/


with VentasporMes as ( select  -- se crea el primer cte, con las ventas por mes
	product,
	format(OrderDate, 'yyyy-MM') as Mes, 
	sum(Quantity) as unidadesVendidas,
	sum (total) as ventatotal
from FactOrders
group by format(OrderDate, 'yyyy-MM'),product
),
ranking as ( -- se crea el segundo Cte con la windows function
select
		mes,
		product,
		unidadesVendidas,
		ventatotal,
		DENSE_RANK() over (partition by mes order by ventatotal desc ) as producto -- aqui se aplica
from VentasporMes
)
select * 
from ranking 
where producto  <= 3 -- filtramos con menos = a 3
	order by mes desc

--Ejercicio 4
	/*calcular las ventas acumuladas por producto*/

WITH VentasporMes AS (
    SELECT  
        product,
        DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1) AS Mes,
        SUM(Quantity) AS unidadesVendidas,
        SUM(total) AS ventatotal
    FROM FactOrders
    GROUP BY 
        product,
        DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1)
)
SELECT 
    mes,
    unidadesVendidas,
    ventatotal,
    SUM(ventatotal) OVER (
        PARTITION BY product 
        ORDER BY mes
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS ventasacumuladas
FROM VentasporMes
ORDER BY product, mes;

select 
	*
from FactOrders
--
