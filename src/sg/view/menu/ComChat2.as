package sg.view.menu
{
	import ui.menu.comChat2UI;
	import laya.events.Event;
	import sg.manager.ModelManager;
	import laya.utils.Handler;
	import sg.utils.Tools;
	import sg.net.NetSocket;
	import sg.manager.FilterManager;
	import sg.net.NetPackage;
	import sg.cfg.ConfigServer;
	import sg.manager.AssetsManager;
	import sg.manager.ViewManager;
	import sg.view.chat.ViewChatCheck;
	import sg.view.chat.ViewChatBlackList;
	import sg.utils.SaveLocal;
	import sg.model.ModelChat;
	import sg.model.ModelOfficial;
	import sg.model.ModelGame;
	import sg.model.ModelUser;
	import laya.maths.MathUtil;

	/**
	 * ...
	 * @author
	 */
	public class ComChat2 extends comChat2UI{

		public var seletedUid:String="";	
		private var mCostNum:Number;//聊天需要花费的元宝数

		private var mTopIndex:int=0;
		private var mBtmIndex:int=0;

		private var mData:Object={};//{"uid":[]}
		private var mChatData:Array;
		private var mLock:Boolean = false;
		private var mStatus:int = 0;//面板状态  三种
		private var mTest:Boolean = false;
		private var mTime:Number;//定时刷新时间
		private var mInterval:Number = 2;//间隔分钟数

		private var mArr:Array=[];
		
		public function ComChat2(){
			this.btnSend.on(Event.CLICK,this,onClick,[btnSend]);
			this.btnBlack.on(Event.CLICK,this,onClick,[btnBlack]);
			this.btnBG.on(Event.CLICK,this,onClick,[btnBG]);

			this.btnSet0.img.skin=AssetsManager.getAssetsUI("icon_duilie21.png");
			this.btnSet1.img.skin=AssetsManager.getAssetsUI("icon_duilie22.png");
			this.btnSet2.img.skin=AssetsManager.getAssetsUI("icon_duilie23.png");
			this.btnSet3.img.skin=AssetsManager.getAssetsUI("icon_duilie21.png");

			this.btnSet0.label.text=Tools.getMsgById("_chat_text06");//"信息";
			this.btnSet1.label.text=Tools.getMsgById("_chat_text08");//"私聊";
			this.btnSet2.label.text=Tools.getMsgById("_chat_text07");//"屏蔽";
			this.btnSet3.label.text=Tools.getMsgById("_chat_text09");//"禁言";
			
			this.btnChannel0.on(Event.CLICK,this,onClick,[btnChannel0]);
			this.btnChannel1.on(Event.CLICK,this,onClick,[btnChannel1]);
			this.btnChannel2.on(Event.CLICK,this,onClick,[btnChannel2]);
			this.btnSet0.on(Event.CLICK,this,onClick,[btnSet0]);
			this.btnSet1.on(Event.CLICK,this,onClick,[btnSet1]);
			this.btnSet2.on(Event.CLICK,this,onClick,[btnSet2]);
			this.btnSet3.on(Event.CLICK,this,onClick,[btnSet3]);
			this.btnChange.on(Event.CLICK,this,onClick,[btnChange]);
			this.btnCheck.on(Event.CLICK,this,onClick,[btnCheck]);
			this.imgArrow.on(Event.CLICK,this,onClick,[imgArrow]);

			this.btnChannel0.label = Tools.getMsgById("_chat_text03");
			this.btnChannel1.label = Tools.getMsgById("_chat_text04");
			this.btnChannel2.label = Tools.getMsgById("_country74");

			this.channelInfo0.text = Tools.getMsgById("_chat_text15");
			this.channelInfo1.text = Tools.getMsgById("_chat_text16");
			this.channelInfo2.text = Tools.getMsgById("_chat_text17");

			this.chatPanel.vScrollBar.changeHandler = new Handler(this,panelChange);
			
			this.mStatus = 1;
			this.height = 200;
			this.tInput.maxChars = 140;
			this.btnBG.visible=this.boxChannel.visible=false;
			//this.chatPanel.vScrollBar.visible = false;
			this.chatPanel.vScorllBarX = 0;

			setData();
			mTime = ConfigServer.getServerTimer() + mInterval*Tools.oneMinuteMilli;
			timeTick();

			Laya.stage.on(Event.KEY_UP,this,function(e):void{
				if(e.keyCode == 13){//回车
					sendMsg();
				}
			});
		}
		private function timeTick():void{
			return;
			timer.once(1000,this,timeTick);

			var now:Number = ConfigServer.getServerTimer();
			if(now>mTime){
				mTime = now + mInterval*Tools.oneMinuteMilli;
				checkChatCom();
			}
		}

		private function channelChange(type:int=0):void{
			if(ModelOfficial.getUserOfficer(ModelManager.instance.modelUser.mUID)==8){
				this.btnSet3.visible=true;
				this.boxSet.height=207;
			}else{
				this.btnSet3.visible=false;
				this.boxSet.height=156;
			}

			var arr:Array=ModelChat.channel_seleted;
			mChatData=[];
			if(arr[0]==1 && ModelManager.instance.modelChat.sysList.length!=0){
				mChatData=mChatData.concat(ModelManager.instance.modelChat.sysList);
			}
			if(arr[1]==1 && ModelManager.instance.modelChat.worldList.length!=0){
				mChatData=mChatData.concat(ModelManager.instance.modelChat.worldList);
			}
			if(arr[2]==1 && ModelManager.instance.modelChat.countryList.length!=0){
				mChatData=mChatData.concat(ModelManager.instance.modelChat.countryList);
			}
			if(arr[3]==1 && ModelManager.instance.modelChat.guildList.length!=0){
				mChatData=mChatData.concat(ModelManager.instance.modelChat.guildList);
			}
			mChatData.sort(MathUtil.sortByKey("sort",false,false));

			if(type==0){
				initChatCom();
			}else{
				addChatCom(true,true);
			}
		}

		private function nameClick(uid:*):void{
			seletedUid=uid;
			if(seletedUid+""==ModelManager.instance.modelUser.mUID){
				return;
			}
			this.boxSet.x=this.mouseX;
			this.boxSet.y=this.mouseY;
			this.boxSet.visible=true;
			this.btnBG.visible=true;
			if(this.boxSet.y > this.height - this.boxSet.height){
				this.boxSet.y = this.boxSet.height;
			}
		}

		private function scrollChange(v:*):void{
			chatPanel.vScrollBar.value = v;
		}

		private function panelChange(v:*):void{
			if(mLock) return;
			var n:Number = chatPanel.vScrollBar.value;
			var m:Number = chatPanel.vScrollBar.max;
			if(n == 0){			
				if(mTopIndex > 0){
					mLock = true;
					addChatCom(false);
				}
			}else if(n == m){
				if(mBtmIndex < mChatData.length-1){
					mLock = true;
					addChatCom(true);
				} 
			}
			//trace('-----------',n,m);
		}

		private function initChatCom():void{
			var _comheight:int = 0;
			var _comY:int = 0;
			var _uData:Array = null;

			for(var j:int=0;j<mArr.length;j++){
				(mArr[j] as ItemChat2).removeSelf();
			}
			mArr = [];
			var index:int=mChatData.length>8 ? mChatData.length-8 : 0; 
			mTopIndex = index;
			mBtmIndex = mChatData.length ? mChatData.length-1 : 0;
			for(var i:int=mTopIndex;i<mChatData.length;i++){
				var com:ItemChat2 = new ItemChat2();
				_uData =  mChatData[i][3] ? mChatData[i][3][1] : null;
				com.setData(mChatData[i]);
				com.y = _comY;
				_comY += com.height; 
				chatContent.addChild(com);
				if(_uData){
					com.tName.on(Event.CLICK,this,nameClick,[_uData[0]]);
					mData[_uData[0]] = _uData;
				}
				_comheight += com.height;
				mArr.push(com);
				mTest && trace("===========init",i);				
			}
			
			chatContent.x = chatPanel.vScrollBar.width + 10;
			chatContent.y = 0;
			chatContent.height = _comheight;
			chatPanel.vScrollBar.setScroll(0,_comheight,_comheight);
		}

		private function addChatCom(isBtm:Boolean,autoBtm:Boolean = false):void{
			var addCom:ItemChat2 = new ItemChat2();
			var _uData:Array = null;
			var _comheight:int = 0;
			
			if(isBtm){
				if(mChatData.length == 0) return;
				if(mChatData.length==1){
					mBtmIndex = 0;
				}else{
					mBtmIndex++;
				}
				_uData = mChatData[mBtmIndex][3] ? mChatData[mBtmIndex][3][1] : null;
				mTest && trace("===========add bottom",mBtmIndex-1);
				addCom.setData(mChatData[mBtmIndex]);
				
				if(_uData){
					mData[_uData[0]] = _uData;
					addCom.tName.on(Event.CLICK,this,nameClick,[_uData[0]]);
				}

				chatContent.addChild(addCom);
				
				addCom.y = mArr[mArr.length-1] ? mArr[mArr.length-1].y + mArr[mArr.length-1].height : 0;
				_comheight = addCom.y + addCom.height;
				mArr.push(addCom);
			}else{
				_uData = mChatData[mTopIndex-1][3] ? mChatData[mTopIndex-1][3][1] : null;
				addCom.setData(mChatData[mTopIndex-1]);

				if(_uData){
					addCom.tName.on(Event.CLICK,this,nameClick,[_uData[0]]);
				}
				chatContent.addChild(addCom);
				mArr.unshift(addCom);

				var _comY:int = 0;
				for(var i:int=0;i<mArr.length;i++){
					var com:ItemChat2 = mArr[i] as ItemChat2;
					com.y =  _comY;
					_comY += com.height;
					_comheight += com.height;
				}
				
				
				mTest && trace("===========add top",(mTopIndex-1));
				mTopIndex--;
			}
			if(mArr.length>=10){
				removeChatCom(isBtm,addCom.height);
				if(autoBtm){
					chatPanel.vScrollBar.setScroll(0,chatPanel.vScrollBar.max,chatPanel.vScrollBar.max);
				}
			}else{
				chatContent.height = _comheight;
				if(isBtm){
					if(autoBtm)	chatPanel.vScrollBar.setScroll(0,_comheight,_comheight);
				}else{
					chatPanel.vScrollBar.setScroll(0,_comheight,addCom.height);
				}
			}
			mLock = false;

		}

		/**
		 * 定时检查清理一下
		 */
		private function checkChatCom():void{
			return;
			if(chatPanel.vScrollBar.value == chatPanel.vScrollBar.max){
				var n:Number = chatContent.numChildren - 12;
				if(n > 0){
					var arr:Array = [];
					for(var i:int=mTopIndex;i<mTopIndex+n;i++){
						var removeCom:* = chatContent.getChildByName("com"+i);
						chatContent.removeChild(removeCom);
						arr.push(i);
						
					}
					mTest && trace("===========remove",arr);
					mTopIndex += n;
					var _comheight:int = 0;
					var _comY:int = 0;
					for(var j:int=mTopIndex;j<=mBtmIndex;j++){
						var com:* = chatContent.getChildByName("com"+j);
						com.y = _comY;
						_comY += com.height; 
						_comheight += com.height;
						arr.push(j);
					}
					
					mTest && trace("===========clear",mTopIndex,mBtmIndex);
					chatContent.height = _comheight;
					chatPanel.vScrollBar.max = _comheight;
					chatPanel.vScrollBar.value = _comheight;
				}
			}
		}

		private function removeChatCom(isBtm:Boolean,addHeight:Number):void{
			//if(chatContent.numChildren>=10){
				var removeCom:ItemChat2;
				var _comheight:int = 0;
				var _comY:int = 0;
				if(isBtm){
					// trace("===========remove top",mTopIndex);
					removeCom = mArr[0] as ItemChat2;
					mTopIndex++;
					removeCom.removeSelf();
					mArr.shift();
				}else{
					// trace("===========remove bottom",mBtmIndex);
					removeCom = mArr[mArr.length-1] as ItemChat2;
					mBtmIndex--;
					removeCom.removeSelf();
					mArr.pop();
				}

				var v1:Number = chatPanel.vScrollBar.value;
				var m1:Number = chatPanel.vScrollBar.max;

				for(var i:int=0;i<mArr.length;i++){
					var com:ItemChat2 = mArr[i] as ItemChat2;
					com.y =  _comY;
					_comY += com.height;
					_comheight += com.height;
				}
				
				

				chatContent.height = _comheight;
				chatContent.y = 0;

				var m2:Number = chatPanel.vScrollBar.max;
				//var v2:Number = v1*m1/m2;
				var v2:Number = m1 - addHeight;
				
				chatPanel.vScrollBar.setScroll(0,_comheight,v2);
			//}
		}


		private function setData():void{
			this.btnChange.label = ModelChat.channel_arr[ModelManager.instance.modelChat.cur_channel];
			var isWorld:Boolean=false;
			isWorld=ModelGame.unlock(btnChannel0,"chat_world").stop;
			this.btnBG.visible=this.boxSet.visible=false;
			ModelManager.instance.modelChat.on(ModelChat.EVENT_ADD_CHAT,this,eventCallBack1);//新消息

			ModelManager.instance.modelChat.on(ModelChat.EVENT_UPDATE_CHANNEL,this,eventCallBack2);//切换频道

			var o:Object=SaveLocal.getValue(SaveLocal.KEY_LOCAL_CHAT_CHANNEL+ModelManager.instance.modelUser.mUID,true);
			if(o) ModelManager.instance.modelChat.cur_channel=o.channel;

			var n:Number=ModelManager.instance.modelChat.cur_channel;
			if(n==-1) n = ConfigServer.system_simple.init_channel;//默认进入的聊天频道
			if(isWorld==false){
				clickChannel(n);
			}else{
				clickChannel(1);
			}
			if(this.btnChannel0.visible==false){
				//this.imgChannel.top=45;
				this.channelInfo0.text="";
			}

			channelChange(0);
		}

		private function eventCallBack1():void{
			channelChange(1);
		}

		private function eventCallBack2():void{
			channelChange(0);
		}

		public function onClick(obj:*):void{
			switch(obj){
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
					this.imgCheck.rotation = boxChannel.visible?180:0;
				 	break;
				case imgArrow:
					panelChange2();
					break;
			}
		}

		private function panelChange2():void{
			mStatus++;
			if(mStatus==3) mStatus = 0;
			if(mStatus == 0 || mStatus == 1){
				this.height = mStatus==0 ? 350 : 200;
				chatPanel.vScrollBar.visible = true;
				chatPanel.bottom = boxBtm.height;
				this.boxBtm.visible = true;
			}else if(mStatus == 2){
				this.height = 80;
				chatPanel.vScrollBar.visible = false;
				chatPanel.bottom = 0;
				this.boxBtm.visible = false;
			}

			chatPanel.vScrollBar.max = chatContent.height;
			chatPanel.vScrollBar.value = chatContent.height;
		}

		public function clickChannel(index:int):void{
			this.boxChannel.visible = false;
			this.btnBG.visible = false;
			this.imgCheck.rotation = boxChannel.visible?180:0;
			if(index==2 && !ModelOfficial.isMayorOrOfficer(ModelManager.instance.modelUser.mUID)){
					ViewManager.instance.showTipsTxt(Tools.getMsgById("_chat_tips08"));
					return;
				}
			this.btnChange.label=ModelChat.channel_arr[index];
			ModelManager.instance.modelChat.cur_channel=index;
			setSendBtn();

			SaveLocal.save(SaveLocal.KEY_LOCAL_CHAT_CHANNEL+ModelManager.instance.modelUser.mUID,{"channel":index},true);
		}

		public function setClick(type:int):void{
			this.btnBG.visible=this.boxSet.visible=false;
			if(type==0){
				ModelManager.instance.modelUser.selectUserInfo(seletedUid);
			}else if(type==1){
				var a:Array = mData[seletedUid];
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
				var uCountry:int=mData[seletedUid][2];// this.list.array[seletedIndex][3][1][2];
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


		public function sendMsg():void{
			if(tInput.text!=""){
				
				if(ModelGame.unlock(null,"chat_limit",true).stop) return;

				if(!Tools.isCanBuy("coin",mCostNum)) return;
				
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
			var s:String = tInput.text.replace(/[<>&]/g,"");
			s = FilterManager.instance.cityWrap(s);
			//屏蔽字处理
			//s = FilterManager.instance.wordBan(s);
			sendData["msg"] = s;
			NetSocket.instance.send("chat",sendData,new Handler(this,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				ModelManager.instance.modelChat.acceptMSG(np.receiveData.chat);
				setSendBtn();
				tInput.text="";
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
	}

}