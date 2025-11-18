/*
Comisión:         02-5600
Grupo:            G02
Integrantes:
    - DE LA FUENTE SILVA, CELESTE (45315259)
    - FERNANDEZ MARISCAL, AGUSTIN (45614233)
    - GAUTO, JUAN BAUTISTA (45239479)

Enunciado:        "Creación procedimientos almacenados para el cifrado de datos sensibles"
*/

--------------------------------SP ENCRIPTACIÓN--------------------------------------
-- PROCEDIMIENTO: Modificacion de tablas para cifrado de datos sensibles
--------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE consorcio.sp_migrar_a_cifrado
    @FraseClave NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @ConstraintName NVARCHAR(128);
    DECLARE @IndexName NVARCHAR(128);
    
    BEGIN TRANSACTION
    
    BEGIN TRY

        -- Eliminación de índices existentes  UF
        SET @IndexName = N'IX_uf_consorcio_piso_depto';
        IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = @IndexName AND object_id = OBJECT_ID(N'consorcio.unidadFuncional'))
        BEGIN
            SET @SQL = N'DROP INDEX ' + QUOTENAME(@IndexName) + ' ON consorcio.unidadFuncional;';
            EXEC sp_executesql @SQL;
            PRINT 'INFO: Índice ' + @IndexName + ' eliminado de consorcio.unidadFuncional.';
        END
        
         SET @IndexName = N'IX_UF_ConsorcioCuenta';
        IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = @IndexName AND object_id = OBJECT_ID(N'consorcio.unidadFuncional'))
        BEGIN
            SET @SQL = N'DROP INDEX ' + QUOTENAME(@IndexName) + ' ON consorcio.unidadFuncional;';
            EXEC sp_executesql @SQL;
            PRINT 'INFO: Índice ' + @IndexName + ' eliminado de consorcio.unidadFuncional.';
        END
        
         SET @IndexName = N'IX_uf_id_consorcio';
        IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = @IndexName AND object_id = OBJECT_ID(N'consorcio.unidadFuncional'))
        BEGIN
            SET @SQL = N'DROP INDEX ' + QUOTENAME(@IndexName) + ' ON consorcio.unidadFuncional;';
            EXEC sp_executesql @SQL;
            PRINT 'INFO: Índice ' + @IndexName + ' eliminado de consorcio.unidadFuncional.';
        END
        
         SET @IndexName = N'IX_uf_consorcio_id_R6';
        IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = @IndexName AND object_id = OBJECT_ID(N'consorcio.unidadFuncional'))
        BEGIN
            SET @SQL = N'DROP INDEX ' + QUOTENAME(@IndexName) + ' ON consorcio.unidadFuncional;';
            EXEC sp_executesql @SQL;
            PRINT 'INFO: Índice ' + @IndexName + ' eliminado de consorcio.unidadFuncional.';
        END

        -- Eliminación de índices existentes  pago

        SET @IndexName = N'IX_pago_fecha_detalle_R1';
        IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = @IndexName AND object_id = OBJECT_ID(N'consorcio.pago'))
        BEGIN
            SET @SQL = N'DROP INDEX ' + QUOTENAME(@IndexName) + ' ON consorcio.pago;';
            EXEC sp_executesql @SQL;
            PRINT 'INFO: Índice ' + @IndexName + ' eliminado de consorcio.pago.';
        END

        SET @IndexName = N'IX_pago_fecha_detalle';
        IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = @IndexName AND object_id = OBJECT_ID(N'consorcio.pago'))
        BEGIN
            SET @SQL = N'DROP INDEX ' + QUOTENAME(@IndexName) + ' ON consorcio.pago;';
            EXEC sp_executesql @SQL;
            PRINT 'INFO: Índice ' + @IndexName + ' eliminado de consorcio.pago.';
        END
        
        SET @IndexName = N'IX_PAGO_CuentaOrigenFecha';
        IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = @IndexName AND object_id = OBJECT_ID(N'consorcio.pago'))
        BEGIN
            SET @SQL = N'DROP INDEX ' + QUOTENAME(@IndexName) + ' ON consorcio.pago;';
            EXEC sp_executesql @SQL;
            PRINT 'INFO: Índice ' + @IndexName + ' eliminado de consorcio.pago.';
        END

        SET @IndexName = N'IX_pago_fecha_detalle_R6';
        IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = @IndexName AND object_id = OBJECT_ID(N'consorcio.pago'))
        BEGIN
            SET @SQL = N'DROP INDEX ' + QUOTENAME(@IndexName) + ' ON consorcio.pago;';
            EXEC sp_executesql @SQL;
            PRINT 'INFO: Índice ' + @IndexName + ' eliminado de consorcio.pago.';
        END
        
       
        -- Creación de columnas temporales para el cifrado
        IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'dni_temp' AND Object_ID = OBJECT_ID(N'consorcio.persona'))
            ALTER TABLE consorcio.persona ADD dni_temp VARBINARY(256) NULL;
        IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'email_temp' AND Object_ID = OBJECT_ID(N'consorcio.persona'))
            ALTER TABLE consorcio.persona ADD email_temp VARBINARY(256) NULL;
        IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'telefono_temp' AND Object_ID = OBJECT_ID(N'consorcio.persona'))
            ALTER TABLE consorcio.persona ADD telefono_temp VARBINARY(256) NULL;
        IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'cuentaOrigen_temp' AND Object_ID = OBJECT_ID(N'consorcio.persona'))
            ALTER TABLE consorcio.persona ADD cuentaOrigen_temp VARBINARY(256) NULL;

        SET @SQL = N'
        UPDATE T
        SET 
            dni_temp = ENCRYPTBYPASSPHRASE(@FraseClaveParam, CAST(dni AS VARCHAR(50)), 1, CONVERT(VARBINARY(4), id_persona)),
            email_temp = ENCRYPTBYPASSPHRASE(@FraseClaveParam, CAST(email_personal AS VARCHAR(100)), 1, CONVERT(VARBINARY(4), id_persona)),
            telefono_temp = ENCRYPTBYPASSPHRASE(@FraseClaveParam, CAST(telefono_contacto AS VARCHAR(20)), 1, CONVERT(VARBINARY(4), id_persona)),
            cuentaOrigen_temp = ENCRYPTBYPASSPHRASE(@FraseClaveParam, CAST(cuenta AS CHAR(22)), 1, CONVERT(VARBINARY(4), id_persona))
        FROM consorcio.persona T
        WHERE 
            dni IS NOT NULL OR 
            email_personal IS NOT NULL OR 
            telefono_contacto IS NOT NULL OR 
            cuenta IS NOT NULL;
        ';
        EXEC sp_executesql @SQL, N'@FraseClaveParam NVARCHAR(128)', @FraseClaveParam = @FraseClave;
        
        --  ELIMINAR LA CLAVE FORÁNEA (FK) DEPENDIENTE 
        SET @SQL = N'ALTER TABLE consorcio.personaUf DROP CONSTRAINT fk_personaUf_dni;';
        EXEC sp_executesql @SQL;
        PRINT 'INFO: Clave Foránea dependiente fk_personaUf_dni eliminada de personaUf.';
        -- Eliminación de restricciones de unicidad/PK en 'dni'
        SELECT @ConstraintName = NULL; 
        
        SELECT TOP 1 @ConstraintName = kc.name 
        FROM sys.key_constraints kc
        INNER JOIN sys.index_columns ic ON kc.parent_object_id = ic.object_id AND kc.unique_index_id = ic.index_id
        INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
        WHERE kc.parent_object_id = OBJECT_ID('consorcio.persona') 
          AND kc.type IN ('UQ', 'PK') 
          AND c.name = 'dni';
        
        IF @ConstraintName IS NOT NULL
        BEGIN
            SET @SQL = N'ALTER TABLE consorcio.persona DROP CONSTRAINT ' + QUOTENAME(@ConstraintName);
            EXEC sp_executesql @SQL;
            PRINT 'INFO: Restricción dependiente (' + @ConstraintName + ') en consorcio.persona.dni eliminada.';
        END
        
        -- Eliminar columnas originales
        ALTER TABLE consorcio.persona DROP COLUMN dni;
        ALTER TABLE consorcio.persona DROP COLUMN email_personal;
        ALTER TABLE consorcio.persona DROP COLUMN telefono_contacto;
        ALTER TABLE consorcio.persona DROP COLUMN cuenta;

        -- Renombrar columnas temporales a sus nombres originales
        EXEC sp_rename 'consorcio.persona.dni_temp', 'dni', 'COLUMN';
        EXEC sp_rename 'consorcio.persona.email_temp', 'email_personal', 'COLUMN';
        EXEC sp_rename 'consorcio.persona.telefono_temp', 'telefono_contacto', 'COLUMN';
        EXEC sp_rename 'consorcio.persona.cuentaOrigen_temp', 'cuenta', 'COLUMN';

        ALTER TABLE consorcio.persona ALTER COLUMN dni VARBINARY(256) NOT NULL;
        ALTER TABLE consorcio.persona ALTER COLUMN cuenta VARBINARY(256) NOT NULL;

        -------------------------------------------------------------
        -- MIGRACIÓN DE cuentaOrigen en otras tablas (unidad_funcional y pago)
        -------------------------------------------------------------
        
        DECLARE @TableName NVARCHAR(128);
        DECLARE @IdColumnName NVARCHAR(128);

        -- Tabla: unidad_funcional
        SET @TableName = N'consorcio.unidadFuncional';
        SET @IdColumnName = N'id_uf';

        IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'cuentaOrigen_temp' AND Object_ID = OBJECT_ID(@TableName))
            SET @SQL = N'ALTER TABLE ' + @TableName + ' ADD cuentaOrigen_temp VARBINARY(256) NULL;';
        ELSE
            SET @SQL = N'UPDATE ' + @TableName + ' SET cuentaOrigen_temp = NULL;';
        EXEC sp_executesql @SQL;

        SET @SQL = N'
        UPDATE T
        SET cuentaOrigen_temp = ENCRYPTBYPASSPHRASE(@FraseClaveParam, CAST(cuenta_origen AS CHAR(22)), 1, CONVERT(VARBINARY(4), ' + @IdColumnName + '))
        FROM ' + @TableName + ' T
        WHERE cuenta_origen IS NOT NULL;
        ';
        EXEC sp_executesql @SQL, N'@FraseClaveParam NVARCHAR(128)', @FraseClaveParam = @FraseClave;
        
        SET @SQL = N'ALTER TABLE ' + @TableName + ' DROP COLUMN cuenta_origen;';
        EXEC sp_executesql @SQL;
        
        SET @SQL = N'EXEC sp_rename ''' + @TableName + '.cuentaOrigen_temp'', ''cuenta_origen'', ''COLUMN'';';
        EXEC sp_executesql @SQL;
        
        SET @SQL = N'ALTER TABLE ' + @TableName + ' ALTER COLUMN cuenta_origen VARBINARY(256) NOT NULL;';
        EXEC sp_executesql @SQL;
        PRINT 'INFO: Migrada columna cuenta_origen en ' + @TableName + '.';
        
        -- Tabla: pago
        SET @TableName = N'consorcio.pago';
        SET @IdColumnName = N'id_pago'; 

        

        IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'cuentaOrigen_temp' AND Object_ID = OBJECT_ID(@TableName))
            SET @SQL = N'ALTER TABLE ' + @TableName + ' ADD cuentaOrigen_temp VARBINARY(256) NULL;';
        ELSE
            SET @SQL = N'UPDATE ' + @TableName + ' SET cuentaOrigen_temp = NULL;';
        EXEC sp_executesql @SQL;
        
        SET @SQL = N'
        UPDATE T
        SET cuentaOrigen_temp = ENCRYPTBYPASSPHRASE(@FraseClaveParam, CAST(cuenta_origen AS CHAR(22)), 1, CONVERT(VARBINARY(4), ' + @IdColumnName + '))
        FROM ' + @TableName + ' T
        WHERE cuenta_origen IS NOT NULL;
        ';
        EXEC sp_executesql @SQL, N'@FraseClaveParam NVARCHAR(128)', @FraseClaveParam = @FraseClave;

        -- Dropear la restricción CHECK que depende de cuenta_origen
        SET @ConstraintName = N'chk_pago_cuentaOrigen'; 
        IF EXISTS (SELECT 1 FROM sys.objects WHERE name = @ConstraintName AND parent_object_id = OBJECT_ID(@TableName))
        BEGIN
            SET @SQL = N'ALTER TABLE ' + @TableName + ' DROP CONSTRAINT ' + QUOTENAME(@ConstraintName) + ';';
            EXEC sp_executesql @SQL;
            PRINT 'INFO: Restricción de dependencia ' + @ConstraintName + ' eliminada de consorcio.pago.';
        END

        SET @SQL = N'ALTER TABLE ' + @TableName + ' DROP COLUMN cuenta_origen;';
        EXEC sp_executesql @SQL;

        SET @SQL = N'EXEC sp_rename ''' + @TableName + '.cuentaOrigen_temp'', ''cuenta_origen'', ''COLUMN'';';
        EXEC sp_executesql @SQL;

        SET @SQL = N'ALTER TABLE ' + @TableName + ' ALTER COLUMN cuenta_origen VARBINARY(256) NOT NULL;';
        EXEC sp_executesql @SQL;
        PRINT 'INFO: Migrada columna cuenta_origen en ' + @TableName + '.';

        COMMIT TRANSACTION;
        PRINT 'Migración de esquema a cifrado reversible COMPLETADA con éxito.';

    END TRY
    BEGIN CATCH
        -- Manejo de Errores
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        -- Lanzar el error para que la aplicación lo detecte
        THROW; 

    END CATCH
END
GO

--------------------------------------------------------------------------------
-- NUMERO: 13
-- ARCHIVO: -
-- PROCEDIMIENTO: Modificacion de tablas para descifrado de datos sensibles
--------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE consorcio.sp_revertir_cifrado
    @FraseClave NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @SQL NVARCHAR(MAX);
    
    BEGIN TRANSACTION
    
    BEGIN TRY

        -------------------------------------------------------------
        -- REVERSIÓN TABLA consorcio.persona
        -------------------------------------------------------------
        
        -- Eliminación de la columna HASH de unicidad (si fue creada en la migración)
        IF EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'dni_hash_unicidad' AND Object_ID = OBJECT_ID(N'consorcio.persona'))
            ALTER TABLE consorcio.persona DROP COLUMN dni_hash_unicidad;
            
        -- Creación de columnas temporales para el descifrado
        SET @SQL = N'
            ALTER TABLE consorcio.persona DROP COLUMN IF EXISTS dni_temp_revert;
            ALTER TABLE consorcio.persona DROP COLUMN IF EXISTS email_temp_revert;
            ALTER TABLE consorcio.persona DROP COLUMN IF EXISTS telefono_temp_revert;
            ALTER TABLE consorcio.persona DROP COLUMN IF EXISTS cuentaOrigen_temp_revert;
            
            -- Se usan los tipos de dato originales
            ALTER TABLE consorcio.persona ADD dni_temp_revert VARCHAR(50) NULL; 
            ALTER TABLE consorcio.persona ADD email_temp_revert VARCHAR(100) NULL;
            ALTER TABLE consorcio.persona ADD telefono_temp_revert VARCHAR(20) NULL;
            ALTER TABLE consorcio.persona ADD cuentaOrigen_temp_revert CHAR(22) NULL;
        ';
        EXEC sp_executesql @SQL;

        -- Descifrado de datos a las columnas temporales
        SET @SQL = N'
        UPDATE T
        SET 
            dni_temp_revert = CAST(DECRYPTBYPASSPHRASE(@FraseClaveParam, dni, 1, CONVERT(VARBINARY(4), id_persona)) AS VARCHAR(50)),
            email_temp_revert = CAST(DECRYPTBYPASSPHRASE(@FraseClaveParam, email_personal, 1, CONVERT(VARBINARY(4), id_persona)) AS VARCHAR(100)),
            telefono_temp_revert = CAST(DECRYPTBYPASSPHRASE(@FraseClaveParam, telefono_contacto, 1, CONVERT(VARBINARY(4), id_persona)) AS VARCHAR(20)),
            cuentaOrigen_temp_revert = CAST(DECRYPTBYPASSPHRASE(@FraseClaveParam, cuenta, 1, CONVERT(VARBINARY(4), id_persona)) AS CHAR(22))
        FROM consorcio.persona T;
        ';
        EXEC sp_executesql @SQL, N'@FraseClaveParam NVARCHAR(128)', @FraseClaveParam = @FraseClave;
        
        -- Eliminación de las columnas cifradas (VARBINARY)
        ALTER TABLE consorcio.persona DROP COLUMN dni;
        ALTER TABLE consorcio.persona DROP COLUMN email_personal;
        ALTER TABLE consorcio.persona DROP COLUMN telefono_contacto;
        ALTER TABLE consorcio.persona DROP COLUMN cuenta;

        -- Renombrar columnas temporales a sus nombres originales
        EXEC sp_rename 'consorcio.persona.dni_temp_revert', 'dni', 'COLUMN';
        EXEC sp_rename 'consorcio.persona.email_temp_revert', 'email_personal', 'COLUMN';
        EXEC sp_rename 'consorcio.persona.telefono_temp_revert', 'telefono_contacto', 'COLUMN';
        EXEC sp_rename 'consorcio.persona.cuentaOrigen_temp_revert', 'cuenta', 'COLUMN';

        -- Restaurar tipos de datos, nulabilidad y restricciones
        ALTER TABLE consorcio.persona ALTER COLUMN dni VARCHAR(50) NOT NULL; 
        ALTER TABLE consorcio.persona ALTER COLUMN email_personal VARCHAR(100) NULL;
        ALTER TABLE consorcio.persona ALTER COLUMN telefono_contacto VARCHAR(20) NULL;
        ALTER TABLE consorcio.persona ALTER COLUMN cuenta CHAR(22) NOT NULL; 
        
        -- Restaurar restricciones
        ALTER TABLE consorcio.persona ADD CONSTRAINT uq_persona_dni UNIQUE (dni);
        ALTER TABLE consorcio.persona ADD CONSTRAINT chk_persona_cuenta CHECK (ISNUMERIC(cuenta) = 1);
        
        -------------------------------------------------------------
        -- REVERSIÓN TABLA consorcio.unidadFuncional 
        -------------------------------------------------------------
        
        -- Creación garantizada con SQL Dinámico
        SET @SQL = N'
            ALTER TABLE consorcio.unidadFuncional DROP COLUMN IF EXISTS cuentaOrigen_temp_revert;
            ALTER TABLE consorcio.unidadFuncional ADD cuentaOrigen_temp_revert CHAR(22) NULL;
        ';
        EXEC sp_executesql @SQL;
            
        SET @SQL = N'
        UPDATE T
        SET cuentaOrigen_temp_revert = CAST(DECRYPTBYPASSPHRASE(@FraseClaveParam, cuenta_origen, 1, CONVERT(VARBINARY(4), id_uf)) AS CHAR(22))
        FROM consorcio.unidadFuncional T;
        ';
        EXEC sp_executesql @SQL, N'@FraseClaveParam NVARCHAR(128)', @FraseClaveParam = @FraseClave;

        ALTER TABLE consorcio.unidadFuncional DROP COLUMN cuenta_origen;
        EXEC sp_rename 'consorcio.unidadFuncional.cuentaOrigen_temp_revert', 'cuenta_origen', 'COLUMN';
        ALTER TABLE consorcio.unidadFuncional ALTER COLUMN cuenta_origen CHAR(22) NOT NULL;
        ALTER TABLE consorcio.unidadFuncional ADD CONSTRAINT chk_unidadFuncional_cuentaOrigen CHECK (ISNUMERIC(cuenta_origen) = 1);

        -------------------------------------------------------------
        -- REVERSIÓN TABLA consorcio.pago
        -------------------------------------------------------------
        
        -- Creación garantizada con SQL Dinámico
        SET @SQL = N'
            ALTER TABLE consorcio.pago DROP COLUMN IF EXISTS cuentaOrigen_temp_revert;
            ALTER TABLE consorcio.pago ADD cuentaOrigen_temp_revert CHAR(22) NULL;
        ';
        EXEC sp_executesql @SQL;
            
        SET @SQL = N'
        UPDATE T
        SET cuentaOrigen_temp_revert = CAST(DECRYPTBYPASSPHRASE(@FraseClaveParam, cuenta_origen, 1, CONVERT(VARBINARY(4), id_pago)) AS CHAR(22))
        FROM consorcio.pago T;
        ';
        EXEC sp_executesql @SQL, N'@FraseClaveParam NVARCHAR(128)', @FraseClaveParam = @FraseClave;

        ALTER TABLE consorcio.pago DROP COLUMN cuenta_origen;
        EXEC sp_rename 'consorcio.pago.cuentaOrigen_temp_revert', 'cuenta_origen', 'COLUMN';
        ALTER TABLE consorcio.pago ALTER COLUMN cuenta_origen CHAR(22) NOT NULL;
        ALTER TABLE consorcio.pago ADD CONSTRAINT chk_pago_cuentaOrigen CHECK (ISNUMERIC(cuenta_origen) = 1);

        -------------------------------------------------------------
        -- REGENERACIÓN DE ÍNDICES 
        -------------------------------------------------------------

        PRINT 'INFO: Regenerando índices';
       

        -- Índice en consorcio.unidad_funcional
        IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_uf_consorcio_piso_depto' AND object_id = OBJECT_ID('consorcio.unidadFuncional'))
        CREATE NONCLUSTERED INDEX IX_uf_consorcio_piso_depto 
        ON consorcio.unidadFuncional (id_consorcio, piso)
        INCLUDE (id_uf, depto)

        IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_UF_ConsorcioCuenta' AND object_id = OBJECT_ID('consorcio.unidadFuncional'))
        BEGIN
            CREATE NONCLUSTERED INDEX IX_UF_ConsorcioCuenta
            ON consorcio.unidadFuncional (id_consorcio, cuenta_origen);
        END

        IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_uf_id_consorcio' AND object_id = OBJECT_ID('consorcio.unidadFuncional'))
        CREATE NONCLUSTERED INDEX IX_uf_id_consorcio
        ON consorcio.unidadFuncional (id_consorcio)
        INCLUDE (id_uf)


        IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_uf_consorcio_id_R6' AND object_id = OBJECT_ID('consorcio.unidadFuncional'))
        CREATE NONCLUSTERED INDEX IX_uf_consorcio_id_R6 
        ON consorcio.unidadFuncional (id_consorcio)
        INCLUDE (id_uf, piso, depto) 
        

        -- Índice en consorcio.pago 
        IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_pago_fecha_detalle_R1' AND object_id = OBJECT_ID('consorcio.pago'))
        CREATE NONCLUSTERED INDEX IX_pago_fecha_detalle_R1 
        ON consorcio.pago (fecha, id_detalleDeCuenta)
        INCLUDE (importe)


        IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_pago_fecha_detalle' AND object_id = OBJECT_ID('consorcio.pago'))
        CREATE NONCLUSTERED INDEX IX_pago_fecha_detalle 
        ON consorcio.pago (fecha, id_detalleDeCuenta)
        INCLUDE (importe)


        IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PAGO_CuentaOrigenFecha' AND object_id = OBJECT_ID('consorcio.pago'))
        BEGIN
            CREATE NONCLUSTERED INDEX IX_PAGO_CuentaOrigenFecha
            ON consorcio.pago (cuenta_origen, fecha)
            INCLUDE (importe); 
        END


        IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_pago_fecha_detalle_R6' AND object_id = OBJECT_ID('consorcio.pago'))
        CREATE NONCLUSTERED INDEX IX_pago_fecha_detalle_R6 
        ON consorcio.pago (fecha)
        INCLUDE (id_detalleDeCuenta)

        COMMIT TRANSACTION;
        PRINT 'Reversión de esquema a datos en claro y regeneración de índices COMPLETADA con éxito.';

    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW; 

    END CATCH
END
GO