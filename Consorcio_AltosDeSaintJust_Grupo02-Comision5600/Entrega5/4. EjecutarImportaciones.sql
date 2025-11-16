/*
Comisión:         02-5600
Grupo:            G02
Integrantes:
    - DE LA FUENTE SILVA, CELESTE (45315259)
    - FERNANDEZ MARISCAL, AGUSTIN (45614233)
    - GAUTO, JUAN BAUTISTA (45239479)
*/

--------------------------------------------------------------------------------
use Com5600G02
GO
-- NOTA! Ejecutar uno por uno, y dos veces c/u por el IDENTITY que empieza en 0 algunas veces.


--CARGAR persona
DECLARE @archivo_personas VARCHAR(255) = ''; --<--Inquilino-propietarios-datos.csv
DELETE FROM persona; 
DBCC CHECKIDENT ('persona', RESEED, 0);
EXEC sp_importar_personas @RutaArchivoPersonas = @archivo_personas;
GO
select * from persona;

--CARGAR consorcio
DECLARE @archivo_consorcios VARCHAR(255) = ''; --<-- datos varios 1(Consorcios).csv
DELETE FROM consorcio; 
DBCC CHECKIDENT ('consorcio', RESEED, 0);
EXEC sp_importar_consorcios @RutaArchivo = @archivo_consorcios;
GO
select * from consorcio

--CARGAR unidadFuncional
DECLARE @archivo_uf VARCHAR(255) = ''; --<-- UF por consorcio.txt
DELETE FROM unidadFuncional; 
DBCC CHECKIDENT ('unidadFuncional', RESEED, 0);
EXEC sp_importar_uf @RutaArchivoUF = @archivo_uf;
GO
select * from unidadFuncional

-- CARGAR cuenta_origen EN unidadFuncional
DECLARE @RutaArchivoC VARCHAR(255) = ''; --<-- Inquilino-propietarios-UF.csv
EXEC sp_asociar_cuentas_uf @RutaArchivoCuentas = @RutaArchivoC;
SELECT * FROM unidadFuncional
GO

-- CARGAR personaUF
DECLARE @archivo_relacion_uf VARCHAR(255) = ''; -- <---- RUTA Inquilino-propietarios-UF.csv
DECLARE @archivo_datos_persona VARCHAR(255) = ''; -- <---- RUTA Inquilino-propietarios-datos.csv
DELETE FROM personaUf;
DBCC CHECKIDENT ('personaUf', RESEED, 0);
EXEC sp_importar_persona_uf 
	@RutaArchivoRelacionUF = @archivo_relacion_uf, 
	@RutaArchivoDatosPersona = @archivo_datos_persona;
GO
select * from personaUF

-- CARGAR pago
DECLARE @archivo_pagos VARCHAR(255) = ''; -- <---- RUTA pagos_consorcios.csv
DELETE FROM pago;
DBCC CHECKIDENT ('pago', RESEED, 0);
EXEC sp_importar_pagos @RutaArchivoPagos = @archivo_pagos;
GO
select top(100) * from pago;

-- CARGAR proveedor
DECLARE @archivo_provedores VARCHAR(255) = ''; -- <---- RUTA datos varios 1(Proveedores).csv
DELETE FROM proveedor;
DBCC CHECKIDENT ('proveedor', RESEED, 0);
EXEC sp_importar_proveedores @RutaArchivoProveedores = @archivo_provedores;
GO
select * from proveedor

-- CARGAR expensa
--DELETE FROM expensa;
--DBCC CHECKIDENT ('expensa', RESEED, 0);
DECLARE @periodo_mes_test VARCHAR(12) = 'Abril'; -- El mes que quieres generar (Abril, Mayo, Junio)
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
order by id_expensa

------------------ CARGAR gasto
DELETE FROM gasto;
DBCC CHECKIDENT ('gasto', RESEED, 0);
-- Ejecutar el Stored Procedure para inicializar la tabla Gasto
EXEC spGenerarGastos;
GO
-- Verificaci�n de Resultados
-- Muestra el n�mero de registros en Gasto que tienen subtotales en NULL
SELECT 
    COUNT(*) AS Total_Registros_Gasto_Creados
FROM 
    gasto g
WHERE 
    g.subtotal_ordinarios IS NULL 
    AND g.subtotal_extraordinarios IS NULL;
select * from gasto

------------------ CARGAR gastoOrdinario
DECLARE @archivo NVARCHAR(4000) = 'C:\Unlam 2.0\Segundo año\Bdd aplicada\Trabajo práctico\SQL\consorcios\Servicios.Servicios.json'; --<-- Servicios.Servicios.json

EXEC sp_gastos_ordinarios @RutaArchivoJSON = @archivo;
GO
select * from gastoOrdinario

-------------------CARGAR gastoExtraordinario
DECLARE @archivo_gastosExtraordinarios VARCHAR(255) = ''; --<----RUTA DE ACCESO a gastos_extraordinarios.csv
DELETE FROM gastoExtraordinario;
DBCC CHECKIDENT ('gastoExtraordinario', RESEED, 0);
EXEC sp_importar_gastosExtraordinarios @RutaArchivo = @archivo_gastosExtraordinarios;
select * from gastoExtraordinario 

------------------ CARGAR subtotalOrdinario EN gasto
EXEC sp_calcularSubtotalesGastos;
GO
select * from gasto
--VERIFICACION
/* 
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
*/



------------------------------ CARGAR estadoCuentaProrrateo
-------------------------------------------------------------------------
-- EJECUCION estadoCuentaProrrateo

-- Redeclaramos las variables para este lote
DECLARE @periodo_mes_eje VARCHAR(12) = ''; 
DECLARE @anio_eje INT = 2025; 

PRINT '--- 1. INICIANDO GENERACIÓN DE DEUDA (PRORRATEO)---';
EXEC sp_generar_estadoCuentaProrrateo @periodo_mes = @periodo_mes_eje, @anio = @anio_eje;
GO 
select * from estadoCuentaProrrateo
GO 

DELETE FROM estadoCuentaProrrateo;
DBCC CHECKIDENT ('estadoCuentaProrrateo', RESEED, 0);


----------------------ASOCIAR PAGOS A ESADOCUENTAPRORRATEO----------------------------
EXEC sp_AsociarPagosAEstadoCuenta;

UPDATE pago
SET 
    asociado = 'NO',
    id_detalleDeCuenta = NULL;

-- (Opcional) Verifica los cambios
SELECT * FROM pago;

------------------Recalcular tabla estadoCuentaProrrateo-------------------------
EXEC sp_RecalcularSaldosYMoras;

select * from estadoCuentaProrrateo


-----------------------CALCULAR ESTADO FINANCIERO-------------------
EXEC generarEstadoFinanciero

select * from estadoFinanciero

DELETE FROM estadoFinanciero;
DBCC CHECKIDENT ('estadoFinanciero', RESEED, 0);
