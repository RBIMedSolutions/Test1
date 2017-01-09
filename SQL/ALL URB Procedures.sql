USE [BI Staging];

SET CONCAT_NULL_YIELDS_NULL OFF

--Temp table to aggregate transaction info for Centricity
SELECT
IVC_TransactionDistributions.PatientVisitProcsId
,SUM(CASE WHEN IVC_Transactions.Action LIKE 'P' THEN IVC_TransactionDistributions.Amount ELSE 0 END) as 'Payment Amount'
,SUM(CASE WHEN IVC_Transactions.Action LIKE 'A' THEN IVC_TransactionDistributions.Amount ELSE 0 END) as 'Adjustment Amount'
,MAX(IVC_PaymentMethod.DateOfEntry) as "Latest Payment"

INTO #Transactions

FROM
IVC_TransactionDistributions
LEFT JOIN IVC_Transactions
ON IVC_TransactionDistributions.TransactionsId = IVC_Transactions.TransactionsId
LEFT JOIN IVC_VisitTransactions
ON IVC_Transactions.VisitTransactionsId = IVC_VisitTransactions.VisitTransactionsId
LEFT JOIN IVC_PaymentMethod
ON IVC_VisitTransactions.PaymentMethodId = IVC_PaymentMethod.PaymentMethodId

WHERE
(IVC_Transactions.Action LIKE 'P' OR IVC_Transactions.Action LIKE 'A')
AND IVC_PaymentMethod.DateOfEntry <= GETDATE()

GROUP BY
IVC_TransactionDistributions.PatientVisitProcsId





--Getting CPU Data
SELECT
CPU_TRANS.TRAMT
,CPU_TRANS.TRQTY
,CPU_TRANS.TRTDAT
,CPU_TRANS.TRPDAT
,CPU_TRANS.Entity
,CPU_TRANS.TRCODE
,CPU_TRANS.TRLOC
,CPU_TRANS.TRADR#
,CPU_TRANS.TRRDR#
,CPU_TRANS.TRNORD
,CPU_TRANS.TRNPCP
,CPU_TRANS.TRFAM#
,CPU_TRANS.TIPMT$
,CPU_TRANS.TIADJ$
,CPU_TRANS.TRMBR#
,CPU_TRANS.TIIN#1
,CPU_TRANS.TRDIAG
,CPU_TRANS.TRDIG2
,CPU_TRANS.TRDIG3
,CPU_TRANS.TRDIG4
,CASE
WHEN CPU_CHARG_loc.CHMCD1 IS NOT NULL THEN CPU_CHARG_loc.CHMCD1
ELSE CPU_CHARG_noloc.CHMCD1
END as 'CHMCD1'
,CASE
WHEN CPU_CHARG_loc.CHMCD1 IS NOT NULL THEN CPU_CHARG_loc.CHTYPE
ELSE CPU_CHARG_noloc.CHTYPE
END as 'CHTYPE'
,CASE
WHEN CPU_CHARG_loc.CHMCD1 IS NOT NULL THEN CPU_CHARG_loc.CHSUBT
ELSE CPU_CHARG_noloc.CHSUBT
END as 'CHSUBT'
,CASE
WHEN CPU_CHARG_loc.CHMCD1 IS NOT NULL THEN CPU_CHARG_loc.CHDESC
ELSE CPU_CHARG_noloc.CHDESC
END as 'CHDESC'
,MAX(Pay.TRPDAT) as "Latest Payment"



INTO #CPU_TRANSandCHARG

FROM
CPU_TRANS
LEFT JOIN CPU_CHARG as "CPU_CHARG_loc"
ON CPU_TRANS.TRCODE = CPU_CHARG_loc.CHCOD AND CPU_TRANS.TRLOC = CPU_CHARG_loc.CHLOC AND CPU_TRANS.Entity LIKE CPU_CHARG_loc.Entity
LEFT JOIN CPU_CHARG as "CPU_CHARG_noloc"
ON CPU_TRANS.TRCODE = CPU_CHARG_noloc.CHCOD AND 1 = CPU_CHARG_noloc.CHLOC AND CPU_TRANS.Entity LIKE CPU_CHARG_noloc.Entity
LEFT JOIN CPU_DETAIL
ON CPU_TRANS.TRFAM# = CPU_DETAIL.DETFAM# AND CPU_TRANS.TRSEQ# = CPU_DETAIL.DETCHGSEQ AND CPU_TRANS.Entity LIKE CPU_DETAIL.Entity
LEFT JOIN CPU_TRANS as "Pay"
ON CPU_DETAIL.DETFAM# = Pay.TRFAM# AND CPU_DETAIL.DETCRDSEQ = Pay.TRSEQ#

WHERE CPU_TRANS.TRTYPE = 'C'
AND CPU_TRANS.TRFAM# <> 999999998

GROUP BY
CPU_TRANS.TRAMT
,CPU_TRANS.TRQTY
,CPU_TRANS.TRTDAT
,CPU_TRANS.TRPDAT
,CPU_TRANS.Entity
,CPU_TRANS.TRCODE
,CPU_TRANS.TRLOC
,CPU_TRANS.TRADR#
,CPU_TRANS.TRRDR#
,CPU_TRANS.TRNORD
,CPU_TRANS.TRNPCP
,CPU_TRANS.TRFAM#
,CPU_TRANS.TIPMT$
,CPU_TRANS.TIADJ$
,CPU_TRANS.TRMBR#
,CPU_TRANS.TIIN#1
,CPU_TRANS.TRDIAG
,CPU_TRANS.TRDIG2
,CPU_TRANS.TRDIG3
,CPU_TRANS.TRDIG4
,CASE
WHEN CPU_CHARG_loc.CHMCD1 IS NOT NULL THEN CPU_CHARG_loc.CHMCD1
ELSE CPU_CHARG_noloc.CHMCD1
END
,CASE
WHEN CPU_CHARG_loc.CHMCD1 IS NOT NULL THEN CPU_CHARG_loc.CHTYPE
ELSE CPU_CHARG_noloc.CHTYPE
END
,CASE
WHEN CPU_CHARG_loc.CHMCD1 IS NOT NULL THEN CPU_CHARG_loc.CHSUBT
ELSE CPU_CHARG_noloc.CHSUBT
END
,CASE
WHEN CPU_CHARG_loc.CHMCD1 IS NOT NULL THEN CPU_CHARG_loc.CHDESC
ELSE CPU_CHARG_noloc.CHDESC
END



SELECT
TRAMT
,TRQTY
,TRTDAT
,TRPDAT
,#CPU_TRANSandCHARG.Entity
,TRCODE
,TRLOC
,TRADR#
,TRNORD
,TRNPCP
,TRFAM#
,TIPMT$
,TIADJ$
,CHMCD1
,CHTYPE
,CHSUBT
,CHDESC
,TRMBR#
,TIIN#1
,TRDIAG
,TRDIG2
,TRDIG3
,TRDIG4
,[Latest Payment]
,ISNULL(CPU_DOCTR_loc.DRUPIN, CPU_DOCTR_noloc.DRUPIN) as "DRUPIN"
,CASE
WHEN PATINDEX('%[^,] %', CPU_DOCTR_loc.DRNAME) > 0 THEN LEFT(CPU_DOCTR_loc.DRNAME, PATINDEX('%[^,] %', CPU_DOCTR_loc.DRNAME))
WHEN PATINDEX('%[^,] %', CPU_DOCTR_noloc.DRNAME) > 0 THEN LEFT(CPU_DOCTR_noloc.DRNAME, PATINDEX('%[^,] %', CPU_DOCTR_noloc.DRNAME))
WHEN CPU_DOCTR_loc.DRNAME IS NOT NULL THEN CPU_DOCTR_loc.DRNAME
ELSE CPU_DOCTR_noloc.DRNAME
END as 'Referring Physician'

INTO #CPU_TRANSandCHARGandDOCTR

FROM
#CPU_TRANSandCHARG
LEFT JOIN CPU_DOCTR as "CPU_DOCTR_loc"
ON #CPU_TRANSandCHARG.TRRDR# = CPU_DOCTR_loc.DRNUM AND #CPU_TRANSandCHARG.TRLOC = CPU_DOCTR_loc.DRLOC AND #CPU_TRANSandCHARG.Entity LIKE CPU_DOCTR_loc.Entity
LEFT JOIN CPU_DOCTR as "CPU_DOCTR_noloc"
ON #CPU_TRANSandCHARG.TRRDR# = CPU_DOCTR_noloc.DRNUM AND 1 = CPU_DOCTR_noloc.DRLOC AND #CPU_TRANSandCHARG.Entity LIKE CPU_DOCTR_noloc.Entity



SELECT
TRFAM# as "Account Number"
,CHMCD1 as "CPT Code"
,CHDESC as "Description"
,CTDESC as "Category"
,TRTDAT as "Date of Service"
,TRPDAT as "Date of Entry"
,CASE
WHEN CPU_DOCTR_TRNPCP.DRNAME IS NOT NULL AND LEN(CPU_DOCTR_TRNPCP.DRNAME) > 1
	THEN LEFT(CPU_DOCTR_TRNPCP.DRNAME, PATINDEX('%[^,] %', CPU_DOCTR_TRNPCP.DRNAME))
WHEN CPU_DOCTR_TRNPCP.DRNAME IS NOT NULL AND #CPU_TRANSandCHARGandDOCTR.TRNPCP <> 0 THEN CPU_DOCTR_TRNPCP.DRNAME
WHEN LEN(CPU_DOCTR_TRADR#.DRNAME) > 1 THEN LEFT(CPU_DOCTR_TRADR#.DRNAME, PATINDEX('%[^,] %', CPU_DOCTR_TRADR#.DRNAME))
ELSE CPU_DOCTR_TRADR#.DRNAME
END as "Performing Physician"
,#CPU_TRANSandCHARGandDOCTR.[Referring Physician] as "Referring Physician"
--,TaskAccount.NAME as "Referring Organization"
--,TaskAccount.LKL3__Practice_Type__c as "Referring Organization Type"
--,ISNULL(ParentAccount.NAME, TaskAccount.NAME) as "Referring Parent Organization"
--,TaskAccount.GROUP__C as "Medical Group"
,CASE
WHEN CPU_DOCTR_TRNORD.DRNAME IS NOT NULL AND LEN(CPU_DOCTR_TRNORD.DRNAME) > 1
	THEN LEFT(CPU_DOCTR_TRNORD.DRNAME, PATINDEX('%[^,] %', CPU_DOCTR_TRNORD.DRNAME))
WHEN CPU_DOCTR_TRNORD.DRNAME IS NOT NULL AND #CPU_TRANSandCHARGandDOCTR.TRNORD <> 0 THEN CPU_DOCTR_TRNORD.DRNAME
END as "Supervising Physician"
,CASE
WHEN TRAMT < 0 THEN -1*TRQTY
ELSE TRQTY
END as "Quantity"
,TRAMT as "Charges"
,-1*TIPMT$ as 'Payments'
,-1*TIADJ$ as 'Adjustments'
,InsuranceName  as "Insurance"
,ISNULL(FinancialClass, 'Unknown') as "Financial Class"
,CASE
WHEN TRAMT + TIPMT$ + TIADJ$ = 0 THEN 'Paid'
WHEN TRAMT + TIPMT$ + TIADJ$ > 0 THEN 'Not Paid'
WHEN TRAMT + TIPMT$ + TIADJ$ < 0 THEN 'Overpaid'
END as 'Payment Status'
,[Latest Payment]
,CASE
WHEN #CPU_TRANSandCHARGandDOCTR.Entity LIKE 'PM' AND #CPU_TRANSandCHARGandDOCTR.TRLOC = 1
THEN CASE
	WHEN TRCODE = 411 THEN 'Medical-UVPM'
	WHEN TRCODE = 430 THEN 'UVPM'
	WHEN TRCODE = 431 THEN 'UVPM'
	WHEN TRCODE = 434 THEN 'UVPM'
	WHEN TRCODE = 518 THEN 'UVPM'
	WHEN TRCODE = 585 THEN 'Botox (Medical)-UVPM'
	WHEN TRCODE = 600 THEN 'UVPM'
	WHEN TRCODE = 621 THEN 'PT-UVPM'
	WHEN TRCODE = 631 THEN 'PT-UVPM'
	WHEN TRCODE = 666 THEN 'UVPM'
	WHEN TRCODE = 700 THEN 'Psych-UVPM'
	WHEN TRCODE = 777 THEN 'UVPM'
	WHEN TRCODE = 800 THEN 'EMG-UVPM'
	WHEN TRCODE = 900 THEN 'UVPM'
	WHEN TRCODE = 950 THEN 'UVPM'
	WHEN TRCODE = 999 THEN 'UVPM'
	WHEN TRCODE = 1100 THEN 'UVPM'
	WHEN TRCODE = 1101 THEN 'UVPM'
	WHEN TRCODE = 1845 THEN 'PT-UVPM'
	WHEN TRCODE = 1885 THEN 'Medical-UVPM'
	WHEN TRCODE = 3288 THEN 'UVPM'
	WHEN TRCODE = 3807 THEN 'PT-UVPM'
	WHEN TRCODE = 3908 THEN 'PT-UVPM'
	WHEN TRCODE = 3915 THEN 'PT-UVPM'
	WHEN TRCODE = 4595 THEN 'PT-UVPM'
	WHEN TRCODE = 6040 THEN 'Medical-UVPM'
	WHEN TRCODE = 6666 THEN 'UVPM'
	WHEN TRCODE = 7335 THEN 'Medical-UVPM'
	WHEN TRCODE = 8427 THEN 'UVPM'
	WHEN TRCODE = 8431 THEN 'UVPM'
	WHEN TRCODE = 8510 THEN 'UVPM'
	WHEN TRCODE = 8539 THEN 'UVPM'
	WHEN TRCODE = 8540 THEN 'UVPM'
	WHEN TRCODE = 8542 THEN 'UVPM'
	WHEN TRCODE = 8553 THEN 'UVPM'
	WHEN TRCODE = 8730 THEN 'UVPM'
	WHEN TRCODE = 8978 THEN 'PT-UVPM'
	WHEN TRCODE = 8979 THEN 'PT-UVPM'
	WHEN TRCODE = 8980 THEN 'PT-UVPM'
	WHEN TRCODE = 8981 THEN 'PT-UVPM'
	WHEN TRCODE = 8982 THEN 'PT-UVPM'
	WHEN TRCODE = 8983 THEN 'PT-UVPM'
	WHEN TRCODE = 8984 THEN 'PT-UVPM'
	WHEN TRCODE = 8985 THEN 'PT-UVPM'
	WHEN TRCODE = 8986 THEN 'PT-UVPM'
	WHEN TRCODE = 8987 THEN 'PT-UVPM'
	WHEN TRCODE = 8988 THEN 'PT-UVPM'
	WHEN TRCODE = 8989 THEN 'PT-UVPM'
	WHEN TRCODE = 8990 THEN 'PT-UVPM'
	WHEN TRCODE = 8991 THEN 'PT-UVPM'
	WHEN TRCODE = 8992 THEN 'PT-UVPM'
	WHEN TRCODE = 9070 THEN 'Medical-UVPM'
	WHEN TRCODE = 9907 THEN 'Psych-UVPM'
	WHEN TRCODE = 9981 THEN 'UVPM'
	WHEN TRCODE = 9988 THEN 'UVPM'
	WHEN TRCODE = 9998 THEN 'UVPM'
	WHEN TRCODE = 9999 THEN 'UVPM'
	WHEN TRCODE = 20550 THEN 'Medical-UVPM'
	WHEN TRCODE = 20551 THEN 'Medical-UVPM'
	WHEN TRCODE = 20552 THEN 'Medical-UVPM'
	WHEN TRCODE = 20553 THEN 'Medical-UVPM'
	WHEN TRCODE = 20605 THEN 'Medical-UVPM'
	WHEN TRCODE = 20610 THEN 'Medical-UVPM'
	WHEN TRCODE = 64405 THEN 'Medical-UVPM'
	WHEN TRCODE = 64450 THEN 'Medical-UVPM'
	WHEN TRCODE = 64505 THEN 'Medical-UVPM'
	WHEN TRCODE = 64550 THEN 'PT-UVPM'
	WHEN TRCODE = 64612 THEN 'Botox (Medical)-UVPM'
	WHEN TRCODE = 64613 THEN 'Botox (Medical)-UVPM'
	WHEN TRCODE = 64614 THEN 'Botox (Medical)-UVPM'
	WHEN TRCODE = 64615 THEN 'Botox (Medical)-UVPM'
	WHEN TRCODE = 64616 THEN 'Botox (Medical)-UVPM'
	WHEN TRCODE = 64999 THEN 'Medical-UVPM'
	WHEN TRCODE = 77002 THEN 'Medical-UVPM'
	WHEN TRCODE = 80101 THEN 'UVPM'
	WHEN TRCODE = 80104 THEN 'UVPM'
	WHEN TRCODE = 80301 THEN 'UVPM'
	WHEN TRCODE = 81003 THEN 'UVPM'
	WHEN TRCODE = 82055 THEN 'UVPM'
	WHEN TRCODE = 82570 THEN 'UVPM'
	WHEN TRCODE = 83986 THEN 'UVPM'
	WHEN TRCODE = 84311 THEN 'UVPM'
	WHEN TRCODE = 85610 THEN 'UVPM'
	WHEN TRCODE = 90785 THEN 'Psych-UVPM'
	WHEN TRCODE = 90791 THEN 'Psych-UVPM'
	WHEN TRCODE = 90792 THEN 'Psych-UVPM'
	WHEN TRCODE = 90801 THEN 'Psych-UVPM'
	WHEN TRCODE = 90804 THEN 'Psych-UVPM'
	WHEN TRCODE = 90806 THEN 'Psych-UVPM'
	WHEN TRCODE = 90808 THEN 'Psych-UVPM'
	WHEN TRCODE = 90832 THEN 'Psych-UVPM'
	WHEN TRCODE = 90834 THEN 'Psych-UVPM'
	WHEN TRCODE = 90837 THEN 'Psych-UVPM'
	WHEN TRCODE = 90839 THEN 'Psych-UVPM'
	WHEN TRCODE = 90847 THEN 'Psych-UVPM'
	WHEN TRCODE = 90853 THEN 'Psych-UVPM'
	WHEN TRCODE = 90875 THEN 'Psych-UVPM'
	WHEN TRCODE = 90876 THEN 'Psych-UVPM'
	WHEN TRCODE = 90901 THEN 'PT-UVPM'
	WHEN TRCODE = 95860 THEN 'EMG-UVPM'
	WHEN TRCODE = 95861 THEN 'EMG-UVPM'
	WHEN TRCODE = 95863 THEN 'EMG-UVPM'
	WHEN TRCODE = 95867 THEN 'EMG-UVPM'
	WHEN TRCODE = 95869 THEN 'EMG-UVPM'
	WHEN TRCODE = 95870 THEN 'EMG-UVPM'
	WHEN TRCODE = 95874 THEN 'Botox (Medical)-UVPM'
	WHEN TRCODE = 95885 THEN 'EMG-UVPM'
	WHEN TRCODE = 95886 THEN 'EMG-UVPM'
	WHEN TRCODE = 95887 THEN 'EMG-UVPM'
	WHEN TRCODE = 95888 THEN 'EMG-UVPM'
	WHEN TRCODE = 95900 THEN 'EMG-UVPM'
	WHEN TRCODE = 95903 THEN 'EMG-UVPM'
	WHEN TRCODE = 95904 THEN 'EMG-UVPM'
	WHEN TRCODE = 95907 THEN 'EMG-UVPM'
	WHEN TRCODE = 95908 THEN 'EMG-UVPM'
	WHEN TRCODE = 95909 THEN 'EMG-UVPM'
	WHEN TRCODE = 95910 THEN 'EMG-UVPM'
	WHEN TRCODE = 95911 THEN 'EMG-UVPM'
	WHEN TRCODE = 95912 THEN 'EMG-UVPM'
	WHEN TRCODE = 95913 THEN 'EMG-UVPM'
	WHEN TRCODE = 95933 THEN 'EMG-UVPM'
	WHEN TRCODE = 95934 THEN 'EMG-UVPM'
	WHEN TRCODE = 95936 THEN 'EMG-UVPM'
	WHEN TRCODE = 95937 THEN 'EMG-UVPM'
	WHEN TRCODE = 95970 THEN 'Medical-UVPM'
	WHEN TRCODE = 95972 THEN 'Medical-UVPM'
	WHEN TRCODE = 95973 THEN 'Medical-UVPM'
	WHEN TRCODE = 96101 THEN 'Psych-UVPM'
	WHEN TRCODE = 96103 THEN 'Psych-UVPM'
	WHEN TRCODE = 96118 THEN 'Psych-UVPM'
	WHEN TRCODE = 96152 THEN 'Psych-UVPM'
	WHEN TRCODE = 96372 THEN 'Medical-UVPM'
	WHEN TRCODE = 96999 THEN 'Medical-UVPM'
	WHEN TRCODE = 97001 THEN 'PT-UVPM'
	WHEN TRCODE = 97002 THEN 'PT-UVPM'
	WHEN TRCODE = 97012 THEN 'PT-UVPM'
	WHEN TRCODE = 97014 THEN 'PT-UVPM'
	WHEN TRCODE = 97033 THEN 'PT-UVPM'
	WHEN TRCODE = 97035 THEN 'PT-UVPM'
	WHEN TRCODE = 97110 THEN 'PT-UVPM'
	WHEN TRCODE = 97112 THEN 'PT-UVPM'
	WHEN TRCODE = 97116 THEN 'PT-UVPM'
	WHEN TRCODE = 97124 THEN 'PT-UVPM'
	WHEN TRCODE = 97140 THEN 'PT-UVPM'
	WHEN TRCODE = 97530 THEN 'PT-UVPM'
	WHEN TRCODE = 97535 THEN 'PT-UVPM'
	WHEN TRCODE = 97545 THEN 'PT-UVPM'
	WHEN TRCODE = 97750 THEN 'PT-UVPM'
	WHEN TRCODE = 97760 THEN 'PT-UVPM'
	WHEN TRCODE = 99070 THEN 'PT-UVPM'
	WHEN TRCODE = 99080 THEN 'UVPM'
	WHEN TRCODE = 99201 THEN 'Medical-UVPM'
	WHEN TRCODE = 99202 THEN 'Medical-UVPM'
	WHEN TRCODE = 99203 THEN 'Medical-UVPM'
	WHEN TRCODE = 99204 THEN 'Medical-UVPM'
	WHEN TRCODE = 99205 THEN 'Medical-UVPM'
	WHEN TRCODE = 99211 THEN 'Medical-UVPM'
	WHEN TRCODE = 99212 THEN 'Medical-UVPM'
	WHEN TRCODE = 99213 THEN 'Medical-UVPM'
	WHEN TRCODE = 99214 THEN 'Medical-UVPM'
	WHEN TRCODE = 99215 THEN 'Medical-UVPM'
	WHEN TRCODE = 99223 THEN 'Medical-UVPM'
	WHEN TRCODE = 99231 THEN 'Medical-UVPM'
	WHEN TRCODE = 99232 THEN 'Medical-UVPM'
	WHEN TRCODE = 99233 THEN 'Medical-UVPM'
	WHEN TRCODE = 99241 THEN 'Medical-UVPM'
	WHEN TRCODE = 99242 THEN 'Medical-UVPM'
	WHEN TRCODE = 99243 THEN 'Medical-UVPM'
	WHEN TRCODE = 99244 THEN 'Medical-UVPM'
	WHEN TRCODE = 99245 THEN 'Medical-UVPM'
	WHEN TRCODE = 99349 THEN 'Medical-UVPM'
	WHEN TRCODE = 99354 THEN 'Medical-UVPM'
	WHEN TRCODE = 99355 THEN 'Medical-UVPM'
	WHEN TRCODE = 123456 THEN 'UVPM'
	WHEN TRCODE = 988888 THEN 'UVPM'
	WHEN TRCODE = 998877 THEN 'UVPM'
	ELSE 'UVPM'
	END
ELSE LONAME
END as 'Specific Location'
,CASE
WHEN #CPU_TRANSandCHARGandDOCTR.Entity LIKE 'CV' AND TRLOC = 1 THEN 'CENTRAL VALLEY MED CTR'
WHEN #CPU_TRANSandCHARGandDOCTR.Entity LIKE 'CV' AND TRLOC = 2 THEN 'CENTRAL VALLEY MED CTR'
WHEN #CPU_TRANSandCHARGandDOCTR.Entity LIKE 'CV' AND TRLOC = 3 THEN 'CENTRAL VALLEY MED CTR'
WHEN #CPU_TRANSandCHARGandDOCTR.Entity LIKE 'GV' AND TRLOC = 1 THEN 'GUNNISON VALLEY HOSPITAL'
WHEN #CPU_TRANSandCHARGandDOCTR.Entity LIKE 'GV' AND TRLOC = 2 THEN 'GUNNISON VALLEY HOSPITAL'
WHEN #CPU_TRANSandCHARGandDOCTR.Entity LIKE 'GV' AND TRLOC = 3 THEN 'GUNNISON VALLEY HOSPITAL'
WHEN #CPU_TRANSandCHARGandDOCTR.Entity LIKE 'PM' AND TRLOC = 1 THEN 'UTAH VALLEY PAIN MANAGEMENT'
WHEN #CPU_TRANSandCHARGandDOCTR.Entity LIKE 'PM' AND TRLOC = 2 THEN 'UTAH VALLEY PAIN MANAGEMENT - Nephi'
WHEN #CPU_TRANSandCHARGandDOCTR.Entity LIKE 'SG' AND TRLOC = 1 THEN 'DIXIE REG. MED. CTR.'
WHEN #CPU_TRANSandCHARGandDOCTR.Entity LIKE 'SG' AND TRLOC = 2 THEN 'DIXIE REG. MED. CTR.'
WHEN #CPU_TRANSandCHARGandDOCTR.Entity LIKE 'SG' AND TRLOC = 3 THEN 'DIXIE REG. MED. CTR.'
WHEN #CPU_TRANSandCHARGandDOCTR.Entity LIKE 'SG' AND TRLOC = 20 THEN 'DIXIE REG. MED. CTR.'
WHEN #CPU_TRANSandCHARGandDOCTR.Entity LIKE 'SG' AND TRLOC = 21 THEN 'DIXIE REG. MED. CTR.'
WHEN #CPU_TRANSandCHARGandDOCTR.Entity LIKE 'SJ' AND TRLOC = 1 THEN 'SAN JUAN HOSPITAL'
WHEN #CPU_TRANSandCHARGandDOCTR.Entity LIKE 'SJ' AND TRLOC = 2 THEN 'SAN JUAN HOSPITAL'
WHEN #CPU_TRANSandCHARGandDOCTR.Entity LIKE 'SJ' AND TRLOC = 3 THEN 'SAN JUAN HOSPITAL'
WHEN #CPU_TRANSandCHARGandDOCTR.Entity LIKE 'UVR' AND TRLOC = 1 THEN 'UTAH VALLEY REG MED CTR'
WHEN #CPU_TRANSandCHARGandDOCTR.Entity LIKE 'UVR' AND TRLOC = 2 THEN 'UTAH VALLEY REG MED CTR'
WHEN #CPU_TRANSandCHARGandDOCTR.Entity LIKE 'UVR' AND TRLOC = 3 THEN 'UTAH VALLEY REG MED CTR'
WHEN #CPU_TRANSandCHARGandDOCTR.Entity LIKE 'UVR' AND TRLOC = 4 THEN 'OREM COMMUNITY HOSPITAL'
WHEN #CPU_TRANSandCHARGandDOCTR.Entity LIKE 'UVR' AND TRLOC = 5 THEN 'OREM COMMUNITY HOSPITAL'
WHEN #CPU_TRANSandCHARGandDOCTR.Entity LIKE 'UVR' AND TRLOC = 6 THEN 'OREM COMMUNITY HOSPITAL'
WHEN #CPU_TRANSandCHARGandDOCTR.Entity LIKE 'UVR' AND TRLOC = 7 THEN 'AMERICAN FORK HOSPITAL'
WHEN #CPU_TRANSandCHARGandDOCTR.Entity LIKE 'UVR' AND TRLOC = 8 THEN 'AMERICAN FORK HOSPITAL'
WHEN #CPU_TRANSandCHARGandDOCTR.Entity LIKE 'UVR' AND TRLOC = 9 THEN 'AMERICAN FORK HOSPITAL'
WHEN #CPU_TRANSandCHARGandDOCTR.Entity LIKE 'UVR' AND TRLOC = 10 THEN 'CASTLE VIEW HOSPITAL'
WHEN #CPU_TRANSandCHARGandDOCTR.Entity LIKE 'UVR' AND TRLOC = 11 THEN 'CASTLE VIEW HOSPITAL'
WHEN #CPU_TRANSandCHARGandDOCTR.Entity LIKE 'UVR' AND TRLOC = 12 THEN 'CASTLE VIEW HOSPITAL'
WHEN #CPU_TRANSandCHARGandDOCTR.Entity LIKE 'UVR' AND TRLOC = 22 THEN 'NORTH OREM CLINIC'
WHEN #CPU_TRANSandCHARGandDOCTR.Entity LIKE 'UVR' AND TRLOC = 23 THEN 'NORTH OREM CLINIC'
WHEN #CPU_TRANSandCHARGandDOCTR.Entity LIKE 'UVR' AND TRLOC = 26 THEN 'HIGHLAND CLINIC'
WHEN #CPU_TRANSandCHARGandDOCTR.Entity LIKE 'UVR' AND TRLOC = 27 THEN 'HIGHLAND CLINIC'
ELSE LONAME
END as 'Location'
,TRDIAG+' '+TRDIG2+' '+TRDIG3+' '+TRDIG4 as "Diagnosis Codes"
,CPU_MEMBR.MBSEX as "Gender"
,DATEDIFF(year, CPU_MEMBR.MBDOB, #CPU_TRANSandCHARGandDOCTR.TRTDAT) as "Age"
,CASE
WHEN DATEDIFF(year, CPU_MEMBR.MBDOB, #CPU_TRANSandCHARGandDOCTR.TRTDAT) <= 10 THEN '0 to 10 Years'
WHEN DATEDIFF(year, CPU_MEMBR.MBDOB, #CPU_TRANSandCHARGandDOCTR.TRTDAT) > 10 AND DATEDIFF(year, CPU_MEMBR.MBDOB, #CPU_TRANSandCHARGandDOCTR.TRTDAT) <= 20 THEN '10 to 20 Years'
WHEN DATEDIFF(year, CPU_MEMBR.MBDOB, #CPU_TRANSandCHARGandDOCTR.TRTDAT) > 20 AND DATEDIFF(year, CPU_MEMBR.MBDOB, #CPU_TRANSandCHARGandDOCTR.TRTDAT) <= 30 THEN '20 to 30 Years'
WHEN DATEDIFF(year, CPU_MEMBR.MBDOB, #CPU_TRANSandCHARGandDOCTR.TRTDAT) > 30 AND DATEDIFF(year, CPU_MEMBR.MBDOB, #CPU_TRANSandCHARGandDOCTR.TRTDAT) <= 40 THEN '30 to 40 Years'
WHEN DATEDIFF(year, CPU_MEMBR.MBDOB, #CPU_TRANSandCHARGandDOCTR.TRTDAT) > 40 AND DATEDIFF(year, CPU_MEMBR.MBDOB, #CPU_TRANSandCHARGandDOCTR.TRTDAT) <= 50 THEN '40 to 50 Years'
WHEN DATEDIFF(year, CPU_MEMBR.MBDOB, #CPU_TRANSandCHARGandDOCTR.TRTDAT) > 50 AND DATEDIFF(year, CPU_MEMBR.MBDOB, #CPU_TRANSandCHARGandDOCTR.TRTDAT) <= 60 THEN '50 to 60 Years'
WHEN DATEDIFF(year, CPU_MEMBR.MBDOB, #CPU_TRANSandCHARGandDOCTR.TRTDAT) > 60 AND DATEDIFF(year, CPU_MEMBR.MBDOB, #CPU_TRANSandCHARGandDOCTR.TRTDAT) <= 70 THEN '60 to 70 Years'
WHEN DATEDIFF(year, CPU_MEMBR.MBDOB, #CPU_TRANSandCHARGandDOCTR.TRTDAT) > 70 AND DATEDIFF(year, CPU_MEMBR.MBDOB, #CPU_TRANSandCHARGandDOCTR.TRTDAT) <= 80 THEN '70 to 80 Years'
WHEN DATEDIFF(year, CPU_MEMBR.MBDOB, #CPU_TRANSandCHARGandDOCTR.TRTDAT) > 80 AND DATEDIFF(year, CPU_MEMBR.MBDOB, #CPU_TRANSandCHARGandDOCTR.TRTDAT) <= 90 THEN '80 to 90 Years'
WHEN DATEDIFF(year, CPU_MEMBR.MBDOB, #CPU_TRANSandCHARGandDOCTR.TRTDAT) > 90 THEN '90+ Years'
END as "Age Bracket"
,NULL as "Referral Source"
,NULL as "Language"
,NULL as "Ethnicity"
,SS_Zip2FIPS.ZIP as "ZIP"
,SS_Zip2FIPS.FIPS as "FIPS"
,SS_Zip2FIPS.STATE as "STATE"
,#CPU_TRANSandCHARGandDOCTR.Entity

FROM
#CPU_TRANSandCHARGandDOCTR
LEFT JOIN CPU_BS70_CTYPE
ON #CPU_TRANSandCHARGandDOCTR.CHTYPE = CPU_BS70_CTYPE.CTCODE AND #CPU_TRANSandCHARGandDOCTR.CHSUBT = CPU_BS70_CTYPE.CTSUBT
LEFT JOIN CPU_DOCTR as "CPU_DOCTR_TRADR#"
ON #CPU_TRANSandCHARGandDOCTR.TRADR# = CPU_DOCTR_TRADR#.DRNUM AND #CPU_TRANSandCHARGandDOCTR.Entity LIKE CPU_DOCTR_TRADR#.Entity
LEFT JOIN CPU_DOCTR as "CPU_DOCTR_TRNPCP"
ON #CPU_TRANSandCHARGandDOCTR.TRNPCP = CPU_DOCTR_TRNPCP.DRNUM AND 1 = CPU_DOCTR_TRNPCP.DRLOC AND #CPU_TRANSandCHARGandDOCTR.Entity LIKE 'PM' AND CPU_DOCTR_TRNPCP.Entity LIKE 'PM'
LEFT JOIN CPU_DOCTR as "CPU_DOCTR_TRNORD"
ON #CPU_TRANSandCHARGandDOCTR.TRNORD = CPU_DOCTR_TRNORD.DRNUM AND 1 = CPU_DOCTR_TRNORD.DRLOC AND #CPU_TRANSandCHARGandDOCTR.Entity LIKE 'PM' AND CPU_DOCTR_TRNORD.Entity LIKE 'PM'
LEFT JOIN CPU_FAMLY
ON #CPU_TRANSandCHARGandDOCTR.TRFAM# = CPU_FAMLY.FMNUM AND #CPU_TRANSandCHARGandDOCTR.Entity LIKE CPU_FAMLY.Entity
LEFT JOIN CPU_BS70_FCLAS
ON CPU_FAMLY.FMCLAS = CPU_BS70_FCLAS.FCNUM
LEFT JOIN CPU_LOC
ON #CPU_TRANSandCHARGandDOCTR.TRLOC = CPU_LOC.LONUM AND #CPU_TRANSandCHARGandDOCTR.Entity LIKE CPU_LOC.Entity
LEFT JOIN CPU_MEMBR
ON #CPU_TRANSandCHARGandDOCTR.TRMBR# = CPU_MEMBR.MBMBR# AND #CPU_TRANSandCHARGandDOCTR.TRFAM# = CPU_MEMBR.MBFAM# AND #CPU_TRANSandCHARGandDOCTR.Entity LIKE CPU_MEMBR.Entity
LEFT JOIN SS_Zip2FIPS
ON CPU_FAMLY.FMZIP1 LIKE SS_Zip2FIPS.ZIP_String
LEFT JOIN SS_CPU_InsuranceToFinancialClass
ON #CPU_TRANSandCHARGandDOCTR.TIIN#1 = SS_CPU_InsuranceToFinancialClass.InsuranceNumber
--LEFT JOIN ZZ_Contact
--ON #CPU_TRANSandCHARGandDOCTR.DRUPIN LIKE ZZ_Contact.LKL3__NPI__C
--LEFT JOIN ZZ_Account as TaskAccount
--ON ZZ_Contact.ACCOUNTID LIKE TaskAccount.ID
--LEFT JOIN ZZ_Account as ParentAccount
--ON TaskAccount.PARENTID LIKE ParentAccount.ID



UNION ALL


--Centricity data
SELECT
IVC_PatientProfile.PatientProfileId as "Account Number"
,ISNULL(IVC_PatientVisitProcs.CPTCode, IVC_PatientVisitProcs.Code) as 'CPT Code'
,IVC_PatientVisitProcs.Description as 'Description'
,CASE
WHEN IVC_PatientVisitProcs.Code LIKE '36475' THEN 'Ablation'
WHEN IVC_PatientVisitProcs.Code LIKE '36476' THEN 'Ablation'
WHEN IVC_PatientVisitProcs.Code LIKE '36478' THEN 'Ablation'
WHEN IVC_PatientVisitProcs.Code LIKE '36479' THEN 'Ablation'
WHEN IVC_PatientVisitProcs.Code LIKE '37765' THEN 'Phlebectomy'
WHEN IVC_PatientVisitProcs.Code LIKE '37766' THEN 'Phlebectomy'
WHEN IVC_PatientVisitProcs.Code LIKE '37799' THEN 'Phlebectomy'
WHEN IVC_PatientVisitProcs.Code LIKE '36470' THEN 'Sclerotherapy'
WHEN IVC_PatientVisitProcs.Code LIKE '36471' THEN 'Sclerotherapy'
WHEN IVC_PatientVisitProcs.Code LIKE '99201' THEN 'New Patient Exam'
WHEN IVC_PatientVisitProcs.Code LIKE '99202' THEN 'New Patient Exam'
WHEN IVC_PatientVisitProcs.Code LIKE '99203' THEN 'New Patient Exam'
WHEN IVC_PatientVisitProcs.Code LIKE '99204' THEN 'New Patient Exam'
WHEN IVC_PatientVisitProcs.Code LIKE '99205' THEN 'New Patient Exam'
WHEN IVC_PatientVisitProcs.Code LIKE '99211' THEN 'Follow-up Exam'
WHEN IVC_PatientVisitProcs.Code LIKE '99212' THEN 'Follow-up Exam'
WHEN IVC_PatientVisitProcs.Code LIKE '99213' THEN 'Follow-up Exam'
WHEN IVC_PatientVisitProcs.Code LIKE '99214' THEN 'Follow-up Exam'
WHEN IVC_PatientVisitProcs.Code LIKE '99215' THEN 'Follow-up Exam'
WHEN IVC_PatientVisitProcs.Code LIKE '10022' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '19000' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '19100' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '19285' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '27094' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '60001' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '76376' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '76536' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '76604' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '76645' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '76536' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '76700' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '76705' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '76770' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '76775' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '76801' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '76802' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '76805' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '76810' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '76815' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '76816' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '76817' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '76818' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '76819' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '76830' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '76831' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '76856' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '76857' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '76870' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '76881' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '76882' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '76937' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '77001' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '93000' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '93306' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '93307' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '93351' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '93880' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '93882' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '93922' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '93923' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '93924' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '93925' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '93926' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '93930' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '93931' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '93965' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '93970' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '93971' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '93975' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '93978' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '93979' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE '93990' THEN 'Ultrasound'
WHEN IVC_PatientVisitProcs.Code LIKE 'G0389' THEN 'Ultrasound'
ELSE 'Other IVC'
END as 'Category'
,IVC_PatientVisitProcs.DateOfServiceFrom as 'Date of Service'
,IVC_PatientVisitProcs.DateOfEntry as 'Date of Entry'
,PerformingDoctor.ListName as 'Performing Physician'
,CASE
	WHEN IVC_MedLists.Description like 'Physician Referral' AND IVC_PatientVisit.ReferringDoctorId = 27			THEN 'Unknown'
	WHEN IVC_MedLists.Description like 'Physician Referral' AND IVC_PatientVisit.ReferringDoctorId = 17			THEN 'Unknown'
	WHEN IVC_MedLists.Description like 'Physician Referral' AND IVC_PatientVisit.ReferringDoctorId = 26			THEN 'Unknown'
	WHEN IVC_MedLists.Description like 'Physician Referral' AND IVC_PatientVisit.ReferringDoctorId = 23			THEN 'Unknown'
	WHEN IVC_MedLists.Description like 'Physician Referral' AND IVC_PatientVisit.ReferringDoctorId = 24			THEN 'Unknown'
	WHEN IVC_MedLists.Description like 'Physician Referral' AND IVC_PatientVisit.ReferringDoctorId = 415		THEN 'Unknown'
	WHEN IVC_MedLists.Description like 'Physician Referral' AND IVC_PatientVisit.ReferringDoctorId = 25			THEN 'Unknown'
	WHEN IVC_MedLists.Description like 'Physician Referral' AND IVC_PatientVisit.ReferringDoctorId = 1328		THEN 'Unknown'
	WHEN IVC_MedLists.Description like 'Physician Referral' AND IVC_PatientVisit.ReferringDoctorId = 28			THEN 'Unknown'
	WHEN IVC_MedLists.Description like 'Physician Referral' AND IVC_PatientVisit.ReferringDoctorId = 745		THEN 'Unknown'
	WHEN IVC_MedLists.Description like 'Physician Referral'					THEN ISNULL(ReferringDoctor.ListName, 'Unknown')
	ELSE NULL
END as 'Referring Physician'
--,TaskAccount.NAME as "Referring Organization"
--,TaskAccount.LKL3__Practice_Type__c as "Referring Organization Type"
--,ISNULL(ParentAccount.NAME, TaskAccount.NAME) as "Referring Parent Organization"
--,TaskAccount.GROUP__C as "Medical Group"
,NULL as "Ordering Physician"
,Units as 'Quantity'
,TotalFee as 'Charges'
,#Transactions.[Payment Amount] as 'Payments'
,#Transactions.[Adjustment Amount] as 'Adjustments'
,InsuranceName as "Insurance"
,ISNULL(FinancialClass, 'Unknown') as "Financial Class"
,CASE
WHEN TotalFee < 0 THEN NULL
WHEN TotalFee = 0 THEN 'Paid'
WHEN TotalFee = ISNULL(#Transactions.[Payment Amount],0) + ISNULL(#Transactions.[Adjustment Amount],0) THEN 'Paid'
WHEN TotalFee < ISNULL(#Transactions.[Payment Amount],0) + ISNULL(#Transactions.[Adjustment Amount],0) THEN 'Overpaid'
ELSE 'Not Paid'
END as 'Payment Status'
,[Latest Payment]
,Facility.ListName as 'Specific Location'
,Facility.OrgName as 'Location'
,Diags1.ICD9Code + ' ' + Diags2.ICD9Code + ' ' + Diags3.ICD9Code + ' ' + Diags4.ICD9Code + ' ' + Diags5.ICD9Code + ' ' + Diags6.ICD9Code + ' ' + Diags7.ICD9Code + ' ' + Diags8.ICD9Code + ' ' + Diags9.ICD9Code + ' ' +  Diags10.ICD9Code + ' ' + Diags11.ICD9Code + ' ' + Diags12.ICD9Code as "Diagnosis Codes"
,IVC_PatientProfile.Sex as "Gender"
,DATEDIFF(year, IVC_PatientProfile.Birthdate, IVC_PatientVisitProcs.DateOfServiceFrom) as "Age"
,CASE
WHEN DATEDIFF(year, IVC_PatientProfile.Birthdate, IVC_PatientVisitProcs.DateOfServiceFrom) <= 10 THEN '0 to 10 Years'
WHEN DATEDIFF(year, IVC_PatientProfile.Birthdate, IVC_PatientVisitProcs.DateOfServiceFrom) > 10 AND DATEDIFF(year, IVC_PatientProfile.Birthdate, IVC_PatientVisitProcs.DateOfServiceFrom) <= 20 THEN '10 to 20 Years'
WHEN DATEDIFF(year, IVC_PatientProfile.Birthdate, IVC_PatientVisitProcs.DateOfServiceFrom) > 20 AND DATEDIFF(year, IVC_PatientProfile.Birthdate, IVC_PatientVisitProcs.DateOfServiceFrom) <= 30 THEN '20 to 30 Years'
WHEN DATEDIFF(year, IVC_PatientProfile.Birthdate, IVC_PatientVisitProcs.DateOfServiceFrom) > 30 AND DATEDIFF(year, IVC_PatientProfile.Birthdate, IVC_PatientVisitProcs.DateOfServiceFrom) <= 40 THEN '30 to 40 Years'
WHEN DATEDIFF(year, IVC_PatientProfile.Birthdate, IVC_PatientVisitProcs.DateOfServiceFrom) > 40 AND DATEDIFF(year, IVC_PatientProfile.Birthdate, IVC_PatientVisitProcs.DateOfServiceFrom) <= 50 THEN '40 to 50 Years'
WHEN DATEDIFF(year, IVC_PatientProfile.Birthdate, IVC_PatientVisitProcs.DateOfServiceFrom) > 50 AND DATEDIFF(year, IVC_PatientProfile.Birthdate, IVC_PatientVisitProcs.DateOfServiceFrom) <= 60 THEN '50 to 60 Years'
WHEN DATEDIFF(year, IVC_PatientProfile.Birthdate, IVC_PatientVisitProcs.DateOfServiceFrom) > 60 AND DATEDIFF(year, IVC_PatientProfile.Birthdate, IVC_PatientVisitProcs.DateOfServiceFrom) <= 70 THEN '60 to 70 Years'
WHEN DATEDIFF(year, IVC_PatientProfile.Birthdate, IVC_PatientVisitProcs.DateOfServiceFrom) > 70 AND DATEDIFF(year, IVC_PatientProfile.Birthdate, IVC_PatientVisitProcs.DateOfServiceFrom) <= 80 THEN '70 to 80 Years'
WHEN DATEDIFF(year, IVC_PatientProfile.Birthdate, IVC_PatientVisitProcs.DateOfServiceFrom) > 80 AND DATEDIFF(year, IVC_PatientProfile.Birthdate, IVC_PatientVisitProcs.DateOfServiceFrom) <= 90 THEN '80 to 90 Years'
WHEN DATEDIFF(year, IVC_PatientProfile.Birthdate, IVC_PatientVisitProcs.DateOfServiceFrom) > 90 THEN '90+ Years'
END as "Age Bracket"
,IVC_MedLists.Description as "Referral Source"
,IVC_Language.ShortDescription as "Language"
,Ethnicity.Description as "Ethnicity"
,SS_Zip2FIPS.ZIP as "ZIP"
,SS_Zip2FIPS.FIPS as "FIPS"
,SS_Zip2FIPS.STATE as "STATE"
,CASE
WHEN IVC_PatientVisit.CompanyId = 722 THEN 'UVU'
ELSE 'IVC'
END as 'Entity'

FROM
IVC_PatientVisitProcs
LEFT JOIN IVC_PatientVisit
ON IVC_PatientVisitProcs.PatientVisitId = IVC_PatientVisit.PatientVisitId
LEFT JOIN IVC_DoctorFacility as "PerformingDoctor"
ON IVC_PatientVisit.DoctorId = PerformingDoctor.DoctorFacilityId
LEFT JOIN IVC_DoctorFacility as "ReferringDoctor"
ON IVC_PatientVisit.ReferringDoctorId = ReferringDoctor.DoctorFacilityId
LEFT JOIN IVC_PatientProfile													--to get "Referral Source"
ON IVC_PatientVisit.PatientProfileId = IVC_PatientProfile.PatientProfileId
LEFT JOIN IVC_MedLists															--still getting "Referral Source" and used to select the right doctors
ON IVC_PatientProfile.ReferenceSourceMId = IVC_MedLists.MedListsId
LEFT JOIN #Transactions
ON IVC_PatientVisitProcs.PatientVisitProcsId = #Transactions.PatientVisitProcsId
LEFT JOIN IVC_DoctorFacility as "Facility"
ON IVC_PatientVisit.FacilityId = Facility.DoctorFacilityId
LEFT JOIN IVC_Language
ON IVC_PatientProfile.LanguageId = IVC_Language.LanguageId
LEFT JOIN SS_Zip2FIPS
ON CASE
WHEN ISNUMERIC(LEFT(IVC_PatientProfile.Zip,5)) = 1  THEN LEFT(IVC_PatientProfile.Zip,5)
END LIKE SS_Zip2FIPS.ZIP_String
LEFT JOIN SS_IVC_InsuranceToFinancialClass
ON IVC_PatientVisit.PrimaryInsuranceCarriersId = SS_IVC_InsuranceToFinancialClass.InsuranceNumber
LEFT JOIN IVC_PatientVisitDiags as "Diags1"
ON IVC_PatientVisit.PatientVisitId = Diags1.PatientVisitId AND IVC_PatientVisitProcs.PatientVisitDiags1 = Diags1.ListOrder
LEFT JOIN IVC_PatientVisitDiags as "Diags2"
ON IVC_PatientVisit.PatientVisitId = Diags2.PatientVisitId AND IVC_PatientVisitProcs.PatientVisitDiags2 = Diags2.ListOrder
LEFT JOIN IVC_PatientVisitDiags as "Diags3"
ON IVC_PatientVisit.PatientVisitId = Diags3.PatientVisitId AND IVC_PatientVisitProcs.PatientVisitDiags3 = Diags3.ListOrder
LEFT JOIN IVC_PatientVisitDiags as "Diags4"
ON IVC_PatientVisit.PatientVisitId = Diags4.PatientVisitId AND IVC_PatientVisitProcs.PatientVisitDiags4 = Diags4.ListOrder
LEFT JOIN IVC_PatientVisitDiags as "Diags5"
ON IVC_PatientVisit.PatientVisitId = Diags5.PatientVisitId AND IVC_PatientVisitProcs.PatientVisitDiags5 = Diags5.ListOrder
LEFT JOIN IVC_PatientVisitDiags as "Diags6"
ON IVC_PatientVisit.PatientVisitId = Diags6.PatientVisitId AND IVC_PatientVisitProcs.PatientVisitDiags6 = Diags6.ListOrder
LEFT JOIN IVC_PatientVisitDiags as "Diags7"
ON IVC_PatientVisit.PatientVisitId = Diags7.PatientVisitId AND IVC_PatientVisitProcs.PatientVisitDiags7 = Diags7.ListOrder
LEFT JOIN IVC_PatientVisitDiags as "Diags8"
ON IVC_PatientVisit.PatientVisitId = Diags8.PatientVisitId AND IVC_PatientVisitProcs.PatientVisitDiags8 = Diags8.ListOrder
LEFT JOIN IVC_PatientVisitDiags as "Diags9"
ON IVC_PatientVisit.PatientVisitId = Diags9.PatientVisitId AND IVC_PatientVisitProcs.PatientVisitDiags9 = Diags9.ListOrder
LEFT JOIN IVC_PatientVisitDiags as "Diags10"
ON IVC_PatientVisit.PatientVisitId = Diags10.PatientVisitId AND IVC_PatientVisitProcs.PatientVisitDiags10 = Diags10.ListOrder
LEFT JOIN IVC_PatientVisitDiags as "Diags11"
ON IVC_PatientVisit.PatientVisitId = Diags11.PatientVisitId AND IVC_PatientVisitProcs.PatientVisitDiags11 = Diags11.ListOrder
LEFT JOIN IVC_PatientVisitDiags as "Diags12"
ON IVC_PatientVisit.PatientVisitId = Diags12.PatientVisitId AND IVC_PatientVisitProcs.PatientVisitDiags12 = Diags12.ListOrder
LEFT JOIN IVC_MedLists as "Ethnicity"
ON IVC_PatientProfile.EthnicityMId = Ethnicity.MedListsId
--LEFT JOIN ZZ_Contact
--ON ReferringDoctor.NPI LIKE ZZ_Contact.LKL3__NPI__C
--AND NOT (
--	IVC_PatientVisit.ReferringDoctorId = 27
--	OR IVC_PatientVisit.ReferringDoctorId = 17
--	OR IVC_PatientVisit.ReferringDoctorId = 26
--	OR IVC_PatientVisit.ReferringDoctorId = 23
--	OR IVC_PatientVisit.ReferringDoctorId = 24
--	OR IVC_PatientVisit.ReferringDoctorId = 415
--	OR IVC_PatientVisit.ReferringDoctorId = 25
--	OR IVC_PatientVisit.ReferringDoctorId = 1328
--	OR IVC_PatientVisit.ReferringDoctorId = 28
--	OR IVC_PatientVisit.ReferringDoctorId = 745
--)
--LEFT JOIN ZZ_Account as TaskAccount
--ON ZZ_Contact.ACCOUNTID LIKE TaskAccount.ID
--LEFT JOIN ZZ_Account as ParentAccount
--ON TaskAccount.PARENTID LIKE ParentAccount.ID

WHERE IVC_PatientVisit.CompanyId <> 3


DROP TABLE #CPU_TRANSandCHARG
DROP TABLE #CPU_TRANSandCHARGandDOCTR
DROP TABLE #Transactions