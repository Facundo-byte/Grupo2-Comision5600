-- NOTAS !!!!!!
-- LEER LOS COMENTARIOS
-- EL ULTIMO SP (sp_importar_uf) no importa bien el "coeficiente", no sé como arreglarlo
-- ALGUNAS VECES CUANDO SE RESETEA EL IDENTITY DSP EMPIEZA EN 0 (Y NO EN 1, COMO DEBERIA) NO SE PQ, SI ALGUNO SABE BIEN SINO LE PREGUNTAMOS AL PROFE
-- TODO LO QUE ESTA ACA ANDA (POR AHI HAYA QUE MODIFICAR COSAS) PERO SI NO LES "COMPILA" O TIENEN ERRORES AVISEN Y LO VEMOS, PQ LO PROBE Y ANDA TODO

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

create table pago (
	id_pago int primary key,
	fecha date,
	cuenta_origen varchar(50),
	importe decimal(10,2),
	asociado bit not null,);
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
	cuenta varchar(50),
	inquilino bit);
go

create table estadoFinanciero (
	id int,
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
	coeficiente decimal (5,2),
	constraint fk_uf_id_consorcio foreign key (id_consorcio) references consorcio (id_consorcio)
	);
go

create table personaUf (
	id_relacion int primary key,
	dni_persona varchar(9) unique,
	id_uf int unique,
	fecha_desde date unique,
	fecha_hasta date,
	--tipo_responsable ????
	constraint fk_personaUf_dni foreign key (dni_persona) references persona (dni),
	constraint fk_personaUf_id_uf foreign key (id_uf) references unidadFuncional (id_uf)
	);
go

create table expensa (
	id_expensa int primary key,
	id_consorcio int,
	id_persona int,
	id_uf int,
	constraint fk_expensa_id_consorcio foreign key (id_consorcio) references consorcio (id_consorcio),
	constraint fk_expensa_id_persona foreign key (id_persona) references persona (id_persona),
	constraint fk_expensa_id_uf foreign key (id_uf) references unidadFuncional (id_uf));
go

create table gasto (
	id_gasto int primary key,
	id_expensa int,
	fecha date,
	periodo date,
	subtotal_ordinarios decimal(10,2),
	subtotal_extraordinarios decimal(10,2)
	constraint fk_gasto_id_expensa foreign key (id_expensa) references expensa (id_expensa));
go

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

create table gastoOrdinario (
	id_gastoOrdinario int primary key,
	id_gasto int,
	tipo_gasto varchar(50),
	--subtipoGasto ???
	nombre_empresa varchar(50),
	nro_factura varchar(50),
	importe decimal(10,2)
	constraint fk_gastoOrdinario_id_gasto 
	foreign key (id_gasto) references gasto (id_gasto),
	);
go

create table gastoExtraordinario (
	id_gastoExtraordinario int primary key,
	id_gasto int,
	tipo_gasto varchar(50),
	--subtipoGasto ???
	nombre_empresa varchar(50),
	nro_factura varchar(50),
	descripcion varchar(50),
	nro_cuota int,
	total_cuotas int,
	importe decimal(10,2)
	constraint fk_gastoExtraordinario_id_gasto 
	foreign key (id_gasto) references gasto (id_gasto),
	);
go


--STORED PROCEDURES

--CARGAR PERSONAS

IF OBJECT_ID('dbo.sp_importar_personas', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_importar_personas;
GO
CREATE PROCEDURE sp_importar_personas
AS
BEGIN
	CREATE TABLE #tempPersona (
		nombre varchar(50),
		apellido varchar(50),
		dni varchar(9) unique,
		email_personal varchar(50),
		telefono_contacto varchar(20),
		cuenta varchar(50),
		inquilino bit);

    BULK INSERT #tempPersona
    FROM '' -- <-- PONER LA RUTA DE ACCESO AL ARCHIVO (inquilino-propietarios-datos) QUE TENGAN USTEDES
    WITH (
        FIELDTERMINATOR = ';',
        ROWTERMINATOR = '\n',
        FIRSTROW = 2
    );

	INSERT INTO persona (nombre, apellido, dni, email_personal, telefono_contacto, cuenta, inquilino)
	SELECT UPPER(LTRIM(RTRIM(nombre))), UPPER(LTRIM(RTRIM(apellido))), LTRIM(RTRIM(dni)), LOWER(REPLACE(LTRIM(RTRIM(email_personal)), ' ', '')), LTRIM(RTRIM(telefono_contacto)), REPLACE(LTRIM(RTRIM(cuenta)), ' ', ''), inquilino
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
-------------------------------------------------

--TUVE QUE MODIFICAR EL ARCHIVO .CSV POR QUE HABIA UN DNI DUPLICADO Y ES UNIQUE ESE CAMPO (Y DEBE SERLO)
--HABRIA QUE AGREGAR ALGO PARA QUE SI HAY UN DNI DUPLICADO LO IGNORE PARA QUE NO SALTE ERROR

---------------------------------------------------------------------------------------------------------------------------------------------------

--CARGAR CONSORCIOS
IF OBJECT_ID('dbo.sp_importar_consorcios', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_importar_consorcios;
GO
CREATE PROCEDURE sp_importar_consorcios
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
-------------------------------------------------


--CARGAR UNIDADES FUNCIONALES
IF OBJECT_ID('dbo.sp_importar_uf', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_importar_uf;
GO
CREATE PROCEDURE sp_importar_uf
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
	SELECT	UPPER(c.id_consorcio), CAST(u.numero_uf AS INT), CAST(u.piso AS varchar(3)), CAST(u.depto as varchar(5)), 
			CASE WHEN u.cochera = 'SI' THEN 1 ELSE 0 END, CAST(u.cochera_m2 AS INT), CASE WHEN u.baulera = 'SI' THEN 1 ELSE 0 END, 
			CAST(u.baulera_m2 as INT), CAST(u.uf_m2 AS INT), CAST(REPLACE(u.coeficiente, ',', '.') AS decimal)
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
-------------------------------------------------
-- TUVE QUE BORRAR LOS ULTIMOS RENGLONES VACIOS DEL ARCHIVO DE TXT PQ SINO NO FUNCIONABA (seguramente tengan que hacer lo mismo)
-- OTRA COSA ES QUE LE PUSE IDENTITY(1,1) A unidadFuncional LO CUAL POR AHI ES MEDIO INCOMODO, PERO SINO ESTO NO FUNCIONA
