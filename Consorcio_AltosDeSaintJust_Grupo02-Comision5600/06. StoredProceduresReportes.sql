/*
Comisión:         02-5600
Grupo:            G02
Integrantes:
    - DE LA FUENTE SILVA, CELESTE (45315259)
    - FERNANDEZ MARISCAL, AGUSTIN (45614233)
    - GAUTO, JUAN BAUTISTA (45239479)

Enunciado:        "Creación de Reportes y APIs"
*/

--------------------------------------------------------------------------------
use Com5600G02
GO
--------------------------------------------------------------------------------
-- configuración para interactuar con las APIs

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
EXEC sp_configure 'Ole Automation Procedures', 1;
RECONFIGURE;
GO
--------------------------------------------------------------------------------

-- REPORTE 1
-- flujo de caja en forma semanal

CREATE OR ALTER PROCEDURE rep.SP_Reporte_1_FlujoCajaSemanal
    @idConsorcio INT,
    @FechaInicio DATE,
    @FechaFin DATE
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Prorratear cada pago individual
        WITH PagosProrrateados AS (
            SELECT
                p.fecha,
                -- Lógica de Prorrateo para Pagos Ordinarios
                CASE 
                    -- Si el total a pagar es 0 o negativo, asignamos el pago completo a ordinario (esto es una suposición de manejo de error)
                    WHEN ISNULL(ec.total_pagar, 0) <= 0 THEN p.importe 
                    -- Calcula la parte del pago correspondiente a Ordinarias
                    ELSE p.importe * (ISNULL(ec.expensas_ordinarias, 0) / ec.total_pagar) 
                END AS PagoOrdinario,
                
                -- Lógica de Prorrateo para Pagos Extraordinarios
                CASE 
                    WHEN ISNULL(ec.total_pagar, 0) <= 0 THEN 0.00
                    -- Calcula la parte del pago correspondiente a Extraordinarias
                    ELSE p.importe * (ISNULL(ec.expensas_extraordinarias, 0) / ec.total_pagar) 
                END AS PagoExtraordinario
                
            FROM
                consorcio.pago p
            -- Unir a estadoCuentaProrrateo (ec)
            JOIN
                consorcio.estadoCuentaProrrateo ec ON p.id_detalleDeCuenta = ec.id_detalleDeCuenta
            -- Unir a expensa (e) para obtener el id_consorcio (el pago es de una UF, la UF pertenece a una expensa, la expensa tiene id_consorcio)
            JOIN
                consorcio.expensa e ON ec.id_expensa = e.id_expensa
            
            WHERE
                e.id_consorcio = @idConsorcio
                AND p.fecha BETWEEN @FechaInicio AND @FechaFin
                AND p.id_detalleDeCuenta IS NOT NULL 
        ),
        
        -- Agrupar por semana
        RecaudacionSemanal AS (
            SELECT
                DATEPART(year, pp.fecha) AS Anio,
                DATEPART(week, pp.fecha) AS Semana,
                -- Agregamos los importes prorrateados por semana
                SUM(pp.PagoOrdinario) AS RecaudadoOrdinario,
                SUM(pp.PagoExtraordinario) AS RecaudadoExtraordinario,
                SUM(pp.PagoOrdinario + pp.PagoExtraordinario) AS TotalSemanal
            FROM
                PagosProrrateados pp
            GROUP BY
                DATEPART(year, pp.fecha),
                DATEPART(week, pp.fecha)
        )

        -- Resultado final con Promedio y Acumulado Progresivo
        SELECT
            s.Anio,
            s.Semana,
            CAST(s.RecaudadoOrdinario AS DECIMAL(12, 2)) AS RecaudadoOrdinario,
            CAST(s.RecaudadoExtraordinario AS DECIMAL(12, 2)) AS RecaudadoExtraordinario,
            CAST(s.TotalSemanal AS DECIMAL(12, 2)) AS TotalSemanal,
            
            -- Promedio del total semanal sobre todo el periodo
            CAST(AVG(s.TotalSemanal) OVER () AS DECIMAL(12, 2)) AS PromedioPeriodo,
            
            -- Suma acumulada progresiva
            CAST(SUM(s.TotalSemanal) OVER (ORDER BY s.Anio, s.Semana ROWS UNBOUNDED PRECEDING) AS DECIMAL(12, 2)) AS AcumuladoProgresivo
        FROM
            RecaudacionSemanal s
        ORDER BY
            s.Anio, s.Semana;

    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE(), @ErrNo INT = ERROR_NUMBER();
        RAISERROR('Error al generar Reporte 1 (Flujo Semanal): (Err %d) %s', 16, 1, @ErrNo, @ErrMsg);
    END CATCH
END;
GO


-- REPORTE 2
--  total de recaudación por mes y departamento en formato de tabla cruzada. 

CREATE OR ALTER PROCEDURE rep.SP_Reporte_2_Recaudacion
    @idConsorcio INT,
    @Anio INT,
    @Piso VARCHAR(3) = NULL 
AS
BEGIN
    SET NOCOUNT ON;

    -- obtener la cotización del dolar con manejo de errores
    DECLARE @url NVARCHAR(256) = 'https://dolarapi.com/v1/dolares/oficial';
    DECLARE @Object INT;
    DECLARE @json TABLE(DATA NVARCHAR(MAX));
    DECLARE @respuesta NVARCHAR(MAX);
    DECLARE @venta DECIMAL(18, 2) = 0.00;

    BEGIN TRY
        -- Intentamos obtener la cotización
        EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
        EXEC sp_OAMethod @Object, 'OPEN', NULL, 'GET', @url, 'FALSE';
        EXEC sp_OAMethod @Object, 'SEND';
        EXEC sp_OAMethod @Object, 'RESPONSETEXT', @respuesta OUTPUT;
        
        INSERT INTO @json 
            EXEC sp_OAGetProperty @Object, 'RESPONSETEXT';
        
        IF @Object IS NOT NULL
            EXEC sp_OADestroy @Object;
        
        -- Parsear la respuesta JSON para obtener la venta
        SELECT @venta = [venta]
        FROM OPENJSON((SELECT DATA FROM @json))
        WITH
        (
            [venta] DECIMAL(18, 2) '$.venta'
        );
    END TRY
    BEGIN CATCH
        -- Si falla, usa un valor de 1.00 para la conversión
        SET @venta = 1.00; 
        DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE();
        PRINT 'Error al comunicarse con la API. Usando Tasa de Cambio 1.00: ' + @ErrorMessage;
    END CATCH
   -- calculo de pagos por mes y departamento
    ;WITH PagosPivot AS (
        SELECT
            CASE MONTH(p.fecha)
                WHEN 1 THEN 'enero' WHEN 2 THEN 'febrero' WHEN 3 THEN 'marzo'
                WHEN 4 THEN 'abril' WHEN 5 THEN 'mayo' WHEN 6 THEN 'junio'
                WHEN 7 THEN 'julio' WHEN 8 THEN 'agosto' WHEN 9 THEN 'septiembre'
                WHEN 10 THEN 'octubre' WHEN 11 THEN 'noviembre' WHEN 12 THEN 'diciembre'
            END AS Mes,
            MONTH(p.fecha) AS MesNumero,
            -- Se utiliza la columna uf.depto para el pivot
            ISNULL(SUM(CASE WHEN uf.depto = 'A' THEN p.importe END), 0.00) AS A,
            ISNULL(SUM(CASE WHEN uf.depto = 'B' THEN p.importe END), 0.00) AS B,
            ISNULL(SUM(CASE WHEN uf.depto = 'C' THEN p.importe END), 0.00) AS C,
            ISNULL(SUM(CASE WHEN uf.depto = 'D' THEN p.importe END), 0.00) AS D,
            ISNULL(SUM(CASE WHEN uf.depto = 'E' THEN p.importe END), 0.00) AS E
           
        FROM 
            consorcio.pago AS p
        -- Unión a estadoCuentaProrrateo usando id_detalleDeCuenta
        INNER JOIN consorcio.estadoCuentaProrrateo AS ec ON p.id_detalleDeCuenta = ec.id_detalleDeCuenta
        -- Unión a unidadFuncional para obtener el departamento y el consorcio
        INNER JOIN consorcio.unidadFuncional AS uf ON ec.id_uf = uf.id_uf
        WHERE
            uf.id_consorcio = @idConsorcio -- Filtro por consorcio
            AND YEAR(p.fecha) = @Anio      -- Filtro por año de pago
            -- Filtro por Piso 
            AND (@Piso IS NULL OR uf.piso = @Piso)
        GROUP BY MONTH(p.fecha)
    )
    
    -- FORMATO XML con estructura ARS/USD
    SELECT
        Mes AS [@nombre],
        @venta AS [TipoCambioVenta], 
        (
            SELECT
                Departamento.nombre AS [Departamento/@nombre],
                (
                    SELECT
                        Departamento.Monto_ARS AS [ARS],
                        -- Si la cotización es 0 o menos, la conversión es 0.00 para evitar errores.
                        CASE WHEN @venta > 0 THEN CAST(Departamento.Monto_ARS / @venta AS DECIMAL(18, 2)) ELSE 0.00 END AS [USD]
                    FOR XML PATH('Monto'), TYPE
                )
            FROM (
                -- El UNION ALL debe incluir todos los departamentos que se pivotearon.
                SELECT 'A' AS nombre, A AS Monto_ARS FROM PagosPivot WHERE PagosPivot.MesNumero = P.MesNumero
                UNION ALL SELECT 'B', B FROM PagosPivot WHERE PagosPivot.MesNumero = P.MesNumero
                UNION ALL SELECT 'C', C FROM PagosPivot WHERE PagosPivot.MesNumero = P.MesNumero
                UNION ALL SELECT 'D', D FROM PagosPivot WHERE PagosPivot.MesNumero = P.MesNumero
                UNION ALL SELECT 'E', E FROM PagosPivot WHERE PagosPivot.MesNumero = P.MesNumero
            ) AS Departamento
            FOR XML PATH(''), ROOT('Departamentos'), TYPE
        )
    FROM PagosPivot AS P
    ORDER BY MesNumero
    FOR XML PATH('Mes'), ROOT('ReporteRecaudacion');
END;
GO


-- REPORTE 3
-- cuadro cruzado con la recaudación total desagregada según su procedencia 
CREATE OR ALTER PROCEDURE rep.SP_Reporte_3_RecaudacionTipoPeriodo
    @idConsorcio INT,
    @PeriodoInicio VARCHAR(7), 
    @PeriodoFin VARCHAR(7)     
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar y generar la lista dinámica de columnas (Periodos)
    
    IF ISDATE(@PeriodoInicio + '-01') = 0 OR ISDATE(@PeriodoFin + '-01') = 0
    BEGIN
        RAISERROR('Períodos de inicio o fin inválidos. Use el formato AAAA-MM (Ej: 2025-03).', 16, 1);
        RETURN -10;
    END

    DECLARE @ColumnList NVARCHAR(MAX);
    
    WITH PeriodosDistintos AS (
        SELECT DISTINCT 
            QUOTENAME(e.periodo) AS ColumnaPeriodo,
            e.periodo AS PeriodoOrden
        FROM consorcio.expensa e
        WHERE e.id_consorcio = @idConsorcio
          AND e.periodo IS NOT NULL
          AND e.periodo BETWEEN @PeriodoInicio AND @PeriodoFin
    )
    SELECT @ColumnList = STRING_AGG(pd.ColumnaPeriodo, ',') WITHIN GROUP (ORDER BY pd.PeriodoOrden)
    FROM PeriodosDistintos pd;
    
    IF @ColumnList IS NULL
    BEGIN
        RAISERROR('No hay datos de expensas para el período seleccionado.', 16, 1);
        RETURN -11;
    END

    -- Crear la consulta SQL Dinámica
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = N'
    -- CTE para obtener los datos agregados por tipo de ingreso y periodo de expensa
    WITH BaseData AS (
        SELECT 
            e.periodo AS Periodo, -- Columna para el PIVOT
            T.TipoIngreso,
            -- Sumamos los conceptos para todas las unidades funcionales de esa expensa/periodo
            SUM(T.Importe) AS Importe
        FROM consorcio.estadoCuentaProrrateo ec
        JOIN consorcio.expensa e ON ec.id_expensa = e.id_expensa
        
        -- CROSS APPLY para des-pivotear y calcular el Total Recaudación
        CROSS APPLY (
            VALUES 
                (''1_Expensas Ordinarias'', ec.expensas_ordinarias),
                (''2_Expensas Extraordinarias'', ec.expensas_extraordinarias),
                -- NUEVA FILA: Suma de Ordinarias + Extraordinarias
                (''3_Total Recaudación'', ec.expensas_ordinarias + ec.expensas_extraordinarias)
        ) AS T(TipoIngreso, Importe)
        
        WHERE 
            e.id_consorcio = @idConsorcioParam
            AND e.periodo IS NOT NULL
            -- Filtramos por el rango de AAAA-MM
            AND e.periodo BETWEEN @PeriodoInicioParam AND @PeriodoFinParam
        GROUP BY 
            e.periodo, T.TipoIngreso
    )
    
    -- 3. Pivotar los datos: TipoIngreso vs Periodo
    SELECT 
        -- Modificamos la etiqueta para que no muestre el prefijo de ordenación
        CASE 
            WHEN TipoIngreso = ''1_Expensas Ordinarias'' THEN ''Expensas Ordinarias''
            WHEN TipoIngreso = ''2_Expensas Extraordinarias'' THEN ''Expensas Extraordinarias''
            WHEN TipoIngreso = ''3_Total Recaudación'' THEN ''TOTAL RECAUDACIÓN''
            ELSE TipoIngreso
        END AS TipoRecaudacion,
        ' + @ColumnList + '
    FROM BaseData
    PIVOT (
        SUM(Importe) 
        FOR Periodo IN (' + @ColumnList + ') 
    ) AS PivotTable
    ORDER BY TipoRecaudacion;
    ';

    -- Ejecutar la consulta dinámica
    EXEC sp_executesql @SQL,
        N'@idConsorcioParam INT, @PeriodoInicioParam VARCHAR(7), @PeriodoFinParam VARCHAR(7)',
        @idConsorcioParam = @idConsorcio,
        @PeriodoInicioParam = @PeriodoInicio,
        @PeriodoFinParam = @PeriodoFin;
END;
GO


-- REPORTE 4
-- meses de mayores gastos y mayores ingresos

CREATE OR ALTER PROCEDURE rep.sp_Reporte_4_Top5Movimientos
    @ConsorcioID INT,           
    @PeriodoInicio VARCHAR(7),  
    @PeriodoFin VARCHAR(7)      
AS
BEGIN
    SET NOCOUNT ON;

    -- El SP devuelve una única celda con la estructura XML que contiene ambos reportes
    SELECT 
        (
            -- TOP 5 Mayores GASTOS en XML
            SELECT TOP 5 
                e.periodo AS Mes,
                SUM(g.subtotal_ordinarios + g.subtotal_extraordinarios) AS Total_Gasto
            FROM consorcio.gasto g
            INNER JOIN consorcio.expensa e ON g.id_expensa = e.id_expensa
            WHERE e.id_consorcio = @ConsorcioID
              AND e.periodo >= @PeriodoInicio 
              AND e.periodo <= @PeriodoFin
            GROUP BY e.periodo
            ORDER BY Total_Gasto DESC
            -- Cláusula XML para la salida
            FOR XML PATH('Gasto'), TYPE
        ) AS Egresos,

        (
            -- TOP 5 Mayores INGRESOS en XML
            SELECT TOP 5
                CONCAT(YEAR(p.fecha), '-', FORMAT(p.fecha, 'MM')) AS Mes,
                SUM(p.importe) AS Total_Ingreso
            FROM consorcio.pago p
            INNER JOIN consorcio.unidadFuncional uf ON p.cuenta_origen = uf.cuenta_origen
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


-- REPORTE 5
-- propietarios con mayor morosidad

CREATE OR ALTER PROCEDURE rep.SP_Reporte_5_Top3Morosos
    @idConsorcio INT = NULL -- Consorcio opcional, por si se quiere filtrar el ranking
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 3
        p.nombre AS NombrePropietario,
        p.apellido AS ApellidoPropietario,
        p.dni AS DNI,
        p.email_personal AS EmailContacto,
        p.telefono_contacto AS TelefonoContacto,
        SUM(ec.deuda) AS Deuda_Total_Acumulada
    FROM
        consorcio.persona p
    -- Unir a personaUf usando DNI
    JOIN
        consorcio.personaUf puf ON p.dni = puf.dni_persona
    -- Unir a unidadFuncional (UF)
    JOIN
        consorcio.unidadFuncional uf ON puf.id_uf = uf.id_uf
    -- Unir a estadoCuentaProrrateo (EC) para obtener la deuda
    JOIN
        consorcio.estadoCuentaProrrateo ec ON uf.id_uf = ec.id_uf
    WHERE
        -- Filtro: Solo propietarios 
        puf.tipo_responsable = 'propietario' 
        -- Filtro: Solo deudas mayores a cero
        AND ec.deuda > 0
        -- Filtro opcional por Consorcio
        AND (@idConsorcio IS NULL OR uf.id_consorcio = @idConsorcio)
    GROUP BY
        p.id_persona, 
        p.nombre,
        p.apellido,
        p.dni,
        p.email_personal,
        p.telefono_contacto
    ORDER BY
        Deuda_Total_Acumulada DESC;
END
GO


-- REPORTE 6
-- fechas de pagos de expensas ordinarias de cada UF y la cantidad de días que 
--pasan entre un pago y el siguiente

CREATE OR ALTER PROCEDURE rep.SP_Reporte_6_PeriodicidadPagosUF
    @idConsorcio INT,
    @FechaDesde DATE = NULL,
    @FechaHasta DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

 
    -- Utiliza la función LAG para obtener la fecha de pago anterior dentro de cada UF
    WITH PagosOrdenados AS (
        SELECT
            c.nombre AS Consorcio,
            uf.piso,
            uf.depto AS Departamento,
            p.fecha AS FechaPago,
            
            -- Función LAG: Trae la fecha del pago anterior para la misma unidad funcional
            LAG(p.fecha, 1, NULL) OVER (PARTITION BY uf.id_uf ORDER BY p.fecha) AS FechaPagoAnterior
            
        FROM
            consorcio.pago AS p 
        -- Unir a estadoCuentaProrrateo (EC) para obtener la UF asociada al pago
        JOIN 
            consorcio.estadoCuentaProrrateo AS ec ON p.id_detalleDeCuenta = ec.id_detalleDeCuenta
        -- Unir a unidadFuncional (UF) para obtener los datos de la unidad y el consorcio
        JOIN 
            consorcio.unidadFuncional AS uf ON ec.id_uf = uf.id_uf
        -- Unir a consorcio (C) para obtener el nombre
        JOIN 
            consorcio.consorcio AS c ON uf.id_consorcio = c.id_consorcio
        
        WHERE
            -- Filtro obligatorio por Consorcio
            uf.id_consorcio = @idConsorcio
            -- Filtro clave: El pago debe haber cubierto expensas ordinarias (asumimos que si hay valor, es un pago asociado)
            AND ec.expensas_ordinarias > 0
            -- Filtros opcionales por rango de fecha de PAGO
            AND (@FechaDesde IS NULL OR p.fecha >= @FechaDesde)
            AND (@FechaHasta IS NULL OR p.fecha <= @FechaHasta)
    )
    
    -- Selección final con el cálculo de la diferencia
    SELECT
        Consorcio,
        piso,
        Departamento,
        FechaPagoAnterior,
        FechaPago AS FechaPagoSiguiente,
        
        -- Cálculo de la diferencia en días
        DATEDIFF(DAY, FechaPagoAnterior, FechaPago) AS DiasEntrePagos
    FROM
        PagosOrdenados
    -- Ordenar por UF (piso/depto) y luego cronológicamente
    ORDER BY
        piso, 
        Departamento, 
        FechaPagoSiguiente;

END;
GO