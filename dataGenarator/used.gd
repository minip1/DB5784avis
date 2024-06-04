
[General]
Version=1

[Preferences]
Username=
Password=2983
Database=
DateFormat=
CommitCount=0
CommitDelay=0
InitScript=

[Table]
Owner=SYS
Name=USED
Count=100

[Record]
Name=REPORT_ID
Type=NUMBER
Size=
Data=List(select report_id from maintnance_report)
Master=

[Record]
Name=EQUIPMENT_ID
Type=NUMBER
Size=
Data=List(select equipment_id from equipment)
Master=

