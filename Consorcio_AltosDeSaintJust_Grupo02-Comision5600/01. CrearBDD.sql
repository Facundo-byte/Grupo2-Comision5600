/*
Comisión:         02-5600
Grupo:            G02
Integrantes:
    - DE LA FUENTE SILVA, CELESTE (45315259)
    - FERNANDEZ MARISCAL, AGUSTIN (45614233)
    - GAUTO, JUAN BAUTISTA (45239479)

Enunciado:        "Creación de Base de Datos"
*/
--------------------------------------------------------------------------------

IF DB_ID('Com5600G02') IS NOT NULL
BEGIN
    -- asegurar que nadie esté usando la DB antes de eliminarla
    ALTER DATABASE Com5600G02 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    
    DROP DATABASE Com5600G02;
    
    PRINT 'Base de datosCom5600G02 eliminada con éxito.';
END
ELSE
BEGIN
    PRINT 'INFO: La base de datos Com5600G02 no existe. No se requiere acción.';
END
GO

create database Com5600G02
go 
use Com5600G02
go



