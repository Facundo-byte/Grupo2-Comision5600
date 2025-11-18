/*
Comisión:         02-5600
Grupo:            G02
Integrantes:
    - DE LA FUENTE SILVA, CELESTE (45315259)
    - FERNANDEZ MARISCAL, AGUSTIN (45614233)
    - GAUTO, JUAN BAUTISTA (45239479)

Enunciado:        "Creación de Tablas"
*/

--------------------------------------------------------------------------------
use Com5600G02
go 

IF NOT EXISTS (SELECT * FROM  sys.schemas WHERE name = 'consorcio')
    EXEC('CREATE SCHEMA consorcio');
GO

IF NOT EXISTS (SELECT * FROM  sys.schemas WHERE name = 'rep')
    EXEC('CREATE SCHEMA rep');
GO

drop table if exists consorcio.pago
go
drop table if exists consorcio.gastoOrdinario
go
drop table if exists consorcio.gastoExtraordinario
go
drop table if exists consorcio.estadoCuentaProrrateo
go
drop table if exists consorcio.gasto
go
drop table if exists consorcio.expensa
go
drop table if exists consorcio.personaUf
go
drop table if exists consorcio.estadoFinanciero
go
drop table if exists consorcio.proveedor
go
drop table if exists consorcio.unidadFuncional 
go
drop table if exists consorcio.persona
go
drop table if exists consorcio.consorcio
go

-- Nota: Tu lista original tiene dos veces la tabla gastoOrdinario, se mantiene aquí el orden lógico.
--------------------------------------------------
create table consorcio.consorcio (
	id_consorcio int identity(1,1) primary key,
	nombre varchar(35),
	direccion varchar(35),
	cant_uf int,
	cant_m2 int,);
go

create table consorcio.persona (
	id_persona int identity(1,1) primary key,
	nombre varchar(50),
	apellido varchar(50),
	dni varchar(9) unique,
	email_personal varchar(50),
	telefono_contacto varchar(20),
	cuenta varchar(50),);
go

create table consorcio.estadoFinanciero (
	id int identity(1,1),
	id_consorcio int,
	saldo_anterior decimal(12,2),
	ingreso_expensas_termino decimal(12,2),
	ingreso_expensas_adeudadas decimal(12,2),
	ingreso_expensas_adelantadas decimal(12,2),
	egreso decimal(12,2),
	saldo_cierre decimal(12,2),
	periodo date,
	primary key (id, id_consorcio),
	constraint fk_estadoFinanciero_id_consorcio foreign key (id_consorcio) references consorcio.consorcio (id_consorcio));
go


create table consorcio.unidadFuncional (
	id_uf int identity(1,1) primary key,
	id_consorcio int,
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
	constraint fk_uf_id_consorcio foreign key (id_consorcio) references consorcio.consorcio (id_consorcio));
go 

-- el unique ese esta raro deber�a funcionar para evitar solapamientos
create table consorcio.personaUf (
	id_relacion int identity(1,1) primary key,
	dni_persona varchar(9),
	id_uf int,
	fecha_desde date,
	fecha_hasta date,
	tipo_responsable varchar (11),
	unique (id_uf, dni_persona, fecha_desde, fecha_hasta),
	constraint fk_personaUf_dni foreign key (dni_persona) references consorcio.persona (dni),
	constraint fk_personaUf_id_uf foreign key (id_uf) references consorcio.unidadFuncional (id_uf)
	);
go

create table consorcio.expensa (
	id_expensa int identity(1,1) primary key,
	id_consorcio int,
	periodo varchar (10) not null,
	constraint fk_expensa_id_consorcio foreign key (id_consorcio) references consorcio.consorcio (id_consorcio),
    );
go

create table consorcio.gasto (
	id_gasto int identity(1,1) primary key,
	id_expensa int,
	periodo varchar (10),
	subtotal_ordinarios decimal(10,2),
	subtotal_extraordinarios decimal(10,2)
	constraint fk_gasto_id_expensa foreign key (id_expensa) references consorcio.expensa (id_expensa),
    );
go

create table consorcio.estadoCuentaProrrateo (
	id_detalleDeCuenta int identity (1,1) primary key,
	id_expensa int,
	id_uf int,
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
	foreign key (id_expensa) references consorcio.expensa (id_expensa),
	constraint fk_estadoCuentaProrrateo_id_uf
	foreign key (id_uf) references consorcio.unidadFuncional (id_uf),
	CONSTRAINT uq_detalle_expensa_unica UNIQUE (id_expensa, id_uf),
    );
go  

create table consorcio.pago (
	id_pago int identity(1,1) primary key not null,
	fecha date,
	cuenta_origen varchar(50),
	importe decimal(13,2),
	asociado char(2) not null,
    id_detalleDeCuenta int null
    constraint fk_pago_detalleDeCuenta 
    foreign key(id_detalleDeCuenta) references consorcio.estadoCuentaProrrateo(id_detalleDeCuenta),
    CONSTRAINT chk_pago_cuentaOrigen CHECK (ISNUMERIC(cuenta_origen) = 1),
    CONSTRAINT chk_pago_importe CHECK (importe > 0),
    );
go 

create table consorcio.gastoOrdinario (
	id_gastoOrdinario int identity(1,1) primary key,
	id_gasto int,
	tipo_gasto varchar(50),
	subtipoGasto varchar(50),
	nombre_empresa varchar(200),
	nro_factura int,
	importe decimal(18,2),
	constraint fk_gastoOrdinario_id_gasto 
	foreign key (id_gasto) references consorcio.gasto (id_gasto),
	);
go

create table consorcio.gastoExtraordinario (
	id_gastoExtraordinario int identity (1,1) primary key,
	id_gasto int,
	id_consorcio int,
	tipo_gasto varchar(50),
	fecha_gasto date,
	descripcion varchar(50),
	forma_pago varchar(15),
	cuota varchar(15),
	importe decimal(10,2),
	constraint fk_gastoExtraordinario_id_gasto 
	foreign key (id_gasto) references consorcio.gasto (id_gasto),
	constraint fk_gastoExtraordinario_id_consorcio 
	foreign key (id_consorcio) references consorcio.consorcio (id_consorcio)
	);
go

create table consorcio.proveedor (
	id_proveedor int identity(1,1) primary key,
	id_consorcio int,
	tipo_gasto varchar(50),
	nombre_empresa varchar(100),
	alias varchar(50),
	constraint fk_proveedor_id_consorcio 
	foreign key (id_consorcio) references consorcio.consorcio (id_consorcio)
	);
go