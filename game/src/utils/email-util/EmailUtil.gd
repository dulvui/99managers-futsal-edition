extends Node

var messages = []

enum MESSAGE_TYPES {TRANSFER,TRANSFER_OFFER,CONTRACT_SIGNED,CONTRACT_OFFER,CONTRACT_OFFER_MADE,NEXT_MATCH}

func _ready():
	messages = DataSaver.messages


# make update method connected to new day signal of calendar
func update():
	for message in messages:
		message["days"] -= 1
		if message["days"] < 1 and message["read"]:
			messages.erase(message)
			
func count_unread_messages():
	var counter = 0
	for message in messages:
		if not message["read"]:
			counter += 1
	return counter

func message(content,type):
	print("new " + str(type) + " mail")
	
	var message = {
		"title" : "TRANSFER",
		"message" : "",
		"days" : 7,
		"type" : type,
		"read" : false
	}
	
	match type:
		MESSAGE_TYPES.TRANSFER:
			message["title"] = "TRANSFER"
			if content.has("success"):
				if content["success"]:
					message["message"] = "You bought for" + str(content["money"]) + " " + content["player"]["name"] + " " + content["player"]["surname"]
				else:
					message["message"] = "You couldnt buy for" + str(content["money"]) + " " + content["player"]["name"] + " " + content["player"]["surname"]
			else:
				message["message"] = "You made an " + str(content["money"]) + " offer for " + content["player"]["name"] + " " + content["player"]["surname"]
		# contract
		MESSAGE_TYPES.CONTRACT_OFFER:
			message["message"] = "You need to make an contract offer for " + content["player"]["name"] + " " + content["player"]["surname"]
			message["title"] = "CONTRACT OFFER"
		MESSAGE_TYPES.CONTRACT_OFFER_MADE:
			message["message"] = "You made an contract offer for " + content["player"]["name"] + " " + content["player"]["surname"]
			message["title"] = "CONTRACT OFFER MADE"
		MESSAGE_TYPES.CONTRACT_SIGNED:
			message["message"] = "The player acceptet " + content["player"]["name"] + " " + content["player"]["surname"] + " the contract"
			message["title"] = "CONTRACT_SIGNED"
		MESSAGE_TYPES.NEXT_MATCH:
			var team_name = content["home"]
			if team_name == DataSaver.selected_team:
				team_name = content["away"]
			message["message"] = "The next match is against " + team_name + ".\nThe quotes are: "
			message["title"] = "NEXT MATCH"
			
	messages.append(message)
	
	

