-- NOTAS !!!!!!
-- LEER LOS COMENTARIOS
-- EST�N LOS SP CON SQL DIN�MICO Y NORMAL, LOS DEJE POR LAS DUDAS(LOS NORMALES)
-- ALGUNAS VECES CUANDO SE RESETEA EL IDENTITY DSP EMPIEZA EN 0 (Y NO EN 1, COMO DEBERIA) NO SE PQ, SI ALGUNO SABE BIEN SINO LE PREGUNTAMOS AL PROFE
-- TODO LO QUE ESTA ACA ANDA (POR AHI HAYA QUE MODIFICAR COSAS) PERO SI NO LES "COMPILA" O TIENEN ERRORES AVISEN Y LO VEMOS, PQ LO PROBE Y ANDA TODO
-- MODIFICAR LOS BITS DE UF PARA QUE PERMITA SI O NO
-- AGREGAR NOMBRE CONSORCIO EN UF PARA QUE SEA MAS F�CIL PARA FUTURAS RELACIONES 
create database Com5600G02
go 

use Com5600G02
go

--Hay que crear schemas??

------------------- TESTING ---------------------
drop table if exists estadoFinanciero 
go
drop table if exists personaUf
go
drop table if exists gastoOrdinario
go
drop table if exists gastoExtraordinario
go
drop table if exists estadoCuentaProrrateo
go
drop table if exists pago
go
drop table if exists gasto
go
drop table if exists expensa
go
drop table if exists persona
go
drop table if exists unidadFuncional 
go
drop table if exists gastoOrdinario
go
drop table if exists proveedor
go
drop table if exists consorcio
go 
--------------------------------------------------
-- Cambios en tablas que me parecieron correctos:  
-- incremental en la mayoria de las tablas
create table pago (
	id_pago int identity(1,1) primary key not null,
	fecha date,
	cuenta_origen varchar(50),
	importe decimal(10,2),
	asociado char(2) not null,
    id_detalleDeCuenta int null);
go 

create table consorcio (
	id_consorcio int identity(1,1) primary key,
	nombre varchar(35),
	direccion varchar(35),
	cant_uf int,
	cant_m2 int,);
go

create table persona (
	id_persona int identity(1,1) primary key,
	nombre varchar(50),
	apellido varchar(50),
	dni varchar(9) unique,
	email_personal varchar(50),
	telefono_contacto varchar(20),
	cuenta varchar(50),);
go

create table estadoFinanciero (
	id int identity(1,1),
	id_consorcio int,
	saldo_anterior decimal(10,2),
	ingreso_expensas_termino decimal(10,2),
	ingreso_expensas_adeudadas decimal(10,2),
	ingreso_expensas_adelantadas decimal(10,2),
	egreso decimal(10,2),
	saldo_cierre decimal(10,2),
	periodo date,
	primary key (id, id_consorcio),
	constraint fk_estadoFinanciero_id_consorcio foreign key (id_consorcio) references consorcio (id_consorcio));
go
-- en per�odo cambiar�a el tipo de dato 

create table unidadFuncional (
	id_uf int identity(1,1) primary key, --LE AGREGE EL IDENTITY(1,1) POR QUE SINO, NO PODIA IMPORTAR Y HACER CC ERA MUY COMPLEJO PARA TESTAR
	id_consorcio int, -- fk
	cuenta_origen varchar(50),
	numero_uf int,
	piso varchar(3),
	depto varchar(5),
	cochera bit,
	cochera_m2 int,
	baulera bit,
	baulera_m2 int,
	cant_m2 int,
	coeficiente decimal (2,1),
	constraint fk_uf_id_consorcio foreign key (id_consorcio) references consorcio (id_consorcio));
go 

-- el unique ese esta raro deber�a funcionar para evitar solapamientos
create table personaUf (
	id_relacion int identity(1,1) primary key,
	dni_persona varchar(9),
	id_uf int,
	fecha_desde date,
	fecha_hasta date,
	tipo_responsable varchar (11),
	unique (id_uf, dni_persona, fecha_desde, fecha_hasta),
	constraint fk_personaUf_dni foreign key (dni_persona) references persona (dni),
	constraint fk_personaUf_id_uf foreign key (id_uf) references unidadFuncional (id_uf)
	);
go

create table expensa (
	id_expensa int identity(1,1) primary key,
	id_consorcio int,
	periodo varchar (10) not null,
	constraint fk_expensa_id_consorcio foreign key (id_consorcio) references consorcio (id_consorcio),
    );
go

create table gasto (
	id_gasto int identity(1,1) primary key,
	id_expensa int,
	periodo varchar (10),
	subtotal_ordinarios decimal(10,2),
	subtotal_extraordinarios decimal(10,2)
	constraint fk_gasto_id_expensa foreign key (id_expensa) references expensa (id_expensa),
    );
go
-- lo mismo con el tipo de dato periodo

create table estadoCuentaProrrateo (
	id_detalleDeCuenta int identity (1,1) primary key,
	id_expensa int,
	id_uf int,
	id_pago int,
	fecha_emision date,
	fecha_1er_venc date,
	fecha_2do_venc date,
	saldo_anterior decimal(10,2),
	pagos_recibidos decimal(10,2),
	deuda decimal(10,2),
	interes_por_mora decimal(10,2),
	expensas_ordinarias decimal(10,2),
	expensas_extraordinarias decimal(10,2),
	total_pagar decimal(10,2),
	constraint fk_estadoCuentaProrrateo_id_expensa
	foreign key (id_expensa) references expensa (id_expensa),
	constraint fk_estadoCuentaProrrateo_id_uf
	foreign key (id_uf) references unidadFuncional (id_uf),
	constraint fk_estadoCuentaProrrateo_id_pago
	foreign key (id_pago) references pago (id_pago));
go  

--subtipo gasto es por si es de limpieza
--nrofactura lo cambie a int
--le agregue la fecha del gasto
create table gastoOrdinario (
	id_gastoOrdinario int identity(1,1) primary key,
	id_gasto int,
	tipo_gasto varchar(50),
	subtipoGasto varchar(50),
	nombre_empresa varchar(200),
	nro_factura int,
	importe decimal(18,2),
	constraint fk_gastoOrdinario_id_gasto 
	foreign key (id_gasto) references gasto (id_gasto),
	);
go

create table gastoExtraordinario (
	id_gastoExtraordinario int identity (1,1) primary key,
	id_gasto int,
	id_consorcio int,
	tipo_gasto varchar(50),
	fecha_gasto date,
	descripcion varchar(50),
	forma_pago varchar(15),
	cuota varchar(15),
	importe decimal(10,2),
	constraint fk_gastoExtraordinario_id_gasto 
	foreign key (id_gasto) references gasto (id_gasto),
	constraint fk_gastoExtraordinario_id_consorcio 
	foreign key (id_consorcio) references consorcio (id_consorcio)
	);
go



create table proveedor (  --Cambiar a "proveedor"
	id_proveedor int identity(1,1) primary key,
	id_consorcio int,
	tipo_gasto varchar(50),
	nombre_empresa varchar(100),
	alias varchar(50),
	constraint fk_proveedor_id_consorcio 
	foreign key (id_consorcio) references consorcio (id_consorcio)
	);
go


--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------  STORED PROCEDURES  ---------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------

--CARGAR PERSONAS CON SQL DIN�MICO PARA LA RUTA DE ACCESO
CREATE OR ALTER PROCEDURE sp_importar_personas
    @RutaArchivoPersonas VARCHAR(255)  -- Par�metro de entrada para la ruta del archivo
AS
BEGIN
   CREATE TABLE #tempPersona (
		nombre varchar(50),
		apellido varchar(50),
		dni varchar(9),
		email_personal varchar(50),
		telefono_contacto varchar(20),
		cuenta varchar(50),
		inquilino bit,);

    -- Declarar una variable para el SQL din�mico
    DECLARE @sql_dinamicoPer NVARCHAR(MAX);

    -- Construir la instrucci�n BULK INSERT usando el par�metro
    SET @sql_dinamicoPer = 
        'BULK INSERT #tempPersona ' + 
        'FROM ''' + @RutaArchivoPersonas + ''' ' +  -- Importante: se usan dos comillas simples ('') para la ruta
        'WITH ( ' +
            'FIELDTERMINATOR = '';'', ' +
            'ROWTERMINATOR = ''\n'', ' +
            'FIRSTROW = 2 ' +
        ');';

    -- Ejecutar la importaci�n (requiere permisos 'BULK ADMIN' o 'ADMINISTRATOR')
    EXEC sp_executesql @sql_dinamicoPer;
	-- Quitar duplicados dentro del CSV
    WITH cte_sin_duplicados AS (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY dni ORDER BY (SELECT NULL)) AS fila
        FROM #tempPersona
    )
    DELETE FROM cte_sin_duplicados WHERE fila > 1;
  
    INSERT INTO persona (nombre, apellido, dni, email_personal, telefono_contacto, cuenta)
	SELECT UPPER(LTRIM(RTRIM(nombre))), UPPER(LTRIM(RTRIM(apellido))), LTRIM(RTRIM(dni)), 
		LOWER(REPLACE(LTRIM(RTRIM(email_personal)), ' ', '')), LTRIM(RTRIM(telefono_contacto)), REPLACE(LTRIM(RTRIM(cuenta)), ' ', '')
	FROM #tempPersona t
   WHERE 
        ISNULL(dni, '') <> ''  -- Evita DNIs vac�os
        AND NOT EXISTS (SELECT 1 FROM persona p WHERE p.dni = t.dni); -- Evita duplicados
END;
GO

-------------------------------------------------------------------------
-- Ejemplo de ejecuci�n (debe estar en el script de testing/invocaciones)
DECLARE @archivo_personas VARCHAR(255) = ''; --<----RUTA DE ACCESO Inquilino-propietarios-datos.csv

-- Restablece el IDENTITY para la prueba
DELETE FROM persona; 
DBCC CHECKIDENT ('persona', RESEED, 0);

-- Ejecuta el SP pasando la variable con la ruta del archivo
EXEC sp_importar_personas @RutaArchivoPersonas = @archivo_personas;

-- Verificaci�n
SELECT * FROM persona; 
GO
--------------------------------------------------------------------------------------------------------------------------------------------

--CARGAR CONSORCIOS CON SQL DIN�MICO PARA LA RUTA DE ACCESO
CREATE OR ALTER PROCEDURE sp_importar_consorcios
    @RutaArchivo VARCHAR(255)  -- Par�metro de entrada para la ruta del archivo
AS
BEGIN
    CREATE TABLE #tempConsorcio (
		num_consorcio varchar(12),
		nombre varchar(35),
		direccion varchar(35),
		cant_uf int,
		cant_m2 int,);

    -- Declarar una variable para el SQL din�mico
    DECLARE @sql_dinamico NVARCHAR(MAX);

    -- Construir la instrucci�n BULK INSERT usando el par�metro
    SET @sql_dinamico = 
        'BULK INSERT #tempConsorcio ' + 
        'FROM ''' + @RutaArchivo + ''' ' +  -- Importante: se usan dos comillas simples ('') para la ruta
        'WITH ( ' +
            'FIELDTERMINATOR = '';'', ' +
            'ROWTERMINATOR = ''\n'', ' +
            'FIRSTROW = 2 ' +
        ');';

    -- Ejecutar la importaci�n (requiere permisos 'BULK ADMIN' o 'ADMINISTRATOR')
    EXEC sp_executesql @sql_dinamico;

    -- Insertar en la tabla final consorcio con transformaciones
    -- Nota: Aqu� se asume que la tabla 'consorcio' no admite duplicados (lo que debes validar)
    INSERT INTO consorcio (nombre, direccion, cant_uf, cant_m2)
	SELECT UPPER(LTRIM(RTRIM(nombre))), UPPER(LTRIM(RTRIM(direccion))), cant_uf, cant_m2
	FROM #tempConsorcio 

END
GO

-------------------------------------------------------------------------
-- Ejemplo de ejecuci�n (debe estar en el script de testing/invocaciones)
DECLARE @archivo_consorcios VARCHAR(255) = ''; --<----RUTA DE ACCESO datos varios 1(Consorcios).csv

-- Restablece el IDENTITY para la prueba
DELETE FROM consorcio; 
DBCC CHECKIDENT ('consorcio', RESEED, 0);

-- Ejecuta el SP pasando la variable con la ruta del archivo
EXEC sp_importar_consorcios @RutaArchivo = @archivo_consorcios;

-- Verificaci�n
SELECT * FROM consorcio;
GO
--------------------------------------------------------------------------------------------------------------------------------------------

--CARGAR UF CON SQL DIN�MICO PARA LA RUTA DE ACCESO
CREATE or ALTER PROCEDURE sp_importar_uf
    @RutaArchivoUF VARCHAR(255)  -- Par�metro de entrada para la ruta del archivo
AS
BEGIN
    CREATE TABLE #tempUf ( 
		nombre_consorcio varchar(35),
		numero_uf varchar(10),
		piso varchar(10),
		depto varchar(10),
		coeficiente varchar(10),
		uf_m2 varchar(10),
		baulera varchar(10),
		cochera varchar(10),
		baulera_m2 varchar(10),
		cochera_m2 varchar(10));

    -- Declarar una variable para el SQL din�mico
    DECLARE @sql_dinamicoUF NVARCHAR(MAX);

    -- Construir la instrucci�n BULK INSERT usando el par�metro
    SET @sql_dinamicoUF = 
        'BULK INSERT #tempUf ' + 
        'FROM ''' + @RutaArchivoUF + ''' ' +  -- Importante: se usan dos comillas simples ('') para la ruta
        'WITH ( ' +
            'FIELDTERMINATOR = ''\t'', ' +
            'ROWTERMINATOR = ''\n'', ' +
            'FIRSTROW = 2, ' +
			'CODEPAGE = ''65001'' '+
        ');';

    -- Ejecutar la importaci�n (requiere permisos 'BULK ADMIN' o 'ADMINISTRATOR')
    EXEC sp_executesql @sql_dinamicoUF;

    -- Insertar en la tabla final unidadfuncional con transformaciones
    -- Nota: Aqu� se asume que la tabla 'unidadfuncional' no admite duplicados (lo que debes validar)
    INSERT INTO unidadFuncional (id_consorcio, numero_uf, piso, depto, cochera, cochera_m2, baulera, baulera_m2, cant_m2, coeficiente)
	SELECT    UPPER(c.id_consorcio), CAST(u.numero_uf AS INT), CAST(u.piso AS varchar(3)), CAST(u.depto as varchar(5)), 
        CASE WHEN u.cochera = 'SI' THEN 1 ELSE 0 END, CAST(u.cochera_m2 AS INT), CASE WHEN u.baulera = 'SI' THEN 1 ELSE 0 END, 
        CAST(u.baulera_m2 as INT), CAST(u.uf_m2 AS INT), CAST(REPLACE(u.coeficiente, ',', '.') AS decimal (2,1))
	FROM #tempUf u
	JOIN consorcio c ON c.nombre = u.nombre_consorcio;
END;
GO

-------------------------------------------------------------------------
-- Ejemplo de ejecuci�n (debe estar en el script de testing/invocaciones) 
DECLARE @archivo_uf VARCHAR(255) = '';--<----RUTA DE ACCESO UF por consorcio.txt

-- Restablece el IDENTITY para la prueba
DELETE FROM unidadFuncional; 
DBCC CHECKIDENT ('unidadFuncional', RESEED, 0);

-- Ejecuta el SP pasando la variable con la ruta del archivo
EXEC sp_importar_uf @RutaArchivoUF = @archivo_uf;

-- Verificaci�n
SELECT * FROM unidadFuncional;
GO
-------------------------------------------------------------------------

-- SP PARA CARGAR cuenta_origen EN unidadFuncional
CREATE OR ALTER PROCEDURE sp_asociar_cuentas_uf
    @RutaArchivoCuentas VARCHAR(255) 
AS
BEGIN
    
    CREATE TABLE #tempCuentasUF (
        CVU_CBU VARCHAR(50),
        NombreConsorcio VARCHAR(50),
        nroUnidadFuncional VARCHAR(10),
        piso VARCHAR(5),
        departamento VARCHAR(5)
    );

    DECLARE @sql_dinamicoCuentas NVARCHAR(MAX);

    SET @sql_dinamicoCuentas =
        'BULK INSERT #tempCuentasUF ' +
        'FROM ''' + @RutaArchivoCuentas + ''' ' +
        'WITH ( ' +
            'FIELDTERMINATOR = ''|'', ' + 
            'ROWTERMINATOR = ''\n'', ' +
            'FIRSTROW = 2, ' +
            'CODEPAGE = ''65001'' ' +
        ');';

    EXEC sp_executesql @sql_dinamicoCuentas;
    -- actualizar unidadFuncional con los CVU/CBU
    -- se hace un JOIN con consorcio y la temporal para encontrar la UF correcta
    
    UPDATE uf
    SET 
        uf.cuenta_origen = t.CVU_CBU
    FROM 
        unidadFuncional uf
    INNER JOIN 
        consorcio c ON uf.id_consorcio = c.id_consorcio 
    INNER JOIN 
        #tempCuentasUF t ON 
            UPPER(t.NombreConsorcio) = UPPER(c.nombre) AND 
            CAST(t.nroUnidadFuncional AS INT) = uf.numero_uf AND -- Convertir a INT para el JOIN
            UPPER(t.piso) = UPPER(uf.piso) AND 
            UPPER(t.departamento) = UPPER(uf.depto)
    WHERE
        t.CVU_CBU IS NOT NULL;

END;
GO
-------------------------------------------------------------------------
-- Ejemplo de ejecuci�n (debe estar en el script de testing/invocaciones)
DECLARE @RutaArchivoC VARCHAR(255) = '';--<----RUTA DE ACCESO Inquilino-propietarios-UF.csv
EXEC sp_asociar_cuentas_uf @RutaArchivoCuentas = @RutaArchivoC;
SELECT * FROM unidadFuncional
GO
--------------------------------------------------------------

-- CARGAR personaUF
-- Este SP necesita dos archivos para cruzar la informaci�n:
-- 1. El archivo de relaci�n UF-CVU/CBU (Inquilino-propietarios-UF.csv)
-- 2. El archivo de datos de Persona (Inquilino-propietarios-datos.csv)

CREATE OR ALTER PROCEDURE sp_importar_persona_uf
 @RutaArchivoRelacionUF VARCHAR(255), -- (delimitador '|')
 @RutaArchivoDatosPersona VARCHAR(255) -- (delimitador ';')
AS
BEGIN
 -- Tabla temporal para la relaci�n UF-CVU/CBU
 CREATE TABLE #tempRelacionUF (
CVU_CBU VARCHAR(50),
 Nombre_Consorcio VARCHAR(35),
nroUnidadFuncional VARCHAR(10),
 piso VARCHAR(10),
 departamento VARCHAR(10)
 );

-- Tabla temporal para obtener el estado de inquilino y DNI a partir del CVU/CBU
CREATE TABLE #tempPersonaStatus (
 Nombre VARCHAR(50),
 Apellido VARCHAR(50),
DNI VARCHAR(9),
 Email_Personal VARCHAR(50),
 Telefono_Contacto VARCHAR(20),
Cuenta VARCHAR(50), 
 Inquilino BIT 
);

 DECLARE @sql_dinamico_uf NVARCHAR(MAX);
 DECLARE @sql_dinamico_per NVARCHAR(MAX);

 -- BULK INSERT para la relaci�n UF-CVU/CBU (usando delimitador '|')
 SET @sql_dinamico_uf = 
'BULK INSERT #tempRelacionUF ' + 
'FROM ''' + @RutaArchivoRelacionUF + ''' ' + 
 'WITH ( ' +
 'FIELDTERMINATOR = ''|'', ' +
'ROWTERMINATOR = ''\n'', ' +
'FIRSTROW = 2 ' +
 ');';
 EXEC sp_executesql @sql_dinamico_uf;

 -- BULK INSERT para el estado de Inquilino
 SET @sql_dinamico_per = 
 'BULK INSERT #tempPersonaStatus ' + 
 'FROM ''' + @RutaArchivoDatosPersona + ''' ' + 
 'WITH ( ' +
'FIELDTERMINATOR = '';'', ' +
'ROWTERMINATOR = ''\n'', ' +
 'FIRSTROW = 2 ' +
');';
 EXEC sp_executesql @sql_dinamico_per;

 -- Insertar en personaUf (JOIN m�ltiple)
 INSERT INTO personaUf (dni_persona, id_uf, fecha_desde, fecha_hasta, tipo_responsable)
 SELECT
p.dni, 
 uf.id_uf,
 GETDATE() AS fecha_desde, -- Asumimos la fecha actual para la relaci�n (esto nose si es asi)
 NULL AS fecha_hasta,
 -- Inferimos el tipo de responsable usando la columna 'Inquilino'
 CASE WHEN tps.Inquilino = 1 THEN 'INQUILINO' ELSE 'PROPIETARIO' END AS tipo_responsable
 FROM
#tempRelacionUF truf
 -- Unir con el estado de inquilino para obtener el DNI y el tipo de responsable
 INNER JOIN #tempPersonaStatus tps ON REPLACE(LTRIM(RTRIM(truf.CVU_CBU)), ' ', '') = REPLACE(LTRIM(RTRIM(tps.Cuenta)), ' ', '')
 -- Unir con la tabla Persona para asegurar la existencia del DNI
 INNER JOIN persona p ON p.dni = LTRIM(RTRIM(tps.DNI))
 -- Unir con la tabla Consorcio
 INNER JOIN consorcio c ON c.nombre = truf.Nombre_Consorcio
 -- Unir con la tabla Unidad Funcional para obtener el id_uf
 INNER JOIN unidadFuncional uf ON
 uf.id_consorcio = c.id_consorcio AND
 uf.numero_uf = CAST(truf.nroUnidadFuncional AS INT) AND
uf.piso = truf.piso AND
 uf.depto = truf.departamento
WHERE
 -- Evitar duplicados ya insertados (si se ejecuta el SP varias veces)
 NOT EXISTS (
 SELECT 1
 FROM personaUf pu
 WHERE pu.dni_persona = p.dni
 AND pu.id_uf = uf.id_uf
 AND pu.fecha_hasta IS NULL -- Solo consideramos las relaciones activas
);

END;
GO

-----------------------Ejecuci�n---------------------- 
DECLARE @archivo_relacion_uf VARCHAR(255) = ''; -- <---- RUTA Inquilino-propietarios-UF.csv
DECLARE @archivo_datos_persona VARCHAR(255) = ''; -- <---- RUTA Inquilino-propietarios-datos.csv

DELETE FROM personaUf;
DBCC CHECKIDENT ('personaUf', RESEED, 0);
EXEC sp_importar_persona_uf 
 @RutaArchivoRelacionUF = @archivo_relacion_uf, 
 @RutaArchivoDatosPersona = @archivo_datos_persona;

SELECT * FROM personaUf;
GO

-----------------------------------------------------
-- CARGAR PAGO
CREATE OR ALTER PROCEDURE sp_importar_pagos
@RutaArchivoPagos VARCHAR(255)
AS
BEGIN

 CREATE TABLE #tempPago (
 Id_de_pago VARCHAR(10),
 fecha VARCHAR(20),
CVU_CBU VARCHAR(50),
 Valor VARCHAR(30)
 );

 DECLARE @sql_dinamico_pagos NVARCHAR(MAX);

-- Construir la instrucci�n BULK INSERT
SET @sql_dinamico_pagos = 
'BULK INSERT #tempPago ' + 
 'FROM ''' + @RutaArchivoPagos + ''' ' + 
'WITH ( ' +
 'FIELDTERMINATOR = '','', ' + 
 'ROWTERMINATOR = ''\n'', ' +
 'FIRSTROW = 2 ' +
 ');';

 EXEC sp_executesql @sql_dinamico_pagos;
-- Transformaciones de datos:
 --  Eliminar '$', espacios y reemplazar '.' por '' para convertir a DECIMAL.
 --  Convertir la fecha a formato DATE.


 INSERT INTO pago (fecha, cuenta_origen, importe, asociado)
SELECT
TRY_CONVERT(DATE, t.fecha, 103), -- Formato 103: dd/mm/yyyy
 REPLACE(LTRIM(RTRIM(t.CVU_CBU)), ' ', ''),
CAST(REPLACE(REPLACE(REPLACE(t.Valor, '$', ''), ' ', ''), '.', '') AS DECIMAL(10, 2)),
'NO' -- Valor por defecto. Se podr�a actualizar a 'SI' cuando se genere la Expensa/EstadoCuentaProrrateo (creo)
 FROM
 #tempPago t
 WHERE
 ISNUMERIC(REPLACE(REPLACE(REPLACE(t.Valor, '$', ''), ' ', ''), '.', '')) = 1 -- Solo importamos si el valor es num�rico v�lido
AND TRY_CONVERT(DATE, t.fecha, 103) IS NOT NULL -- Solo importamos si la fecha es v�lida
 -- Evitar duplicados (mismo CVU/CBU, misma fecha, mismo importe)
AND NOT EXISTS (
 SELECT 1
 FROM pago p
WHERE
p.cuenta_origen = REPLACE(LTRIM(RTRIM(t.CVU_CBU)), ' ', '') AND
 p.fecha = TRY_CONVERT(DATE, t.fecha, 103) AND
 p.importe = CAST(REPLACE(REPLACE(REPLACE(t.Valor, '$', ''), ' ', ''), '.', '') AS DECIMAL(10, 2))
 );

END;
GO

-----------------------Ejecuci�n---------------------- 
DECLARE @archivo_pagos VARCHAR(255) = ''; -- <---- RUTA pagos_consorcios.csv
DELETE FROM pago;
DBCC CHECKIDENT ('pago', RESEED, 0);
EXEC sp_importar_pagos @RutaArchivoPagos = @archivo_pagos;
SELECT * FROM pago;
GO
---------------------------------------------------
-- IMPORTAR PROVEEDORES
CREATE OR ALTER PROCEDURE sp_importar_proveedores
 @RutaArchivoProveedores VARCHAR(255)
AS
BEGIN
 CREATE TABLE #tempProveedor (
		tipo_gasto varchar(50),
		nombre_empresa varchar(100),
		alias varchar(50),
		nombre_consorcio varchar(50)
 );

 DECLARE @sql_dinamico_proveedores NVARCHAR(MAX);

 -- Construir la instrucci�n BULK INSERT
 SET @sql_dinamico_proveedores = 
 'BULK INSERT #tempProveedor ' + 
'FROM ''' + @RutaArchivoProveedores + ''' ' + 
 'WITH ( ' +
 'FIELDTERMINATOR = '';'', ' +
            'ROWTERMINATOR = ''\n'', ' +
            'FIRSTROW = 2 ' +
');';

 EXEC sp_executesql @sql_dinamico_proveedores;
 -- Transformaciones de datos:
 --  Eliminar '$', espacios y reemplazar '.' por '' para convertir a DECIMAL.
--  Convertir la fecha a formato DATE.


 INSERT INTO proveedor (id_consorcio, tipo_gasto, nombre_empresa, alias)
 SELECT 
		c.id_consorcio, p.tipo_gasto, p.nombre_empresa, p.alias
    FROM
		consorcio c INNER JOIN #tempProveedor p ON c.nombre = p.nombre_consorcio
END;
GO
--------------EJECUCION-------------------
DECLARE @archivo_provedores VARCHAR(255) = ''; -- <---- RUTA datos varios 1(Proveedores).csv
DELETE FROM proveedor;
DBCC CHECKIDENT ('proveedor', RESEED, 0);
EXEC sp_importar_proveedores @RutaArchivoProveedores = @archivo_provedores;
SELECT * FROM proveedor;
GO
-------------------------------------------------------------
----------------------------------------------------------------------IMPORTAR EXPENSAS-------------------------------------------------------
CREATE OR ALTER PROCEDURE spGenerarExpensas
    @periodo_mes VARCHAR(12), -- Nombre del mes (ej. 'Abril')
    @anio INT                 -- A�o (ej. 2025)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @periodo_completo VARCHAR(10); -- Almacenar� el formato YYYY-MM
    
    -- ==========================================================
    -- 1. VALIDACIONES INICIALES y CONSTRUCCI�N DEL PER�ODO
    -- ==========================================================
    
    -- Validamos y convertimos el periodo a formato YYYY-MM para el campo 'periodo'
    -- (Esta l�gica asegura que solo se procesen meses v�lidos)
    WITH Meses AS (
        SELECT 'enero' AS nombre, '01' AS num UNION ALL SELECT 'febrero', '02' UNION ALL 
        SELECT 'marzo', '03' UNION ALL SELECT 'abril', '04' UNION ALL 
        SELECT 'mayo', '05' UNION ALL SELECT 'junio', '06' UNION ALL
        SELECT 'julio', '07' UNION ALL SELECT 'agosto', '08' UNION ALL 
        SELECT 'septiembre', '09' UNION ALL SELECT 'octubre', '10' UNION ALL 
        SELECT 'noviembre', '11' UNION ALL SELECT 'diciembre', '12'
    )
    SELECT @periodo_completo = CONCAT(@anio, '-', num)
    FROM Meses
    WHERE nombre = LOWER(@periodo_mes);
    
    -- Verificamos si la conversi�n fall� (indicando un mes inv�lido)
    IF @periodo_completo IS NULL
    BEGIN
        RAISERROR('Error: El nombre de mes ingresado no es v�lido.', 16, 1);
        RETURN -1; 
    END

    -- ==========================================================
    -- 2. GENERACI�N E INSERCI�N DE EXPENSAS POR CONSORCIO
    -- ==========================================================
    
    BEGIN TRY
        
        -- Insertar un registro de expensa para cada Consorcio activo.
        INSERT INTO expensa (
            id_consorcio,
            periodo
        )
        SELECT
            c.id_consorcio,
            @periodo_completo
        FROM
            consorcio c -- Fuente de todos los Consorcios
        WHERE NOT EXISTS (
                SELECT 1 
                FROM expensa e
                WHERE e.id_consorcio = c.id_consorcio
                  AND e.periodo = @periodo_completo
            );

        -- Mensaje de �xito o advertencia
        IF @@ROWCOUNT = 0
        BEGIN
            PRINT 'Advertencia: No se insertaron nuevas expensas. Ya exist�an para el periodo, o no hay consorcios activos.';
        END
        ELSE
        BEGIN
            PRINT 'Se crearon ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros de encabezado de expensa para el periodo ' + @periodo_completo;
        END
        
        RETURN 0;

    END TRY
    BEGIN CATCH
        -- Manejo de errores de bajo nivel
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Error inesperado al generar las expensas: %s', 16, 1, @ErrorMessage);
        RETURN -4;
    END CATCH

    SET NOCOUNT OFF;
END;
GO

-- 1. Declarar variables para los par�metros
DECLARE @periodo_mes_test VARCHAR(12) = 'Mayo'; -- El mes que quieres generar (Abril, Mayo, Junio)
DECLARE @anio_test INT = 2025;             -- El a�o

-- 2. Ejecutar el Stored Procedure
EXEC spGenerarExpensas    
    @periodo_mes = @periodo_mes_test,
    @anio = @anio_test;

-- 3. Verificaci�n de Resultados
SELECT 
    e.id_expensa,
    e.periodo,
    c.nombre AS Nombre_Consorcio
FROM 
    expensa e
INNER JOIN 
    consorcio c ON e.id_consorcio = c.id_consorcio
WHERE 
    e.periodo = CONCAT(@anio_test, 
        CASE LOWER(@periodo_mes_test)
            WHEN 'enero' THEN '-01' WHEN 'febrero' THEN '-02' WHEN 'marzo' THEN '-03' 
            WHEN 'abril' THEN '-04' WHEN 'mayo' THEN '-05' WHEN 'junio' THEN '-06' 
            WHEN 'julio' THEN '-07' WHEN 'agosto' THEN '-08' WHEN 'septiembre' THEN '-09' 
            WHEN 'octubre' THEN '-10' WHEN 'noviembre' THEN '-11' WHEN 'diciembre' THEN '-12'
        END)
ORDER BY c.nombre;
GO

select * from expensa
order by id_consorcio

DELETE FROM expensa;
DBCC CHECKIDENT ('expensa', RESEED, 0);
GO
-----------------------INSERTAR GASTOS------------------------------
CREATE OR ALTER PROCEDURE spGenerarGastos
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Insertar un registro de Gasto por cada Expensa que a�n no tenga uno.
    INSERT INTO gasto (
        id_expensa, 
        periodo, 
        subtotal_ordinarios, 
        subtotal_extraordinarios
    )
    SELECT
        e.id_expensa,
        e.periodo, -- Heredamos el periodo directamente de la Expensa
        NULL,      -- Valor NULL seg�n el requerimiento
        NULL       -- Valor NULL seg�n el requerimiento
    FROM 
        expensa e
    WHERE
        -- Cl�usula NOT EXISTS para asegurar la unicidad (no crear duplicados)
        NOT EXISTS (
            SELECT 1 
            FROM Gasto g
            WHERE g.id_expensa = e.id_expensa
        );

    -- Mensaje de �xito o advertencia
    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'Advertencia: No se insertaron nuevos registros de Gasto. Todas las expensas ya tienen un registro asociado.';
    END
    ELSE
    BEGIN
        PRINT 'Se crearon ' + CAST(@@ROWCOUNT AS VARCHAR) + ' nuevos registros en la tabla Gasto.';
    END
    
    RETURN 0;

END;
GO

-- Ejecutar el Stored Procedure para inicializar la tabla Gasto
EXEC spGenerarGastos;
GO

select * from gasto

-- Verificaci�n de Resultados
-- Muestra el n�mero de registros en Gasto que tienen subtotales en NULL
SELECT 
    COUNT(*) AS Total_Registros_Gasto_Creados
FROM 
    gasto g
WHERE 
    g.subtotal_ordinarios IS NULL 
    AND g.subtotal_extraordinarios IS NULL;

-- Muestra algunos de los nuevos registros para inspecci�n
SELECT TOP 10 *
FROM gasto
ORDER BY id_gasto DESC;
GO

DELETE FROM gasto;
DBCC CHECKIDENT ('gasto', RESEED, 0);


CREATE OR ALTER PROCEDURE sp_gastos_ordinarios
    @RutaArchivoJSON NVARCHAR(4000)
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #gastoOrdinarioTemp (
        nombreConsorcio NVARCHAR(100),
        mes_nombre NVARCHAR(20),
        bancarios NVARCHAR(20),
        limpieza NVARCHAR(20),
        administracion NVARCHAR(20),
        seguros NVARCHAR(20),
        gastosGenerales NVARCHAR(20),
        agua NVARCHAR(20),
        luz NVARCHAR(20)
    );

    -- 2. Lectura del JSON a la tabla temporal (Pivoteada)
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = N'
    INSERT INTO #gastoOrdinarioTemp (nombreConsorcio, mes_nombre, bancarios, limpieza, administracion, seguros, gastosGenerales, agua, luz)
    SELECT 
        j."Nombre del consorcio", 
        TRIM(j.Mes),
        j.BANCARIOS, j.LIMPIEZA, j.ADMINISTRACION, j.SEGUROS, j."GASTOS GENERALES", 
        j."SERVICIOS PUBLICOS-Agua", j."SERVICIOS PUBLICOS-Luz"
    FROM OPENROWSET (BULK ''' + @RutaArchivoJSON + N''', SINGLE_CLOB) AS JData
    CROSS APPLY OPENJSON (JData.BulkColumn)
    WITH (
        "Nombre del consorcio" NVARCHAR(100) ''$."Nombre del consorcio"'',
        Mes NVARCHAR(20) ''$.Mes'',
        BANCARIOS NVARCHAR(20) ''$.BANCARIOS'',
        LIMPIEZA NVARCHAR(20)  ''$.LIMPIEZA'',
        ADMINISTRACION NVARCHAR(20)  ''$.ADMINISTRACION'',
        SEGUROS NVARCHAR(20) ''$.SEGUROS'',
        "GASTOS GENERALES" NVARCHAR(20) ''$."GASTOS GENERALES"'',
        "SERVICIOS PUBLICOS-Agua" NVARCHAR(20)  ''$."SERVICIOS PUBLICOS-Agua"'',
        "SERVICIOS PUBLICOS-Luz" NVARCHAR(20)  ''$."SERVICIOS PUBLICOS-Luz"''
    ) AS j
    WHERE j."Nombre del consorcio" IS NOT NULL;
    ';
    EXEC sp_executesql @SQL;
    
    -- [Definición de CTEs Meses y MapeoGastos]
    WITH Meses AS (
        SELECT 'abril' AS nombre, '04' AS num UNION ALL SELECT 'mayo', '05' AS num UNION ALL 
        SELECT 'junio', '06' AS num UNION ALL SELECT 'julio', '07' AS num UNION ALL 
        SELECT 'agosto', '08' AS num UNION ALL SELECT 'septiembre', '09' AS num UNION ALL 
        SELECT 'octubre', '10' AS num UNION ALL SELECT 'noviembre', '11' AS num UNION ALL 
        SELECT 'diciembre', '12' AS num UNION ALL SELECT 'enero', '01' AS num UNION ALL 
        SELECT 'febrero', '02' AS num UNION ALL SELECT 'marzo', '03' AS num
    ),

    MapeoGastos AS ( 
        -- Paso 1: Aplanar la tabla temporal (UNPIVOT LÓGICO)
        SELECT 
            c.id_consorcio,
            g.id_gasto,
            TRIM(t.mes_nombre) AS Mes,
            CAST(YEAR(GETDATE()) AS INT) AS Anio,
            pvt.TipoGastoCorto,
            pvt.ImporteString
        FROM #gastoOrdinarioTemp t
        INNER JOIN consorcio c ON UPPER(TRIM(c.nombre)) = UPPER(TRIM(t.nombreConsorcio))
        INNER JOIN (
            -- UNPIVOT: Convierte las columnas de gasto en filas
            SELECT nombreConsorcio, mes_nombre, 'BANCARIOS' AS TipoGastoCorto, bancarios AS ImporteString FROM #gastoOrdinarioTemp
            UNION ALL SELECT nombreConsorcio, mes_nombre, 'LIMPIEZA', limpieza FROM #gastoOrdinarioTemp
            UNION ALL SELECT nombreConsorcio, mes_nombre, 'ADMINISTRACION', administracion FROM #gastoOrdinarioTemp
            UNION ALL SELECT nombreConsorcio, mes_nombre, 'SEGUROS', seguros FROM #gastoOrdinarioTemp
            UNION ALL SELECT nombreConsorcio, mes_nombre, 'G.GENERALES', gastosGenerales FROM #gastoOrdinarioTemp
            UNION ALL SELECT nombreConsorcio, mes_nombre, 'AGUA', agua FROM #gastoOrdinarioTemp
            UNION ALL SELECT nombreConsorcio, mes_nombre, 'LUZ', luz FROM #gastoOrdinarioTemp
        ) AS pvt ON pvt.nombreConsorcio = t.nombreConsorcio AND pvt.mes_nombre = t.mes_nombre
        INNER JOIN Meses m ON LOWER(m.nombre) = LOWER(TRIM(t.mes_nombre))
        INNER JOIN expensa e ON e.id_consorcio = c.id_consorcio 
                             AND e.periodo = CONCAT(CAST(YEAR(GETDATE()) AS NVARCHAR), '-', m.num)
        INNER JOIN Gasto g ON g.id_expensa = e.id_expensa
    ),
    
    -- Paso 2: Mapear a Proveedor y Aplicar Lógica de Negocio
    FinalData AS (
        SELECT
            m.id_gasto,
            -- Tipos de Gasto...
            CASE m.TipoGastoCorto WHEN 'BANCARIOS' THEN 'GASTOS BANCARIOS' WHEN 'ADMINISTRACION' THEN 'GASTOS DE ADMINISTRACION' WHEN 'SEGUROS' THEN 'SEGUROS' WHEN 'LIMPIEZA' THEN 'GASTOS DE LIMPIEZA' WHEN 'G.GENERALES' THEN 'GASTOS GENERALES' WHEN 'AGUA' THEN 'SERVICIOS PUBLICOS' WHEN 'LUZ' THEN 'SERVICIOS PUBLICOS' ELSE 'OTROS' END AS tipo_gasto,
            -- Subtipos de Gasto...
            CASE m.TipoGastoCorto WHEN 'BANCARIOS' THEN 'GASTOS BANCARIOS' WHEN 'ADMINISTRACION' THEN 'HONORARIOS' WHEN 'SEGUROS' THEN 'INTEGRAL DE CONSORCIO' WHEN 'LIMPIEZA' THEN 'SERVICIO DE LIMPIEZA' WHEN 'AGUA' THEN 'SERVICIO DE AGUA' WHEN 'LUZ' THEN 'SERVICIO DE ELECTRICIDAD' ELSE NULL END AS subtipoGasto,
            
            p.nombre_empresa,
            
            -- ***************************************************************
            -- CONVERSIÓN EXTREMA: Eliminar todos los separadores de miles y estandarizar la coma decimal
            -- ***************************************************************
            TRY_CAST(
                REPLACE(
                    REPLACE( -- 2. Reemplazamos las comas (posibles separadores decimales) por puntos
                        REPLACE(TRIM(m.ImporteString), '.', ''), -- 1. Primero, eliminamos todos los puntos (asumidos separadores de miles)
                    ',', '.'),
                ' ', '') -- 3. Eliminamos cualquier espacio residual que pueda causar error
            AS DECIMAL(18, 2)) AS importe
            
        FROM MapeoGastos m
        -- LEFT JOIN a Proveedor
        LEFT JOIN proveedor p
            ON p.id_consorcio = m.id_consorcio
            -- 1. Mapeo del Tipo Gasto a la categoría de la tabla 'proveedor'
            AND p.tipo_gasto = (
                CASE m.TipoGastoCorto
                    WHEN 'AGUA' THEN 'SERVICIOS PUBLICOS'
                    WHEN 'LUZ' THEN 'SERVICIOS PUBLICOS'
                    WHEN 'BANCARIOS' THEN 'GASTOS BANCARIOS'
                    WHEN 'ADMINISTRACION' THEN 'GASTOS DE ADMINISTRACION'
                    WHEN 'LIMPIEZA' THEN 'GASTOS DE LIMPIEZA'
                    WHEN 'SEGUROS' THEN 'SEGUROS'
                    WHEN 'G.GENERALES' THEN 'GASTOS GENERALES'
                    ELSE 'OTROS'
                END
            )
            -- 2. Discriminación de Proveedor (AYSA/EDENOR)
            AND (
                (m.TipoGastoCorto = 'AGUA' AND p.nombre_empresa = 'AYSA')
                OR (m.TipoGastoCorto = 'LUZ' AND p.nombre_empresa = 'EDENOR')
                OR (m.TipoGastoCorto NOT IN ('AGUA', 'LUZ'))
            )
    )

    -- 4. Inserción Final
    INSERT INTO gastoOrdinario (id_gasto, tipo_gasto, subtipoGasto, nombre_empresa, importe)
    SELECT
        fd.id_gasto,
        fd.tipo_gasto,
        fd.subtipoGasto,
        fd.nombre_empresa,
        fd.importe
    FROM FinalData fd
    WHERE
        fd.importe IS NOT NULL
        AND fd.importe > 0
        AND fd.id_gasto IS NOT NULL;

    -- 5. Limpieza y Mensaje
    DROP TABLE #gastoOrdinarioTemp;
    
    PRINT 'Carga de Gastos Ordinarios completada. Se insertaron ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros.';

END
GO

--prueba
DECLARE @archivo NVARCHAR(4000) = '';

DELETE FROM gastoOrdinario;
DBCC CHECKIDENT ('gastoOrdinario', RESEED, 0);

EXEC sp_gastos_ordinarios @RutaArchivoJSON = @archivo;

SELECT * FROM gastoOrdinario;
GO





--------------------------------------------------------------------------------------------------------------------------------------------
--CARGAR GASTOS EXTRAORDINARIOS CON SQL DIN�MICO PARA LA RUTA DE ACCESO
CREATE OR ALTER PROCEDURE sp_importar_gastosExtraordinarios
    @RutaArchivo VARCHAR(255)  -- Par�metro de entrada para la ruta del archivo
AS
BEGIN
    CREATE TABLE #tempGastoExtraordinario (
		nombre_consorcio varchar(50),
		tipo varchar(50),
		descripcion varchar(100),
		importe decimal(10,2),
        fecha date,
		tipo_pago varchar(15),
        cuota varchar(15),
        );

    -- Declarar una variable para el SQL din�mico
    DECLARE @sql_dinamico NVARCHAR(MAX);

    -- Construir la instrucci�n BULK INSERT usando el par�metro
    SET @sql_dinamico = 
        'BULK INSERT #tempGastoExtraordinario ' + 
        'FROM ''' + @RutaArchivo + ''' ' +  -- Importante: se usan dos comillas simples ('') para la ruta
        'WITH ( ' +
            'FIELDTERMINATOR = '';'', ' +
            'ROWTERMINATOR = ''\n'', ' +
            'FIRSTROW = 2 ' +
        ');';

    -- Ejecutar la importaci�n (requiere permisos 'BULK ADMIN' o 'ADMINISTRATOR')
    EXEC sp_executesql @sql_dinamico;

    INSERT INTO gastoExtraordinario (id_consorcio, tipo_gasto, descripcion,importe,fecha_gasto,forma_pago,cuota)
	SELECT c.id_consorcio, tge.tipo, tge.descripcion, tge.importe, tge.fecha, tge.tipo_pago, tge.cuota
	FROM #tempGastoExtraordinario tge 
    inner join consorcio c on tge.nombre_consorcio = c.nombre
    
    --Asocia id_gasto a cada gasto (lo prob� y funciona perfecto, pero testear por las dudas)
    UPDATE ge 
    SET ge.id_gasto = g.id_gasto
    FROM gastoExtraordinario ge
    JOIN consorcio c ON ge.id_consorcio = c.id_consorcio
    JOIN expensa e ON e.id_consorcio = c.id_consorcio
    JOIN gasto g ON g.id_expensa = e.id_expensa
    WHERE e.periodo = CONVERT(VARCHAR(7), ge.fecha_gasto, 120);

END
GO
-------------------------------------------------------------------------
-- Ejemplo de ejecuci�n (debe estar en el script de testing/invocaciones)
DECLARE @archivo_gastosExtraordinarios VARCHAR(255) = ''; --<----RUTA DE ACCESO a gastos_extraordinarios.csv

DELETE FROM gastoExtraordinario;
DBCC CHECKIDENT ('gastoExtraordinario', RESEED, 0);

-- Ejecuta el SP pasando la variable con la ruta del archivo
EXEC sp_importar_gastosExtraordinarios @RutaArchivo = @archivo_gastosExtraordinarios;

-- Verificaci�n
SELECT * FROM gastoExtraordinario
order by id_consorcio
GO
--------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE sp_calcularSubtotalesGastos
AS
BEGIN
    SET NOCOUNT ON;

    -- FIX: Se combinan ambas CTEs en una única cláusula WITH, separadas por coma.
    WITH SubtotalesOrdinarios AS (
        SELECT
            go.id_gasto,
            SUM(go.importe) AS TotalOrdinario
        FROM
            gastoOrdinario go
        GROUP BY
            go.id_gasto
    ), -- <--- ¡LA COMA ES ESENCIAL AQUÍ!
    
    SubtotalesExtraordinarios AS (
        SELECT
            ge.id_gasto,
            SUM(ge.importe) AS TotalExtraordinario
        FROM
            gastoExtraordinario ge
        GROUP BY
            ge.id_gasto
    ) -- No lleva coma porque le sigue la instrucción principal (UPDATE)

    -- Realizar la actualización masiva de la tabla 'gasto'
    UPDATE g
    SET 
        g.subtotal_ordinarios = ISNULL(so.TotalOrdinario, 0),
        g.subtotal_extraordinarios = ISNULL(se.TotalExtraordinario, 0)
    FROM
        gasto g
    LEFT JOIN
        SubtotalesOrdinarios so ON g.id_gasto = so.id_gasto
    LEFT JOIN
        SubtotalesExtraordinarios se ON g.id_gasto = se.id_gasto
    WHERE 
        -- Condición para asegurar que solo se actualizan registros que realmente han cambiado
        g.subtotal_ordinarios IS NULL 
        OR g.subtotal_extraordinarios IS NULL 
        OR g.subtotal_ordinarios <> ISNULL(so.TotalOrdinario, 0)
        OR g.subtotal_extraordinarios <> ISNULL(se.TotalExtraordinario, 0);

    -- Mensaje de éxito
    PRINT 'Actualización de subtotales de gastos completada. ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros actualizados.';
    RETURN 0;

END;
GO

-- 1. Ejecutar el Stored Procedure
EXEC sp_calcularSubtotalesGastos;
GO

select * from gasto
-- 2. Verificación de Resultados
-- Muestra el IdGasto, la suma de los detalles y el subtotal actualizado.
SELECT
    g.id_gasto,
    g.subtotal_ordinarios AS Calculado_Ordinario,
    g.subtotal_extraordinarios AS Calculado_Extraordinario,
    (SELECT SUM(importe) FROM gastoOrdinario gu WHERE gu.id_gasto = g.id_gasto) AS Suma_Detalle_Ordinario,
    (SELECT SUM(importe) FROM gastoExtraordinario ge WHERE ge.id_gasto = g.id_gasto) AS Suma_Detalle_Extraordinario
FROM 
    gasto g
WHERE 
    g.subtotal_ordinarios IS NOT NULL OR g.subtotal_extraordinarios IS NOT NULL
ORDER BY
    g.id_gasto;
GO
---------------- ESTADO CUENTA PRORRATEO -----------------------
CREATE OR ALTER PROCEDURE sp_generar_estadoCuentaProrrateo
    @periodo_mes VARCHAR(12),
    @anio INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @periodo_completo VARCHAR(10);
    DECLARE @periodo_anterior VARCHAR(10);
    DECLARE @fecha_emision DATE;
    DECLARE @fecha_1er_venc DATE;
    DECLARE @fecha_2do_venc DATE;
    DECLARE @periodo_fecha DATE;

    -- Validar y construir el período (AAAA-MM) y el período anterior
    SELECT @periodo_completo = CONCAT(@anio, '-', M.num)
    FROM (
        SELECT 'enero' AS nombre, '01' AS num UNION ALL SELECT 'febrero', '02' UNION ALL SELECT 'marzo', '03' UNION ALL SELECT 'abril', '04' UNION ALL
        SELECT 'mayo', '05' UNION ALL SELECT 'junio', '06' UNION ALL SELECT 'julio', '07' UNION ALL SELECT 'agosto', '08' UNION ALL
        SELECT 'septiembre', '09' UNION ALL SELECT 'octubre', '10' UNION ALL SELECT 'noviembre', '11' UNION ALL SELECT 'diciembre', '12'
    ) AS M
    WHERE LOWER(M.nombre) = LOWER(@periodo_mes);

    IF @periodo_completo IS NULL
    BEGIN
        PRINT 'ERROR: Período de mes no válido.';
        RETURN;
    END

    -- Calcular el periodo anterior en formato AAAA-MM
    SET @periodo_fecha = CONVERT(DATE, @periodo_completo + '-01');
    SET @periodo_anterior = CONVERT(VARCHAR(7), DATEADD(MONTH, -1, @periodo_fecha), 126);

    -- Definir fechas de emisión y vencimiento
    SET @fecha_emision = DATEADD(DAY, 1, @periodo_fecha); 
    SET @fecha_1er_venc = DATEADD(DAY, 10, @fecha_emision);
    SET @fecha_2do_venc = DATEADD(DAY, 20, @fecha_emision);

    -- Calcular Prorrateo y Saldo Anterior
    WITH DatosExpensa AS (
        SELECT
            e.id_expensa, uf.id_uf, g.subtotal_ordinarios, g.subtotal_extraordinarios, uf.coeficiente,
            e.id_consorcio
        FROM expensa e
        INNER JOIN gasto g ON e.id_expensa = g.id_expensa
        INNER JOIN unidadFuncional uf ON e.id_consorcio = uf.id_consorcio
        WHERE e.periodo = @periodo_completo -- FILTRA por 'AAAA-MM'
    ),
    SaldoAnterior AS (
        SELECT
            de.id_uf,
            -- Busca la DEUDA FINAL del período ANTERIOR para esta UF
            ISNULL((
                SELECT TOP 1 ecp.deuda 
                FROM estadoCuentaProrrateo ecp
                INNER JOIN expensa e_prev ON e_prev.id_expensa = ecp.id_expensa
                WHERE ecp.id_uf = de.id_uf
                AND e_prev.periodo = @periodo_anterior -- FILTRA por PERIODO ANTERIOR
                ORDER BY ecp.id_detalleDeCuenta DESC
            ), 0.00) AS SaldoAnteriorCalculado
        FROM DatosExpensa de
        GROUP BY de.id_uf
    ),
    ProrrateoCalculado AS (
        SELECT
            de.id_expensa, de.id_uf, sa.SaldoAnteriorCalculado AS saldo_anterior,
            (de.subtotal_ordinarios * de.coeficiente) AS expensas_ordinarias,
            (de.subtotal_extraordinarios * de.coeficiente) AS expensas_extraordinarias
        FROM DatosExpensa de
        INNER JOIN SaldoAnterior sa ON de.id_uf = sa.id_uf
    )
    -- Insertar el Prorrateo en la tabla de destino
    INSERT INTO estadoCuentaProrrateo (
        id_expensa, id_uf, id_pago, fecha_emision, fecha_1er_venc, fecha_2do_venc,
        saldo_anterior, pagos_recibidos, deuda, interes_por_mora, expensas_ordinarias,
        expensas_extraordinarias, total_pagar 
    )
    SELECT
        pc.id_expensa, pc.id_uf, NULL AS id_pago, @fecha_emision, @fecha_1er_venc, @fecha_2do_venc,
        pc.saldo_anterior, 0.00 AS pagos_recibidos, 
        pc.saldo_anterior + pc.expensas_ordinarias + pc.expensas_extraordinarias AS deuda_inicial,
        0.00 AS interes_por_mora, 
        pc.expensas_ordinarias, pc.expensas_extraordinarias,
        pc.saldo_anterior + pc.expensas_ordinarias + pc.expensas_extraordinarias AS total_pagar_inicial
    FROM ProrrateoCalculado pc
    WHERE NOT EXISTS (
        SELECT 1 FROM estadoCuentaProrrateo ecp WHERE ecp.id_expensa = pc.id_expensa AND ecp.id_uf = pc.id_uf
    ); 

    PRINT 'Generación de Estado de Cuenta y Prorrateo completada para el período: ' + @periodo_completo;

END
GO
-------------------- ACTUALIZAR PAGO ------------------------
CREATE OR ALTER PROCEDURE sp_asociar_y_aplicar_pagos
AS
BEGIN
    SET NOCOUNT ON;

    -- Limpiamos la tabla temporal por si quedó de una ejecución previa
    IF OBJECT_ID('tempdb..#PagosFinales') IS NOT NULL DROP TABLE #PagosFinales;

    -- Identificar el pago, calcular intereses y guardar el resultado en la tabla temporal
    WITH PagosParaAplicar AS (
        SELECT
            p.id_pago,
            p.fecha AS fecha_pago_real, 
            p.importe AS importe_pago,
            ecp.id_detalleDeCuenta,
            ecp.deuda AS deuda_pendiente,
            ecp.fecha_1er_venc,
            ecp.fecha_2do_venc,
            -- Calculo de Interés y montos necesarios
            CASE
                WHEN p.fecha > ecp.fecha_2do_venc THEN ecp.deuda * 0.05
                WHEN p.fecha > ecp.fecha_1er_venc THEN ecp.deuda * 0.02
                ELSE 0.00
            END AS interes_calculado,
            -- Prioriza la expensa PENDIENTE más antigua (rn = 1)
            ROW_NUMBER() OVER (PARTITION BY p.id_pago ORDER BY e.periodo ASC) as rn
        FROM pago p
        INNER JOIN unidadFuncional uf ON p.cuenta_origen = uf.cuenta_origen
        INNER JOIN estadoCuentaProrrateo ecp ON uf.id_uf = ecp.id_uf
        INNER JOIN expensa e ON ecp.id_expensa = e.id_expensa
        WHERE p.asociado = 'NO'
          AND ecp.deuda > 0
          AND ecp.id_pago IS NULL
    )
    -- Guardamos el resultado de la CTE en la tabla temporal para que sea accesible por los UPDATES
    SELECT
        id_pago,
        id_detalleDeCuenta,
        importe_pago,
        deuda_pendiente,
        interes_calculado,
        deuda_pendiente + interes_calculado AS total_requerido,
        (deuda_pendiente + interes_calculado) - importe_pago AS nueva_deuda_calculada
    INTO #PagosFinales 
    FROM PagosParaAplicar
    WHERE rn = 1; 
    
    -- Actualizar la tabla 'pago' (Ahora usa la tabla temporal #PagosFinales)
    UPDATE p
    SET
        p.asociado = 'SI'
    FROM pago p
    INNER JOIN #PagosFinales pf ON p.id_pago = pf.id_pago;

    -- Actualizar estadoCuentaProrrateo (Ahora usa la tabla temporal #PagosFinales)
    UPDATE ecp
    SET
        ecp.id_pago = pf.id_pago,
        ecp.pagos_recibidos = pf.importe_pago,
        ecp.interes_por_mora = pf.interes_calculado,
        ecp.total_pagar = pf.total_requerido,
        ecp.deuda = CASE
            WHEN pf.nueva_deuda_calculada <= 0.00 THEN 0.00
            ELSE pf.nueva_deuda_calculada
        END
    FROM estadoCuentaProrrateo ecp
    INNER JOIN #PagosFinales pf ON ecp.id_detalleDeCuenta = pf.id_detalleDeCuenta;

    PRINT 'Proceso de asociación y aplicación de pagos completado';

END
GO
------------------- ESTADO FINANCIERO -----------------------------
CREATE OR ALTER PROCEDURE sp_generar_estadoFinanciero
    @periodo_mes VARCHAR(12),
    @anio INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @periodo_completo VARCHAR(10);
    
    --Validar y construir el período (AAAA-MM)
    SELECT @periodo_completo = CONCAT(@anio, '-', M.num)
    FROM (
        SELECT 'enero' AS nombre, '01' AS num UNION ALL SELECT 'febrero', '02' UNION ALL SELECT 'marzo', '03' UNION ALL SELECT 'abril', '04' UNION ALL
        SELECT 'mayo', '05' UNION ALL SELECT 'junio', '06' UNION ALL SELECT 'julio', '07' UNION ALL SELECT 'agosto', '08' UNION ALL
        SELECT 'septiembre', '09' UNION ALL SELECT 'octubre', '10' UNION ALL SELECT 'noviembre', '11' UNION ALL SELECT 'diciembre', '12'
    ) AS M
    WHERE LOWER(M.nombre) = LOWER(@periodo_mes);

    IF @periodo_completo IS NULL
    BEGIN
        PRINT 'ERROR: Período de mes no válido.';
        RETURN;
    END;

    -- Calcular datos financieros
    WITH DatosFinancieros AS (
        SELECT
            c.id_consorcio, 
            e.id_expensa,
            CONVERT(DATE, @periodo_completo + '-01') AS PeriodoFecha,
            
            -- Saldo Anterior
            ISNULL((
                SELECT TOP 1 ef_prev.saldo_cierre
                FROM estadoFinanciero ef_prev
                WHERE ef_prev.id_consorcio = c.id_consorcio
                AND ef_prev.periodo = CONVERT(DATE, DATEADD(MONTH, -1, CONVERT(DATE, @periodo_completo + '-01'))) 
                ORDER BY ef_prev.id DESC
            ), 0.00) AS SaldoAnteriorCalculado,
            
            -- Ingresos por pago de expensas en término (Pago <= 1er Vencimiento)
            SUM(CASE WHEN p.fecha <= ecp.fecha_1er_venc THEN p.importe ELSE 0 END) AS TotalIngresoTermino,
            
            -- Ingresos por pago de expensas adeudadas (Pago > 1er Vencimiento y asociado al período)
            SUM(CASE WHEN p.fecha > ecp.fecha_1er_venc AND p.importe > 0 AND p.asociado = 'SI' THEN p.importe ELSE 0 END) AS TotalIngresoAdeudadas,
            
            -- Ingresos por expensas adelantadas (se asume 0.00)
            0.00 AS TotalIngresoAdelantadas, 
            
            -- Egresos por gastos del mes
            ISNULL((
                SELECT (g.subtotal_ordinarios + g.subtotal_extraordinarios) 
                FROM gasto g 
                WHERE g.id_expensa = e.id_expensa
            ), 0.00) AS EgresoCalculado
            
        FROM consorcio c
        INNER JOIN expensa e ON c.id_consorcio = e.id_consorcio
        LEFT JOIN estadoCuentaProrrateo ecp ON e.id_expensa = ecp.id_expensa
        LEFT JOIN pago p ON ecp.id_pago = p.id_pago 
        WHERE e.periodo = @periodo_completo
        GROUP BY c.id_consorcio, e.id_expensa 
    )
    -- Insertar el Estado Financiero
    INSERT INTO estadoFinanciero (
        id_consorcio, saldo_anterior, ingreso_expensas_termino, ingreso_expensas_adeudadas,
        ingreso_expensas_adelantadas, egreso, saldo_cierre, periodo
    )
    SELECT
        df.id_consorcio, df.SaldoAnteriorCalculado, df.TotalIngresoTermino, df.TotalIngresoAdeudadas,
        df.TotalIngresoAdelantadas, df.EgresoCalculado,
        -- Saldo al cierre: Saldo Anterior + Ingresos Totales - Egresos Totales
        df.SaldoAnteriorCalculado + df.TotalIngresoTermino + df.TotalIngresoAdeudadas + df.TotalIngresoAdelantadas - df.EgresoCalculado AS saldo_cierre_calculado,
        df.PeriodoFecha
    FROM DatosFinancieros df
    WHERE NOT EXISTS (
        SELECT 1 FROM estadoFinanciero ef WHERE ef.id_consorcio = df.id_consorcio AND ef.periodo = df.PeriodoFecha
    ); 

    PRINT 'Generación de Estado Financiero completada para el período: ' + @periodo_completo;

END
GO
-------------------------------------------------------------------------
-- VARIABLES DE PERÍODO: JUNIO 2025 (porque asi tenia cargada expensa)  EJECUTEN TODO JUNTO
-------------------------------------------------------------------------
DECLARE @periodo_mes_eje VARCHAR(12) = 'Junio'; 
DECLARE @anio_eje INT = 2025; 
GO 

-- Redeclaramos las variables para este lote
DECLARE @periodo_mes_eje VARCHAR(12) = 'Junio'; 
DECLARE @anio_eje INT = 2025; 

PRINT '--- 1. INICIANDO GENERACIÓN DE DEUDA (PRORRATEO)---';
EXEC sp_generar_estadoCuentaProrrateo @periodo_mes = @periodo_mes_eje, @anio = @anio_eje;
GO 

PRINT '--- 2. CARGANDO PAGOS DESDE EL ARCHIVO ---';

GO 

PRINT '--- 3. INICIANDO APLICACIÓN DE PAGOS Y CÁLCULO DE INTERESES ---';
EXEC sp_asociar_y_aplicar_pagos;
GO 

-- Redeclaramos las variables por última vez
DECLARE @periodo_mes_eje VARCHAR(12) = 'Junio'; 
DECLARE @anio_eje INT = 2025; 

PRINT '--- 4. INICIANDO GENERACIÓN DE ESTADO FINANCIERO ---';
EXEC sp_generar_estadoFinanciero @periodo_mes = @periodo_mes_eje, @anio = @anio_eje;
GO

PRINT '--- FLUJO DE PROCESAMIENTO FINALIZADO CON ÉXITO ---';

SELECT * FROM gasto
SELECT * FROM pago
SELECT * FROM estadoCuentaProrrateo
SELECT * FROM estadoFinanciero