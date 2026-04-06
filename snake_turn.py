#!/usr/bin/env python3
import json, random, sys, os

STATE_FILE = "/home/user/Savedate-/snake_state.json"
W, H = 20, 15

def new_game():
    snake = [[W//2 - i, H//2] for i in range(3)]
    state = {
        "snake": snake,
        "dir": [1, 0],
        "food": spawn_food(snake),
        "score": 0,
        "alive": True
    }
    return state

def spawn_food(snake):
    while True:
        pos = [random.randint(0, W-1), random.randint(0, H-1)]
        if pos not in snake:
            return pos

def step(state, move):
    dirs = {"w": [0,-1], "a": [-1,0], "s": [0,1], "d": [1,0]}
    if move in dirs:
        nd = dirs[move]
        # Prevent 180 turn
        if nd[0] != -state["dir"][0] or nd[1] != -state["dir"][1]:
            state["dir"] = nd

    head = [state["snake"][0][0] + state["dir"][0],
            state["snake"][0][1] + state["dir"][1]]

    if head[0] < 0 or head[0] >= W or head[1] < 0 or head[1] >= H:
        state["alive"] = False
        return state
    if head in state["snake"]:
        state["alive"] = False
        return state

    state["snake"].insert(0, head)
    if head == state["food"]:
        state["score"] += 1
        state["food"] = spawn_food(state["snake"])
    else:
        state["snake"].pop()
    return state

def render(state):
    print(f"\n  SNAKE  |  Score: {state['score']}")
    print("  ┌" + "──" * W + "┐")
    snake_set = {tuple(s) for s in state["snake"]}
    head = tuple(state["snake"][0])
    food = tuple(state["food"])
    dir_ch = {str([1,0]): "▶", str([-1,0]): "◀", str([0,-1]): "▲", str([0,1]): "▼"}
    for y in range(H):
        row = "  │"
        for x in range(W):
            p = (x, y)
            if p == head:
                row += dir_ch.get(str(state["dir"]), "●") + " "
            elif p == food:
                row += "🍎"
            elif p in snake_set:
                row += "██"
            else:
                row += "· "
        row += "│"
        print(row)
    print("  └" + "──" * W + "┘")
    if not state["alive"]:
        print(f"\n  💀 GAME OVER! Score: {state['score']}")
        print("  Run with 'start' to play again")
    else:
        print("\n  Move: w=↑ a=← s=↓ d=→  (or 'f' = forward)")

def main():
    move = sys.argv[1] if len(sys.argv) > 1 else "start"

    if move == "start":
        state = new_game()
    else:
        with open(STATE_FILE) as f:
            state = json.load(f)
        if not state["alive"]:
            state = new_game()
        else:
            if move == "f":
                move = None  # keep current direction
                state = step(state, None)
            else:
                state = step(state, move)

    with open(STATE_FILE, "w") as f:
        json.dump(state, f)

    render(state)

if __name__ == "__main__":
    main()
