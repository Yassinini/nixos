import random

while True:
  user_input = input("Enter '1' to generate a list of numbers: ")
  if user_input == '':
    s = []
    for i in range(3):
      s.append(random.randint(1, 100))
    print(s)
    if s[0] == s[1] and s[1] == s[2]:
      print("JACKPOT")
    else:
      print("No jackpot this time. Try again!")
  else:
    print("Invalid input. Please enter '1' to play.")
