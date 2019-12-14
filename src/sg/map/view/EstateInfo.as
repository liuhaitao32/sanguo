package sg.map.view {
	import sg.cfg.ConfigServer;
	import sg.map.model.entitys.EntityHeroCatch;
	import sg.map.utils.TestUtils;
	import sg.scene.SceneMain;
	import sg.scene.view.ui.NoScaleUI;
	import sg.utils.TimeHelper;
	import sg.utils.Tools;
	import ui.mapScene.EstateInfoUI;
	import ui.mapScene.HeroCatchInfoUI;
	
	/**
	 * ...
	 * @author light
	 */
	public class EstateInfo extends NoScaleUI {
		
		private var _ui:EstateInfoUI = new EstateInfoUI();
		
		public function EstateInfo(scene:SceneMain) {
			super();
			this.minLost = true;
			this.initScene(scene);
			this.addChild(this._ui);
		}
		
		
		public function setData(estateData:Object):void {
			this._ui.name_txt.text = estateData.name;
			this._ui.level_txt.text = estateData.level;
			
			if (estateData.occupy) {
				this._ui.name_txt.color = "#ffc600";
				this._ui.level_txt.color = "#ffc600";
				this._ui.occupy_img.visible = true;
			} else {				
				this._ui.name_txt.color = "#cccccc";
				this._ui.level_txt.color = "#FFFFFF";
				this._ui.occupy_img.visible = false;
			}
			
			
			MapViewMain.instance.mapLayer.infoLayer.addChild(this);
		}
		
		override public function destroy(destroyChild:Boolean = true):void {
			super.destroy(destroyChild);
		}
	}

}