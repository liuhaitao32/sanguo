package sg.view.map
{
	import sg.view.inside.ViewBuildingQuickly;
	import sg.manager.ViewManager;
	import sg.model.ModelItem;
	import sg.net.NetSocket;
	import sg.net.NetPackage;
	import laya.utils.Handler;
	import sg.manager.ModelManager;
	import sg.model.ModelBuiding;
	import sg.utils.Tools;
	import sg.cfg.ConfigServer;
	import sg.model.ModelCityBuild;

	/**
	 * ...
	 * @author
	 */
	public class ViewCityBuildQuickly extends ViewBuildingQuickly{

		private var config_cb:Object={};
		private var user_cb:Object={};
		private var cb_obj:Object={};
        private var needCoin:Number=0;
		public function ViewCityBuildQuickly(){
			super();
		}

		override public function onAdded():void{
			cb_obj=this.currArg;
			user_cb=ModelManager.instance.modelUser.city_build;
			config_cb=ConfigServer.city_build;
			this.checkUI();
			Laya.timer.loop(1000,this,time_tick);
            this.checkBoxProps();
		}

		override public function checkUI():void{
			this.mTimerAll = config_cb.time*Tools.oneMillis;
            this.mTimerLast = Tools.getTimeStamp(user_cb[cb_obj.cid][cb_obj.bid][1])-ConfigServer.getServerTimer();
            //
            if(this.mTimerLast<=1000){
                this.closeSelf();
                ModelCityBuild.updateCityBuild(cb_obj.cid,cb_obj.bid);
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
                this.tStatus.text = Tools.getMsgById("_city_build_text09");//"建筑加速";
                //
                this.mProgress.initData(580,this.mTimerAll,passTimer);
                this.btn_free.visible = false;
                this.btn_cd.visible = true;
                this.btn_coin.visible = true;
                //
                this.bar_time.value = passTimer/this.mTimerAll;
                //
                this.btn_coin.setData("",ModelBuiding.getCostByCD(m,5));
                needCoin=ModelBuiding.getCostByCD(m,4);
                //
            }            
		}

		override public function click(type:int):void{
            var s:Object;
            var num:int = parseInt(this.tCdNum.text);
            if(type==1){
                s = {item_id:-1,item_num:1,cid:cb_obj.cid,bid:cb_obj.bid};
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
                    s = {item_id:this.autoID,item_num:num,cid:cb_obj.cid,bid:cb_obj.bid};
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
            NetSocket.instance.send("kill_city_build_cd",s,Handler.create(this,this.socketCallBack),s);
        }

		public function socketCallBack(np:NetPackage):void{
			ModelManager.instance.modelUser.updateData(np.receiveData);
			user_cb=ModelManager.instance.modelUser.city_build;
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