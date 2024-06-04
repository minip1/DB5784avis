
[General]
Version=1

[Preferences]
Username=
Password=2039
Database=
DateFormat=
CommitCount=0
CommitDelay=0
InitScript=

[Table]
Owner=SYS
Name=WORKED
Count=200

[Record]
Name=TEAM_ID
Type=NUMBER
Size=
Data=List(select team_id from team)
Master=

[Record]
Name=REPORT_ID
Type=NUMBER
Size=
Data=List(select reaport_id from maintenance_report)
Master=

