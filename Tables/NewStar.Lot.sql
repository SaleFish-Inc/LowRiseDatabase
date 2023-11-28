USE LSALiveNEW
GO

/****** Object:  Table [NewStar].[Lot]    Script Date: 3/22/2022 11:28:52 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [NewStar].[Lot](
	[Unit_No] [nvarchar](50) NULL,
	[Model] [nvarchar](50) NULL,
	[Elev] [nvarchar](50) NULL,
	[Phase] [nvarchar](1) NULL,
	[Block_No] [nvarchar](1) NULL,
	[Customer] [nvarchar](50) NULL,
	[Suite] [nvarchar](1) NULL,
	[Street_Number] [nvarchar](1) NULL,
	[Street] [nvarchar](1) NULL,
	[Closing_Date] [nvarchar](1) NULL,
	[BuildPro_Lot] [nvarchar](50) NOT NULL,
	[Schedule_Code] [nvarchar](1) NULL,
	[Constr_Start_Date] [nvarchar](1) NULL,
	[Scheduled_Compl_Date] [nvarchar](1) NULL,
	[Projected_Compl_Date] [nvarchar](1) NULL,
	[Actual_Compl_Date] [nvarchar](1) NULL,
	[Posting_Stop_Date] [nvarchar](1) NULL,
	[Permit_Received_Date] [nvarchar](1) NULL,
	[Permit_No] [nvarchar](1) NULL,
	[Release_Date] [nvarchar](1) NULL,
	[Sellable] [nvarchar](50) NOT NULL,
	[Model_Est_Sq_Ft] [nvarchar](50) NOT NULL,
	[Curr_Hist] [nvarchar](50) NOT NULL,
	[Lot_Status] [nvarchar](50) NOT NULL,
	[Lot_Type] [nvarchar](50) NOT NULL,
	[Type] [nvarchar](1) NULL,
	[Shell_Lot] [nvarchar](1) NULL,
	[Unit] [nvarchar](1) NULL,
	[Legal_Suite] [nvarchar](1) NULL,
	[Legal_Floor] [nvarchar](1) NULL,
	[of_Parking_s] [nvarchar](50) NOT NULL,
	[of_Storage_s] [nvarchar](50) NOT NULL,
	[Plan_No] [nvarchar](1) NULL
) ON [PRIMARY]
GO

