ALTER PROC [dba].[SP_ActualizacionMetadatos]
AS 
BEGIN 
--El tiempo esperado de ejecucion es menor al minuto
--Actualiza la tabla de metadatoscampos
 
 --actualiza los campos de las tablas y vistas 
 EXEC dba.SP_ActualizacionMetadatos_Coincidentes

--elimina las tablas y vistas que ya no existen pero estan la tabla metadatoscampos
 EXEC dba.SP_ActualizacionMetadatos_Eliminacion

 --inserta tablas y vistas a nivel objeto y campo de las nuevas tablas y vistas
 EXEC dba.SP_ActualizacionMetadatos_Nuevas
	
END
