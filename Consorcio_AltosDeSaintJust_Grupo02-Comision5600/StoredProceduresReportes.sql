-- REPORTE 4
CREATE OR ALTER PROCEDURE sp_Reporte_Top2Movimientos
    @ConsorcioID INT,            -- Parámetro 1: Filtro por Consorcio
    @PeriodoInicio VARCHAR(7),   -- Parámetro 2: Filtro de fecha de inicio (Ej. '2025-01')
    @PeriodoFin VARCHAR(7)       -- Parámetro 3: Filtro de fecha de fin (Ej. '2025-12')
AS
BEGIN
    SET NOCOUNT ON;

    -- El SP devuelve una única celda con la estructura XML que contiene ambos reportes
    SELECT 
        (
            -- 1. TOP 2 Mayores GASTOS en XML
            SELECT TOP 2 
                e.periodo AS Mes,
                SUM(g.subtotal_ordinarios + g.subtotal_extraordinarios) AS Total_Gasto
            FROM gasto g
            INNER JOIN expensa e ON g.id_expensa = e.id_expensa
            WHERE e.id_consorcio = @ConsorcioID
              AND e.periodo >= @PeriodoInicio 
              AND e.periodo <= @PeriodoFin
            GROUP BY e.periodo
            ORDER BY Total_Gasto DESC
            -- Cláusula XML para la salida
            FOR XML PATH('Gasto'), TYPE
        ) AS Egresos,

        (
            -- 2. TOP 2 Mayores INGRESOS en XML
            SELECT TOP 2
                CONCAT(YEAR(p.fecha), '-', FORMAT(p.fecha, 'MM')) AS Mes,
                SUM(p.importe) AS Total_Ingreso
            FROM pago p
            INNER JOIN unidadFuncional uf ON p.cuenta_origen = uf.cuenta_origen
            WHERE uf.id_consorcio = @ConsorcioID
              AND CONCAT(YEAR(p.fecha), '-', FORMAT(p.fecha, 'MM')) >= @PeriodoInicio 
              AND CONCAT(YEAR(p.fecha), '-', FORMAT(p.fecha, 'MM')) <= @PeriodoFin
            GROUP BY CONCAT(YEAR(p.fecha), '-', FORMAT(p.fecha, 'MM'))
            ORDER BY Total_Ingreso DESC
            -- Cláusula XML para la salida
            FOR XML PATH('Ingreso'), TYPE
        ) AS Ingresos
        
    -- NODO RAIZ: Envuelve ambos resultados en un documento XML
    FOR XML PATH('Reporte_Top_Movimientos'), ROOT('Datos_Consorcio')

END
GO
