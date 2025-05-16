ALTER PROC [dba].[SP_ActualizacionMetadatos_Nuevas]
AS
BEGIN
--Adición de todos los objetos que no se encuentran en metadatos pero sí en el sistema

DECLARE @objects_quantity INT= 0;-- este contador nos sirve para varios procesos

---------------------------------------------------------BASES DE DATOS----------------------------------------------------------------------------------------------------------------------
		DECLARE @dblist TABLE (
		NombreBaseDeDatos VARCHAR(255)
		)
		SELECT @objects_quantity = COUNT(*)
		FROM MoovaFleetProd_ProdBK.dba.Metadatos m 
		RIGHT OUTER JOIN sys.databases d ON m.NombreDeObjeto = d.name COLLATE SQL_Latin1_General_CP1_CI_AS
		WHERE m.NombreDeObjeto IS NULL

		INSERT INTO @dblist
		SELECT d.name
		FROM MoovaFleetProd_ProdBK.dba.Metadatos m 
		RIGHT OUTER JOIN sys.databases d ON m.NombreDeObjeto = d.name COLLATE SQL_Latin1_General_CP1_CI_AS
		WHERE m.NombreDeObjeto IS NULL
		

		--Condicional si detectan filas a eliminar
		IF @objects_quantity<>0
			BEGIN
            -- Inserción de nuevas BBDD
            INSERT INTO MoovaFleetProd_ProdBK.dba.Metadatos 
                (IdUniversal, Instancia, BaseDeDatos,Esquema , TipoDeObjeto, NombreDeObjeto, Descripcion, Contenido, FechaUltimaModificacion)
            SELECT 
                CONCAT('MF-DES','_', l.NombreBaseDeDatos) AS IdUniversal,
				'MF-DES' AS Instancia,
				l.NombreBaseDeDatos AS BaseDeDatos,
                '-' AS Esquema,
                'Base de Datos' AS TipoDeObjeto,
                l.NombreBaseDeDatos AS NombreDeObjeto,
                'Descripcion Base de Datos' AS Descripcion,
                'Tamaño en GB: '+CAST(FORMAT(SUM(m.size) * 8.0 / 1048576,'N2') AS VARCHAR(255)) AS Contenido,
				GETDATE() AS FechaDeUltimaModificacion
            FROM @dblist l
            JOIN sys.databases d ON l.NombreBaseDeDatos = d.name COLLATE SQL_Latin1_General_CP1_CI_AS
            JOIN sys.master_files m ON m.database_id = d.database_id
			GROUP BY l.NombreBaseDeDatos
        END
---------------------------------------------------------ESQUEMAS----------------------------------------------------------------------------------------------------------------------
EXEC [dba].sp_MSforeachdbMax N'
        IF ''?'' != ''tempdb''
        BEGIN
            USE [?]
		
		DECLARE @objects_quantity INT= 0;
		DECLARE @slist TABLE (
		NombreEsquema VARCHAR(255)
		)

		SELECT @objects_quantity = COUNT(*)
		FROM MoovaFleetProd_ProdBK.dba.Metadatos m 
		RIGHT OUTER JOIN sys.schemas s ON m.NombreDeObjeto = s.name COLLATE SQL_Latin1_General_CP1_CI_AS
		WHERE m.NombreDeObjeto IS NULL


		INSERT INTO @slist
		SELECT s.name
		FROM MoovaFleetProd_ProdBK.dba.Metadatos m 
		RIGHT OUTER JOIN sys.schemas s ON m.NombreDeObjeto = s.name COLLATE SQL_Latin1_General_CP1_CI_AS
		WHERE m.NombreDeObjeto IS NULL

		--Condicional si detectan filas a eliminar
		IF @objects_quantity<>0
			BEGIN
            -- Inserción de nuevos schemas
            INSERT INTO MoovaFleetProd_ProdBK.dba.Metadatos 
                (IdUniversal, Instancia, BaseDeDatos, Esquema, TipoDeObjeto, NombreDeObjeto, Descripcion, Contenido, FechaUltimaModificacion)
            SELECT 
                CONCAT(''MF-DES'',''_'', DB_NAME(),''_'',s.name) AS IdUniversal,
				''MF-DES'' AS Instancia,
                DB_NAME() AS BaseDeDatos,
                s.name AS Esquema,
                ''Esquema'' AS TipoDeObjeto,
                s.name AS NombreDeObjeto,
                ''Descripcion Esquema'' AS Descripcion,
                ''Objetos del esquema: ''+(SELECT CAST(COUNT(*) AS NVARCHAR) FROM sys.objects o INNER JOIN sys.schemas s ON o.schema_id = s.schema_id	WHERE s.name =l.NombreEsquema COLLATE SQL_Latin1_General_CP1_CI_AS) AS Contenido,
				GETDATE() AS FechaDeUltimaModificacion
            FROM @slist l
            JOIN sys.schemas s ON l.NombreEsquema = s.name COLLATE SQL_Latin1_General_CP1_CI_AS
			END
			END'

---------------------------------------------------------TRIGGERS----------------------------------------------------------------------------------------------------------------------
EXEC [dba].sp_MSforeachdbMax N'
	BEGIN
		USE [?]

DECLARE @count INT = 0
DECLARE @table TABLE (
NombreDeObjeto VARCHAR(255)
)

SELECT @count =COUNT(*)
FROM MoovaFleetProd_ProdBK.dba.Metadatos m
RIGHT OUTER JOIN sys.triggers o ON m.NombreDeObjeto=o.name COLLATE SQL_Latin1_General_CP1_CI_AS
WHERE m.NombreDeObjeto IS NULL AND o.is_disabled = 0

INSERT INTO @table
	SELECT o.name
	FROM MoovaFleetProd_ProdBK.dba.Metadatos m
	RIGHT OUTER JOIN sys.triggers o ON m.NombreDeObjeto=o.name COLLATE SQL_Latin1_General_CP1_CI_AS
	WHERE m.NombreDeObjeto IS NULL AND o.is_disabled = 0 

		IF @count<>0
			BEGIN
            -- Inserción de nuevos triggers
            INSERT INTO MoovaFleetProd_ProdBK.dba.Metadatos 
                (IdUniversal, Instancia, BaseDeDatos, Esquema, TipoDeObjeto, NombreDeObjeto, Descripcion, Contenido, FechaUltimaModificacion)
            SELECT 
                CONCAT(''MF-DES'',''_'', DB_NAME(),''_'', s.name, ''_'', ''TR'', ''_'', o.name) AS IdUniversal,
				''MF-DES'' AS Instancia,
				 DB_NAME() AS BaseDeDatos,
                s.name AS Esquema,
                ''Trigger'' AS TipoDeObjeto,
                o.name AS NombreDeObjeto,
                ''Descripcion Trigger'' AS Descripcion,
                mo.definition AS Contenido,
				GETDATE() AS FechaDeUltimaModificacion
            FROM @table t
			JOIN sys.triggers o ON o.name = t.NombreDeObjeto COLLATE SQL_Latin1_General_CP1_CI_AS
			JOIN sys.objects ob ON o.name = ob.name COLLATE SQL_Latin1_General_CP1_CI_AS
			JOIN sys.schemas s ON s.schema_id= ob.schema_id
			JOIN sys.sql_modules mo ON o.object_id = mo.object_id
        END
		END'
---------------------------------------------------------JOBS----------------------------------------------------------------------------------------------------------------------
		DECLARE @jlist TABLE (
		NombreJob VARCHAR(255)
		)

		SELECT @objects_quantity = COUNT(*)
		FROM MoovaFleetProd_ProdBK.dba.Metadatos m 
		RIGHT OUTER JOIN msdb.dbo.sysjobs j 
			ON m.NombreDeObjeto = j.name COLLATE SQL_Latin1_General_CP1_CI_AS
		WHERE m.NombreDeObjeto IS NULL

		INSERT INTO @jlist
		SELECT j.name
		FROM MoovaFleetProd_ProdBK.dba.Metadatos m 
		RIGHT OUTER JOIN msdb.dbo.sysjobs j 
			ON m.NombreDeObjeto = j.name COLLATE SQL_Latin1_General_CP1_CI_AS
		WHERE m.NombreDeObjeto IS NULL

		--Condicional si detectan filas a eliminar
		IF @objects_quantity<>0
			BEGIN
            -- Inserción de nuevos schemas
            INSERT INTO MoovaFleetProd_ProdBK.dba.Metadatos 
                (IdUniversal, Instancia, BaseDeDatos, Esquema, TipoDeObjeto, NombreDeObjeto, Descripcion, Contenido, FechaUltimaModificacion)
            SELECT 
                CONCAT('MF-DES','_','JB','_',j.NombreJob) AS IdUniversal,
				'MF-DES' AS Instancia,
                '-' AS BaseDeDatos,
                '-' AS Esquema,
                'Job' AS TipoDeObjeto,
                j.NombreJob AS NombreDeObjeto,
                'Descripcion Job' AS Descripcion,
				STUFF((SELECT ','+'P'+CAST(js.step_id AS VARCHAR(10))+':'+js.step_name+' - COMMAND: '+js.command
																	FROM msdb.dbo.sysjobsteps js
																	JOIN msdb.dbo.sysjobs j ON j.job_id=js.job_id
																	WHERE js.job_id = j.job_id
																	ORDER BY js.step_id
																	FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS Contenido,
				GETDATE() AS FechaDeUltimaModificacion
            FROM @jlist j
            ---JOIN sys.schemas s ON t.NombreEsquema = s.name
		END
---------------------------------------------------------FUNCIONES----------------------------------------------------------------------------------------------------------------------
 EXEC [dba].sp_MSforeachdbMax N'
        IF ''?'' != ''tempdb''
        BEGIN
            USE [?]
		
		DECLARE @objects_quantity INT= 0;
		DECLARE @tlist TABLE (
		NombreEsquema VARCHAR(255),
		NombreFunc VARCHAR(255),
		IdObjeto VARCHAR(255)
		)

		SELECT @objects_quantity = COUNT(*)
		FROM MoovaFleetProd_ProdBK.dba.Metadatos m 
		RIGHT OUTER JOIN sys.objects s ON m.NombreDeObjeto = s.name COLLATE SQL_Latin1_General_CP1_CI_AS
		WHERE s.type IN (''FN'', ''IF'', ''TF'') AND m.NombreDeObjeto IS NULL

		INSERT INTO @tlist
		SELECT s.name, o.name,o.object_id
		FROM MoovaFleetProd_ProdBK.dba.Metadatos m 
		RIGHT OUTER JOIN sys.objects o ON m.NombreDeObjeto = o.name COLLATE SQL_Latin1_General_CP1_CI_AS
		JOIN sys.schemas s ON o.schema_id = s.schema_id
		WHERE o.type IN (''FN'', ''IF'', ''TF'') AND m.NombreDeObjeto IS NULL

		--Condicional si detectan filas a eliminar
		IF @objects_quantity<>0
			BEGIN
            -- Inserción de nuevos schemas
            INSERT INTO MoovaFleetProd_ProdBK.dba.Metadatos 
                (IdUniversal, Instancia, BaseDeDatos, Esquema, TipoDeObjeto, NombreDeObjeto, Descripcion, Contenido, FechaUltimaModificacion)
            SELECT 
                CONCAT(''MF-DES'',''_'', DB_NAME(),''_'',t.NombreEsquema,''_'',''FN'',''_'',t.NombreFunc) AS IdUniversal,
				''MF-DES'' AS Instancia,
                DB_NAME() AS BaseDeDatos,
                t.NombreEsquema AS Esquema,
                ''Funcion'' AS TipoDeObjeto,
                t.NombreFunc AS NombreDeObjeto,
                ''Descripcion Funcion'' AS Descripcion,
				''Tipo: '' +o.type + ''. Definición: '' + COALESCE(m.definition, ''Sin definición'') AS Contenido,
				GETDATE() AS FechaDeUltimaModificacion
            FROM @tlist t
			LEFT JOIN sys.sql_modules m 
				ON t.IdObjeto = m.object_id
			JOIN sys.objects o 
				ON t.IdObjeto = o.object_id 
            ---JOIN sys.schemas s ON t.NombreEsquema = s.name COLLATE SQL_Latin1_General_CP1_CI_AS
			END
			END'
---------------------------------------------------------VISTAS----------------------------------------------------------------------------------------------------------------------
    EXEC [dba].sp_MSforeachdbMax N'
        IF ''?'' != ''tempdb''
        BEGIN
            USE [?]
		
		DECLARE @objects_quantity INT= 0;
		DECLARE @vlist TABLE (
		NombreEsquema VARCHAR(255),
		NombreVista VARCHAR(255),
		IdObjeto VARCHAR(255)
		)

		SELECT @objects_quantity = COUNT(*)
		FROM MoovaFleetProd_ProdBK.dba.Metadatos m 
		RIGHT OUTER JOIN sys.objects s ON m.NombreDeObjeto = s.name COLLATE SQL_Latin1_General_CP1_CI_AS
		WHERE s.type = ''V'' AND m.NombreDeObjeto IS NULL

		INSERT INTO @vlist
		SELECT s.name, o.name,o.object_id
		FROM MoovaFleetProd_ProdBK.dba.Metadatos m 
		RIGHT OUTER JOIN sys.objects o ON m.NombreDeObjeto = o.name COLLATE SQL_Latin1_General_CP1_CI_AS
		JOIN sys.schemas s ON o.schema_id = s.schema_id
		WHERE m.NombreDeObjeto IS NULL AND o.type = ''V'' 

		--Condicional si detectan filas a eliminar
		IF @objects_quantity<>0
			BEGIN
            -- Inserción de nuevos schemas
            INSERT INTO MoovaFleetProd_ProdBK.dba.Metadatos 
                (IdUniversal, Instancia, BaseDeDatos, Esquema, TipoDeObjeto, NombreDeObjeto, Descripcion, Contenido, FechaUltimaModificacion)
            SELECT 
                CONCAT(''MF-DES'',''_'', DB_NAME(),''_'',t.NombreEsquema,''_'',''VW'',''_'',t.NombreVista) AS IdUniversal,
				''MF-DES'' AS Instancia,
                DB_NAME() AS BaseDeDatos,
                t.NombreEsquema AS Esquema,
                ''Vista'' AS TipoDeObjeto,
                t.NombreVista AS NombreDeObjeto,
                ''Descripcion Vista'' AS Descripcion,
				COALESCE(m.definition, ''Sin definición'') AS Contenido,
				GETDATE() AS FechaDeUltimaModificacion
			FROM @vlist t
			LEFT JOIN sys.sql_modules m ON m.object_id =t.IdObjeto
			END
			END'
---------------------------------------------------------PAS----------------------------------------------------------------------------------------------------------------------
 EXEC [dba].sp_MSforeachdbMax N'
        IF ''?'' != ''tempdb''
        BEGIN
            USE [?]
		
		DECLARE @objects_quantity INT= 0;
		DECLARE @tlist TABLE (
		NombreEsquema VARCHAR(255),
		NombrePA VARCHAR(255),
		IdObjeto VARCHAR(255)
		)

		SELECT @objects_quantity = COUNT(*)
		FROM MoovaFleetProd_ProdBK.dba.Metadatos m 
		RIGHT OUTER JOIN sys.procedures p ON m.NombreDeObjeto = p.name COLLATE SQL_Latin1_General_CP1_CI_AS
		WHERE m.NombreDeObjeto IS NULL

		INSERT INTO @tlist
		SELECT s.name,p.name,p.object_id
		FROM MoovaFleetProd_ProdBK.dba.Metadatos m 
		RIGHT OUTER JOIN sys.procedures p ON m.NombreDeObjeto = p.name COLLATE SQL_Latin1_General_CP1_CI_AS
		JOIN sys.schemas s ON p.schema_id = s.schema_id
		WHERE m.NombreDeObjeto IS NULL

		--Condicional si detectan filas a eliminar
		IF @objects_quantity<>0
			BEGIN
            -- Inserción de nuevos schemas
            INSERT INTO MoovaFleetProd_ProdBK.dba.Metadatos 
                (IdUniversal, Instancia, BaseDeDatos, Esquema, TipoDeObjeto, NombreDeObjeto, Descripcion, Contenido, FechaUltimaModificacion)
            SELECT 
                CONCAT(''MF-DES'',''_'', DB_NAME(),''_'',t.NombreEsquema,''_'',''USP'',''_'',t.NombrePA) AS IdUniversal,
				''MF-DES'' AS Instancia,
                DB_NAME() AS BaseDeDatos,
                t.NombreEsquema AS Esquema,
                ''Procedimiento'' AS TipoDeObjeto,
                t.NombrePA AS NombreDeObjeto,
                ''Descripcion Proceso'' AS Descripcion,
				COALESCE(m.definition, ''Sin definición'') AS Contenido,
				GETDATE() AS FechaDeUltimaModificacion
            FROM @tlist t
            ---JOIN sys.schemas s ON t.NombreEsquema = s.name COLLATE SQL_Latin1_General_CP1_CI_AS
			LEFT JOIN sys.sql_modules m ON m.object_id =t.IdObjeto
			END
			END'
---------------------------------------------------------TABLAS----------------------------------------------------------------------------------------------------------------------
 EXEC [dba].sp_MSforeachdbMax N'
        IF ''?'' != ''tempdb''
        BEGIN
            USE [?];
		DECLARE @objects_quantity INT= 0;
		DECLARE @tlist TABLE (
		NombreEsquema VARCHAR(255),
		NombreTablas VARCHAR(255)
		)

		SELECT @objects_quantity = COUNT(*)
		FROM MoovaFleetProd_ProdBK.dba.Metadatos m 
		RIGHT OUTER JOIN sys.objects s ON m.NombreDeObjeto = s.name COLLATE SQL_Latin1_General_CP1_CI_AS
		WHERE s.type = ''U'' AND m.NombreDeObjeto IS NULL

		INSERT INTO @tlist
		SELECT s.name, o.name
		FROM MoovaFleetProd_ProdBK.dba.Metadatos m 
		RIGHT OUTER JOIN sys.objects o ON m.NombreDeObjeto = o.name COLLATE SQL_Latin1_General_CP1_CI_AS
		JOIN sys.schemas s ON o.schema_id = s.schema_id
		WHERE o.type = ''U'' AND m.NombreDeObjeto IS NULL

		--Condicional si detectan filas a eliminar
		IF @objects_quantity<>0
			BEGIN
            -- Inserción de nuevas tablas
            INSERT INTO MoovaFleetProd_ProdBK.dba.Metadatos 
                (IdUniversal, Instancia, BaseDeDatos, Esquema, TipoDeObjeto, NombreDeObjeto, Descripcion, Contenido, FechaUltimaModificacion)
            SELECT 
                CONCAT(''MF-DES'',''_'', DB_NAME(),''_'',t.NombreEsquema,''_'',t.NombreTablas) AS IdUniversal,
				''MF-DES'' AS Instancia,
                DB_NAME() AS BaseDeDatos,
                t.NombreEsquema AS Esquema,
                ''Tabla'' AS TipoDeObjeto,
                t.NombreTablas AS NombreDeObjeto,
                ''Descripcion Tabla'' AS Descripcion,
				(SELECT STRING_AGG(COLUMN_NAME, '','') AS Resultado FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME=t.NombreTablas) AS Contenido,
				GETDATE() AS FechaDeUltimaModificacion
            FROM @tlist t
			END
		END'
END
