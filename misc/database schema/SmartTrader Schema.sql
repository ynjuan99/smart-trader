USE [SmartTrader]
GO
/****** Object:  Table [dbo].[tb_Calendar]    Script Date: 2014-12-30 22:11:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tb_Calendar]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tb_Calendar](
	[CalendarDate] [datetime] NOT NULL,
	[IsBizMonthBeg] [bit] NULL,
	[IsCalMonthBeg] [bit] NULL,
	[IsBizMonthEnd] [bit] NULL,
	[IsCalMonthEnd] [bit] NULL,
	[SeqD] [int] NULL,
	[SeqM] [int] NULL,
	[SeqQ] [int] NULL,
	[SeqY] [int] NULL,
	[DayOfWeek] [int] NULL,
	[DayOfYear] [int] NULL,
	[YYYY] [int] NULL,
	[MM] [int] NULL,
	[DD] [int] NULL,
	[YYYYMMDD] [varchar](30) NULL
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_Factor]    Script Date: 2014-12-30 22:11:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tb_Factor]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tb_Factor](
	[FID] [int] NOT NULL,
	[FACTOR] [varchar](50) NULL,
	[FACTORDESC] [varchar](250) NULL,
	[FACTORGRP] [varchar](50) NULL,
	[FACTORSUBGRP] [varchar](50) NULL,
	[ISRAWDATA] [bit] NOT NULL CONSTRAINT [DF_tb_Factor_ISRAWDATA]  DEFAULT ((1)),
	[FORMULA] [varchar](250) NULL,
	[ISACTIVE] [bit] NOT NULL CONSTRAINT [DF_tb_Factor_ISACTIVE]  DEFAULT ((1)),
	[ISINVERTED] [bit] NOT NULL CONSTRAINT [DF_tb_Factor_ISINVERTED]  DEFAULT ((0)),
	[ISCOMPOSITE] [bit] NOT NULL CONSTRAINT [DF_tb_Factor_ISCOMPOSITE]  DEFAULT ((0)),
	[CUSTOMCOMPOSITION] [bit] NOT NULL CONSTRAINT [DF_tb_Factor_CUSTOMCOMPOSITION]  DEFAULT ((0)),
 CONSTRAINT [PK_tb_Factor] PRIMARY KEY CLUSTERED 
(
	[FID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_FactorData]    Script Date: 2014-12-30 22:11:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tb_FactorData]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tb_FactorData](
	[Date] [datetime] NOT NULL,
	[SecId] [int] NOT NULL,
	[SML] [char](1) NULL,
	[Sector] [char](26) NULL,
	[BookYieldFY1] [float] NULL,
	[DividendYieldFY0] [float] NULL,
	[DividendYieldFY1] [float] NULL,
	[DividendYieldFY2] [float] NULL,
	[EarningsYieldFY0] [float] NULL,
	[EarningsYieldFY1] [float] NULL,
	[EarningsYieldFY2] [float] NULL,
	[EBITDAYieldFY0] [float] NULL,
	[EBITDAYieldFY1] [float] NULL,
	[EBITDAYieldFY2] [float] NULL,
	[SalesYieldFY0] [float] NULL,
	[SalesYieldFY1] [float] NULL,
	[SalesYieldFY2] [float] NULL,
	[EBIT_EV_NTM] [float] NULL,
	[EBITDA_EV_NTM] [float] NULL,
	[SALES_EV_NTM] [float] NULL,
	[PEGFY1] [float] NULL,
	[EarningsYield1Y] [float] NULL,
	[FCFYield1Y] [float] NULL,
	[SalesYield1Y] [float] NULL,
	[EBIT_EV1Y] [float] NULL,
	[EBITDA_EV1Y] [float] NULL,
	[BookRevFY1_1M] [float] NULL,
	[BookRevFY1_3M] [float] NULL,
	[BookRevFY1_6M] [float] NULL,
	[DivRevFY1_1M] [float] NULL,
	[DivRevFY1_3M] [float] NULL,
	[DivRevFY1_6M] [float] NULL,
	[EarningsRevFY1_1M] [float] NULL,
	[EarningsRevFY1_3M] [float] NULL,
	[EarningsRevFY1_6M] [float] NULL,
	[EBITDARevFY1_1M] [float] NULL,
	[EBITDARevFY1_3M] [float] NULL,
	[EBITDARevFY1_6M] [float] NULL,
	[SalesRevFY1_1M] [float] NULL,
	[SalesRevFY1_3M] [float] NULL,
	[SalesRevFY1_6M] [float] NULL,
	[NMRevFY1_1M] [float] NULL,
	[NMRevFY1_3M] [float] NULL,
	[EarningsFY1Std] [float] NULL,
	[EarningsFY2Std] [float] NULL,
	[EarningsFY1UpDnGrade_1M] [float] NULL,
	[EarningsFY2UpDnGrade_1M] [float] NULL,
	[EarningsFY1UpDnGrade_3M] [float] NULL,
	[EarningsFY2UpDnGrade_3M] [float] NULL,
	[EarningsFY1UpDnGrade_6M] [float] NULL,
	[EarningsFY2UpDnGrade_6M] [float] NULL,
	[EarningsFY1Cov] [float] NULL,
	[EBITDAMarginNTM] [float] NULL,
	[EBITMarginNTM] [float] NULL,
	[NetMarginNTM] [float] NULL,
	[NetDebtEbitdaNTM] [float] NULL,
	[DivRatio] [float] NULL,
	[ROIC1Y] [float] NULL,
	[CROIC1Y] [float] NULL,
	[DebtCapLQ] [float] NULL,
	[DebtTALQ] [float] NULL,
	[DebtEbitdaLQ] [float] NULL,
	[OpCFOverFCF1Y] [float] NULL,
	[OpCFOverEarnings1Y] [float] NULL,
	[OpCFOverCDiv1Y] [float] NULL,
	[NetCashDebt1Y] [float] NULL,
	[SharesChg3M] [float] NULL,
	[SharesChg6M] [float] NULL,
	[SharesChg12M] [float] NULL,
	[FERating] [float] NULL,
	[EPS_LTGMean] [float] NULL,
	[EPSMeanNTMSlope6M] [float] NULL,
	[EPSPastSlope6M] [float] NULL,
	[EPSPastSlope12M] [float] NULL,
	[EPSPastSlope36M] [float] NULL,
	[EPSPastSlope60M] [float] NULL,
	[EPSPastTStat36M] [float] NULL,
	[EPSPastTStat60M] [float] NULL,
	[SalesPSPastSlope6M] [float] NULL,
	[SalesPSPastSlope12M] [float] NULL,
	[SalesPSPastSlope36M] [float] NULL,
	[SalesPSPastSlope60M] [float] NULL,
	[SalesPSPastTStat36M] [float] NULL,
	[SalesPSPastTStat60M] [float] NULL,
	[NetMarginPastSlope12M] [float] NULL,
	[NetMarginPastSlope36M] [float] NULL,
	[PriceSlope10D] [float] NULL,
	[PriceSlope20D] [float] NULL,
	[PriceSlope50D] [float] NULL,
	[PriceSlope100D] [float] NULL,
	[PriceSlope200D] [float] NULL,
	[PriceTStat10D] [float] NULL,
	[PriceTStat20D] [float] NULL,
	[PriceTStat50D] [float] NULL,
	[PriceTStat100D] [float] NULL,
	[PriceTStat200D] [float] NULL,
	[MoneyFlow14D] [float] NULL,
	[MoneyFlow50D] [float] NULL,
	[MoneyFlow200D] [float] NULL,
	[RSI14D] [float] NULL,
	[RSI50D] [float] NULL,
	[PMOM10] [float] NULL,
	[PMOM20] [float] NULL,
	[PMOM50] [float] NULL,
	[PMOM100] [float] NULL,
	[PriceMA10] [float] NULL,
	[PriceMA20] [float] NULL,
	[PriceMA50] [float] NULL,
	[PriceMA100] [float] NULL,
	[PriceMA200] [float] NULL,
	[Price52WHigh] [float] NULL,
	[Price52WLow] [float] NULL,
	[Volatility1M] [float] NULL,
	[Volatility3M] [float] NULL,
	[Volatility6M] [float] NULL,
	[Volatility12M] [float] NULL,
	[TVAL1DOver5D] [float] NULL,
	[TVAL5DOver20D] [float] NULL,
	[TVAL20DOver50D] [float] NULL,
	[Beta1M] [float] NULL,
	[Beta3M] [float] NULL,
	[Beta6M] [float] NULL,
	[Beta12M] [float] NULL,
	[PriceRetF1D] [float] NULL,
	[PriceRetF5D] [float] NULL,
	[PriceRetF10D] [float] NULL,
	[PriceRetF20D] [float] NULL,
	[PriceRetF40D] [float] NULL,
	[PriceRetFF10D] [float] NULL,
	[PriceRetFF20D] [float] NULL,
 CONSTRAINT [PK_tb_FactorData] PRIMARY KEY CLUSTERED 
(
	[Date] ASC,
	[SecId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_FactorReturn]    Script Date: 2014-12-30 22:11:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tb_FactorReturn]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tb_FactorReturn](
	[Date] [datetime] NOT NULL,
	[Factors] [varchar](255) NOT NULL,
	[Q1retn] [float] NULL,
	[Q2retn] [float] NULL,
	[Q3retn] [float] NULL,
	[Q4retn] [float] NULL,
	[Q5retn] [float] NULL,
	[lretn] [float] NULL,
	[sretn] [float] NULL,
	[lsretn] [float] NULL,
 CONSTRAINT [PK_tb_FactorReturn] PRIMARY KEY CLUSTERED 
(
	[Date] ASC,
	[Factors] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_FactorReturnSummaryAll]    Script Date: 2014-12-30 22:11:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tb_FactorReturnSummaryAll]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tb_FactorReturnSummaryAll](
	[Factor] [varchar](255) NULL,
	[Stat] [varchar](255) NULL,
	[Q1retn] [float] NULL,
	[Q2retn] [float] NULL,
	[Q3retn] [float] NULL,
	[Q4retn] [float] NULL,
	[Q5retn] [float] NULL,
	[lretn] [float] NULL,
	[sretn] [float] NULL,
	[lsretn] [float] NULL
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_FactorReturnSummaryByYear]    Script Date: 2014-12-30 22:11:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tb_FactorReturnSummaryByYear]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tb_FactorReturnSummaryByYear](
	[Factor] [varchar](255) NULL,
	[Year] [int] NULL,
	[Stats] [varchar](255) NULL,
	[Q1retn] [float] NULL,
	[Q2retn] [float] NULL,
	[Q3retn] [float] NULL,
	[Q4retn] [float] NULL,
	[Q5retn] [float] NULL,
	[lretn] [float] NULL,
	[sretn] [float] NULL,
	[lsretn] [float] NULL
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_FactorScore]    Script Date: 2014-12-30 22:11:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tb_FactorScore]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tb_FactorScore](
	[Date] [datetime] NOT NULL,
	[SecId] [varchar](255) NOT NULL,
	[Sector] [varchar](255) NOT NULL,
	[BookYieldFY1] [float] NULL,
	[DividendYieldFY0] [float] NULL,
	[DividendYieldFY1] [float] NULL,
	[DividendYieldFY2] [float] NULL,
	[EarningsYieldFY0] [float] NULL,
	[EarningsYieldFY1] [float] NULL,
	[EarningsYieldFY2] [float] NULL,
	[EBITDAYieldFY0] [float] NULL,
	[EBITDAYieldFY1] [float] NULL,
	[EBITDAYieldFY2] [float] NULL,
	[SalesYieldFY0] [float] NULL,
	[SalesYieldFY1] [float] NULL,
	[SalesYieldFY2] [float] NULL,
	[EBIT_EV_NTM] [float] NULL,
	[EBITDA_EV_NTM] [float] NULL,
	[SALES_EV_NTM] [float] NULL,
	[PEGFY1] [float] NULL,
	[EarningsYield1Y] [float] NULL,
	[FCFYield1Y] [float] NULL,
	[SalesYield1Y] [float] NULL,
	[EBIT_EV1Y] [float] NULL,
	[EBITDA_EV1Y] [float] NULL,
	[BookRevFY1_1M] [float] NULL,
	[BookRevFY1_3M] [float] NULL,
	[BookRevFY1_6M] [float] NULL,
	[DivRevFY1_1M] [float] NULL,
	[DivRevFY1_3M] [float] NULL,
	[DivRevFY1_6M] [float] NULL,
	[EarningsRevFY1_1M] [float] NULL,
	[EarningsRevFY1_3M] [float] NULL,
	[EarningsRevFY1_6M] [float] NULL,
	[EBITDARevFY1_1M] [float] NULL,
	[EBITDARevFY1_3M] [float] NULL,
	[EBITDARevFY1_6M] [float] NULL,
	[SalesRevFY1_1M] [float] NULL,
	[SalesRevFY1_3M] [float] NULL,
	[SalesRevFY1_6M] [float] NULL,
	[NMRevFY1_1M] [float] NULL,
	[NMRevFY1_3M] [float] NULL,
	[EarningsFY1Std] [float] NULL,
	[EarningsFY2Std] [float] NULL,
	[EarningsFY1UpDnGrade_1M] [float] NULL,
	[EarningsFY2UpDnGrade_1M] [float] NULL,
	[EarningsFY1UpDnGrade_3M] [float] NULL,
	[EarningsFY2UpDnGrade_3M] [float] NULL,
	[EarningsFY1UpDnGrade_6M] [float] NULL,
	[EarningsFY2UpDnGrade_6M] [float] NULL,
	[EarningsFY1Cov] [float] NULL,
	[EBITDAMarginNTM] [float] NULL,
	[EBITMarginNTM] [float] NULL,
	[NetMarginNTM] [float] NULL,
	[NetDebtEbitdaNTM] [float] NULL,
	[DivRatio] [float] NULL,
	[ROIC1Y] [float] NULL,
	[CROIC1Y] [float] NULL,
	[DebtCapLQ] [float] NULL,
	[DebtTALQ] [float] NULL,
	[DebtEbitdaLQ] [float] NULL,
	[OpCFOverFCF1Y] [float] NULL,
	[OpCFOverEarnings1Y] [float] NULL,
	[OpCFOverCDiv1Y] [float] NULL,
	[NetCashDebt1Y] [float] NULL,
	[SharesChg3M] [float] NULL,
	[SharesChg6M] [float] NULL,
	[SharesChg12M] [float] NULL,
	[FERating] [float] NULL,
	[EPS_LTGMean] [float] NULL,
	[EPSMeanNTMSlope6M] [float] NULL,
	[EPSPastSlope6M] [float] NULL,
	[EPSPastSlope12M] [float] NULL,
	[EPSPastSlope36M] [float] NULL,
	[EPSPastSlope60M] [float] NULL,
	[EPSPastTStat36M] [float] NULL,
	[EPSPastTStat60M] [float] NULL,
	[SalesPSPastSlope6M] [float] NULL,
	[SalesPSPastSlope12M] [float] NULL,
	[SalesPSPastSlope36M] [float] NULL,
	[SalesPSPastSlope60M] [float] NULL,
	[SalesPSPastTStat36M] [float] NULL,
	[SalesPSPastTStat60M] [float] NULL,
	[NetMarginPastSlope12M] [float] NULL,
	[NetMarginPastSlope36M] [float] NULL,
	[PriceSlope10D] [float] NULL,
	[PriceSlope20D] [float] NULL,
	[PriceSlope50D] [float] NULL,
	[PriceSlope100D] [float] NULL,
	[PriceSlope200D] [float] NULL,
	[PriceTStat10D] [float] NULL,
	[PriceTStat20D] [float] NULL,
	[PriceTStat50D] [float] NULL,
	[PriceTStat100D] [float] NULL,
	[PriceTStat200D] [float] NULL,
	[MoneyFlow14D] [float] NULL,
	[MoneyFlow50D] [float] NULL,
	[MoneyFlow200D] [float] NULL,
	[RSI14D] [float] NULL,
	[RSI50D] [float] NULL,
	[PMOM10] [float] NULL,
	[PMOM20] [float] NULL,
	[PMOM50] [float] NULL,
	[PMOM100] [float] NULL,
	[PriceMA10] [float] NULL,
	[PriceMA20] [float] NULL,
	[PriceMA50] [float] NULL,
	[PriceMA100] [float] NULL,
	[PriceMA200] [float] NULL,
	[Price52WHigh] [float] NULL,
	[Price52WLow] [float] NULL,
	[Volatility1M] [float] NULL,
	[Volatility3M] [float] NULL,
	[Volatility6M] [float] NULL,
	[Volatility12M] [float] NULL,
	[TVAL1DOver5D] [float] NULL,
	[TVAL5DOver20D] [float] NULL,
	[TVAL20DOver50D] [float] NULL,
	[Beta1M] [float] NULL,
	[Beta3M] [float] NULL,
	[Beta6M] [float] NULL,
	[Beta12M] [float] NULL,
	[PriceRetF1D] [float] NULL,
	[PriceRetF5D] [float] NULL,
	[PriceRetF10D] [float] NULL,
	[PriceRetF20D] [float] NULL,
	[PriceRetF40D] [float] NULL,
	[PriceRetFF10D] [float] NULL,
	[PriceRetFF20D] [float] NULL,
	[PriceRetFF20D_Absolute] [float] NULL,
 CONSTRAINT [PK_tb_FactorScore] PRIMARY KEY CLUSTERED 
(
	[Date] ASC,
	[SecId] ASC,
	[Sector] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_FactorStatsBySector]    Script Date: 2014-12-30 22:11:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tb_FactorStatsBySector]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tb_FactorStatsBySector](
	[Date] [datetime] NOT NULL,
	[Sector] [varchar](50) NOT NULL,
	[Factor] [varchar](100) NOT NULL,
	[Mean] [float] NULL,
	[Median] [float] NULL,
	[Mad] [float] NULL,
	[Std] [float] NULL,
	[Max] [float] NULL,
	[Min] [float] NULL,
	[PercNAs] [float] NULL,
	[LowerLimit] [float] NULL,
	[HigherLimit] [float] NULL,
 CONSTRAINT [PK_tb_FactorStatsBySector] PRIMARY KEY CLUSTERED 
(
	[Date] ASC,
	[Sector] ASC,
	[Factor] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_FactorStatsByUniverse]    Script Date: 2014-12-30 22:11:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tb_FactorStatsByUniverse]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tb_FactorStatsByUniverse](
	[Date] [datetime] NOT NULL,
	[Universe] [varchar](5) NOT NULL,
	[Factor] [varchar](100) NOT NULL,
	[Mean] [float] NULL,
	[Median] [float] NULL,
	[Mad] [float] NULL,
	[Std] [float] NULL,
	[Max] [float] NULL,
	[Min] [float] NULL,
	[PercNAs] [float] NULL,
	[LowerLimit] [float] NULL,
	[HigherLimit] [float] NULL,
 CONSTRAINT [PK_tb_FactorStatsByUniverse] PRIMARY KEY CLUSTERED 
(
	[Date] ASC,
	[Universe] ASC,
	[Factor] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_ModelResult]    Script Date: 2014-12-30 22:11:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tb_ModelResult]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tb_ModelResult](
	[Id] [uniqueidentifier] NOT NULL CONSTRAINT [DF_tb_ModelResult_Id]  DEFAULT (newsequentialid()),
	[ModelName] [nvarchar](50) NOT NULL,
	[Sector] [nvarchar](50) NOT NULL,
	[ForYear] [int] NOT NULL,
	[ForMonth] [int] NOT NULL,
	[Accuracy] [float] NULL,
	[Sensitivity] [float] NULL,
	[Specificity] [float] NULL,
	[Precision] [float] NULL,
	[Top10SecurityIds] [nvarchar](1000) NULL,
 CONSTRAINT [PK_tb_ModelResult] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[tb_OtherData]    Script Date: 2014-12-30 22:11:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tb_OtherData]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tb_OtherData](
	[Date] [datetime] NOT NULL,
	[SecId] [int] NOT NULL,
	[CompanyName] [char](51) NULL,
	[SML] [char](1) NULL,
	[Sector] [char](26) NULL,
	[VolumeDaily] [float] NULL,
	[SharesOutstanding] [float] NULL,
	[SharesLessCloselyHeld] [float] NULL,
	[CloselyHeldShares___] [float] NULL,
	[MarketValue] [float] NULL,
	[DividendPS] [float] NULL,
	[ShareRepurchaseAmtANN] [float] NULL,
	[ShareRepurchaseAmtQTR] [float] NULL,
	[ShareSalesAmtANN] [float] NULL,
	[ShareSalesAmtQTR] [float] NULL,
	[NumInsiderBuy] [float] NULL,
	[NumInsiderSales] [float] NULL,
	[NumShsBuy] [float] NULL,
	[NumShsSold] [float] NULL,
	[EPSReportDate] [float] NULL,
	[EPSReportDate_QTR_] [float] NULL,
	[EPSReportDate_ANN_] [float] NULL,
 CONSTRAINT [PK_tb_OtherData] PRIMARY KEY CLUSTERED 
(
	[Date] ASC,
	[SecId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_ReturnPriceData]    Script Date: 2014-12-30 22:11:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tb_ReturnPriceData]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tb_ReturnPriceData](
	[Date] [datetime] NOT NULL,
	[SecId] [int] NOT NULL,
	[CompanyName] [char](51) NULL,
	[SML] [char](1) NULL,
	[Sector] [char](26) NULL,
	[OpenFromYClose] [float] NULL,
	[CloseFromOpen] [float] NULL,
	[TotRet1D] [float] NULL,
	[PriceRet1D] [float] NULL,
	[PriceRet5D] [float] NULL,
	[PriceRet10D] [float] NULL,
	[PriceRet20D] [float] NULL,
	[PriceRet50D] [float] NULL,
	[PriceRet100D] [float] NULL,
	[PriceRet200D] [float] NULL,
	[PriceClose] [float] NULL,
	[PriceOpen] [float] NULL,
	[PriceHigh] [float] NULL,
	[PriceLow] [float] NULL,
	[PriceHigh52W] [float] NULL,
	[PriceLow52W] [float] NULL,
	[VWAP] [float] NULL,
	[VolumeDaily] [float] NULL,
	[MA10] [float] NULL,
	[MA20] [float] NULL,
	[MA50] [float] NULL,
	[MA100] [float] NULL,
	[MA200] [float] NULL,
 CONSTRAINT [PK_tb_ReturnPriceData] PRIMARY KEY CLUSTERED 
(
	[Date] ASC,
	[SecId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_SecurityMaster]    Script Date: 2014-12-30 22:11:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tb_SecurityMaster]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tb_SecurityMaster](
	[SecId] [int] NOT NULL,
	[CompanyName] [varchar](255) NULL,
	[Sedol] [varchar](50) NULL,
	[BBTicker] [varchar](50) NULL,
	[Isin] [varchar](50) NULL,
	[GICSCode] [int] NULL,
	[GICS_SEC] [varchar](250) NULL,
	[GICS_GRP] [varchar](250) NULL,
	[GICS_IND] [varchar](250) NULL,
	[GICS_SUB] [varchar](250) NULL,
	[SML] [char](1) NULL,
	[FYEND] [char](6) NULL,
 CONSTRAINT [PK_tb_SecurityMaster1] PRIMARY KEY CLUSTERED 
(
	[SecId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_SecurityMasterO]    Script Date: 2014-12-30 22:11:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tb_SecurityMasterO]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tb_SecurityMasterO](
	[SecId] [int] NOT NULL,
	[CompanyName] [varchar](255) NULL,
	[Sedol] [varchar](50) NULL,
	[BBTicker] [varchar](50) NULL,
	[Isin] [varchar](50) NULL,
	[GICSCode] [int] NULL,
	[GICS_SEC] [varchar](250) NULL,
	[GICS_GRP] [varchar](250) NULL,
	[GICS_IND] [varchar](250) NULL,
	[GICS_SUB] [varchar](250) NULL,
	[SML] [char](1) NULL,
	[FYEND] [char](6) NULL,
 CONSTRAINT [PK_tb_SecurityMaster] PRIMARY KEY CLUSTERED 
(
	[SecId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
