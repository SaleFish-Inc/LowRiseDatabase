USE [LSALiveNEW]
GO

/****** Object:  Table [NewStar].[ProjctToCommunityMap]    Script Date: 6/14/2022 2:14:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [NewStar].[ProjctToCommunityMap](
	[ID] [smallint] IDENTITY(1,1) NOT NULL,
	[SalefishProjectID] [varchar](10) NOT NULL,
	[SalefishProjectName] [varchar](100) NOT NULL,
	[NewStarCommunityID] [varchar](10) NOT NULL,
	[NewStarCommunityName] [varchar](100) NOT NULL,
	[NewStarProjectCode] [varchar](10) NOT NULL,
 CONSTRAINT [PK_ProjctToCommunityMap] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_ProjctToCommunityMap_NewStarCommunityID] UNIQUE NONCLUSTERED 
(
	[NewStarCommunityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_ProjctToCommunityMap_SalefishProjectID] UNIQUE NONCLUSTERED 
(
	[SalefishProjectID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO



SELECT * FROM [NewStar].[ProjctToCommunityMap]
GO

INSERT INTO NewStar.ProjctToCommunityMap(SalefishProjectID, SalefishProjectName, NewStarCommunityID, NewStarCommunityName, NewStarProjectCode)
VALUES('A0506', -- SalefishProjectID - varchar(10)
'West & Post Townhomes – Oakville'  , -- SalefishProjectName - varchar(100)
'WO01'  , -- NewStarCommunityID - varchar(10)
'Branthaven West Oak Inc.'  , -- NewStarCommunityName - varchar(100)
'00010118'  -- NewStarProjectCode - varchar(10)
    )