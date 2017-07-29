package screens;

import kha.Assets;
import sdg.graphics.shapes.Polygon;
import sdg.Screen;
import sdg.Object;

class PlayScreen extends Screen
{
	public function new()
	{
		super();
	}
	public override function init()
	{
		super.init();
		var char = new Object(16,200,Polygon.createRectangle(16,32,kha.Color.Green,true,.2));
		add(char);

		var bull = new Object(200,200,Polygon.createRectangle(64,32,kha.Color.Red,true,.2));
		add(bull);
	}

	public override function update()
	{
		super.update();
	}
}