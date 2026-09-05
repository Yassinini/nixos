import sys

table={
    'A': '.-',   'B': '-...',  'C': '-.-.',  'D': '-..',
    'E': '.',    'F': '..-.',  'G': '--.',   'H': '....',
    'I': '..',   'J': '.---',  'K': '-.-',   'L': '.-..',
    'M': '--',   'N': '-.',    'O': '---',   'P': '.--.',
    'Q': '--.-', 'R': '.-.',   'S': '...',   'T': '-',
    'U': '..-',  'V': '...-',  'W': '.--',   'X': '-..-',
    'Y': '-.--', 'Z': '--..',
    '0': '-----','1': '.----', '2': '..---', '3': '...--',
    '4': '....-','5': '.....', '6': '-....', '7': '--...',
    '8': '---..' ,'9': '----.',
    '.': '.-.-.-',',': '--..--','?': '..--..','!': '-.-.--',
    '/': '-..-.', '@': '.--.-.','-': '-....-','(': '-.--.',
    ')': '-.--.-',' ': '/'
}
def encode(x):
    for i in x:
        print(m[i.upper()], " ")

def decode(y):
    l=y.split(' ')
    for i in l:
        if i == "/":
            print(" \n ",)
        else:
            for key, val in m.items():
                if val == i:
                    print(key, " ")
                    break

print("welcome to my morse coder \n")
while True:
    n=int(input("\n 1: encode \n 2: decoder \n 3: exit \n"))
    if n == 1:
        encode(input("input: \n"))
    elif n == 2:
        decode(input("input: \n"))
    elif n == 3:
        sys.exit()
    else:
        print("invalid input, please try again")
        continue