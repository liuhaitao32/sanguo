package sg.view.guild
{
	import ui.guild.guildInfoUI;
	import laya.events.Event;
	import sg.utils.Tools;
	import sg.net.NetSocket;
	import sg.net.NetPackage;
	import laya.utils.Handler;
	import sg.cfg.ConfigServer;
	import sg.utils.ObjectSingle;
	import sg.cfg.ConfigClass;
	import sg.model.ModelUser;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.model.ModelGuild;
	import laya.ui.Box;
	import ui.guild.guildInfoItemUI;
	import laya.maths.MathUtil;
	import sg.model.ModelItem;
	import sg.model.ModelCityBuild;
	import sg.guide.model.ModelGuide;
	import sg.utils.StringUtil;
	import laya.html.dom.HTMLDivElement;
	import laya.display.Animation;
	import sg.manager.EffectManager;
	import sg.boundFor.GotoManager;
	import sg.manager.FilterManager;

	/**
	 * ...
	 * @author
	 */
	public class ViewGuildInfo extends guildInfoUI{

		public var isOpenBox:Boolean=false;
		public var data:Object={};
		//public var leaderData:Array=[];
		//public var vice_leaderData:Array=[];
		public var configData:Object=ConfigServer.guild;
		public var curInputText:String="";
		public var isManager:Boolean=false;
		public var listData:Array=[];
		public var redBagData:Array=[];

		public var curRechargeLv:Number=0;
		public var curRechargeIndex:Number=0;
		public var redBagNum:Number=0;//礼包个数
		public var totalPayMoney:Number=0;

		//public var ani:Animation;

		public function ViewGuildInfo(){
			//ani=EffectManager.loadAnimation("glow000");
			//ani.visible=false;
			//this.rechargeIcon.addChild(ani);
			//ani.pos(this.rechargeIcon.width/2,this.rechargeIcon.height/2);
			this.btnSet.on(Event.CLICK,this,this.setClick);
			this.btnEditor.on(Event.CLICK,this,editorClick);
			this.contentLabel.on(Event.BLUR,this,inputBlur);
			this.btnQuit.on(Event.CLICK,this,quitClick);
			this.btnChange.on(Event.CLICK,this,changeClick);
			this.list.itemRender=Item;
			this.list.scrollBar.visible=false;
			this.list.renderHandler=new Handler(this,this.listRender);
			this.btnAsk.on(Event.CLICK, this, this.askClick);
			this.comBox.on(Event.CLICK,this,this.rechargeClick);
			//this.rechargeIcon.on(Event.CLICK,this,this.rechargeClick);
			this.btnCheck.on(Event.CLICK,this,function():void{
				ViewManager.instance.showView(["ViewGuildStatistics",ViewGuildStatistics]);
				box1.visible=false;
			});

			this.btnMsg.on(Event.CLICK,this,function():void{
				ViewManager.instance.showView(["viewGuildMessage",viewGuildMessage]);
			});
			this.panel.hScrollBar.visible=false;

			this.btnTest.visible=false;
			this.btnTest.on(Event.CLICK,this,function():void{
				//NetSocket.instance.send("get_guild_redbag",{"redbag_index":-1},Handler.create(this,function(np:NetPackage):void{
				//	ViewManager.instance.showTipsTxt("一键领取所有奖励");
				//}));
			});

			ModelManager.instance.modelGuild.on(ModelGuild.EVENT_GUILD_NAME,this,function():void{
				this.nameLabel.text=ModelManager.instance.modelGuild.name;
			});

			this.panel.hScrollBar.touchScrollEnable=false;
		}

		override public function onAdded():void{
			this.textLabel1.text=Tools.getMsgById("_guild_text14");
			this.textLabel2.text=Tools.getMsgById("_guild_text18");
			this.text0.text=Tools.getMsgById("_guild_text08");
			this.text1.text=Tools.getMsgById("_guild_text09");
			this.text2.text=Tools.getMsgById("_guild_text13");
			this.text3.text=Tools.getMsgById("_guild_text11");
			this.btnCheck.label=Tools.getMsgById("_guild_text105");
			this.btnChange.label=Tools.getMsgById("_guild_text106");
			this.btnQuit.label=Tools.getMsgById("_guild_text107");
			this.box1.visible=false;
			data=this.currArg;
			redBagData=[];
			redBagData=data.redbag;
			
			this.contentLabel.text=data.notice==null?"":data.notice;
			curInputText=data.notice;
			this.contentLabel.maxChars=200;
			this.textLabel2.text=Tools.getMsgById("_guild_text18");//"参与活动获得军团分享礼包";
			//getLeaderData();
			setPanel();
			getListData();
			getRechargePro();
			getMSG();
			//trace("===================",ModelManager.instance.modelGuild);
		}

		public function inputBlur():void{
			if(data.notice==null&&this.contentLabel.text==""){
				return;
			}
			if(curInputText==contentLabel.text){
				return;
			}
			curInputText=contentLabel.text;
			if(!FilterManager.instance.isLegalWord(this.contentLabel.text)){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("193005"));
				return;
			}
			NetSocket.instance.send("change_guild_notice",{"notice":contentLabel.text},Handler.create(this,editorCallBack));
		}

		public function editorCallBack(np:NetPackage):void{
			ModelGuild.isEditor=true;
			if(np.receiveData==true){

			}else{
				curInputText="";
			}
		}

		public function setPanel():void{
			this.nameLabel.text=data.name;
			//this.leaderLabel.text=""+leaderData[1];
			this.leaderLabel2.text=Tools.getMsgById("_guild_text10");
			//if(vice_leaderData.length>=1){
			//	var s:String="";
			//	for(var i:int=0;i<vice_leaderData.length;i++){
			//		s+=vice_leaderData[0][1]+"  ";
			//	}
			//	this.leaderLabel2.text=""+s;
			//}
			var uid:String=ModelManager.instance.modelUser.mUID;
			isManager=uid==ModelManager.instance.modelGuild.leader || ModelManager.instance.modelGuild.vice_id.indexOf(uid)!=-1;
			this.leaderLabel.text=ModelManager.instance.modelGuild.u_dict[ModelManager.instance.modelGuild.leader][1];
			if(ModelManager.instance.modelGuild.vice_id.length>=1){
				var s:String="";
				for(var i:int=0;i<ModelManager.instance.modelGuild.vice_id.length;i++){
					s+=ModelManager.instance.modelGuild.u_dict[ModelManager.instance.modelGuild.vice_id[i]][1]+"  ";	
				}
				this.leaderLabel2.text=""+s;
			}
			this.numLabel.text=""+Tools.getDictLength(data.u_dict)+"/"+configData.configure.maxpeople;
			getTotalATK();
			this.boxLabel.text=Tools.getMsgById("_guild_text15",[StringUtil.numberToChinese(1)]);
			this.btnEditor.visible=isManager;
			this.btnChange.gray=!isManager;
			this.contentLabel.mouseEnabled=isManager;
		}

		public function getTotalATK():void{
			var n:Number=0;
			for(var s:String in data.u_dict){
				n+=data.u_dict[s][3];
			}
			this.comPower.setNum(n);
			//this.atkLabel.text=""+n;
		}

		/*
		public function getLeaderData():void{
			isManager=false;
			vice_leaderData=[];
			leaderData=[];
			for(var v:String in data.u_dict)
			{
				var a:Array=data.u_dict[v];
				if(a[0]==1){
					if(v==ModelManager.instance.modelUser.mUID){
						isManager=true;
					}
					var str:String=a[1]==null?v+"":a[1];
					vice_leaderData.push([Number(v),str]);
				}else if(a[0]==0){
					if(v==ModelManager.instance.modelUser.mUID){
						isManager=true;
					}
					var str2:String=a[1]==null?v+"":a[1];
					leaderData.push(Number(v),str2);
				}
			}
		}*/

		public function getListData():void{
			listData=[];
			redBagNum=0;
			if(redBagData.length==0){
				//var o:Object={"title":Tools.getMsgById("_guild_text19"),"content":Tools.getMsgById("_guild_text21"),"btn":"1"};
				var o2:Object={"title":Tools.getMsgById("_guild_text20"),"content":Tools.getMsgById("_guild_text22"),"btn":"2","gotoArr":GotoManager.VIEW_PAY_TEST};
				//listData.push(o);
				listData.push(o2);
				this.list.array=listData;
			}else{
				var now:Number=ConfigServer.getServerTimer();
				var m:Number=48*Tools.oneDayMilli;
				for(var i:int=0;i<redBagData.length;i++){
					var obj:Object=redBagData[i];
					if(obj[4].hasOwnProperty(ModelManager.instance.modelUser.mUID)){
						var n:Number=obj[4][ModelManager.instance.modelUser.mUID];
						
						var t:Number=Tools.getTimeStamp(obj[1]);
						if(n>=1){
							redBagNum+=n;
							if(now<m+t){
								for(var j:int=0;j<n;j++){
									var d:Object={};
									d["index"]=i;
									d["uid"]=obj[0];
									d["uname"]=obj[2];
									d["time"]=obj[1];
									d["item"]=obj[3];
									d["head"]=ModelManager.instance.modelGuild.getMemberHeadById(obj[0]);
									listData.push(d);
								}
							}else{
								//trace("这个过期了");
							}
						}else{
							//trace("第"+i+"领完了");
						}
					}
				}
				if(listData.length==0){
					//trace("全都领完了");
					redBagData=[];
					getListData();
				}
				this.list.array=listData;
			}
			
		}

		public function listRender(cell:Item,index:int):void{
			cell.setData(listData[index]);
			cell.btn0.off(Event.CLICK,this,this.redBagClick);
			cell.btn0.on(Event.CLICK,this,this.redBagClick,[index]);
			if(redBagNum>=20){
				cell.setBtn();
			}
		}



		public function redBagClick(index:int):void{
			if(listData[index].hasOwnProperty("title")){
				if(listData[index].btn==1){
					//trace("周卡");
				}else{
					//trace("精彩活动");
				}
				GotoManager.boundForPanel(listData[index].gotoArr);
			}else{
				var n:Number=redBagNum>=20?-1:listData[index].index;
				NetSocket.instance.send("get_guild_redbag",{"redbag_index":n},new Handler(this,redBagCallBack));
				
			}
		}
		public function redBagCallBack(np:NetPackage):void{
			ModelManager.instance.modelUser.updateData(np.receiveData);
			ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
			redBagData=[];
			redBagData=np.receiveData.guild.redbag;
			getListData();
		}		


		public function changeClick():void{
			if(!isManager){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_guild_tips06"));
				return;
			}
			ViewManager.instance.showView(ConfigClass.VIEW_CREAT_TEAM,"change");
		}

		public function setClick():void{
			if(isOpenBox){
				this.box1.visible=false;
			}else{
				this.box1.visible=true;
				this.box1.x=this.btnSet.x-this.box1.width;
				this.box1.y=this.btnSet.y;
			}
			isOpenBox=!isOpenBox;
		}

		public function editorClick():void{
			this.contentLabel.focus=true;
		}

		public function quitClick():void{
			ViewManager.instance.showAlert(Tools.getMsgById("_guild_text89"),function(index:int):void{
				if(index==0){
					NetSocket.instance.send("guild_exit",{},Handler.create(this,socketCallBack));
					
					}else if(index==1){

					}
			});
			
		}

		public function socketCallBack(np:NetPackage):void{
			if(np.receiveData){
				ModelManager.instance.modelUser.guild_id=null;
				ObjectSingle.getObjectByArr(ConfigClass.VIEW_GUILD_MAIN).event(ModelUser.EVENT_GUILD_QUIT_SUC);
				ModelManager.instance.modelUser.event(ModelUser.EVENT_USER_UPDATE,[{"guild":""},true]);
			}
		}

		public function getRechargePro():void{//军团宝藏
			//curRechargeLv=data.recharge.length;
			curRechargeLv=0;
			totalPayMoney=data.pay_money;
			var m:Number=totalPayMoney;
			var rechargeData:Array=configData.recharge;
			var rechargeItem:Array=rechargeData[curRechargeLv];
			var curMoney:Number=0;
			var maxMoney:Number=0;
			for(var i:int=0;i<rechargeData.length;i++){
				var n:Number=rechargeData[i][1];
				if(i==0){
					if(totalPayMoney<n){
						curRechargeLv=i;
						curMoney=totalPayMoney;
						maxMoney=rechargeData[i][1];
						break;
					}
				}else if(i<rechargeData.length-1){
					if(totalPayMoney<n && totalPayMoney>=rechargeData[i-1][1]){
						curRechargeLv=i;
						curMoney=totalPayMoney-rechargeData[i-1][1];
						maxMoney=rechargeData[i][1]-rechargeData[i-1][1];
						break;
					}
				}else if(i==rechargeData.length-1){
					curRechargeLv=i;
					var maxGap:Number=rechargeData[rechargeData.length-1][1]-rechargeData[rechargeData.length-2][1];
					while(m>=maxGap){
						m-=maxGap;
					}
					curMoney=m;
					maxMoney=maxGap;
				}
			}
			this.pro.value=curMoney/maxMoney;
			this.proText.text=Tools.getMsgById("_guild_text16",[curMoney,maxMoney]);// curMoney+"/"+maxMoney;
			this.boxLabel.text=Tools.getMsgById("_guild_text15",[StringUtil.numberToChinese(curRechargeLv+1)]);
			var item:ModelItem=ModelManager.instance.modelProp.getItemProp(configData.recharge[curRechargeLv][0]);
			//this.rechargeIcon.skin="ui/"+item.icon;
			getRechargeBox();
			
		}

		public function getRechargeBox():void{
			var userRecharge:Array=data.recharge;
			var rechargeNum:Number=0;
			if(userRecharge.length==0){
				this.boxNumLabel.text=Tools.getMsgById("_guild_text17",[rechargeNum]);//"当前数量："+rechargeNum;
				curRechargeIndex =-1;
				//this.rechargeBG.visible=!(curRechargeIndex==-1);
			}
			else{
				var flag:Number=0;
				for(var j:int=userRecharge.length-1;j>=0;j--){
					var a:Array=userRecharge[j];
					var uids:Array=a[3];
					if(uids.indexOf(ModelManager.instance.modelUser.mUID)!=-1){
						rechargeNum+=1;
						if(flag==0){
							curRechargeIndex=j;
						}
						flag=1;
					}
				}
				if(flag==0){
					//trace("已经没得领了");
					curRechargeIndex=-1;
				}
				//ani.visible=!(curRechargeIndex==-1);
				//this.rechargeBG.visible=!(curRechargeIndex==-1);
				this.boxNumLabel.text = Tools.getMsgById("_guild_text17", [rechargeNum]);// "当前数量："+rechargeNum;
			}
			this.comBox.setRewardBox(curRechargeIndex !=-1?1:0);
		}

		public function getMSG():void{
			var msg_arr:Array=[];
			var arr:Array=[];
			
				
			
		
			if(this.data.msg){
				for(var i:int=0;i<this.data.msg.length;i++){
					var obj:Object=this.data.msg[i];
					var o:Object={};
					var ss:String="";
					if(obj.msg_type=="effort"){
						ss=ModelGuild.htmlStr0(obj)+" "+ModelGuild.htmlStr2(obj);
					}else if(obj.msg_type=="attack"){
						ss=ModelGuild.htmlStr0(obj)+" "+ModelGuild.htmlStr1(obj);
					}else if(obj.msg_type=="official"){
						ss=ModelGuild.htmlStr0(obj)+" "+ModelGuild.htmlStr3(obj);
					}else if(obj.msg_type=="mayor"){
						ss=ModelGuild.htmlStr0(obj)+" "+ModelGuild.htmlStr4(obj);
					}else if(obj.msg_type=="team_award"){
						ss=ModelGuild.htmlStr0(obj)+" "+ModelGuild.htmlStr5(obj);
					}
					arr.push(ss);
				}
			}

			if( !this.data.msg || this.data.msg.length<ModelGuild.total_news){
				var s:String=StringUtil.htmlFontColor(Tools.dateFormat(ModelManager.instance.modelGuild.add_time,0), "#70B0FF")+Tools.getMsgById("_guild_text69");
				arr.push(s);				
			}

			var fun:Function=function(html:HTMLDivElement,index:int):void{
				if(!arr[index]){
					len=0;
				}
				html.innerHTML=arr[len];
				len+=1;
				html.width=html.contextWidth;
			}

			var distance:Number=50;
			var label_arr:Array=[this.msgLabel0,this.msgLabel1,this.msgLabel2];
			var len:Number=0;
			for(var j:int=0;j<3;j++){
				var label:HTMLDivElement=label_arr[j];
				label.style.fontSize=20;
				label.style.color="#ffffff";
				label.style.wordWrap=false;
				if(!arr[len]){
					len=0;
				}
				label.innerHTML=arr[len];
				len+=1;
				label.width=label.contextWidth;
			}
			this.msgLabel0.x=0;
			this.msgLabel1.x=this.msgLabel0.x+this.msgLabel0.width+distance;
			this.msgLabel2.x=this.msgLabel1.x+this.msgLabel1.width+distance;

			timer.frameLoop(1,this,function():void{
				msgLabel0.x-=1;
				msgLabel1.x-=1;
				msgLabel2.x-=1;
				if(msgLabel0.x<-msgLabel0.width){
					msgLabel0.x=msgLabel2.x+msgLabel2.width+distance;
					fun(msgLabel0,len);
				}
				if(msgLabel1.x<-msgLabel1.width){
					msgLabel1.x=msgLabel0.x+msgLabel0.width+distance;
					fun(msgLabel1,len);
				}
				if(msgLabel2.x<-msgLabel2.width){
					msgLabel2.x=msgLabel1.x+msgLabel1.width+distance;
					fun(msgLabel2,len);
				}

			});
		}

		public function askClick():void{
			ViewManager.instance.showTipsPanel(Tools.getMsgById(ConfigServer.guild.configure.tips));
		}


		public function rechargeClick():void{
			//trace("click box");
			if(curRechargeIndex==-1){
				return;
			}
			NetSocket.instance.send("get_guild_recharge",{"recharge_index":curRechargeIndex},Handler.create(this,rechargeCallBack));
		}

		public function rechargeCallBack(np:NetPackage):void{
			ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
			ModelManager.instance.modelUser.updateData(np.receiveData);
			data.recharge=np.receiveData.guild.recharge;
			getRechargeBox();
		}

		override public function onRemoved():void{

		}
	}

}



import ui.guild.guildInfoItemUI;
import sg.utils.Tools;

class Item extends guildInfoItemUI{

	public function Item(){

	}

	public function setData(obj:Object):void{

		textLabel2.style.color="#FFFFFF";
		textLabel2.style.fontSize=20;
		if(obj.hasOwnProperty("title")){
			this.textLabel1.text=obj.title;
			this.textLabel2.innerHTML=obj.content;
			this.btn0.label=Tools.getMsgById("_jia0032");
			this.icon0.visible=false;
			this.img0.visible=true;
			if(obj.btn=="1"){
				this.img0.skin="ui/icon_53.png";
			}else{
				this.img0.skin="ui/icon_activity_1.png";
			}
			
			this.btn0.skin="ui/btn_no_s.png";
		}else{
			this.textLabel1.text=Tools.getMsgById("_guild_text23");//"单充奖励";
			this.textLabel2.innerHTML=Tools.getMsgById("_guild_text24",[obj.uname]);// "我军 "+obj.uname+" 发放了单充分享礼包";
			this.btn0.label=Tools.getMsgById("_jia0035");//"领取";
			this.icon0.visible=true;
			this.img0.visible=false;
			this.icon0.setHeroIcon(obj.head);
			this.btn0.skin="ui/btn_yes_s.png";
		}
		if(this.icon0.visible){
			this.textLabel1.text="";
		}
			
	}

	public function setBtn():void{
		this.btn0.label=Tools.getMsgById("_jia0036");//"一键领取";
	}
}