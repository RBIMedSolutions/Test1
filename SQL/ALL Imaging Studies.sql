
DECLARE @StartDate datetime, @EndDate datetime

SET @StartDate = (SELECT TOP 1 EXAM_COMPLETED_DTS
						FROM SS_IHC_Hospital_timestamp
						ORDER BY EXAM_COMPLETED_DTS)

SET @EndDate = (SELECT TOP 1 EXAM_COMPLETED_DTS
						FROM SS_IHC_Hospital_timestamp
						ORDER BY EXAM_COMPLETED_DTS DESC)



SELECT
FCILTY_NM as "Location"
,CAST(ACCESSION_NO as nvarchar) as "Accession Number"
,1 as "Quantity"
,EXAM_BEGIN_DTS as "Exam Start"
,EXAM_COMPLETED_DTS as "Exam Completed"
,EXAM_FINALIZED_DTS as "Exam Finalized"
,DICTATION_START_DTS as "Dictation Start"
,DICTATION_END_DTS as "Dictation Completed"
,PATIENT_ARRIVAL_DTS as "Patient Arrival"
,DATEDIFF(MINUTE, EXAM_COMPLETED_DTS, DICTATION_END_DTS) as "Turn Around Time"
,EXAM_DSC as "Exam Description"
,CASE
WHEN LEFT(EXAM_DSC, 2) LIKE 'PT' THEN 'PET'
WHEN LEFT(EXAM_DSC, 2) LIKE 'PET' THEN 'PET'
WHEN LEFT(EXAM_DSC, 2) LIKE 'CT' THEN 'CT'
WHEN LEFT(EXAM_DSC, 2) LIKE 'HE' THEN 'US'
WHEN LEFT(EXAM_DSC, 2) LIKE 'IN' THEN 'FL'
WHEN LEFT(EXAM_DSC, 2) LIKE 'MG' THEN 'Mammo'
WHEN LEFT(EXAM_DSC, 2) LIKE 'MR' THEN 'MR'
WHEN LEFT(EXAM_DSC, 2) LIKE 'NM' THEN 'NM'
WHEN LEFT(EXAM_DSC, 2) LIKE 'US' THEN 'US'
WHEN LEFT(EXAM_DSC, 2) LIKE 'XR' THEN 'XRay'
WHEN SUBSTRING(EXAM_DSC, 4, 2) LIKE 'CT' THEN 'CT'
WHEN SUBSTRING(EXAM_DSC, 4, 2) LIKE 'MR' THEN 'MR'
WHEN SUBSTRING(EXAM_DSC, 4, 2) LIKE 'XR' THEN 'XRay'
ELSE 'Unknown'
END as "Modality"
,PATIENT_TYPE_DSC as "Patient Type"
,CAST(EXAM_STATUS_DSC as nvarchar) as "Exam Status"
,CAST(ACCT_NO as nvarchar) as "Account Number"
,REPLACE(DICTATING_PRVDR_NM, '"', '') as "Reading Physician"
,'IHC' as "System"

FROM
SS_IHC_Hospital_timestamp

WHERE EXAM_STATUS_DSC NOT LIKE 'Non-Report%'

UNION ALL

SELECT
CASE
WHEN AcqSiteAbbr LIKE '5MC' THEN '5 Minute Clinic'
WHEN AcqSiteAbbr LIKE 'ACHC' THEN 'Adams County Health Center'
WHEN AcqSiteAbbr LIKE 'ANON' THEN 'Anonymous'
WHEN AcqSiteAbbr LIKE 'BC' THEN 'Blanding Medical Clinic'
WHEN AcqSiteAbbr LIKE 'BMC' THEN 'Blanding Medical Clinic'
WHEN AcqSiteAbbr LIKE 'BYUHC' THEN 'BYU Health Center'
WHEN AcqSiteAbbr LIKE 'CDI' THEN 'Coral Desert Imaging'
WHEN AcqSiteAbbr LIKE 'CFAS' THEN 'Cook Foot and Ankle Specialists'
WHEN AcqSiteAbbr LIKE 'CMS' THEN 'Carbon Medical Service'
WHEN AcqSiteAbbr LIKE 'CVH' THEN 'Castleview Hospital'
WHEN AcqSiteAbbr LIKE 'CVMC' THEN 'Central Valley Medical Center'
WHEN AcqSiteAbbr LIKE 'DCC' THEN 'Dove Creek Clinic'
WHEN AcqSiteAbbr LIKE 'FAI' THEN 'Foot and Ankle Institute'
WHEN AcqSiteAbbr LIKE 'GVH' THEN 'Gunnison Valley Hospital'
WHEN AcqSiteAbbr LIKE 'IVC' THEN 'Intermountain Vein Center'
WHEN AcqSiteAbbr LIKE 'IVC8001' THEN 'Intermountain Vein Center'
WHEN AcqSiteAbbr LIKE 'MDU' THEN 'Mobile Diagnostic Ultrasound'
WHEN AcqSiteAbbr LIKE 'NIRL' THEN 'NOTUS Imaging Research Laboraties'
WHEN AcqSiteAbbr LIKE 'NSC' THEN 'Northpointe Surgical Center'
WHEN AcqSiteAbbr LIKE 'OSTC' THEN 'One Source Trauma Care'
WHEN AcqSiteAbbr LIKE 'PCC' THEN 'Park City Clinic'
WHEN AcqSiteAbbr LIKE 'PCHC' THEN 'Park City Health Clinic'
WHEN AcqSiteAbbr LIKE 'PCI' THEN 'Park City Imaging'
WHEN AcqSiteAbbr LIKE 'PFM' THEN 'Premier Family Medical'
WHEN AcqSiteAbbr LIKE 'PMD' THEN 'Pacific Mobile Diagnostics'
WHEN AcqSiteAbbr LIKE 'RSVC' THEN 'Red Sands Vein Center'
WHEN AcqSiteAbbr LIKE 'RUC' THEN 'Riverwoods Urgent Care'
WHEN AcqSiteAbbr LIKE 'SCC' THEN 'Snow Canyon Clinic'
WHEN AcqSiteAbbr LIKE 'SJC' THEN 'San Juan Clinic'
WHEN AcqSiteAbbr LIKE 'SJH' THEN 'San Juan Hospital'
WHEN AcqSiteAbbr LIKE 'STGR' THEN 'St. George Radiology'
WHEN AcqSiteAbbr LIKE 'SVC' THEN 'Spanish Valley Clinic'
WHEN AcqSiteAbbr LIKE 'TCMC' THEN 'Tri-City Medical Center'
WHEN AcqSiteAbbr LIKE 'TVI' THEN 'Tooele Valley Imaging'
WHEN AcqSiteAbbr LIKE 'UBMC' THEN 'Uintah Basin Medical Center'
WHEN AcqSiteAbbr LIKE 'UNI' THEN 'Utah Neurological Imaging'
WHEN AcqSiteAbbr LIKE 'URA' THEN 'Utah Radiology Associates'
WHEN AcqSiteAbbr LIKE 'USS' THEN 'Ultrasound Specialists'
WHEN AcqSiteAbbr LIKE 'UVI' THEN 'Utah Valley Imaging'
WHEN AcqSiteAbbr LIKE 'UVPEDS' THEN 'Utah Valley Pediatrics'
WHEN AcqSiteAbbr LIKE 'UVPM' THEN 'Utah Valley Pain Management'
WHEN AcqSiteAbbr LIKE 'UVSH' THEN 'Utah Valley Specialty Hospital'
WHEN AcqSiteAbbr LIKE 'UVU' THEN 'Utah Valley Ultrasound'
WHEN AcqSiteAbbr LIKE 'UVU8003' THEN 'Utah Valley Ultrasound'
WHEN AcqSiteAbbr LIKE 'WMC' THEN 'Wasatch Medical Clinic'
ELSE AcqSiteAbbr
END as "Location"
,DR_Online.ExamID as "Accession Number"
,1 as "Quantity"
,DR_Online.ExamDate as "Exam Start"
,DR_Online.ExamCompleteDate as "Exam Completed"
,NULL as "Exam Finalized"
,NULL as "Dictation Start"
,DR_Online.ReadingDate as "Dictation Completed"
,NULL as "Patient Arrival"
,DATEDIFF(minute, ExamCompleteDate, ReadingDate) as "Turn Around Time"
,DR_Online.ExamDescr as "Exam Description"
,CASE
WHEN DR_Online.Modality LIKE '00' THEN 'Unknown'
WHEN DR_Online.Modality LIKE 'calca' THEN 'Unknown'
WHEN DR_Online.Modality LIKE 'CR' THEN 'XRay'
WHEN DR_Online.Modality LIKE 'CT' THEN 'CT'
WHEN DR_Online.Modality LIKE 'ES' THEN 'XRay'
WHEN DR_Online.Modality LIKE 'FL' THEN 'FL'
WHEN DR_Online.Modality LIKE 'IR' THEN 'Unknown'
WHEN DR_Online.Modality LIKE 'MG' THEN 'Mammo'
WHEN DR_Online.Modality LIKE 'MR' THEN 'MR'
WHEN DR_Online.Modality LIKE 'MS' THEN 'MR'
WHEN DR_Online.Modality LIKE 'NM' THEN 'NM'
WHEN DR_Online.Modality LIKE 'OT' THEN 'FL'
WHEN DR_Online.Modality LIKE 'RF' THEN 'FL'
WHEN DR_Online.Modality LIKE 'SC' THEN 'MR'
WHEN DR_Online.Modality LIKE 'US' THEN 'US'
WHEN DR_Online.Modality LIKE 'XA' THEN 'FL'
ELSE 'Unknown'
END as "Modality"
,DR_Online.PatientType as "Patient Type"
,'Read' as "Exam Status"
,PatientID as "Account Number"
,DR_Online.ReadingRadiologist as "Reading Physician"
,'DR' as "System"

FROM
DR_Online

WHERE DR_Online.ExamCompleteDate >= @StartDate
AND DR_Online.ExamCompleteDate <= @EndDate
AND DR_Online.Status LIKE 'R'							--If this is changed besure to change the "Exam Status"
AND DR_Online.ReadingRadiologist NOT LIKE '%Marked Read%'

UNION ALL

SELECT
IF_STUDY.INSTITUTION as "Location"
,IF_STUDY.ACCESS_NO as "Accession Number"
,1 as "Quantity"
,IF_STUDY.STUDY_DTTM as "Exam Start"
,IF_STUDY.CREATION_DTTM as "Exam Completed"
,IF_STUDY.VALIDATE_DTTM as "Exam Finalized"
,NULL as "Dictation Start"
,IF_REPORT.DICTATE_DTTM as "Dictation Completed"
,IF_VISIT.ADMISSION_DTTM as "Patient Arrival"
,DATEDIFF(minute, IF_STUDY.CREATION_DTTM, IF_REPORT.DICTATE_DTTM) as "Turn Around Time"
,IF_STUDY.STUDY_DESC as "Exam Description"
,CASE
WHEN IF_STUDY.MODALITIES LIKE '%PT%' THEN 'PET'
WHEN IF_STUDY.MODALITIES LIKE '%RF%' THEN 'FL'
WHEN IF_STUDY.MODALITIES LIKE '%FL%' THEN 'FL'
WHEN IF_STUDY.MODALITIES LIKE '%IR%' THEN 'FL'
WHEN IF_STUDY.MODALITIES LIKE '%XA%' THEN 'FL'
WHEN IF_STUDY.MODALITIES LIKE '%MR%' THEN 'MR'
WHEN IF_STUDY.MODALITIES LIKE '%MA%' THEN 'MR'
WHEN IF_STUDY.MODALITIES LIKE '%NM%' THEN 'NM'
WHEN IF_STUDY.MODALITIES LIKE '%CT%' THEN 'CT'
WHEN IF_STUDY.MODALITIES LIKE '%US%' THEN 'US'
WHEN IF_STUDY.MODALITIES LIKE '%MG%' THEN 'Mammo'
WHEN IF_STUDY.MODALITIES LIKE '%CR%' THEN 'XRay'
WHEN IF_STUDY.MODALITIES LIKE '%DX%' THEN 'XRay'
WHEN IF_STUDY.MODALITIES LIKE '%XR%' THEN 'XRay'
ELSE 'Unknown'
END as "Modality"
,NULL as "Patient Type"
,IF_EXAMSTAT.STAT_MEANING as "Exam Status"
,IF_PATIENT.PATIENT_ID as "Account Number"
,REPLACE(Reading.USER_NAME, '^', ' ') as "Reading Physician"
,'Infinitt' as "System"

FROM
IF_STUDY
LEFT JOIN (
	SELECT
	MIN(REPORT_KEY) as REPORT_KEY
	,STUDY_KEY
	FROM
	IF_REPORT
	WHERE DICTATE_DTTM IS NOT NULL
	GROUP BY STUDY_KEY
) as ReportLink
ON IF_STUDY.STUDY_KEY = ReportLink.STUDY_KEY
LEFT JOIN IF_REPORT
ON ReportLink.REPORT_KEY = IF_REPORT.REPORT_KEY
LEFT JOIN IF_IORDER
ON IF_STUDY.ORDER_KEY = IF_IORDER.ORDER_KEY
LEFT JOIN IF_VISIT
ON IF_IORDER.VISIT_KEY = IF_VISIT.VISIT_KEY
LEFT JOIN IF_PATIENT
ON IF_VISIT.PATIENT_KEY = IF_PATIENT.PATIENT_KEY
LEFT JOIN IF_EXAMSTAT
ON IF_STUDY.STUDY_STAT = IF_EXAMSTAT.STAT_CODE
LEFT JOIN IF_USERS as "Reading"
ON IF_REPORT.DICTATOR_KEY = Reading.USER_KEY
LEFT JOIN IF_USERS as "Approver"
ON IF_REPORT.APPROVER_KEY = Approver.USER_KEY
LEFT JOIN IF_USERS as "Ordering"
ON IF_IORDER.REFER_DOCTOR_KEY = Ordering.USER_KEY

WHERE IF_STUDY.ORDER_KEY IS NOT NULL
AND IF_EXAMSTAT.STAT_MEANING LIKE 'Final'			--Drop this?
AND Approver.USER_NAME NOT LIKE 'ADMINISTRATOR'
AND IF_STUDY.MODALITIES NOT LIKE '%AU%'
AND IF_STUDY.MODALITIES NOT LIKE '%ES%'
AND Reading.USER_NAME NOT LIKE 'WATSON^JEFF%'
AND Reading.USER_NAME NOT LIKE 'THORNTON^LAYNE%'
AND IF_STUDY.CREATION_DTTM BETWEEN @StartDate AND @EndDate