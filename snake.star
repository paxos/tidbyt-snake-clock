load("render.star", "render")
load("time.star", "time")
load("random.star", "random")
load("cache.star", "cache")
load("encoding/json.star", "json")

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

def main(config):
    timezone = config.get("timezone") or "America/New_York"
    now = time.now().in_location(timezone)

    random.seed(time.now().second) # makes sure things are random every second

    max_width = 64
    max_height = 32
    fps = 20

    snake_str = cache.get("snake")
    # snake_str = ""

    if snake_str == "":
        snake = [
            {"x": 10, "y": 16, "color": "#f00"},
            {"x": 11, "y": 16, "color": "#ff0"},
            {"x": 12, "y": 16, "color": "#ff0"},
            {"x": 13, "y": 16, "color": "#ff0"},
            {"x": 14, "y": 16, "color": "#ff0"},
            {"x": 15, "y": 16, "color": "#ff0"},
            {"x": 16, "y": 16, "color": "#ff0"},
            {"x": 17, "y": 16, "color": "#f00"},
            {"x": 18, "y": 16, "color": "#ff0"},
            {"x": 19, "y": 16, "color": "#ff0"},
            {"x": 20, "y": 16, "color": "#ff0"},
        ]
    else:
        snake = json.decode(snake_str)

    snake = move(snake)
    cache.set("snake", json.encode(snake), 300)

    snake_render_elements = [
        render.Padding(
            pad=(segment["x"], segment["y"], 0, 0),  # x, y
            child=render.Box(width=1, height=1, color=("#f00" if i == 0 else "#fff")),
        )
        for i, segment in enumerate(snake)
    ]

    return render.Root(
        delay = 500,
        child = render.Stack(
            children = snake_render_elements
        )
    )