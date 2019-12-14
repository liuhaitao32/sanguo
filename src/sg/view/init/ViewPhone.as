package sg.view.init
{
	import ui.init.ViewPhoneUI;
	import laya.events.Event;
	import sg.manager.ModelManager;
	import sg.net.NetHttp;
	import laya.utils.Handler;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigServer;
	import sg.model.ModelPlayer;
	import sg.net.NetSocket;
	import sg.net.NetPackage;
	import sg.utils.Tools;
	import laya.ui.Box;
	import ui.bag.bagItemUI;
	import laya.ui.Label;
	import sg.model.ModelItem;
	import sg.manager.EffectManager;
	import sg.manager.LoadeManager;

	/**
	 * ...
	 * @author
	 */
	public class ViewPhone extends ViewPhoneUI{

		private var isCanCheck:Boolean;
		private var mType:Number=0;
		public function ViewPhone(){
			this.list.renderHandler=new Handler(this,listRender);
			this.btnCheck.on(Event.CLICK,this,checkClick);
			this.btn.on(Event.CLICK,this,btnClick);
			this.text0.text=Tools.getMsgById("_phone01");
			this.text1.text=Tools.getMsgById("_phone02");//"手机号：";
			this.text2.text=Tools.getMsgById("_phone03");//"验证码：";
			this.text3.text=Tools.getMsgById("_phone04");//"绑定奖励";
			this.text4.text=Tools.getMsgById("_phone05");//"已绑定";			
			this.list.scrollBar.visible=false;

		}


		override public function onAdded():void{
			LoadeManager.loadTemp(imgTemp,"ui/bg_19.png");
			mType=this.currArg?this.currArg:0;
			this.box2.visible=mType==0;
			this.box.height=mType==0?564:400;
			this.comTitle.setViewTitle(Tools.getMsgById("phone_name"));
			this.input0.text=ModelPlayer.instance.tel+"";
			this.input1.text="";
			this.input0.prompt=Tools.getMsgById("_phone10");
			this.input1.prompt=Tools.getMsgById("_phone11");
			this.input0.maxChars=11;
			this.input1.maxChars=10;
			this.input0.restrict=this.input1.restrict="0-9";
			setData();
			if(this.box0.visible && mType==1){
				this.btn.visible = false;
			}
			
		}

		public function setData():void{
			var arr:Array=ModelManager.instance.modelProp.getRewardProp(ConfigServer.system_simple.phone_reward);
			this.list.repeatX=arr.length;
			this.list.centerX=0;
			this.list.array=arr;
			this.box0.visible=ModelPlayer.instance.tel!="";
			this.box1.visible=!this.box0.visible;
			this.input0.mouseEnabled=this.box1.visible;
			setBtn();
			setCheckLabel();
		}

		public function checkClick():void{
			if(!isCanCheck){
				return;
			}
			if(this.input0.text==""){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_phone_tips01"));//"请输入手机号");
				return;
			}
			var sendData:Object={"uid":ModelManager.instance.modelUser.mUID,
									"sessionid":ModelManager.instance.modelUser.mSessionid,
									"zone":ModelManager.instance.modelUser.zone,
									"tel":input0.text};
			NetHttp.instance.send("user_zone.send_sign",sendData,Handler.create(this,function(re:Object):void{
				if(NetHttp.checkReIsError(re)){
					ViewManager.instance.showTipsTxt(re.msg);
					return;
				}
				ModelManager.instance.modelUser.userPhoneCount=ConfigServer.getServerTimer()+30000;
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_phone_tips02"));//"发送验证码");
				setData();
			}));
		}

		public function setCheckLabel():void{
			var n:Number=ModelManager.instance.modelUser.userPhoneCount;
			var now:Number=ConfigServer.getServerTimer();
			isCanCheck=false;
			if(n==0 || now>n){
				this.btnCheck.label=Tools.getMsgById("_phone06");
				this.btnCheck.gray=false;
				isCanCheck=true;
				return;
			}else{
				this.btnCheck.gray=true;
				this.btnCheck.label="("+Math.floor((n-now)/1000)+"s)";
			}
			timer.once(1000,this,setCheckLabel);
		}

		public function setBtn():void{
			if(ModelPlayer.instance.tel==""){
				this.btn.label=Tools.getMsgById("_phone07");//"绑定账号";
				this.btn.gray=false;
			}else{
				if(ModelManager.instance.modelUser.tel!=null){
					this.btn.label=Tools.getMsgById("_phone08");//"已领奖";
					this.btn.gray=true;
				}else{
					this.btn.label=Tools.getMsgById("_phone09");//"领奖";
					this.btn.gray=false;
				}
			}
		}

		public function btnClick():void{
			if(ModelPlayer.instance.tel==""){
				if(this.input1.text==""){
					ViewManager.instance.showTipsTxt(Tools.getMsgById("_phone_tips05"));//("请输入验证码");
					return;
				}
				var sendData:Object={"uid":ModelManager.instance.modelUser.mUID,
									"sessionid":ModelManager.instance.modelUser.mSessionid,
									"zone":ModelManager.instance.modelUser.zone,
									"sign":input1.text};
				NetHttp.instance.send("user_zone.tel_bind",sendData,Handler.create(this,function(re:Object):void{
					if(NetHttp.checkReIsError(re)){
						ViewManager.instance.showTipsTxt(re.msg);
						return;
					}
					ModelManager.instance.modelUser.userPhoneCount=0;
					ModelPlayer.instance.tel=input0.text;
					ViewManager.instance.showTipsTxt(Tools.getMsgById("_phone_tips03"));//("绑定成功");
					if(mType==1){
						closeSelf();
					}else{
						setData();
					}
					
				}));
			}else{
				if(!Tools.isNullString(ModelManager.instance.modelUser.tel)){
					ViewManager.instance.showTipsTxt(Tools.getMsgById("_phone_tips04"));//("已领取");
				}else{
					NetSocket.instance.send("get_telbind_reward",{},new Handler(this,function(np:NetPackage):void{
						ModelManager.instance.modelUser.updateData(np.receiveData);
						ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
						setData();
					}));
				}
			}
			
		}

		public function listRender(cell:Box,index:int):void{
			var arr:Array=this.list.array[index];
			var icon:bagItemUI=cell.getChildByName("icon") as bagItemUI;
			var label:Label=cell.getChildByName("rewardName") as Label;
			icon.setData(arr[0],arr[1],-1);
			label.text=ModelItem.getItemName(arr[0]);
		}

		override public function onRemoved():void{
			
		}
	}

}