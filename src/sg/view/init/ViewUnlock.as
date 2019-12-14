package sg.view.init
{
	import ui.init.unlockUI;
	import sg.manager.AssetsManager;
	import sg.manager.ModelManager;
	import sg.net.NetSocket;
	import laya.events.Event;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.model.ModelUser;
	import sg.manager.ViewManager;
	import sg.utils.Tools;

	/**
	 * ...
	 * @author
	 */
	public class ViewUnlock extends unlockUI{
		public var mData:Array=[];//["index","h_index","info","num"]
		public function ViewUnlock(){
			this.btn.on(Event.CLICK,this,this.btnClick);
		}

		override public function onAdded():void{
			this.comTitle.setViewTitle(Tools.getMsgById("_public203"));
			this.text0.text=Tools.getMsgById("_public208");
			mData=this.currArg;
			this.tInfo.text=mData[2];
			var n:Number=ModelManager.instance.modelUser.coin>=mData[3]?0:1;
			this.pay.setData(AssetsManager.getAssetItemOrPayByID("coin"),mData[3],n);
		}

		public function btnClick():void{
			if(!Tools.isCanBuy("coin",mData[3])){
				return;
			}
			NetSocket.instance.send("shogun_unblock",{"shogun_index":mData[0],"h_index":mData[1]},Handler.create(this,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				//ModelManager.instance.modelUser.event(ModelUser.EVENT_UPDATE_SHOGUN_HERO);
				ViewManager.instance.closePanel(this);
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_shogun_tips04"));
			}));
		}

		override public function onRemoved():void{

		}
	}

}