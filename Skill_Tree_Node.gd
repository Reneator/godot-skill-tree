tool
extends TextureButton

export (NodePath) var previous_node
export (Texture) var texture setget set_texture
export (ShaderMaterial) var on_learned_shader
export (String) var tooltip_text
export (bool) var unlocked = false setget set_unlocked
export (bool) var learned = false

signal on_learned()
signal on_unlocked()

func _init():
	texture_normal = texture

func _ready():
	refresh_line()
	if previous_node:
		get_node(previous_node).connect("on_learned", self, "on_learned")

func set_unlocked(_unlocked):
	unlocked = _unlocked
	disabled = !unlocked
	if unlocked:
		set_active()
	else:
		set_inactive()
		
func set_active():
	modulate = Color(1,1,1,1)

func set_inactive():
	modulate = Color(0.6,0.6,0.6,1)

func set_texture(_texture):
	texture = _texture
	texture_normal = texture	

func _process(delta):
	if not Engine.is_editor_hint():
		return
	refresh_line()

func refresh_line(): #this sets the line2d to be connected with the previous_node
	if not previous_node:
		return
	var line = $Line2D
	var target_pos = get_node(previous_node).rect_global_position
	var line_point = target_pos - rect_global_position
	var points = line.points
	if points.size() > 1:
		points.remove(1)
	points.append(line_point)
	line.points = points
	
func get_tooltip_text():
	return tooltip_text

func on_learned():
	set_unlocked(true)
	emit_signal("on_unlocked")
	print("Skill_Node %s unlocked" % name)	

func _on_TextureButton_pressed():
	if learned:
		return
	learned = true
	emit_signal("on_learned")
	$LearnedColor.show()
	print("Skill_Node %s learned" % name)
