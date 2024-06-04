
[General]
Version=1

[Preferences]
Username=
Password=2803
Database=
DateFormat=
CommitCount=0
CommitDelay=0
InitScript=

[Table]
Owner=SYS
Name=TEAM
Count=500

[Record]
Name=TEAM_ID
Type=NUMBER
Size=
Data=Sequence(1, 100)
Master=

[Record]
Name=TEAM_NAME
Type=VARCHAR2
Size=100
Data=List('team a','team b','team c','team d') + Sequence(1,1)
Master=

[Record]
Name=SPECIALITY
Type=VARCHAR2
Size=100
Data=List('electric, 'cleaning', 'plumbing','repairs')
Master=

[Record]
Name=DEPARTMANT_ID
Type=NUMBER
Size=
Data=List(select departmant_id from departmant)
Master=

