import random
import sys

words = ["Aback", "Abaft", "Aboon", "About", "Above", "Abuse", "Accel", "Acute", 
  "Adieu", "Adios", "Admit", "Adopt", "Adown", "Adult", "Afore", "Afoot", 
  "Afoul", "After", "Again", "Agape", "Agent", "Agree", "Agogo", "Agone", 
  "Ahead", "Ahull", "Alack", "Alcon", "Alert", "Alife", "Alike", "Alive", 
  "Aline", "Allay", "Allow", "Aloft", "Aloha", "Alone", "Along", "Aloof", 
  "Aloud", "Alter", "Amiss", "Among", "Amply", "Amuck", "Anger", "Angry", 
  "Apace", "Apart", "Apple", "Apply", "Aptly", "Arear", "Argue", "Arise", 
  "Aside", "Askew", "Aught", "Avast", "Avoid", "Award", "Aware", "Awful", 
  "Bacon", "Badly", "Bakaw", "Bally", "Basic", "Basis", "Basta", "Beach", 
  "Begin", "Below", "Birth", "Black", "Blame", "Bless", "Blind", "Block", 
  "Blood", "Board", "Bothe", "Brain", "Brava", "Bravo", "Bread", "Break", 
  "Brief", "Bring", "Broad", "Brown", "Build", "Burst", "Buyer", "Canny", 
  "Carry", "Catch", "Cause", "Chain", "Chair", "Cheap", "Check", "Chest", 
  "Chief", "Child", "China", "Circa", "Civil", "Claim", "Class", "Clean", 
  "Clear", "Climb", "Clock", "Close", "Coach", "Coast", "Count", "Court", 
  "Cover", "Coyly", "Crazy", "Cream", "Crime", "Cross", "Crowd", "Crown", 
  "Cycle", "Daily", "Dance", "Death", "Depth", "Dimly", "Dirty", "Ditto", 
  "Doubt", "Draft", "Drama", "Dream", "Dress", "Drink", "Drive", "Drily", 
  "Dryly", "Dully", "Early", "Earth", "Empty", "Enemy", "Enjoy", "Enter", 
  "Entry", "Equal", "Error", "Event", "Exact", "Exist", "Extra", "Faint", 
  "Faith", "False", "Fault", "Field", "Fight", "Final", "First", "Floor", 
  "Focus", "Force", "Forte", "Forth", "Frame", "Frank", "Fresh", "Front", 
  "Fruit", "Fudge", "Fully", "Funny", "Gaily", "Gayly", "Giant", "Glass", 
  "Godly", "Golly", "Grand", "Grant", "Grass", "Gratz", "Great", "Green", 
  "Gross", "Group", "Guess", "Guide", "Hallo", "Haply", "Happy", "Harsh", 
  "Heart", "Heavy", "Hella", "Hello", "Hence", "Henry", "Horse", "Hotel", 
  "House", "Howdy", "Hullo", "Human", "Huzza", "Icily", "Ideal", "Image", 
  "Imply", "Index", "Infra", "Input", "Issue", "Japan", "Jesus", "Jildi",  
  "Joint", "Jolly", "Judge", "Kapow", "Knife", "Large", "Laugh", "Layer", 
  "Laxly", "Learn", "Leave", "Legal", "Lento", "Level", "Light", "Limit", 
  "Local", "Loose", "Lordy", "Lower", "Lowly", "Lucky", "Lunch", "Madly", 
  "Magic", "Major", "March", "Marry", "Match", "Maybe", "Mercy", "Metal", 
  "Minor", "Model", "Money", "Month", "Moral", "Motor", "Mouth", "Music", 
  "Naked", "Nasty", "Naval", "Never", "Newly", "Night", "Nobly", "Noise", 
  "North", "Novel", "Nurse", "Occur", "Oddly", "Offer", "Often", "Order", 
  "Other", "Ought", "Outer", "Owner", "Panel", "Paper", "Party", "Peace", 
  "Phase", "Phone", "Piano", "Piece", "Pilot", "Pitch", "Place", "Plain", 
  "Plane", "Plant", "Plate", "Plonk", "Plumb", "Point", "Pound", "Power", 
  "Press", "Price", "Pride", "Prime", "Prior", "Prize", "Proof", "Proud", 
  "Prove", "Queen", "Queer", "Quick", "Quiet", "Quite", "Radio", "Raise", 
  "Range", "Rapid", "Ratio", "Reach", "Ready", "Refer", "Relax", "Reply", 
  "Right", "River", "Roman", "Rough", "Round", "Route", "Royal", "Rugby", 
  "Rural", "Sadly", "Scale", "Scene", "Scope", "Score", "Sense", "Serve", 
  "Shape", "Share", "Sharp", "Sheep", "Sheer", "Sheet", "Shift", "Shirt", 
  "Shock", "Shoot", "Sight", "Silly", "Since", "Skill", "Sleek", "Sleep", 
  "Smile", "Smoke", "Solid", "Solve", "Sorry", "Sound", "South", "Space", 
  "Spare", "Speak", "Speed", "Spend", "Spite", "Split", "Sport", "Squad", 
  "Staff", "Stage", "Stand", "Start", "State", "Steam", "Steel", "Steep", 
  "Still", "Stock", "Stone", "Store", "Study", "Stuff", "Style", "Sugar", 
  "Super", "Sweet", "Table", "Taste", "Teach", "Thank", "Theme", "There", 
  "Thick", "Thine", "Thing", "Think", "Third", "Throw", "Tight", "Title", 
  "Today", "Total", "Touch", "Tough", "Tower", "Track", "Trade", "Train", 
  "Treat", "Trend", "Trial", "Truly", "Trust", "Truth", "Twice", "Uncle", 
  "Under", "Union", "Unity", "Upper", "Upset", "Urban", "Usual", "Utter", 
  "Vague", "Valid", "Value", "Video", "Visit", "Vital", "Voice", "Waste", 
  "Watch", "Water", "Where", "Which", "While", "White", "Whole", "Whose", 
  "Whoso", "Woman", "World", "Worry", "Would", "Write", "Wrong", "Wryly", 
  "Young", "Yours", "Youth"
]
words = [word.upper() for word in words]
word = words[random.randint(0,len(words)-1)]
points = len(word)

wordL = list(word)
reveal = ["_"] * len(word)

    
def let_check(word, index, letter, points):
    print(f"Limbs: {points}")
    if wordL[index] == letter:
        reveal[index] = letter
        print("Correct!")
        print(reveal)
    else:
        reveal[index] = word[index]
        points -= 1
        print("Incorrect, heres the letter")
        print(f"*LIMB CUT* \n {points} left.")
        print(reveal)
    return points

def the_thing(points):
    inp = input("\nEnter position and letter (e.g., 2,E): ").strip().upper()
    
    try:
        parts = inp.split(",")
        index = int(parts[0].strip()) - 1
        letter = parts[1].strip()
        points = let_check(word, index, letter, points)

    except (ValueError, IndexError):
        print("Number out of range! Use numbers 1-5 and a letter separated by a comma (e.g., 2,E): ")
    return points

def choose():
    return input("\n0: Exit\n1: Start game\nEnter choice: ").strip()

def main():
    global points
    while True:
        choice = choose()
        if choice == "0":
            print("Thanks for playing! Goodbye.")
            sys.exit()
        elif choice == "1":
            points = the_thing(points)
            if reveal == wordL:
                print("You win!")
                sys.exit()
            elif points <= 0:
                print(f"Game Over. The word was {word}")
                sys.exit()
        else:
            print("Invalid option! Please enter 0 or 1.")

main()