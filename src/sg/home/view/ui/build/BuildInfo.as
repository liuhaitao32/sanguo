package sg.home.view.ui.build 
{
	import laya.display.Sprite;
	import sg.home.model.entitys.EntityBuild;
	import sg.home.view.HomeViewMain;
	import sg.utils.Tools;
	import ui.home.BuildArmyInfoUI;
	import ui.home.BuildInfoUI;
	import sg.scene.interfaces.IResizeUI;
	
	/**
	 * ...
	 * @author light
	 */
	public class BuildInfo extends BuildInfoUI implements IResizeUI
	{
		public var entity:EntityBuild;
		public var armyInfo:BuildArmyInfoUI;
		
		public function BuildInfo() 
		{
			
		}
		
		public function setData(data:*):void {
			this.resize();
			if (data == null) {
				this.visible = false;
			}else {
				this.name_txt.text = data.name;
				if (data.level == 0) {
					this.level_txt.visible = false;
					this.lock_img.visible = true;
					this.up_img.visible = false;
				}else {
					this.level_txt.visible = true;
					this.lock_img.visible = false;					
					this.up_img.visible = data.up;
					this.level_txt.text = Tools.getMsgById(100001, [data.level]);	
				}
				this.visible = true;
			}
			
		}
	
		
		public function initBuild(build:EntityBuild):void {
			this.entity = build;
			
		}
		
		
		/* INTERFACE IResizeUI */
		
		public function resize():void {
			//var sc:Number = 1 / HomeViewMain.instance.tMap.scale;
			//this.scale(sc, sc);
		}
	}

}