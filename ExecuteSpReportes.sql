-- EJECUCION REPORTE 4

DECLARE @ConsorcioID_R4 INT = 2;         -- Reemplazar por cualquier ID de Consorcio real
DECLARE @PeriodoInicio_R4 VARCHAR(7) = '2025-01'; -- yyyy-mm
DECLARE @PeriodoFin_R4 VARCHAR(7) = '2025-12'; -- yyyy-mm

EXEC sp_Reporte_Top2Movimientos
    @ConsorcioID = @ConsorcioID_R4,
    @PeriodoInicio = @PeriodoInicio_R4,
    @PeriodoFin = @PeriodoFin_R4;
GO

