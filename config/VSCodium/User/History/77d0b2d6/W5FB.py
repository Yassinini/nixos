import random

while True:
  user_input = input("Enter to ROLL")
  if user_input == '':
    s = []
    for i in range(3):
      s.append(random.randint(1, 100))
    print(s)
    if s[0] == s[1] and s[1] == s[2]:
      print("JACKPOT")
    else:
      print("Unlucky roll!")
  else:
    print("Invalid input. Please just click ENTER")