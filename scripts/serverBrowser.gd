extends Control

signal server_found
signal server_removed

var broadcastTimer : Timer
var broadcaster : PacketPeerUDP
var listener : PacketPeerUDP
@export var listenPort : int = 8911
@export var broadcastPort: int = 8912
@export var broadcastAddress: String = "192.168.1.255"

var roomInfo = {"name" : "name", "playerCount" : 0}

# Called when the node enters the scene tree for the first time.
func _ready():
	broadcastTimer = $BroadcastTimer
	setUp()
	
func setUp():
	listener = PacketPeerUDP.new()
	var ok = listener.bind(listenPort)
	
	if ok == OK:
		%ListenPortLabel.text = "Bound to Listen Port."
		print("Bound to listen port: ", listenPort)
	else:
		%ListenPortLabel.text = "IS NOT bound to Listen Port."
		print("Failed to bind to listen port.")

func setUpBroadcast(name):
	roomInfo.name = name
	roomInfo.playerCount = GameManager.Players.size()
	
	broadcaster = PacketPeerUDP.new()
	broadcaster.set_broadcast_enabled(true)
	# Setting dest address may not be necessary since broadcast is enabled.
	# 255 = every adress
	broadcaster.set_dest_address(broadcastAddress, listenPort)
	
	var ok = broadcaster.bind(broadcastPort)
	
	if ok == OK:
		print("Bound to broadcast port: ", broadcastPort)
	else:
		print("Failed to bind to broadcast port.")
	
	$BroadcastTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if listener.get_available_packet_count() > 0:
		var serverip = listener.get_packet_ip()
		var serverport = listener.get_packet_port()
		var bytes = listener.get_packet()
		var data = bytes.get_string_from_utf16()
		var roomInfo = JSON.parse_string(data)
		
		print("Server IP: ", serverip,
		" Server Port: ", serverport, " Room Info: ", roomInfo)


func _on_broadcast_timer_timeout():
	print("Broadcasting game.")
	roomInfo.playerCount = GameManager.Players.size()
	var data = JSON.stringify(roomInfo)
	# Use data to UTF16 or UTF32 for glyphs like japanese.
	# Note that this compatability will increase packet size.
	var packet = data.to_utf16_buffer()
	broadcaster.put_packet(packet)
	
func cleanUp():
	listener.close()
	
	$BroadcastTimer.stop()
	if broadcaster != null:
		broadcaster.close()
	

func _exit_tree():
	cleanUp()
