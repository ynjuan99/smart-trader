CREATE TABLE [dbo].[tb_ModelResult](
	[Version] [DATETIME] NOT NULL PRIMARY KEY CONSTRAINT [DF_Table_1_Id]  DEFAULT (GETDATE()),
	[ModelName] [NVARCHAR](50) NOT NULL,
	[Sector] [NVARCHAR](50) NOT NULL,
	[ForYear] [INT] NOT NULL,
	[Accuracy] [FLOAT] NULL,
	[Sensitivity] [FLOAT] NULL,
	[Specificity] [FLOAT] NULL,
	[Precision] [FLOAT] NULL,
	[Top10SecurityIds] [NVARCHAR](1000) NULL   
)


INSERT tb_ModelResult(ModelName, Sector, ForYear, Accuracy, Sensitivity, Specificity, Precision, Top10SecurityIds)
VALUES()


