
ALTER PROC [dba].[SP_ActualizacionMetadatosCampos_Nuevas]
AS
BEGIN
EXEC [dba].sp_MSforeachdbMax N'
	IF ''?''!=''tempdb''
	BEGIN
		USE [?]

		--Seleccion a nivel objeto (tabla y vista) de registros nuevos, guardado de la cantidad de los mismos en la variable @objects_quantity
		DECLARE @objects_quantity INT= 0;

		SELECT @objects_quantity=COUNT(B.is_new)
		FROM (	SELECT	*,
						ISNULL(A.nombre_metadatos, ''1'') AS is_new
				FROM (	SELECT	t.IdUniversal AS ID,
								t.NombreTabla_O_Vista AS nombre_metadatos,
								t.Tipo AS Tipo,
								o.name AS nombre_sysobjects
						FROM (	SELECT	* 
								FROM [MoovaFleetProd_BackUp10012025].dba.Metadatos_Campos
								WHERE Tipo IN (''Tabla'', ''Vista'') 
								AND BaseDeDatos = DB_NAME()) AS t
						RIGHT JOIN sys.objects o    --right join tambien debe quedarse solo con los objetos tipo tabla o tipo vista
							ON t.NombreTabla_O_Vista = o.name COLLATE SQL_Latin1_General_CP1_CI_AS 
						WHERE (o.type IN (''U'', ''V''))) AS A) AS B
		WHERE B.is_new = ''1''
    

		--Condicional si detectan filas a insertar
		IF @objects_quantity<>0
			BEGIN
				DECLARE @COUNTERAID INT = 0
				DECLARE @TableOrViewName VARCHAR(100)
				DECLARE @FromSchema VARCHAR(100)
				DECLARE @FromDDBB VARCHAR(100)
				DECLARE @Type VARCHAR(50)

		--Ejecuta mientras contador<cantidad
				WHILE @COUNTERAID<@objects_quantity
					BEGIN	
					
						--TOMAMOS COMO LAS VARIABLES SUS CORRESPONDIENTES VALORES 
						SELECT  @TableOrViewName = B.nombre_sysobjects,
								@FromSchema = B.esquema,
								@FromDDBB = B.ddbb,
								@Type =B.Tipo								
						FROM (	SELECT	A.ID,
										A.nombre_sysobjects,
										A.ddbb,
										A.Tipo,
										A.esquema,
										ISNULL(A.nombre_metadatos, ''1'') AS is_new
								FROM (	SELECT	t.IdUniversal AS ID,
												DB_NAME() AS ddbb,
												t.NombreTabla_O_Vista AS nombre_metadatos,
												o.type AS Tipo,
												s.name AS esquema,
												o.name AS nombre_sysobjects
										FROM (	SELECT	* 
												FROM [MoovaFleetProd_BackUp10012025].dba.Metadatos_Campos
												WHERE Tipo IN (''Tabla'', ''Vista'') 
												AND BaseDeDatos = DB_NAME()) AS t
										RIGHT JOIN sys.objects o 
											ON t.NombreTabla_O_Vista = o.name COLLATE SQL_Latin1_General_CP1_CI_AS
										JOIN sys.schemas s 
											ON s.schema_id=o.schema_id
										WHERE o.type IN (''U'', ''V'')) AS A ) AS B
						WHERE B.is_new = ''1''
						ORDER BY B.ID
						OFFSET @COUNTERAID ROWS FETCH NEXT 1 ROWS ONLY

						--insertado de datos en la tabla de metadatos_campos					
						DECLARE @sql NVARCHAR(MAX)

						SET @sql = N''
						INSERT INTO [MoovaFleetProd_BackUp10012025].dba.Metadatos_Campos (Id_Union,IdUniversal, BaseDeDatos, Esquema, Tipo, NombreCampo, FechaDeCreacion, FechaDeUltimaModificacion, FechaModificacionSistema, Descripcion, NombreTabla_O_Vista)
						SELECT	CONCAT(''''MF-DES'''',''''_'''',DB_NAME(), ''''_'''', s.name, CASE WHEN o.type = ''''V'''' THEN ''''_VW_'''' ELSE ''''_'''' END, o.name) AS Id_Union,
								CONCAT(''''MF-DES'''',''''_'''',DB_NAME(), ''''_'''', s.name, CASE WHEN o.type = ''''V'''' THEN ''''_VW_'''' ELSE ''''_'''' END, o.name) AS IdUniversal,
								@FromDDBB AS BaseDeDatos,
								s.name AS Esquema,
								CASE WHEN o.type = ''''U'''' THEN ''''Tabla'''' ELSE ''''Vista'''' END AS Tipo,
								CAST(''''-'''' AS NVARCHAR(128)) AS NombreCampo,
								GETDATE() AS FechaDeCreacion,
								GETDATE() AS FechaDeUltimaModificacion,
								o.modify_date AS FechaModificacionSistema,
								CASE WHEN o.type = ''''U'''' THEN ''''Descripcion Tabla'''' ELSE ''''Descripcion Vista'''' END AS Descripcion,
								o.name AS NombreTabla_O_Vista
						FROM '' + QUOTENAME(@FromDDBB) + ''.sys.objects o
						JOIN '' + QUOTENAME(@FromDDBB) + ''.sys.schemas s ON o.schema_id = s.schema_id
						WHERE o.name = @TableOrViewName AND o.type = @Type AND s.name = @FromSchema
						UNION
						SELECT
							CONCAT(''''MF-DES'''',''''_'''',DB_NAME(),''''_'''',s.name, CASE WHEN o.type = ''''V'''' THEN ''''_VW_'''' ELSE ''''_'''' END, o.name) AS Id_Union,
							CONCAT(''''MF-DES'''',''''_'''',DB_NAME(),''''_'''',s.name,CASE WHEN o.type = ''''V'''' THEN ''''_VW_'''' ELSE ''''_'''' END, o.name,''''_'''',CASE WHEN o.type = ''''U'''' THEN ''''Campo tabla'''' ELSE ''''Campo vista'''' END,''''_'''',i.name) AS IdUniversal,
							@FromDDBB AS BaseDeDatos,
							s.name AS Esquema,
							CASE WHEN o.type = ''''U'''' THEN ''''Campo tabla'''' ELSE ''''Campo vista'''' END AS Tipo,
							i.name AS NombreCampo,
							GETDATE() AS FechaDeCreacion,
							GETDATE() AS FechaDeUltimaModificacion,
							NULL AS FechaModificacionSistema,
							''''Descripcion de campo'''' AS Descripcion,
							o.name  as NombreTabla_O_Vista
						FROM '' + QUOTENAME(@FromDDBB) + ''.sys.objects o
						JOIN '' + QUOTENAME(@FromDDBB) + ''.sys.schemas s ON o.schema_id = s.schema_id
						LEFT JOIN '' + QUOTENAME(@FromDDBB) + ''.sys.all_columns i ON o.object_id=i.object_id
						WHERE o.name = @TableOrViewName AND o.type = @Type AND s.name = @FromSchema;'';
						-- Ejecutar la consulta dinámica
						EXEC sp_executesql @sql, 
							N''@FromDDBB VARCHAR(100), @TableOrViewName VARCHAR(100), @Type VARCHAR(50), @FromSchema VARCHAR(100)'',
							@FromDDBB, @TableOrViewName, @Type, @FromSchema;
				
						--aumentamos el contador del bucle
						SET @COUNTERAID = @COUNTERAID + 1
			
					END --cerramos bucle 
			END --cerramos condicional
	END'
END


