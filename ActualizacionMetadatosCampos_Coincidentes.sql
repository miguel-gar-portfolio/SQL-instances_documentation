
ALTER PROC [dba].[SP_ActualizacionMetadatosCampos_Coincidentes]
AS
BEGIN
EXEC [dba].sp_MSforeachdbMax N'
	IF ''?''!=''tempdb''
	BEGIN
		USE [?]

		--Declara variable con la cantidad de elementos modificados
		DECLARE @objects_quantity INT =0


		SELECT	@objects_quantity= COUNT(A.name)
		FROM (	SELECT	t.NombreTabla_O_Vista,
						t.FechaDeUltimaModificacion,
						t.Esquema,
						t.BaseDeDatos,
						o.name,
						CASE WHEN o.type = ''U'' THEN ''Tabla'' ELSE ''Vista'' END AS Tipo,
						o.modify_date,
						CASE WHEN o.modify_date <= t.FechaDeUltimaModificacion THEN 1 ELSE 0 END AS CompararFechas
				FROM(	SELECT	* 
						FROM [MoovaFleetProd_BackUp10012025].dba.Metadatos_Campos
						WHERE Tipo IN (''Tabla'', ''Vista'')) AS t
		JOIN sys.objects o 
			ON t.NombreTabla_O_Vista = o.name COLLATE SQL_Latin1_General_CP1_CI_AS) AS A
		WHERE A.CompararFechas = 0

		--entra en el condicional solo si hay objetos a modificar
		IF @objects_quantity<>0
			BEGIN
				DECLARE @COUNTERAID INT = 0
				DECLARE @TableOrViewName NVARCHAR(100)
				DECLARE @FromSchema NVARCHAR(100)
				DECLARE @FromDDBB NVARCHAR(100)
				DECLARE @Type NVARCHAR(50)
				DECLARE @CreationDate DATETIME
				DECLARE @SysModificationDate DATETIME
				DECLARE @ObjectId INT
				DECLARE @TableOrViewUniversalID NVARCHAR(500)
		
		--Ejecuta mientras contador<cantidad
				WHILE @COUNTERAID<@objects_quantity
					BEGIN
						
						--TOMAMOS COMO LAS VARIABLES SUS CORRESPONDIENTES VALORES 
						SELECT	@TableOrViewName = A.Nombre,
								@FromSchema = A.esquema,
								@FromDDBB = A.ddbb,
								@CreationDate = A.fechacreacion,
								@SysModificationDate = A.fechamodificacionsistema
								@Type = A.Tipo,
								@ObjectId=A.ID,
								@TableOrViewUniversalID = A.IdUni
						FROM (	SELECT	t.NombreTabla_O_Vista,
										t.FechaDeUltimaModificacion,
										t.Esquema AS esquema,
										t.BaseDeDatos AS ddbb,
										t.FechaDeCreacion AS fechacreacion,
										t.IdUniversal AS IdUni
										o.modify_date AS fechamodificacionsistema,
										o.object_id AS ID,
										o.name AS Nombre,
										t.Tipo AS Tipo,
										CASE WHEN o.modify_date <= t.FechaDeUltimaModificacion THEN 1 ELSE 0 END AS CompararFechas
								FROM(	SELECT * 
										FROM [MoovaFleetProd_BackUp10012025].dba.Metadatos_Campos
										WHERE Tipo IN (''Tabla'', ''Vista'')) AS t
								JOIN sys.objects o 
									ON t.NombreTabla_O_Vista = o.name COLLATE SQL_Latin1_General_CP1_CI_AS) AS A
						WHERE A.CompararFechas = 0
						ORDER BY A.Nombre
						OFFSET @COUNTERAID ROWS FETCH NEXT 1 ROWS ONLY


						--primero vemos si hay campos nuevos y guardamos la cantidad de campos nuevos en @NewFields_quantity		
						DECLARE @NewFields_quantity INT	= 0			

						SELECT @NewFields_quantity = COUNT(is_new) 
						FROM(	SELECT	i.name,
										ISNULL(A.NombreTabla_O_Vista,''1'') AS is_new 
								FROM(	SELECT	t.NombreTabla_O_Vista,
												t.NombreCampo,
												t.esquema,
												o.name,
												o.object_id
										FROM [MoovaFleetProd_BackUp10012025].dba.Metadatos_Campos t
										JOIN sys.objects o 
											ON  o.name = t.NombreTabla_O_Vista
										WHERE (t.Tipo = CASE WHEN @Type =''Tabla'' THEN ''Campo tabla'' ELSE ''Campo vista'' END) 
										AND (t.NombreTabla_O_Vista = @TableOrViewName) AND(t.esquema = @FromSchema)) AS A
								RIGHT JOIN sys.all_columns i 
									ON A.NombreCampo = i.name
								WHERE i.object_id=@ObjectId ) AS B
						WHERE B.is_new=''1''
						
						--si hay campos nuevos entramos para el bucle
						IF @NewFields_quantity<>0
							BEGIN
								DECLARE @COUNTERAID2 INT = 0
								 
								--iniciamos el bucle para insertado de campos nuevos
								WHILE @COUNTERAID2<@objects_quantity
									BEGIN

										--obtencion del nombre del campo
										SELECT  @colName = B.name
										FROM(	SELECT	i.name,
														ISNULL(A.NombreTabla_O_Vista,''1'') AS is_new 
												FROM (	SELECT  t.NombreTabla_O_Vista,
																t.NombreCampo,
																t.esquema,
																o.name,
																o.object_id
														FROM [MoovaFleetProd_BackUp10012025].dba.Metadatos_Campos t
														JOIN sys.objects o 
															ON  o.name = t.NombreTabla_O_Vista
														WHERE (t.Tipo = CASE WHEN @Type =''Tabla'' THEN ''Campo tabla'' ELSE ''Campo vista'' END) 
														AND (t.NombreTabla_O_Vista = @TableOrViewName) AND(t.esquema = @FromSchema)) AS A
												RIGHT JOIN sys.all_columns i ON A.NombreCampo = i.name
												WHERE i.object_id=@ObjectId ) AS B
										WHERE B.is_new=''1''
										ORDER BY B.name
										OFFSET @COUNTERAID2 ROWS FETCH NEXT 1 ROWS ONLY


										--insertado de nuevo campo
										DECLARE @sql NVARCHAR(MAX)

										SET @sql = N''
										INSERT INTO [MoovaFleetProd_BackUp10012025].dba.Metadatos_Campos (Id_Union,IdUniversal, BaseDeDatos, Esquema, Tipo, NombreCampo, FechaDeCreacion, FechaDeUltimaModificacion, FechaModificacionSistema, Descripcion, NombreTabla_O_Vista)
										SELECT
											CONCAT(''''MF-DES'''',''''_'''',DB_NAME(),''''_'''',s.name, CASE WHEN @Type = ''''Vista'''' THEN ''''_VW_'''' ELSE ''''_'''' END,o.name) AS Id_Union,
											CONCAT(''''MF-DES'''',''''_'''',DB_NAME(),''''_'''',s.name,CASE WHEN @Type = ''''Vista'''' THEN ''''_VW_'''' ELSE ''''_'''' END,o.name,''''_'''',CASE WHEN @Type = ''''Tabla'''' THEN ''''Campo tabla'''' ELSE ''''Campo vista'''' END,''''_'''',@colName) AS IdUniversal,
											@FromDDBB AS BaseDeDatos,
											s.name AS Esquema,
											CASE WHEN o.type = ''''U'''' THEN ''''Campo tabla'''' ELSE ''''Campo vista'''' END AS Tipo,
											@colName AS NombreCampo,
											@CreationDate AS FechaDeCreacion,
											GETDATE() AS FechaDeUltimaModificacion,
											NULL AS FechaModificacionSistema,
											''''Descripcion de campo'''' AS Descripcion,
											o.name  as NombreTabla_O_Vista
										FROM '' + QUOTENAME(@FromDDBB) + ''.sys.objects o
										JOIN '' + QUOTENAME(@FromDDBB) + ''.sys.schemas s ON o.schema_id = s.schema_id
										WHERE (o.object_id=@ObjectId);'';
										-- Ejecutar la consulta dinámica
										EXEC sp_executesql @sql, 
											N''@FromDDBB VARCHAR(100), @TableOrViewName VARCHAR(100), @Type VARCHAR(50), @CreationDate DATETIME,@ObjectId INT,@colName NVARCHAR(150)'',
											@FromDDBB, @TableOrViewName, @Type, @CreationDate,@ObjectId,@colName;

										--	aumentamos el contador para que en la siguiente vuelta incluya el siguiente campo 
										SET @COUNTERAID2 = @COUNTERAID2 + 1
									
									END --cierro bucle de insertado de campos nuevos

								--acutalizar campos de ultimas modificaciones a nivel objeto (tabla o vista)
								UPDATE [MoovaFleetProd_BackUp10012025].dba.Metadatos_Campos
								SET FechaDeUltimaModificacion = GETDATE(),
									FechaModificacionSistema = @SysModificationDate
								WHERE IdUniversal = @TableOrViewUniversalID;


							END--cierro condicional 
						
						--vemos si hay campos que se han borrado y almacenamos la cantidad en la variable @Deleted_quantity
						DECLARE @deleted_quantity INT
					
						SELECT	@deleted_quantity=COUNT(*)
						FROM(	SELECT	i.name,
										A.NombreCampo,
										ISNULL(i.name,''1'') AS is_deleted 
								FROM (	SELECT	t.NombreTabla_O_Vista,
												t.NombreCampo,
												t.esquema,
												o.name,
												o.object_id
										FROM [MoovaFleetProd_BackUp10012025].dba.Metadatos_Campos t
										JOIN sys.objects o 
											ON  o.name = t.NombreTabla_O_Vista
										WHERE (t.Tipo = CASE WHEN @Type =''Tabla'' THEN ''Campo tabla'' ELSE ''Campo vista'' END) 
										AND (t.NombreTabla_O_Vista = @TableOrViewName) AND(t.esquema = @FromSchema)) AS A
								LEFT JOIN sys.all_columns i 
									ON A.NombreCampo = i.name) AS B
						WHERE B.is_deleted =''1''
						
						--si hay campos a eliminar entra en el condicional
						IF @deleted_quantity<>0
							BEGIN
								DECLARE @COUNTERAID3 INT = 0
								 
								--iniciamos el bucle para eliminacion de campos inexistentes
								WHILE @COUNTERAID3<@deleted_quantity
									BEGIN
								
										--almacenamiento del id del campo en la variable 
										DECLARE @colID NVARCHAR(150)
				
										SELECT	@colID = B.ID
										FROM(	SELECT	i.name,
														A.NombreCampo,
														A.ID,
														ISNULL(i.name,''1'') AS is_deleted 
												FROM(	SELECT	t.NombreTabla_O_Vista,
																t.NombreCampo,
																t.esquema,
																t.IdUniversal AS ID,
																o.name,
																o.object_id
														FROM [MoovaFleetProd_BackUp10012025].dba.Metadatos_Campos t
														JOIN sys.objects o 
															ON  o.name = t.NombreTabla_O_Vista
														WHERE (t.Tipo = CASE WHEN @Type =''Tabla'' THEN ''Campo tabla'' ELSE ''Campo vista'' END) AND (t.NombreTabla_O_Vista = @TableOrViewName) AND(t.esquema = @FromSchema)) AS A
												LEFT JOIN sys.all_columns i ON A.NombreCampo = i.name) AS B
										WHERE B.is_deleted =''1''
										ORDER BY B.ID 
										OFFSET @COUNTERAID3 ROWS FETCH NEXT 1 ROWS ONLY


										--Eliminacion de la fila a traves del id universal 
										DELETE FROM [MoovaFleetProd_BackUp10012025].dba.Metadatos_Campos
										WHERE IdUniversal = @colID

										--aumentamos el contador para la siguiente vuelta del while 
										SET @COUNTERAID3 = @COUNTERAID3 + 1

									END --cerramos el bucle 
							
								--acutalizar campos de ultimas modificaciones a nivel objeto (tabla o vista)
								UPDATE [MoovaFleetProd_BackUp10012025].dba.Metadatos_Campos
								SET FechaDeUltimaModificacion = GETDATE(),
									FechaModificacionSistema = @SysModificationDate
								WHERE IdUniversal = @TableOrViewUniversalID;
							
							
							END --cerramos el condicional


					SET @COUNTERAID = @COUNTERAID +1 --aumentamos el contador del bucle de objeto

					END --cerramos bucle a nivel objeto
	
			END--cerramos condicional a nivel objeto 
	END'
END

