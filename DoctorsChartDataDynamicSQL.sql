
/*
     =============================================
     Author:        Nikhil Patil
     Create date:   25-09-2024
     Description:   Return the list of doctor Appointments for all the doctor for previous given months
     
     Parameters: 
       @NumberOfMonths: Months for which list of doctor Appointments Needed
     Returns: List of doctor Appointments
    Usage:
       EXEC dbo.DoctorsChartData 6
	 =============================================
	*/

CREATE PROCEDURE dbo.DoctorsChartData 
@NumberOfMonths int
as 
BEGIN
CREATE TABLE #DoctorsInfo(
    Doctor_Name  NVARCHAR(100),
    [MONTH] NVARCHAR(100),
    Appointments int
)

INSERT INTO #DoctorsInfo

select D1.Doctor_name as 'Doctor_Name',CONVERT(VARCHAR(10), D1.[MONTH]) +'-' + CONVERT(VARCHAR(10), D1.[YEAR])  as [MONTH],ISNULL(V1.Appointments,0) as 'Appointments' from 

(

select * from 
(select Doctor_name  from Doctors )T1
cross join 

(select * from dbo.GetMonthsList(@NumberOfMonths)
)T2

)D1
left outer join [dbo].[DoctorAppointments] V1

on D1.Doctor_name = V1.Doctor_Name and D1.[MONTH]= V1.Month and D1.[YEAR]= V1.YEAR

order by D1.[MONTH],D1.[YEAR]

DECLARE @cols NVARCHAR(MAX);
DECLARE @query NVARCHAR(MAX);



SELECT @cols = STRING_AGG(QUOTENAME(T.MONTH), ', ')
FROM
(select DISTINCT [MONTH] FROM #DoctorsInfo)T

SET @query=

'SELECT Doctor_Name,'+
@cols +
'
FROM 
#DoctorsInfo
PIVOT
(
SUM(Appointments)
FOR [MONTH] IN
('
+
@cols
+
')

)
AS PVT'
print  @query

EXEC sp_executesql @query;
DROP TABLE  #DoctorsInfo
END
