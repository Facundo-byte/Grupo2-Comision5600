/*
Comisión:         02-5600
Grupo:            G02
Integrantes:
    - DE LA FUENTE SILVA, CELESTE (45315259)
    - FERNANDEZ MARISCAL, AGUSTIN (45614233)
    - GAUTO, JUAN BAUTISTA (45239479)

Enunciado:        "Creación de roles, users y logins"
*/

--------------------------------------------------------------------------------
USE Com5600G02
GO

-- =======================================================
-- ELIMINACIÓN DE USUARIOS DE LA BASE DE DATOS
-- =======================================================

-- Administrativo general
DROP USER IF EXISTS user_exequiel;
DROP USER IF EXISTS user_miguel;
DROP USER IF EXISTS user_edinson;
GO

-- Administrativo Bancario
DROP USER IF EXISTS user_leandro;
DROP USER IF EXISTS user_ander;
DROP USER IF EXISTS user_milton;
GO

-- Administrativo Operativo
DROP USER IF EXISTS user_lautaro;
DROP USER IF EXISTS user_ayrton;
DROP USER IF EXISTS user_marco;
GO

-- Sistemas
DROP USER IF EXISTS user_roman_sys;
DROP USER IF EXISTS user_ruso_sys;
GO

-- ELIMINACIÓN DE ROLES DE LA BASE DE DATOS
DROP ROLE IF EXISTS [Administrativo general];
DROP ROLE IF EXISTS [Administrativo Bancario];
DROP ROLE IF EXISTS [Administrativo operativo];
DROP ROLE IF EXISTS [Sistemas];
GO


-- ELIMINACIÓN DE LOGINS

-- Administrativo general
DROP LOGIN login_exequiel;
DROP LOGIN login_miguel;
DROP LOGIN login_edinson;
GO

-- Administrativo Bancario
DROP LOGIN login_leandro;
DROP LOGIN login_ander;
DROP LOGIN login_milton;
GO

-- Administrativo Operativo
DROP LOGIN login_lautaro;
DROP LOGIN login_ayrton;
DROP LOGIN login_marco;
GO

-- Sistemas
DROP LOGIN login_roman_sys;
DROP LOGIN login_ruso_sys;
GO

----------------------------------------------------
--  CREACIÓN DE ROLES DE BASE DE DATOS
----------------------------------------------------
CREATE ROLE [Administrativo general];
CREATE ROLE [Administrativo Bancario];
CREATE ROLE [Administrativo operativo];
CREATE ROLE [Sistemas];
GO

-- Actualización de datos de UF para Admin General y Admin Operativo --
GRANT UPDATE ON consorcio.unidadFuncional TO [Administrativo general],[Administrativo operativo];
GRANT SELECT ON consorcio.unidadFuncional TO [Administrativo general],[Administrativo operativo];
GO

-- Importación de información bancaria para Admin Bancario --
GRANT INSERT ON consorcio.pago TO [Administrativo Bancario]; -- Importación de información bancaria
GRANT SELECT ON consorcio.expensa TO [Administrativo Bancario];
GRANT SELECT ON consorcio.estadoCuentaProrrateo TO [Administrativo Bancario];
GO

-- Generación de reportes para todos los roles --
GRANT EXECUTE ON SCHEMA :: rep TO [Administrativo general], [Administrativo Bancario], [Administrativo operativo], [Sistemas];
GO


--- Creación usuarios Administrativo General ---
-- EXEQUIEL
CREATE LOGIN login_exequiel WITH
    PASSWORD = '$P9kR!t7',
    CHECK_POLICY = ON;
CREATE USER user_exequiel FOR LOGIN login_exequiel WITH DEFAULT_SCHEMA = consorcio;
ALTER ROLE [Administrativo general] ADD MEMBER user_exequiel;
GO

-- MIGUEL
CREATE LOGIN login_miguel WITH
    PASSWORD = 'a4%Jc3H$',
    CHECK_POLICY = ON;
CREATE USER user_miguel FOR LOGIN login_miguel WITH DEFAULT_SCHEMA = consorcio;
ALTER ROLE [Administrativo general] ADD MEMBER user_miguel;
GO

-- EDINSON
CREATE LOGIN login_edinson WITH
    PASSWORD = '!7Fp@zK1',
    CHECK_POLICY = ON;
CREATE USER user_edinson FOR LOGIN login_edinson WITH DEFAULT_SCHEMA = consorcio;
ALTER ROLE [Administrativo general] ADD MEMBER user_edinson;
GO

--- Creación usuarios Administrativo Bancario ---
-- LEANDRO
CREATE LOGIN login_leandro WITH
    PASSWORD = 'B8v$Xw2E',
    CHECK_POLICY = ON;
CREATE USER user_leandro FOR LOGIN login_leandro WITH DEFAULT_SCHEMA = consorcio;
ALTER ROLE [Administrativo Bancario] ADD MEMBER user_leandro;
GO

-- ANDER
CREATE LOGIN login_ander WITH
    PASSWORD = 'm6&ZtY*3',
    CHECK_POLICY = ON;
CREATE USER user_ander FOR LOGIN login_ander WITH DEFAULT_SCHEMA = consorcio;
ALTER ROLE [Administrativo Bancario] ADD MEMBER user_ander;
GO

-- MILTON
CREATE LOGIN login_milton WITH
    PASSWORD = '@rL2h9J!',
    CHECK_POLICY = ON;
CREATE USER user_milton FOR LOGIN login_milton WITH DEFAULT_SCHEMA = consorcio;
ALTER ROLE [Administrativo Bancario] ADD MEMBER user_milton;
GO

--- Creación usuarios Administrativo Operativo ---
-- LAUTARO
CREATE LOGIN login_lautaro WITH
    PASSWORD = 'Q4nK%p8',
    CHECK_POLICY = ON;
CREATE USER user_lautaro  FOR LOGIN login_lautaro  WITH DEFAULT_SCHEMA = consorcio;
ALTER ROLE [Administrativo operativo] ADD MEMBER user_lautaro ;
GO

-- AYRTON
CREATE LOGIN login_ayrton WITH
    PASSWORD = '^D1mU$cO',
    CHECK_POLICY = ON;
CREATE USER user_ayrton FOR LOGIN login_ayrton WITH DEFAULT_SCHEMA = consorcio;
ALTER ROLE [Administrativo operativo] ADD MEMBER user_ayrton;
GO

-- MARCO
CREATE LOGIN login_marco WITH
    PASSWORD = '9W!f*G6a',
    CHECK_POLICY = ON;
CREATE USER user_marco FOR LOGIN login_marco WITH DEFAULT_SCHEMA = consorcio;
ALTER ROLE [Administrativo operativo] ADD MEMBER user_marco;
GO

--- Creación usuarios Sistemas ---
-- ROMAN
CREATE LOGIN login_roman_sys WITH
    PASSWORD = 'T$sR7^e4',
    CHECK_POLICY = ON;
CREATE USER user_roman_sys FOR LOGIN login_roman_sys WITH DEFAULT_SCHEMA = consorcio;
ALTER ROLE [Sistemas] ADD MEMBER user_roman_sys;
GO

-- RUSO
CREATE LOGIN login_ruso_sys WITH
    PASSWORD = '!tV9*jPz&',
    CHECK_POLICY = ON;
CREATE USER user_ruso_sys FOR LOGIN login_ruso_sys WITH DEFAULT_SCHEMA = consorcio;
ALTER ROLE [Sistemas] ADD MEMBER user_ruso_sys;
GO

-------- VER USUARIOS CREADOS ------------------
SELECT 
    name AS NombreUsuario,
    type_desc AS Tipo,
    create_date AS FechaCreacion,
    sid AS SID,
    default_schema_name AS EsquemaPorDefecto
FROM 
    sys.database_principals
WHERE 
    type IN ('S', 'U', 'G')
    AND name NOT IN ('public', 'guest', 'INFORMATION_SCHEMA', 'sys', 'dbo');
GO 

-------- VER LOGINS CREADOS ------------------
SELECT
    name AS NombreLogin,
    type_desc AS Tipo,
    create_date AS FechaCreacion,
    sid AS SID
FROM
    sys.server_principals
WHERE
    type = 'S'
    AND name NOT LIKE '##%';
GO

--  Habilitar el modo de autenticación Mixto de SQL Server y Windows
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', 
    N'Software\Microsoft\MSSQLServer\MSSQLServer', 
    N'LoginMode', REG_DWORD, 2;
GO