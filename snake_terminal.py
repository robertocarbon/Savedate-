#!/usr/bin/env python3
import curses
import random
import time

def main(stdscr):
    # Setup
    curses.curs_set(0)
    curses.start_color()
    curses.use_default_colors()
    curses.init_pair(1, curses.COLOR_GREEN, -1)   # Snake
    curses.init_pair(2, curses.COLOR_RED, -1)      # Food
    curses.init_pair(3, curses.COLOR_YELLOW, -1)   # Score
    curses.init_pair(4, curses.COLOR_CYAN, -1)     # Border
    curses.init_pair(5, curses.COLOR_WHITE, curses.COLOR_GREEN)  # Snake head

    GRID_W, GRID_H = 30, 20
    BOX_TOP, BOX_LEFT = 2, 2
    tick = 0.12

    def show_screen(title, subtitle, color_pair=1):
        stdscr.clear()
        h, w = stdscr.getmaxyx()
        # Border
        for x in range(BOX_LEFT, BOX_LEFT + GRID_W + 2):
            stdscr.addch(BOX_TOP, x, '─', curses.color_pair(4))
            stdscr.addch(BOX_TOP + GRID_H + 1, x, '─', curses.color_pair(4))
        for y in range(BOX_TOP, BOX_TOP + GRID_H + 2):
            stdscr.addch(y, BOX_LEFT, '│', curses.color_pair(4))
            stdscr.addch(y, BOX_LEFT + GRID_W + 1, '│', curses.color_pair(4))
        stdscr.addch(BOX_TOP, BOX_LEFT, '┌', curses.color_pair(4))
        stdscr.addch(BOX_TOP, BOX_LEFT + GRID_W + 1, '┐', curses.color_pair(4))
        stdscr.addch(BOX_TOP + GRID_H + 1, BOX_LEFT, '└', curses.color_pair(4))
        stdscr.addch(BOX_TOP + GRID_H + 1, BOX_LEFT + GRID_W + 1, '┘', curses.color_pair(4))

        cy = BOX_TOP + GRID_H // 2
        cx = BOX_LEFT + 1 + (GRID_W - len(title)) // 2
        stdscr.addstr(cy, max(cx, BOX_LEFT + 1), title, curses.color_pair(color_pair) | curses.A_BOLD)
        cx2 = BOX_LEFT + 1 + (GRID_W - len(subtitle)) // 2
        stdscr.addstr(cy + 2, max(cx2, BOX_LEFT + 1), subtitle, curses.color_pair(3))
        stdscr.refresh()
        stdscr.nodelay(False)
        stdscr.getch()

    def spawn_food(snake):
        while True:
            pos = (random.randint(0, GRID_W - 1), random.randint(0, GRID_H - 1))
            if pos not in snake:
                return pos

    while True:
        show_screen("🐍  S N A K E  🐍", "Press any key to play")

        # Init game
        snake = [(GRID_W // 2 - i, GRID_H // 2) for i in range(3)]
        snake_set = set(snake)
        direction = (1, 0)
        next_dir = (1, 0)
        score = 0
        food = spawn_food(snake_set)
        speed = tick

        stdscr.nodelay(True)
        stdscr.timeout(int(speed * 1000))

        game_over = False
        while not game_over:
            # Input
            key = stdscr.getch()
            while key != -1:
                if key == curses.KEY_UP or key == ord('w'):
                    if direction != (0, 1): next_dir = (0, -1)
                elif key == curses.KEY_DOWN or key == ord('s'):
                    if direction != (0, -1): next_dir = (0, 1)
                elif key == curses.KEY_LEFT or key == ord('a'):
                    if direction != (1, 0): next_dir = (-1, 0)
                elif key == curses.KEY_RIGHT or key == ord('d'):
                    if direction != (-1, 0): next_dir = (1, 0)
                elif key == ord('q'):
                    return
                key = stdscr.getch()

            direction = next_dir
            head = (snake[0][0] + direction[0], snake[0][1] + direction[1])

            # Collision
            if head[0] < 0 or head[0] >= GRID_W or head[1] < 0 or head[1] >= GRID_H:
                game_over = True
                continue
            if head in snake_set:
                game_over = True
                continue

            snake.insert(0, head)
            snake_set.add(head)

            if head == food:
                score += 1
                food = spawn_food(snake_set)
                speed = max(0.05, tick - score * 0.003)
                stdscr.timeout(int(speed * 1000))
            else:
                tail = snake.pop()
                snake_set.remove(tail)

            # Draw
            stdscr.clear()
            # Score bar
            score_text = f" SCORE: {score} "
            stdscr.addstr(0, BOX_LEFT, score_text, curses.color_pair(3) | curses.A_BOLD)
            controls = "← ↑ ↓ → / WASD  Q=Quit"
            stdscr.addstr(0, BOX_LEFT + GRID_W + 2 - len(controls), controls, curses.color_pair(4))

            # Border
            for x in range(BOX_LEFT, BOX_LEFT + GRID_W + 2):
                stdscr.addch(BOX_TOP, x, '─', curses.color_pair(4))
                stdscr.addch(BOX_TOP + GRID_H + 1, x, '─', curses.color_pair(4))
            for y in range(BOX_TOP + 1, BOX_TOP + GRID_H + 1):
                stdscr.addch(y, BOX_LEFT, '│', curses.color_pair(4))
                stdscr.addch(y, BOX_LEFT + GRID_W + 1, '│', curses.color_pair(4))
            stdscr.addch(BOX_TOP, BOX_LEFT, '┌', curses.color_pair(4))
            stdscr.addch(BOX_TOP, BOX_LEFT + GRID_W + 1, '┐', curses.color_pair(4))
            stdscr.addch(BOX_TOP + GRID_H + 1, BOX_LEFT, '└', curses.color_pair(4))
            stdscr.addch(BOX_TOP + GRID_H + 1, BOX_LEFT + GRID_W + 1, '┘', curses.color_pair(4))

            # Food
            fx, fy = food
            stdscr.addch(BOX_TOP + 1 + fy, BOX_LEFT + 1 + fx, '●', curses.color_pair(2) | curses.A_BOLD)

            # Snake
            for i, (sx, sy) in enumerate(snake):
                if i == 0:
                    ch = {(1,0): '>', (-1,0): '<', (0,-1): '^', (0,1): 'v'}.get(direction, 'O')
                    stdscr.addch(BOX_TOP + 1 + sy, BOX_LEFT + 1 + sx, ch, curses.color_pair(5) | curses.A_BOLD)
                else:
                    stdscr.addch(BOX_TOP + 1 + sy, BOX_LEFT + 1 + sx, '█', curses.color_pair(1))

            stdscr.refresh()

        # Game Over
        show_screen(f"GAME OVER  -  Score: {score}", "Press any key to retry (Q=Quit)")

if __name__ == "__main__":
    curses.wrapper(main)
