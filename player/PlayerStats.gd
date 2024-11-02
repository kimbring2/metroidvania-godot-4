extends Stats

@export var max_missiles = 0 : set = set_max_missiles
@export var max_shields = 0 : set = set_max_shields 

@onready var missiles = max_missiles : set = set_missiles
@onready var shields = max_shields : set = set_shields

@onready var starting_max_health = max_health
@onready var starting_max_missiles = max_missiles
@onready var starting_max_shields = max_shields

signal max_missiles_changed
signal max_shields_changed

signal missiles_changed
signal shields_changed


func set_max_missiles(value):
	max_missiles = value
	max_missiles_changed.emit()
	

func set_max_shields(value):
	max_shields = value
	max_shields_changed.emit()


func set_missiles(value):
	missiles = value
	missiles_changed.emit()
	

func set_shields(value):
	shields = value
	shields_changed.emit()


func reset():
	max_health = starting_max_health
	max_missiles = starting_max_missiles
	max_shields = starting_max_shields
	refill()


func refill():
	health = max_health
	missiles = max_missiles
	shields = max_shields


func stash_stats():
	WorldStash.stash("player", "max_health", max_health)
	WorldStash.stash("player", "max_missiles", max_missiles)
	WorldStash.stash("player", "max_shields", max_shields)


func retrieve_stats():
	max_health = WorldStash.retrieve("player", "max_health")
	max_missiles = WorldStash.retrieve("player", "max_missiles")
	max_shields = WorldStash.retrieve("player", "max_shields")
	refill()
