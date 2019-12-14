package sg.view.map
{
	import sg.view.inside.ViewBuildingQuickly;
	import sg.model.ModelBuiding;
	import sg.manager.ModelManager;
	import sg.cfg.ConfigServer;
	import sg.utils.Tools;
	import sg.manager.ViewManager;
	import sg.model.ModelItem;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.model.ModelEstate;

	/**
	 * ...
	 * @author
	 */
	public class ViewEstateQuickly extends ViewBuildingQuickly{

		public var estate_index:int=0;
		private var user_estate:Object={};
		private var config_estate:Object={};
        private var needCoin:Number=0;
		public function ViewEstateQuickly(){
			super();
            this.mTypeCD = 4;
		}

		override public function onAdded():void{
			estate_index=this.currArg;
			user_estate=ModelManager.instance.modelUser.estate[estate_index];
            var estate_id:String = ConfigServer.city[user_estate.city_id].estate[user_estate.estate_index][0];
			config_estate=ConfigServer.estate.estate[estate_id];			
			this.checkUI();
			Laya.timer.loop(1000,this,time_tick);
            this.checkBoxProps();
		}

		override public function checkUI():void{
			this.mTimerAll = config_estate.active_time*Tools.oneMinuteMilli;
            this.mTimerLast = Tools.getTimeStamp(user_estate.active_harvest_time)-ConfigServer.getServerTimer();
            //
            if(this.mTimerLast<=0){
                this.closeSelf();
                ModelManager.instance.modelGame.getModelEstate(user_estate.city_id,user_estate.estate_index).event(ModelEstate.EVENT_ESTATE_UPDATE);
                return;
            }
            //
            var m:Number = (this.mTimerLast*0.001)/60;
            var passTimer:Number = this.mTimerAll - this.mTimerLast;
            //
            if(this.reUIbyCD!=m){
                this.reUIbyCD = m;
                //
                //this.tname.text = Tools.getMsgById("_building21");//"加速";
                this.comTitle.setViewTitle(Tools.getMsgById("_building21"));
                this.ttime.text = Tools.getTimeStyle(this.mTimerLast);
                //
                this.tStatus.text = Tools.getMsgById("_estate_text31");//"产业加速";
                //
                this.mProgress.initData(580,this.mTimerAll,passTimer);
                this.btn_free.visible = false;
                this.btn_cd.visible = true;
                this.btn_coin.visible = true;
                //
                this.bar_time.value = passTimer/this.mTimerAll;
                //
                this.btn_coin.setData("",ModelBuiding.getCostByCD(m,4));
                needCoin=ModelBuiding.getCostByCD(m,4);
                //
            }            
		}

		override public function click(type:int):void{
            var s:Object;
            var num:int = parseInt(this.tCdNum.text);
            if(type==1){
                s ={item_id:-1,item_num:1,estate_index:estate_index};
                if(!Tools.isCanBuy("coin",needCoin)){
                    return;
                }
            }
            else{
                if(this.autoID == ""){
                    ViewManager.instance.showTipsTxt(Tools.getMsgById("_building2"));
                    return ;
                }
                else{
                    s ={item_id:this.autoID,item_num:num,estate_index:estate_index};
                }
                var status:Array = ModelItem.checkCDitemStatus(s.item_id,num,this.mTimerLast);
                if(status[0]<0){
                    ViewManager.instance.showTipsTxt(Tools.getMsgById("_public19"));
                    return;
                }
                if(status[1]>0){
                    ViewManager.instance.showTipsTxt(Tools.getMsgById("_building3",[status[1]]));
                    return;
                }
            }
            NetSocket.instance.send("kill_estate_active_cd",s,Handler.create(this,this.socketCallBack),s);
        }

		public function socketCallBack(np:NetPackage):void{
			ModelManager.instance.modelUser.updateData(np.receiveData);
			user_estate=ModelManager.instance.modelUser.estate[estate_index];
			//
            this.checkUI();
            //
            this.checkBoxProps();
		}

		public function time_tick():void{
			this.checkUI();
		}

		override public function onRemoved():void{
			Laya.timer.clear(this,time_tick);
		}
	}

}