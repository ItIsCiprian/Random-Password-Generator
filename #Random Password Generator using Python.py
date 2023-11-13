import random
import string

def generate_password(length):
    # Define character sets
    lowercase = string.ascii_lowercase
    uppercase = string.ascii_uppercase
    digits = string.digits
    special_characters = string.punctuation

    # Combine the character sets
    all_characters = lowercase + uppercase + digits + special_characters

    # Ensure the length is valid
    if length < 1:
        print("Password length must be at least 1 character.")
        return None

    # Generate a random password
    password_list = random.sample(all_characters, length)
    password = "".join(password_list)

    return password

def get_password_length():
    # Input the length of the password
    while True:
        try:
            length = int(input("Enter the length of the password: "))
            if length > 0:
                return length
            else:
                print("Password length must be a positive integer.")
        except ValueError:
            print("Invalid input. Please enter a valid integer.")

if __name__ == "__main__":
    # Get password length from user
    password_length = get_password_length()

    # Generate and print the password
    generated_password = generate_password(password_length)
    if generated_password:
        print("Generated Password:", generated_password)
