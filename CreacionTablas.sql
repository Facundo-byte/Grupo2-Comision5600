create database Com5600G02
go 

use Com5600G02

--Hay que crear schemas??

drop table if exists pago
create table pago (
	id_pago int primary key,
	fecha date,
	cuenta_origen varchar(50),
	importe decimal(10,2),
	asociado bit not null,);
go

drop table if exists consorcio
create table consorcio (
	id_consorcio int primary key,
	nombre varchar(35),
	direccion varchar(35),
	cant_UF int,
	cant_m2 int,);
go

drop table if exists persona
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

drop table if exists estadoFinanciero
create table estadoFinanciero (
	id int,
	id_consorcio int,
	saldo_Anterior decimal(10,2),
	ingreso_expensas_termino decimal(10,2),
	ingreso_expensas_adeudadas decimal(10,2),
	ingreso_expensas_adelantadas decimal(10,2),
	egreso decimal(10,2),
	saldo_Cierre decimal(10,2),
	periodo date,
	primary key (id, id_consorcio),
	constraint fk_estadoFinanciero_id_consorcio foreign key (id_consorcio) references consorcio (id_consorcio));
go

drop table if exists unidadFuncional
create table unidadFuncional (
	id_uf int primary key,
	id_consorcio int,
	cuenta_origen varchar(50),
	numero_uf int,
	piso varchar(3),
	depto varchar(5),
	cochera bit,
	baulera bit,
	cant_m2 int,
	--Coeficiente ????
	constraint fk_uf_id_consorcio foreign key (id_consorcio) references consorcio (id_consorcio)
	);
go

drop table if exists personaUf
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

drop table if exists expensa
create table expensa (
	id_expensa int primary key,
	id_consorcio int,
	id_persona int,
	id_uf int,
	constraint fk_expensa_id_consorcio foreign key (id_consorcio) references consorcio (id_consorcio),
	constraint fk_expensa_id_persona foreign key (id_persona) references persona (id_persona),
	constraint fk_expensa_id_uf foreign key (id_uf) references unidadFuncional (id_uf));
go

drop table if exists gasto
create table gasto (
	id_gasto int primary key,
	id_expensa int,
	fecha date,
	periodo date,
	subtotal_ordinarios decimal(10,2),
	subtotal_extraordinarios decimal(10,2)
	constraint fk_gasto_id_expensa foreign key (id_expensa) references expensa (id_expensa));
go

drop table if exists estadoCuentaProrrateo
create table estadoCuentaProrrateo (
	id_detalleDeCuenta int primary key,
	id_expensa int,
	id_uf int,
	id_pago int,
	fechaEmision date,
	fecha1erVenc date,
	fecha2doVenc date,
	saldoAnterior decimal(10,2),
	pagosRecibidos decimal(10,2),
	deuda decimal(10,2),
	interesPorMora decimal(10,2),
	expensasOrdinarias decimal(10,2),
	expensasExtraordinarias decimal(10,2),
	totalPagar decimal(10,2),
	constraint fk_estadoCuentaProrrateo_id_expensa
	foreign key (id_expensa) references expensa (id_expensa),
	constraint fk_estadoCuentaProrrateo_id_uf
	foreign key (id_uf) references unidadFuncional (id_uf),
	constraint fk_estadoCuentaProrrateo_id_pago
	foreign key (id_pago) references pago (id_pago));
go

drop table if exists gastoOrdinario
create table gastoOrdinario (
	id_gastoOrdinario int primary key,
	id_gasto int,
	--tipo_gasto ???
	--subtipoGasto ???
	nombreEmpresa varchar(50),
	nroFactura varchar(50),
	importe decimal(10,2)
	constraint fk_gastoOrdinario_id_gasto 
	foreign key (id_gasto) references gasto (id_gasto),
	);
go

drop table if exists gastoExtraordinario
create table gastoExtraordinario (
	id_gastoExtraordinario int primary key,
	id_gasto int,
	--tipo_gasto ???
	--subtipoGasto ???
	nombreEmpresa varchar(50),
	nroFactura varchar(50),
	descripcion varchar(50),
	nroCuota int,
	totalCuotas int,
	importe decimal(10,2)
	constraint fk_gastoExtraordinario_id_gasto 
	foreign key (id_gasto) references gasto (id_gasto),
	);
go


--STORED PROCEDURES

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
	SELECT nombre, apellido, dni, email_personal, telefono_contacto, cuenta, inquilino
	FROM #tempPersona
END;
go

exec sp_importar_personas; --test
select * from persona --test para ver personas

--HAY QUE PARSEAR, ALGUNO TIENE ESPACIOS ' ' DE MAS Y PASAR A MAYUSCULAS O MINUSCULAS TODOS LOS NOMBRES Y MAILS
--TUVE QUE MODIFICAR EL ARCHIVO .CSV POR QUE HABIA UN DNI DUPLICADO Y ES UNIQUE ESE CAMPO (Y DEBE SERLO)
--HABRIA QUE AGREGAR ALGO PARA QUE SI HAY UN DNI DUPLICADO LO IGNORE PARA QUE NO SALTE ERROR