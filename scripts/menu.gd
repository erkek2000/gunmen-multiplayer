extends Control
@export var Adress = "127.0.0.1"
@export var Port = 8910
var Peer

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
	print("Player Connected: ", id)

# Gets called on server and clients
func peer_disconnected(id):
	print("Player Disconnected: ", id)
	
# Called only from clients
func connected_to_server():
	print("Connected to Server!")
	sendPlayerInfo.rpc_id(1, $VBoxContainer/LineEdit.text, multiplayer.get_unique_id())

# Called only from clients
func connection_failed():
	print("Connection Failed!")

@rpc("any_peer")
func sendPlayerInfo(name, id):
	print("Received player info: ", name, " with ID: ", id)
	if !GameManager.Players.has(id):
		GameManager.Players[id] = {
			"name" : name,
			"id": id,
			"score" : 0
		}
		print("Added player to dictionary. Total players: ", GameManager.Players.size())
	
	if multiplayer.is_server():
		print("Server broadcasting all player info...")
		for i in GameManager.Players:
			sendPlayerInfo.rpc(GameManager.Players[i].name, i)
			
@rpc("any_peer","call_local")
func startGame():	
	var scene = load("res://scenes/Test_Scene.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()

func _on_host_button_pressed():
	Peer = ENetMultiplayerPeer.new()
	# Max clients = 2
	var error = Peer.create_server(Port, 2)
	if error != OK:
		print ("Error hosting the Server: ", error)
		return
	
	# Compress methods use CPU versus Bandwidth.
	# Compress method needs to be the SAME across the board.
	Peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(Peer)
	print("Waiting for players...")
	
	# Add the host player to the dictionary
	var host_name = $VBoxContainer/LineEdit.text
	if host_name == "":
		host_name = "Host"
	sendPlayerInfo(host_name, multiplayer.get_unique_id())

func _on_join_button_pressed():
	Peer = ENetMultiplayerPeer.new()
	Peer.create_client(Adress, Port)
	Peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(Peer)

func _on_start_button_pressed():
	startGame.rpc()
	pass # Replace with function body.
