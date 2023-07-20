#!/usr/bin/env python3
# modified from HSCTF 10 grader
import json
with open("locations.json") as f:
	locations = json.load(f)
wrong = False
for i, coords in enumerate(locations, start=1):
	x2, y2 = coords
	x, y = map(float, input(f"Please enter the long and lat of the location: ").replace(",","").split(" "))
	if abs(x2 - x) < 0.0025 and abs(y2 - y) < 0.0025:
		print("Correct!")
	else:
		print("Wrong!")
		wrong = True

if not wrong:
	with open("flag.txt") as f:
		print("Great job, the flag is ",f.read().strip())
else:
	print("Better luck next time, but here's a postcard. (hopefully your term can display it) ")
	with open("bear.bin") as f:
		print(f.read())