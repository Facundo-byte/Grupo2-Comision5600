/*
Comisión:         02-5600
Grupo:            G02
Integrantes:
    - DE LA FUENTE SILVA, CELESTE (45315259)
    - FERNANDEZ MARISCAL, AGUSTIN (45614233)
    - GAUTO, JUAN BAUTISTA (45239479)
*/
/*
ROL: ADMIN BANCARIO
ACCIONES: Importación de información bancaria, generación de reportes
*/
--------------------------------------------------------------------------------
-- USUARIOS ADMINISTRATIVO BANCARIO :
-- * leandro
-- * ander
-- * milton

USE Com5600G02
GO
PRINT '--- PRUEBAS: Administrativo Bancario (user_leandro) ---';
EXECUTE AS LOGIN = 'login_leandro';
GO

-- PRUEBA DE ÉXITO: Importar pagos
-- Resultado Esperado: 1 fila afectada
BEGIN TRANSACTION
INSERT INTO consorcio.pago 
    (id_pago, fecha, cuenta_origen, importe, asociado, id_detalleDeCuenta)
VALUES 
    (
        999991,
        GETDATE(),
        '1234567890123456789012',
        15500.50,   
        0,                           
        NULL                                        
    );
ROLLBACK TRANSACTION;
GO


-- PRUEBA DE ÉXITO: Ejecución de reporte_2
-- Resultado Esperado: Reporte generado con éxito
EXEC rep.SP_Reporte_2_Recaudacion 
    @idConsorcio = 1,
    @Anio = 2025,
    @Piso = '2';
GO


-- PRUEBA DE FALLO: Intentar UPDATE en 'unidad_funcional' (Tarea de Admin General/Operativo)
-- Resultado Esperado: ERROR (Msg 229: The UPDATE permission was denied... y Msg 229: The SELECT permission was denied...)
UPDATE consorcio.unidadFuncional SET coeficiente = 0.10 WHERE id_uf = 1;
GO