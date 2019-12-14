package sg.view.inside
{
	import ui.inside.armyUpgradeAlertUI;
	import laya.events.Event;
	import sg.manager.ViewManager;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.manager.ModelManager;
	import sg.model.ModelUser;
	import sg.manager.AssetsManager;
	import sg.cfg.ConfigServer;
	import sg.utils.Tools;
	import sg.utils.StringUtil;

	/**
	 * ...
	 * @author
	 */
	public class ViewArmyUpgradeAlert extends armyUpgradeAlertUI{
		private var mdata:Array=[];
		private var mtype:int=0;//是否成功
		private var userData:Array=[];
		private var mCoin:Number=0;
		public function ViewArmyUpgradeAlert(){
			this.text1.text=Tools.getMsgById("msg_ViewArmyUpgradeAlert_0");
			this.btn0.label=Tools.getMsgById("_ftask_text05");
			this.btn1.label=Tools.getMsgById("ViewArmyUpgradeAlert_1");
			this.btn0.on(Event.CLICK,this,this.btnClick,[0]);
			this.btn1.on(Event.CLICK,this,this.btnClick,[1]);
		}

		override public function onAdded():void{
			this.isAutoClose=false;
			mdata=this.currArg;//[b_id,type(0:强化1次，1:强化10次,2:突破),np.receiveData]
			userData=mdata[2];//ModelManager.instance.modelUser.home[mdata[0]].science;
			this.img0.skin= AssetsManager.getAssetLater((mdata[1]==2)?"img_name19.png":"img_name04.png");
			setData();
		}

		public function setData():void{
			var d:Array=ConfigServer.army.army_add_cost[mdata[1]];//[object,100,10,10,190]
			if(mdata[1]==0 || mdata[1]==1){
				var n1:String=100*(d[2]/d[1])+"%";
				var n2:String=d[3]+"";
				var n3:String=(d[2]+d[4])/d[1]*100+"%";
				this.text0.text=Tools.getMsgById("_building16",[n1,n2,n3]);//"研究失败，只获得"+n1+"经验，花费"+n2+"黄金进行补救，可获得"+n3+"经验！";
				//this.com0.setData(AssetsManager.getAssetItemOrPayByID("coin"),d[3]);
				mCoin=d[3];
			}else{
				mCoin=Math.round(d[2]*(1-userData.user.home[mdata[0]].science[5])*100);
				//var nnn:Number=Math.round(d[2]*(1-userData.user.home[mdata[0]].science[5])*100);
				this.text0.text=Tools.getMsgById("_building17",[mCoin,StringUtil.numberToPercent(d[1])]);//"突破失败增加"+nnn+"突破成功率\n花费"+d[1]*100+"%黄金进行补救，可直接突破成功!";
				//this.com0.setData(AssetsManager.getAssetItemOrPayByID("coin"),nnn);
				
			}
			this.com0.setData(AssetsManager.getAssetItemOrPayByID("coin"),mCoin);

		}

		public function btnClick(index:int):void{
			if(index==0){
				mtype=0;
				ModelManager.instance.modelUser.event(ModelUser.EVENT_UPDATE_ARMY_UPGRADE,[mdata[1],mtype,userData]);
				ViewManager.instance.closePanel(this);
			}else{
				mtype=1;
				var s:String=mdata[1]==0 || mdata[1]==1?"army_science_rate_safeup":"army_science_lv_safeup";
				if(!Tools.isCanBuy("coin",mCoin)){
					return;
				}
				NetSocket.instance.send(s,{"b_id":mdata[0]},Handler.create(this,socekt_call_back));
			}
		}

		public function socekt_call_back(np:NetPackage):void{
			//ModelManager.instance.modelUser.updateData(np.receiveData);
			ViewManager.instance.closePanel(this);
			ModelManager.instance.modelUser.event(ModelUser.EVENT_UPDATE_ARMY_UPGRADE,[mdata[1],mtype,np.receiveData]);
		}



		override public function onRemoved():void{
			
		}
	}

}