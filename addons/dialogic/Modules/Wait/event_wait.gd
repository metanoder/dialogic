@tool
class_name DialogicWaitEvent
extends DialogicEvent
#var wait_interrupted: bool = false
#var timer:Timer

## Event that waits for some time before continuing.


### Settings

## The time in seconds that the event will stop before continuing.
var time: float = 1.0
## If true the text box will be hidden while the event waits.
var hide_text: bool = true

func _wait_interrupter(timer):
	#printerr("wait interrupter triggered.  wait intrrupted now true")
	#wait_interrupted = true
	printerr("_wait_interrupter timer== ", timer)
	_finish_wait(timer)

################################################################################
## 						EXECUTE
################################################################################

func _execute() -> void:
	var final_wait_time := time

	if dialogic.Inputs.auto_skip.enabled:
		var time_per_event: float = dialogic.Inputs.auto_skip.time_per_event
		final_wait_time = min(time, time_per_event)

	if hide_text and dialogic.has_subsystem("Text"):
		dialogic.Text.update_dialog_text('')
		dialogic.Text.hide_textbox()
	dialogic.current_state = dialogic.States.WAITING
	#print("timer b4== ", timer)
	var timer = Timer.new()
	timer.autostart = true
	timer.one_shot = true
	timer.wait_time = final_wait_time
	var game_node = GM.get_node("Game")
	game_node.add_child(timer)
	var connect = GM.connect("skip_movie", _finish_wait.bind(timer))
	print("timer is: ", timer)
	#print("is connected: ", GM.is_connected("skip_movie", _wait_interrupter))
	#timer.connect("timeout", _finish_wait)
	await timer.timeout
	#timer = await dialogic.get_tree().create_timer(time, true, DialogicUtil.is_physics_timer()).timeout
	#print("timer after == ", timer)
	if GM.is_connected("skip_movie", _finish_wait):
		print("GM is connected...")
		print("timer== ", timer)
		
	else: 
		print("not connected")
		
	_finish_wait(timer)
	#if wait_interrupted == false:
		#_finish_wait()
	#else:
		#wait_interrupted = false
	
func _finish_wait(timer):
	printerr("_finish_wait timer== ", timer)
	if is_instance_valid(timer):
		timer.queue_free()
		printerr("timer is queue_freed")
	#wait_interrupted = true
	dialogic.current_state = dialogic.States.IDLE
	finish()


################################################################################
## 						INITIALIZE
################################################################################

func _init() -> void:
	event_name = "Wait"
	set_default_color('Color5')
	event_category = "Flow"
	event_sorting_index = 11


################################################################################
## 						SAVING/LOADING
################################################################################

func get_shortcode() -> String:
	return "wait"


func get_shortcode_parameters() -> Dictionary:
	return {
		#param_name : property_info
		"time" 		:  {"property": "time", 		"default": 1},
		"hide_text" :  {"property": "hide_text", 	"default": true},
	}


################################################################################
## 						EDITOR REPRESENTATION
################################################################################

func build_event_editor():
	add_header_edit('time', ValueType.NUMBER, {'left_text':'Wait', 'autofocus':true, 'min':0})
	add_header_label('seconds', 'time != 1')
	add_header_label('second', 'time == 1')
	add_body_edit('hide_text', ValueType.BOOL, {'left_text':'Hide text box:'})
