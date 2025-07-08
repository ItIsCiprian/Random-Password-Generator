import random
import string
import os
import textwrap

class PasswordGenerator:
    def __init__(self, length=12, use_lowercase=True, use_uppercase=True, use_digits=True, use_special=True):
        self.length = length
        self.use_lowercase = use_lowercase
        self.use_uppercase = use_uppercase
        self.use_digits = use_digits
        self.use_special = use_special
        self.character_sets = self._build_character_sets()

    def _build_character_sets(self):
        character_sets = []
        if self.use_lowercase:
            character_sets.append(string.ascii_lowercase)
        if self.use_uppercase:
            character_sets.append(string.ascii_uppercase)
        if self.use_digits:
            character_sets.append(string.digits)
        if self.use_special:
            character_sets.append('!@#$%^&*()_+-=[]{}|;:,.<>?')
        return character_sets

    def generate(self):
        if not self.character_sets:
            raise ValueError("At least one character type must be selected.")

        password = []
        # Ensure at least one character from each selected set
        for char_set in self.character_sets:
            password.append(random.choice(char_set))

        # Fill the rest of the password length
        all_chars = "".join(self.character_sets)
        remaining_length = self.length - len(password)
        if remaining_length > 0:
            password.extend(random.choices(all_chars, k=remaining_length))

        # Shuffle to ensure randomness
        random.shuffle(password)
        return "".join(password)

def print_header(title):
    os.system('cls' if os.name == 'nt' else 'clear')
    print("==========================================")
    print(f"   {title}   ")
    print("==========================================")

def print_centered(text):
    terminal_width = os.get_terminal_size().columns
    for line in text.split('\n'):
        print(line.center(terminal_width))

def get_yes_no(prompt):
    while True:
        choice = input(prompt).lower()
        if choice in ['y', 'n']:
            return choice == 'y'
        print("Invalid input. Please enter 'y' or 'n'.")

def show_info():
    print_header("About Cipher Generator")
    info_text = """
    Modern Password Generator
    Built by Ionut Ciprian Anescu
    GitHub Profile: https://github.com/ItIsCiprian

    Features:
    - Customizable Password Generation
    - Interactive CLI
    - Modern Web UI
    - Secure

    Project Overview:
    This project contains two implementations of a random password generator:
    - A Flutter application
    - A simple web version
    """
    print(textwrap.dedent(info_text))
    input("\nPress Enter to return to the main menu...")

def show_license():
    print_header("License - GPL v3")
    license_text = """
    GNU General Public License v3.0
    Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
    Everyone is permitted to copy and distribute verbatim copies of this license document, but changing it is not allowed.
    (The full license text is available in the LICENSE file)
    """
    print(textwrap.dedent(license_text))
    input("\nPress Enter to return to the main menu...")


def main():
    while True:
        print_header("Modern Password Generator")
        print("1. Generate Password")
        print("2. About")
        print("3. License")
        print("4. Exit")
        choice = input("\nEnter your choice: ")

        if choice == '1':
            try:
                length = int(input("Enter password length (e.g., 12): "))
                if length < 4:
                    print("Password length must be at least 4.")
                    continue

                use_lowercase = get_yes_no("Include lowercase letters? (y/n): ")
                use_uppercase = get_yes_no("Include uppercase letters? (y/n): ")
                use_digits = get_yes_no("Include digits? (y/n): ")
                use_special = get_yes_no("Include special characters? (y/n): ")

                generator = PasswordGenerator(
                    length=length,
                    use_lowercase=use_lowercase,
                    use_uppercase=use_uppercase,
                    use_digits=use_digits,
                    use_special=use_special
                )
                password = generator.generate()
                print(f"\nGenerated Password: {password}")
                input("\nPress Enter to continue...")

            except ValueError as e:
                print(f"Error: {e}")
            except Exception as e:
                print(f"An unexpected error occurred: {e}")

        elif choice == '2':
            show_info()
        elif choice == '3':
            show_license()
        elif choice == '4':
            break
        else:
            print("Invalid choice. Please try again.")

if __name__ == "__main__":
    main()