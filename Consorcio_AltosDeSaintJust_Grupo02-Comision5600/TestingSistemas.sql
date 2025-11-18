/*
Comisión:         02-5600
Grupo:            G02
Integrantes:
    - DE LA FUENTE SILVA, CELESTE (45315259)
    - FERNANDEZ MARISCAL, AGUSTIN (45614233)
    - GAUTO, JUAN BAUTISTA (45239479)
*/

/*
ROL: SISTEMAS
ACCIONES: generación de reportes
*/


-- USUARIOS SISTEMAS :
-- * roman
-- * ruso

PRINT '--- PRUEBAS: Sistemas (user_roman_sys) ---';
EXECUTE AS LOGIN = 'login_roman_sys';

-- PRUEBA DE ÉXITO: Ejecución de reporte_5
-- Resultado Esperado: Reporte generado con éxito
EXEC rep.SP_Reporte_5_Top3Morosos @idConsorcio = NULL;
GO

-- PRUEBA DE FALLO: Intentar leer la tabla gasto
-- Resultado Esperado: ERROR (Msg 229: The SELECT permission was denied...)
SELECT * FROM consorcio.gasto;