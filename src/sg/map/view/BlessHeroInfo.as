package sg.map.view {
	import sg.scene.SceneMain;
	import sg.scene.view.ui.NoScaleUI;
	import ui.mapScene.BlessHeroInfoUI;
	
	/**
	 * ...
	 * @author Thor
	 */
	public class BlessHeroInfo extends NoScaleUI {
		
		private var _ui:BlessHeroInfoUI = new BlessHeroInfoUI();
		
		public function BlessHeroInfo(scene:SceneMain) {
			super();
			this.minLost = true;
			this.initScene(scene);
			this.addChild(this._ui);
			MapViewMain.instance.mapLayer.infoLayer.addChild(this);
		}
		
		public function setName(name:String):void {
			this._ui.name_txt.text = name;
		}
		
		override public function destroy(destroyChild:Boolean = true):void {
			super.destroy(destroyChild);
		}
	}

}