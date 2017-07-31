package;

import kha.Framebuffer;
import kha.Scheduler;
import kha.System;
import kha.Assets;
import sdg.Engine;
import sdg.manager.GamePadMan;
import sdg.Sdg;
import sdg.manager.Manager.*;
import sdg.collision.Hitbox;

class Project {
	public function new() {
		Assets.loadEverything(assetsLoaded);
	}

	function assetsLoaded()
	{
		var engine = new Engine(320, 188);
		engine.enable(KEYBOARD | MOUSE | GAMEPAD | DELTA);

		Hitbox.init();
		Sdg.addScreen('Play', new PlayScreen(), true);

		System.notifyOnRender(engine.render);
		Scheduler.addTimeTask(engine.update, 0, 1 / 60);
		
	}
}
