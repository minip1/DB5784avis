
[General]
Version=1

[Preferences]
Username=
Password=2319
Database=
DateFormat=
CommitCount=0
CommitDelay=0
InitScript=

[Table]
Owner=SYS
Name=MAINTENANCE_REPORT
Count=500

[Record]
Name=REPORT_ID
Type=NUMBER
Size=
Data=Sequence(1,1)
Master=

[Record]
Name=MAINTENANCE_REPORT_DESCRIPTION
Type=VARCHAR2
Size=300
Data=List('repair', 'fix','do','install') + List(select equipment_name from equipment)
Master=

[Record]
Name=REPORT_DATE
Type=DATE
Size=
Data=Sequence(1/1/1950, 1/1/2020)
Master=

