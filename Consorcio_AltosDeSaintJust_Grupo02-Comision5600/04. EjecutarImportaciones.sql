/*
Comisión:         02-5600
Grupo:            G02
Integrantes:
    - DE LA FUENTE SILVA, CELESTE (45315259)
    - FERNANDEZ MARISCAL, AGUSTIN (45614233)
    - GAUTO, JUAN BAUTISTA (45239479)

Enunciado:        "Ejecución de Procedimientos Almacenados para la importación y cifrado de datos"
*/

--------------------------------------------------------------------------------
use Com5600G02
go


--------------------------------------CARGAR persona
DECLARE @archivo_personas VARCHAR(255) = 'C:\Unlam 2.0\Segundo año\Bdd aplicada\Trabajo práctico\SQL\TP_Final_Grupo02_Com5600\Grupo2-Comision5600\Archivos_importacion\Inquilino-propietarios-datos.csv'; --<--Inquilino-propietarios-datos.csv
--DELETE FROM consorcio.persona; 
--DBCC CHECKIDENT ('consorcio.persona', RESEED, 0);
EXEC consorcio.sp_importar_personas @RutaArchivoPersonas = @archivo_personas;
GO
--select * from consorcio.persona;

--------------------------------------CARGAR consorcio
DECLARE @archivo_consorcios VARCHAR(255) = 'C:\Unlam 2.0\Segundo año\Bdd aplicada\Trabajo práctico\SQL\TP_Final_Grupo02_Com5600\Grupo2-Comision5600\Archivos_importacion\datos varios(Consorcios).csv'; --<-- datos varios 1(Consorcios).csv
--DELETE FROM consorcio.consorcio; 
--DBCC CHECKIDENT ('consorcio.consorcio', RESEED, 0);
EXEC consorcio.sp_importar_consorcios @RutaArchivo = @archivo_consorcios;
GO
--select * from consorcio.consorcio

------------------------------------CARGAR unidadFuncional
DECLARE @archivo_uf VARCHAR(255) = 'C:\Unlam 2.0\Segundo año\Bdd aplicada\Trabajo práctico\SQL\TP_Final_Grupo02_Com5600\Grupo2-Comision5600\Archivos_importacion\UF por consorcio.txt'; --<-- UF por consorcio.txt
--DELETE FROM consorcio.unidadFuncional; 
--DBCC CHECKIDENT ('consorcio.unidadFuncional', RESEED, 0);
EXEC consorcio.sp_importar_uf @RutaArchivoUF = @archivo_uf;
GO
--select * from consorcio.unidadFuncional

------------------------------------CARGAR cuenta_origen EN unidadFuncional
DECLARE @RutaArchivoC VARCHAR(255) = 'C:\Unlam 2.0\Segundo año\Bdd aplicada\Trabajo práctico\SQL\TP_Final_Grupo02_Com5600\Grupo2-Comision5600\Archivos_importacion\Inquilino-propietarios-UF.csv'; --<-- Inquilino-propietarios-UF.csv
EXEC consorcio.sp_asociar_cuentas_uf @RutaArchivoCuentas = @RutaArchivoC;
--SELECT * FROM consorcio.unidadFuncional
GO

-------------------------------------CARGAR personaUF
DECLARE @archivo_relacion_uf VARCHAR(255) = 'C:\Unlam 2.0\Segundo año\Bdd aplicada\Trabajo práctico\SQL\TP_Final_Grupo02_Com5600\Grupo2-Comision5600\Archivos_importacion\Inquilino-propietarios-UF.csv'; -- <---- RUTA Inquilino-propietarios-UF.csv
DECLARE @archivo_datos_persona VARCHAR(255) = 'C:\Unlam 2.0\Segundo año\Bdd aplicada\Trabajo práctico\SQL\TP_Final_Grupo02_Com5600\Grupo2-Comision5600\Archivos_importacion\Inquilino-propietarios-datos.csv'; -- <---- RUTA Inquilino-propietarios-datos.csv
--DELETE FROM consorcio.personaUf;
--DBCC CHECKIDENT ('consorcio.personaUf', RESEED, 0);
EXEC consorcio.sp_importar_persona_uf 
	@RutaArchivoRelacionUF = @archivo_relacion_uf, 
	@RutaArchivoDatosPersona = @archivo_datos_persona;
GO
--select * consorcio.from personaUF

--------------------------------------------------CARGAR pago
DECLARE @archivo_pagos VARCHAR(255) = 'C:\Unlam 2.0\Segundo año\Bdd aplicada\Trabajo práctico\SQL\TP_Final_Grupo02_Com5600\Grupo2-Comision5600\Archivos_importacion\pagos_consorcios.csv'; -- <---- RUTA pagos_consorcios.csv
--DELETE FROM consorcio.pago;
--DBCC CHECKIDENT ('consorcio.pago', RESEED, 0);
EXEC consorcio.sp_importar_pagos @RutaArchivoPagos = @archivo_pagos;
GO
--select top(100) * consorcio.from pago;
--select * from consorcio.pago

---------------------------------------------CARGAR proveedor
DECLARE @archivo_provedores VARCHAR(255) = 'C:\Unlam 2.0\Segundo año\Bdd aplicada\Trabajo práctico\SQL\TP_Final_Grupo02_Com5600\Grupo2-Comision5600\Archivos_importacion\datos varios 1(Proveedores).csv'; -- <---- RUTA datos varios 1(Proveedores).csv
--DELETE FROM consorcio.proveedor;
--DBCC CHECKIDENT ('consorcio.proveedor', RESEED, 0);
EXEC consorcio.sp_importar_proveedores @RutaArchivoProveedores = @archivo_provedores;
GO
--select * from consorcio.proveedor

----------------------------------------------CARGAR expensa
--DELETE FROM consorcio.expensa;
--DBCC CHECKIDENT ('consorcio.expensa', RESEED, 0);
DECLARE @periodo_mes_test VARCHAR(12) = 'Abril'; -- (Abril, Mayo, Junio)
DECLARE @anio_test INT = 2025;             -- el año
-- 2. Ejecutar el Stored Procedure
EXEC consorcio.sp_generar_expensas   
    @periodo_mes = @periodo_mes_test,
    @anio = @anio_test;
GO 

DECLARE @periodo_mes_test VARCHAR(12) = 'Mayo'; -- (Abril, Mayo, Junio)
DECLARE @anio_test INT = 2025;             -- El año
-- 2. Ejecutar el Stored Procedure
EXEC consorcio.sp_generar_expensas   
    @periodo_mes = @periodo_mes_test,
    @anio = @anio_test;
GO 

DECLARE @periodo_mes_test VARCHAR(12) = 'Junio'; -- (Abril, Mayo, Junio)
DECLARE @anio_test INT = 2025;             -- El año
-- 2. Ejecutar el Stored Procedure
EXEC consorcio.sp_generar_expensas    
    @periodo_mes = @periodo_mes_test,
    @anio = @anio_test;
GO 
--select * consorcio.from expensa;
-- 3. Verificaci�n de Resultados
/*SELECT 
    e.id_expensa,
    e.periodo,
    c.nombre AS Nombre_Consorcio
FROM 
    consorcio.expensa e
INNER JOIN 
    consorcio.consorcio c ON e.id_consorcio = c.id_consorcio
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
select * consorcio.from expensa
order by id_expensa*/

--------------------------------------------------------CARGAR gasto
--DELETE FROM consorcio.gasto;
--DBCC CHECKIDENT ('consorcio.gasto', RESEED, 0);
-- Ejecutar el Stored Procedure para inicializar la tabla Gasto
EXEC consorcio.sp_generar_gastos;
GO

--select * from consorcio.gasto
-- Verificaci�n de Resultados
-- Muestra el n�mero de registros en Gasto que tienen subtotales en NULL
/*SELECT 
    COUNT(*) AS Total_Registros_Gasto_Creados
FROM 
    consorcio.gasto g
WHERE 
    g.subtotal_ordinarios IS NULL 
    AND g.subtotal_extraordinarios IS NULL;
select * from consorcio.gasto*/

------------------------------------------------CARGAR gastoOrdinario
DECLARE @archivo NVARCHAR(4000) = 'C:\Unlam 2.0\Segundo año\Bdd aplicada\Trabajo práctico\SQL\TP_Final_Grupo02_Com5600\Grupo2-Comision5600\Archivos_importacion\Servicios.Servicios.json'; --<-- Servicios.Servicios.json
--DELETE FROM consorcio.gastoOrdinario;
--DBCC CHECKIDENT ('consorcio.gastoOrdinario', RESEED, 0);
EXEC consorcio.sp_gastos_ordinarios @RutaArchivoJSON = @archivo;
GO
--select * from consorcio.gastoOrdinario

-----------------------------------------------CARGAR gastoExtraordinario
DECLARE @archivo_gastosExtraordinarios VARCHAR(255) = 'C:\Unlam 2.0\Segundo año\Bdd aplicada\Trabajo práctico\SQL\TP_Final_Grupo02_Com5600\Grupo2-Comision5600\Archivos_importacion\gastos_extraordinarios.csv'; --<----RUTA DE ACCESO a gastos_extraordinarios.csv
--DELETE FROM consorcio.gastoExtraordinario;
--DBCC CHECKIDENT ('consorcio.gastoExtraordinario', RESEED, 0);
EXEC consorcio.sp_importar_gastosExtraordinarios @RutaArchivo = @archivo_gastosExtraordinarios;
--select * from consorcio.gastoExtraordinario 

----------------------------------------------------CARGAR subtotalOrdinario EN gasto
EXEC consorcio.sp_calcular_subtotalesGastos;
GO
--select * from consorcio.gasto
--VERIFICACION
/* 
select * from consorcio.gasto
-- 2. Verificación de Resultados
-- Muestra el IdGasto, la suma de los detalles y el subtotal actualizado.
SELECT
    g.id_gasto,
    g.subtotal_ordinarios AS Calculado_Ordinario,
    g.subtotal_extraordinarios AS Calculado_Extraordinario,
    (SELECT SUM(importe) FROM consorcio.gastoOrdinario gu WHERE gu.id_gasto = g.id_gasto) AS Suma_Detalle_Ordinario,
    (SELECT SUM(importe) FROM consorcio.gastoExtraordinario ge WHERE ge.id_gasto = g.id_gasto) AS Suma_Detalle_Extraordinario
FROM 
    consorcio.gasto g
WHERE 
    g.subtotal_ordinarios IS NOT NULL OR g.subtotal_extraordinarios IS NOT NULL
ORDER BY
    g.id_gasto;
GO
*/



-------------------------------------------------------CARGAR estadoCuentaProrrateo

-- Redeclaramos las variables para este lote
DECLARE @periodo_mes_eje VARCHAR(12) = 'Abril'; 
DECLARE @anio_eje INT = 2025; 

PRINT '--- 1. INICIANDO GENERACIÓN DE DEUDA (PRORRATEO)---';
EXEC consorcio.sp_generar_estadoCuentaProrrateo @periodo_mes = @periodo_mes_eje, @anio = @anio_eje;
GO

DECLARE @periodo_mes_eje VARCHAR(12) = 'Mayo'; 
DECLARE @anio_eje INT = 2025; 

PRINT '--- 1. INICIANDO GENERACIÓN DE DEUDA (PRORRATEO)---';
EXEC consorcio.sp_generar_estadoCuentaProrrateo @periodo_mes = @periodo_mes_eje, @anio = @anio_eje;
GO 

DECLARE @periodo_mes_eje VARCHAR(12) = 'Junio'; 
DECLARE @anio_eje INT = 2025; 

PRINT '--- 1. INICIANDO GENERACIÓN DE DEUDA (PRORRATEO)---';
EXEC consorcio.sp_generar_estadoCuentaProrrateo @periodo_mes = @periodo_mes_eje, @anio = @anio_eje;
GO 

--select * from consorcio.estadoCuentaProrrateo 

--DELETE FROM consorcio.estadoCuentaProrrateo;
--DBCC CHECKIDENT ('consorcio.estadoCuentaProrrateo', RESEED, 0);


--------------------------------------------ASOCIAR PAGOS A ESADOCUENTAPRORRATEO----------------------------
EXEC consorcio.sp_AsociarPagosAEstadoCuenta;
GO
/*UPDATE consorcio.pago
SET 
    asociado = 'NO',
    id_detalleDeCuenta = NULL;

-- (Opcional) Verifica los cambios
SELECT * FROM consorcio.pago;*/
--select * from consorcio.estadoCuentaProrrateo 
---------------------------------------------Recalcular tabla estadoCuentaProrrateo-------------------------
EXEC consorcio.sp_RecalcularSaldosYMoras;
GO

--select * from consorcio.estadoCuentaProrrateo


----------------------------------------------CALCULAR ESTADO FINANCIERO-------------------
EXEC consorcio.sp_generar_estado_financiero
GO

--select * from consorcio.estadoFinanciero

--DELETE FROM consorcio.estadoFinanciero;
--DBCC CHECKIDENT ('consorcio.estadoFinanciero', RESEED, 0);


---------------------------------Migrar a cifrado de datos-----------
EXEC consorcio.sp_migrar_a_cifrado
    @FraseClave = 'cifradoseguro';
GO
-----unidadFuncional cuenta cifrada
-----pago
-----persona

------------------------------Descifrar datos ------------------------------------
EXEC consorcio.sp_revertir_cifrado
    @FraseClave = 'cifradoseguro';
GO

---------------------------------------TESTING--------------------------------------------------
select * from consorcio.persona
select * from consorcio.consorcio
select * from consorcio.personaUF
select * from consorcio.unidadFuncional
select * from consorcio.proveedor
select * from consorcio.pago
select * from consorcio.gasto
select * from consorcio.gastoOrdinario
select * from consorcio.gastoExtraordinario
select * from consorcio.expensa
select * from consorcio.estadoCuentaProrrateo
select * from consorcio.estadoFinanciero
