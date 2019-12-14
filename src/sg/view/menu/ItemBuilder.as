package sg.view.menu
{
	import sg.guide.view.GuideFocus;
	import sg.home.model.HomeModel;
	import sg.home.model.entitys.EntityBuild;
	import sg.home.view.HomeViewMain;
	import sg.map.view.MapViewMain;
	import ui.menu.builderUI;
	import sg.model.ModelBuiding;
	import sg.manager.ModelManager;
	import sg.model.ModelInside;
	import sg.utils.Tools;
	import laya.events.Event;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import sg.model.ModelOffice;
	import laya.display.Animation;
	import sg.manager.EffectManager;
	import sg.scene.view.MapCamera;
	import sg.cfg.ConfigServer;

	/**
	 * 主界面 正在升级的 建筑
	 * @author
	 */
	public class ItemBuilder extends builderUI{
		public var mModel:ModelBuiding;
		// private var reModel:ModelBuiding;
		private var builderData:Object
		public var isBuilding:Boolean = false;
		private var isAdded:Boolean = false;
		private var isLock:Boolean = false;
		private var aniFree:Animation;
		public function ItemBuilder(){
			
			ModelManager.instance.modelInside.on(ModelInside.BUILDING_UPDATE_CD,this,this.on_building_set);
			ModelManager.instance.modelInside.on(ModelInside.BUILDING_UPDATE_END,this,this.on_building_set);
			ModelManager.instance.modelInside.on(ModelInside.BUILDING_BUILDER_REMOVE,this,this.on_building_set);
			//
			this.mModel = null;
		}
		public function initData(md:*):void{
			var index:Number = Number(this.name.charAt(this.name.length-1));
			this.isAdded = (index == 1);
			this.isLock = (ModelOffice.func_buildworkerNum()<=0);
			
			this.off(Event.CLICK,this,this.click);
			this.on(Event.CLICK,this,this.click);
			this.mModel = md as ModelBuiding;
			this.change();

			this.gray = (this.isAdded && this.isLock);
		}
		private function click():void{
			if(this.mModel){
				MapCamera.lookAtBuild(this.mModel.id, 500, true);
				if(this.mModel.isUpgradeIng() && !this.mModel.isFreeCanUse()){
                    GuideFocus.focusOut();
					ViewManager.instance.showView(ConfigClass.VIEW_BUILDING_QUICKLY,this.mModel);
				}
			}
			else{

				if(this.isAdded && this.isLock){
					//MapCamera.lookAtBuild(ModelManager.instance.modelInside.getBase().id, 500);
					EntityBuild(HomeModel.instance.builds[ModelManager.instance.modelInside.getBase().id]).view.onClick();
					GuideFocus.focusInMenu(EntityBuild(HomeModel.instance.builds[ModelManager.instance.modelInside.getBase().id]).view, "15", true, 500);
					ViewManager.instance.showTipsTxt(Tools.getMsgById("_office2",[ModelOffice.func_buildworkerInfo()]));//"需要"+ModelOffice.func_buildworkerInfo()+"特权");
				}
				else{
					
					var upBMD:ModelBuiding = ModelBuiding.checkUpgradeBuild();
					if(upBMD){
						MapCamera.lookAtBuild(upBMD.id, 500, true);
					}else{
						ViewManager.instance.showTipsTxt(Tools.getMsgById("_country88"));
					}
				}
			}
		}
		public function change():void{
			this.txt.text = "";//Laya.timer.currTimer+"";//new Date().getTime()+"";
			this.bgTimer.visible = false;
			this.bgTxt.visible = true;
			this.txt.visible = true;
			if(this.mModel){
			// 	Trace.log("ItemBuilder change",this.mModel.id);
				if(this.mModel.isUpgradeIng()){
					this.txt.text = Tools.getTimeStyle(this.mModel.getLastCDtimer());

					// this.tname.text = this.mModel.getName();
					this.bgTimer.visible = true;
					this.bgTxt.visible = false;
				}
			}
			else{
				if(this.isAdded && this.isLock){
					this.txt.text = Tools.getMsgById("_public123");//"未解锁";
					// this.tname.text = "";
				}
				else{
					this.txt.text = Tools.getMsgById("_science3");//"闲置状态";
					// this.tname.text = "";
					this.bgTxt.visible = false;
					this.txt.visible = false;
				}
			}
			this.checkIsFree();
		}
		public function checkIsFree():void
		{
			if(this.aniFree){
				this.aniFree.destroy(true);
				this.aniFree = null;
			}
			if(!this.txt.visible){
				
				this.aniFree = EffectManager.loadAnimation("glow018");
				this.aniFree.x = this.width*0.5;
				this.aniFree.y = this.height*0.5;
				this.addChild(this.aniFree);
			}
		}
		private function on_building_set(md:ModelBuiding):void{
			if(this.mModel){
				if(md.isUpgradeIng()){
					if(md.isFreeCanUse() && ConfigServer.getServerTimer()>md.freeCDtipsTimer){
						md.freeCDtipsTimer = ConfigServer.getServerTimer()+md.getLastCDtimer();
						md.updateStatus();
					}
					if(md.id == this.mModel.id){
						this.mModel = md;
					}
				}
				else{
					if(md.id == this.mModel.id){
						this.mModel = null;
					}
				}
			}
			this.change();
		}
	}

}