package sg.view.map
{
	import laya.events.Event;
	import laya.utils.Handler;
	import sg.manager.AssetsManager;
	import sg.manager.ModelManager;
	import sg.map.model.MapModel;
	import sg.map.model.entitys.EntityCity;
	import sg.model.ModelBuiding;
	import sg.model.ModelGame;
	import sg.model.ModelTroop;
	import sg.utils.Tools;
	import sg.view.com.CitySendPanel;
	import ui.map.heroSendUI;

	/**
	* 确定部队，选择临近的目的地城市  突进或撤军
	* @author zhuda
	*/
    public class ViewCitySend extends heroSendUI{
		private var mModel:ModelTroop;
        public var mCityId:int;

        public var mOtherPa:*;
        public var mCitySendPanel:CitySendPanel;
        public function ViewCitySend():void{
            //
            this.mCitySendPanel = new CitySendPanel();
            this.boxMain.addChild(this.mCitySendPanel);
            this.mCitySendPanel.left = 6;
            this.mCitySendPanel.right = 6;
            this.mCitySendPanel.top = 50;
			this.mCitySendPanel.bottom = 160;
			//this.imgTitle.width = 250;
            //
            this.btn_send.on(Event.CLICK,this,this.click_send);
            this.btn_send.label = Tools.getMsgById("_lht25");
            this.text2.text=Tools.getMsgById("_public209");
        }
        override public function initData():void{
            this.tPowerInfo.visible=this.comPower.visible=false;
            ModelManager.instance.modelGame.on(ModelGame.EVENT_HERO_TROOP_EDIT_UI_CHANGE, this, this.event_hero_troop_edit_ui_change);
			
			this.mModel = this.currArg[0] as ModelTroop;
			this.mCityId = this.currArg[1];
			var arr:Array = this.currArg[2];
			var type:int = this.currArg[3];
            //
            this.mCitySendPanel.initData([this.mCityId,arr,this.mModel,type,new Handler(this,this.cityChange)]);
            this.setUI(true);
        }
        private function cityChange():void
        {
			//变更目的地
            this.checkUI();
        }
        private function event_hero_troop_edit_ui_change():void{
			if (this.mModel && this.mModel.deaded){
				this.closeSelf();
				return;
			}
			
            this.setUI(true);            
        }
        override public function onRemoved():void{
            ModelManager.instance.modelGame.off(ModelGame.EVENT_HERO_TROOP_EDIT_UI_CHANGE,this,this.event_hero_troop_edit_ui_change);
            this.mCitySendPanel.clear();
        }        
        private function setUI(update:Boolean = false):void{
            this.mCitySendPanel.setList(update);
            this.setPKstatusUI(false);
        }

        public function setPKstatusUI(b:Boolean):void{
            this.text0.visible = b;
            this.text1.visible = b;
        }        
        private function checkUI():void{
            this.tStatus.text = Tools.getMsgById("msg_ViewCitySend_0")+this.mCitySendPanel.mSelectArr.length;
            //
            var pay:Object = this.getTroopPay();
            var b:Boolean = pay.l>0;
            //
            this.btn_send.disabled = !b;
            //
			var ec:EntityCity = MapModel.instance.citys[this.mCityId];
            //this.tCity.text = ec.name + " - " + this.mModel.getName() + Tools.getMsgById("_view_timer04");
            this.cTitle.setViewTitle(ec.name + " - " + this.mModel.getName() + Tools.getMsgById("_view_timer04"));
            //
            this.tPayFood.setData(ModelBuiding.getMaterialTypeUI("food"),pay.food);
            this.tPayTime.setData(AssetsManager.getAssetsUI("img_icon_02.png"),Tools.getTimeStyle(pay.time*Tools.oneMillis));
        }
        private function getTroopPay():Object{
            var len:int = this.mCitySendPanel.mSelectArr.length;
            var food:Number = 0;
            var time:Number = 0;
			var l:int = this.mCitySendPanel.mSelectArr.length;
			if (l > 0){
				var obj:Object = this.mCitySendPanel.mSelectArr[0];
				time = obj.time;
				food = obj.food;
			}
            return {l:l, time:time,food:food};
        }
        private function click_send():void{
            var len:int = this.mCitySendPanel.mSelectArr.length;
            var arr:Array = [];
            for(var i:int = 0; i < len; i++)
            {
               arr.push(this.mCitySendPanel.mSelectArr[i]);
            }
            if(arr.length == 1){
                this.click_send_func(arr[0]);
            }
            this.closeSelf();
        }
        public function click_send_func(data:*):void{
			var city_list:Array = [this.mCityId, data.ct.cid];
			if (data.type == 1){
				//突进
				ModelManager.instance.modelTroopManager.sendBreakTroops(this.mModel.hero, city_list);
			}
			else{
				//撤军
				ModelManager.instance.modelTroopManager.sendRunAwayTroops(this.mModel.hero, city_list);
			}
            //ModelManager.instance.modelTroopManager.sendMoveTroops(arr);
        }
    }   
}