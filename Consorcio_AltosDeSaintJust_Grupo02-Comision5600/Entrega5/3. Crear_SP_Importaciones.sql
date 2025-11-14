-- NOTA! Se puede ejectuar todo de una

--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------  STORED PROCEDURES  ---------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------

--CARGAR PERSONAS
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

--------------------------------------------------------------------------------------------------------------------------------------------

--CARGAR CONSORCIOS 
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

--------------------------------------------------------------------------------------------------------------------------------------------

--CARGAR UF
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
    -- Nota: Aqu� se asume que la tabla 'unidadfuncional' no admite duplicados 
    INSERT INTO unidadFuncional (id_consorcio, numero_uf, piso, depto, cochera, cochera_m2, baulera, baulera_m2, cant_m2, coeficiente)
	SELECT    UPPER(c.id_consorcio), CAST(u.numero_uf AS INT), CAST(u.piso AS varchar(3)), CAST(u.depto as varchar(5)), 
        CASE WHEN u.cochera = 'SI' THEN 1 ELSE 0 END, CAST(u.cochera_m2 AS INT), CASE WHEN u.baulera = 'SI' THEN 1 ELSE 0 END, 
        CAST(u.baulera_m2 as INT), CAST(u.uf_m2 AS INT), CAST(REPLACE(u.coeficiente, ',', '.') AS decimal (2,1))
	FROM #tempUf u
	JOIN consorcio c ON c.nombre = u.nombre_consorcio;
END;
GO

--------------------------------------------------------------------------------------------------------------------------------------------

-- CARGAR cuenta_origen EN unidadFuncional
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
--------------------------------------------------------------------------------------------------------------------------------------------

-- CARGAR personaUF
-- Este SP necesita dos archivos para cruzar la informaci�n:
-- 1. El archivo de relaci�n UF-CVU/CBU (Inquilino-propietarios-UF.csv)
-- 2. El archivo de datos de Persona (Inquilino-propietarios-datos.csv)

CREATE OR ALTER PROCEDURE sp_importar_persona_uf
    @RutaArchivoRelacionUF VARCHAR(255), -- (delimitador '|')
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
        GETDATE() AS fecha_desde, -- Asumimos la fecha actual para la relación 
        NULL AS fecha_hasta,
        -- Inferimos el tipo de responsable usando la columna 'Inquilino'
        CASE WHEN tps.Inquilino = 1 THEN 'INQUILINO' ELSE 'PROPIETARIO' END AS tipo_responsable
    FROM
        #tempRelacionUF truf
        -- Unir con el estado de inquilino para obtener el DNI y el tipo de responsable
        INNER JOIN #tempPersonaStatus tps 
            ON REPLACE(LTRIM(RTRIM(truf.CVU_CBU)), ' ', '') = REPLACE(LTRIM(RTRIM(tps.Cuenta)), ' ', '')
        -- Unir con la tabla Persona para asegurar la existencia del DNI
        INNER JOIN persona p 
            ON p.dni = LTRIM(RTRIM(tps.DNI))
        -- Unir con la tabla Consorcio
        INNER JOIN consorcio c 
            ON c.nombre = truf.Nombre_Consorcio
        -- Unir con la tabla Unidad Funcional para obtener el id_uf
        INNER JOIN unidadFuncional uf 
            ON uf.id_consorcio = c.id_consorcio 
            AND uf.numero_uf = CAST(truf.nroUnidadFuncional AS INT)
            AND uf.piso = truf.piso 
            AND uf.depto = truf.departamento
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

--------------------------------------------------------------------------------------------------------------------------------------------

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


 INSERT INTO pago (fecha, cuenta_origen, importe, asociado, id_detalleDeCuenta)
SELECT
TRY_CONVERT(DATE, t.fecha, 103), -- Formato 103: dd/mm/yyyy
 REPLACE(LTRIM(RTRIM(t.CVU_CBU)), ' ', ''),
CAST(REPLACE(REPLACE(REPLACE(t.Valor, '$', ''), ' ', ''), '.', '') AS DECIMAL(10, 2)),
'NO', -- Valor por defecto. Se podr�a actualizar a 'SI' cuando se genere la Expensa/EstadoCuentaProrrateo
 NULL AS id_detalleDeCuenta
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

--------------------------------------------------------------------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------------------------------------------------------------------

-- CARGAR expensa
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

--------------------------------------------------------------------------------------------------------------------------------------------

-- CARGAR gasto
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

--------------------------------------------------------------------------------------------------------------------------------------------
-- CARGAR gastoOrdinario
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

    --  Lectura del JSON a la tabla temporal (Pivoteada)
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
        --  Aplanar la tabla temporal (UNPIVOT LÓGICO)
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
    
    --  Mapear a Proveedor y Aplicar Lógica de Negocio
    FinalData AS (
        SELECT
            m.id_gasto,
            -- Tipos de Gasto...
            CASE m.TipoGastoCorto WHEN 'BANCARIOS' THEN 'GASTOS BANCARIOS' WHEN 'ADMINISTRACION' THEN 'GASTOS DE ADMINISTRACION' WHEN 'SEGUROS' THEN 'SEGUROS' WHEN 'LIMPIEZA' THEN 'GASTOS DE LIMPIEZA' WHEN 'G.GENERALES' THEN 'GASTOS GENERALES' WHEN 'AGUA' THEN 'SERVICIOS PUBLICOS' WHEN 'LUZ' THEN 'SERVICIOS PUBLICOS' ELSE 'OTROS' END AS tipo_gasto,
            -- Subtipos de Gasto...
            CASE m.TipoGastoCorto WHEN 'BANCARIOS' THEN 'GASTOS BANCARIOS' WHEN 'ADMINISTRACION' THEN 'HONORARIOS' WHEN 'SEGUROS' THEN 'INTEGRAL DE CONSORCIO' WHEN 'LIMPIEZA' THEN 'SERVICIO DE LIMPIEZA' WHEN 'AGUA' THEN 'SERVICIO DE AGUA' WHEN 'LUZ' THEN 'SERVICIO DE ELECTRICIDAD' ELSE NULL END AS subtipoGasto,
            
            p.nombre_empresa,
            
           TRY_CAST(
               REPLACE(
                   REPLACE(
                       TRIM(m.ImporteString), 
                   '.', ''), -- 1. Eliminar todos los puntos (asumidos separadores de miles)
               ',', '')       -- 2. Eliminar todas las comas (asumidas separadores de miles/decimales)
           AS DECIMAL(18, 2)) / 100.0 AS importe
            
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
            --  Discriminación de Proveedor (AYSA/EDENOR)
            AND (
                (m.TipoGastoCorto = 'AGUA' AND p.nombre_empresa = 'AYSA')
                OR (m.TipoGastoCorto = 'LUZ' AND p.nombre_empresa = 'EDENOR')
                OR (m.TipoGastoCorto NOT IN ('AGUA', 'LUZ'))
            )
    )

    --  Inserción Final
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

    --  Limpieza y Mensaje
    DROP TABLE #gastoOrdinarioTemp;
    
    PRINT 'Carga de Gastos Ordinarios completada. Se insertaron ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros.';

END
GO
--------------------------------------------------------------------------------------------------------------------------------------------
--CARGAR gastoExtraordinario
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
    
    --Asocia id_gasto a cada gasto 
    UPDATE ge 
    SET ge.id_gasto = g.id_gasto
    FROM gastoExtraordinario ge
    JOIN consorcio c ON ge.id_consorcio = c.id_consorcio
    JOIN expensa e ON e.id_consorcio = c.id_consorcio
    JOIN gasto g ON g.id_expensa = e.id_expensa
    WHERE e.periodo = CONVERT(VARCHAR(7), ge.fecha_gasto, 120);

END
GO
--------------------------------------------------------------------------------------------------------------------------------------------
-- CARGAR subtotales EN gasto
CREATE OR ALTER PROCEDURE sp_calcularSubtotalesGastos
AS
BEGIN
    SET NOCOUNT ON;

    --  Se combinan ambas CTEs en una única cláusula WITH, separadas por coma.
    WITH SubtotalesOrdinarios AS (
        SELECT
            ge.id_gasto,
            SUM(ge.importe) AS TotalOrdinario
        FROM
            gastoOrdinario ge
        GROUP BY
            ge.id_gasto
    ), -- 
    
    SubtotalesExtraordinarios AS (
        SELECT
            ge.id_gasto,
            SUM(ge.importe) AS TotalExtraordinario
        FROM
            gastoExtraordinario ge
        GROUP BY
            ge.id_gasto
    ) 

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

    
    PRINT 'Actualización de subtotales de gastos completada. ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros actualizados.';
    RETURN 0;

END
GO
--------------------------------------------------------------------------------------------------------------------------------------------
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
            de.subtotal_ordinarios * (de.coeficiente/100) AS expensas_ordinarias,
            de.subtotal_extraordinarios * (de.coeficiente/100) AS expensas_extraordinarias
        FROM DatosExpensa de
        INNER JOIN SaldoAnterior sa ON de.id_uf = sa.id_uf
    )
    -- Insertar el Prorrateo en la tabla de destino
    INSERT INTO estadoCuentaProrrateo (
        id_expensa, id_uf, fecha_emision, fecha_1er_venc, fecha_2do_venc,
        saldo_anterior, pagos_recibidos, deuda, interes_por_mora, expensas_ordinarias,
        expensas_extraordinarias, total_pagar 
    )
    SELECT
        pc.id_expensa, pc.id_uf, @fecha_emision, @fecha_1er_venc, @fecha_2do_venc,
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

select * from estadoCuentaProrrateo

--------------------------------Asociar los pagos------------------------------------------
CREATE OR ALTER PROCEDURE sp_AsociarPagosAEstadoCuenta
AS
BEGIN
    -- Evita que se devuelvan mensajes de conteo de filas (SET NOCOUNT ON)
    SET NOCOUNT ON; 

    -- Declarar variables para seguimiento
    DECLARE @PagosAsociados INT = 0;

    -- Actualizar la tabla 'pago' para asociar los pagos a un 'estadoCuentaProrrateo'
    -- Se añade la condición de que el AÑO y el MES del pago (P.fecha) 
    -- deben coincidir con el AÑO y el MES de emisión de la expensa (ECP.fecha_emision).
    UPDATE P
    SET 
        P.asociado = 'SI',
        P.id_detalleDeCuenta = ECP.id_detalleDeCuenta
    FROM 
        pago P
    INNER JOIN 
        unidadFuncional UF ON P.cuenta_origen = UF.cuenta_origen
    INNER JOIN 
        estadoCuentaProrrateo ECP ON UF.id_uf = ECP.id_uf
    WHERE 
        P.asociado = 'NO' -- Solo pagos no asociados
        AND P.id_detalleDeCuenta IS NULL -- Aseguramos que no tenga asociación previa
        
        -- Asocia el pago a la expensa emitida en el MISMO mes y año del pago.
        AND YEAR(P.fecha) = YEAR(ECP.fecha_emision)
        AND MONTH(P.fecha) = MONTH(ECP.fecha_emision);

    -- Capturar el número de filas actualizadas
    SET @PagosAsociados = @@ROWCOUNT;

    -- Se suma el importe de los pagos recién asociados (y los previamente asociados) 
    -- al campo 'pagos_recibidos' de la cuenta corriente.
    UPDATE ECP
    SET 
        ECP.pagos_recibidos = ISNULL(ECP.pagos_recibidos, 0) + P.importe
    FROM 
        estadoCuentaProrrateo ECP
    INNER JOIN 
        pago P ON ECP.id_detalleDeCuenta = P.id_detalleDeCuenta
    WHERE
        P.id_detalleDeCuenta IS NOT NULL; -- Solo registros que tienen una asociación.

    -- Retornar el número de pagos asociados
    SELECT @PagosAsociados AS PagosAsociadosExitosamente;

END
GO
-------------------------Recalcular tabla estadoCuentaProrrateo------------------

CREATE OR ALTER FUNCTION fn_CalcularInteresMora_Nuevo (
    @p_saldo_pendiente DECIMAL(10,2),
    @p_fecha_1er_venc DATE,
    @p_fecha_2do_venc DATE,
    @p_fecha_calculo DATE
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Interes DECIMAL(10,2) = 0.00;
    
    IF @p_saldo_pendiente <= 0
        RETURN 0.00; 

    -- Caso 1: Después del 2do Vencimiento (5%)
    IF @p_fecha_calculo > @p_fecha_2do_venc
    BEGIN
        SET @Interes = @p_saldo_pendiente * 0.05;
    END
    -- Caso 2: Después del 1er Vencimiento y hasta el 2do Vencimiento (2%)
    ELSE IF @p_fecha_calculo > @p_fecha_1er_venc
    BEGIN
        -- Nota: La mora del 2% se aplica al monto Ordinario/Total (no solo al saldo pendiente).
        -- Para simplificar y seguir la lógica de aplicar mora al "saldo pendiente" (Deuda),
        -- aplicaremos el 2% a ese saldo pendiente.
        SET @Interes = @p_saldo_pendiente * 0.02; 
    END

    RETURN @Interes;
END
GO

CREATE OR ALTER PROCEDURE sp_RecalcularSaldosYMoras
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Se utiliza la fecha actual para determinar si aplica mora
    DECLARE @FechaCalculo DATE = GETDATE();

    -- Actualizar DEUDA e INTERES_POR_MORA para *TODAS* las expensas
    -- La lógica de mora se aplica sobre el SALDO PENDIENTE (Total a Pagar Inicial - Pagos Recibidos)

    UPDATE ECP
    SET
        -- Calcular el SALDO PENDIENTE (Deuda) 
        -- Nota: Usamos la columna 'deuda' para guardar el saldo final adeudado.
        ECP.deuda = ECP.total_pagar - ISNULL(ECP.pagos_recibidos, 0),
        
        -- Calcular el nuevo INTERÉS POR MORA
        -- Se aplica mora solo si el pago fue menor que el total a pagar
        ECP.interes_por_mora = 
            CASE
                -- Si hay un saldo pendiente (Deuda)
                WHEN ECP.total_pagar > ISNULL(ECP.pagos_recibidos, 0) THEN
                    -- Se llama a la función de mora para calcular el interés
                    dbo.fn_CalcularInteresMora_Nuevo(
                        ECP.total_pagar - ISNULL(ECP.pagos_recibidos, 0), -- Monto a aplicar la mora (Deuda)
                        ECP.fecha_1er_venc,
                        ECP.fecha_2do_venc,
                        @FechaCalculo
                    )
                ELSE
                    0.00 -- Si se pagó por completo o de más, la mora es cero
            END
    FROM
        estadoCuentaProrrateo ECP; -- Aplica a TODAS las filas

    -- 2. Actualizar TOTAL A PAGAR (Total Pagar Final) para *TODAS* las expensas
    
    UPDATE ECP
    SET
        -- Total a pagar = Deuda Pendiente + Interés por Mora 
        ECP.total_pagar = ECP.deuda + ECP.interes_por_mora
    FROM
        estadoCuentaProrrateo ECP; -- Aplica a TODAS las filas

    PRINT 'Recálculo de saldos y moras completado para TODAS las expensas cargadas.';

END
GO




------------------- ESTADO FINANCIERO -----------------------------
CREATE OR ALTER PROCEDURE generarEstadoFinanciero
AS
BEGIN
    SET NOCOUNT ON;

    -------------------------------------------------------------------
    -- Obtener todos los períodos como fecha, ordenados
    -------------------------------------------------------------------
    IF OBJECT_ID('tempdb..#periodos') IS NOT NULL DROP TABLE #periodos;

    SELECT DISTINCT 
        CONVERT(date, periodo + '-01') AS periodo_fecha
    INTO #periodos
    FROM expensa;

    -------------------------------------------------------------------
    -- Ordenar períodos
    -------------------------------------------------------------------
    DECLARE @periodo_actual DATE;

    WHILE EXISTS (SELECT 1 FROM #periodos)
    BEGIN
        -------------------------------------------------------------------
        -- Tomar el período más antiguo
        -------------------------------------------------------------------
        SELECT TOP 1 @periodo_actual = periodo_fecha
        FROM #periodos
        ORDER BY periodo_fecha;

        -------------------------------------------------------------------
        -- Insertar estado financiero para todos los consorcios en este período
        -------------------------------------------------------------------
        INSERT INTO estadoFinanciero (
            id_consorcio,
            saldo_anterior,
            ingreso_expensas_termino,
            ingreso_expensas_adeudadas,
            ingreso_expensas_adelantadas,
            egreso,
            saldo_cierre,
            periodo
        )
        SELECT  
            c.id_consorcio,

            --------------------------------------------------------------
            -- SALDO ANTERIOR
            --------------------------------------------------------------
            ISNULL((
                SELECT TOP 1 ef.saldo_cierre
                FROM estadoFinanciero ef
                WHERE ef.id_consorcio = c.id_consorcio
                  AND ef.periodo < @periodo_actual
                ORDER BY ef.periodo DESC
            ), 0) AS saldo_anterior,

            --------------------------------------------------------------
            -- INGRESOS EN TÉRMINO
            --------------------------------------------------------------
            ISNULL((
                SELECT SUM(pg.importe)
                FROM pago pg
                JOIN estadoCuentaProrrateo ec ON pg.id_detalleDeCuenta = ec.id_detalleDeCuenta
                JOIN expensa ex ON ec.id_expensa = ex.id_expensa
                WHERE ex.id_consorcio = c.id_consorcio
                  AND CONVERT(date, ex.periodo + '-01') = @periodo_actual
                  AND pg.fecha <= ec.fecha_2do_venc
                  AND pg.fecha >= ec.fecha_emision
            ), 0) AS ingreso_termino,

            --------------------------------------------------------------
            -- INGRESOS ADEUDADOS
            --------------------------------------------------------------
            ISNULL((
                SELECT SUM(pg.importe)
                FROM pago pg
                JOIN estadoCuentaProrrateo ec ON pg.id_detalleDeCuenta = ec.id_detalleDeCuenta
                JOIN expensa ex ON ec.id_expensa = ex.id_expensa
                WHERE ex.id_consorcio = c.id_consorcio
                  AND CONVERT(date, ex.periodo + '-01') = @periodo_actual
                  AND pg.fecha > ec.fecha_2do_venc
            ), 0) AS ingreso_adeudadas,

            --------------------------------------------------------------
            -- INGRESOS ADELANTADOS
            --------------------------------------------------------------
            ISNULL((
                SELECT SUM(pg.importe)
                FROM pago pg
                JOIN estadoCuentaProrrateo ec ON pg.id_detalleDeCuenta = ec.id_detalleDeCuenta
                JOIN expensa ex ON ec.id_expensa = ex.id_expensa
                WHERE ex.id_consorcio = c.id_consorcio
                  AND CONVERT(date, ex.periodo + '-01') = @periodo_actual
                  AND pg.fecha < ec.fecha_emision
            ), 0) AS ingreso_adelantadas,

            --------------------------------------------------------------
            -- EGRESOS
            --------------------------------------------------------------
            (
                ISNULL((
                    SELECT SUM(gor.importe)
                    FROM gasto g
                    JOIN gastoOrdinario gor ON g.id_gasto = gor.id_gasto
                    WHERE g.id_expensa IN (
                        SELECT id_expensa FROM expensa
                        WHERE id_consorcio = c.id_consorcio
                          AND CONVERT(date, periodo + '-01') = @periodo_actual
                    )
                ), 0)
                +
                ISNULL((
                    SELECT SUM(ger.importe)
                    FROM gasto g
                    JOIN gastoExtraordinario ger ON g.id_gasto = ger.id_gasto
                    WHERE g.id_expensa IN (
                        SELECT id_expensa FROM expensa
                        WHERE id_consorcio = c.id_consorcio
                          AND CONVERT(date, periodo + '-01') = @periodo_actual
                    )
                ), 0)
            ) AS egresos,

            --------------------------------------------------------------
            -- SALDO DE CIERRE
            --------------------------------------------------------------
            (
                -- saldo anterior
                ISNULL((
                    SELECT TOP 1 saldo_cierre
                    FROM estadoFinanciero
                    WHERE id_consorcio = c.id_consorcio
                      AND periodo < @periodo_actual
                    ORDER BY periodo DESC
                ), 0)
                +
                -- ingresos totales
                ISNULL((
                    SELECT SUM(pg.importe)
                    FROM pago pg
                    JOIN estadoCuentaProrrateo ec ON pg.id_detalleDeCuenta = ec.id_detalleDeCuenta
                    JOIN expensa ex ON ec.id_expensa = ex.id_expensa
                    WHERE ex.id_consorcio = c.id_consorcio
                      AND CONVERT(date, ex.periodo + '-01') = @periodo_actual
                ), 0)
                -
                -- egresos totales
                (
                    ISNULL((
                        SELECT SUM(gor.importe)
                        FROM gasto g
                        JOIN gastoOrdinario gor ON g.id_gasto = gor.id_gasto
                        WHERE g.id_expensa IN (
                            SELECT id_expensa FROM expensa
                            WHERE id_consorcio = c.id_consorcio
                              AND CONVERT(date, periodo + '-01') = @periodo_actual
                        )
                    ), 0)
                    +
                    ISNULL((
                        SELECT SUM(ger.importe)
                        FROM gasto g
                        JOIN gastoExtraordinario ger ON g.id_gasto = ger.id_gasto
                        WHERE g.id_expensa IN (
                            SELECT id_expensa FROM expensa
                            WHERE id_consorcio = c.id_consorcio
                              AND CONVERT(date, periodo + '-01') = @periodo_actual
                        )
                    ), 0)
                )
            ) AS saldo_cierre,

            @periodo_actual

        FROM consorcio c;

        -------------------------------------------------------------------
        -- Remover el período ya procesado
        -------------------------------------------------------------------
        DELETE FROM #periodos WHERE periodo_fecha = @periodo_actual;

    END -- WHILE

END;

