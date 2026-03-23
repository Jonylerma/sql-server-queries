CREATE TABLE Orders_Staging (
    OrderID INT PRIMARY KEY,
    CustomerName NVARCHAR(100),
    Product NVARCHAR(50),
    Quantity INT,
    Price DECIMAL(10,2),
    OrderDate DATE,
    Status NVARCHAR(20),
    Total DECIMAL(10,2)
);

select * from Orders_Staging

/* mini‑ejercicio de validación:
obtener el Top‑5 clientes por volumen de compras
*/

select top 5
    CustomerName,
    product,
    max(total) as totalcompras
from Orders_Staging
group by CustomerName,
    product
   order by totalcompras desc