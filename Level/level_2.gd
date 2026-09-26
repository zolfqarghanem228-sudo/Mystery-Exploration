extends Node3D

func _ready():
	$CanvasLayer/Arabic1.hide()
	
	$PuzzleMusic.volume_db = -15
	$PuzzleMusic.play()

	# إعادة تشغيل الموسيقى كلما خلصت
	$PuzzleMusic.finished.connect(_on_puzzle_music_finished)

	await get_tree().create_timer(2).timeout

	$CanvasLayer/Arabic1.show()
	
	$Audio1.play()
	await $Audio1.finished

	await get_tree().create_timer(1).timeout

	$Audio2.play()
	await $Audio2.finished

	await get_tree().create_timer(1).timeout

	$Audio3.play()
	await $Audio3.finished

	$CanvasLayer/Arabic1.hide()


func _on_puzzle_music_finished():
	$PuzzleMusic.play()


func _on_area_3d_body_entered(body: Node3D) -> void:
	pass
