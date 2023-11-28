
/****** Object:  Table [NewStar].[LotMap]    Script Date: 3/22/2022 11:29:23 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [NewStar].[LotMap](
	[ID] [smallint] IDENTITY(1,1) NOT NULL,
	[SalefishLotNo] [varchar](10) NOT NULL,
	[NewStarLotNo] [varchar](10) NOT NULL,
	[SalefishLotID] [int] NOT NULL,
 CONSTRAINT [PK__LowRiseL__3214EC2789049EB5] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_SuiteToLotMap_NewStarLotNo] UNIQUE NONCLUSTERED 
(
	[NewStarLotNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_SuiteToLotMap_SalefishLotNo] UNIQUE NONCLUSTERED 
(
	[SalefishLotNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

