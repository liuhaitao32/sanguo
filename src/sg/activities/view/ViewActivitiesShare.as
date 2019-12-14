package sg.activities.view
{
	import laya.events.Event;
	import laya.utils.Handler;

	import sg.activities.model.ModelWXShare;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.net.NetPackage;
	import sg.net.NetSocket;
	import sg.utils.Tools;

	import ui.activities.activitiesShareUI;
	import sg.cfg.ConfigApp;
	import sg.cfg.ConfigServer;
	import sg.net.NetHttp;
	import sg.manager.LoadeManager;
	import sg.manager.AssetsManager;

	/**
	 * ...
	 * @author
	 */
	public class ViewActivitiesShare extends activitiesShareUI{

		private var model:ModelWXShare;
		private var mCanShare:Boolean;
		public function ViewActivitiesShare(){
			this.btn.on(Event.CLICK,this,this.click);
			this.btn_close.on(Event.CLICK,this,function():void{
				closeSelf();
			});
		}


		public override function onAdded():void{
			imgBG.skin=AssetsManager.getAssetsAD("actPay1_7.png");
			Platform.eventListener.on(Platform.EVENT_SHARE_OK,this,eventCallBack);
			model=ModelWXShare.instance;
			this.btn.label=Tools.getMsgById("_share_text01");//"去分享";
			//
			Platform.shareFunCheck();
			//
			setData();
		}


		public function setData():void{
			var n:Number=model.times();
			numLabel.text=(model.cfg.length - n)+"/"+model.cfg.length;
			//this.btn.gray=(model.cfg.length == n || model.getTime()>0);
			mCanShare=!(model.cfg.length == n || model.getTime()>0);
			var m:Number=model.cfg[n]?n:0;
			var arr:Array=ModelManager.instance.modelProp.getRewardProp(model.cfg[m][1]);
			this.com.setData(arr[0][0],arr[0][1],-1);
		}
		public function click():void{
			/*
			if(model.cfg.length == model.times()){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_share_text03"));//"今日次数不足");
				return;
			}
			var n:Number=model.getTime();
			if(n>0){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_share_text04",[Tools.getTimeStyle(n)]));//+"后可再次分享");
				return;
			}*/

			/*
			if(ConfigApp.pf=="wx"){
				Platform.share();	
			}else{
				 var sendData:Object={"uid":ModelManager.instance.modelUser.mUID,
									"sessionid":ModelManager.instance.modelUser.mSessionid,
									"zone":ModelManager.instance.modelUser.zone,
									"pf":ConfigApp.pf};
                    NetHttp.instance.send("user_zone.get_weixin_share",sendData,new Handler(this,function(obj:Object):void{
						Platform.share(obj);
					}));
					
			}*/
			// var cfg:Array = ConfigServer.system_simple.share_pf[ConfigApp.pf];
			// if(Platform.share_wx_and_qq && cfg && cfg[5]>0){
			// 	//微信和qq最新分享
			// }
			// else{
				Platform.share(0);
			// }
		}
		public function eventCallBack():void{
			if(!mCanShare){
				this.closeSelf();
				return;
			}
			NetSocket.instance.send("wx_share",{},new Handler(this,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
				setData();
				model.event(ModelWXShare.EVENT_ChANGE_SHARE);
				closeSelf();
			}));
		}
		public override function onRemoved():void{
			Platform.eventListener.off(Platform.EVENT_SHARE_OK,this,eventCallBack);
		}
	}

}