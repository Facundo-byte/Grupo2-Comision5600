-- INDICES REPORTES
-- ÍNDICES PARA OPTIMIZAR EL REPORTE 4
-- 1. Índice para la tabla EXPENSA (Filtro y Ordenamiento de Gastos)
-- Objetivo: Optimizar el filtro por Consorcio y el rango de Período (para el cálculo de Gasto).
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_EXPENSA_ConsorcioPeriodo' AND object_id = OBJECT_ID('expensa'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_EXPENSA_ConsorcioPeriodo
    ON expensa (id_consorcio, periodo);
END
GO

-- 2. Índice para la tabla GASTO (Unión y Filtrado de Gasto)
-- Objetivo: Optimizar la unión con EXPENSA.
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_GASTO_IdExpensa' AND object_id = OBJECT_ID('gasto'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_GASTO_IdExpensa
    ON gasto (id_expensa)
    INCLUDE (subtotal_ordinarios, subtotal_extraordinarios); -- Incluye columnas usadas en la suma
END
GO

-- 3. Índice para la tabla UNIDADFUNCIONAL (Unión y Filtrado de Ingresos)
-- Objetivo: Optimizar el filtro por Consorcio y la unión con PAGO mediante cuenta_origen.
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_UF_ConsorcioCuenta' AND object_id = OBJECT_ID('unidadFuncional'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_UF_ConsorcioCuenta
    ON unidadFuncional (id_consorcio, cuenta_origen);
END
GO

-- 4. Índice para la tabla PAGO (Filtro y Ordenamiento de Ingresos)
-- Objetivo: Optimizar la unión con UF y el agrupamiento/ordenamiento por Fecha/Período.
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PAGO_CuentaOrigenFecha' AND object_id = OBJECT_ID('pago'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_PAGO_CuentaOrigenFecha
    ON pago (cuenta_origen, fecha)
    INCLUDE (importe); -- Incluye el importe, usado en la suma
END
GO
