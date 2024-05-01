extends Node

# each named channel will only play one concurrent sound
var channels:Dictionary


func _ready():
    channels = {}


func get_or_create_channel(channel_name:String) -> AudioStreamPlayer:
    if channel_name not in channels:
        channels[channel_name] = AudioStreamPlayer.new()
        add_child(channels[channel_name])
    return channels[channel_name]


func interrupt_channel(channel_name:String, audio_file_path:String):
    var currently_playing = get_or_create_channel(channel_name)
    if currently_playing.is_playing():
        currently_playing.stop()
    currently_playing.stream = load(audio_file_path)
    currently_playing.play()
