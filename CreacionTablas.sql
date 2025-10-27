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
	id_persona int primary key,
	dni varchar(8) unique,
	cuenta varchar(50),
	nombre varchar(50),
	apellido varchar(50),
	email_personal varchar(30),
	telefono_contacto varchar(20),);
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
	constraint fk_id_consorcio foreign key (id_consorcio) references consorcio (id_consorcio));
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
	dni_persona varchar(8) unique,
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
	--pagosRecibidos ???,
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
	--fecha_gasto date, //Si queremos ponerlo aca hay que hacerlo UNIQUE en table gasto.
	--					//pero se puede conseguir haciendo un JOIN con id_gasto por lo que no lo pondría aca pero idk
	--tipo_gasto ???
	--subtipoGasto ???
	nombreEmpresa varchar(50),
	nroFactura varchar(50),
	importe decimal(10,2)
	constraint fk_gastoOrdinario_id_gasto 
	foreign key (id_gasto) references gasto (id_gasto),
	--constraint fk_gastoOrdinario_fecha_gasto 
	--foreign key (fecha_gasto) references gasto (fecha),
	);
go

drop table if exists gastoExtraordinario
create table gastoExtraordinario (
	id_gastoExtraordinario int primary key,
	id_gasto int,
	--fecha_gasto date, //Si queremos ponerlo aca hay que hecerlo UNIQUE en table gasto.
	--					//pero se puede conseguir haciendo un JOIN con id_gasto
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
	--constraint fk_gastoExtraordinario_fecha_gasto 
	--foreign key (fecha_gasto) references gasto (fecha),
	);
go
