load("render.star", "render")
load("time.star", "time")
load("schema.star", "schema")

# --- 11 Color Themes ---
# [background, divider, left_label, left_number, right_label, right_number]
THEMES = {
    "ocean":   ["#091520", "#1a4a6e", "#5dade2", "#00e5ff", "#48c9b0", "#1affd5"],
    "sunset":  ["#1a0a05", "#6e3a1a", "#e2875d", "#ff6e00", "#d4a843", "#ffd51a"],
    "mystic":  ["#140a20", "#4a1a6e", "#ad5de2", "#c800ff", "#c9a848", "#f7dc6f"],
    "forest":  ["#071a0c", "#1a6e2e", "#5de278", "#00ff6e", "#a8c948", "#d5ff1a"],
    "rose":    ["#1a0a14", "#6e1a4a", "#e25dad", "#ff69b4", "#c95d78", "#ff8fab"],
    "ice":     ["#0a1420", "#1a4a6e", "#a8d8ea", "#e0f7ff", "#c8d6e5", "#ffffff"],
    "fire":    ["#1a0800", "#6e2a0a", "#e26a30", "#ff4500", "#e2a85d", "#ffaa00"],
    "lavender":["#12091a", "#3d1a5e", "#b39ddb", "#e1bee7", "#9fa8da", "#c5cae9"],
    "gold":    ["#1a1400", "#6e5a0a", "#d4a843", "#ffd700", "#c9a030", "#ffec8b"],
    "berry":   ["#1a0510", "#6e1040", "#d45d8a", "#ff1493", "#a84dca", "#da70d6"],
    "midnight":["#050510", "#1a1a4e", "#6e6ebe", "#8a8aff", "#5e8ebe", "#70b0ff"],
}

# 5x7 block numerals for a larger, bolder display.
DIGIT_PATTERNS = {
    "0": ["11111", "11011", "11011", "11011", "11011", "11011", "11111"],
    "1": ["00110", "01110", "00110", "00110", "00110", "00110", "11111"],
    "2": ["11111", "00011", "00011", "11111", "11000", "11000", "11111"],
    "3": ["11111", "00011", "00011", "01111", "00011", "00011", "11111"],
    "4": ["11011", "11011", "11011", "11111", "00011", "00011", "00011"],
    "5": ["11111", "11000", "11000", "11111", "00011", "00011", "11111"],
    "6": ["11111", "11000", "11000", "11111", "11011", "11011", "11111"],
    "7": ["11111", "00011", "00011", "00110", "00110", "01100", "01100"],
    "8": ["11111", "11011", "11011", "01110", "11011", "11011", "11111"],
    "9": ["11111", "11011", "11011", "11111", "00011", "00011", "11111"],
}

def get_theme(config):
    name = config.get("theme") or "ocean"
    t = THEMES.get(name)
    if t == None:
        t = THEMES["ocean"]
    return t

def digit_sum(n):
    total = 0
    s = str(n)
    for i in range(len(s)):
        c = s[i]
        if c >= "0" and c <= "9":
            total = total + int(c)
    return total

def reduce_to_single(n):
    for _ in range(10):
        if n <= 9 or n == 11 or n == 22 or n == 33:
            return n
        n = digit_sum(n)
    return n

def universal_day_number(year, month, day):
    total = 0
    total = total + digit_sum(month)
    total = total + digit_sum(day)
    total = total + digit_sum(year)
    return reduce_to_single(total)

def calendar_day_number(day):
    return reduce_to_single(digit_sum(day))

def render_big_number_row(text, color, scale, digit_gap):
    digits = []
    for i in range(len(text)):
        ch = text[i]
        pattern = DIGIT_PATTERNS.get(ch)
        if pattern == None:
            continue

        rows = []
        for row in pattern:
            pixels = []
            for j in range(len(row)):
                col = row[j]
                if col == "1":
                    pixels.append(render.Box(width = scale, height = scale, color = color))
                else:
                    pixels.append(render.Box(width = scale, height = scale))
            rows.append(
                render.Row(
                    children = pixels,
                ),
            )

        digits.append(
            render.Column(
                children = rows,
            ),
        )

        if i < len(text) - 1:
            digits.append(render.Box(width = digit_gap, height = 1))

    return render.Row(
        children = digits,
    )

def render_big_number(value, color):
    scale = 3
    digit_gap = 1
    text = str(value)

    return render_big_number_row(
        text = text,
        color = color,
        scale = scale,
        digit_gap = digit_gap,
    )

def main(config):
    timezone = config.get("timezone") or "America/New_York"
    now = time.now().in_location(timezone)

    year = now.year
    month = now.month
    day = now.day

    uni_num = universal_day_number(year, month, day)
    cal_num = calendar_day_number(day)

    theme = get_theme(config)
    bg = theme[0]
    divider = theme[1]
    left_label = theme[2]
    left_num = theme[3]
    right_label = theme[4]
    right_num = theme[5]

    # Master numbers get gold
    if uni_num == 11 or uni_num == 22 or uni_num == 33:
        left_num = "#f7dc6f"
    if cal_num == 11 or cal_num == 22 or cal_num == 33:
        right_num = "#f7dc6f"

    return render.Root(
        child = render.Box(
            color = bg,
            child = render.Column(
                children = [
                    render.Box(width = 1, height = 1),
                    render.Row(
                        children = [
                            render.Box(width = 1, height = 1),
                            render.Row(
                                expanded = True,
                                main_align = "space_evenly",
                                cross_align = "center",
                                children = [
                                    # --- LEFT: Universal ---
                                    render.Column(
                                        main_align = "center",
                                        cross_align = "center",
                                        expanded = True,
                                        children = [
                                            render.Text(
                                                content = "UNIV",
                                                font = "tom-thumb",
                                                color = left_label,
                                            ),
                                            render.Box(width = 1, height = 1),
                                            render_big_number(uni_num, left_num),
                                        ],
                                    ),
                                    # --- DIVIDER ---
                                    render.Box(
                                        width = 1,
                                        height = 26,
                                        color = divider,
                                    ),
                                    # --- RIGHT: Calendar ---
                                    render.Column(
                                        main_align = "center",
                                        cross_align = "center",
                                        expanded = True,
                                        children = [
                                            render.Text(
                                                content = "CAL",
                                                font = "tom-thumb",
                                                color = right_label,
                                            ),
                                            render.Box(width = 1, height = 1),
                                            render_big_number(cal_num, right_num),
                                        ],
                                    ),
                                ],
                            ),
                            render.Box(width = 1, height = 1),
                        ],
                    ),
                    render.Box(width = 1, height = 1),
                ],
            ),
        ),
    )

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Dropdown(
                id = "theme",
                name = "Color Theme",
                desc = "Pick a color vibe.",
                icon = "palette",
                default = "ocean",
                options = [
                    schema.Option(display = "Ocean", value = "ocean"),
                    schema.Option(display = "Sunset", value = "sunset"),
                    schema.Option(display = "Mystic", value = "mystic"),
                    schema.Option(display = "Forest", value = "forest"),
                    schema.Option(display = "Rose", value = "rose"),
                    schema.Option(display = "Ice", value = "ice"),
                    schema.Option(display = "Fire", value = "fire"),
                    schema.Option(display = "Lavender", value = "lavender"),
                    schema.Option(display = "Gold", value = "gold"),
                    schema.Option(display = "Berry", value = "berry"),
                    schema.Option(display = "Midnight", value = "midnight"),
                ],
            ),
        ],
    )
