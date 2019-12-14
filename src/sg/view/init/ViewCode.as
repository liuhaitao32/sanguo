package sg.view.init
{
	import ui.init.viewCodeUI;
	import laya.events.Event;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.utils.Tools;

	/**
	 * ...
	 * @author
	 */
	public class ViewCode extends viewCodeUI{
		public function ViewCode(){
			this.inputLabel.prompt = Tools.getMsgById("ViewCode_1");
		}

		override public function onAdded():void{
			this.okBtn.on(Event.CLICK,this,this.btnClick);
			this.okBtn.label= Tools.getMsgById("_public129");//"兑换";
			this.inputLabel.maxChars=100;
		}

		public function btnClick():void{
			if(this.inputLabel.text==""){
				return;
			}
			NetSocket.instance.send("get_reward_by_code",{"code":this.inputLabel.text},Handler.create(this,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
			}));
		}

		override public function onRemoved():void{
			this.inputLabel.text==""
		}
	}

}