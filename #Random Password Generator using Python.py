#Random Password Generator using Python

#import the necessary modules
import random
import string

#imput the length of the password
lenght = int(input("Enter the length of the password: "))

#Define the data
lower = string.ascii_lowercase
upper = string.ascii_uppercase
num = string.digits
string = string.punctuation

#combine the data
all = lower + upper + num + string

#use random
temp    = random.sample(all, lenght)

#Create the password
password = "".join(temp)

#print the password
print("Password: ", password)

