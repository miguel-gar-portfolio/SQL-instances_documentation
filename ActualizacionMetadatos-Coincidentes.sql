------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------SP DE COINCIDENTES--------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------


ALTER PROCEDURE [dba].[SP_ActualizacionMetadatos_Coincidentes]
AS 
BEGIN

------------------------ACTUALIZACION JOB---------------------------------

DECLARE @objects_quantity INT= 0;

SELECT @objects_quantity=COUNT(B.is_modified)
FROM (	SELECT	m.IdUniversal,
				A.Id,
				CASE WHEN fechamodificacion>m.FechaUltimaModificacion THEN 1 ELSE 0 END AS is_modified
		FROM (	SELECT *
				FROM [MoovaFleetProd_ProdBK].dba.Metadatos
				WHERE TipoDeObjeto='Job' ) AS m
		INNER JOIN  (	SELECT	CONCAT('MF-DES', '_', 'JB','_',j.name) AS id,		 
								j.name AS nombrejob,
								STUFF((SELECT ', '+'P'+CAST(js.step_id AS VARCHAR(10))+': '+js.step_name+' - COMMAND: '+js.command
																	FROM msdb.dbo.sysjobsteps js
																	WHERE js.job_id = j.job_id
																	ORDER BY js.step_id
																	FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS Contenido,
								j.description AS descripcion,
								j.date_modified AS fechamodificacion
						FROM  msdb.dbo.sysjobs j) AS A
			ON A.id=m.IdUniversal COLLATE SQL_Latin1_General_CP1_CI_AS) AS B 
WHERE B.is_modified = 1						

IF @objects_quantity<>0
	BEGIN
		DECLARE @COUNTERAID INT = 0

		--Ejecuta mientras contador<cantidad
		WHILE @COUNTERAID<@objects_quantity
			BEGIN	
				DECLARE @ID NVARCHAR(100)
				DECLARE @Contenido NVARCHAR(MAX)
				DECLARE @Descripcion NVARCHAR(MAX)
				
				--TOMAMOS COMO LAS VARIABLES SUS CORRESPONDIENTES VALORES 
				SELECT	@ID = B.IdUniversal,
						@Contenido = Contenido,
						@Descripcion = descripcion
				FROM (	SELECT	m.IdUniversal,
								A.Id,
								CASE WHEN fechamodificacion>m.FechaUltimaModificacion THEN 1 ELSE 0 END AS is_modified,
								A.Contenido,
								A.descripcion
						FROM (	SELECT *
								FROM [MoovaFleetProd_ProdBK].dba.Metadatos
								WHERE TipoDeObjeto='Job' ) AS m
						INNER JOIN  (	SELECT	CONCAT('MF-DES', '_', 'JB','_',j.name) AS id,		 
												j.name AS nombrejob,
												STUFF((SELECT ', '+'P'+CAST(js.step_id AS VARCHAR(10))+': '+js.step_name+' - COMMAND: '+js.command
																					FROM msdb.dbo.sysjobsteps js
																					WHERE js.job_id = j.job_id
																					ORDER BY js.step_id
																					FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS Contenido,
												j.description AS descripcion,
												j.date_modified AS fechamodificacion
										FROM  msdb.dbo.sysjobs j) AS A
							ON A.id=m.IdUniversal COLLATE SQL_Latin1_General_CP1_CI_AS) AS B 
				WHERE B.is_modified = 1
				ORDER BY B.IdUniversal
				OFFSET @COUNTERAID ROWS FETCH NEXT 1 ROWS ONLY

				--Actualizo el registro asociado al job en fecha de ultima modificacion y en su contenido 
				UPDATE [MoovaFleetProd_ProdBK].dba.Metadatos
				SET FechaUltimaModificacion = GETDATE(), Contenido=@Contenido, Descripcion=@Descripcion
				WHERE IdUniversal=@ID

				--Aumentamos el contador del bucle para que siga iterando
				SET @COUNTERAID = @COUNTERAID + 1

	--cerramos bucle y condicional
			END
	END

------------------------ACTUALIZACION FUNCTIONS---------------------------------

EXEC dba.SP_MSforeachdbMax N'
IF ''?''!=''tempdb''
	BEGIN
	USE [?];

	DECLARE @objects_quantity INT= 0;

	SELECT @objects_quantity=COUNT(B.is_modified)
	FROM (	SELECT	m.IdUniversal,
					A.Id,
					CASE WHEN fechamodificacion>m.FechaUltimaModificacion THEN 1 ELSE 0 END AS is_modified
			FROM (	SELECT *
					FROM [MoovaFleetProd_ProdBK].dba.Metadatos
					WHERE TipoDeObjeto=''Funcion'' AND BaseDeDatos=DB_NAME() ) AS m
			INNER JOIN  (	SELECT	CONCAT(''MF-DES'',''_'', DB_NAME(), ''_'', s.name,''_'',''FN'',''_'',o.name) AS id,		 
									DB_NAME() AS ddbb,
									s.name AS esquema,
									o.name AS nombrefun,
									''Tipo: ''+o.type+''   Codigo:''+m.definition  COLLATE SQL_Latin1_General_CP1_CI_AS AS Contenido,
									o.modify_date AS fechamodificacion
							FROM  sys.objects o
							INNER JOIN sys.schemas s 
								ON o.schema_id = s.schema_id
							INNER JOIN sys.sql_modules m 
								ON o.object_id = m.object_id
							WHERE o.type IN (''FN'', ''IF'', ''TF'')) AS A
				ON A.id=m.IdUniversal COLLATE SQL_Latin1_General_CP1_CI_AS ) AS B 
	WHERE B.is_modified = 1





	IF @objects_quantity<>0
		BEGIN
			DECLARE @COUNTERAID INT = 0

			--Ejecuta mientras contador<cantidad
			WHILE @COUNTERAID<@objects_quantity
				BEGIN	
					DECLARE @ID NVARCHAR(100)
					DECLARE @Contenido NVARCHAR(MAX)
				
					--TOMAMOS COMO LAS VARIABLES SUS CORRESPONDIENTES VALORES 
					SELECT	@ID = B.IdUniversal,
							@Contenido = Contenido
					FROM (	SELECT	m.IdUniversal,
									A.Id,
									CASE WHEN fechamodificacion>m.FechaUltimaModificacion THEN 1 ELSE 0 END AS is_modified,
									A.Contenido
							FROM (	SELECT *
									FROM [MoovaFleetProd_ProdBK].dba.Metadatos
									WHERE TipoDeObjeto=''Funcion'' AND BaseDeDatos=DB_NAME() ) AS m
							INNER JOIN  (	SELECT	CONCAT(''MF-DES'',''_'', DB_NAME(), ''_'', s.name,''_'',''FN'',''_'',o.name) AS id,		 
													DB_NAME() AS ddbb,
													s.name AS esquema,
													o.name AS nombrefun,
													''Tipo: ''+o.type+''   Codigo:''+m.definition  COLLATE SQL_Latin1_General_CP1_CI_AS AS Contenido,
													o.modify_date AS fechamodificacion
											FROM  sys.objects o
											INNER JOIN sys.schemas s 
												ON o.schema_id = s.schema_id
											INNER JOIN sys.sql_modules m 
												ON o.object_id = m.object_id
											WHERE o.type IN (''FN'', ''IF'', ''TF'')) AS A
								ON A.id=m.IdUniversal COLLATE SQL_Latin1_General_CP1_CI_AS) AS B 
					WHERE B.is_modified = 1
					ORDER BY B.IdUniversal
					OFFSET @COUNTERAID ROWS FETCH NEXT 1 ROWS ONLY

					--Actualizo el registro asociado a la function en fecha de ultima modificacion y en su contenido 
					UPDATE [MoovaFleetProd_ProdBK].dba.Metadatos
					SET FechaUltimaModificacion = GETDATE(), Contenido=@Contenido
					WHERE IdUniversal=@ID

					--Aumentamos el contador del bucle para que siga iterando
					SET @COUNTERAID = @COUNTERAID + 1

		--cerramos bucle y condicional
				END
		END
	END'

------------------------ACTUALIZACION  VIEWS---------------------------------

EXEC dba.SP_MSforeachdbMax N'
IF ''?''!=''tempdb''
	BEGIN
	USE [?];

	DECLARE @objects_quantity INT= 0;

	SELECT @objects_quantity=COUNT(B.is_modified)
	FROM (	SELECT	m.IdUniversal,
					A.Id,
					CASE WHEN fechamodificacion>m.FechaUltimaModificacion THEN 1 ELSE 0 END AS is_modified
			FROM (	SELECT *
					FROM [MoovaFleetProd_ProdBK].dba.Metadatos
					WHERE TipoDeObjeto=''Vista'' AND BaseDeDatos=DB_NAME() ) AS m
			INNER JOIN  (	SELECT	CONCAT(''MF-DES'',''_'', DB_NAME(), ''_'', s.name,''_'',''VW'',''_'',v.name) AS id,		 
									DB_NAME() AS ddbb,
									s.name AS esquema,
									v.name AS nombreview, 
									m.definition AS Contenido,
									v.modify_date AS fechamodificacion
							FROM  sys.views v
							INNER JOIN sys.schemas s 
								ON v.schema_id = s.schema_id
							LEFT JOIN sys.sql_modules m 
								ON m.object_id =v.object_id) AS A
				ON A.id=m.IdUniversal COLLATE SQL_Latin1_General_CP1_CI_AS) AS B 
	WHERE B.is_modified = 1

	IF @objects_quantity<>0
		BEGIN
			DECLARE @COUNTERAID INT = 0

			--Ejecuta mientras contador<cantidad
			WHILE @COUNTERAID<@objects_quantity
				BEGIN	
					DECLARE @ID NVARCHAR(100)
					DECLARE @Contenido NVARCHAR(MAX)
				
					--TOMAMOS COMO LAS VARIABLES SUS CORRESPONDIENTES VALORES 
					SELECT	@ID = B.IdUniversal,
							@Contenido = Contenido
					FROM (	SELECT	m.IdUniversal,
									A.Id,
									CASE WHEN fechamodificacion>m.FechaUltimaModificacion THEN 1 ELSE 0 END AS is_modified,
									A.Contenido
							FROM (	SELECT *
									FROM [MoovaFleetProd_ProdBK].dba.Metadatos
									WHERE TipoDeObjeto=''Vista'' AND BaseDeDatos=DB_NAME() ) AS m
							INNER JOIN  (	SELECT	CONCAT(''MF-DES'',''_'', DB_NAME(), ''_'', s.name,''_'',''VW'',''_'',v.name) AS id,		 
													DB_NAME() AS ddbb,
													s.name AS esquema,
													v.name AS nombreview, 
													m.definition AS Contenido,
													v.modify_date AS fechamodificacion
											FROM  sys.views v
											INNER JOIN sys.schemas s 
												ON v.schema_id = s.schema_id
											LEFT JOIN sys.sql_modules m 
												ON m.object_id =v.object_id) AS A
								ON A.id=m.IdUniversal COLLATE SQL_Latin1_General_CP1_CI_AS) AS B 
					WHERE B.is_modified = 1
					ORDER BY B.IdUniversal
					OFFSET @COUNTERAID ROWS FETCH NEXT 1 ROWS ONLY

					--Actualizo el registro asociado a la  view en fecha de ultima modificacion y en su contenido 
					UPDATE [MoovaFleetProd_ProdBK].dba.Metadatos
					SET FechaUltimaModificacion = GETDATE(), Contenido=@Contenido
					WHERE IdUniversal=@ID

					--Aumentamos el contador del bucle para que siga iterando
					SET @COUNTERAID = @COUNTERAID + 1

		--cerramos bucle y condicional
				END
		END
	END'

------------------------ACTUALIZACION TABLES---------------------------------

EXEC dba.SP_MSforeachdbMax N'
IF ''?''!=''tempdb''
	BEGIN
	USE [?];
	DECLARE @objects_quantity INT= 0;

	SELECT @objects_quantity=COUNT(B.is_modified)
	FROM (	SELECT	m.IdUniversal,
					A.Id,
					CASE WHEN fechamodificacion>m.FechaUltimaModificacion THEN 1 ELSE 0 END AS is_modified
			FROM (	SELECT *
					FROM [MoovaFleetProd_ProdBK].dba.Metadatos
					WHERE TipoDeObjeto=''Tabla'' AND BaseDeDatos=DB_NAME() ) AS m
			INNER JOIN  (	SELECT	CONCAT(''MF-DES'',''_'', DB_NAME(), ''_'', s.name,''_'',t.name) AS id,		 
									DB_NAME() AS ddbb,
									s.name AS esquema,
									t.name AS nombretable, 
									(SELECT STRING_AGG(COLUMN_NAME, '','') AS Resultado FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME=t.name) AS Contenido,
									t.modify_date AS fechamodificacion
							FROM  sys.tables t
							INNER JOIN sys.schemas s 
								ON t.schema_id = s.schema_id) AS A
				ON A.id=m.IdUniversal COLLATE SQL_Latin1_General_CP1_CI_AS) AS B 
	WHERE B.is_modified = 1
						

	IF @objects_quantity<>0
		BEGIN
			DECLARE @COUNTERAID INT = 0

			--Ejecuta mientras contador<cantidad
			WHILE @COUNTERAID<@objects_quantity
				BEGIN	
					DECLARE @ID NVARCHAR(100)
					DECLARE @Contenido NVARCHAR(MAX)
				
					--TOMAMOS COMO LAS VARIABLES SUS CORRESPONDIENTES VALORES 
					SELECT	@ID = B.IdUniversal,
							@Contenido = Contenido
					FROM (	SELECT	m.IdUniversal,
									A.Id,
									CASE WHEN fechamodificacion>m.FechaUltimaModificacion THEN 1 ELSE 0 END AS is_modified,
									A.Contenido
							FROM (	SELECT *
									FROM [MoovaFleetProd_ProdBK].dba.Metadatos
									WHERE TipoDeObjeto=''Tabla'' AND BaseDeDatos=DB_NAME() ) AS m
							INNER JOIN  (	SELECT	CONCAT(''MF-DES'',''_'', DB_NAME(), ''_'', s.name,''_'',t.name) AS id,		 
													DB_NAME() AS ddbb,
													s.name AS esquema,
													t.name AS nombretable, 
													(SELECT STRING_AGG(COLUMN_NAME, '','') AS Resultado FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME=t.name) AS Contenido,
													t.modify_date AS fechamodificacion
											FROM  sys.tables t
											INNER JOIN sys.schemas s 
												ON t.schema_id = s.schema_id) AS A
								ON A.id=m.IdUniversal COLLATE SQL_Latin1_General_CP1_CI_AS) AS B 
					WHERE B.is_modified = 1
					ORDER BY B.IdUniversal
					OFFSET @COUNTERAID ROWS FETCH NEXT 1 ROWS ONLY

					--Actualizo el registro asociado a la  table en fecha de ultima modificacion y en su contenido 
					UPDATE [MoovaFleetProd_ProdBK].dba.Metadatos
					SET FechaUltimaModificacion = GETDATE(), Contenido=@Contenido
					WHERE IdUniversal=@ID

					--Aumentamos el contador del bucle para que siga iterando
					SET @COUNTERAID = @COUNTERAID + 1

		--cerramos bucle y condicional
				END
		END
	END'

 ------------------------ACTUALIZACION TRIGGERS---------------------------------

EXEC dba.SP_MSforeachdbMax N'
IF ''?''!=''tempdb''
	BEGIN
	USE [?];


	DECLARE @objects_quantity INT= 0;

	SELECT @objects_quantity=COUNT(B.is_modified)
	FROM (	SELECT	m.IdUniversal,
					A.Id,
					CASE WHEN fechamodificacion>m.FechaUltimaModificacion THEN 1 ELSE 0 END AS is_modified
			FROM (	SELECT *
					FROM [MoovaFleetProd_ProdBK].dba.Metadatos
					WHERE TipoDeObjeto=''Trigger'' AND BaseDeDatos=DB_NAME() ) AS m
			INNER JOIN  (	SELECT	CONCAT(''MF-DES'',''_'', DB_NAME(), ''_'', s.name,''_'',''TR'',''_'',t.name) AS id,		 
									DB_NAME() AS ddbb,
									s.name AS esquema,
									t.name AS nombretabla, 
									''Tabla: ''+o.name+'' - Estado: Activado - Contenido: ''+OBJECT_DEFINITION(t.object_id) AS Contenido,
									t.modify_date AS fechamodificacion
							FROM  sys.triggers t
							INNER JOIN sys.objects o 
								ON t.parent_id = o.object_id
							INNER JOIN sys.schemas s 
								ON o.schema_id = s.schema_id
							WHERE 
								t.is_ms_shipped = 0
									AND is_disabled=0) AS A
				ON A.id=m.IdUniversal COLLATE SQL_Latin1_General_CP1_CI_AS) AS B 
	WHERE B.is_modified = 1


	IF @objects_quantity<>0
		BEGIN
			DECLARE @COUNTERAID INT = 0

			--Ejecuta mientras contador<cantidad
			WHILE @COUNTERAID<@objects_quantity
				BEGIN	
					DECLARE @ID NVARCHAR(100)
					DECLARE @Contenido NVARCHAR(MAX)
				
					--TOMAMOS COMO LAS VARIABLES SUS CORRESPONDIENTES VALORES 
					SELECT	@ID = B.IdUniversal,
							@Contenido = Contenido
					FROM (	SELECT	m.IdUniversal,
									A.Id,
									CASE WHEN fechamodificacion>m.FechaUltimaModificacion THEN 1 ELSE 0 END AS is_modified,
									A.Contenido
							FROM (	SELECT *
									FROM [MoovaFleetProd_ProdBK].dba.Metadatos
									WHERE TipoDeObjeto=''Trigger'' AND BaseDeDatos=DB_NAME() ) AS m
							INNER JOIN  (	SELECT	CONCAT(''MF-DES'',''_'', DB_NAME(), ''_'', s.name,''_'',''TR'',''_'',t.name) AS id,		 
													DB_NAME() AS ddbb,
													s.name AS esquema,
													t.name AS nombretabla, 
													''Tabla: ''+o.name+'' - Estado: Activado - Contenido: ''+OBJECT_DEFINITION(t.object_id) AS Contenido,
													t.modify_date AS fechamodificacion
											FROM  sys.triggers t
											INNER JOIN sys.objects o 
												ON t.parent_id = o.object_id
											INNER JOIN sys.schemas s 
												ON o.schema_id = s.schema_id
											WHERE 
												t.is_ms_shipped = 0
													AND is_disabled=0) AS A
								ON A.id=m.IdUniversal COLLATE SQL_Latin1_General_CP1_CI_AS) AS B 
					WHERE B.is_modified = 1
					ORDER BY B.IdUniversal
					OFFSET @COUNTERAID ROWS FETCH NEXT 1 ROWS ONLY

					--Actualizo el registro asociado al trigger en fecha de ultima modificacion y en su contenido 
					UPDATE [MoovaFleetProd_ProdBK].dba.Metadatos
					SET FechaUltimaModificacion = GETDATE(), Contenido=@Contenido
					WHERE IdUniversal=@ID

					--Aumentamos el contador del bucle para que siga iterando
					SET @COUNTERAID = @COUNTERAID + 1

		--cerramos bucle y condicional
				END
		END
	END'

	------------------------ACTUALIZACION PAS---------------------------------

EXEC dba.SP_MSforeachdbMax N'
IF ''?''!=''tempdb''
	BEGIN
	USE [?];

	DECLARE @objects_quantity INT= 0;

	SELECT @objects_quantity=COUNT(B.is_modified)
	FROM (	SELECT	m.IdUniversal,
					A.Id,
					CASE WHEN fechamodificacion>m.FechaUltimaModificacion THEN 1 ELSE 0 END AS is_modified
			FROM (	SELECT *
					FROM [MoovaFleetProd_ProdBK].dba.Metadatos
					WHERE TipoDeObjeto=''Procedimiento'' AND BaseDeDatos=DB_NAME() ) AS m
			INNER JOIN  (	SELECT	CONCAT(''MF-DES'',''_'', DB_NAME(), ''_'', s.name,''_'',''USP'',''_'',p.name) AS id,		 
									DB_NAME() AS ddbb,
									s.name AS esquema,
									p.name AS nombreproc,
									m.definition AS Contenido,
									p.modify_date AS fechamodificacion
							FROM  sys.procedures p
							INNER JOIN sys.schemas s 
								ON p.schema_id = s.schema_id
							INNER JOIN sys.sql_modules m 
								ON m.object_id = p.object_id) AS A
				ON A.id=m.IdUniversal COLLATE SQL_Latin1_General_CP1_CI_AS) AS B 
	WHERE B.is_modified = 1


	IF @objects_quantity<>0
		BEGIN
			DECLARE @COUNTERAID INT = 0

			--Ejecuta mientras contador<cantidad
			WHILE @COUNTERAID<@objects_quantity
				BEGIN	
					DECLARE @ID NVARCHAR(100)
					DECLARE @Contenido NVARCHAR(MAX)
				
					--TOMAMOS COMO LAS VARIABLES SUS CORRESPONDIENTES VALORES 
					SELECT	@ID = B.IdUniversal,
							@Contenido = Contenido
					FROM (	SELECT	m.IdUniversal,
									A.Id,
									CASE WHEN fechamodificacion>m.FechaUltimaModificacion THEN 1 ELSE 0 END AS is_modified,
									A.Contenido
							FROM (	SELECT *
									FROM [MoovaFleetProd_ProdBK].dba.Metadatos
									WHERE TipoDeObjeto=''Procedimiento'' AND BaseDeDatos=DB_NAME() ) AS m
							INNER JOIN  (	SELECT	CONCAT(''MF-DES'',''_'', DB_NAME(), ''_'', s.name,''_'',''USP'',''_'',p.name) AS id,		 
													DB_NAME() AS ddbb,
													s.name AS esquema,
													p.name AS nombreproc,
													m.definition AS Contenido,
													p.modify_date AS fechamodificacion
											FROM  sys.procedures p
											INNER JOIN sys.schemas s 
												ON p.schema_id = s.schema_id
											INNER JOIN sys.sql_modules m 
												ON m.object_id = p.object_id) AS A
								ON A.id=m.IdUniversal COLLATE SQL_Latin1_General_CP1_CI_AS) AS B 
					WHERE B.is_modified = 1
					ORDER BY B.IdUniversal
					OFFSET @COUNTERAID ROWS FETCH NEXT 1 ROWS ONLY

					--Actualizo el registro asociado al PA en fecha de ultima modificacion y en su contenido 
					UPDATE [MoovaFleetProd_ProdBK].dba.Metadatos
					SET FechaUltimaModificacion = GETDATE(), Contenido=@Contenido
					WHERE IdUniversal=@ID

					--Aumentamos el contador del bucle para que siga iterando
					SET @COUNTERAID = @COUNTERAID + 1

		--cerramos bucle y condicional
				END
		END
	END'

	end
