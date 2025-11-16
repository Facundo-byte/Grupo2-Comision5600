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

-- EJECUCION REPORTE 1

DECLARE @ConsorcioID INT = 1;    
DECLARE @FechaInicio DATE = '2025-04-01'; 
DECLARE @FechaFin DATE = '2025-06-30'; 

EXEC SP_Reporte_1_FlujoCajaSemanal 
    @idConsorcio = @ConsorcioID, 
    @FechaInicio = @FechaInicio,
    @FechaFin = @FechaFin;
GO


-- EJECUCION REPORTE 2

DECLARE @ConsorcioID_Piso INT = 1; 
DECLARE @AnioReporte_Piso INT = 2025; 
DECLARE @FiltroPiso VARCHAR(3) = 'PB'; -- Ejemplo

EXEC SP_Reporte_2_Recaudacion 
    @idConsorcio = @ConsorcioID_Piso, 
    @Anio = @AnioReporte_Piso,
    @Piso = @FiltroPiso;
GO


-- EJECUCION REPORTE 3

DECLARE @ConsorcioID INT = 1;      
DECLARE @PeriodoInicio_R3 VARCHAR(7) = '2025-04'; 
DECLARE @PeriodoFin_R3 VARCHAR(7) = '2025-06'; 

EXEC SP_Reporte_3_RecaudacionTipoPeriodo 
    @idConsorcio = @ConsorcioID, 
    @PeriodoInicio = @PeriodoInicio_R3,
    @PeriodoFin = @PeriodoFin_R3;
GO


-- EJECUCION REPORTE 4

DECLARE @ConsorcioID_R4 INT = 2;      
DECLARE @PeriodoInicio_R4 VARCHAR(7) = '2025-01'; -- yyyy-mm
DECLARE @PeriodoFin_R4 VARCHAR(7) = '2025-12'; -- yyyy-mm

EXEC sp_Reporte_Top2Movimientos
    @ConsorcioID = @ConsorcioID_R4,
    @PeriodoInicio = @PeriodoInicio_R4,
    @PeriodoFin = @PeriodoFin_R4;
GO



-- EJECUCION REPORTE 5

-- Reporte General (Top 3 morosos en toda la administración)
EXEC SP_Reporte_5_Top3Morosos @idConsorcio = NULL;
GO

-- Reporte Filtrado por Consorcio 
DECLARE @ConsorcioID INT = 1; 

EXEC SP_Reporte_5_Top3Morosos @idConsorcio = @ConsorcioID;
GO



-- EJECUCION REPORTE 6

DECLARE @ConsorcioID INT = 1;     
DECLARE @FechaInicio DATE = '2025-04-01'; 
DECLARE @FechaFin DATE = '2025-06-30'; 

EXEC SP_Reporte_6_PeriodicidadPagosUF 
    @idConsorcio = @ConsorcioID, 
    @FechaDesde = @FechaInicio,
    @FechaHasta = @FechaFin;
GO

