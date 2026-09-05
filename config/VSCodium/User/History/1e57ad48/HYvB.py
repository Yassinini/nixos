import random
import sys

words = ['plant', 'hello']
words = [word.upper() for word in words]
word = words[random.randint(0,len(words)-1)]

# input --> num , letter
#use hangman game logic
    
def let_check(word, index, letter):
    print(points)
    if wordL[index] == letter:
        reveal[index] = letter
        print("Correct!")
        print(reveal)
        return reveal
    else:
        reveal[index] = word[index]
        print("Incorrect, heres the letter")
        return reveal

def the_thing():
    inp = input("Enter a number and a letter seperated by comma (4,f): ").upper()
    inp = inp.split(",")
    wordL = list(word)
    index = int(inp[0].strip()) - 1
    letter = inp[1].strip()
    reveal = ["_"] * len(word)
    points = len(word)
    let_check(word,index,letter)


while True:
    enter = int(input("0: Exit\n 1: Start game \n "))
    if input == 0:
        sys.exit()
    elif input == 1:
        the_thing()