import random

words = ['plant']
words = [word.upper() for word in words]
word = words[random.randint(0,len(words)-1)]

# input --> num , letter
#use hangman game logic

inp = input("Enter a number and a letter seperated by comma (4,f): ").upper()
inp = inp.split(",")
wordL = list(word)
index = int(inp[0].strip()) - 1
letter = inp[1].strip()
reveal = ["_"] * len(word)

#letter = inp[1]
#guess = [index, letter]

#print(wordL)
#print(guess)


def let_check(word, index, letter):
    if wordL[index] == letter:
        reveal[index] = letter
        print("Correct!")
        return reveal
    else:
        print("Incorrect, die.")
        return reveal

let_check(word,index,letter)