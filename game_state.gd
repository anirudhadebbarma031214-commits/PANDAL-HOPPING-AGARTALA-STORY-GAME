extends Node
## Central story state for PANDAL HOPPING: AN AGARTALA STORY.
## Add as an Autoload named GameState in Project Settings when integrating.

signal mission_changed(title: String, description: String)
signal money_changed(balance: int)
signal message_received(sender: String, message: String)

var current_day: int = 10
var current_month: String = "October"
var current_mission: String = "THE CALL FROM HOME"
var mission_description: String = "Listen to Ma and Baba. Decide whether to return to Agartala."
var completed_missions: Array[String] = []
var balance: int = 18500
var phone_messages: Array[Dictionary] = [
    {"sender": "Ma", "text": "Baba, pujor age bari phire ay. We miss you."},
    {"sender": "Baba", "text": "If you can come home, your mother will be happy."}
]
var story_flags: Dictionary = {
    "office_call_seen": false,
    "ticket_booked": false,
    "arrived_agartala": false,
    "met_parents": false,
    "visited_friend_udaipur": false,
    "bought_puja_clothes": false,
    "first_pandal_visited": false
}

func set_mission(title: String, description: String) -> void:
    current_mission = title
    mission_description = description
    mission_changed.emit(title, description)

func complete_mission(title: String) -> void:
    if not completed_missions.has(title):
        completed_missions.append(title)

func add_message(sender: String, message: String) -> void:
    phone_messages.push_front({"sender": sender, "text": message})
    message_received.emit(sender, message)

func change_balance(amount: int) -> bool:
    if balance + amount < 0:
        return false
    balance += amount
    money_changed.emit(balance)
    return true

func set_flag(flag_name: String, value: bool = true) -> void:
    story_flags[flag_name] = value
