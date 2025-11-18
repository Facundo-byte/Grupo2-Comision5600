/*
Comisión:         02-5600
Grupo:            G02
Integrantes:
    - DE LA FUENTE SILVA, CELESTE (45315259)
    - FERNANDEZ MARISCAL, AGUSTIN (45614233)
    - GAUTO, JUAN BAUTISTA (45239479)


Enunciado:        "Política de respaldo y schedule"
*/


/*Dado que la información de cada expensa generada es crítica para la contabilidad del sistema 
y para la administración de los consorcios, se implementarán políticas de respaldo acordes. 
Abarcando tanto las expensas como las ventas diarias y los reportes generados, con el objetivo de que no haya perdida substancial 
de informacion, en caso de una falla o ataque.

-- Respaldos automáticos --
Se realizará un backup completo de la base de datos al finalizar cada jornada (fuera del horario laboral).
Con el objetivo de que la información sobre expensas, movimientos y pagos del día quede protegida.

-- Respaldos diferenciales --
Durante el día se ejecutarán respaldos diferenciales y de logs de transacción cada 1 hora.
Para reducir la posibilidad de pérdida de datos, en caso de que sea necesario volver a un estado anterior.

-- Respaldo y versionado de reportes --
Todos los reportes emitidos se almacenarán de manera versionada.
Se recomienda realizar respaldos de los respaldos en un medio físico on-premise, como medida extra de seguridad.
Los respaldos más viejos deberán ser almacenados en medios externos al servidor, ya que si esto no se hace 
la necesidad por más recursos en el servidor crecerá y con esto el gasto del servicio de nube.

-- Pruebas y verificaciones de restauración --
Se realizarán pruebas de restauración completas una vez al mes. Luego de cada generación de reportes mensual.
Se recomienda verificar la integridad de los archivos de backup una vez por semana, o minimamente al generarse un nuevo respaldo.
Estas verificaciones aseguran que los respaldos sean utilizables al momento de ser necesarios.

-- Seguridad y cifrado --
Los respaldos se almacenarán de forma cifrada por una constraseña que tendrán solo los roles y/o personas que 
la deban tener para asegurar la operación de la base de datos.
Con el objetivo de evitar accesos no autorizados a información sensible.

-- Objetivos de Recuperación del Servicio --
RTO (Recovery Time Objective)
RTO recomendado: 1 a 4 horas
Este rango es adecuado porque:
El sistema si bien administra expensas de varios consorcios, no se requiere que sea de alta disponibilidad en tiempo real las 24 horas.
Un período de 1 a 4 horas permite hacer restauraciones completas sin afectar procesos administrativos 
y pueden realizarse durante una jornada laboral si fuese absolutamente necesario.

RPO (Recovery Point Objective)
RPO recomendado: 1 hora
Ante una falla, la pérdida de datos no debería exceder la última hora de trabajo.
Este RPO funciona bien con:
La posibilidad de ejecutar respaldos incrementales cada hora o de logs de transacciones.

-- Aclaraciones --
Otras técnicas como replicas y log shipping entre otras, no son necesarias (por el fin de aplicación) 
y tampoco son recomendables ya que éstas requieren de una mayor capacidad de procesamiento y de almacenamiento 
(incrementado el costo del servicio en la nube) lo cual no se justifica para el tipo de programa/aplicación solicitado. */