package sg.view.guild
{
	import sg.manager.AssetsManager;
	import laya.events.Event;
	import sg.manager.ViewManager;
	import sg.net.NetSocket;
	import sg.net.NetPackage;
	import ui.guild.creatGuildUI;
	import sg.cfg.ConfigServer;
	import sg.utils.Tools;
	import laya.utils.Handler;
	import sg.manager.ModelManager;
	import sg.utils.ObjectSingle;
	import sg.cfg.ConfigClass;
	import sg.model.ModelUser;
	import sg.model.ModelGuild;
	import sg.manager.FilterManager;

	/**
	 * ...
	 * @author
	 */
	public class ViewCreatGuild extends creatGuildUI{


		public var configData:Object=ConfigServer.guild;
		public var str:String="";
		public function ViewCreatGuild(){
			
		}

		override public function onAdded():void{
			this.text0.text=Tools.getMsgById("_guild_text104");
			var d:String=this.currArg;
			if(d=="creat"){
				this.titleLabel.text=Tools.getMsgById("_guild_text60");//"创建军团";
				this.btnClick.setData(AssetsManager.getAssetItemOrPayByID("coin"),configData.configure.consumegold);	
			}else if(d=="change"){
				this.titleLabel.text=Tools.getMsgById("_guild_text61");//"修改军团名称";
				this.btnClick.setData(AssetsManager.getAssetItemOrPayByID("coin"),configData.configure.name_cost);
			}
			//this.titleLabel.text="输入军团名称";this.titleLabel.text="输入军团名称";//纯中文或纯字母  1）英文a-z是65-90,A-Z是97-122   2）数字是0-9是，48-57

			this.putText.prompt=Tools.getMsgById("_guild_text62");
			this.putText.restrict="\u4e00-\u9fa5,a-zA-Z";//19968
			this.btnClick.on(Event.CLICK,this,this.clickbtn);
		}

		public function clickbtn():void{
			if(!Tools.isCanBuy("coin",configData.configure.consumegold)){
				return;
			}
			str= this.putText.text;
			var fn:Number=str.charCodeAt(0);
			var charType:int=0;
			for (var i:int = 1; i < str.length; i++)
			{
				if(fn<=122){
					if(str.charCodeAt(i)>122){
						ViewManager.instance.showTipsTxt(Tools.getMsgById("_guild_tips01"));
						charType=1;
						break;
					}
				}else{
					if(str.charCodeAt(i)<=122){
						ViewManager.instance.showTipsTxt(Tools.getMsgById("_guild_tips01"));
						charType=1;
						break;
					}
				}
			}
			if(charType==0){
				if(fn<112){
					if(str.length>10||str.length<5){
						ViewManager.instance.showTipsTxt(Tools.getMsgById("_guild_tips02"));
						return;
					}
				}else{
					if(str.length>5||str.length<2){
						ViewManager.instance.showTipsTxt(Tools.getMsgById("_guild_tips03"));
						return;
					}
				}
			}
			if(!FilterManager.instance.isLegalWord(str)){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("193005"));
				return;
			}
			var o:Object={};
			o["guild_name"]=str;
			
			var s:String=this.currArg=="creat"?"create_guild":"change_guild_name";
			NetSocket.instance.send(s,o,Handler.create(this,this.socektCallBack));
			
		}

		public function socektCallBack(np:NetPackage):void{
			if(this.currArg=="creat"){
				ModelManager.instance.modelGuild.setData(np.receiveData.guild);
				ModelManager.instance.modelUser.updateData(np.receiveData);
				ObjectSingle.getObjectByArr(ConfigClass.VIEW_GUILD_MAIN).event(ModelUser.EVENT_GUILD_CREAT_SUC);
				
			}else{
				ModelManager.instance.modelGuild.name=str;
				ModelManager.instance.modelGuild.event(ModelGuild.EVENT_GUILD_NAME);
				//ModelManager.instance.modelGuild.updateData(np.receiveData.guild);
			}
			this.closeSelf();
			
			
		}

		override public function onRemoved():void{
			this.putText.text="";
		}

	}
}