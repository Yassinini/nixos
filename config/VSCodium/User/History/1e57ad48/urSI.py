import random

words = ['hello','plant']
word = words[random.randint(0,len(words))]

# input --> num , letter
#use hangman game logic

inp = input("Enter a number and a letter seperated by comma (4,f): ").upper()
inp = inp.split(",")

wordL = list(word)
index, letter = inp, inp
#letter = inp[1]
#guess = [index, letter]

#print(wordL)
#print(guess)

empty = ["_","_","_","_","_"]
def let_check(word, index, letter):
    if wordL[index] == letter:
        empty[index] = letter
        return empty
    else:
        return empty