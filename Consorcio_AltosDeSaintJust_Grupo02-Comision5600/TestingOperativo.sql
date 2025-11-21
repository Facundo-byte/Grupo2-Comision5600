/*
Comisión:         02-5600
Grupo:            G02
Integrantes:
    - DE LA FUENTE SILVA, CELESTE (45315259)
    - FERNANDEZ MARISCAL, AGUSTIN (45614233)
    - GAUTO, JUAN BAUTISTA (45239479)
*/
/*
ROL: OPERATIVO
ACCIONES: Actualización de datos UF, generación de reportes
*/

--------------------------------------------------------------------------------
-- USUARIOS ADMINISTRATIVO OPERATIVO  :
-- * lautaro 
-- * ayrton
-- * marco
use Com5600G02
go


PRINT '--- PRUEBAS: Administrativo operativo (user_lautaro) ---';
EXECUTE AS LOGIN = 'login_lautaro';
GO

-- PRUEBA DE ÉXITO: Actualización del coeficiente de la UF id = 1
-- Resultado Esperado: 1 fila afectada
BEGIN TRANSACTION;
UPDATE consorcio.unidadFuncional
SET coeficiente = 0.47 
WHERE id_uf = 1;
ROLLBACK TRANSACTION;
GO


-- PRUEBA DE ÉXITO: Ejecución de reporte_4
-- Resultado Esperado: Reporte generado con éxito
EXEC rep.sp_Reporte_4_Top5Movimientos
    @ConsorcioID= '2',
    @PeriodoInicio = '2025-01', -- Fecha de inicio del período a examinar
    @PeriodoFin = '2025-12';   -- Fecha de fin del período a examinar
GO


-- PRUEBA DE FALLO: Intentar INSERT en la tabla 'pago' (Tarea de Admin Bancario)
-- Resultado Esperado: ERROR (Msg 229: The INSERT permission was denied...)
INSERT INTO consorcio.pago ( fecha, cuenta_origen, importe, asociado)
VALUES ( GETDATE(), '3333333333333333333333', 500.00, 0);