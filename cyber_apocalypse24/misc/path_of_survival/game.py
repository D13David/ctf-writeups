import json
import requests
from collections import defaultdict
import heapq

url = "http://83.136.250.36:50877/"

terrain_costs = {
    "P": {"P": 1, "M":  5, "S": 2, "R": 5, "C": 1, "G": 1},
    "M": {"P": 2, "M":  1, "S": 5, "R": 8, "C": 1, "G": 1},
    "S": {"P": 2, "M":  7, "S": 1, "R": 8, "C": 1, "G": 1},
    "R": {"P": 5, "M": 10, "S": 7, "R": 1, "C": 1, "G": 1},
    "C": {"P": 1, "M":  1, "S": 1, "R": 1, "C": 1, "G": 1},
    "G": {"P": 1, "M":  1, "S": 1, "R": 1, "C": 1, "G": 1}
}


posX = 0
posY = 0
grid = {}

def get_neighbors(pos):
    x, y = pos
    neighbors = []

    # left
    if (x - 1, y) in grid and not grid[(x-1, y)]["terrain"] == "C":
        neighbors.append((x - 1, y))
    # right
    if (x + 1, y) in grid and not grid[(x+1,y)]["terrain"] == "G":
        neighbors.append((x + 1, y))
    # bottom
    if (x, y + 1) in grid and not grid[(x,y+1)]["terrain"] == "G":
        neighbors.append((x, y + 1))
    # top
    if (x, y - 1) in grid and not grid[(x,y-1)]["terrain"] == "C":
        neighbors.append((x, y - 1))

    return neighbors

def search_path(start, end):
    heap = [(0, start, [])]
    visited = set()
    distances = defaultdict(lambda: float("inf"))
    distances[start] = 0
    while heap:
        dist, current, path = heapq.heappop(heap)
        if current in visited:
            continue
        visited.add(current)
        if current == end:
            return dist, path + [current]
        for neighbor in get_neighbors(current):
            new_dist = dist + terrain_costs[grid[current]["terrain"]][grid[neighbor]["terrain"]]
            if new_dist < distances[neighbor]:
                distances[neighbor] = new_dist
                heapq.heappush(heap, (new_dist, neighbor, path + [current]))
    return float("inf"), []

def load_map():
    global grid
    global posX, posY

    result = json.loads(requests.post(url + "map").text)

    posX = result["player"]["position"][0]
    posY = result["player"]["position"][1]

    grid = {}

    for k, v in result["tiles"].items():
        if v["terrain"] == "E":
            continue
        x, y = k.strip("()").split(",")
        x = int(x)
        y = int(y)
        grid[(x,y)] = v

for i in range(100):
    load_map()

    weapon_tiles = []
    for pos, tile in grid.items():
        if tile["has_weapon"]:
            weapon_tiles.append(pos)

    print(weapon_tiles)

    dist = 999999
    path = None
    for i in weapon_tiles:
        dist_, path_ = search_path((posX, posY), i)
        if dist_ < dist:
            dist = dist_
            path = path_

    print(dist, path)

    for i in path[1:]:
        px, py = i
        d = ""
        if px < posX:
            d = "L"
        elif px > posX:
            d = "R"
        elif py < posY:
            d = "U"
        else:
            d = "D"
        posX = px
        posY = py

        result = requests.post(url + "update", json={"direction": d})
        print(result.text)