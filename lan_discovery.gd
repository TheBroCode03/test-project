extends Node

var udp := PacketPeerUDP.new()
var listen_port := 9998
var broadcast_port := 9998

var found_lobbies = []

signal lobby_found(lobby)

func _ready():
	start_listener()

# CLIENT: listen for hosts
func start_listener():
	udp.bind(listen_port)
	udp.set_broadcast_enabled(true)
	set_process(true)

func _process(_delta):
	if udp.get_available_packet_count() > 0:
		var packet = udp.get_packet()
		var msg = packet.get_string_from_utf8()
		
		var data = JSON.parse_string(msg)
		if data:
			# avoid duplicates
			for l in found_lobbies:
				if l.ip == data.ip:
					return
			
			found_lobbies.append(data)
			lobby_found.emit(data)
