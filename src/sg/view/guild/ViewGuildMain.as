package sg.view.guild
{
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import laya.events.Event;
	import ui.guild.guildMainUI;
	import sg.view.ViewScenes;
	import sg.model.ModelUser;
	import sg.manager.ModelManager;
	import sg.net.NetPackage;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import laya.ui.Tab;
	import laya.ui.Button;
	import sg.model.ModelGame;
	import laya.ui.Box;
	import sg.model.ModelCityBuild;
	import sg.utils.Tools;
	import sg.model.ModelGuild;
	import sg.model.ModelAlert;

	/**
	 * ...
	 * @author
	 */
	public class ViewGuildMain extends guildMainUI{

		public var isHaveGuild:Boolean=false;
		public var itemView:ViewScenes=null;
		public var tab_arr:Array=[];
		public var userModel:ModelUser=null;
		public var curStr:String="";
		public var lastIndex:int=0;
		public var gotoIndex:int=-1;
		public var str_arr:Array=[Tools.getMsgById("_guild_text02"),Tools.getMsgById("_guild_text03"),Tools.getMsgById("_guild_text04"),
									Tools.getMsgById("_guild_text05"),Tools.getMsgById("_guild_text06"),Tools.getMsgById("_guild_text07")];
		public function ViewGuildMain(){
			this.comTab.on(Event.CHANGE,this,this.tabChange);
			this.on(ModelUser.EVENT_GUILD_CREAT_SUC,this,this.eventCallBack,[1]);
			this.on(ModelUser.EVENT_GUILD_QUIT_SUC,this,this.eventCallBack,[0]);
			this.on(ModelUser.EVENT_GUILD_APPLY_SUC,this,this.eventCallBack,[1]);
			this.on("changeTab",this,function(arg:*):void{
				comTab.selectedIndex=arg;
			});
			ModelManager.instance.modelGuild.on(ModelGuild.EVENT_UPDATE_RED,this,this.eventCallBack2);
		}
		override public function set currArg(value:*):void 
		{
			super.currArg = value;
		}

		public function eventCallBack(type:int):void{
			if(type==1){
				comTab.selectedIndex=-1;
				curStr="";
			}
			setData();
		}

		public function eventCallBack2():void{
			setTabRed();
			ModelManager.instance.modelUser.event(ModelUser.EVENT_USER_UPDATE,[{"guild":""},true]);//通知红点刷新
		}

		override public function onAdded():void{
			ModelManager.instance.modelGuild.isShowRedPoint=false;
			this.setTitle(Tools.getMsgById("_guild_text01"));
			gotoIndex=this.currArg?this.currArg:0;
			setData();
		}

		public function setData():void{
			comTab.labels=str_arr[0]+","+str_arr[1]+","+str_arr[2]+","+str_arr[3]+","+str_arr[4]+","+str_arr[5];
			userModel=ModelManager.instance.modelUser;
			if(userModel.guild_id!=null&&userModel.guild_id!=""){
				isHaveGuild=true;
				tab_arr=[];
				var o0:Object={"visible":true,"gray":false,"text":""};
				var o1:Object=ModelGame.unlock(comTab.items[1] as Button,"guild_achi");
				var o2:Object={"visible":true,"gray":false,"text":""};
				var o3:Object=ModelGame.unlock(comTab.items[3] as Button,"guild_res");
				var o4:Object=ModelGame.unlock(null,"guild_shop");
				var o5:Object=ModelGame.unlock(null,"guild_alien");
				tab_arr=[o0,o1,o2,o3,o4,o5];
				var str:String="";
				var nnn:int=0;
				for(var i:int=0;i<tab_arr.length;i++){
					tab_arr[i]["key"]=ModelGuild.tab_key[i];
					//trace(d[i].visible,d[i].gray);
					(comTab.items[i] as Button).gray=tab_arr[i].gray;

					if(tab_arr[i].visible){
						str+=str_arr[i]+",";
						tab_arr[i]["id"]=nnn;
						nnn+=1;
					}else{
						tab_arr[i]["id"]=-1;
					}
				}
				str=str.substr(0,str.length-1);
				//trace(str);
				comTab.labels=str;
				setTabRed();
			}else{
				isHaveGuild=false;
			}
			//trace(tab_arr);
			//this.btnClick.on(Event.CLICK,this,this.creatClick);
			this.comTab.visible=true;
			if(!isHaveGuild){
				this.comTab.visible=false;
				NetSocket.instance.send("get_guild_list",{},Handler.create(this,socketCallBack2));
			}else{
				comTab.selectedIndex=gotoIndex;
			}
		}

		public function setTabRed():void{
			for(var i:int=0;i<tab_arr.length;i++){
				var b:Boolean=ModelAlert.red_guild_check(tab_arr[i].key);
				//trace(b);
				ModelGame.redCheckOnce(comTab.getChildAt(tab_arr[i].id),b);
			}
		}

		public function tabChange():void{
			//trace("     "+comTab.selectedIndex);
			if(comTab.selectedIndex==-1)
				return;
			
			if(tab_arr[comTab.selectedIndex].gray){
				ViewManager.instance.showTipsTxt(tab_arr[comTab.selectedIndex].text);
				comTab.selectedIndex=lastIndex;
				return;
			}
			if(comTab.selectedIndex+""==curStr){
				return;
			}
			
			for(var i:int=0;i<tab_arr.length;i++){
				if(tab_arr[i].id==comTab.selectedIndex){
					gotoIndex=i;
					break;
				}
			}
			lastIndex=comTab.selectedIndex;
			if(gotoIndex==4){
				var sendData:Object={};
				sendData["shop_id"]="guild_shop";
				NetSocket.instance.send("get_shop",sendData,Handler.create(this,socketCallBack));		
			}else if(gotoIndex==5){
				NetSocket.instance.send("get_guild_alien",{},Handler.create(this,this.socketCallBack));
			}else{
				NetSocket.instance.send("get_my_guild",{},Handler.create(this,this.socketCallBack));
			}
			curStr=comTab.selectedIndex+"";
			
		}

		public function socketCallBack(np:NetPackage):void{
			if(itemView!=null){
				this.removeChild(itemView);
			}
			/*
			switch(gotoIndex)
			{
				case 0:
					itemView=new ViewGuildInfo();
					break;
				case 1:
					itemView=new ViewGuildAchieve();
					break;
				case 2:
					itemView=new ViewGuildMember();
					break;
				case 3:
					itemView=new ViewGuildResource();
					break;
				case 4:
					ModelManager.instance.modelUser.updateData(np.receiveData);
					itemView=new ViewGuildShop();
					break;
				case 5:
					ModelManager.instance.modelUser.updateData(np.receiveData);
					itemView=new ViewGuildAlien();
					break;
				default:
					break;
			}
			*/     
			if(np){
				itemView.currArg=np.receiveData;
				ModelManager.instance.modelGuild.setData(np.receiveData);
			}
			itemView.init();
			if(gotoIndex==5){
				if(itemView.currArg.guild.alien_log){
					itemView.currArg.guild.alien_log={};
				}	
			}		
			this.addChild(itemView);			
			itemView.mouseThrough=true;
			this.setChildIndex(itemView,this.getChildIndex(this.comTab));
			itemView.bottom=itemView.left=itemView.right=0;	
			itemView.top=this.comTab.height;			
			//trace("-------",itemView.y,itemView.height);
			setPanel();
			ModelManager.instance.modelGuild.event(ModelGuild.EVENT_UPDATE_RED);
		}

		public function socketCallBack2(np:NetPackage):void{
			if(itemView!=null){
				this.removeChild(itemView);
			}
			//itemView=new ViewGuildIndex();
			itemView.init();
			itemView.currArg=np.receiveData;
			this.addChild(itemView);
			this.setChildIndex(itemView,this.getChildIndex(itemView)-1);
			this.itemView.top=this.itemView.bottom=this.itemView.left=this.itemView.right=0;
			setPanel();
		}

		public function setPanel():void{
			if(itemView.getChildByName("box")){
				var box:Box=(itemView.getChildByName("box") as Box);
				box.height=itemView.height>884?1162:itemView.height+140+138;
				// trace("======",itemView.y,itemView.height,box.y,box.height);
			}
		}
		
		override public function onRemoved():void{
			if(!itemView){
				this.removeChild(itemView);
			}
			comTab.selectedIndex=-1;
			curStr="";
		}
	}

}