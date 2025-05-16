
CREATE TABLE [dba].[Metadatos_Campos](
	[Id_Union] [nvarchar](500) NULL,
	[IdUniversal] [nvarchar](500) NOT NULL,
	[FechaDeCreacion] [datetime] NULL,
	[FechaDeUltimaModificacion] [datetime] NULL,
	[BaseDeDatos] [nvarchar](50) NULL,
	[Esquema] [nvarchar](30) NULL,
	[NombreTabla_O_Vista] [nvarchar](500) NULL,
	[Tipo] [nvarchar](20) NULL,
	[NombreCampo] [nvarchar](max) NULL,
	[Descripcion] [nvarchar](max) NULL,
	[FechaModificacionSistema] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[IdUniversal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


