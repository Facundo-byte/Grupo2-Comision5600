-- NOTAS !!!!!!
-- LEER LOS COMENTARIOS
-- ESTÁN LOS SP CON SQL DINÁMICO Y NORMAL, LOS DEJE POR LAS DUDAS(LOS NORMALES)
-- ALGUNAS VECES CUANDO SE RESETEA EL IDENTITY DSP EMPIEZA EN 0 (Y NO EN 1, COMO DEBERIA) NO SE PQ, SI ALGUNO SABE BIEN SINO LE PREGUNTAMOS AL PROFE
-- TODO LO QUE ESTA ACA ANDA (POR AHI HAYA QUE MODIFICAR COSAS) PERO SI NO LES "COMPILA" O TIENEN ERRORES AVISEN Y LO VEMOS, PQ LO PROBE Y ANDA TODO
-- CHEQUEAR IMPORTE DNI DUPLICADOS 
-- MODIFICAR LOS BITS DE UF PARA QUE PERMITA SI O NO
-- AGREGAR NOMBRE CONSORCIO EN UF PARA QUE SEA MAS FÁCIL PARA FUTURAS RELACIONES 
create database Com5600G02
go 

use Com5600G02
go

--Hay que crear schemas??

------------------- TESTING ---------------------
drop table if exists estadoFinanciero 
go
drop table if exists personaUf
go
drop table if exists gastoOrdinario
go
drop table if exists gastoExtraordinario
go
drop table if exists estadoCuentaProrrateo
go
drop table if exists pago
go
drop table if exists gasto
go
drop table if exists expensa
go
drop table if exists persona
go
drop table if exists unidadFuncional 
go
drop table if exists gastoOrdinario
go
drop table if exists consorcio
go
--------------------------------------------------
-- Cambios en tablas que me parecieron correctos:  
-- incremental en la mayoria de las tablas
create table pago (
	id_pago int identity(1,1) primary key not null,
	fecha date,
	cuenta_origen varchar(50),
	importe decimal(10,2),
	asociado char(2) not null,);
go

create table consorcio (
	id_consorcio int identity(1,1) primary key,
	nombre varchar(35),
	direccion varchar(35),
	cant_uf int,
	cant_m2 int,);
go

create table persona (
	id_persona int identity(1,1) primary key,
	nombre varchar(50),
	apellido varchar(50),
	dni varchar(9) unique,
	email_personal varchar(50),
	telefono_contacto varchar(20),
	cuenta varchar(50),);
go

create table estadoFinanciero (
	id int identity(1,1),
	id_consorcio int,
	saldo_anterior decimal(10,2),
	ingreso_expensas_termino decimal(10,2),
	ingreso_expensas_adeudadas decimal(10,2),
	ingreso_expensas_adelantadas decimal(10,2),
	egreso decimal(10,2),
	saldo_cierre decimal(10,2),
	periodo date,
	primary key (id, id_consorcio),
	constraint fk_estadoFinanciero_id_consorcio foreign key (id_consorcio) references consorcio (id_consorcio));
go
-- en período cambiaría el tipo de dato 

create table unidadFuncional (
	id_uf int identity(1,1) primary key, --LE AGREGE EL IDENTITY(1,1) POR QUE SINO, NO PODIA IMPORTAR Y HACER CC ERA MUY COMPLEJO PARA TESTAR
id_consorcio int, -- fk
cuenta_origen varchar(50),
numero_uf int,
piso varchar(3),
depto varchar(5),
cochera bit,
cochera_m2 int,
baulera bit,
baulera_m2 int,
cant_m2 int,
coeficiente decimal (2,1),
constraint fk_uf_id_consorcio foreign key (id_consorcio) references consorcio (id_consorcio));
go 


-- el unique ese esta raro debería funcionar para evitar solapamientos
create table personaUf (
	id_relacion int identity(1,1) primary key,
	dni_persona varchar(9),
	id_uf int,
	fecha_desde date,
	fecha_hasta date,
	tipo_responsable varchar (11),
	unique (id_uf, dni_persona, fecha_desde, fecha_hasta),
	constraint fk_personaUf_dni foreign key (dni_persona) references persona (dni),
	constraint fk_personaUf_id_uf foreign key (id_uf) references unidadFuncional (id_uf)
	);
go

create table expensa (
	id_expensa int identity(1,1) primary key,
	id_consorcio int,
	id_persona int,
	id_uf int,
	constraint fk_expensa_id_consorcio foreign key (id_consorcio) references consorcio (id_consorcio),
	constraint fk_expensa_id_persona foreign key (id_persona) references persona (id_persona),
	constraint fk_expensa_id_uf foreign key (id_uf) references unidadFuncional (id_uf));
go

create table gasto (
	id_gasto int identity(1,1) primary key,
	id_expensa int,
	fecha date,
	periodo date,
	subtotal_ordinarios decimal(10,2),
	subtotal_extraordinarios decimal(10,2)
	constraint fk_gasto_id_expensa foreign key (id_expensa) references expensa (id_expensa));
go
-- lo mismo con el tipo de dato periodo

create table estadoCuentaProrrateo (
	id_detalleDeCuenta int primary key,
	id_expensa int,
	id_uf int,
	id_pago int,
	fecha_emision date,
	fecha_1er_venc date,
	fecha_2do_venc date,
	saldo_anterior decimal(10,2),
	pagos_recibidos decimal(10,2),
	deuda decimal(10,2),
	interes_por_mora decimal(10,2),
	expensas_ordinarias decimal(10,2),
	expensas_extraordinarias decimal(10,2),
	total_pagar decimal(10,2),
	constraint fk_estadoCuentaProrrateo_id_expensa
	foreign key (id_expensa) references expensa (id_expensa),
	constraint fk_estadoCuentaProrrateo_id_uf
	foreign key (id_uf) references unidadFuncional (id_uf),
	constraint fk_estadoCuentaProrrateo_id_pago
	foreign key (id_pago) references pago (id_pago));
go

--subtipo gasto es por si es de limpieza
--nrofactura lo cambie a int
--le agregue la fecha del gasto
create table gastoOrdinario (
	id_gastoOrdinario int identity(1,1) primary key,
	id_gasto int,
	fecha_gasto date,
	tipo_gasto varchar(50),
	subtipoGasto varchar(50),
	nombre_empresa varchar(50),
	nro_factura int,
	importe decimal(10,2)
	constraint fk_gastoOrdinario_id_gasto 
	foreign key (id_gasto) references gasto (id_gasto),
	constraint fk_gastoOrdinario_fecha_gasto 
	foreign key (fecha_gasto) references gasto (fecha),
	);
go

create table gastoExtraordinario (
	id_gastoExtraordinario int identity (1,1) primary key,
	id_gasto int,
	tipo_gasto varchar(50),
	fecha_gasto date,
	nombre_empresa varchar(50),
	nro_factura varchar(50),
	descripcion varchar(50),
	nro_cuota int,
	total_cuotas int,
	importe decimal(10,2)
	constraint fk_gastoExtraordinario_id_gasto 
	foreign key (id_gasto) references gasto (id_gasto),
	constraint fk_gastoExtraordinario_fecha_gasto 
	foreign key (fecha_gasto) references gasto (fecha),
	);
go


--STORED PROCEDURES

--CARGAR PERSONAS

/*IF OBJECT_ID('dbo.sp_importar_personas', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_importar_personas;
GO
CREATE or ALTER PROCEDURE sp_importar_personas
AS
BEGIN
	CREATE TABLE #tempPersona (
		nombre varchar(50),
		apellido varchar(50),
		dni varchar(9) unique,
		email_personal varchar(50),
		telefono_contacto varchar(20),
		cuenta varchar(50),
		inquilino bit,);

    BULK INSERT #tempPersona
    FROM '' -- <-- PONER LA RUTA DE ACCESO AL ARCHIVO (inquilino-propietarios-datos) QUE TENGAN USTEDES
    WITH (
        FIELDTERMINATOR = ';',
        ROWTERMINATOR = '\n',
        FIRSTROW = 2
    );

	INSERT INTO persona (nombre, apellido, dni, email_personal, telefono_contacto, cuenta)
	SELECT UPPER(LTRIM(RTRIM(nombre))), UPPER(LTRIM(RTRIM(apellido))), LTRIM(RTRIM(dni)), LOWER(REPLACE(LTRIM(RTRIM(email_personal)), ' ', '')), LTRIM(RTRIM(telefono_contacto)), REPLACE(LTRIM(RTRIM(cuenta)), ' ', '')
	FROM #tempPersona
END;
go

--EJECUTAR TODO JUNTO ESTO
------------------- TESTING ---------------------
delete from persona --test
go
DBCC CHECKIDENT ('persona', RESEED, 0); --Reincia el IDENTITY(1,1)
go
exec sp_importar_personas; --test
go
select * from persona --test para ver personas
-------------------------------------------------*/

--TUVE QUE MODIFICAR EL ARCHIVO .CSV POR QUE HABIA UN DNI DUPLICADO Y ES UNIQUE ESE CAMPO (Y DEBE SERLO)
--HABRIA QUE AGREGAR ALGO PARA QUE SI HAY UN DNI DUPLICADO LO IGNORE PARA QUE NO SALTE ERROR


--CARGAR PERSONAS CON SQL DINÁMICO PARA LA RUTA DE ACCESO
CREATE OR ALTER PROCEDURE sp_importar_personas
    @RutaArchivoPersonas VARCHAR(255)  -- Parámetro de entrada para la ruta del archivo
AS
BEGIN
   CREATE TABLE #tempPersona (
		nombre varchar(50),
		apellido varchar(50),
		dni varchar(9) unique,
		email_personal varchar(50),
		telefono_contacto varchar(20),
		cuenta varchar(50),
		inquilino bit,);

    -- Declarar una variable para el SQL dinámico
    DECLARE @sql_dinamicoPer NVARCHAR(MAX);

    -- Construir la instrucción BULK INSERT usando el parámetro
    SET @sql_dinamicoPer = 
        'BULK INSERT #tempPersona ' + 
        'FROM ''' + @RutaArchivoPersonas + ''' ' +  -- Importante: se usan dos comillas simples ('') para la ruta
        'WITH ( ' +
            'FIELDTERMINATOR = '';'', ' +
            'ROWTERMINATOR = ''\n'', ' +
            'FIRSTROW = 2 ' +
        ');';

    -- Ejecutar la importación (requiere permisos 'BULK ADMIN' o 'ADMINISTRATOR')
    EXEC sp_executesql @sql_dinamicoPer;

    -- Insertar en la tabla final consorcio con transformaciones
    -- Nota: Aquí se asume que la tabla 'consorcio' no admite duplicados (lo que debes validar)
    INSERT INTO persona (nombre, apellido, dni, email_personal, telefono_contacto, cuenta)
	SELECT UPPER(LTRIM(RTRIM(nombre))), UPPER(LTRIM(RTRIM(apellido))), LTRIM(RTRIM(dni)), LOWER(REPLACE(LTRIM(RTRIM(email_personal)), ' ', '')), LTRIM(RTRIM(telefono_contacto)), REPLACE(LTRIM(RTRIM(cuenta)), ' ', '')
	FROM #tempPersona
END;
GO


-- Ejemplo de ejecución (debe estar en el script de testing/invocaciones)
DECLARE @archivo_personas VARCHAR(255) = ''; --<----RUTA DE ACCESO

-- Restablece el IDENTITY para la prueba
DELETE FROM persona; 
DBCC CHECKIDENT ('persona', RESEED, 0);

-- Ejecuta el SP pasando la variable con la ruta del archivo
EXEC sp_importar_personas @RutaArchivoPersonas = @archivo_personas;

-- Verificación
SELECT * FROM persona;
GO
---------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------

--CARGAR CONSORCIOS
/*IF OBJECT_ID('dbo.sp_importar_consorcios', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_importar_consorcios;
GO
CREATE or ALTER PROCEDURE sp_importar_consorcios
AS
BEGIN
	CREATE TABLE #tempConsorcio (
		num_consorcio varchar(12),
		nombre varchar(35),
		direccion varchar(35),
		cant_uf int,
		cant_m2 int,);

    BULK INSERT #tempConsorcio
    FROM '' -- <-- PONER LA RUTA DE ACCESO AL ARCHIVO (datos varios 1(Consorcios).csv) QUE TENGAN USTEDES (ES EL ARCHIVO EXCEL, TIENE DOS VENTANAS DENTRO, EXPORTAR COMO CSV)
    WITH (
        FIELDTERMINATOR = ';',
        ROWTERMINATOR = '\n',
        FIRSTROW = 2
    );

	INSERT INTO consorcio (nombre, direccion, cant_uf, cant_m2)
	SELECT UPPER(LTRIM(RTRIM(nombre))), UPPER(LTRIM(RTRIM(direccion))), cant_uf, cant_m2
	FROM #tempConsorcio
END;
go

--EJECUTAR TODO JUNTO ESTO
------------------- TESTING ---------------------
delete from consorcio --test
go
DBCC CHECKIDENT ('consorcio', RESEED, 0); --Reincia el IDENTITY(1,1)
go
exec sp_importar_consorcios; --test
go
select * from consorcio --test para ver consorcios
-------------------------------------------------*/

--CARGAR CONSORCIOS CON SQL DINÁMICO PARA LA RUTA DE ACCESO
CREATE OR ALTER PROCEDURE sp_importar_consorcios
    @RutaArchivo VARCHAR(255)  -- Parámetro de entrada para la ruta del archivo
AS
BEGIN
    CREATE TABLE #tempConsorcio (
		num_consorcio varchar(12),
		nombre varchar(35),
		direccion varchar(35),
		cant_uf int,
		cant_m2 int,);

    -- Declarar una variable para el SQL dinámico
    DECLARE @sql_dinamico NVARCHAR(MAX);

    -- Construir la instrucción BULK INSERT usando el parámetro
    SET @sql_dinamico = 
        'BULK INSERT #tempConsorcio ' + 
        'FROM ''' + @RutaArchivo + ''' ' +  -- Importante: se usan dos comillas simples ('') para la ruta
        'WITH ( ' +
            'FIELDTERMINATOR = '';'', ' +
            'ROWTERMINATOR = ''\n'', ' +
            'FIRSTROW = 2 ' +
        ');';

    -- Ejecutar la importación (requiere permisos 'BULK ADMIN' o 'ADMINISTRATOR')
    EXEC sp_executesql @sql_dinamico;

    -- Insertar en la tabla final consorcio con transformaciones
    -- Nota: Aquí se asume que la tabla 'consorcio' no admite duplicados (lo que debes validar)
    INSERT INTO consorcio (nombre, direccion, cant_uf, cant_m2)
	SELECT UPPER(LTRIM(RTRIM(nombre))), UPPER(LTRIM(RTRIM(direccion))), cant_uf, cant_m2
	FROM #tempConsorcio 

END
GO


-- Ejemplo de ejecución (debe estar en el script de testing/invocaciones)
DECLARE @archivo_consorcios VARCHAR(255) = ''; --<----RUTA DE ACCESO

-- Restablece el IDENTITY para la prueba
DELETE FROM consorcio; 
DBCC CHECKIDENT ('consorcio', RESEED, 0);

-- Ejecuta el SP pasando la variable con la ruta del archivo
EXEC sp_importar_consorcios @RutaArchivo = @archivo_consorcios;

-- Verificación
SELECT * FROM consorcio;
GO
---------------------------------



--CARGAR UNIDADES FUNCIONALES
--Modifique el decimal en coeficiente
/*IF OBJECT_ID('dbo.sp_importar_uf', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_importar_uf;
GO
CREATE or ALTER PROCEDURE sp_importar_uf
AS
BEGIN
	-- MISMO ORDEN QUE EN EL ARCHIVO "UF por consorcio.txt"
	CREATE TABLE #tempUf ( 
		nombre_consorcio varchar(35),
    numero_uf varchar(10),
    piso varchar(10),
    depto varchar(10),
    coeficiente varchar(10),
    uf_m2 varchar(10),
    baulera varchar(10),
    cochera varchar(10),
    baulera_m2 varchar(10),
    cochera_m2 varchar(10));

    BULK INSERT #tempUf
    FROM '' -- <-- PONER LA RUTA DE ACCESO AL ARCHIVO (UF por consorcio.txt) QUE TENGAN USTEDES
    WITH (
        FIELDTERMINATOR = '\t',
        ROWTERMINATOR = '\n',
        FIRSTROW = 2,
		CODEPAGE = '65001' 
    );

	INSERT INTO unidadFuncional (id_consorcio, numero_uf, piso, depto, cochera, cochera_m2, baulera, baulera_m2, cant_m2, coeficiente)
SELECT    UPPER(c.id_consorcio), CAST(u.numero_uf AS INT), CAST(u.piso AS varchar(3)), CAST(u.depto as varchar(5)), 
        CASE WHEN u.cochera = 'SI' THEN 1 ELSE 0 END, CAST(u.cochera_m2 AS INT), CASE WHEN u.baulera = 'SI' THEN 1 ELSE 0 END, 
        CAST(u.baulera_m2 as INT), CAST(u.uf_m2 AS INT), CAST(REPLACE(u.coeficiente, ',', '.') AS decimal (2,1))
FROM #tempUf u
JOIN consorcio c ON c.nombre = u.nombre_consorcio;
END;
go

--EJECUTAR TODO JUNTO ESTO
------------------- TESTING ---------------------
delete from unidadFuncional --test
go
DBCC CHECKIDENT ('unidadFuncional', RESEED, 0); --Reincia el IDENTITY(1,1)
go
exec sp_importar_uf; --test
go
select * from unidadFuncional --test para ver consorcios
-------------------------------------------------*/
-- TUVE QUE BORRAR LOS ULTIMOS RENGLONES VACIOS DEL ARCHIVO DE TXT PQ SINO NO FUNCIONABA (seguramente tengan que hacer lo mismo)


--CARGAR UF CON SQL DINÁMICO PARA LA RUTA DE ACCESO
CREATE or ALTER PROCEDURE sp_importar_uf
    @RutaArchivoUF VARCHAR(255)  -- Parámetro de entrada para la ruta del archivo
AS
BEGIN
    CREATE TABLE #tempUf ( 
		nombre_consorcio varchar(35),
    numero_uf varchar(10),
    piso varchar(10),
    depto varchar(10),
    coeficiente varchar(10),
    uf_m2 varchar(10),
    baulera varchar(10),
    cochera varchar(10),
    baulera_m2 varchar(10),
    cochera_m2 varchar(10));

    -- Declarar una variable para el SQL dinámico
    DECLARE @sql_dinamicoUF NVARCHAR(MAX);

    -- Construir la instrucción BULK INSERT usando el parámetro
    SET @sql_dinamicoUF = 
        'BULK INSERT #tempUf ' + 
        'FROM ''' + @RutaArchivoUF + ''' ' +  -- Importante: se usan dos comillas simples ('') para la ruta
        'WITH ( ' +
            'FIELDTERMINATOR = ''\t'', ' +
            'ROWTERMINATOR = ''\n'', ' +
            'FIRSTROW = 2, ' +
			'CODEPAGE = ''65001'' '+
        ');';

    -- Ejecutar la importación (requiere permisos 'BULK ADMIN' o 'ADMINISTRATOR')
    EXEC sp_executesql @sql_dinamicoUF;

    -- Insertar en la tabla final unidadfuncional con transformaciones
    -- Nota: Aquí se asume que la tabla 'unidadfuncional' no admite duplicados (lo que debes validar)
    INSERT INTO unidadFuncional (id_consorcio, numero_uf, piso, depto, cochera, cochera_m2, baulera, baulera_m2, cant_m2, coeficiente)
	SELECT    UPPER(c.id_consorcio), CAST(u.numero_uf AS INT), CAST(u.piso AS varchar(3)), CAST(u.depto as varchar(5)), 
        CASE WHEN u.cochera = 'SI' THEN 1 ELSE 0 END, CAST(u.cochera_m2 AS INT), CASE WHEN u.baulera = 'SI' THEN 1 ELSE 0 END, 
        CAST(u.baulera_m2 as INT), CAST(u.uf_m2 AS INT), CAST(REPLACE(u.coeficiente, ',', '.') AS decimal (2,1))
	FROM #tempUf u
	JOIN consorcio c ON c.nombre = u.nombre_consorcio;
END;
GO


-----------------------Ejecución---------------------- 
DECLARE @archivo_uf VARCHAR(255) = '';--<----RUTA DE ACCESO

-- Restablece el IDENTITY para la prueba
DELETE FROM unidadFuncional; 
DBCC CHECKIDENT ('unidadFuncional', RESEED, 0);

-- Ejecuta el SP pasando la variable con la ruta del archivo
EXEC sp_importar_uf @RutaArchivoUF = @archivo_uf;

-- Verificación
SELECT * FROM unidadFuncional;
GO
--------------------------------------------------------------


