/*
Comisión:         02-5600
Grupo:            G02
Integrantes:
    - DE LA FUENTE SILVA, CELESTE (45315259)
    - FERNANDEZ MARISCAL, AGUSTIN (45614233)
    - GAUTO, JUAN BAUTISTA (45239479)

Enunciado:        "Creación de indices"
*/

--------------------------------------------------------------------------------
use Com5600G02
GO
-- INDICES REPORTES

-- REPORTE 1
-- flujo de caja en forma semanal

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_pago_fecha_detalle_R1' AND object_id = OBJECT_ID('consorcio.pago'))
CREATE NONCLUSTERED INDEX IX_pago_fecha_detalle_R1 
ON consorcio.pago (fecha, id_detalleDeCuenta)
INCLUDE (importe)
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ecp_detalle_valores_R1' AND object_id = OBJECT_ID('consorcio.estadoCuentaProrrateo'))
CREATE NONCLUSTERED INDEX IX_ecp_detalle_valores_R1 
ON consorcio.estadoCuentaProrrateo (id_detalleDeCuenta)
INCLUDE (id_expensa, total_pagar, expensas_ordinarias, expensas_extraordinarias)
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_expensa_consorcio_R1' AND object_id = OBJECT_ID('consorcio.expensa'))
CREATE NONCLUSTERED INDEX IX_expensa_consorcio_R1 
ON consorcio.expensa (id_consorcio)
INCLUDE (id_expensa)
GO

-- REPORTE 2
--  total de recaudación por mes y departamento en formato de tabla cruzada. 

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_pago_fecha_detalle' AND object_id = OBJECT_ID('consorcio.pago'))
CREATE NONCLUSTERED INDEX IX_pago_fecha_detalle 
ON consorcio.pago (fecha, id_detalleDeCuenta)
INCLUDE (importe)
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ecp_detalleDeCuenta_uf' AND object_id = OBJECT_ID('consorcio.estadoCuentaProrrateo'))
CREATE NONCLUSTERED INDEX IX_ecp_detalleDeCuenta_uf 
ON consorcio.estadoCuentaProrrateo (id_detalleDeCuenta)
INCLUDE (id_uf)
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_uf_consorcio_piso_depto' AND object_id = OBJECT_ID('consorcio.unidadFuncional'))
CREATE NONCLUSTERED INDEX IX_uf_consorcio_piso_depto 
ON consorcio.unidadFuncional (id_consorcio, piso)
INCLUDE (id_uf, depto)
GO


-- REPORTE 3
-- cuadro cruzado con la recaudación total desagregada según su procedencia 

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_expensa_consorcio_periodo' AND object_id = OBJECT_ID('consorcio.expensa'))
CREATE NONCLUSTERED INDEX IX_expensa_consorcio_periodo 
ON consorcio.expensa (id_consorcio, periodo)
INCLUDE (id_expensa)
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ecp_id_expensa_conceptos' AND object_id = OBJECT_ID('consorcio.estadoCuentaProrrateo'))
CREATE NONCLUSTERED INDEX IX_ecp_id_expensa_conceptos 
ON consorcio.estadoCuentaProrrateo (id_expensa)
INCLUDE (expensas_ordinarias, expensas_extraordinarias, interes_por_mora)
GO


-- REPORTE 4
-- meses de mayores gastos y mayores ingresos

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_EXPENSA_ConsorcioPeriodo' AND object_id = OBJECT_ID('consorcio.expensa'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_EXPENSA_ConsorcioPeriodo
    ON consorcio.expensa (id_consorcio, periodo);
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_GASTO_IdExpensa' AND object_id = OBJECT_ID('consorcio.gasto'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_GASTO_IdExpensa
    ON consorcio.gasto (id_expensa)
    INCLUDE (subtotal_ordinarios, subtotal_extraordinarios); 
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_UF_ConsorcioCuenta' AND object_id = OBJECT_ID('consorcio.unidadFuncional'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_UF_ConsorcioCuenta
    ON consorcio.unidadFuncional (id_consorcio, cuenta_origen);
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PAGO_CuentaOrigenFecha' AND object_id = OBJECT_ID('consorcio.pago'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_PAGO_CuentaOrigenFecha
    ON consorcio.pago (cuenta_origen, fecha)
    INCLUDE (importe); 
END
GO


-- REPORTE 5
-- propietarios con mayor morosidad.

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_puf_propietario_dni_uf' AND object_id = OBJECT_ID('consorcio.personaUf'))
CREATE NONCLUSTERED INDEX IX_puf_propietario_dni_uf 
ON consorcio.personaUf (tipo_responsable) 
INCLUDE (dni_persona, id_uf)
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ecp_id_uf_deuda' AND object_id = OBJECT_ID('consorcio.estadoCuentaProrrateo'))
CREATE NONCLUSTERED INDEX IX_ecp_id_uf_deuda 
ON consorcio.estadoCuentaProrrateo (id_uf)
INCLUDE (deuda) 
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_uf_id_consorcio' AND object_id = OBJECT_ID('consorcio.unidadFuncional'))
CREATE NONCLUSTERED INDEX IX_uf_id_consorcio
ON consorcio.unidadFuncional (id_consorcio)
INCLUDE (id_uf)
GO


-- REPORTE 6
-- echas de pagos de expensas ordinarias de cada UF y la cantidad de días que 
--pasan entre un pago y el siguiente
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_pago_fecha_detalle_R6' AND object_id = OBJECT_ID('consorcio.pago'))
CREATE NONCLUSTERED INDEX IX_pago_fecha_detalle_R6 
ON consorcio.pago (fecha)
INCLUDE (id_detalleDeCuenta)
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ecp_detalle_ordinarias_uf_R6' AND object_id = OBJECT_ID('consorcio.estadoCuentaProrrateo'))
CREATE NONCLUSTERED INDEX IX_ecp_detalle_ordinarias_uf_R6 
ON consorcio.estadoCuentaProrrateo (id_detalleDeCuenta)
INCLUDE (id_uf, expensas_ordinarias)
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_uf_consorcio_id_R6' AND object_id = OBJECT_ID('consorcio.unidadFuncional'))
CREATE NONCLUSTERED INDEX IX_uf_consorcio_id_R6 
ON consorcio.unidadFuncional (id_consorcio)
INCLUDE (id_uf, piso, depto) 
GO