-----------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------SP DE ELIMINACION--------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------


ALTER PROCEDURE [dba].[SP_ActualizacionMetadatos_Eliminacion] 
AS 
BEGIN 
---------------------------------ELIMINACION BASE DE DATOS----------------------------------------

--seleccion y almacenamiento de numero de registros a eliminar
DECLARE @objects_quantity INT= 0;

SELECT @objects_quantity=COUNT(B.is_deleted)
FROM (	SELECT	m.IdUniversal,
				A.Id,
				ISNULL(A.id,'1') AS is_deleted
		FROM (	SELECT *
				FROM MoovaFleetProd_ProdBK.dba.Metadatos
				WHERE TipoDeObjeto='Base de Datos') AS m
		LEFT JOIN  (	SELECT	CONCAT('MF-DES', '_', f.name) AS id,		 
								f.name AS nombreddbb							     
						FROM sys.databases f) AS A
			ON A.id=m.IdUniversal COLLATE SQL_Latin1_General_CP1_CI_AS) AS B 
WHERE B.is_deleted = '1'

--Condicional si detectan filas a eliminar
IF @objects_quantity<>0
	BEGIN
		DECLARE @COUNTERAID INT = 0

		--Ejecuta mientras contador<cantidad
		WHILE @COUNTERAID<@objects_quantity
			BEGIN	
				DECLARE @ID VARCHAR(100)
				
				--TOMAMOS COMO LAS VARIABLES SUS CORRESPONDIENTES VALORES 
				SELECT	@ID = B.IdUniversal
				FROM (	SELECT	m.IdUniversal,
								A.Id,
								ISNULL(A.id,'1') AS is_deleted
						FROM (	SELECT *
								FROM MoovaFleetProd_ProdBK.dba.Metadatos
								WHERE TipoDeObjeto='Base de Datos') AS m
						LEFT JOIN  (	SELECT	CONCAT('MF-DES', '_', f.name) AS id,		 
												f.name AS nombreddbb							     
										FROM sys.databases f) AS A
							ON A.id=m.IdUniversal COLLATE SQL_Latin1_General_CP1_CI_AS) AS B 
				WHERE B.is_deleted = '1'
				ORDER BY B.IdUniversal
				OFFSET @COUNTERAID ROWS FETCH NEXT 1 ROWS ONLY

				--Borro todos los registros asociados a db incluidos sus campos
				DELETE FROM MoovaFleetProd_ProdBK.dba.Metadatos
				WHERE IdUniversal LIKE @ID+'%' 

				--Aumentamos el contador del bucle para que siga iterando
				SET @COUNTERAID = @COUNTERAID + 1

	--cerramos bucle y condicional
			END
	END

---------------------------------ELIMINACION SCHEMAS----------------------------------------

EXEC dba.SP_MSforeachdbMax N'
IF ''?''!=''tempdb''
	BEGIN
	USE [?];
	--seleccion y almacenamiento de numero de registros a eliminar
	DECLARE @objects_quantity INT= 0;

	SELECT @objects_quantity=COUNT(B.is_deleted)
	FROM (	SELECT	m.IdUniversal,
					A.Id,
					ISNULL(A.id,''1'') AS is_deleted
			FROM (	SELECT *
					FROM MoovaFleetProd_ProdBK.dba.Metadatos
					WHERE TipoDeObjeto=''Esquema'' AND BaseDeDatos=DB_NAME() ) AS m
			LEFT JOIN  (	SELECT	CONCAT(''MF-DES'', ''_'', DB_NAME(),''_'',s.name) AS id,		 
									s.name AS nombresquema							     
							FROM  sys.schemas s
							WHERE s.schema_id<16000) AS A
				ON A.id=m.IdUniversal COLLATE SQL_Latin1_General_CP1_CI_AS) AS B 
	WHERE B.is_deleted = ''1''

	--Condicional si detectan filas a eliminar
	IF @objects_quantity<>0
		BEGIN
			DECLARE @COUNTERAID INT = 0

			--Ejecuta mientras contador<cantidad
			WHILE @COUNTERAID<@objects_quantity
				BEGIN	
					DECLARE @ID VARCHAR(100)
				
					--TOMAMOS COMO LAS VARIABLES SUS CORRESPONDIENTES VALORES 
					SELECT	@ID = B.IdUniversal
					FROM (	SELECT	m.IdUniversal,
									A.Id,
									ISNULL(A.id,''1'') AS is_deleted
							FROM (	SELECT *
									FROM MoovaFleetProd_ProdBK.dba.Metadatos
									WHERE TipoDeObjeto=''Esquema'' AND BaseDeDatos=DB_NAME() ) AS m
							LEFT JOIN  (	SELECT	CONCAT(''MF-DES'', ''_'', DB_NAME(),''_'',s.name) AS id,		 
													s.name AS nombresquema							     
											FROM  sys.schemas s
											WHERE s.schema_id<16000) AS A
								ON A.id=m.IdUniversal COLLATE SQL_Latin1_General_CP1_CI_AS) AS B 
					WHERE B.is_deleted = ''1''
					ORDER BY B.IdUniversal
					OFFSET @COUNTERAID ROWS FETCH NEXT 1 ROWS ONLY

					--Borro todos los registros asociados a este schema
					DELETE FROM MoovaFleetProd_ProdBK.dba.Metadatos
					WHERE IdUniversal LIKE @ID+''%'' 

					--Aumentamos el contador del bucle para que siga iterando
					SET @COUNTERAID = @COUNTERAID + 1

		--cerramos bucle y condicional
				END
		END
	END'


---------------------------------ELIMINACION JOB----------------------------------------

--seleccion y almacenamiento de numero de registros a eliminar
SET @objects_quantity = 0;

SELECT @objects_quantity=COUNT(B.is_deleted)
FROM (	SELECT	m.IdUniversal,
				A.Id,
				ISNULL(A.id,'1') AS is_deleted
		FROM (	SELECT *
				FROM MoovaFleetProd_ProdBK.dba.Metadatos
				WHERE TipoDeObjeto='Job' ) AS m
		LEFT JOIN  (	SELECT	CONCAT('MF-DES', '_', 'JB','_',j.name) AS id,		 
								j.name AS nombrejob 							     
						FROM  msdb.dbo.sysjobs j) AS A
			ON A.id=m.IdUniversal COLLATE SQL_Latin1_General_CP1_CI_AS) AS B 
WHERE B.is_deleted = '1'

--Condicional si detectan filas a eliminar
IF @objects_quantity<>0
	BEGIN
		SET @COUNTERAID = 0

		--Ejecuta mientras contador<cantidad
		WHILE @COUNTERAID<@objects_quantity
			BEGIN	
				SET @ID = NULL
				
				--TOMAMOS COMO LAS VARIABLES SUS CORRESPONDIENTES VALORES 
				SELECT	@ID = B.IdUniversal
				FROM (	SELECT	m.IdUniversal,
								A.Id,
								ISNULL(A.id,'1') AS is_deleted
						FROM (	SELECT *
								FROM MoovaFleetProd_ProdBK.dba.Metadatos
								WHERE TipoDeObjeto='Job' ) AS m
						LEFT JOIN  (	SELECT	CONCAT('MF-DES', '_', 'JB','_',j.name) AS id,		 
												j.name AS nombrejob 							     
										FROM  msdb.dbo.sysjobs j) AS A
							ON A.id=m.IdUniversal COLLATE SQL_Latin1_General_CP1_CI_AS) AS B 
				WHERE B.is_deleted = '1'
				ORDER BY B.IdUniversal
				OFFSET @COUNTERAID ROWS FETCH NEXT 1 ROWS ONLY

				--Borro el job a traves del id
				DELETE FROM MoovaFleetProd_ProdBK.dba.Metadatos
				WHERE ( IdUniversal = @ID)

				--Aumentamos el contador del bucle para que siga iterando
				SET @COUNTERAID = @COUNTERAID + 1

	--cerramos bucle y condicional
			END
	END


---------------------------------ELIMINACION TRIGGERS----------------------------------------

EXEC dba.SP_MSforeachdbMax N'
IF ''?''!=''tempdb''
	BEGIN
	USE [?];
	--seleccion y almacenamiento de numero de registros a eliminar
	DECLARE @objects_quantity INT= 0;

	SELECT @objects_quantity=COUNT(B.is_deleted)
	FROM (	SELECT	m.IdUniversal,
					A.Id,
					ISNULL(A.id,''1'') AS is_deleted
			FROM (	SELECT *
					FROM MoovaFleetProd_ProdBK.dba.Metadatos
					WHERE TipoDeObjeto=''Trigger'' AND BaseDeDatos=DB_NAME() ) AS m
			LEFT JOIN  (	SELECT	CONCAT(''MF-DES'',''_'', DB_NAME(), ''_'', s.name,''_'',''TR'',''_'',t.name) AS id,		 
									DB_NAME() AS ddbb,
									s.name AS esquema,
									t.name AS nombretabla
							FROM  sys.triggers t
							INNER JOIN sys.objects o 
								ON t.parent_id = o.object_id
							INNER JOIN sys.schemas s 
								ON o.schema_id = s.schema_id
							WHERE 
								t.is_ms_shipped = 0
									AND is_disabled=0) AS A
				ON A.id=m.IdUniversal COLLATE SQL_Latin1_General_CP1_CI_AS) AS B 
	WHERE B.is_deleted = ''1''

	--Condicional si detectan filas a eliminar
	IF @objects_quantity<>0
		BEGIN
			DECLARE @COUNTERAID INT = 0

			--Ejecuta mientras contador<cantidad
			WHILE @COUNTERAID<@objects_quantity
				BEGIN	
					DECLARE @ID VARCHAR(100)
				
					--TOMAMOS COMO LAS VARIABLES SUS CORRESPONDIENTES VALORES 
					SELECT	@ID = B.IdUniversal
					FROM (	SELECT	m.IdUniversal,
									A.Id,
									ISNULL(A.id,''1'') AS is_deleted
							FROM (	SELECT *
									FROM MoovaFleetProd_ProdBK.dba.Metadatos
									WHERE TipoDeObjeto=''Trigger'' 
										AND BaseDeDatos=DB_NAME() ) AS m
							LEFT JOIN  (	SELECT	CONCAT(''MF-DES'',''_'', DB_NAME(), ''_'', s.name,''_'',''TR'',''_'',t.name) AS id,		 
													DB_NAME() AS ddbb,
													s.name AS esquema,
													t.name AS nombretabla
											FROM  sys.triggers t
											INNER JOIN sys.objects o 
												ON t.parent_id = o.object_id
											INNER JOIN sys.schemas s 
												ON o.schema_id = s.schema_id
											WHERE 
												t.is_ms_shipped = 0
													AND is_disabled=0) AS A
								ON A.id=m.IdUniversal COLLATE SQL_Latin1_General_CP1_CI_AS) AS B 
					WHERE B.is_deleted = ''1''
					ORDER BY B.IdUniversal
					OFFSET @COUNTERAID ROWS FETCH NEXT 1 ROWS ONLY

					--Borro el trigger a traves de su id 
					DELETE FROM MoovaFleetProd_ProdBK.dba.Metadatos
					WHERE ( IdUniversal = @ID)

					--Aumentamos el contador del bucle para que siga iterando
					SET @COUNTERAID = @COUNTERAID + 1

		--cerramos bucle y condicional
				END
		END
	END'


---------------------------------ELIMINACION VIEWS----------------------------------------

EXEC dba.SP_MSforeachdbMax N'
IF ''?''!=''tempdb''
	BEGIN
	USE[?];
	--seleccion y almacenamiento de numero de registros a eliminar
	DECLARE @objects_quantity INT= 0;

	SELECT @objects_quantity=COUNT(B.is_deleted)
	FROM (	SELECT	m.IdUniversal,
					A.Id,
					ISNULL(A.id,''1'') AS is_deleted
			FROM (	SELECT *
					FROM MoovaFleetProd_ProdBK.dba.Metadatos
					WHERE TipoDeObjeto=''Vista'' AND BaseDeDatos=DB_NAME() ) AS m
			LEFT JOIN  (	SELECT	CONCAT(''MF-DES'',''_'', DB_NAME(), ''_'', s.name,''_'',''VW'',''_'',v.name) AS id,		 
									DB_NAME() AS ddbb,
									s.name AS esquema,
									v.name AS nombreview, 
									m.definition AS Contenido 
							FROM  sys.views v
							INNER JOIN sys.schemas s 
								ON v.schema_id = s.schema_id
							LEFT JOIN sys.sql_modules m 
								ON m.object_id =v.object_id) AS A
				ON A.id=m.IdUniversal COLLATE SQL_Latin1_General_CP1_CI_AS) AS B 
	WHERE B.is_deleted = ''1''

	--Condicional si detectan filas a eliminar
	IF @objects_quantity<>0
		BEGIN
			DECLARE @COUNTERAID INT = 0

			--Ejecuta mientras contador<cantidad
			WHILE @COUNTERAID<@objects_quantity
				BEGIN	
					DECLARE @ID VARCHAR(100)
				
					--TOMAMOS COMO LAS VARIABLES SUS CORRESPONDIENTES VALORES 
					SELECT	@ID = B.IdUniversal
					FROM (	SELECT	m.IdUniversal,
									A.Id,
									ISNULL(A.id,''1'') AS is_deleted
							FROM (	SELECT *
									FROM MoovaFleetProd_ProdBK.dba.Metadatos
									WHERE TipoDeObjeto=''Vista'' AND BaseDeDatos=DB_NAME() ) AS m
							LEFT JOIN  (	SELECT	CONCAT(''MF-DES'',''_'', DB_NAME(), ''_'', s.name,''_'',''VW'',''_'',v.name) AS id,		 
													DB_NAME() AS ddbb,
													s.name AS esquema,
													v.name AS nombreview, 
													m.definition AS Contenido 
											FROM  sys.views v
											INNER JOIN sys.schemas s 
												ON v.schema_id = s.schema_id
											LEFT JOIN sys.sql_modules m 
												ON m.object_id =v.object_id) AS A
								ON A.id=m.IdUniversal COLLATE SQL_Latin1_General_CP1_CI_AS) AS B 
					WHERE B.is_deleted = ''1''
					ORDER BY B.IdUniversal
					OFFSET @COUNTERAID ROWS FETCH NEXT 1 ROWS ONLY

					--Borro la vista a traves del id
					DELETE FROM MoovaFleetProd_ProdBK.dba.Metadatos
					WHERE ( IdUniversal = @ID)

					--Aumentamos el contador del bucle para que siga iterando
					SET @COUNTERAID = @COUNTERAID + 1

		--cerramos bucle y condicional
				END
		END
	END'

---------------------------------ELIMINACION TABLES----------------------------------------

EXEC dba.SP_MSforeachdbMax N'
IF ''?''!=''tempdb''
	BEGIN
	USE [?];
	--seleccion y almacenamiento de numero de registros a eliminar
	DECLARE @objects_quantity INT= 0;

	SELECT @objects_quantity=COUNT(B.is_deleted)
	FROM (	SELECT	m.IdUniversal,
					A.Id,
					ISNULL(A.id,''1'') AS is_deleted
			FROM (	SELECT *
					FROM MoovaFleetProd_ProdBK.dba.Metadatos
					WHERE TipoDeObjeto=''Tabla'' AND BaseDeDatos=DB_NAME() ) AS m
			LEFT JOIN  (	SELECT	CONCAT(''MF-DES'',''_'', DB_NAME(), ''_'', s.name,''_'',t.name) AS id,		 
									DB_NAME() AS ddbb,
									s.name AS esquema,
									t.name AS nombretable, 
									(SELECT STRING_AGG(COLUMN_NAME, '','') AS Resultado FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME=t.name) AS Contenido 
							FROM  sys.tables t
							INNER JOIN sys.schemas s 
								ON t.schema_id = s.schema_id) AS A
				ON A.id=m.IdUniversal COLLATE SQL_Latin1_General_CP1_CI_AS) AS B 
	WHERE B.is_deleted = ''1''

	--Condicional si detectan filas a eliminar
	IF @objects_quantity<>0
		BEGIN
			DECLARE @COUNTERAID INT = 0

			--Ejecuta mientras contador<cantidad
			WHILE @COUNTERAID<@objects_quantity
				BEGIN	
					DECLARE @ID VARCHAR(100)
				
					--TOMAMOS COMO LAS VARIABLES SUS CORRESPONDIENTES VALORES 
					SELECT	@ID = B.IdUniversal
					FROM (	SELECT	m.IdUniversal,
									A.Id,
									ISNULL(A.id,''1'') AS is_deleted
							FROM (	SELECT *
									FROM MoovaFleetProd_ProdBK.dba.Metadatos
									WHERE TipoDeObjeto=''Tabla'' AND BaseDeDatos=DB_NAME() ) AS m
							LEFT JOIN  (	SELECT	CONCAT(''MF-DES'',''_'', DB_NAME(), ''_'', s.name,''_'',t.name) AS id,		 
													DB_NAME() AS ddbb,
													s.name AS esquema,
													t.name AS nombretable, 
													(SELECT STRING_AGG(COLUMN_NAME, '','') AS Resultado FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME=t.name) AS Contenido 
											FROM  sys.tables t
											INNER JOIN sys.schemas s 
												ON t.schema_id = s.schema_id) AS A
								ON A.id=m.IdUniversal COLLATE SQL_Latin1_General_CP1_CI_AS) AS B 
					WHERE B.is_deleted = ''1''
					ORDER BY B.IdUniversal
					OFFSET @COUNTERAID ROWS FETCH NEXT 1 ROWS ONLY

					--Borro las tables a traves del ID
					DELETE FROM MoovaFleetProd_ProdBK.dba.Metadatos
					WHERE ( IdUniversal = @ID)

					--Aumentamos el contador del bucle para que siga iterando
					SET @COUNTERAID = @COUNTERAID + 1

		--cerramos bucle y condicional
				END
		END
	END'

---------------------------------ELIMINACION FUNCTIONS----------------------------------------

EXEC dba.SP_MSforeachdbMax N'
IF ''?''!=''tempdb''
	BEGIN
	USE [?];
	--seleccion y almacenamiento de numero de registros a eliminar
	DECLARE @objects_quantity INT= 0;

	SELECT @objects_quantity=COUNT(B.is_deleted)
	FROM (	SELECT	m.IdUniversal,
					A.Id,
					ISNULL(A.id,''1'') AS is_deleted
			FROM (	SELECT *
					FROM MoovaFleetProd_ProdBK.dba.Metadatos
					WHERE TipoDeObjeto=''Funcion'' AND BaseDeDatos=DB_NAME() ) AS m
			LEFT JOIN  (	SELECT	CONCAT(''MF-DES'',''_'', DB_NAME(), ''_'', s.name,''_'',''FN'',''_'',o.name) AS id,		 
									DB_NAME() AS ddbb,
									s.name AS esquema,
									o.name AS nombrefun,
									''Tipo: ''+o.type+''   Codigo:''+m.definition  COLLATE SQL_Latin1_General_CP1_CI_AS AS Contenido
							FROM  sys.objects o
							INNER JOIN sys.schemas s 
								ON o.schema_id = s.schema_id
							INNER JOIN sys.sql_modules m 
								ON o.object_id = m.object_id
							WHERE o.type IN (''FN'', ''IF'', ''TF'')) AS A
				ON A.id=m.IdUniversal COLLATE SQL_Latin1_General_CP1_CI_AS) AS B 
	WHERE B.is_deleted = ''1''

	--Condicional si detectan filas a eliminar
	IF @objects_quantity<>0
		BEGIN
			DECLARE @COUNTERAID INT = 0

			--Ejecuta mientras contador<cantidad
			WHILE @COUNTERAID<@objects_quantity
				BEGIN	
					DECLARE @ID VARCHAR(100)
				
					--TOMAMOS COMO LAS VARIABLES SUS CORRESPONDIENTES VALORES 
					SELECT	@ID = B.IdUniversal
					FROM (	SELECT	m.IdUniversal,
									A.Id,
									ISNULL(A.id,''1'') AS is_deleted
							FROM (	SELECT *
									FROM MoovaFleetProd_ProdBK.dba.Metadatos
									WHERE TipoDeObjeto=''Funcion'' AND BaseDeDatos=DB_NAME() ) AS m
							LEFT JOIN  (	SELECT	CONCAT(''MF-DES'',''_'', DB_NAME(), ''_'', s.name,''_'',''FN'',''_'',o.name) AS id,		 
													DB_NAME() AS ddbb,
													s.name AS esquema,
													o.name AS nombrefun
											FROM  sys.objects o
											INNER JOIN sys.schemas s 
												ON o.schema_id = s.schema_id
											INNER JOIN sys.sql_modules m 
												ON o.object_id = m.object_id
											WHERE o.type IN (''FN'', ''IF'', ''TF'')) AS A
								ON A.id=m.IdUniversal COLLATE SQL_Latin1_General_CP1_CI_AS) AS B 
					WHERE B.is_deleted = ''1''
					ORDER BY B.IdUniversal
					OFFSET @COUNTERAID ROWS FETCH NEXT 1 ROWS ONLY

					--Borro la function a traves del id 
					DELETE FROM MoovaFleetProd_ProdBK.dba.Metadatos
					WHERE ( IdUniversal = @ID)

					--Aumentamos el contador del bucle para que siga iterando
					SET @COUNTERAID = @COUNTERAID + 1

		--cerramos bucle y condicional
				END
		END
	END'


---------------------------------ELIMINACION PAS----------------------------------------

EXEC dba.SP_MSforeachdbMax N'
IF ''?''!=''tempdb''
	BEGIN
	USE [?];

	--seleccion y almacenamiento de numero de registros a eliminar
	DECLARE @objects_quantity INT= 0;

	SELECT @objects_quantity=COUNT(B.is_deleted)
	FROM (	SELECT	m.IdUniversal,
					A.Id,
					ISNULL(A.id,''1'') AS is_deleted
			FROM (	SELECT *
					FROM MoovaFleetProd_ProdBK.dba.Metadatos
					WHERE TipoDeObjeto=''Procedimiento'' AND BaseDeDatos=DB_NAME() ) AS m
			LEFT JOIN  (	SELECT	CONCAT(''MF-DES'',''_'', DB_NAME(), ''_'', s.name,''_'',''USP'',''_'',p.name) AS id,		 
									DB_NAME() AS ddbb,
									s.name AS esquema,
									p.name AS nombreproc, 
									m.definition AS Contenido
							FROM  sys.procedures p
							INNER JOIN sys.schemas s 
								ON p.schema_id = s.schema_id
							INNER JOIN sys.sql_modules m 
								ON m.object_id = p.object_id) AS A
				ON A.id=m.IdUniversal COLLATE SQL_Latin1_General_CP1_CI_AS) AS B 
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
					SELECT	@TableOrViewID = B.IdUniversal
					FROM (	SELECT	m.IdUniversal,
									A.Id,
									ISNULL(A.id,''1'') AS is_deleted
							FROM (	SELECT *
									FROM MoovaFleetProd_ProdBK.dba.Metadatos
									WHERE TipoDeObjeto=''Procedimiento'' AND BaseDeDatos=DB_NAME() ) AS m
							LEFT JOIN  (	SELECT	CONCAT(''MF-DES'',''_'', DB_NAME(), ''_'', s.name,''_'',''USP'',''_'',p.name) AS id,		 
													DB_NAME() AS ddbb,
													s.name AS esquema,
													p.name AS nombreproc, 
													m.definition AS Contenido
											FROM  sys.procedures p
											INNER JOIN sys.schemas s 
												ON p.schema_id = s.schema_id
											INNER JOIN sys.sql_modules m 
												ON m.object_id = p.object_id) AS A
								ON A.id=m.IdUniversal COLLATE SQL_Latin1_General_CP1_CI_AS) AS B 
					WHERE B.is_deleted = ''1''
					ORDER BY B.IdUniversal
					OFFSET @COUNTERAID ROWS FETCH NEXT 1 ROWS ONLY

					--Borro el PA a traves del id 
					DELETE FROM MoovaFleetProd_ProdBK.dba.Metadatos
					WHERE ( IdUniversal = @TableOrViewID)

					--Aumentamos el contador del bucle para que siga iterando
					SET @COUNTERAID = @COUNTERAID + 1

		--cerramos bucle y condicional
				END
		END
	END'

	END
