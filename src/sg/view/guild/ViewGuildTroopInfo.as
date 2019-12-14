package sg.view.guild
{
	import sg.fight.FightMain;
	import ui.guild.guildTroopInfoUI;
	import ui.guild.guildTroopinfoItemUI;
	import laya.utils.Handler;
	import laya.events.Event;
	import sg.net.NetSocket;
	import sg.net.NetPackage;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigServer;
	import sg.cfg.ConfigClass;
	import sg.manager.ModelManager;
	import sg.model.ModelGuild;
	import sg.model.ModelHero;
	import sg.utils.Tools;

	/**
	 * ...
	 * @author
	 */
	public class ViewGuildTroopInfo extends guildTroopInfoUI{

		public var curData:Object={};
		public var curLv:Number=0;
		public var listData:Array=[];
		public var isAuto:int=0;
		public var configData:Object={};
		public var isLeader:Boolean=false;//是否是队长
		public var isEnough:Boolean=false;//是否是两个uid
		public var myHeroNum:Number=0;
		public function ViewGuildTroopInfo(){
			this.list.scrollBar.visible=false;
			this.list.itemRender=Item;
			this.list.renderHandler=new Handler(this,listRender);
			//this.text2.text="在异邦来访的战斗中，不会损耗兵力";
			this.btn1.on(Event.CLICK,this,this.chatClick);
			this.btn2.on(Event.CLICK,this,this.joinClick);
			this.btn3.on(Event.CLICK,this,startClick);
			//this.btnCheck.on(Event.CLICK,this,this.checkClick);
			this.text0.text=Tools.getMsgById("_guild_text47");
			this.text1.text = Tools.getMsgById("_guild_text114");
			this.btn2.label = Tools.getMsgById("_guild_text46");//"召集";
			this.btn3.label=Tools.getMsgById("_guild_text43");//"召集";
		}

		override public function onAdded():void{
			this.comTitle.setViewTitle(Tools.getMsgById("_guild_text115"));
			ModelManager.instance.modelGuild.on(ModelGuild.EVENT_UPDATE_ALIEN_TROOP_INFO,this,eventUpdatePanel);
			configData=ConfigServer.guild.alien;
			//text2.text="";
			setData();	
			
		}


		public function eventUpdatePanel(np:NetPackage,index:int):void{
			this.currArg=[ModelManager.instance.modelGuild.alien,index];
			setData();
		}

		public function setData():void{
			curData=ModelManager.instance.modelGuild.alien[this.currArg[1]];
			if(curData["team"][0]["troop"].length==0){
				//ViewManager.instance.showTipsTxt("已被解散");
				ViewManager.instance.closePanel();
				return;
			}
			curLv=this.currArg[1];
			setCallBtn();
			isLeader=curData["team"][0]["troop"][0].uid==ModelManager.instance.modelUser.mUID;
			this.numLabel.text=curData["team"][0]["troop"].length+"/"+ModelManager.instance.modelGuild.alien_max_troops;

			isEnough=false;
			var arr:Array=curData["team"][0]["troop"];
			var tempId:String="";
			for(var i:int=0;i<arr.length;i++){
				if(tempId==""){
					tempId=arr[i].uid;
				}else{
					if(tempId!=arr[i].uid){
						isEnough=true;
						break;
					}
				}
			}
			
			listData=curData["team"][0]["troop"];
			isAuto=curData["auto"];
			this.list.array=listData;
			getMyHeroNum();
			setTextLabel();
			setCheckBtn();
			btn3.visible=btn1.visible=isLeader;			
		}

		public function setCallBtn():void{
			if(ModelManager.instance.modelGuild.getAlienLastTime(curLv)==0){
				this.btn1.label=Tools.getMsgById("_guild_text45");//"召集";
				this.btn1.gray=false;
			}else{
				time_tick();
				timer.loop(1000,this,time_tick);
				
			}
		}

		public function getMyHeroNum():void{
			myHeroNum=0;
			for(var i:int=0;i<listData.length;i++){
				var o:Object=listData[i];
				if(o.uid==ModelManager.instance.modelUser.mUID){
					myHeroNum+=1;
				}
			}
			//this.btn2.visible=!(myHeroNum==2);
			this.btn2.gray=(myHeroNum==ModelManager.instance.modelGuild.alien_max_hero);
		}

		public function setTextLabel():void{
			//this.text1.text="集结中"+listData.length+"/8";
		}

		public function setCheckBtn():void{
			//btnCheck.label=isAuto+"";
		}

		public function listRender(cell:Item,index:int):void{
			var o:Object=listData[index];
			cell.setData(o,index);

			cell.btn0.on(Event.CLICK,this,this.btnClick,[index]);
			var s:String=ModelManager.instance.modelUser.mUID;
			cell.btn0.visible=true;
			if(isLeader){
				if(index==0){
					cell.btn0.label=Tools.getMsgById("_guild_text48");//"解散";
				}else{
					if(listData[index].uid==s){
						cell.btn0.label=Tools.getMsgById("_guild_text50");//"撤军";
					}else{
						cell.btn0.label=Tools.getMsgById("_guild_text49");//"踢出";
					}
					
				}
			}else{
				if(listData[index].uid==s){
					cell.btn0.label=Tools.getMsgById("_guild_text50");
				}else{
					cell.btn0.visible=false;
				}
			}
		}

		public function checkClick():void{
			var sendData:Object={};
			//.selected=!btnCheck.selected;
			//sendData["auto"]=btnCheck.selected?0:1;
			//sendData["alien_id"]=curLv;
			//NetSocket.instance.send("change_alien_auto",sendData,Handler.create(this,this.checkCallBack));
		}

		public function checkCallBack(np:NetPackage):void{
			isAuto=isAuto==0?1:0;
			curData["auto"]=isAuto;
			setCheckBtn();
		}

		public function startClick():void{
			if(!isLeader){
				return;
			}
			if(!isEnough){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_guild_tips04",[ModelManager.instance.modelGuild.alien_max_hero]));
				return;
			}
			var sendData:Object={};
			sendData["alien_id"]=curLv;
			NetSocket.instance.send("begin_alien_fight",sendData,Handler.create(this,startCallBack));
		}

		public function startCallBack(np:NetPackage):void{
			var receiveData:* = np.receiveData;
			//异族入侵开始战斗
			FightMain.startBattle(receiveData, this, this.outFight, [receiveData]);
			ModelManager.instance.modelUser.updateData(np.receiveData);
			ViewManager.instance.closePanel();
			ModelManager.instance.modelGuild.event(ModelGuild.EVENT_ALIEN_MSG);
		}
		private function outFight(receiveData:*):void{

		}

		public function btnClick(index:int):void{
			var s:String=ModelManager.instance.modelUser.mUID;
			if(listData[0].uid==s){//队长
				if(index==0 || listData[index].uid==s){//解散或撤军
					quitTeam(index);
				}else{//踢人
					outTeam(index);
				}
			}else{//非队长
				if(listData[index].uid==s){//撤军
					quitTeam(index);
				}
			}
			
		}

		public function outTeam(index:int):void{//踢人
			var sendData:Object={};
			sendData["troop_index"]=index;
			sendData["alien_id"]=curLv;
			NetSocket.instance.send("guild_alien_expel",sendData,Handler.create(this,outCallBack));
		}

		public function quitTeam(index:int):void{//撤军
			var sendData:Object={};
			sendData["troop_index"]=index;
			sendData["alien_id"]=curLv;
			NetSocket.instance.send("guild_alien_quit",sendData,Handler.create(this,outCallBack));
		}

		public function chatClick():void{
			if(ModelManager.instance.modelGuild.getAlienLastTime(curLv)!=0){
				return;
			}
			var sendData:Object={};
			sendData["icon"]=2;
			sendData["type"]="guild_call";
			sendData["key"]=curLv;
			sendData["msg"]=ModelHero.getHeroName(curData["team"][1]["troop"][0]["hid"]);
			NetSocket.instance.send("chat",sendData,new Handler(this,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				ModelManager.instance.modelChat.acceptMSG(np.receiveData.chat);
				ModelManager.instance.modelGuild.alienCallCD[curLv+""]=ConfigServer.getServerTimer();
				setCallBtn();
			}));
		}

		public function joinClick():void{
			if(listData.length>=configData.troops){
				return;
			}
			if(myHeroNum==ModelManager.instance.modelGuild.alien_max_hero){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_guild_text82",[ModelManager.instance.modelGuild.alien_max_hero]));// "最多加入"+ModelManager.instance.modelGuild.alien_max_hero+"支队伍");
				return;
			}
			ViewManager.instance.showView(ConfigClass.VIEW_GUILD_TROOP,this.currArg);
		}

		public function outCallBack(np:NetPackage):void{
			ModelManager.instance.modelUser.updateData(np.receiveData);
			if(np.receiveData.guild.alien[this.currArg[1]]["team"][0]["troop"].length==0){//解散
				ViewManager.instance.closePanel();
			}else{
				this.currArg=[np.receiveData,curLv];
				setData();
			}
			ModelManager.instance.modelGuild.event(ModelGuild.EVENT_UPDATE_ALIEN,null);	
		}

		public function time_tick():void{
			if(ModelManager.instance.modelGuild.getAlienLastTime(curLv)==0){
				timer.clear(this,time_tick);
				this.btn1.label=Tools.getMsgById("_guild_text45");
				this.btn1.gray=false;
			}else{
				this.btn1.label=ModelManager.instance.modelGuild.getAlienLastTime(curLv)+Tools.getMsgById("_public112");
				this.btn1.gray=true;
			}

		}

		override public function onRemoved():void{
			ModelManager.instance.modelGuild.off(ModelGuild.EVENT_UPDATE_ALIEN_TROOP_INFO,this,eventUpdatePanel);
		}
	}

}

import ui.guild.guildTroopinfoItemUI;
import sg.model.ModelHero;
import sg.manager.ModelManager;
import sg.utils.Tools;
import sg.cfg.ConfigServer;
import sg.model.ModelPrepare;

class Item extends guildTroopinfoItemUI{
	public function Item(){

	}

	public function setData(obj:*,index:int):void{
		var hmd:ModelHero;
		var pmd:ModelPrepare;
		if(obj.uid+""==ModelManager.instance.modelUser.mUID){
			hmd=ModelManager.instance.modelGame.getModelHero(obj.hid);
			pmd=hmd.getPrepare();
		}else{
			hmd=new ModelHero(true);
			//hmd.initData(obj.hid,obj);
			hmd.setData(obj);
			pmd=hmd.getPrepare(true,obj);
		}
		
		this.heroIcon.setHeroIcon(hmd.id,true,hmd.getStarGradeColor());
		this.uNameLabel.text=obj.uname;
		this.hNameLabel.text = hmd.getName();
		this.comPower.setNum(hmd.getPower());
		//this.atkLabel.text=hmd.getPower()+"";
		this.armyLabel.text=hmd.getArmyHpm(0,pmd)+hmd.getArmyHpm(1,pmd) +"";
		this.pro.value=1;
		this.comType.setHeroType(hmd.getType());
		
		if(index==0){
			this.indexLabel.text=Tools.getMsgById("_guild_text83");//"部队主帅";
		//}else if(obj.uid==ModelManager.instance.modelUser.mUID){
			//this.indexLabel.text="本部";
		}else{
			this.indexLabel.text=Tools.getMsgById("_guild_text84",[index+1]);// "第"+(index+1)+"阵";
		}
		
	}
}