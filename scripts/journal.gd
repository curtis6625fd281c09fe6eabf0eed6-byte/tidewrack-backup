extends Node
## GameState owns discovery state; this service owns entry definitions.
signal entry_added(id: String)
const ENTRIES := {
	"edith_log": {"title": "Edith's last log", "text": "Three nights of fog. A light off the north rocks answered Edith's signal: three flashes, then dark. Eleven days ago she rowed out to meet it. Her dinghy has not returned."},
	"lamp_notes": {"title": "Tending the light", "text": "The service plate gives the keeper's order: trim the wick, align the lens, then light the burner. There is no hurry. Check each part before bringing the flame to it."},
	"answer": {"title": "An answering light", "text": "The lamp is burning again. Beyond the north rocks, three flashes answer through the fog. Edith's rhythm. The water is no longer empty."}
}

func discover(id: String) -> void:
	if not ENTRIES.has(id) or has(id):
		return
	GameState.journal_entries.append(id)
	GameState.state_changed.emit()
	entry_added.emit(id)

func entries() -> Array[String]:
	return GameState.journal_entries.duplicate()

func has(id: String) -> bool:
	return id in GameState.journal_entries
