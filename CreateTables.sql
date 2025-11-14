-- NOTA! Se puede ejectuar todo de una

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
drop table if exists proveedor
go
drop table if exists consorcio
go 
--------------------------------------------------
create table pago (
	id_pago int identity(1,1) primary key not null,
	fecha date,
	cuenta_origen varchar(50),
	importe decimal(10,2),
	asociado char(2) not null,
    id_detalleDeCuenta int null);
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

create table unidadFuncional (
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
	constraint fk_uf_id_consorcio foreign key (id_consorcio) references consorcio (id_consorcio));
go 

-- el unique ese esta raro deber�a funcionar para evitar solapamientos
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
	periodo varchar (10) not null,
	constraint fk_expensa_id_consorcio foreign key (id_consorcio) references consorcio (id_consorcio),
    );
go

create table gasto (
	id_gasto int identity(1,1) primary key,
	id_expensa int,
	periodo varchar (10),
	subtotal_ordinarios decimal(10,2),
	subtotal_extraordinarios decimal(10,2)
	constraint fk_gasto_id_expensa foreign key (id_expensa) references expensa (id_expensa),
    );
go

create table estadoCuentaProrrateo (
	id_detalleDeCuenta int identity (1,1) primary key,
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
	id_gastoOrdinario int identity(1,1) primary key,
	id_gasto int,
	tipo_gasto varchar(50),
	subtipoGasto varchar(50),
	nombre_empresa varchar(200),
	nro_factura int,
	importe decimal(18,2),
	constraint fk_gastoOrdinario_id_gasto 
	foreign key (id_gasto) references gasto (id_gasto),
	);
go

create table gastoExtraordinario (
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
	foreign key (id_gasto) references gasto (id_gasto),
	constraint fk_gastoExtraordinario_id_consorcio 
	foreign key (id_consorcio) references consorcio (id_consorcio)
	);
go

create table proveedor (
	id_proveedor int identity(1,1) primary key,
	id_consorcio int,
	tipo_gasto varchar(50),
	nombre_empresa varchar(100),
	alias varchar(50),
	constraint fk_proveedor_id_consorcio 
	foreign key (id_consorcio) references consorcio (id_consorcio)
	);
go