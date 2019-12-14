package sg.map.view {
	import sg.cfg.ConfigServer;
	import sg.map.model.entitys.EntityFtask;
	import sg.map.utils.TestUtils;
	import sg.scene.SceneMain;
	import sg.scene.view.ui.NoScaleUI;
	import sg.utils.TimeHelper;
	import sg.utils.Tools;
	import ui.mapScene.FtaskInfoUI;
	
	/**
	 * ...
	 * @author light
	 */
	public class FtaskInfo extends NoScaleUI {
		
		private var _ui:FtaskInfoUI = new FtaskInfoUI();
		
		public function FtaskInfo(scene:SceneMain) {
			super();
			this.minLost = true;
			this.initScene(scene);
			this.addChild(this._ui);
		}
		
		
		public function setData(data:Object):void {
			MapViewMain.instance.mapLayer.infoLayer.addChild(this);
			this._ui.name_txt.text = data.label;
			this._ui.name_txt.color = data.color;
			var w:Number = this._ui.name_txt.textField.textWidth + 40;
			this._ui.bg_img.x = -w / 2;
			this._ui.bg_img.width = w;
		}
		
		override public function destroy(destroyChild:Boolean = true):void {
			super.destroy(destroyChild);
		}
	}

}