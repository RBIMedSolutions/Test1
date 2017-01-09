USE [BI Staging];

SELECT
DR_Online.ExamID
,DR_Online.PatientID
,CAST(DR_Online.ExamCode as varchar(15)) as "Exam Code"					--Replace w/ CPT Code?
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
,CASE
WHEN ExamCompleteDate IS NULL THEN NULL
WHEN DATEPART(HOUR, ExamCompleteDate) >= 7 AND DATEPART(HOUR, ExamCompleteDate) < 15 THEN '7 AM to 3 PM'
WHEN DATEPART(HOUR, ExamCompleteDate) >= 15 AND DATEPART(HOUR, ExamCompleteDate) < 23 THEN '3 PM to 11 PM'
ELSE '11 PM to 7 AM'
END as "Online Shift"
,CASE
WHEN ReadingDate IS NULL THEN NULL
WHEN DATEPART(HOUR, ReadingDate) >= 7 AND DATEPART(HOUR, ReadingDate) < 15 THEN '7 AM to 3 PM'
WHEN DATEPART(HOUR, ReadingDate) >= 15 AND DATEPART(HOUR, ReadingDate) < 23 THEN '3 PM to 11 PM'
ELSE '11 PM to 7 AM'
END as "Reading Shift"
,DR_Online.ExamDate as "Exam Start Date"
,DR_Online.ExamCompleteDate as "Exam Complete Date"
,DR_Online.ReadingDate as "Reading Date"
,DATEDIFF(minute, ExamCompleteDate, ReadingDate) as "Turn Around Time"
,DR_Online.ReadingRadiologist as "Reading Radiologist"
,DR_Online.AcqTechName as "Acquiring Tech Name"
,DR_Online.Referring as "Referring Physician"
,NULL as "Referring Midlevel"
,NULL as "Insurance"
,NULL as "Financial Class"
,CASE
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
END as "Acquiring Site"
,DR_Online.Sex as "Gender"
,DR_Online.BirthDate as "Birth Date"
,CASE
WHEN DATEDIFF(year, DR_Online.BirthDate, DR_Online.ExamCompleteDate) <= 10 THEN '0 to 10 Years'
WHEN DATEDIFF(year, DR_Online.BirthDate, DR_Online.ExamCompleteDate) > 10 AND DATEDIFF(year, DR_Online.BirthDate, DR_Online.ExamCompleteDate) <= 20 THEN '10 to 20 Years'
WHEN DATEDIFF(year, DR_Online.BirthDate, DR_Online.ExamCompleteDate) > 20 AND DATEDIFF(year, DR_Online.BirthDate, DR_Online.ExamCompleteDate) <= 30 THEN '20 to 30 Years'
WHEN DATEDIFF(year, DR_Online.BirthDate, DR_Online.ExamCompleteDate) > 30 AND DATEDIFF(year, DR_Online.BirthDate, DR_Online.ExamCompleteDate) <= 40 THEN '30 to 40 Years'
WHEN DATEDIFF(year, DR_Online.BirthDate, DR_Online.ExamCompleteDate) > 40 AND DATEDIFF(year, DR_Online.BirthDate, DR_Online.ExamCompleteDate) <= 50 THEN '40 to 50 Years'
WHEN DATEDIFF(year, DR_Online.BirthDate, DR_Online.ExamCompleteDate) > 50 AND DATEDIFF(year, DR_Online.BirthDate, DR_Online.ExamCompleteDate) <= 60 THEN '50 to 60 Years'
WHEN DATEDIFF(year, DR_Online.BirthDate, DR_Online.ExamCompleteDate) > 60 AND DATEDIFF(year, DR_Online.BirthDate, DR_Online.ExamCompleteDate) <= 70 THEN '60 to 70 Years'
WHEN DATEDIFF(year, DR_Online.BirthDate, DR_Online.ExamCompleteDate) > 70 AND DATEDIFF(year, DR_Online.BirthDate, DR_Online.ExamCompleteDate) <= 80 THEN '70 to 80 Years'
WHEN DATEDIFF(year, DR_Online.BirthDate, DR_Online.ExamCompleteDate) > 80 AND DATEDIFF(year, DR_Online.BirthDate, DR_Online.ExamCompleteDate) <= 90 THEN '80 to 90 Years'
WHEN DATEDIFF(year, DR_Online.BirthDate, DR_Online.ExamCompleteDate) > 90 THEN '90+ Years'
END as "Age Bracket"
,'DR' as "System"
,NULL as "Lien?"


FROM
DR_Online

WHERE
DR_Online.Status LIKE 'R'
AND DR_Online.AcqSiteAbbr NOT LIKE 'UVI'
AND DR_Online.ReadingRadiologist NOT LIKE '%Marked Read %'


UNION ALL

SELECT
DR_Online.ExamID
,DR_Online.PatientID
,CAST(DR_Online.ExamCode as varchar(15)) as "Exam Code"					--Replace w/ CPT Code?
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
,CASE
WHEN ExamCompleteDate IS NULL THEN NULL
WHEN DATEPART(HOUR, ExamCompleteDate) >= 7 AND DATEPART(HOUR, ExamCompleteDate) < 15 THEN '7 AM to 3 PM'
WHEN DATEPART(HOUR, ExamCompleteDate) >= 15 AND DATEPART(HOUR, ExamCompleteDate) < 23 THEN '3 PM to 11 PM'
ELSE '11 PM to 7 AM'
END as "Online Shift"
,CASE
WHEN ReadingDate IS NULL THEN NULL
WHEN DATEPART(HOUR, ReadingDate) >= 7 AND DATEPART(HOUR, ReadingDate) < 15 THEN '7 AM to 3 PM'
WHEN DATEPART(HOUR, ReadingDate) >= 15 AND DATEPART(HOUR, ReadingDate) < 23 THEN '3 PM to 11 PM'
ELSE '11 PM to 7 AM'
END as "Reading Shift"
,DR_Online.ExamDate as "Exam Start Date"
,DR_Online.ExamCompleteDate as "Exam Complete Date"
,DR_Online.ReadingDate as "Reading Date"
,DATEDIFF(minute, ExamCompleteDate, ReadingDate) as "Turn Around Time"
,DR_Online.ReadingRadiologist as "Reading Radiologist"
,DR_Online.AcqTechName as "Acquiring Tech Name"
,DR_Online.Referring as "Referring Physician"
,CASE
WHEN DR_OnlineRefPhys.Name LIKE '%Jeff%' AND DR_OnlineRefPhys.Name LIKE '%Pierson%' THEN 'Pierson, Jeff'
WHEN DR_OnlineRefPhys.Name LIKE '%Karee%' AND DR_OnlineRefPhys.Name LIKE '%Yates%' THEN 'Yates, Karee'
WHEN DR_OnlineRefPhys.Name LIKE '%Megan%' AND DR_OnlineRefPhys.Name LIKE '%Jensen%' THEN 'Jensen, Megan'
WHEN DR_OnlineRefPhys.Name LIKE '%Travis%' AND DR_OnlineRefPhys.Name LIKE '%Dimond%' THEN 'Dimond, Travis'
WHEN DR_OnlineRefPhys.Name LIKE '%Michael%' AND DR_OnlineRefPhys.Name LIKE '%Francis%' THEN 'Francis, Michael'
WHEN DR_OnlineRefPhys.Name LIKE '%John%' AND DR_OnlineRefPhys.Name LIKE '%Manwaring%' THEN 'Manwaring, John'
WHEN DR_OnlineRefPhys.Name LIKE '%Adam%' AND DR_OnlineRefPhys.Name LIKE '%Wright%' THEN 'Wright, Adam'
WHEN DR_OnlineRefPhys.Name LIKE '%Norm%' AND DR_OnlineRefPhys.Name LIKE '%Bowers%' THEN 'Bowers, Norm'
END as "Referring Midlevel"
,NULL as "Insurance"
,NULL as "Financial Class"
,CASE
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
END as "Acquiring Site"
,DR_Online.Sex as "Gender"
,DR_Online.BirthDate as "Birth Date"
,CASE
WHEN DATEDIFF(year, DR_Online.BirthDate, GETDATE()) <= 10 THEN '0 to 10 Years'
WHEN DATEDIFF(year, DR_Online.BirthDate, GETDATE()) > 10 AND DATEDIFF(year, DR_Online.BirthDate, GETDATE()) <= 20 THEN '10 to 20 Years'
WHEN DATEDIFF(year, DR_Online.BirthDate, GETDATE()) > 20 AND DATEDIFF(year, DR_Online.BirthDate, GETDATE()) <= 30 THEN '20 to 30 Years'
WHEN DATEDIFF(year, DR_Online.BirthDate, GETDATE()) > 30 AND DATEDIFF(year, DR_Online.BirthDate, GETDATE()) <= 40 THEN '30 to 40 Years'
WHEN DATEDIFF(year, DR_Online.BirthDate, GETDATE()) > 40 AND DATEDIFF(year, DR_Online.BirthDate, GETDATE()) <= 50 THEN '40 to 50 Years'
WHEN DATEDIFF(year, DR_Online.BirthDate, GETDATE()) > 50 AND DATEDIFF(year, DR_Online.BirthDate, GETDATE()) <= 60 THEN '50 to 60 Years'
WHEN DATEDIFF(year, DR_Online.BirthDate, GETDATE()) > 60 AND DATEDIFF(year, DR_Online.BirthDate, GETDATE()) <= 70 THEN '60 to 70 Years'
WHEN DATEDIFF(year, DR_Online.BirthDate, GETDATE()) > 70 AND DATEDIFF(year, DR_Online.BirthDate, GETDATE()) <= 80 THEN '70 to 80 Years'
WHEN DATEDIFF(year, DR_Online.BirthDate, GETDATE()) > 80 AND DATEDIFF(year, DR_Online.BirthDate, GETDATE()) <= 90 THEN '80 to 90 Years'
WHEN DATEDIFF(year, DR_Online.BirthDate, GETDATE()) > 90 THEN '90+ Years'
END as "Age Bracket"
,'DR' as "System"
,CASE
WHEN DR_Online.AcqSiteAbbr LIKE 'UVI' AND DR_PatIns.PlanNumber LIKE '987' THEN 'True'
WHEN DR_Online.AcqSiteAbbr LIKE 'UVI' THEN 'False'
END as "Lien?"


FROM
DR_Online
LEFT JOIN DR_OnlineRefPhys
ON DR_Online.ExamID LIKE DR_OnlineRefPhys.ExamID AND (
	Name LIKE '%Pierson%'
	OR Name LIKE '%Yates%'
	OR Name LIKE '%Jensen%'
	OR Name LIKE '%Dimond%'
	OR Name LIKE '%Francis%'
	OR Name LIKE '%Manwaring%'
	OR Name LIKE '%Wright%'
	OR Name LIKE '%Bowers%')
LEFT JOIN DR_PatIns
ON DR_Online.PatientID LIKE DR_PatIns.PatientID AND DR_PatIns.PlanNumber LIKE '987' AND DR_PatIns.[Priority] = 0
WHERE
DR_Online.Status LIKE 'R'
AND DR_Online.AcqSiteAbbr LIKE 'UVI'
AND DR_Online.ReadingRadiologist NOT LIKE '%Marked Read %'


UNION ALL


SELECT

IF_STUDY.ACCESS_NO as ExamID
,IF_PATIENT.PATIENT_ID as PatientID
,CAST(IF_STUDY.REQUEST_CODE as varchar(15)) as "Exam Code"					--Replace w/ CPT Code?
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
,CASE
WHEN IF_STUDY.CREATION_DTTM IS NULL THEN NULL
WHEN DATEPART(HOUR, IF_STUDY.CREATION_DTTM) >= 7 AND DATEPART(HOUR, IF_STUDY.CREATION_DTTM) < 15 THEN '7 AM to 3 PM'
WHEN DATEPART(HOUR, IF_STUDY.CREATION_DTTM) >= 15 AND DATEPART(HOUR, IF_STUDY.CREATION_DTTM) < 23 THEN '3 PM to 11 PM'
ELSE '11 PM to 7 AM'
END as "Online Shift"
,CASE
WHEN IF_REPORT.DICTATE_DTTM IS NULL THEN NULL
WHEN DATEPART(HOUR, IF_REPORT.DICTATE_DTTM) >= 7 AND DATEPART(HOUR, IF_REPORT.DICTATE_DTTM) < 15 THEN '7 AM to 3 PM'
WHEN DATEPART(HOUR, IF_REPORT.DICTATE_DTTM) >= 15 AND DATEPART(HOUR, IF_REPORT.DICTATE_DTTM) < 23 THEN '3 PM to 11 PM'
ELSE '11 PM to 7 AM'
END as "Reading Shift"
,IF_STUDY.STUDY_DTTM as "Exam Start Date"
,IF_STUDY.CREATION_DTTM as "Exam Complete Date"
,IF_REPORT.DICTATE_DTTM as "Reading Date"
,DATEDIFF(minute, IF_STUDY.CREATION_DTTM, IF_REPORT.DICTATE_DTTM) as "Turn Around Time"
,REPLACE(Reading.USER_NAME, '^', ' ') as "Reading Radiologist"
,REPLACE(Technician.USER_NAME, '^', ' ') as "Acquiring Tech Name"
,REPLACE(Referring.USER_NAME, '^', ' ') as "Referring Physician"
,CASE
WHEN Ordering.USER_NAME LIKE '%Jeff%' AND Ordering.USER_NAME LIKE '%Pierson%' THEN 'Pierson, Jeff'
WHEN Ordering.USER_NAME LIKE '%Karee%' AND Ordering.USER_NAME LIKE '%Yates%' THEN 'Yates, Karee'
WHEN Ordering.USER_NAME LIKE '%Megan%' AND Ordering.USER_NAME LIKE '%Jensen%' THEN 'Jensen, Megan'
WHEN Ordering.USER_NAME LIKE '%Travis%' AND Ordering.USER_NAME LIKE '%Dimond%' THEN 'Dimond, Travis'
WHEN Ordering.USER_NAME LIKE '%Michael%' AND Ordering.USER_NAME LIKE '%Francis%' THEN 'Francis, Michael'
WHEN Ordering.USER_NAME LIKE '%John%' AND Ordering.USER_NAME LIKE '%Manwaring%' THEN 'Manwaring, John'
WHEN Ordering.USER_NAME LIKE '%Adam%' AND Ordering.USER_NAME LIKE '%Wright%' THEN 'Wright, Adam'
WHEN Ordering.USER_NAME LIKE '%Norm%' AND Ordering.USER_NAME LIKE '%Bowers%' THEN 'Bowers, Norm'
END as "Referring Midlevel"
,NULL as "Insurance"
,NULL as "Financial Class"
,IF_STUDY.INSTITUTION as "Acquiring Site"
,IF_PATIENT.PATIENT_SEX as "Gender"
,IF_PATIENT.PATIENT_BIRTH_DTTM as "Birth Date"
,CASE
WHEN DATEDIFF(year, IF_PATIENT.PATIENT_BIRTH_DTTM, IF_STUDY.CREATION_DTTM) <= 10 THEN '0 to 10 Years'
WHEN DATEDIFF(year, IF_PATIENT.PATIENT_BIRTH_DTTM, IF_STUDY.CREATION_DTTM) > 10 AND DATEDIFF(year, IF_PATIENT.PATIENT_BIRTH_DTTM, IF_STUDY.CREATION_DTTM) <= 20 THEN '10 to 20 Years'
WHEN DATEDIFF(year, IF_PATIENT.PATIENT_BIRTH_DTTM, IF_STUDY.CREATION_DTTM) > 20 AND DATEDIFF(year, IF_PATIENT.PATIENT_BIRTH_DTTM, IF_STUDY.CREATION_DTTM) <= 30 THEN '20 to 30 Years'
WHEN DATEDIFF(year, IF_PATIENT.PATIENT_BIRTH_DTTM, IF_STUDY.CREATION_DTTM) > 30 AND DATEDIFF(year, IF_PATIENT.PATIENT_BIRTH_DTTM, IF_STUDY.CREATION_DTTM) <= 40 THEN '30 to 40 Years'
WHEN DATEDIFF(year, IF_PATIENT.PATIENT_BIRTH_DTTM, IF_STUDY.CREATION_DTTM) > 40 AND DATEDIFF(year, IF_PATIENT.PATIENT_BIRTH_DTTM, IF_STUDY.CREATION_DTTM) <= 50 THEN '40 to 50 Years'
WHEN DATEDIFF(year, IF_PATIENT.PATIENT_BIRTH_DTTM, IF_STUDY.CREATION_DTTM) > 50 AND DATEDIFF(year, IF_PATIENT.PATIENT_BIRTH_DTTM, IF_STUDY.CREATION_DTTM) <= 60 THEN '50 to 60 Years'
WHEN DATEDIFF(year, IF_PATIENT.PATIENT_BIRTH_DTTM, IF_STUDY.CREATION_DTTM) > 60 AND DATEDIFF(year, IF_PATIENT.PATIENT_BIRTH_DTTM, IF_STUDY.CREATION_DTTM) <= 70 THEN '60 to 70 Years'
WHEN DATEDIFF(year, IF_PATIENT.PATIENT_BIRTH_DTTM, IF_STUDY.CREATION_DTTM) > 70 AND DATEDIFF(year, IF_PATIENT.PATIENT_BIRTH_DTTM, IF_STUDY.CREATION_DTTM) <= 80 THEN '70 to 80 Years'
WHEN DATEDIFF(year, IF_PATIENT.PATIENT_BIRTH_DTTM, IF_STUDY.CREATION_DTTM) > 80 AND DATEDIFF(year, IF_PATIENT.PATIENT_BIRTH_DTTM, IF_STUDY.CREATION_DTTM) <= 90 THEN '80 to 90 Years'
WHEN DATEDIFF(year, IF_PATIENT.PATIENT_BIRTH_DTTM, IF_STUDY.CREATION_DTTM) > 90 THEN '90+ Years'
END as "Age Bracket"
,'Infinitt' as "System"
,CASE
WHEN IF_STUDY.INSTITUTION LIKE 'UTAH VALLEY IMAGING' AND PrimaryInsurance.INSURANCE_NAME LIKE '%OFSG%' THEN 'True'
WHEN IF_STUDY.INSTITUTION LIKE 'UTAH VALLEY IMAGING' THEN 'False'
END as "Lien?"


FROM
IF_STUDY
LEFT JOIN IF_MSPS
ON IF_STUDY.STUDY_KEY = IF_MSPS.STUDY_KEY
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
--LEFT JOIN IF_PATIENTCONTACT
--ON IF_PATIENT.PATIENT_KEY = IF_PATIENTCONTACT.PATIENT_KEY AND IF_PATIENTCONTACT.CONTACT_TYPE LIKE 'H'
LEFT JOIN IF_PATIENTINSURANCE as "PrimaryInsurance"
ON IF_PATIENT.PATIENT_KEY = PrimaryInsurance.PATIENT_KEY AND PrimaryInsurance.INSURANCE_NO = 0
--LEFT JOIN IF_PATIENTINSURANCE as "SecondaryInsurance"
--ON IF_PATIENT.PATIENT_KEY = SecondaryInsurance.PATIENT_KEY AND PrimaryInsurance.INSURANCE_NO = 1
--LEFT JOIN IF_PATIENTGUARANTOR							--Not 1:1
--ON IF_PATIENT.PATIENT_KEY = IF_PATIENTGUARANTOR.PATIENT_KEY
LEFT JOIN IF_EXAMSTAT
ON IF_STUDY.STUDY_STAT = IF_EXAMSTAT.STAT_CODE
LEFT JOIN IF_USERS as "Referring"
ON IF_IORDER.REFER_DOCTOR_KEY = Referring.USER_KEY
LEFT JOIN IF_USERS as "Ordering"
ON IF_IORDER.ORDER_DOCTOR_KEY = Ordering.USER_KEY
--LEFT JOIN IF_USERCONTACT
--ON IF_IORDER.REFER_DOCTOR_KEY = IF_USERCONTACT.USER_KEY AND IF_USERCONTACT.CONTACT_TYPE LIKE 'O'
--LEFT JOIN IF_CODEDICT as "Race"
--ON IF_PATIENT.RACE_CODE_KEY = Race.CODE_KEY
--LEFT JOIN IF_CODEDICT as "Language"
--ON IF_PATIENT.LANGUAGE_CODE_KEY = Language.CODE_KEY
--LEFT JOIN IF_CODEDICT as "Relation"
--ON IF_PATIENTGUARANTOR.RELATION_CODE_KEY = Relation.CODE_KEY
--LEFT JOIN IF_STUDYDIAG
--ON IF_STUDY.STUDY_KEY = IF_STUDYDIAG.STUDY_KEY
--LEFT JOIN IF_DIAGCODE
--ON IF_STUDYDIAG.DIAG_KEY = IF_DIAGCODE.DIAG_KEY
LEFT JOIN IF_USERS as "Technician"
ON IF_MSPS.PERFORM_DOCTOR_KEY = Technician.USER_KEY
LEFT JOIN IF_USERS as "Reading"
ON IF_REPORT.DICTATOR_KEY = Reading.USER_KEY
--LEFT JOIN IF_USERS as "Revisor"
--ON IF_REPORT.REVISER_KEY = Revisor.USER_KEY
LEFT JOIN IF_USERS as "Approver"
ON IF_REPORT.APPROVER_KEY = Approver.USER_KEY
--LEFT JOIN IF_STATIONMOD
--ON IF_MSPS.STATION_KEY = IF_STATIONMOD.STATION_KEY

WHERE IF_STUDY.ORDER_KEY IS NOT NULL
AND IF_EXAMSTAT.STAT_MEANING LIKE 'Final'			--Drop this?
AND Approver.USER_NAME NOT LIKE 'ADMINISTRATOR'
AND IF_STUDY.MODALITIES NOT LIKE '%AU%'
AND IF_STUDY.MODALITIES NOT LIKE '%ES%'
AND Reading.USER_NAME NOT LIKE 'WATSON^JEFF%'
AND Reading.USER_NAME NOT LIKE 'THORNTON^LAYNE%'