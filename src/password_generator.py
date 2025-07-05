import random
import string

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
            character_sets.append(string.punctuation)
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

def main():
    print("========================================")
    print("   Welcome to the Password Generator!   ")
    print("========================================")

    try:
        length = int(input("Enter password length (e.g., 12): "))
        if length < 4:
            print("Password length must be at least 4.")
            return

        use_lowercase = input("Include lowercase letters? (y/n): ").lower() == 'y'
        use_uppercase = input("Include uppercase letters? (y/n): ").lower() == 'y'
        use_digits = input("Include digits? (y/n): ").lower() == 'y'
        use_special = input("Include special characters? (y/n): ").lower() == 'y'

        generator = PasswordGenerator(
            length=length,
            use_lowercase=use_lowercase,
            use_uppercase=use_uppercase,
            use_digits=use_digits,
            use_special=use_special
        )
        password = generator.generate()
        print(f"\nGenerated Password: {password}")

    except ValueError as e:
        print(f"Error: {e}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")

if __name__ == "__main__":
    main()
