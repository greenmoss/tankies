extends Node

# each named channel will only play one concurrent sound
var channels:Dictionary


func _ready():
    channels = {}


func get_channel_stream(channel_name:String) -> AudioStreamPlayer2D:
    if channel_name not in channels: return null

    var channel_stream = channels[channel_name]
    if channel_stream == null: return null
    if not is_instance_valid(channel_stream): return null
    if channel_stream.is_queued_for_deletion(): return null
    return channel_stream


func interrupt_channel(channel_name:String, audio_stream:AudioStreamPlayer2D):
    if audio_stream == null: return
    if not is_instance_valid(audio_stream): return
    if audio_stream.is_queued_for_deletion(): return

    if channel_name not in channels:
        channels[channel_name] = audio_stream

    var channel_stream = get_channel_stream(channel_name)
    if channel_stream == null:
        channel_stream = audio_stream
        channels[channel_name] = audio_stream

    if channel_stream.is_playing():
        # If we're already playing this audio, continue playing it
        if channel_stream.stream == audio_stream.stream:
            return
        channel_stream.stop()

    if channel_stream.stream == audio_stream.stream:
        channel_stream.play()
    else:
        channels[channel_name] = audio_stream
        audio_stream.play()


func stop_all(channel_names:Array[String]):
    for channel_name in channel_names:
        if channel_name not in channels.keys(): continue
        var channel_stream = get_channel_stream(channel_name)
        if channel_stream == null: continue
        if not channel_stream.is_playing(): continue
        channel_stream.stop()


func tween_channel_volume(channel_name:String, final_db:int, tween_time:float):
    if channel_name not in channels.keys(): return
    var channel_stream = get_channel_stream(channel_name)
    if channel_stream == null: return
    if not channel_stream.is_playing(): return
    var channel_tween = create_tween()
    channel_tween.tween_property(channel_stream, "volume_db", final_db, tween_time)
