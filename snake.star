load("render.star", "render")
load("time.star", "time")
load("random.star", "random")

def main(config):
    timezone = config.get("timezone") or "America/New_York"
    now = time.now().in_location(timezone)

    random.seed(time.now().second) # makes sure things are random every second
    num = random.number(0, 100)
    num_str = str(num)

    return render.Root(
        delay = 500,
        child = render.Box(
            color="#000",
            child = render.Animation(
                children = [
                        render.Text(
                        content = num_str,
                        font = "6x13",
                    ),
                ],
            ),
        ),
    )