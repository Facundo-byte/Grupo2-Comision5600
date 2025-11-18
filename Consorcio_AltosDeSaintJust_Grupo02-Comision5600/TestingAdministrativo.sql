/*
Comisión:         02-5600
Grupo:            G02
Integrantes:
    - DE LA FUENTE SILVA, CELESTE (45315259)
    - FERNANDEZ MARISCAL, AGUSTIN (45614233)
    - GAUTO, JUAN BAUTISTA (45239479)
*/
/*
ROL: ADMIN GENERAL
ACCIONES: Actualizacion de datos UF, generación de reportes
*/
--------------------------------------------------------------------------------
-- USUARIOS ADMINISTRATIVO GENERAL :
-- * exequiel 
-- * miguel
-- * edinson

PRINT '--- PRUEBAS: Administrativo general (user_exequiel) ---';
EXECUTE AS LOGIN = 'login_exequiel';
GO

-- PRUEBA DE ÉXITO: Actualización de Unidad Funcional (Tarea propia del rol)
-- Resultado Esperado: Una fila afectada (el cambio se revierte).
BEGIN TRANSACTION;
    UPDATE consorcio.unidadFuncional SET coeficiente = 0.50 WHERE id_uf = 1;
ROLLBACK TRANSACTION;


-- PRUEBA DE ÉXITO: Ejecución de reportes
-- Resultado Esperado: reporte_1 generado con éxito
EXEC rep.SP_Reporte_1_FlujoCajaSemanal 
    @idConsorcio = 1,
    @FechaInicio = '2025-05-01',
    @FechaFin = '2025-05-31';
GO


-- PRUEBA DE FALLO: Intentar leer la tabla persona
-- Resultado Esperado: ERROR (Msg 229: The SELECT permission was denied...)
SELECT * FROM consorcio.persona;
GO
