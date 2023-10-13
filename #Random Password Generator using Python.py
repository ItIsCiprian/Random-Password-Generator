import random
import string

# Input the length of the password
length = int(input("Enter the length of the password: "))

# Define character sets
lowercase = string.ascii_lowercase
uppercase = string.ascii_uppercase
digits = string.digits
special_characters = string.punctuation

# Combine the character sets
all_characters = lowercase + uppercase + digits + special_characters

# Generate a random password
password_list = random.sample(all_characters, length)
password = "".join(password_list)

# Print the password
print("Generated Password:", password)
