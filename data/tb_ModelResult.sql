CREATE TABLE [dbo].[tb_ModelResult](
	[Id] [UNIQUEIDENTIFIER] NOT NULL CONSTRAINT [PK_tb_ModelResult] PRIMARY KEY CONSTRAINT [DF_tb_ModelResult_Id]  DEFAULT (NEWSEQUENTIALID()),
	[ModelName] [NVARCHAR](50) NOT NULL,
	[Sector] [NVARCHAR](50) NOT NULL,
	[ForYear] [INT] NOT NULL,
	[ForMonth] [INT] NOT NULL,
	[Accuracy] [FLOAT] NULL,
	[Sensitivity] [FLOAT] NULL,
	[Specificity] [FLOAT] NULL,
	[Precision] [FLOAT] NULL,
	[Top10SecurityIds] [NVARCHAR](1000) NULL,
)

--Insert 
INSERT tb_ModelResult(ModelName, Sector, ForYear, ForMonth, Accuracy, Sensitivity, Specificity, Precision, Top10SecurityIds)
VALUES()


--Query last day for prediction
SELECT * FROM tb_Calendar 
WHERE IsBizMonthEnd = 1 AND YEAR(CalendarDate) = 2014 AND MONTH(CalendarDate) = 10

-- Run range: from 12/2004 to 10/2014 for all 10 sectors, expecting (10 * 12 - 1) * 10 = 1190 records
