extends Node

const tile_size = 80

const ai_team = "RedTeam"
const human_team = "GreenTeam"

const team_colors = {
    "NoTeam": Color(1, 1, 1, 1),
    "GreenTeam": Color(0, 0.862745, 0, 1),
    "RedTeam": Color(1, 0.247059, 0.188235, 1),
}

var debug_select_any = false
