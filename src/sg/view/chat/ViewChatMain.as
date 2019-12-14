package sg.view.chat
{
	import ui.chat.chatMainUI;
	import sg.manager.FilterManager;
	import laya.events.Event;
	import sg.manager.ViewManager;
	import sg.boundFor.GotoManager;
	import sg.manager.ModelManager;
	import ui.chat.item_chat_userUI;
	import laya.utils.Handler;
	import sg.model.ModelChat;
	import sg.net.NetSocket;
	import sg.net.NetPackage;
	import laya.ui.List;	
	import laya.display.Node;
	import laya.ui.Component;
	import laya.maths.MathUtil;
	import sg.manager.AssetsManager;
	import sg.model.ModelOfficial;
	import sg.cfg.ConfigServer;
	import sg.utils.Tools;

	import sg.model.ModelUser;
	import sg.cfg.ConfigClass;
	import sg.model.ModelGame;
	import sg.utils.SaveLocal;

	/**
	 * ...
	 * @author
	 */
	public class ViewChatMain extends chatMainUI{

		public var lastCellY:Number=0;//最后一个格子的y坐标

		public var showLength:Number=0;
		public var cellobj:Object={};
		public var cellHeigtobj:Object={};	
		public var seletedUid:String="";	
		public var seletedIndex:Number=0;	
		private var isBottom:Boolean=false;
		private var isWorld:Boolean=false;
		private var mCostNum:Number;//聊天需要花费的元宝数

		private var itemFace:ViewFace;
		public function ViewChatMain(){

			this.btnSend.on(Event.CLICK,this,onClick,[btnSend]);
			this.btnBlack.on(Event.CLICK,this,onClick,[btnBlack]);
			this.btnBG.on(Event.CLICK,this,onClick,[btnBG]);
			
			this.btnChannel1.on(Event.CLICK,this,onClick,[btnChannel1]);
			this.btnChannel2.on(Event.CLICK,this,onClick,[btnChannel2]);
			this.btnSet0.on(Event.CLICK,this,onClick,[btnSet0]);
			this.btnSet1.on(Event.CLICK,this,onClick,[btnSet1]);
			this.btnSet2.on(Event.CLICK,this,onClick,[btnSet2]);
			this.btnSet3.on(Event.CLICK,this,onClick,[btnSet3]);
			this.btnChange.on(Event.CLICK,this,onClick,[btnChange]);
			this.btnCheck.on(Event.CLICK,this,onClick,[btnCheck]);
			this.btnSearch.on(Event.CLICK,this,onClick,[btnSearch]);

			this.btnFace.on(Event.CLICK,this,onClick,[btnFace]);

			this.list.itemRender=Item_User;
			this.list.renderHandler=new Handler(this,listRender);
			
			this.list.scrollBar.visible=false;

			this.btnChannel0.label = Tools.getMsgById("_chat_text03");
			this.btnChannel1.label = Tools.getMsgById("_chat_text04");
			this.btnChannel2.label = Tools.getMsgById("_country74");
			this.btnSearch.label = Tools.getMsgById("_country90");
			//this.list.scrollBar.changeHandler=new Handler(this,changeHandler);

			
			this.channelInfo1.text=Tools.getMsgById("_chat_text16");
			this.channelInfo2.text=Tools.getMsgById("_chat_text17");

			if(ModelManager.instance.modelChat.isOpenFace()){
				itemFace = new ViewFace();
				this.addChild(itemFace);
				itemFace.visible = false;
				itemFace.centerX = 0;
				itemFace.bottom = 160;
			}
			
		}

		public function eventCallBack1():void{
			setList();
		}
		public function eventCallBack2():void{
			setList();
			list.scrollBar.value=list.scrollBar.max;
		}
		public function eventCallBack3(str:String):void{
			this.inputLabel.focus = true;
			this.inputLabel.text = this.inputLabel.text + '' + str;
			
		}
		public function eventCallBack4():void{
			onClick(this.btnBG);
		}

		public override function onAdded():void{
			//this.list.visible=false;
			ModelGame.unlock(this.btnFace,"face");
			if(ModelManager.instance.modelChat.isOpenFace()==false) this.btnFace.visible = false;
			
			ModelGame.unlock(this.btnSearch,"chat_search");
			isWorld=ModelGame.unlock(btnChannel0,"chat_world").stop;
			this.btnBG.visible=this.boxSet.visible=false;
			ModelManager.instance.modelChat.on(ModelChat.EVENT_ADD_CHAT,this,eventCallBack1);//新消息

			ModelManager.instance.modelChat.on(ModelChat.EVENT_UPDATE_CHANNEL,this,eventCallBack2);//切换频道

			ModelManager.instance.modelChat.on(ModelChat.EVENT_ADD_FACE,this,eventCallBack3);//表情

			ModelManager.instance.modelChat.on(ModelChat.EVENT_CLOSE_FACE,this,eventCallBack4);//表情

			this.setTitle(Tools.getMsgById("_chat_text01"));
			//this.html.style.color="#ffffff";
			//this.html.style.fontSize=25;
			//this.html.innerHTML=FilterManager.instance.Exec("我要去邺城北啦   ")+FilterManager.instance.Exec("我要去邺城啦");
			//this.html.on(Event.LINK,this,click);
			this.inputLabel.maxChars=80;
			this.btnBG.visible=this.boxChannel.visible=false;
			this.list.height=this.height-160;
			this.boxChannel.visible=false;
			this.html.visible=false;
			isBottom=true;
			setList(true);
			this.list.scrollBar.changeHandler = new Handler(this,scrollBarChange);
			this.btnChange.label = ModelChat.channel_arr[ModelManager.instance.modelChat.cur_channel];
			initBoxSet();
			//setPanel();

			this.btnChannel0.off(Event.CLICK,this,onClick);
			this.imgChannel.top=0;
			this.channelInfo0.text=Tools.getMsgById("_chat_text15");

			var o:Object=SaveLocal.getValue(SaveLocal.KEY_LOCAL_CHAT_CHANNEL+ModelManager.instance.modelUser.mUID,true);
			if(o)
				ModelManager.instance.modelChat.cur_channel=o.channel;

			var n:Number=ModelManager.instance.modelChat.cur_channel;
			if(n==-1)
				n = ConfigServer.system_simple.init_channel;//默认进入的聊天频道
			if(isWorld==false){
				this.btnChannel0.on(Event.CLICK,this,onClick,[btnChannel0]);
				clickChannel(n);
			}else{
				clickChannel(1);
			}
			if(this.btnChannel0.visible==false){
				this.imgChannel.top=45;
				this.channelInfo0.text="";
			}
			setSendBtn();
		}

		public function initBoxSet():void{
			this.btnSet0.img.skin=AssetsManager.getAssetsUI("icon_duilie21.png");
			this.btnSet1.img.skin=AssetsManager.getAssetsUI("icon_duilie22.png");
			this.btnSet2.img.skin=AssetsManager.getAssetsUI("icon_duilie23.png");
			this.btnSet3.img.skin=AssetsManager.getAssetsUI("icon_duilie21.png");

			this.btnSet0.label.text=Tools.getMsgById("_chat_text06");//"信息";
			this.btnSet1.label.text=Tools.getMsgById("_chat_text08");//"私聊";
			this.btnSet2.label.text=Tools.getMsgById("_chat_text07");//"屏蔽";
			this.btnSet3.label.text=Tools.getMsgById("_chat_text09");//"禁言";

			if(ModelOfficial.getUserOfficer(ModelManager.instance.modelUser.mUID)==8){
				this.btnSet3.visible=true;
				this.boxSet.height=207;
			}else{
				this.btnSet3.visible=false;
				this.boxSet.height=156;
			}
		}
		/*

		public function setPanel():void{
			if(this.list.array.length<10){
				showLength=this.list.array.length;
			}else{
				showLength=10;
			}
			for(var i:int=this.list.array.length-showLength;i<this.list.array.length-1;i++){
				var cell:Item_User=new Item_User();
				cell.setData(this.list.array[i],i);
				//this.panel.addChild(cell);
				if(i==0){
					cell.y=0;
				}else{
					cell.y=cellobj[i-1][0]+cellobj[i-1][1];
				}
				cellobj[i]=[cell.y,cell.height];
			}
			callLater(function():void{
				this.panel.vScrollBar.value=this.panel.vScrollBar.max;
			});
		}

		public function addPanel():void{
			showLength+=1;
			//var max:Number=this.panel.vScrollBar.max;
			var cell:Item_User=new Item_User();
			cell.setData(this.list.array[showLength-1],showLength-1);
			//this.panel.addChild(cell);
			cell.name="cell"+(showLength-1);
			cell.y=cellobj[showLength-1][0]+cellobj[showLength-1][1];
			cellobj[showLength-1]=[cell.y,cell.height];
			//if(max==this.panel.vScrollBar.value){
				callLater(function():void{
					this.panel.vScrollBar.value=this.panel.vScrollBar.max;
				});
			//}
			
		}

		public function addTopCell():void{
			showLength+=1;
			if(this.list.array[showLength]){
				var cell:Item_User=new Item_User();
				cell.setData(this.list.array[showLength],showLength);
				//this.panel.addChild(cell);
				cell.y=0;
				cellobj[0]=[cell.y,cell.height];
				//for(var i:int=1;i<this.panel.numChildren;i++){

				//}
			}
		}

		public function panelScroller():void{
			//trace(this.panel.vScrollBar.value);
		}
		*/
		
		public function scrollBarChange():void{
			//trace("=======",this.list.scrollBar.value,this.list.scrollBar.max,isBottom);
			isBottom=this.list.scrollBar.value==this.list.scrollBar.max;
		}
		

		public function setList(b:Boolean=false):void{
			var arr:Array=ModelChat.channel_seleted;
			var chat:Array=[];
			if(arr[0]==1 && ModelManager.instance.modelChat.sysList.length!=0){
				chat=chat.concat(ModelManager.instance.modelChat.sysList);
			}
			if(arr[1]==1 && ModelManager.instance.modelChat.worldList.length!=0){
				chat=chat.concat(ModelManager.instance.modelChat.worldList);
			}
			if(arr[2]==1 && ModelManager.instance.modelChat.countryList.length!=0){
				chat=chat.concat(ModelManager.instance.modelChat.countryList);
			}
			if(arr[3]==1 && ModelManager.instance.modelChat.guildList.length!=0){
				chat=chat.concat(ModelManager.instance.modelChat.guildList);
			}
			chat.sort(MathUtil.sortByKey("sort",false,false));
			this.list.array=chat;

			//收到新消息就跳到最底端
			if(isBottom){
				list.scrollBar.value=list.scrollBar.max;
			}
			if(b==false){
				//addPanel();
			}
			//
			//return;
			//var h:Number=0;
			//for(var s:String in cellHeigtobj){
			//	h+=cellHeigtobj[s]+this.list.repeatY;
			//}
			//this.list.content.height=h;
			//list.scrollBar.max=h-this.list.height;
			//list.scrollBar.value=list.scrollBar.max;
		}



		public function listRender(cell:Item_User,index:int):void{
			cell.setData(this.list.array[index],index);
			/*
			if(!cellYobj.hasOwnProperty(index+"")){
				if(index==0){
					cell.y=0;
				}else{
					cell.y=curCellH+curCellY+this.list.spaceY;
				}
				cellYobj[index+""]=cell.y;
			}else{
				cell.y=cellYobj[index+""];
			}
			curCellH=cell.height;
			curCellY=cell.y;
			if(!cellHeigtobj.hasOwnProperty(index+"")){
				cellHeigtobj[index+""]=cell.height;
			}
			*/
			//changeHandler(0);
			//trace(index,cell.y,cell.height);
			cell.nameLabel.off(Event.CLICK,this,this.itemClick);
			cell.nameLabel.on(Event.CLICK,this,this.itemClick,[index]);
			
			cell.comHero.off(Event.CLICK,this,this.itemClick);
			cell.comHero.on(Event.CLICK,this,this.itemClick,[index]);
		}

		public function itemClick(index:int):void{
			seletedUid=this.list.array[index][3][1][0];
			seletedIndex=index;
			if(seletedUid+""==ModelManager.instance.modelUser.mUID){
				return;
			}
			this.boxSet.x=this.mouseX;
			this.boxSet.y=this.mouseY;
			this.boxSet.visible=true;
			this.btnBG.visible=true;
		}

		public function setClick(type:int):void{
			this.btnBG.visible=this.boxSet.visible=false;
			if(type==0){
				ModelManager.instance.modelUser.selectUserInfo(seletedUid);
			}else if(type==1){
				/*[uid,uname,country,head,olv,lv]*/

				//var uname:String=this.list.array[seletedIndex][3][1][1];
				//NetSocket.instance.send("find_user",{"uname":uname},Handler.create(this,ModelManager.instance.modelChat.findUerCallBack));
				var a:Array = this.list.array[seletedIndex][3][1];
				NetSocket.instance.send("get_msg",{},Handler.create(this,function(np:NetPackage):void{
					ModelManager.instance.modelUser.updateData(np.receiveData);
					ModelManager.instance.modelUser.setChatData(ModelManager.instance.modelUser.msg.usr);	
					ModelManager.instance.modelUser.event(ModelUser.EVENT_UPDATE_MAIL_CHAT_MAIN,ModelManager.instance.modelUser.msg.usr);
					ModelManager.instance.modelChat.findUerCallBack({"receiveData":{"uid":a[0],
																				"uname":a[1],
																				"country":a[2],
																				"head":a[3],
																				"lv":a[5]}},1);
				}));

				
				
			}else if(type==2){
				if(ModelManager.instance.modelUser.banned_users.hasOwnProperty(seletedUid)){
					ViewManager.instance.showTipsTxt(Tools.getMsgById("_chat_tips04"));//"已经屏蔽过他了"
				}else{
					NetSocket.instance.send("ban_user",{"uid":seletedUid},new Handler(this,function(np:NetPackage):void{
						ModelManager.instance.modelUser.updateData(np.receiveData);
						ViewManager.instance.showTipsTxt(Tools.getMsgById("_chat_tips02"));//"屏蔽成功"
					}));
				}
			}else if(type==3){//只能禁国家频道
				var uCountry:int=this.list.array[seletedIndex][3][1][2];
				if(uCountry!=ModelManager.instance.modelUser.country){
					ViewManager.instance.showTipsTxt("_chat_tips07");
					return;
				}
				NetSocket.instance.send("chat_ban",{"uid":seletedUid},new Handler(this,function(np:NetPackage):void{
					ModelManager.instance.modelUser.updateData(np.receiveData);
					ViewManager.instance.showTipsTxt(Tools.getMsgById("_chat_tips03"));//"禁言成功"
				}));
			}
		}


		
		
		public function changeHandler(value:Number):void{
			var h:Number=0;
			/*
			for(var s:String in cellHeigtobj){
				h+=cellHeigtobj[s]+this.list.repeatY;
			}
			this.list.content.height=h;
			*/
			var arr:Array=[];
			for(var j:int=0;j<this.list.content.numChildren;j++){
				var node:Component=this.list.content.getChildAt(j) as Component;
				arr.push({"y":node.y,"index":j});
			}
			arr.sort(MathUtil.sortByKey("y",false));
			

			for(var i:int=0;i<arr.length;i++){
				var node1:Component=this.list.content.getChildAt(arr[i].index) as Component;
				if(i==0){
					//node.y=0;
					//trace(node.y);
				}else{
					var node2:Component=this.list.content.getChildAt(arr[i-1].index) as Component;
					node1.y=node2.y+node2.height+this.list.spaceY;
					// trace(node2.y,node2.height);
				}
				h+=node1.height+this.list.spaceY*arr.length;
				//trace(node.name);
				
			}
			//var last:Component=(list.content.getChildAt(this.list.content.numChildren-1)) as Component;
			this.list.content.height=h;
			//this.list.scrollBar.height=this.list.content.height;
		}


		public function onClick(obj:*):void{
			switch(obj){
				case btnFace:
					if(ModelGame.unlock(null,"face").gray) return;
					
					if(itemFace) itemFace.visible = this.btnBG.visible = true;
					break;
				case btnSend:
					sendMsg();
					break;
				case btnSet0:
					setClick(0);
					break;
				case btnSet1:
					setClick(1);
					break;
				case btnSet2:
					setClick(2);
					break;
				case btnSet3:
					setClick(3);
					break;
				case btnChannel0:
					clickChannel(0);
					break;
				case btnChannel1:
					clickChannel(1);
					break;
				case btnChannel2:
					clickChannel(2);
					break;
				case btnChange:
					boxChannel.visible=!boxChannel.visible;
					this.btnBG.visible=true;
					this.imgCheck.rotation=boxChannel.visible?180:0;
					break;
				case btnCheck:
					ViewManager.instance.showView(["ViewChatCheck",ViewChatCheck]);
					break;
				case btnBlack:
					ViewManager.instance.showView(["ViewChatBlackList",ViewChatBlackList]);
				break;
				case btnBG:
					this.btnBG.visible=this.boxSet.visible=this.boxChannel.visible=false;
					if(itemFace) itemFace.visible = false;
					break;
				case btnSearch:
					var s:String = ModelGame.unlock(this.btnSearch,"chat_search").text;
					if(s!=""){
						ViewManager.instance.showTipsTxt(s);
					}else{
						ViewManager.instance.showView(ConfigClass.VIEW_ADD_CHAT,1);
					}
					break;

			}
		}

		public function clickChannel(index:int):void{
			this.boxChannel.visible=false;
			this.btnBG.visible=false;
			//if(index==2 && ModelManager.instance.modelUser.guild_id==null){
			//	ViewManager.instance.showTipsTxt(Tools.getMsgById("_chat_tips05"));//"请先加入一个军团"
			//	return;
			//}
			if(index==2 && !ModelOfficial.isMayorOrOfficer(ModelManager.instance.modelUser.mUID)){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_chat_tips08"));
				return;
			}
			this.btnChange.label=ModelChat.channel_arr[index];
			ModelManager.instance.modelChat.cur_channel=index;
			setSendBtn();

			SaveLocal.save(SaveLocal.KEY_LOCAL_CHAT_CHANNEL+ModelManager.instance.modelUser.mUID,{"channel":index},true);
		}


		public function sendMsg():void{
			if(inputLabel.text!=""){
				//for(var i:int=0;i<4;i++){
					//var obj:Object=
				//}
				if(ModelGame.unlock(null,"chat_limit",true).stop) return;

				if(!Tools.isCanBuy("coin",mCostNum)){
					return;
				}
				
				
				if(ModelManager.instance.modelChat.cur_channel==2){//国家栋梁
					if(!ModelOfficial.isMayorOrOfficer(ModelManager.instance.modelUser.mUID)){
						ViewManager.instance.showTipsTxt(Tools.getMsgById("_chat_tips08"));
						return;
					}
				}else if(ModelManager.instance.modelChat.cur_channel==0){
					if(ModelGame.unlock(null,"chat_world",true).stop) return;
				}

				if(mCostNum!=0){
					ViewManager.instance.showAlert(Tools.getMsgById("_chat_tips09"),
						Handler.create(this,this.sendText),["coin",mCostNum],"",false,false,"world_chat");
				}else{
					sendText(0);
				}

			}
			
		}

		private function sendText(type:int):void{
			if(type!=0) return;
			var sendData:Object={};
			sendData["icon"] = ModelManager.instance.modelChat.cur_channel;
			sendData["type"] = 0;
			sendData["key"]  = 0;
			var s:String = inputLabel.text.replace(/[<>&]/g,"");
			s = FilterManager.instance.cityWrap(s);
			s = ModelManager.instance.modelChat.faceFliter(s);
			sendData["msg"] = s;
			NetSocket.instance.send("chat",sendData,new Handler(this,function(np:NetPackage):void{
				isBottom=true;
				ModelManager.instance.modelUser.updateData(np.receiveData);
				ModelManager.instance.modelChat.acceptMSG(np.receiveData.chat);
				setSendBtn();
				inputLabel.text="";
			}));
		}


		public function setSendBtn():void{
			//世界频道才读这个花费配置
			var config_cost:Array=ModelManager.instance.modelChat.cur_channel!=0 ? [0] : ConfigServer.system_simple.worldtalk_spend;
			var user_arr:Array=ModelManager.instance.modelUser.records.chat[ModelManager.instance.modelChat.cur_channel+""];
			var n:Number=Tools.isNewDay(user_arr.time)?0:user_arr.num;
			var m:Number=n>config_cost.length-1?n=config_cost.length-1:n;
			mCostNum=0;
			if(config_cost[m]==0){
				if(config_cost.length==1){
					btnSend.setData("",Tools.getMsgById("_chat_text12"),-1,1);
				}else{
					var free_num:Number=0;
					for(var i:int=0;i<config_cost.length;i++){
						if(config_cost[i]==0){
							free_num+=1;
						}else{
							break;
						}
					}
					btnSend.setData("",Tools.getMsgById("_chat_text11",[(free_num-m),free_num]),-1,1);
				}
			}else{
				btnSend.setData(AssetsManager.getAssetItemOrPayByID("coin"),config_cost[m]);
				mCostNum=config_cost[m];
			}
			
		}

		public override function onRemoved():void{
			ModelManager.instance.modelChat.off(ModelChat.EVENT_ADD_CHAT,this,eventCallBack1);
			ModelManager.instance.modelChat.off(ModelChat.EVENT_UPDATE_CHANNEL,this,eventCallBack2);
			ModelManager.instance.modelChat.off(ModelChat.EVENT_ADD_FACE,this,eventCallBack3);
			ModelManager.instance.modelChat.off(ModelChat.EVENT_CLOSE_FACE,this,eventCallBack4);
			onClick(this.btnBG);
			this.list.scrollBar.changeHandler.clear();			

		}
	}

}

import ui.chat.item_chat_userUI;
import sg.model.ModelUser;
import sg.utils.Tools;
import sg.model.ModelChat;
import sg.model.ModelOfficial;
import sg.manager.ModelManager;
import sg.manager.EffectManager;
import sg.cfg.ConfigColor;
import sg.boundFor.GotoManager;
import laya.events.Event;
import sg.manager.FilterManager;
import sg.manager.ViewManager;
import sg.cfg.ConfigClass;
import sg.view.country.ViewAlienTroopInfo;
import sg.activities.model.ModelPayRank;
import sg.activities.model.ModelEquipBox;

class Item_User extends item_chat_userUI{

	public var reData:Array;
	public function Item_User():void{

	}

	public function setData(arr:Array,index:int):void{
		reData=arr;
		var b:Boolean=arr[1]==0;
		this.textLabel.style.color="#FFFFFF";
		this.textLabel.style.fontSize = 20;
		this.textLabel.style.leading = 6;

		this.timeLabel.text = Tools.dateFormat(arr[4],0);
		//系统、世界、国家、栋梁
		this.btnChannel.label = arr[0]==0 && arr[1]!=0 ? Tools.getMsgById("_chat_text18") : ModelChat.channel_arr[arr[0]];

		if(b){
			var user_data:Array=arr[3][1];//[uid,uname,country,head,official,b001_lv]
			this.nameLabel.text=user_data[1];
			if(user_data[0]+""==ModelManager.instance.modelUser.mUID){
				this.nameLabel.color="#10F010";
			}else{
				this.nameLabel.color="#FFFFFF";
			}
			var s:String = arr[3][0];
			//FilterManager.instance.cityWrap(arr[3][0]);
			//s = FilterManager.instance.wordBan(s); 
			this.textLabel.innerHTML = s;
			this.comOfficial.visible=this.comFlag.visible=this.comHero.visible=true;
			this.comHero.setHeroIcon(ModelUser.getUserHead(user_data[3]));
			this.comOfficial.setOfficialIcon(user_data[4], ModelOfficial.getInvade(user_data[2]), user_data[2]);
			this.comFlag.setCountryFlag(user_data[2]);

			this.height           = 100;
			this.imgMayor.visible = ModelOfficial.isCityMayor(user_data[0],user_data[2])!="";
			this.comOfficial.x    = this.nameLabel.x+this.nameLabel.width+2;
			this.imgMayor.x       = user_data[4]==-100 ? this.comOfficial.x : this.comOfficial.x+this.comOfficial.width*this.comOfficial.scaleX+2;
			this.imgText.x        = this.btnChannel.x=this.comHero.x+this.comHero.width+4;
			this.imgText.width    = this.width-this.imgText.x-4;
			this.imgText.y        = 33;
			
			this.heroLv.setNum(user_data[5]);
			this.heroLv.visible = true;
			//this.lvLabel.text=user_data[5];
		}else{
			this.heroLv.visible = false;
			//this.lvBox.visible=false;
			this.textLabel.innerHTML = ModelManager.instance.modelChat.sysMessage(arr);
			this.nameLabel.text = "";
			this.imgMayor.visible = this.comOfficial.visible=this.comFlag.visible=this.comHero.visible=false;
			this.height = 80;
			this.btnChannel.x = this.imgText.x = 0;
			this.imgText.x = 8;
			this.imgText.width = this.width-16;
			this.imgText.y = this.timeLabel.y+this.timeLabel.height+2;	
			
		}
		this.textLabel.off(Event.LINK,this,click);
		this.textLabel.on(Event.LINK,this,click);
		this.textLabel.width=this.imgText.width-10-this.btnChannel.width;
		this.textLabel.x=this.imgText.x+this.btnChannel.width+8;
		this.btnChannel.y=this.textLabel.y=this.imgText.y+5;
		this.btnChannel.x=this.imgText.x+5;
		this.btnChannel.skin=ModelChat.channel_skin[arr[0]];
		if(this.textLabel.height>52){
			this.imgText.height = this.textLabel.height;//+10;
			this.height=this.imgText.height+(100-62);
		}
		//trace(this.textLabel.height,aaa,this.height);
	}

	public function click(data:*):void{
		//trace("================",data,"===========");
		if(data=="country_call"){
			if(ModelManager.instance.modelClub.alien[reData[2]]["team"][0]["troop"].length!=0){
				//ViewManager.instance.showView(ConfigClass.VIEW_GUILD_TROOP_INFO,[null,reData[2]]);
				ViewManager.instance.showView(["ViewAlienTroopInfo",ViewAlienTroopInfo],reData[2]);
			}else{
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_guild_tips16"));//"找不到集结编组");
			}
		}else if(data=="look_star"){
			GotoManager.boundFor({type:2,buildingID:"building006","state":1});
			//GotoManager.boundForPanel(GotoManager.VIEW_STAR_GET);	
		}else if(data=="limit_free"){
            GotoManager.showView(ConfigClass.VIEW_FREE_BILL);
		}else if(data=="pvp_pk"){
            GotoManager.boundForPanel(GotoManager.VIEW_PK);
		}else if(data=="pk_yard"){
			GotoManager.boundForPanel(GotoManager.VIEW_PK_YARD);
		}else if(data=="pay_rank"){
			ModelPayRank.instance.active && !ModelPayRank.instance.notStart && GotoManager.boundForPanel(GotoManager.VIEW_PAY_RANK);
		}else if(data=="equip_box"){
			ModelEquipBox.instance.active &&  GotoManager.boundForPanel(GotoManager.VIEW_EQUIP_BOX);
		}else if(data!=" "){
			GotoManager.boundFor({type:1,cityID:data});
		}
	}

}