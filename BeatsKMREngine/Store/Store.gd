extends  Node

const BKMRUtils: Script = preload("res://BeatsKMREngine/utils/BKMRUtils.gd")
const BKMRLogger: Script = preload("res://BeatsKMREngine/utils/BKMRLogger.gd")

signal get_cards_complete
signal buy_card_complete

var GetCards: Node
var BuyCard: Node
var host: String = "https://zf78qflq-8081.asse.devtunnels.ms"
#weak ref
var wrGetCards: WeakRef = null
var wrBuyCard: WeakRef = null

#Item Arrays
var cards_for_sale: Array = []

func get_store_items(item_type: String) -> Node:
	var prepared_http_req: Dictionary = BKMREngine.prepare_http_request()
	GetCards = prepared_http_req.request
	wrGetCards = prepared_http_req.weakref
	GetCards.request_completed.connect(_onGetCards_request_completed)
	BKMRLogger.info("Calling BKMREngine to get cards on sale data")
	var request_url: String = host + "/api/store/cards/get?itemType=" + item_type
	BKMREngine.send_get_request(GetCards, request_url)
	return self
	
func _onGetCards_request_completed(_result, response_code, headers, body) -> void:
	var status_check: bool = BKMRUtils.check_http_response(response_code, headers, body)
	if is_instance_valid(GetCards):
		BKMREngine.free_request(wrGetCards, GetCards)
	if status_check:
		var json_body: Array = JSON.parse_string(body.get_string_from_utf8())
		cards_for_sale = json_body
		get_cards_complete.emit()
		
func buy_card(token_id: String, card_name: String, username: String) -> Node:
	var prepared_http_req: Dictionary = BKMREngine.prepare_http_request()
	BuyCard = prepared_http_req.request
	wrBuyCard = prepared_http_req.weakref
	BuyCard.request_completed.connect(_onBuyCard_request_completed)
	BKMRLogger.info("Calling BKMREngine to get buy a card")
	var payload: Dictionary = {"tokenId": token_id,"cardName": card_name, "username": username}
	BKMRLogger.debug("Validate session payload: " + str(payload))
	var request_url: String = host + "/api/store/cards/buy"
	BKMREngine.send_post_request(BuyCard, request_url, payload)
	return self

func _onBuyCard_request_completed(_result, response_code, headers, body) -> void:
	var status_check: bool = BKMRUtils.check_http_response(response_code, headers, body)
	if status_check:
		var json_body: Dictionary = JSON.parse_string(body.get_string_from_utf8())
		var _bkmr_result: Dictionary = BKMREngine.build_result(json_body)
		if json_body.success:
			BKMRLogger.info("Purchase was succesful.")
		else:
			BKMRLogger.error("BKMREngine request password reset failure: " + str(json_body.error))
		buy_card_complete.emit(json_body)
