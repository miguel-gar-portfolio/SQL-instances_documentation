
ALTER PROC [dba].[SP_ActualizacionMetadatosCampos_Eliminacion]
AS
BEGIN
EXEC [dba].sp_MSforeachdbMax N'
	BEGIN
		USE [?]
		--Seleccion a nivel objeto (tabla y vista) de registros eliminados, guardado de la cantidad de los mismos en la variable @objects_quantity
		DECLARE @objects_quantity INT =0;

		SELECT @objects_quantity=COUNT(B.is_deleted)
		FROM (	SELECT	*,
						ISNULL(A.nombre_sysobjects, ''1'') AS is_deleted
				FROM (	SELECT	t.IdUniversal AS ID,
								t.NombreTabla_O_Vista AS nombre_metadatos,
								t.Tipo AS Tipo,
								o.name AS nombre_sysobjects
						FROM (	SELECT * 
								FROM [MoovaFleetProd_BackUp10012025].dba.Metadatos_Campos
								WHERE Tipo IN (''Tabla'', ''Vista'') 
								AND BaseDeDatos = DB_NAME()) AS t
						LEFT JOIN sys.objects o 
							ON t.NombreTabla_O_Vista = o.name COLLATE SQL_Latin1_General_CP1_CI_AS) AS A ) AS B					
		WHERE B.is_deleted = ''1''

		--Condicional si detectan filas a eliminar
		IF @objects_quantity<>0
			BEGIN
				DECLARE @COUNTERAID INT = 0

				--Ejecuta mientras contador<cantidad
				WHILE @COUNTERAID<@objects_quantity
					BEGIN	
						DECLARE @TableOrViewID VARCHAR(100)
				
						--TOMAMOS COMO LAS VARIABLES SUS CORRESPONDIENTES VALORES 
						SELECT	@TableOrViewID = B.ID
						FROM (	SELECT	A.ID,
										A.nombre_sysobjects,				
										ISNULL(A.nombre_sysobjects, ''1'') AS is_deleted
								FROM (	SELECT t.Id_Union AS ID,
												t.NombreTabla_O_Vista AS nombre_metadatos,
												t.Tipo AS Tipo,
												t.Esquema AS esquema,
												o.name AS nombre_sysobjects
										FROM (	SELECT * 
												FROM [MoovaFleetProd_BackUp10012025].dba.Metadatos_Campos
												WHERE Tipo IN (''Tabla'', ''Vista'') 
												AND BaseDeDatos = DB_NAME()) AS t
										LEFT JOIN sys.objects o 
											ON t.NombreTabla_O_Vista = o.name COLLATE SQL_Latin1_General_CP1_CI_AS) AS A ) AS B
						WHERE B.is_deleted = ''1''
						ORDER BY B.ID
						OFFSET @COUNTERAID ROWS FETCH NEXT 1 ROWS ONLY

						--Borro todos los registros asociados a esa tabla o vista incluidos sus campos
						DELETE FROM [MoovaFleetProd_BackUp10012025].dba.Metadatos_Campos
						WHERE ( Id_Union = @TableOrViewID)

						--Aumentamos el contador del bucle para que siga iterando
						SET @COUNTERAID = @COUNTERAID + 1

			--cerramos bucle y condicional
					END
			END
		END'
END
