extends Node

class_name YandexAds, "res://yandex-ads/icon.png"

# signals
signal banner_loaded
signal banner_failed_to_load(error_code)

signal interstitial_failed_to_load(error_code)
signal interstitial_loaded
signal interstitial_closed

signal rewarded_video_loaded
signal rewarded_video_closed
signal rewarded(currency, ammount)
signal rewarded_video_failed_to_load(error_code)
signal rewarded_video_left_application


# properties
export var banner_on_top:bool = false
export(String, "BANNER_240x400", "BANNER_300x250", "BANNER_300x300", 
"BANNER_320x100", "BANNER_400x240", "BANNER_728x90", "BANNER_320x50") var banner_size = "BANNER_320x50"
export var api_key:String
export var banner_id:String #"R-M-DEMO-320x50";
export var interstitial_id:String #"R-M-DEMO-interstitial"
export var rewarded_id:String #"R-M-DEMO-rewarded-client-side-rtb"

# "private" properties
var _admob_singleton = null
var _is_interstitial_loaded:bool = false
var _is_rewarded_video_loaded:bool = false


func _enter_tree():
	if not init():
		print("Yandex AdMob Java Singleton not found. This plugin will only work on Android")


# initialization
func init() -> bool:
	if(Engine.has_singleton("GodotAndroidYandexAds")):
		_admob_singleton = Engine.get_singleton("GodotAndroidYandexAds")
		
		# check if one signal is already connected
		if not _admob_singleton.is_connected("_on_banner_loaded", self, "_on_banner_loaded"):
			connect_signals()
		_admob_singleton.init(api_key) #

		return true
	return false

# connect the AdMob Java signals
func connect_signals() -> void:
	_admob_singleton.connect("_on_banner_loaded", self, "_on_banner_loaded")
	_admob_singleton.connect("_on_banner_failed_to_load", self, "_on_banner_failed_to_load")
	
	_admob_singleton.connect("_on_interstitial_loaded", self, "_on_interstitial_loaded")
	_admob_singleton.connect("_on_interstitial_failed_to_load", self, "_on_interstitial_failed_to_load")
	_admob_singleton.connect("_on_returned_to_application_after_interstitial", self, "_on_returned_to_application_after_interstitial")
	_admob_singleton.connect("_on_interstitial_ad_dismissed", self, "_on_interstitial_ad_dismissed")
	
	_admob_singleton.connect("_on_rewarded_video_ad_failed_to_load", self, "_on_rewarded_video_ad_failed_to_load")
	_admob_singleton.connect("_on_rewarded_video_ad_loaded", self, "_on_rewarded_video_ad_loaded")
	_admob_singleton.connect("_on_rewarded", self, "_on_rewarded")
	_admob_singleton.connect("_on_returned_to_application_after_rewarded_video", self, "_on_rewarded_video_ad_closed")
	_admob_singleton.connect("_on_rewarded_video_ad_dismissed", self, "_on_rewarded_video_ad_closed")
	_admob_singleton.connect("_on_rewarded_video_ad_left_application", self, "_on_rewarded_video_ad_left_application")

# load
func load_banner() -> void:
	if _admob_singleton != null:
		_admob_singleton.loadBanner(banner_id, banner_on_top, banner_size)

func load_interstitial() -> void:
	if _admob_singleton != null:
		_admob_singleton.loadInterstitial(interstitial_id)

func is_interstitial_loaded() -> bool:
	if _admob_singleton != null:
		return _is_interstitial_loaded
	return false

func load_rewarded_video() -> void:
	if _admob_singleton != null:
		_admob_singleton.loadRewardedVideo(rewarded_id)
		
func is_rewarded_video_loaded() -> bool:
	if _admob_singleton != null:
		return _is_rewarded_video_loaded
	return false

# show / hide
func show_banner() -> void:
	if _admob_singleton != null:
		_admob_singleton.showBanner()
		
func hide_banner() -> void:
	if _admob_singleton != null:
		_admob_singleton.hideBanner()

func show_interstitial() -> void:
	if _admob_singleton != null:
		_admob_singleton.showInterstitial()
		_is_interstitial_loaded = false
		
func show_rewarded_video() -> void:
	if _admob_singleton != null:
		_admob_singleton.showRewardedVideo()
		_is_rewarded_video_loaded = false


# dimension
func get_banner_dimension() -> Vector2:
	if _admob_singleton != null:
		return Vector2(_admob_singleton.getBannerWidth(), _admob_singleton.getBannerHeight())
	return Vector2()

# callbacks
# banner
func _on_banner_loaded() -> void:
	emit_signal("banner_loaded")

func _on_banner_failed_to_load(error_code:int) -> void:
	emit_signal("banner_failed_to_load", error_code)

#interstitial
func _on_interstitial_failed_to_load(error_code:int) -> void:
	_is_interstitial_loaded = false
	emit_signal("interstitial_failed_to_load", error_code)

func _on_interstitial_loaded() -> void:
	_is_interstitial_loaded = true
	emit_signal("interstitial_loaded")

func _on_returned_to_application_after_interstitial() -> void:
	emit_signal("interstitial_closed")

func _on_interstitial_ad_dismissed() -> void:
	emit_signal("interstitial_closed")

#rewarded
func _on_rewarded_video_ad_loaded() -> void:
	_is_rewarded_video_loaded = true
	emit_signal("rewarded_video_loaded")

func _on_rewarded(currency:String, amount:int) -> void:
	emit_signal("rewarded", currency, amount)

func _on_rewarded_video_ad_failed_to_load(error_code:int) -> void:
	_is_rewarded_video_loaded = false
	emit_signal("rewarded_video_failed_to_load", error_code)

func _on_rewarded_video_ad_closed() -> void:
	emit_signal("rewarded_video_closed")

func _on_rewarded_video_ad_left_application() -> void:
	emit_signal("rewarded_video_left_application")
