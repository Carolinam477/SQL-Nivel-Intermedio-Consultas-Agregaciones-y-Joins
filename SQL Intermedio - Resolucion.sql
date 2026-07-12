-- 1.	¿Cuántas filas hay dentro de la tabla personas?
SELECT COUNT(*) AS TotalFilas
FROM Person.Person;

-- 2.	Indicar la cantidad de empleados cuyos apellidos empiecen con una letra inferior a “D”

SELECT COUNT(*) AS CantidadEmpleados FROM HumanResources.Employee e LEFT JOIN  Person.Person p
	ON  e.BusinessEntityID = p.BusinessEntityID
	WHERE LastName LIKE '[A-C]%';


-- 3.	¿Cuál es el promedio de StandardCost para cada producto donde StandardCost es mayor a $0? (Production.Product)

SELECT  
	AVG(StandardCost) AS PromedioCosto
FROM Production.Product
WHERE StandardCost > 0;

-- 4.	En la tabla personas ¿cuántas personas están asociadas con cada tipo de persona (PersonType)?
SELECT 
	PersonType, 
	COUNT(*) AS CantidadPersonas
FROM Person.Person
GROUP BY PersonType;

-- 5.	¿Cuántos productos en Production.Product hay que son rojos (red) y cuántos que son negros (black)?
SELECT 
	Color, 
	COUNT(*) AS CantidadProductos
FROM Production.Product
WHERE Color IN ('Red', 'Black')
GROUP BY Color;

-- 6.	¿Cuáles son las ventas por territorio para todas las filas de Sales.SalesOrderHeader? 
-- Traer sólo los territorios que se pasen de $10 millones en ventas históricas, traer el total de las ventas y el TerritoryID.
SELECT 
	TerritoryID, 
	SUM(TotalDue) AS TotalVentas
FROM Sales.SalesOrderHeader
GROUP BY TerritoryID
HAVING SUM(TotalDue) > 10000000;

-- 7.	Usando la query anterior, hacer un join hacia Sales.SalesTerritory y reemplazar el TerritoryID con el nombre del territorio. 

SELECT 
	ventas.TerritoryID,
	territorio.Name, 
	SUM(TotalDue) AS TotalVentas
FROM Sales.SalesOrderHeader ventas
INNER JOIN Sales.SalesTerritory territorio
ON ventas.TerritoryID = territorio.TerritoryID
GROUP BY ventas.TerritoryID, territorio.Name
HAVING SUM(TotalDue) > 10000000;

-- 8.	¿Cuántas filas en Person.Person no tienen NULL en MiddleName?

SELECT COUNT(*) AS FilasSinMiddleName
FROM Person.Person
WHERE MiddleName IS NOT NULL;

-- 9.	Usando Production.Product encontrar cuántos productos están asociados con cada color. 
-- Ignorar las filas donde el color no tenga datos (NULL). Luego de agruparlos, devolver sólo los colores que tienen al menos 20 productos en ese color.
SELECT 
	Color, 
	COUNT(*) AS CantidadProductos
FROM Production.Product
WHERE Color IS NOT NULL
GROUP BY Color
HAVING COUNT(*) >= 20;

-- 10.	Hacer un join entre Production.Product y Production.ProductInventory sólo cuando los productos aparecen en ambas tablas. 
-- Hacerlo sobre el ProductID. Production.ProductInventory tiene la cantidad de cada producto, si se vende cada producto con un ListPrice mayor a cero, 
-- ¿cuánto fue el total facturado? 
SELECT 
	SUM(producto.ListPrice * inventario.Quantity) AS TotalFacturado
FROM Production.Product AS producto
INNER JOIN Production.ProductInventory AS inventario 
ON producto.ProductID = inventario.ProductID
WHERE producto.ListPrice > 0;

-- 11.	Traer FirstName y LastName de Person.Person. Crear una tercera columna donde se lea “Promo 1” si el EmailPromotion es 0, 
-- “Promo 2” si el valor es 1 o “Promo 3” si es 2
SELECT 
	FirstName, 
	LastName,
	CASE 
		WHEN EmailPromotion = 0 THEN 'Promo 1'
		WHEN EmailPromotion = 1 THEN 'Promo 2'
		WHEN EmailPromotion = 2 THEN 'Promo 3'
		ELSE 'Otro'
	END AS PromotionType
FROM Person.Person;

-- 12.	Traer el BusinessEntityID y SalesYTD de Sales.SalesPerson, juntarla con Sales.SalesTerritory de tal manera que Sales.SalesPerson 
-- devuelva valores aunque no tenga asignado un territorio. Traes el nombre de Sales.SalesTerritory.
SELECT 
	SP.BusinessEntityID, 
	SP.SalesYTD, 
	ST.Name AS TerritoryName
FROM Sales.SalesPerson AS SP
LEFT JOIN Sales.SalesTerritory AS ST 
ON SP.TerritoryID = ST.TerritoryID;

-- 13.	Usando el ejemplo anterior, vamos a hacerlo un poco más complejo. Unir Person.Person para traer también el nombre y apellido. 
-- Sólo traer las filas cuyo territorio sea “Northeast” o “Central”.
SELECT 
	P.FirstName, 
	P.LastName, 
	SP.BusinessEntityID, 
	SP.SalesYTD, 
	ST.Name AS TerritoryName
FROM Person.Person AS P
RIGHT JOIN Sales.SalesPerson AS SP 
ON P.BusinessEntityID = SP.BusinessEntityID
LEFT JOIN Sales.SalesTerritory AS ST 
ON SP.TerritoryID = ST.TerritoryID
WHERE ST.Name IN ('Northeast', 'Central');

-- 14.	Usando Person.Person y Person.Password hacer un INNER JOIN trayendo FirstName, LastName y PasswordHash.
SELECT 
	P.FirstName, 
	P.LastName, 
	PP.PasswordHash
FROM Person.Person AS P
INNER JOIN Person.Password AS PP 
ON P.BusinessEntityID = PP.BusinessEntityID;

-- 15.	Traer el título de Person.Person. Si es NULL devolver “No hay título”.
SELECT 
	FirstName, 
	LastName,
	CASE
		WHEN Title IS NULL THEN 'No hay titulo' 
		Else Title 
	END AS Title
FROM Person.Person;
-- O
SELECT 
	FirstName, 
	LastName,
	ISNULL(Title, 'No hay titulo') AS Title -- notar que no me permite agregar más de 8 caracteres de esta forma por las caracteristicas de la columna
FROM Person.Person;

-- 16.	Si MiddleName es NULL devolver FirstName y LastName concatenados, con un espacio de por medio. 
-- Si MiddeName no es NULL devolver FirstName, MiddleName y LastName concatenados, con espacios de por medio.
SELECT 
	FirstName, 
	MiddleName,
	LastName,
    CASE 
        WHEN MiddleName IS NULL THEN CONCAT(FirstName, ' ', LastName)
        ELSE CONCAT(FirstName, ' ', MiddleName, ' ', LastName)
    END AS FullName,
	CONCAT_WS(' ',FirstName,MiddleName,LastName) as FullName_v2
FROM Person.Person;

-- 17.	Usando Production.Product si las columnas MakeFlag y FinishedGoodsFlag son iguales, que devuelva NULL. 
-- En caso contrario devolver ambos valores concatenados.
SELECT 
	MakeFlag,
	FinishedGoodsFlag,
    CASE
        WHEN MakeFlag = FinishedGoodsFlag THEN NULL
        ELSE CONCAT(MakeFlag,' ', FinishedGoodsFlag)
    END AS Result
FROM Production.Product;

-- 18.	Usando Production.Product si el valor en color es NULL devolver “Sin color”. Si el color sí está, devolver el color. Se puede hacer de por lo menos dos maneras, desarrollar ambas (buscar funciones ISNULL y COALESCE).

-- Usando CASE
SELECT 
    CASE
        WHEN Color IS NULL THEN 'Sin Color'
        ELSE Color
    END AS Result
FROM Production.Product;

-- Usando ISNULL
SELECT ISNULL(Color, 'Sin color') AS Color
FROM Production.Product;

-- Usando COALESCE
SELECT COALESCE(Color, 'Sin color') AS Color
FROM Production.Product;

-- 19.	Traer el primer nombre y el apellido de los empleados que sean solteros. Resolverlo de 3 formas diferentes: con una CTE, subquery de lista y una de tabla

SELECT * FROM HumanResources.Employee



-- INNER JOIN

SELECT 
	PP.FirstName, 
	PP.LastName
FROM Person.Person AS PP
INNER JOIN HumanResources.Employee AS HRE 
ON PP.BusinessEntityID = HRE.BusinessEntityID
WHERE HRE.MaritalStatus = 'S'

-- SUBQUERY DE LISTA
SELECT FirstName, LastName
FROM Person.Person 
WHERE 
	BusinessEntityID IN (
		SELECT BusinessEntityID
		FROM HumanResources.Employee
		WHERE MaritalStatus = 'S'
	) 

-- SUBQUERY DE TABLA
SELECT PP.FirstName, PP.LastName
FROM Person.Person AS PP
INNER JOIN (
	SELECT *
	FROM HumanResources.Employee
	WHERE MaritalStatus = 'S'
) AS HRE 
ON PP.BusinessEntityID = HRE.BusinessEntityID;

--- CTE
WITH Empleados AS(
	SELECT *
	FROM HumanResources.Employee
	WHERE MaritalStatus = 'S'
)
SELECT
	FirstName,
	LastName
FROM Person.Person person
INNER JOIN Empleados empleados
ON person.BusinessEntityID = empleados.BusinessEntityID;

-- 20.	Traer el ID, nombre,segundo nombre,apellido, fecha de cumpleaños y edad  de los empleados mayores a 30 años.

SELECT * FROM Person.Person

SELECT * FROM HumanResources.Employee

-- EN ESTA LA EDAD ESTA MAL CALCULADA PORQUE NO CONSIDERA SI YA CUMPLITE AÑOS O NO EL AÑO QUE CORRE. 

SELECT 
	empleado.BusinessEntityID, 
	FirstName, 
	LastName,
	BirthDate,
	DATEDIFF(YEAR, BirthDate, GETDATE()) AS Edad
FROM HumanResources.Employee empleado
INNER JOIN Person.Person persona
ON empleado.BusinessEntityID = persona.BusinessEntityID
WHERE DATEDIFF(YEAR, BirthDate, GETDATE()) > 30
ORDER BY BirthDate DESC;


-- SOLUCION CORRECTA:

SELECT 
	empleado.BusinessEntityID, 
	FirstName, 
	LastName,
	BirthDate,
	YEAR(GETDATE()) - YEAR(BirthDate) 
    - CASE 
        WHEN FORMAT(BirthDate, 'MMdd') > FORMAT(GETDATE(), 'MMdd') 
        THEN 1 
        ELSE 0 
      END AS Edad
FROM HumanResources.Employee empleado
INNER JOIN Person.Person persona
ON empleado.BusinessEntityID = persona.BusinessEntityID
WHERE YEAR(GETDATE()) - YEAR(BirthDate) 
    - CASE 
        WHEN FORMAT(BirthDate, 'MMdd') > FORMAT(GETDATE(), 'MMdd') 
        THEN 1 
        ELSE 0 
      END > 30
ORDER BY BirthDate DESC;



-- EJERCICIOS EXTRA : 



-- 21.	Indicar el número de entidad de negocio y los tres primeros números del número de identificación nacional de cada uno de los empleados. Renombrar la nueva columna como id_tres.
-- Keywords: BusinessEntityId, NationalIDNumber, HumanResources.Employee.
SELECT 
	BusinessEntityID, 
	NationalIDNumber,
	LEFT(NationalIDNumber, 3) AS id_tres
FROM HumanResources.Employee;

-- 22.	Indicar el id de dirección, la línea 1 de dirección (Addressline1) y los cuatro últimos dígitos del código postal de cada dirección registrada y 
-- renombrarla postal_4. Eliminar los espacios en el inicio y el final de los valores resultantes de addressline1. 
-- Keywords: addressid, Addresline1, postalcode,person.Address
SELECT 
	AddressID, 
	AddressLine1,
	TRIM(AddressLine1) AS AddressLine1,
	PostalCode,
	RIGHT(PostalCode, 4) AS postal_4
FROM Person.Address;

-- 23.	Indicar el id de provincia-estado y la concatenación de los campos codigo de region-país, nombre y código de provincia-estado.  
-- El resultado debe utilizar dos separadores: primero barra inclinada (/) y luego guión (-). Ejemplo: CA/California-CA. 
-- Renombrar la nueva columna como región. Los resultados de la nueva columna deben estar en mayúsculas. 
-- Keywords: stateprovinceid, countryregioncode, name, stateprovinceid, Person.stateProvince
SELECT 
	StateProvinceID, 
	UPPER(CONCAT(CountryRegionCode, '/', Name, '-', StateProvinceCode)) AS región
FROM Person.StateProvince;

-- 24.	indicar el id de la foto producto y el nombre de archivo de foto. Reemplazar el tipo de archivo gif por jpeg en cada uno de los registros. 
-- Renombrar la nueva columna como foto. 
-- Keywords: productphotoid, thumbnailphotofilename, productphoto,production.ProductPhoto
SELECT 
	ProductPhotoID, 
	ThumbnailPhotoFileName,
	REPLACE(ThumbnailPhotoFileName, '.gif', '.jpeg') AS foto
FROM Production.ProductPhoto;

-- 25.	Indicar el código de unidad de medida, el nombre y el año en el que fue modificado cada registro. Renombrar la nueva columna como anio_modificacion.
-- Keywords: unitmeasurecode, name, modifieddate, production.unitMeasure.
SELECT 
	UnitMeasureCode, 
	Name, 
	YEAR(ModifiedDate) AS anio_modificacion
FROM Production.UnitMeasure;

-- 26.	Indicar el id de tarjeta de crédito, el tipo de tarjeta y el mes en el que fue modificado cada registro almacenado para las tarjetas de crédito. 
-- Renombrar a la nueva columna Mes_modificacion. 
-- Keywords: Creditcardid, cardtype, modifieddate, creditcard, sales.CreditCard.
SELECT 
	CreditCardID, 
	CardType, 
	ModifiedDate,
	MONTH(ModifiedDate) AS Mes_modificacion
FROM Sales.CreditCard;

-- 27.	Indicar el id del producto,la suma de la cantidad de producto y el día de la semana(ej: lunes, martes, etc) de la transacción. 
-- Ordenar descentente por id producto. Prestar atención a la agrupación para que solo aparezca un día de la semana por producto 
-- Keywords: transactionid, referenceorderid, transactiondate, transactionhistoryarchive, production.TransactionHistoryArchive.

--set language spanish
SELECT 
	ProductID,
    DATENAME(WEEKDAY, TransactionDate) AS DiaSemana, 
	SUM(Quantity) AS TotalCantidad
FROM Production.TransactionHistoryArchive
GROUP BY ProductID, DATENAME(WEEKDAY, TransactionDate)
ORDER BY ProductID DESC;

-- 28.	Indicar el id de orden de pedido, la fecha de inicio y cual seria la fecha de entrega, si cada orden debe ser recibida 30 días después de su inicio. 
-- Consultar para cada orden de pedido registrada. Renombrar la nueva columna como entrega_estimada.
-- Keywords: workorderid, startdate, workorder, production.workOrder.
SELECT 
	WorkOrderID, 
	StartDate,
	DATEADD(DAY, 30, StartDate) AS entrega_estimada
FROM Production.WorkOrder;

-- 29.	Indicar el id de orden de pedido y cuántos dias hay entre la fecha programada de inicio y la fecha programada de fin, 
-- para los id de orden comprendidos entre 72060 y 72070. Se requiere la información correspondiente a la máxima fecha de registro, 
-- sin agregar la fecha de forma manual. Renombrar la nueva columna como diferencia_dias. 
-- Keywords: workorderid, scheduledstartdate, scheduledenddate, modifieddate, production.WorkOrderRouting

SELECT TOP 1
	WorkOrderID, 
	DATEDIFF(DAY, ScheduledStartDate, ScheduledEndDate) AS diferencia_dias
FROM Production.WorkOrderRouting
WHERE WorkOrderID BETWEEN 72060 AND 72070
ORDER BY ModifiedDate DESC;

-- 30.	Para el número de orden 43659: Indicar el número de orden de venta y el número entero correspondiente al precio unitario de 
-- todos los registros de los detalles de ventas. Se requiere la información correspondiente a la mínima fecha de registro, 
-- sin agregar la condición de fecha de forma manual. Renombrar la nueva columna como precio_en_enteros. 
-- Keywords: salesorderid, unitprice, salesorderdetail, modifieddate, Sales.salesOrderDetail

SELECT TOP 1
	SalesOrderID, 
	UnitPrice,
	CAST(FLOOR(UnitPrice) AS INT),
	CAST(UnitPrice AS INT) AS precio_en_enteros
FROM Sales.SalesOrderDetail
WHERE SalesOrderID = 43659
ORDER BY ModifiedDate ASC;