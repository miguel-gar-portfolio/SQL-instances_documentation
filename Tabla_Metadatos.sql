CREATE TABLE [dba].[Metadatos](
	[IdUniversal] [nvarchar](4000) NOT NULL,
	[Instancia] [nvarchar](100) NULL,
	[BaseDeDatos] [nvarchar](100) NULL,
	[Esquema] [nvarchar](100) NULL,
	[TipoDeObjeto] [nvarchar](100) NULL,
	[NombreDeObjeto] [nvarchar](250) NULL,
	[Descripcion] [nvarchar](max) NULL,
	[Contenido] [nvarchar](max) NULL,
	[FechaUltimaModificacion] [datetime] NULL,
 CONSTRAINT [PK_Metadatos] PRIMARY KEY CLUSTERED 
(
	[IdUniversal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
