import random

words = ['hello','plant']
word = words[random.randint(0,len(words)-1)]

# input --> num , letter
#use hangman game logic

inp = input("Enter a number and a letter seperated by comma (4,f): ").upper()
inp = inp.split(",")
wordL = list(word)
index, letter = inp
reveal = ["_"] * len(word)

#letter = inp[1]
#guess = [index, letter]

#print(wordL)
#print(guess)


def let_check(word, index, letter):
    if wordL[index] == letter:
        reveal[index] = letter
        return reveal
    else:
        return reveal

let_check(word,index,letter)