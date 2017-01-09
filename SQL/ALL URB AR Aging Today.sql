USE [BI Staging];

SELECT
TRAMT as "Amount"
,Entity
,TRPDAT as "Charge Date"
,TRPDAT as "Posting Date"
,ISNULL(FinancialClass, 'Unknown') as "Financial Class"
,TRFAM# as "Account"
,'CPU' as "Source"

INTO #transactions

FROM
CPU_TRANS
LEFT JOIN SS_CPU_InsuranceToFinancialClass
ON TIIN#1 = InsuranceNumber

WHERE TRTYPE LIKE 'C'

UNION ALL

SELECT
DETAPAMT as "Amount"
,CPU_DETAIL.Entity
,ISNULL(Chg.TRPDAT, PayAndAdj.TRPDAT) as "Charge Date"
,PayAndAdj.TRPDAT as "Posting Date"
,CASE
WHEN Chg.TIIN#1 IS NOT NULL THEN ISNULL(ChgFinancialClass.FinancialClass, 'Unknown')
ELSE ISNULL(PayAndAdjFinancialClass.FinancialClass, 'Unknown')
END as "Financial Class"
,DETFAM# as "Account"
,'CPU' as "Source"


FROM
CPU_DETAIL
LEFT JOIN CPU_TRANS as "Chg"
ON CPU_DETAIL.DETCHGSEQ = Chg.TRSEQ# AND CPU_DETAIL.DETFAM# = Chg.TRFAM# AND CPU_DETAIL.Entity LIKE Chg.Entity
LEFT JOIN CPU_TRANS as "PayAndAdj"
ON CPU_DETAIL.DETCRDSEQ = PayAndAdj.TRSEQ# AND CPU_DETAIL.DETFAM# = PayAndAdj.TRFAM# AND CPU_DETAIL.Entity LIKE PayAndAdj.Entity
LEFT JOIN SS_CPU_InsuranceToFinancialClass as "ChgFinancialClass"
ON Chg.TIIN#1 = ChgFinancialClass.InsuranceNumber
LEFT JOIN SS_CPU_InsuranceToFinancialClass as "PayAndAdjFinancialClass"
ON PayAndAdj.TIIN#1 = PayAndAdjFinancialClass.InsuranceNumber

WHERE DETTYPE NOT LIKE 'D'

UNION ALL

SELECT
IVC_PatientVisitProcs.TotalFee as "Amount"
,CASE
WHEN IVC_PatientVisit.CompanyId = 4 THEN 'IVC'
ELSE 'UVU'
END as "Entity"
,IVC_PatientVisitProcs.DateOfEntry as "Charge Date"
,IVC_PatientVisitProcs.DateOfEntry as "Posting Date"
,ISNULL(FinancialClass, 'Unknown') as "Financial Class"
,IVC_PatientVisit.PatientProfileId as "Account"
,'Centricity' as "Source"


FROM
IVC_PatientVisitProcs
LEFT JOIN IVC_PatientVisit
ON IVC_PatientVisitProcs.PatientVisitId = IVC_PatientVisit.PatientVisitId
LEFT JOIN SS_IVC_InsuranceToFinancialClass
ON IVC_PatientVisit.PrimaryInsuranceCarriersId = SS_IVC_InsuranceToFinancialClass.InsuranceNumber

WHERE IVC_PatientVisit.CompanyId <> 3

UNION ALL

SELECT
-1*IVC_Transactions.Amount as "Amount"
,CASE
WHEN IVC_PatientVisit.CompanyId = 4 THEN 'IVC'
ELSE 'UVU'
END as "Entity"
,ISNULL(IVC_PatientVisitProcs.DateOfEntry, IVC_PaymentMethod.DateOfEntry) as "Service Date"
,IVC_PaymentMethod.DateOfEntry as "Posting Date"
,ISNULL(FinancialClass, 'Unknown') as "Financial Class"
,IVC_PatientVisit.PatientProfileId as "Account"
,'Centricity' as "Source"

FROM
IVC_Transactions
LEFT JOIN IVC_VisitTransactions
ON IVC_Transactions.VisitTransactionsId = IVC_VisitTransactions.VisitTransactionsId
LEFT JOIN IVC_PaymentMethod
ON IVC_VisitTransactions.PaymentMethodId = IVC_PaymentMethod.PaymentMethodId
LEFT JOIN IVC_PatientVisit
ON IVC_VisitTransactions.PatientVisitid = IVC_PatientVisit.PatientVisitId
LEFT JOIN IVC_PatientVisitProcs
ON IVC_PatientVisit.PatientVisitId = IVC_PatientVisitProcs.PatientVisitId AND IVC_PatientVisitProcs.ListOrder = 1
LEFT JOIN SS_IVC_InsuranceToFinancialClass
ON IVC_PatientVisit.PrimaryInsuranceCarriersId = SS_IVC_InsuranceToFinancialClass.InsuranceNumber

WHERE (IVC_Transactions.Action LIKE 'P' OR IVC_Transactions.Action LIKE 'A')
AND IVC_PatientVisit.CompanyId <> 3




SELECT
date_id as "Date"
,#transactions.Entity as "Entity"
,[Financial Class] as "Financial Class"
,SUM(Amount) as "Amount"
,CASE
WHEN [Charge Date] >= DATEADD(DAY,-30,date_id)															THEN 'Current'
WHEN [Charge Date] <  DATEADD(DAY,-30,date_id)		AND [Charge Date] >= DATEADD(DAY,-60,date_id)		THEN '31 to 60'
WHEN [Charge Date] <  DATEADD(DAY,-60,date_id)		AND [Charge Date] >= DATEADD(DAY,-90,date_id)		THEN '61 to 90'
WHEN [Charge Date] <  DATEADD(DAY,-90,date_id)		AND [Charge Date] >= DATEADD(DAY,-120,date_id)		THEN '91 to 120'
WHEN [Charge Date] <  DATEADD(DAY,-120,date_id)		AND [Charge Date] >= DATEADD(DAY,-150,date_id)		THEN '121 to 150'
WHEN [Charge Date] <  DATEADD(DAY,-150,date_id)															THEN 'Over 150'
END as "Bucket"
,CASE
WHEN [Charge Date] >= DATEADD(DAY,-30,date_id)															THEN 1
WHEN [Charge Date] <  DATEADD(DAY,-30,date_id)		AND [Charge Date] >= DATEADD(DAY,-60,date_id)		THEN 2
WHEN [Charge Date] <  DATEADD(DAY,-60,date_id)		AND [Charge Date] >= DATEADD(DAY,-90,date_id)		THEN 3
WHEN [Charge Date] <  DATEADD(DAY,-90,date_id)		AND [Charge Date] >= DATEADD(DAY,-120,date_id)		THEN 4
WHEN [Charge Date] <  DATEADD(DAY,-120,date_id)		AND [Charge Date] >= DATEADD(DAY,-150,date_id)		THEN 5
WHEN [Charge Date] <  DATEADD(DAY,-150,date_id)															THEN 6
END as "Ordering"
,'False' as "Overpayments"

FROM
Dates
LEFT JOIN #transactions
ON Dates.date_id > #transactions.[Posting Date]

WHERE Dates.date_id = CAST(GETDATE() as DATE)

GROUP BY date_id
,#transactions.Entity
,[Financial Class]
,CASE
WHEN [Charge Date] >= DATEADD(DAY,-30,date_id)															THEN 'Current'
WHEN [Charge Date] <  DATEADD(DAY,-30,date_id)		AND [Charge Date] >= DATEADD(DAY,-60,date_id)		THEN '31 to 60'
WHEN [Charge Date] <  DATEADD(DAY,-60,date_id)		AND [Charge Date] >= DATEADD(DAY,-90,date_id)		THEN '61 to 90'
WHEN [Charge Date] <  DATEADD(DAY,-90,date_id)		AND [Charge Date] >= DATEADD(DAY,-120,date_id)		THEN '91 to 120'
WHEN [Charge Date] <  DATEADD(DAY,-120,date_id)		AND [Charge Date] >= DATEADD(DAY,-150,date_id)		THEN '121 to 150'
WHEN [Charge Date] <  DATEADD(DAY,-150,date_id)															THEN 'Over 150'
END
,CASE
WHEN [Charge Date] >= DATEADD(DAY,-30,date_id)															THEN 1
WHEN [Charge Date] <  DATEADD(DAY,-30,date_id)		AND [Charge Date] >= DATEADD(DAY,-60,date_id)		THEN 2
WHEN [Charge Date] <  DATEADD(DAY,-60,date_id)		AND [Charge Date] >= DATEADD(DAY,-90,date_id)		THEN 3
WHEN [Charge Date] <  DATEADD(DAY,-90,date_id)		AND [Charge Date] >= DATEADD(DAY,-120,date_id)		THEN 4
WHEN [Charge Date] <  DATEADD(DAY,-120,date_id)		AND [Charge Date] >= DATEADD(DAY,-150,date_id)		THEN 5
WHEN [Charge Date] <  DATEADD(DAY,-150,date_id)															THEN 6
END


UNION ALL

SELECT
date_id as "Date"
,#Overpayments.Entity as "Entity"
,ISNULL(FCDESC, [CPU or Financial Class]) as "Financial Class"
,-1*SUM(Amount) as "Amount"
,CASE
WHEN [Charge Date] >= DATEADD(DAY,-30,date_id)															THEN 'Current'
WHEN [Charge Date] <  DATEADD(DAY,-30,date_id)		AND [Charge Date] >= DATEADD(DAY,-60,date_id)		THEN '31 to 60'
WHEN [Charge Date] <  DATEADD(DAY,-60,date_id)		AND [Charge Date] >= DATEADD(DAY,-90,date_id)		THEN '61 to 90'
WHEN [Charge Date] <  DATEADD(DAY,-90,date_id)		AND [Charge Date] >= DATEADD(DAY,-120,date_id)		THEN '91 to 120'
WHEN [Charge Date] <  DATEADD(DAY,-120,date_id)		AND [Charge Date] >= DATEADD(DAY,-150,date_id)		THEN '121 to 150'
WHEN [Charge Date] <  DATEADD(DAY,-150,date_id)															THEN 'Over 150'
END as "Bucket"
,CASE
WHEN [Charge Date] >= DATEADD(DAY,-30,date_id)															THEN 1
WHEN [Charge Date] <  DATEADD(DAY,-30,date_id)		AND [Charge Date] >= DATEADD(DAY,-60,date_id)		THEN 2
WHEN [Charge Date] <  DATEADD(DAY,-60,date_id)		AND [Charge Date] >= DATEADD(DAY,-90,date_id)		THEN 3
WHEN [Charge Date] <  DATEADD(DAY,-90,date_id)		AND [Charge Date] >= DATEADD(DAY,-120,date_id)		THEN 4
WHEN [Charge Date] <  DATEADD(DAY,-120,date_id)		AND [Charge Date] >= DATEADD(DAY,-150,date_id)		THEN 5
WHEN [Charge Date] <  DATEADD(DAY,-150,date_id)															THEN 6
END as "Ordering"
,'True' as "Overpayments"

FROM
(SELECT
	date_id
	,SUM(Amount) as "Amount"
	,CASE
	WHEN [Source] LIKE 'CPU' THEN Source
	ELSE [Financial Class]
	END as "CPU or Financial Class"
	,Entity
	,Account
	,MIN([Charge Date]) as "Charge Date"

	FROM
	Dates
	LEFT JOIN #transactions
	ON Dates.date_id > #transactions.[Posting Date]

	WHERE Dates.date_id = CAST(GETDATE() as DATE)
	
	GROUP BY date_id
	,CASE
	WHEN [Source] LIKE 'CPU' THEN Source
	ELSE [Financial Class]
	END
	,Entity
	,Account

	HAVING SUM(Amount) < 0
	) as "#Overpayments"
LEFT JOIN CPU_FAMLY
ON #Overpayments.[CPU or Financial Class] LIKE 'CPU' AND #Overpayments.Entity LIKE CPU_FAMLY.Entity AND Account = FMNUM
LEFT JOIN CPU_BS70_FCLAS
ON FMCLAS = FCNUM

GROUP BY
date_id
,#Overpayments.Entity
,ISNULL(FCDESC, [CPU or Financial Class])
,CASE
WHEN [Charge Date] >= DATEADD(DAY,-30,date_id)															THEN 'Current'
WHEN [Charge Date] <  DATEADD(DAY,-30,date_id)		AND [Charge Date] >= DATEADD(DAY,-60,date_id)		THEN '31 to 60'
WHEN [Charge Date] <  DATEADD(DAY,-60,date_id)		AND [Charge Date] >= DATEADD(DAY,-90,date_id)		THEN '61 to 90'
WHEN [Charge Date] <  DATEADD(DAY,-90,date_id)		AND [Charge Date] >= DATEADD(DAY,-120,date_id)		THEN '91 to 120'
WHEN [Charge Date] <  DATEADD(DAY,-120,date_id)		AND [Charge Date] >= DATEADD(DAY,-150,date_id)		THEN '121 to 150'
WHEN [Charge Date] <  DATEADD(DAY,-150,date_id)															THEN 'Over 150'
END
,CASE
WHEN [Charge Date] >= DATEADD(DAY,-30,date_id)															THEN 1
WHEN [Charge Date] <  DATEADD(DAY,-30,date_id)		AND [Charge Date] >= DATEADD(DAY,-60,date_id)		THEN 2
WHEN [Charge Date] <  DATEADD(DAY,-60,date_id)		AND [Charge Date] >= DATEADD(DAY,-90,date_id)		THEN 3
WHEN [Charge Date] <  DATEADD(DAY,-90,date_id)		AND [Charge Date] >= DATEADD(DAY,-120,date_id)		THEN 4
WHEN [Charge Date] <  DATEADD(DAY,-120,date_id)		AND [Charge Date] >= DATEADD(DAY,-150,date_id)		THEN 5
WHEN [Charge Date] <  DATEADD(DAY,-150,date_id)															THEN 6
END



DROP TABLE #transactions