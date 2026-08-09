class_name UI
extends Control


signal object_selected(object: GameObject)


const category_tab := preload("res://src/ui/category.tscn")
const object_selector := preload("res://src/ui/object_selector.tscn")

@export var world: World
@export var category_group: ButtonGroup
@export var object_group: ButtonGroup

@export var notification_duration: float
@export var notification_pad_time: float

@onready var categories := %Categories as Control
@onready var objects := %Objects as Control
@onready var object_list := %ObjectList as Control
@onready var screen := %Screen as Control
@onready var notifications := %Notifications as Control
@onready var notification_padding := %NotificationPadding as Control

var notification_tween: Tween
var callbacks: Array[Callable] = []
var stack := []
var cancelling = null


func _ready() -> void:
	for category in world.categories:
		var tab := category_tab.instantiate() as CategoryTab
		categories.add_child(tab)
		tab.category = category
		tab.setup()
	
	set_category(null)
	
	category_group.pressed.connect(set_category)
	object_group.pressed.connect(set_object)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"Cancel"): cancel()


func center() -> Vector2: return screen.global_position + screen.size / 2


func set_category(button: Button = null) -> void:
	pop(Category)
	
	if button and category_group.get_pressed_button():
		var category := button.owner as CategoryTab
		objects.visible = true
		for object in object_list.get_children(): object.queue_free()
		for object in category.objects:
			var tab := object_selector.instantiate() as ObjectSelector
			object_list.add_child(tab)
			tab.object = object
			tab.setup()
		push(Category, set_category)
	else:
		unpress(category_group)
		objects.visible = false


func set_object(button: Button = null) -> void:
	pop(GameObject)
	
	if button and object_group.get_pressed_button():
		var object := button.owner as ObjectSelector
		object_selected.emit(object.object)
		push(GameObject, set_object)
	else:
		unpress(object_group)
		object_selected.emit(null)


func unpress(group: ButtonGroup) -> void:
	var button := group.get_pressed_button()
	if button: button.button_pressed = false


func notify(text: String, duration := -1.0) -> void:
	if duration == -1.0: duration = notification_duration
	
	var n := preload("res://src/ui/notification.tscn").instantiate() as Label
	n.text = text
	notifications.add_child(n)
	await get_tree().create_timer(duration).timeout
	pad_notification(n.size.y)
	n.queue_free()


func pad_notification(height: float) -> void:
	if notification_tween: notification_tween.kill()
	if notifications.get_child_count() < 2:
		notification_padding.custom_minimum_size.y = 0
		return
	notification_padding.custom_minimum_size.y += height
	notification_tween = create_tween()
	notification_tween.tween_property(notification_padding, ^"custom_minimum_size:y", 0, notification_pad_time).from_current()


func push(tag, callback: Callable) -> void:
	if tag != null:
		callbacks.append(callback)
		stack.append(tag)


func pop(tag) -> void:
	if cancelling != tag and tag in stack:
		while not stack.is_empty():
			if stack.back() == tag:
				stack.pop_back()
				callbacks.pop_back()
				break
			
			cancel()


func cancel() -> void:
	if not stack.is_empty():
		cancelling = stack.pop_back()
		callbacks.pop_back().call()
		cancelling = null


func cancel_all() -> void:
	while not stack.is_empty(): cancel()
