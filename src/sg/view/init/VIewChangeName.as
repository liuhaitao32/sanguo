package sg.view.init
{
	import ui.init.changeNameUI;
	import sg.utils.Tools;
	import sg.net.NetMethodCfg;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import laya.events.Event;
	import sg.model.ModelItem;
	import sg.cfg.ConfigServer;
	import sg.model.ModelUser;
	import sg.model.ModelGame;

	/**
	 * ...
	 * @author
	 */
	public class VIewChangeName extends changeNameUI{
		private var timerRe:Number = 0;
		private var propNum:Number = 0;
		private var mIsRandom:Boolean = false;
		public function VIewChangeName(){
			this.bImg.on(Event.CLICK,this,this.click_re);
			this.btn.on(Event.CLICK,this,this.click_ok);
			this.tName.on(Event.FOCUS,this,this.focus);
			this.tName.on(Event.BLUR,this,this.blur);

			this.tName.on(Event.INPUT,this,this.changeTxt);
			this.tName.on(Event.INPUT, this, this.focus);
			this.btn.label = Tools.getMsgById("_public183");
		}

		override public function onAdded():void{
			mIsRandom = false;
			if(ModelGame.unlock(null,"random_uname").stop){
				this.bImg.visible = false;
			}
			setData();
		}

		public function setData():void{
            this.tName.prompt = Tools.getMsgById("_public128");//"请输入2~5个中文";
			var s:String=ConfigServer.system_simple.rename_item;
			var item:ModelItem=ModelManager.instance.modelProp.getItemProp(s);
			this.comProp.setData(item.id);
			this.comProp.setName("x"+item.num);
			propNum=item.num;
		}

		private function changeTxt():void{
            mIsRandom = false;
        } 

		public function focus():void{
			// var s:String = FilterManager.instance.wordBan(this.tName.text);
            // s = FilterManager.instance.nameBan(s);
            // this.tName.text = s;
		}

		public function blur():void{
			//this.tName.prompt="请输入2~8个中文";
		}

		private function click_re():void{
            //随机
            this.timerRe = Tools.runAtTimer(this.timerRe,1000,Handler.create(this,this.getName));
        }

        private function getName():void{
            NetSocket.instance.send(NetMethodCfg.WS_SR_GET_RANDOM_UNAME,{},Handler.create(this,this.ws_sr_get_random_uname));
        }

        private function ws_sr_get_random_uname(re:NetPackage):void{
            var str:String = re.receiveData;
            str = str.replace(/\s/g,"");
            this.tName.text = str;
			mIsRandom = true;
        }

		private function click_ok():void{
            var str:String = this.tName.text;
			if(mIsRandom){
				NetSocket.instance.send(NetMethodCfg.WS_SR_CHANGE_UNAME,{uname:str},Handler.create(this,this.ws_sr_change_uname));
				return;
			}

			if(propNum==0){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("200091")+Tools.getMsgById("_public95"));//改名卡数量不足
			} else {
				var _this:VIewChangeName = this;
				Tools.checkNameInput(str, Handler.create(this, function(input:String):void {
					NetSocket.instance.send(NetMethodCfg.WS_SR_CHANGE_UNAME,{uname: input}, Handler.create(_this, _this.ws_sr_change_uname));
				}));
			}
		}

		private function ws_sr_change_uname(np:NetPackage):void{
			// trace("改名字",np.receiveData);
            ModelManager.instance.modelUser.updateData(np.receiveData);
			ViewManager.instance.closePanel(this);
			ViewManager.instance.showTipsTxt(Tools.getMsgById("_public193"));
			ModelManager.instance.modelUser.event(ModelUser.EVENT_USER_INFO_UPDATE);
			//
			Platform.uploadUserData(3);
		}

		override public function onRemoved():void{

		}
	}

}