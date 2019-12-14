package sg.home.view.ui.build {
	import laya.display.Animation;
	import laya.events.Event;
	import sg.home.model.entitys.EntityBuild;
	import sg.home.view.HomeViewMain;
	import sg.home.view.entity.BuildClip;
	import sg.manager.AssetsManager;
	import sg.manager.EffectManager;
	import sg.scene.interfaces.IResizeUI;
	import sg.scene.view.entity.EntityClip;
	import sg.utils.Tools;
	import sg.view.com.ComPayType;
	import ui.home.BuidingInfoUI;
	import sg.manager.AssetsManager;
	
	/**
	 * ...
	 * @author light
	 */
	public class BuildingInfo extends BuidingInfoUI implements IResizeUI {
		
		private var entity:EntityBuild;
		
		private var time:Number = 0;
		
		private var total:Number = 0;
		
		private var buildingAni:Animation;
		
		
		
		public function BuildingInfo() {
			
		}
		
		
		
		public function setData(data:*, entityClip:BuildClip):void {
			this.resize();
			if (data == null){
				this.visible = false;
				this.clearTimer(this, this.changeTime);
				if (this.buildingAni) {
					this.buildingAni.removeSelf();
					this.buildingAni.clear();
					this.buildingAni = null;	
				}
				
			}else {
				this.visible = true;
				
				//up:{total:总时间毫秒, cd:剩余时间毫秒, content:文字提升, icon:素材地址, ui:图标类ComPayType(需要 new 出来 addchild 上 使用 setBuildingTipsIcon("icon地址") building:0)}
				this.time = data.cd;
				this.total = data.total;
				this.changeTime();
				this.info_txt.text = data.content;
				var icon:ComPayType = new data.ui();
				icon.setBuildingTipsIcon(data.icon);
				this.icon_img.addChild(icon);				
				this.timerLoop(1000, this, this.changeTime);
				
				
				if (this.buildingAni == null) {
					var res:String = data.building == 0 ? entityClip.entityBuild.getParamConfig("build_show") : "building_work";
					if (res) {
						var this2:BuildingInfo = this;
						this.buildingAni = new Animation();
						EffectManager.loadAnimationAndCall(res, this, function():void {
							if (!buildingAni) return;
							buildingAni.loadAnimation(AssetsManager.getUrlAnimation(res));							
							if (data.building == 0){
								if (data.total - data.cd < 2000) {
									buildingAni.play();
									buildingAni.once(Event.COMPLETE, this2, function(e):void {
										buildingAni.gotoAndStop(buildingAni.count - 1);
									});
								} else{
									buildingAni.gotoAndStop(buildingAni.count - 1);
								}
							} else {
								buildingAni.play(0, true);
							}
						}, null, this.buildingAni);
						
						entityClip.addChild(this.buildingAni);
					}
				}
				
			}
		}
		
		public function changeTime():void {			
			this.pro_txt.text = Tools.getTimeStyle(this.time);			
			this.pro.value = 1 - this.time / this.total;
			this.time = Math.max(0, this.time - 1000);
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