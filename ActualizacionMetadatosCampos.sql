
ALTER PROC [dba].[SP_ActualizacionMetadatosCampos]
AS 
BEGIN 
--Actualiza la tabla de metadatoscampos
 
 --actualiza los campos de las tablas y vistas 
 EXEC dba.SP_ActualizacionMetadatosCampos_Coincidentes

--elimina las tablas y vistas que ya no existen pero estan la tabla metadatoscampos
 EXEC dba.SP_ActualizacionMetadatosCampos_Eliminacion

 --inserta tablas y vistas a nivel objeto y campo de las nuevas tablas y vistas
 EXEC dba.SP_ActualizacionMetadatosCampos_Nuevas
	
END
