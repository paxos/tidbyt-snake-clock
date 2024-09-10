"""
Applet: Snake Clock
Summary: Shows the time and a snake
Description: Shows the time with a snake slithering around in the background.
Author: paxos
"""

load("render.star", "render")
load("time.star", "time")
load("random.star", "random")
load("cache.star", "cache")
load("encoding/json.star", "json")

def hex_to_rgb(hex_color):
    hex_color = hex_color.lstrip('#')
    return (int(hex_color[0:2], 16), int(hex_color[2:4], 16), int(hex_color[4:6], 16))

def int_to_hex(value):
    hex_chars = "0123456789abcdef"
    return hex_chars[(value >> 4) & 0xF] + hex_chars[value & 0xF]

def rgb_to_hex(rgb_color):
    return "#" + int_to_hex(rgb_color[0]) + int_to_hex(rgb_color[1]) + int_to_hex(rgb_color[2])

def interpolate_color(color1, color2, factor):
    rgb1 = hex_to_rgb(color1)
    rgb2 = hex_to_rgb(color2)
    interpolated_rgb = (
        int(rgb1[0] + (rgb2[0] - rgb1[0]) * factor),
        int(rgb1[1] + (rgb2[1] - rgb1[1]) * factor),
        int(rgb1[2] + (rgb2[2] - rgb1[2]) * factor)
    )
    return rgb_to_hex(interpolated_rgb)


def color_snake(snake):
    head_color = "#ff0000"
    tail_color = "#000000"
    
    length = len(snake)
    for i, segment in enumerate(snake):
        factor = i / (length - 1) if length > 1 else 0
        segment["color"] = interpolate_color(head_color, tail_color, factor)
    
    return snake

def valid_location(x,y,snake):
    if x < 0 or x >= 64 or y < 0 or y >= 32:
        return False

    # Check if we overlap with any snake parts
    for part in snake:
        if part["x"] == x and part["y"] == y:
            return False

    return True

def move(snake):

    head = snake[0]
    x = head["x"]
    y = head["y"]

    direction = random.number(0, 3)

    if direction == 0:
        # Move right
        x = x + 1
    elif direction == 1:
        # Move left
        x = x - 1
    elif direction == 2:
        # Move up
        y = y - 1
    else:
        # Move down
        y = y + 1

    is_valid_move = valid_location(x, y, snake)
    if not is_valid_move:
        print("No valid location found, trying again")
        return move(snake)
    else:
        print("Moving to " + str(x) + ", " + str(y))

    new_head = {"x": x, "y": y, "color": "#ff0"}

    snake.insert(0, new_head)
    snake.pop()

    return snake

def snake_to_elements(snake):
    snake_elements = [
        render.Padding(
            pad=(segment["x"], segment["y"], 0, 0),  # x, y
            child=render.Box(width=1, height=1, color=(segment["color"])),
        )
        for i, segment in enumerate(snake)
    ]
    return snake_elements

def main(config):
    timezone = config.get("timezone") or "America/New_York"
    now = time.now().in_location(timezone)

    random.seed(time.now().second) # makes sure things are random every second

    max_width = 64
    max_height = 32
    fps = 20

    snake_str = cache.get("snake")
    #snake_str = None

    if snake_str == None:
        snake = []
        for i in range(10, 30):
            snake.append({"x": i, "y": 16, "color": "#ff0"})
    else:
        snake = json.decode(snake_str)

    
    
    snake_render_elements = []

    for i in range(30):
        snake = move(snake)
        snake = color_snake(snake)
        snake_render_elements.append(
            render.Stack(
                children = snake_to_elements(snake)
            )
        )

    cache.set("snake", json.encode(snake), 300) 

    timezone = config.get("timezone") or "America/New_York"
    now = time.now().in_location(timezone)

    #print(snake_render_elements)

    return render.Root(
        delay = 50, # lets assume we refresh every 60 seconds, so we generate 30 frames and show each 2 seconds
        child = render.Stack(
            children = [
                render.Animation(
                    children=snake_render_elements
                )
            ]
             + [
                render.Box(
                    child = render.Padding(
                        color = "#181918", # BG Color for time padding
                        pad = (1, 1, 1, 0),
                        child = render.Text(
                            content = now.format("15:04"),
                            font = "tom-thumb",
                            color = "#fff",
                        ),
                    ),
                )
            ]
        )
    )