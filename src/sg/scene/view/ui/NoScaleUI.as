package sg.scene.view.ui {
	import laya.display.Sprite;
	import laya.renders.RenderContext;
	import sg.map.utils.ArrayUtils;
	import sg.scene.SceneMain;
	import sg.scene.interfaces.IResizeUI;
	
	/**
	 * ...
	 * @author light
	 */
	public class NoScaleUI extends Sprite implements IResizeUI {
		
		public var sceneMain:SceneMain;
		
		public var minLost:Boolean = false;
		
		public function NoScaleUI() {
			
		}
		
		public function initScene(scene:SceneMain):void {
			this.sceneMain = scene;
		}
		
		override public function render(context:RenderContext, x:Number, y:Number):void 
		{
			if (!this.scaleX) return;
			super.render(context, x, y);
		}
		
		public function resize():void {
			var sc:Number = 1 / this.sceneMain.tMap.scale;
			if (this.minLost && this.sceneMain.tMap.scale < this.sceneMain.maxScale) {
				sc = 0;
			}
			this.scale(sc, sc);
		}
		
		override public function destroy(destroyChild:Boolean = true):void {
			if (this.sceneMain) {
				ArrayUtils.remove(this, this.sceneMain.bubbles);
			}
			super.destroy(destroyChild);
		}
	}

}