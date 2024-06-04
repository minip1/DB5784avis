
[General]
Version=1

[Preferences]
Username=
Password=2431
Database=
DateFormat=
CommitCount=0
CommitDelay=0
InitScript=

[Table]
Owner=SYS
Name=WORKED
Count=500

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
Data=List(select report_id from maintenance_report)
Master=

