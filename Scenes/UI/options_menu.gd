extends CanvasLayer

signal back_pressed

@onready var master_slider = %MasterSlider
@onready var master_value_label = %MasterValueLabel
@onready var music_slider = %MusicSlider
@onready var music_value_label = %MusicValueLabel
@onready var sfx_slider = %SfxSlider
@onready var sfx_value_label = %SfxValueLabel
@onready var window_button = %WindowButton
@onready var back_button = %BackButton
@onready var reset_save_button = %ResetSaveButton


func _ready():
	master_slider.value_changed.connect(on_audio_slider_changed.bind("Master"))
	music_slider.value_changed.connect(on_audio_slider_changed.bind("Music"))
	sfx_slider.value_changed.connect(on_audio_slider_changed.bind("SFX"))
	window_button.pressed.connect(on_window_button_pressed)
	back_button.pressed.connect(on_back_button_pressed)
	reset_save_button.pressed.connect(on_reset_save_button_pressed)
	
	update_display()
	


func update_display():
	window_button.text = "Windowed"
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		window_button.text = "Fullscreen"
	
	# get the volumes from the audio server
	var master_vol = get_bus_volume_percent("Master")
	var music_vol = get_bus_volume_percent("Music")
	var sfx_vol = get_bus_volume_percent("SFX")
		
	# set the sliders to correct position
	master_slider.value = master_vol
	music_slider.value = music_vol
	sfx_slider.value = sfx_vol
	
	# set the labels to the correct volume
	master_value_label.text = str(int(master_vol * 100))
	music_value_label.text = str(int(music_vol * 100))
	sfx_value_label.text = str(int(sfx_vol * 100))


func get_bus_volume_percent(bus_name: String):
	var bus_index = AudioServer.get_bus_index(bus_name)
	var volume_db = AudioServer.get_bus_volume_db(bus_index)
	return db_to_linear(volume_db)


func set_bus_volume_percent(bus_name: String, percent: float):
	var bus_index = AudioServer.get_bus_index(bus_name)
	var volume_db = linear_to_db(percent)
	AudioServer.set_bus_volume_db(bus_index, volume_db)


func on_window_button_pressed():
	var mode = DisplayServer.window_get_mode()
	if mode != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	update_display()


func on_audio_slider_changed(value: float, bus_name: String):
	print_debug("audio slider changed")
	set_bus_volume_percent(bus_name, value)
	update_display()


func on_back_button_pressed():
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	
	back_pressed.emit()


func on_reset_save_button_pressed():
	MetaProgression.clear()
