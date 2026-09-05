import random
import sys

words = ['plant', 'hello']
words = [word.upper() for word in words]
word = words[random.randint(0,len(words)-1)]
points = len(word)

wordL = list(word)
reveal = ["_"] * len(word)

    
def let_check(word, index, letter):
    print(f"Limbs: {points}")
    if wordL[index] == letter:
        reveal[index] = letter
        print("Correct!")
        print(reveal)
        return reveal
    else:
        reveal[index] = word[index]
        print("Incorrect, heres the letter")
        print(reveal)
        return reveal

def the_thing():
    inp = input("Enter a number and a letter seperated by comma (4,f): ").upper()
    inp = inp.split(",")
    index = int(inp[0].strip()) - 1
    letter = inp[1].strip()
    let_check(word,index,letter)

def choose():
    return input("\n0: Exit\n1: Start game\nEnter choice: ").strip()

def main():
    choice = choose()
    while True:
        if choice == "0":
            print("Thanks for playing! Goodbye.")
            sys.exit()
        elif choice == "1":
            the_thing()
        else:
            print("Invalid option! Please enter 0 or 1.")
            break1
        if reveal == word:
            choose()

main()