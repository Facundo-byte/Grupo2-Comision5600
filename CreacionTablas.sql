-- NOTAS !!!!!!
-- LEER LOS COMENTARIOS
-- ESTÁN LOS SP CON SQL DINÁMICO Y NORMAL, LOS DEJE POR LAS DUDAS(LOS NORMALES)
-- ALGUNAS VECES CUANDO SE RESETEA EL IDENTITY DSP EMPIEZA EN 0 (Y NO EN 1, COMO DEBERIA) NO SE PQ, SI ALGUNO SABE BIEN SINO LE PREGUNTAMOS AL PROFE
-- TODO LO QUE ESTA ACA ANDA (POR AHI HAYA QUE MODIFICAR COSAS) PERO SI NO LES "COMPILA" O TIENEN ERRORES AVISEN Y LO VEMOS, PQ LO PROBE Y ANDA TODO
-- MODIFICAR LOS BITS DE UF PARA QUE PERMITA SI O NO
-- AGREGAR NOMBRE CONSORCIO EN UF PARA QUE SEA MAS FÁCIL PARA FUTURAS RELACIONES 
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
	asociado char(2) not null,);
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
-- en período cambiaría el tipo de dato 

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

-- el unique ese esta raro debería funcionar para evitar solapamientos
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
	id_detalleDeCuenta int primary key,
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
	--nombre_empresa varchar(50),
	--nro_factura varchar(50),
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

--CARGAR PERSONAS CON SQL DINÁMICO PARA LA RUTA DE ACCESO
CREATE OR ALTER PROCEDURE sp_importar_personas
    @RutaArchivoPersonas VARCHAR(255)  -- Parámetro de entrada para la ruta del archivo
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

    -- Declarar una variable para el SQL dinámico
    DECLARE @sql_dinamicoPer NVARCHAR(MAX);

    -- Construir la instrucción BULK INSERT usando el parámetro
    SET @sql_dinamicoPer = 
        'BULK INSERT #tempPersona ' + 
        'FROM ''' + @RutaArchivoPersonas + ''' ' +  -- Importante: se usan dos comillas simples ('') para la ruta
        'WITH ( ' +
            'FIELDTERMINATOR = '';'', ' +
            'ROWTERMINATOR = ''\n'', ' +
            'FIRSTROW = 2 ' +
        ');';

    -- Ejecutar la importación (requiere permisos 'BULK ADMIN' o 'ADMINISTRATOR')
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
        ISNULL(dni, '') <> ''  -- Evita DNIs vacíos
        AND NOT EXISTS (SELECT 1 FROM persona p WHERE p.dni = t.dni); -- Evita duplicados
END;
GO

-------------------------------------------------------------------------
-- Ejemplo de ejecución (debe estar en el script de testing/invocaciones)
DECLARE @archivo_personas VARCHAR(255) = ''; --<----RUTA DE ACCESO Inquilino-propietarios-datos.csv

-- Restablece el IDENTITY para la prueba
DELETE FROM persona; 
DBCC CHECKIDENT ('persona', RESEED, 0);

-- Ejecuta el SP pasando la variable con la ruta del archivo
EXEC sp_importar_personas @RutaArchivoPersonas = @archivo_personas;

-- Verificación
SELECT * FROM persona; 
GO
--------------------------------------------------------------------------------------------------------------------------------------------

--CARGAR CONSORCIOS CON SQL DINÁMICO PARA LA RUTA DE ACCESO
CREATE OR ALTER PROCEDURE sp_importar_consorcios
    @RutaArchivo VARCHAR(255)  -- Parámetro de entrada para la ruta del archivo
AS
BEGIN
    CREATE TABLE #tempConsorcio (
		num_consorcio varchar(12),
		nombre varchar(35),
		direccion varchar(35),
		cant_uf int,
		cant_m2 int,);

    -- Declarar una variable para el SQL dinámico
    DECLARE @sql_dinamico NVARCHAR(MAX);

    -- Construir la instrucción BULK INSERT usando el parámetro
    SET @sql_dinamico = 
        'BULK INSERT #tempConsorcio ' + 
        'FROM ''' + @RutaArchivo + ''' ' +  -- Importante: se usan dos comillas simples ('') para la ruta
        'WITH ( ' +
            'FIELDTERMINATOR = '';'', ' +
            'ROWTERMINATOR = ''\n'', ' +
            'FIRSTROW = 2 ' +
        ');';

    -- Ejecutar la importación (requiere permisos 'BULK ADMIN' o 'ADMINISTRATOR')
    EXEC sp_executesql @sql_dinamico;

    -- Insertar en la tabla final consorcio con transformaciones
    -- Nota: Aquí se asume que la tabla 'consorcio' no admite duplicados (lo que debes validar)
    INSERT INTO consorcio (nombre, direccion, cant_uf, cant_m2)
	SELECT UPPER(LTRIM(RTRIM(nombre))), UPPER(LTRIM(RTRIM(direccion))), cant_uf, cant_m2
	FROM #tempConsorcio 

END
GO

-------------------------------------------------------------------------
-- Ejemplo de ejecución (debe estar en el script de testing/invocaciones)
DECLARE @archivo_consorcios VARCHAR(255) = ''; --<----RUTA DE ACCESO datos varios 1(Consorcios).csv

-- Restablece el IDENTITY para la prueba
DELETE FROM consorcio; 
DBCC CHECKIDENT ('consorcio', RESEED, 0);

-- Ejecuta el SP pasando la variable con la ruta del archivo
EXEC sp_importar_consorcios @RutaArchivo = @archivo_consorcios;

-- Verificación
SELECT * FROM consorcio;
GO
--------------------------------------------------------------------------------------------------------------------------------------------

--CARGAR UF CON SQL DINÁMICO PARA LA RUTA DE ACCESO
CREATE or ALTER PROCEDURE sp_importar_uf
    @RutaArchivoUF VARCHAR(255)  -- Parámetro de entrada para la ruta del archivo
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

    -- Declarar una variable para el SQL dinámico
    DECLARE @sql_dinamicoUF NVARCHAR(MAX);

    -- Construir la instrucción BULK INSERT usando el parámetro
    SET @sql_dinamicoUF = 
        'BULK INSERT #tempUf ' + 
        'FROM ''' + @RutaArchivoUF + ''' ' +  -- Importante: se usan dos comillas simples ('') para la ruta
        'WITH ( ' +
            'FIELDTERMINATOR = ''\t'', ' +
            'ROWTERMINATOR = ''\n'', ' +
            'FIRSTROW = 2, ' +
			'CODEPAGE = ''65001'' '+
        ');';

    -- Ejecutar la importación (requiere permisos 'BULK ADMIN' o 'ADMINISTRATOR')
    EXEC sp_executesql @sql_dinamicoUF;

    -- Insertar en la tabla final unidadfuncional con transformaciones
    -- Nota: Aquí se asume que la tabla 'unidadfuncional' no admite duplicados (lo que debes validar)
    INSERT INTO unidadFuncional (id_consorcio, numero_uf, piso, depto, cochera, cochera_m2, baulera, baulera_m2, cant_m2, coeficiente)
	SELECT    UPPER(c.id_consorcio), CAST(u.numero_uf AS INT), CAST(u.piso AS varchar(3)), CAST(u.depto as varchar(5)), 
        CASE WHEN u.cochera = 'SI' THEN 1 ELSE 0 END, CAST(u.cochera_m2 AS INT), CASE WHEN u.baulera = 'SI' THEN 1 ELSE 0 END, 
        CAST(u.baulera_m2 as INT), CAST(u.uf_m2 AS INT), CAST(REPLACE(u.coeficiente, ',', '.') AS decimal (2,1))
	FROM #tempUf u
	JOIN consorcio c ON c.nombre = u.nombre_consorcio;
END;
GO

-------------------------------------------------------------------------
-- Ejemplo de ejecución (debe estar en el script de testing/invocaciones) 
DECLARE @archivo_uf VARCHAR(255) = '';--<----RUTA DE ACCESO UF por consorcio.txt

-- Restablece el IDENTITY para la prueba
DELETE FROM unidadFuncional; 
DBCC CHECKIDENT ('unidadFuncional', RESEED, 0);

-- Ejecuta el SP pasando la variable con la ruta del archivo
EXEC sp_importar_uf @RutaArchivoUF = @archivo_uf;

-- Verificación
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
-- Ejemplo de ejecución (debe estar en el script de testing/invocaciones)
DECLARE @RutaArchivoC VARCHAR(255) = '';--<----RUTA DE ACCESO Inquilino-propietarios-UF.csv
EXEC sp_asociar_cuentas_uf @RutaArchivoCuentas = @RutaArchivoC;
SELECT * FROM unidadFuncional
--------------------------------------------------------------

-- CARGAR personaUF
-- Este SP necesita dos archivos para cruzar la información:
-- 1. El archivo de relación UF-CVU/CBU (Inquilino-propietarios-UF.csv)
-- 2. El archivo de datos de Persona (Inquilino-propietarios-datos.csv)

CREATE OR ALTER PROCEDURE sp_importar_persona_uf
    @RutaArchivoRelacionUF VARCHAR(255),  -- (delimitador '|')
    @RutaArchivoDatosPersona VARCHAR(255) -- (delimitador ';')
AS
BEGIN
    -- Tabla temporal para la relación UF-CVU/CBU
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

    -- BULK INSERT para la relación UF-CVU/CBU (usando delimitador '|')
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

    -- Insertar en personaUf (JOIN múltiple)
    INSERT INTO personaUf (dni_persona, id_uf, fecha_desde, fecha_hasta, tipo_responsable)
    SELECT
        p.dni, 
        uf.id_uf,
        GETDATE() AS fecha_desde, -- Asumimos la fecha actual para la relación (esto nose si es asi)
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

-----------------------Ejecución---------------------- 
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

    -- Construir la instrucción BULK INSERT
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
        'NO' -- Valor por defecto. Se podría actualizar a 'SI' cuando se genere la Expensa/EstadoCuentaProrrateo (creo)
    FROM
        #tempPago t
    WHERE
        ISNUMERIC(REPLACE(REPLACE(REPLACE(t.Valor, '$', ''), ' ', ''), '.', '')) = 1  -- Solo importamos si el valor es numérico válido
        AND TRY_CONVERT(DATE, t.fecha, 103) IS NOT NULL  -- Solo importamos si la fecha es válida
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

-----------------------Ejecución---------------------- 
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

    -- Construir la instrucción BULK INSERT
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
    @anio INT                 -- Año (ej. 2025)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @periodo_completo VARCHAR(10); -- Almacenará el formato YYYY-MM
    
    -- ==========================================================
    -- 1. VALIDACIONES INICIALES y CONSTRUCCIÓN DEL PERÍODO
    -- ==========================================================
    
    -- Validamos y convertimos el periodo a formato YYYY-MM para el campo 'periodo'
    -- (Esta lógica asegura que solo se procesen meses válidos)
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
    
    -- Verificamos si la conversión falló (indicando un mes inválido)
    IF @periodo_completo IS NULL
    BEGIN
        RAISERROR('Error: El nombre de mes ingresado no es válido.', 16, 1);
        RETURN -1; 
    END

    -- ==========================================================
    -- 2. GENERACIÓN E INSERCIÓN DE EXPENSAS POR CONSORCIO
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

        -- Mensaje de éxito o advertencia
        IF @@ROWCOUNT = 0
        BEGIN
            PRINT 'Advertencia: No se insertaron nuevas expensas. Ya existían para el periodo, o no hay consorcios activos.';
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

-- 1. Declarar variables para los parámetros
DECLARE @periodo_mes_test VARCHAR(12) = 'Junio'; -- El mes que quieres generar (Abril, Mayo, Junio)
DECLARE @anio_test INT = 2025;             -- El año

-- 2. Ejecutar el Stored Procedure
EXEC spGenerarExpensas    
    @periodo_mes = @periodo_mes_test,
    @anio = @anio_test;

-- 3. Verificación de Resultados
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

-----------------------INSERTAR GASTOS------------------------------
CREATE OR ALTER PROCEDURE spGenerarGastos
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Insertar un registro de Gasto por cada Expensa que aún no tenga uno.
    INSERT INTO gasto (
        id_expensa, 
        periodo, 
        subtotal_ordinarios, 
        subtotal_extraordinarios
    )
    SELECT
        e.id_expensa,
        e.periodo, -- Heredamos el periodo directamente de la Expensa
        NULL,      -- Valor NULL según el requerimiento
        NULL       -- Valor NULL según el requerimiento
    FROM 
        expensa e
    WHERE
        -- Cláusula NOT EXISTS para asegurar la unicidad (no crear duplicados)
        NOT EXISTS (
            SELECT 1 
            FROM Gasto g
            WHERE g.id_expensa = e.id_expensa
        );

    -- Mensaje de éxito o advertencia
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

-- Verificación de Resultados
-- Muestra el número de registros en Gasto que tienen subtotales en NULL
SELECT 
    COUNT(*) AS Total_Registros_Gasto_Creados
FROM 
    gasto g
WHERE 
    g.subtotal_ordinarios IS NULL 
    AND g.subtotal_extraordinarios IS NULL;

-- Muestra algunos de los nuevos registros para inspección
SELECT TOP 10 *
FROM gasto
ORDER BY id_gasto DESC;
GO

DELETE FROM gasto; 
DBCC CHECKIDENT ('gasto', RESEED, 0);


-----------INSERTAR GASTOS ORDINARIOS--------------------------------
-------------------Versón juan act----------------------
CREATE OR ALTER PROCEDURE spImportarGastosOrdinarios
    @RutaArchivoJson VARCHAR(255) -- Parámetro para la ruta del archivo JSON
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Variables para SQL Dinámico y el contenido del JSON
    DECLARE @sql_dinamico NVARCHAR(MAX);
    DECLARE @JsonData NVARCHAR(MAX); 

    -- [SECCIÓN 1: EXTRACT (Lectura del Archivo)]
    SET @sql_dinamico = 
        'SELECT @JsonData = BulkColumn FROM OPENROWSET(BULK ''' + @RutaArchivoJson + ''', SINGLE_CLOB) AS J;';
    
    EXEC sp_executesql 
        @stmt = @sql_dinamico, 
        @param = N'@JsonData NVARCHAR(MAX) OUTPUT', 
        @JsonData = @JsonData OUTPUT;

    IF @JsonData IS NULL OR @JsonData = ''
    BEGIN
        RAISERROR('Error: No se pudo leer el archivo JSON o está vacío.', 16, 1);
        RETURN -1;
    END

    -- [SECCIÓN 2: TRANSFORM & LOAD]
    
    BEGIN TRY
        
        WITH JsonGastosAplanados AS (
            SELECT
                JSON_VALUE(j.value, '$."Nombre del consorcio"') AS NombreConsorcio,
                TRIM(JSON_VALUE(j.value, '$.Mes')) AS Mes,
                GastoData.[key] AS TipoGastoJson,
                
                -- ***************************************************************
                -- SOLUCIÓN FINAL A TRUNCAMIENTO Y FORMATO REGIONAL (TRY_PARSE)
                -- ***************************************************************
                TRY_PARSE(
                    TRIM(GastoData.value) -- Limpiamos solo espacios externos
                    AS DECIMAL(18, 2) USING 'es-ES' -- Usa el formato Español (punto=miles, coma=decimal)
                ) AS Importe_Decimal
                
            FROM 
                OPENJSON(@JsonData) j 
            CROSS APPLY 
                OPENJSON(j.value) AS GastoData
            WHERE
                GastoData.[key] NOT IN ('_id', 'Nombre del consorcio', 'Mes')
                AND JSON_VALUE(j.value, '$."Nombre del consorcio"') IS NOT NULL
        ),
        
        -- Mapear el Mes a su formato YYYY-MM
        Meses AS (
            SELECT 'abril' AS nombre, '04' AS num UNION ALL SELECT 'mayo', '05' UNION ALL 
            SELECT 'junio', '06' AS num
        )
        
        INSERT INTO gastoOrdinario(
            id_gasto, 
            tipo_gasto, 
            nombre_empresa,
            importe
        )
        SELECT
            g.id_gasto,
            UPPER(j.TipoGastoJson), 
            p.nombre_empresa,
            j.Importe_Decimal
        FROM 
            JsonGastosAplanados j
        INNER JOIN 
            consorcio c ON UPPER(c.nombre) = UPPER(j.NombreConsorcio COLLATE Modern_Spanish_CI_AS)
        INNER JOIN 
            Meses m ON LOWER(m.nombre) = LOWER(j.Mes COLLATE Modern_Spanish_CI_AS)
        INNER JOIN 
            expensa e ON e.id_consorcio = c.id_consorcio 
                         AND e.periodo = CONCAT('2025-', m.num)
        INNER JOIN 
            Gasto g ON g.id_expensa = e.id_expensa
        LEFT JOIN
            proveedor p ON p.id_consorcio = c.id_consorcio
                           AND p.tipo_gasto = (
                               CASE UPPER(j.TipoGastoJson) COLLATE Modern_Spanish_CI_AS
                                   WHEN 'BANCARIOS' THEN 'GASTOS BANCARIOS' COLLATE Modern_Spanish_CI_AS
                                   -- ... (resto de CASE para mapeo de tipo_gasto)
                                   WHEN 'ADMINISTRACION' THEN 'GASTOS DE ADMINISTRACION' COLLATE Modern_Spanish_CI_AS
                                   WHEN 'LIMPIEZA' THEN 'GASTOS DE LIMPIEZA' COLLATE Modern_Spanish_CI_AS
                                   WHEN 'SEGUROS' THEN 'SEGUROS' COLLATE Modern_Spanish_CI_AS
                                   WHEN 'GASTOS GENERALES' THEN 'GASTOS GENERALES' COLLATE Modern_Spanish_CI_AS
                                   WHEN 'SERVICIOS PUBLICOS-AGUA' THEN 'SERVICIOS PUBLICOS' COLLATE Modern_Spanish_CI_AS
                                   WHEN 'SERVICIOS PUBLICOS-LUZ' THEN 'SERVICIOS PUBLICOS' COLLATE Modern_Spanish_CI_AS
                                   ELSE UPPER(j.TipoGastoJson) COLLATE Modern_Spanish_CI_AS
                               END
                           )
                           AND (
                               (UPPER(j.TipoGastoJson COLLATE Modern_Spanish_CI_AS) = 'SERVICIOS PUBLICOS-AGUA' AND UPPER(p.nombre_empresa) = 'AYSA')
                               OR (UPPER(j.TipoGastoJson COLLATE Modern_Spanish_CI_AS) = 'SERVICIOS PUBLICOS-LUZ' AND UPPER(p.nombre_empresa) = 'EDENOR')
                               OR (UPPER(j.TipoGastoJson COLLATE Modern_Spanish_CI_AS) NOT LIKE 'SERVICIOS PUBLICOS%')
                           )

        WHERE
            j.Importe_Decimal IS NOT NULL -- Filtra los valores que no se pudieron parsear
            AND j.Importe_Decimal > 0 
            AND NOT EXISTS (
                SELECT 1
                FROM gastoOrdinario go_exist
                WHERE go_exist.id_gasto = g.id_gasto
                  AND go_exist.tipo_gasto = UPPER(j.TipoGastoJson COLLATE Modern_Spanish_CI_AS)
            );
            
        PRINT 'Carga de Gastos Ordinarios completada. Se insertaron ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros.';
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Error al cargar Gastos Ordinarios desde JSON: %s', 16, 1, @ErrorMessage);
        RETURN -4;
    END CATCH

END;
GO



-- 1. Declarar la variable para la ruta del JSON
DECLARE @RutaJson VARCHAR(255) = ''; -- <--- ¡ACTUALIZA ESTO!
-- 2. Ejecutar el Stored Procedure
EXEC spImportarGastosOrdinarios @RutaArchivoJson = @RutaJson;
GO

select * from gastoOrdinario

DELETE FROM gastoOrdinario; 
DBCC CHECKIDENT ('gastoOrdinario', RESEED, 0);

--------------------------------------------------------------------------------------------------------------------------------------------
--CARGAR GASTOS EXTRAORDINARIOS CON SQL DINÁMICO PARA LA RUTA DE ACCESO
CREATE OR ALTER PROCEDURE sp_importar_gastosExtraordinarios
    @RutaArchivo VARCHAR(255)  -- Parámetro de entrada para la ruta del archivo
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

    -- Declarar una variable para el SQL dinámico
    DECLARE @sql_dinamico NVARCHAR(MAX);

    -- Construir la instrucción BULK INSERT usando el parámetro
    SET @sql_dinamico = 
        'BULK INSERT #tempGastoExtraordinario ' + 
        'FROM ''' + @RutaArchivo + ''' ' +  -- Importante: se usan dos comillas simples ('') para la ruta
        'WITH ( ' +
            'FIELDTERMINATOR = '';'', ' +
            'ROWTERMINATOR = ''\n'', ' +
            'FIRSTROW = 2 ' +
        ');';

    -- Ejecutar la importación (requiere permisos 'BULK ADMIN' o 'ADMINISTRATOR')
    EXEC sp_executesql @sql_dinamico;

    INSERT INTO gastoExtraordinario (id_consorcio, tipo_gasto, descripcion,importe,fecha_gasto,forma_pago,cuota)
	SELECT c.id_consorcio, tge.tipo, tge.descripcion, tge.importe, tge.fecha, tge.tipo_pago, tge.cuota
	FROM #tempGastoExtraordinario tge 
    inner join consorcio c on tge.nombre_consorcio = c.nombre
    
    --Asocia id_gasto a cada gasto (lo probé y funciona perfecto, pero testear por las dudas)
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
-- Ejemplo de ejecución (debe estar en el script de testing/invocaciones)
DECLARE @archivo_gastosExtraordinarios VARCHAR(255) = ''; --<----RUTA DE ACCESO a gastos_extraordinarios.csv

-- Restablece el IDENTITY para la prueba
DELETE FROM gastoExtraordinario; 
DBCC CHECKIDENT ('gastoExtraordinario', RESEED, 0);

-- Ejecuta el SP pasando la variable con la ruta del archivo
EXEC sp_importar_gastosExtraordinarios @RutaArchivo = @archivo_gastosExtraordinarios;

-- Verificación
SELECT * FROM gastoExtraordinario
order by id_consorcio
GO
--------------------------------------------------------------------------------------------------------------------------------------------





