package sg.home.view.ui.build 
{
	import laya.maths.Rectangle;
	import laya.utils.Tween;
	import sg.home.model.entitys.EntityBuild;
	import sg.home.view.entity.BuildClip;
	import sg.model.ModelBuiding;
	import sg.scene.interfaces.IResizeUI;
	import sg.scene.view.ui.Bubble;
	import ui.home.BuildArmyInfoUI;
	/**
	 * ...
	 * @author ...
	 */
	public class BuildArmyInfo extends BuildArmyInfoUI implements IResizeUI
	{
		public var entity:EntityBuild;
		
		public var yanjiu:Bubble;
		
		public function BuildArmyInfo(clip:BuildClip) 
		{
			this.yanjiu = new Bubble(clip);
		}
		
		public function setData(data:*):void {
			if (this.entity.model.isArmy() && this.entity.model.lv > 0) {
				this.resize();
				this.visible = true;
				this.num_txt.text = this.entity.model.getArmyNum() + "/" + this.entity.model.getArmyNumMax();
				//this.kucun_container.visible = true;
				if (data.up == null){
					this.kucun_container.y = 11;
				}
				else{
					this.kucun_container.y = 27;
				}
				this.addChild(this.yanjiu);
				this.yanjiu.scale(0.6, 0.6);
				Tween.clearAll(this.yanjiu);
				this.yanjiu.x = 35 + 45
				this.yanjiu.y = -86 + 45;
				this.yanjiu.visible = data[ModelBuiding.CHECK_STATUS_BUBBLET];
				if (this.yanjiu.visible) {
					this.yanjiu.setData(data[ModelBuiding.CHECK_STATUS_BUBBLET]);	
					var rect:Rectangle = this.yanjiu.hitArea;
					rect.y += 45;
					this.yanjiu.hitArea = rect;
				}
			} 
		}
		
		override public function clear():void {
			super.clear();
			this.destroy();
		}
		
		
		public function resize():void {
			//var sc:Number = 1 / HomeViewMain.instance.tMap.scale;
			//this.scale(sc, sc);
		}
	}

}