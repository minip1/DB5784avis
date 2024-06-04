
[General]
Version=1

[Preferences]
Username=
Password=2310
Database=
DateFormat=
CommitCount=0
CommitDelay=0
InitScript=

[Table]
Owner=SYS
Name=MAINTENANCE_REQUEST
Count=300

[Record]
Name=MAINTENANCE_REQUEST_ID
Type=NUMBER
Size=
Data=Sequence(1,1)
Master=

[Record]
Name=PRIORITY
Type=NUMBER
Size=
Data=Random(1, 10)
Master=

[Record]
Name=MAINTENANCE_REQUEST_DESCRIPTION
Type=VARCHAR2
Size=300
Data=List('repair', 'fix','do','install') + List(select equipment_name from equipment)
Master=

[Record]
Name=DEPARTMANT_ID
Type=NUMBER
Size=
Data=List(select departmant_id from departmant)
Master=

