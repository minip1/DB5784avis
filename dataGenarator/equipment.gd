
[General]
Version=1

[Preferences]
Username=
Password=2903
Database=
DateFormat=
CommitCount=0
CommitDelay=0
InitScript=

[Table]
Owner=SYS
Name=EQUIPMENT
Count=500

[Record]
Name=EQUIPMENT_ID
Type=NUMBER
Size=
Data=Sequence(1,1)
Master=

[Record]
Name=EQUIPMENT_NAME
Type=VARCHAR2
Size=100
Data=Components.Description
Master=

[Record]
Name=PURCHASE_DATE
Type=DATE
Size=
Data=Random(1/1/1990,1/1/2020)
Master=

