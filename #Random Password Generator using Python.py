import random
import string

def generate_secure_password(length):
    """
    Generate a secure password of specified length with at least one character from each category.
    Args:
        length (int): Desired length of the password.
    Returns:
        str: Generated password, or None if length is invalid.
    """
    if length < 4:  # Minimum length to ensure one character from each category
        print("Password length must be at least 4 characters to include all required types.")
        return None

    # Define character sets
    lowercase = string.ascii_lowercase
    uppercase = string.ascii_uppercase
    digits = string.digits
    special = string.punctuation

    # Ensure at least one character from each category
    password = [
        random.choice(lowercase),
        random.choice(uppercase),
        random.choice(digits),
        random.choice(special)
    ]

    # Fill the remaining length with random characters
    all_chars = lowercase + uppercase + digits + special
    remaining_length = length - 4
    if remaining_length > 0:
        password.extend(random.choices(all_chars, k=remaining_length))

    # Shuffle the password
    random.shuffle(password)
    return "".join(password)

def get_password_length():
    """
    Prompt user for password length with validation.
    Returns:
        int: Valid password length.
    """
    while True:
        try:
            length = int(input("Enter the length of the password (minimum 4): "))
            if length < 1:
                print("Password length must be a positive integer.")
            elif length < 4:
                print("Password length must be at least 4 to include all character types.")
            else:
                return length
        except ValueError:
            print("Invalid input. Please enter a valid integer.")

def toggle_password_visibility(password, is_visible):
    """
    Toggle password visibility for display.
    Args:
        password (str): The password to display.
        is_visible (bool): Whether to show the password or mask it.
    Returns:
        str: Displayed password (either actual or masked).
    """
    return password if is_visible else "•" * len(password)

def main():
    """Main function to run the password generator."""
    print("Welcome to the Secure Password Generator!")

    # Get password length
    password_length = get_password_length()

    # Generate the password
    password = generate_secure_password(password_length)
    if not password:
        return

    # Toggle visibility
    is_visible = False
    while True:
        display_password = toggle_password_visibility(password, is_visible)
        print(f"\nGenerated Password: {display_password}")
        
        choice = input("Show password (s), generate new (n), or exit (e)? ").lower()
        if choice == 's':
            is_visible = not is_visible
        elif choice == 'n':
            password = generate_secure_password(password_length)
            is_visible = False
        elif choice == 'e':
            print("Goodbye!")
            break
        else:
            print("Invalid choice. Use 's' to show/hide, 'n' for new password, or 'e' to exit.")

if __name__ == "__main__":
    main()
