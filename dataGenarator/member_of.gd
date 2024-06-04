
[General]
Version=1

[Preferences]
Username=
Password=2656
Database=
DateFormat=
CommitCount=0
CommitDelay=0
InitScript=

[Table]
Owner=SYS
Name=MEMBER_OF
Count=500

[Record]
Name=TEAM_ID
Type=NUMBER
Size=
Data=List(select team_id from team)
Master=

[Record]
Name=EMPLOYEE_ID
Type=NUMBER
Size=
Data=List(select employee_id from employee)
Master=

