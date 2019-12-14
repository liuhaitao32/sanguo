package sg.view.map
{
	import sg.view.inside.ViewBuildingQuickly;
	import sg.model.ModelBuiding;
	import sg.manager.ViewManager;
	import sg.model.ModelItem;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.manager.ModelManager;
	import sg.cfg.ConfigServer;
	import sg.utils.Tools;
	import sg.model.ModelVisit;

	/**
	 * ...
	 * @author
	 */
	public class ViewVisitQuickly extends ViewBuildingQuickly{


		private var cid:String="";
        private var needCoin:Number=0;
		public function ViewVisitQuickly(){
			
		}
		override public function onAdded():void{
			cid=this.currArg;		
			this.checkUI();
			Laya.timer.loop(1000,this,time_tick);
            this.checkBoxProps();
		}

		override public function checkUI():void{
			this.mTimerAll = ConfigServer.visit.visit_time*Tools.oneMinuteMilli;
            this.mTimerLast = Tools.getTimeStamp(ModelManager.instance.modelUser.visit[cid][2])-ConfigServer.getServerTimer();
            //
            if(this.mTimerLast<=1000){
                ModelVisit.updateData(cid);
                this.closeSelf();
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
                this.tStatus.text = Tools.getMsgById("_visit_text01")+Tools.getMsgById("_building21");//"拜访加速";
                //
                this.mProgress.initData(580,this.mTimerAll,passTimer);
                this.btn_free.visible = false;
                this.btn_cd.visible = true;
                this.btn_coin.visible = true;
                //
                this.bar_time.value = passTimer/this.mTimerAll;
                //
                this.btn_coin.setData("",ModelBuiding.getCostByCD(m,6));
                needCoin=ModelBuiding.getCostByCD(m,4);
                //
            }            
		}

		override public function click(type:int):void{
            var s:Object;
            var num:int = parseInt(this.tCdNum.text);
            if(type==1){
                s ={item_id:-1,item_num:1,city_id:cid};
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
                    s ={item_id:this.autoID,item_num:num,city_id:cid};
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
            NetSocket.instance.send("kill_visit_cd",s,Handler.create(this,this.socketCallBack),s);
        }

		public function socketCallBack(np:NetPackage):void{
			ModelManager.instance.modelUser.updateData(np.receiveData);
			//user_estate=ModelManager.instance.modelUser.estate[estate_index];
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