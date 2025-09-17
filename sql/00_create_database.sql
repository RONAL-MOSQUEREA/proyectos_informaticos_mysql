CREATE DATABASE IF NOT EXISTS proyectos_informaticos;
--Q0: Creación y uso de la base de datos
--Garantiza que la base de datos exista y la selecciona para ejecutar las consultas posteriores.



USE proyectos_informaticos;
--2.	USE proyectos_informaticos;
--o	Le indica al servidor MySQL que, a partir de este momento, todas las consultas se ejecutarán dentro de esa base de datos.
--o	Es como “entrar” en la base de datos para trabajar con sus tablas, procedimientos, funciones, etc.

--•	SELECT p.proyecto_id, p.nombre AS proyecto, d.nombres AS docente_jefe
--o	Indica las columnas que se quieren mostrar en el resultado:
--	p.proyecto_id → el identificador único del proyecto.
	--p.nombre AS proyecto → el nombre del proyecto. El alias AS proyecto es solo para que la columna aparezca con ese nombre en los resultados.
--d.nombres AS docente_jefe → el nombre del docente que está asignado como jefe del proyecto. También se renombra la columna para mayor claridad.
	

--•	FROM proyecto 
--o	Se indica la tabla principal: proyecto.
--o	Se le da un alias (p) para simplificar el uso en la consulta.


--•	JOIN docente d ON d.docente_id = p.docente_id_jefe
--o	Se hace un INNER JOIN entre las tablas proyecto y docente.
--o	La condición de unión es que el campo docente_id en docente coincida con docente_id_jefe en proyecto.
--o	Es decir: se busca el docente que corresponde a cada proyecto


 --Funcionalidad
--•	Une información de dos tablas relacionadas (proyecto y docente).
--•	Permite identificar quién es el responsable principal de cada proyecto.
--•	Sirve para generar reportes, validar datos y mostrar en interfaces (ejemplo: "Proyecto: Plataforma Académica — Jefe: Ana Gómez").


--Esta consulta te da la relación 1 a 1 entre cada proyecto y el docente que figura como jefe.

--1.	SELECT d.docente_id, d.nombres,
--o	Selecciona el id del docente (docente_id) y el nombre del docente (nombres) de la tabla docente.
--o	Esto es información base para identificar al docente en el resultado.

--2.	fn_promedio_presupuesto_por_docente(d.docente_id) AS promedio_presupuesto
--o	Llama a la función fn_promedio_presupuesto_por_docente, pasando como parámetro el docente_id actual de cada fila.
--o	Esa función hace internamente un AVG(presupuesto) de todos los proyectos que tengan como jefe al docente recibido.
--o	El resultado se muestra con el alias promedio_presupuesto.
--Gracias a esto, no necesitas escribir toda la lógica del cálculo en cada consulta: queda encapsulada en la función.
--3.	FROM docente d;
--o	La consulta recorre la tabla docente (d es un alias).
--o	Por cada docente, calcula el promedio de presupuesto de sus proyectos mediante la UDF.
--•	Centraliza la lógica: el cálculo del promedio no se repite en cada SELECT, se delega a la función.

--•	Automatiza reportes: de un solo query obtienes el docente y su promedio de presupuestos.

--•	Optimiza mantenimiento: si cambia la forma de calcular el promedio, solo modificas la función, no todas las consultas.

--Esta consulta permite verificar que el trigger AFTER UPDATE sobre la tabla docente está funcionando correctamente.
--El trigger guarda un registro en la tabla copia_actualizados_docente cada vez que un docente es actualizado.

--1.	SELECT * FROM copia_actualizados_docente
--o	Trae todas las columnas de la tabla de auditoría copia_actualizados_docente.
--o	Esa tabla almacena información como:
--	auditoria_id: identificador único del evento.
	--docente_id: id del docente afectado.
	--fecha: cuándo ocurrió la actualización.
	--usuario: qué usuario de MySQL realizó el cambio.
--old_row: los valores del registro antes del cambio (en formato JSON).
	--new_row: los valores del registro después del cambio (en formato JSON).

--2.	ORDER BY auditoria_id DESC
	--Ordena los resultados en orden descendente según el id de auditoría.
--	Esto significa que se mostrarán primero los cambios más recientes.

--3.	LIMIT 10;
--	Restringe la salida a los 10 registros más recientes.
--	Esto evita que se devuelvan miles de filas y permite una verificación rápida.
-- Funcionalidad
--•	Permite auditar los últimos cambios realizados sobre docentes.
--•	Sirve para comprobar que el trigger está insertando correctamente los datos en copia_actualizados_docente.
--•	Útil para auditoría de seguridad, debugging y control de cambios.

-- Q4: Verificar trigger DELETE (auditoría)
--Muestra lo registrado por el trigger AFTER DELETE de la tabla docente.
--Ordena por auditoria_id de forma descendente para ver las eliminaciones más recientes.
--Limita el resultado a los últimos 10 registros.
--Funcionalidad: auditar y confirmar qué docentes fueron eliminados y cuándo. 

-- Q5: Validar CHECKs
--	Selecciona proyectos mostrando sus datos principales.
--fecha_final IS NULL OR fecha_final >= fecha_inicial → asegura que la fecha final sea válida o no esté definida.
--presupuesto >= 0 → evita presupuestos negativos.
--horas >= 0 → evita horas negativas.
--Funcionalidad: validar que los proyectos cumplan las reglas de integridad (CHECKs) antes de ser considerados válidos

-- Q6: Docentes con sus proyectos
--	Lista a todos los docentes junto con los proyectos que dirigen.
--Usa LEFT JOIN → muestra también a los docentes que no tienen proyectos asignados.
--Ordena el resultado por docente_id.
--Funcionalidad: ver la relación entre docentes y proyectos, incluyendo los que aún no son jefes de ningún proyecto. 

-- Q7: Total de horas por docente
--Muestra cada docente con la suma total de horas de los proyectos que lidera.
--LEFT JOIN → incluye docentes sin proyectos (su total será NULL o 0).
--GROUP BY agrupa resultados por docente para calcular el total.
--Funcionalidad: obtener la carga de trabajo (horas acumuladas) de cada docente en sus proyectos. 

-- Q8: Inserciones vía procedimientos
--	CALL sp_docente_crear(...) → inserta docentes usando el procedimiento almacenado.
--SET @id_ana, @id_carlos → guarda en variables los IDs generados para esos docentes.
--CALL sp_proyecto_crear(...) → crea proyectos y los asigna a cada docente usando sus IDs.

-- Q9: Inserciones directas (opcional)
--	CALL sp_docente_crear(...) → inserta docentes usando el procedimiento almacenado.
--SET @id_ana, @id_carlos → guarda en variables los IDs generados para esos docentes.
--CALL sp_proyecto_crear(...) → crea proyectos y los asigna a cada docente usando sus IDs.
-- Funcionalidad: automatizar inserciones de docentes y proyectos con procedimientos, manteniendo consistencia y evitando escribir INSERT manualmente. 

--Profesor, gracias por compartir su conocimiento con tanta pasión y paciencia. Más que enseñarnos teoría, nos inspira a crecer, a pensar diferente y a dar lo mejor de nosotros. 
--Su esfuerzo y dedicación dejan huella, y estoy seguro de que lo que aprendemos con usted nos acompañará mucho más allá del aula. 














