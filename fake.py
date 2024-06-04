from faker import Faker
import pandas as pd

# Initialize Faker for generating fake data
fake = Faker()

# Create a list of dictionaries with fake data
data = []
for i in range(99,999):  # Create 10 entries
    data.append({
        'employee_id': str(0).join(map(str, [0, i+1])),
        'employee_name': fake.first_name(),
        'employee_last_name': fake.last_name()
    })

# Create a DataFrame from the list of dictionaries
df = pd.DataFrame(data)

# Display the table
print(df)