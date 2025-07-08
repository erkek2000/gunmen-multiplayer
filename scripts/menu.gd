extends Control

@export var Adress = "127.0.0.1"
@export var Port = 8910
var peer

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Gets called on server and clients
func peer_connected(id):
	print("Player Connected: " + id)

# Gets called on server and clients
func peer_disconnected(id):
	print("Player Disconnected: " + id)
	
# Called only from clients
func connected_to_server(id):
	print("Connected to Server!")

# Called only from clients
func connection_failed(id):
	print("Connection Failed!")

func _on_host_button_pressed():
	peer = ENetMultiplayerPeer.new()
	# Max clients = 2
	var error = peer.create_server(Port, 2)
	if error != OK:
		print ("Error hosting the Server: " + error)
		return
	
	# Compress methods use CPU versus Bandwidth.
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting for players...")


func _on_join_button_pressed():
	pass # Replace with function body.


func _on_start_button_pressed():
	pass # Replace with function body.
