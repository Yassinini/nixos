c=input("continue? (y/n) (y default):   ")
while c == "y" or c == "" or c=="yes":
    x=input("show em hands: ").lower().split()
    print("\n")
    n = 0
    word=input("whats the word? whats the haps? \n")
    for i in x:
        if i == word:
            n+=1

    print(f"ur word hath been detected by this very advanced model a total of {n} whole times")
    c=input("continue? (y/n) (y default):   ")

#try to make a cli word app where u get word counters and stuff to edit and know more ab ur essay wdyt future me?