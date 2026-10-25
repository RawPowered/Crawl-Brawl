class_name CrawlBrawlRenderLayer
extends Node2D

var draw_callback: Callable


func configure(callback: Callable, redraw: bool = true) -> void:
	draw_callback = callback
	if redraw:
		queue_redraw()


func _draw() -> void:
	if draw_callback.is_valid():
		draw_callback.call(self)
