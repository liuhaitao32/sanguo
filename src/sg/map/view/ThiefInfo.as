package sg.map.view {
	import sg.manager.ModelManager;
	import sg.map.utils.ArrayUtils;
	import sg.map.utils.MapUtils;
	import sg.model.ModelItem;
	import sg.scene.view.ui.NoScaleUI;
	import sg.utils.TimeHelper;
	import ui.mapScene.ThiefInfoUI;
	
	/**
	 * ...
	 * @author light
	 */
	public class ThiefInfo extends NoScaleUI {
		
		private var _ui:ThiefInfoUI = new ThiefInfoUI();
		
		public function ThiefInfo() {
			this.sceneMain = MapViewMain.instance;
			this.addChild(this._ui);
		}
		
		public function setData(obj:Object):void {
			var itemProp:ModelItem = ModelManager.instance.modelProp.getItemProp(obj.icon);			
			//this._ui.icon.setData(itemProp.icon, itemProp.ratity, "", "");			
			this._ui.icon.setData(obj.icon,-1,-1);			
			TimeHelper.countDown(this._ui.name_txt, obj.time);
			//this.resize();
			//ArrayUtils.push(this, MapViewMain.instance.bubbles);
		}
		
		override public function destroy(destroyChild:Boolean = true):void {
			super.destroy(destroyChild);
			TimeHelper.removeCountDown(this._ui.name_txt);
		}
		
	}

}