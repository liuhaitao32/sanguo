package sg.view.mail
{
	import ui.mail.addChatUI;
	import laya.events.Event;
	import sg.manager.ViewManager;
	import sg.utils.SaveLocal;
	import sg.manager.ModelManager;
	import sg.model.ModelUser;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.cfg.ConfigServer;
	import sg.utils.Tools;

	/**
	 * ...
	 * @author
	 */
	public class ViewAddChat extends addChatUI{
		

		private var mType:int = 0;//0 从邮件进  1 从聊天进
		public function ViewAddChat(){
			this.btn0.on(Event.CLICK,this,this.btnClick);
			this.btn1.on(Event.CLICK,this,function():void{
				ViewManager.instance.closePanel(this);
			});
			this.inputLabel.text = "";
			this.inputLabel.maxChars = 20;
			this.inputLabel.prompt = Tools.getMsgById("_guild_text101");//"请输入对方名字";

			this.comTitle.setViewTitle(Tools.getMsgById("_mail_text03"));
			this.text0.text=Tools.getMsgById("_public205");
			this.btn0.label=Tools.getMsgById("_public183");//确定
			this.btn1.label=Tools.getMsgById("_shogun_text03");//取消
		}

		override public function onAdded():void{
			mType = this.currArg ? this.currArg : 0; 
		}


		public function btnClick():void{
			if(this.inputLabel.text!=""){
				//SaveLocal.save("1",{"data":[1]});
				if(this.inputLabel.text==ModelManager.instance.modelUser.uname){
					ViewManager.instance.showTipsTxt(Tools.getMsgById("_guild_text102"));//"不能搜索自己");
					this.closeSelf();
					return;
				}
				NetSocket.instance.send("find_user",{"uname":this.inputLabel.text},Handler.create(this,function(np:NetPackage):void{
					var reData:* = np.receiveData;
					if(np.receiveData is Boolean && !np.receiveData){
						ViewManager.instance.showTipsTxt(Tools.getMsgById("_guild_text100"));//没有这个人
					}else{
						var _this:* = this;
						NetSocket.instance.send("get_msg",{},Handler.create(this,function(re:NetPackage):void{
							ModelManager.instance.modelUser.updateData(re.receiveData);
							ModelManager.instance.modelUser.setChatData(ModelManager.instance.modelUser.msg.usr);	
							ModelManager.instance.modelChat.findUerCallBack({"receiveData":{"uid":reData.uid,
																				"uname":reData.uname,
																				"country":reData.country,
																				"head":reData.head,
																				"lv":reData.lv}},mType);
							ModelManager.instance.modelUser.event(ModelUser.EVENT_UPDATE_MAIL_CHAT,re.receiveData.uid);
							ViewManager.instance.closePanel(_this);
						}));

						
						/*
						var o:Object=SaveLocal.getValue(SaveLocal.KEY_CHAT+ModelManager.instance.modelUser.mUID,true);
						var u:Object=np.receiveData;
						var s:String="";
						if(Tools.isNullString(o) || !o.hasOwnProperty(u.uid)){
							var user:ModelUser=ModelManager.instance.modelUser;
							var a:Array=[];
							var b:Array=[u,s,ConfigServer.getServerTimer(),true];
							a.push(b);
							ModelManager.instance.modelUser.setChatData(a);
						}else{
							s=np.receiveData.uid;
							ViewManager.instance.showTipsTxt(Tools.getMsgById("_guild_text103"));//已在聊天列表中
						}
						*/
						
					}
				}));
			}else{
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_guild_text101"));
			}
		}

		override public function onRemoved():void{
			this.inputLabel.text="";
		}

	}

}