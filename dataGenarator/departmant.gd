
[General]
Version=1

[Preferences]
Username=
Password=2590
Database=
DateFormat=
CommitCount=0
CommitDelay=0
InitScript=

[Table]
Owner=SYS
Name=DEPARTMANT
Count=10

[Record]
Name=DEPARTMANT_ID
Type=NUMBER
Size=
Data=Sequence(1, 1)
Master=

[Record]
Name=DEPARTMANT_NAME
Type=VARCHAR2
Size=100
Data=List('Electrical','Plumbing', 'HVAC', 'Painting', 'Carpentry', 'Groundskeeping', 'Safety', 'Cleaning', 'Pest Control', 'Security')
Master=

[Record]
Name=SUPERVISER_ID
Type=NUMBER
Size=
Data=List(select employee_id from employee)
Master=

