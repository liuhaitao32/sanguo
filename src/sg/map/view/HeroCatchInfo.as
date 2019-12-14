package sg.map.view {
	import sg.cfg.ConfigServer;
	import sg.map.model.entitys.EntityHeroCatch;
	import sg.map.utils.TestUtils;
	import sg.scene.SceneMain;
	import sg.scene.view.ui.NoScaleUI;
	import sg.utils.TimeHelper;
	import sg.utils.Tools;
	import ui.mapScene.HeroCatchInfoUI;
	
	/**
	 * ...
	 * @author light
	 */
	public class HeroCatchInfo extends NoScaleUI {
		
		private var _ui:HeroCatchInfoUI = new HeroCatchInfoUI();
		
		public function HeroCatchInfo(scene:SceneMain) {
			super();
			this.minLost = true;
			this.initScene(scene);
			this.addChild(this._ui);
			if(this._ui.text_txt) this._ui.text_txt.text = Tools.getMsgById("_public243");
		}
		
		public function setData(entity:EntityHeroCatch):void {
			this.setName(entity.name);
			TimeHelper.countDown(this._ui.countDown_txt, entity.countDown);
			MapViewMain.instance.mapLayer.infoLayer.addChild(this);
		}
		
		public function setName(name:String):void {
			this._ui.name_txt.text = name;
		}
		
		override public function destroy(destroyChild:Boolean = true):void {
			super.destroy(destroyChild);
			TimeHelper.removeCountDown(this._ui.countDown_txt);
		}
	}

}