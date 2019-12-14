package sg.view.guild
{
	import sg.fight.FightMain;
	import ui.guild.guildAlienUI;
	import ui.guild.guildAlienItemUI;
	import laya.utils.Handler;
	import laya.ui.Box;
	import laya.ui.Label;
	import laya.ui.Image;
	import sg.cfg.ConfigServer;
	import sg.utils.Tools;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import sg.net.NetPackage;
	import sg.net.NetSocket;
	import laya.events.Event;
	import sg.model.ModelGuild;
	import sg.manager.ModelManager;
	import sg.model.ModelItem;
	import ui.bag.bagItemUI;
	import sg.model.ModelHero;
	import sg.utils.StringUtil;
	import sg.model.ModelGame;

	/**
	 * ...
	 * @author
	 */
	public class ViewGuildAlien extends guildAlienUI{
		public var config_alien:Object={};
		public var boxData:Array=[];
		public var time_arr:Array=[];
		public var box_arr:Array=[];
		public var curData:Object={};
		public var refresh_time:Number=0;
		public var listData:Array=[];
		public var alien_log:Object={};
		public var log_time_obj:Object={};
		public var curIndex:int=0;
		private var isLeader:Boolean=false;
		private var my_join_length:int=0;
		private var team_length:int=0;
		private var user_arr:Array=[];
		private var lock_num:int=0;
			

		public function ViewGuildAlien(){
			this.list.scrollBar.visible=false;
			this.list.itemRender=Item;
			this.list.renderHandler=new Handler(this,listRender);
			this.list.selectHandler=new Handler(this,selectRender);
			this.box1.on(Event.CLICK,this,boxClick,[0]);
			this.box2.on(Event.CLICK,this,boxClick,[1]);
			this.box3.on(Event.CLICK,this,boxClick,[2]);
			this.btnJoin.on(Event.CLICK,this,this.joinCLick);
			this.btnTeam.on(Event.CLICK,this,this.teamClick);
			this.btnSelet2.on(Event.CLICK,this,autoClick);

			this.rewardList.renderHandler=new Handler(this,rewardListRender);
			this.rewardList.scrollBar.visible=false;

			this.weakList.renderHandler=new Handler(this,weakListRender);

			ModelManager.instance.modelGuild.on(ModelGuild.EVENT_ALIEN_MSG,this,eventCallBack);
			ModelManager.instance.modelGuild.on(ModelGuild.EVENT_UPDATE_ALIEN,this,eventUpDatePanel);
			
			
			
		}



		override public function onAdded():void{
			this.text0.text=Tools.getMsgById("_guild_text37");
			this.text1.text=Tools.getMsgById("_guild_text85");
			this.text2.text=Tools.getMsgById("_guild_text41");
			this.text3.text=Tools.getMsgById("_guild_text86");
			

			this.autoLabel.text=Tools.getMsgById("_guild_text40");
			this.btnTeam.label=Tools.getMsgById("_guild_text42");
			this.btnSelet.mouseEnabled=false;
			box_arr=[];
			box_arr=[box1,box2,box3];

			config_alien=ConfigServer.guild.alien;
			this.list.selectedIndex=0;
			setData();
			//ViewManager.instance.showView(ConfigClass.VIEW_GUILD_TROOP);
		}

		public function eventCallBack():void{
			setData();
			if(curIndex!=-1){
				ModelManager.instance.modelGuild.event(ModelGuild.EVENT_UPDATE_ALIEN_TROOP_INFO,[null,curIndex]);
			}
			//NetSocket.instance.send("get_guild_alien",{},Handler.create(this,this.eventCallSocket));
		}
		public function eventCallSocket(np:NetPackage):void{
			//ModelManager.instance.modelUser.updateData(np.receiveData);
			//this.currArg=np.receiveData;
		}

		public function eventUpDatePanel(d:Object):void{
			//this.currArg=d;
			setData();
		}

		public function setBox():void{
			time_arr=[];
			var boxData:Array=ModelManager.instance.modelUser.alien_reward;
			var now:Number=ConfigServer.getServerTimer();
			for(var i:int=0;i<3;i++)
			{
				var img:bagItemUI=box_arr[i].getChildByName("comIcon") as bagItemUI;
				if(i<boxData.length){
					var o:Object=boxData[i];
					var it:ModelItem=ModelManager.instance.modelProp.getItemProp(o[0]);
					//img.setData(it.icon,it.ratity,it.name,"",it.type);
					img.setData(it.id);
					img.visible=true;
					var n:Number=Tools.getTimeStamp(o[1]);
					if(now>n){
						time_arr.push(0);
					}else{
						time_arr.push(Tools.getTimeStamp(o[1]));
					}

				}else{
					//img.setData("",0,"","");
					img.setIcon("");
					img.setName("");
					img.mCanClick=false;
					time_arr.push(-1);
				}
			}
			timer.clear(this,time_tick);
			time_tick();
			timer.loop(1000,this,time_tick);
		}


		public function setData():void{
			//curData=this.currArg;
			curData=ModelManager.instance.modelGuild;
			refresh_time=Tools.getTimeStamp(curData.alien_refresh_time);
			
			getAlienLog();
			getListData();
			setBox();
			//trace(curData);
			if(refresh_time<ConfigServer.getServerTimer()){
				trace("error  error  error===guildalien error",curData.alien_refresh_time);
				this.timerLabel.text="";
				timer.clear(this,refresh_time_tick);
			}else{
				refresh_time_tick();
				timer.loop(1000,this,this.refresh_time_tick);
			}
			
		}

		public function refresh_time_tick():void{
			var now:Number=ConfigServer.getServerTimer();
			if(refresh_time-now>0){
				this.timerLabel.text=Tools.getTimeStyle(refresh_time-now);
			}else{
				this.timerLabel.text="";
				timer.clear(this,refresh_time_tick);
				NetSocket.instance.send("get_guild_alien",{},Handler.create(this,function(np:NetPackage):void{
					ModelManager.instance.modelGuild.updateData(np.receiveData.guild);
					ViewManager.instance.closePanel();
					setData();
				}));
				//eventCallBack();
			}
		}

		public function getListData():void{
			listData=[];
			listData=(curData["alien"] as Array).concat();
			if(listData.length<ConfigServer.guild.alien.instance.length){
				listData.push({"lock":listData.length});
			}
			this.list.array=listData;
			this.list.scrollBar.value=this.list.scrollBar.max;
			itemClick((curData["alien"] as Array).length-1);
		}

		public function listRender(cell:Item,index:int):void{
			cell.setData(listData[index],index);
			if(listData[index].team!=null && listData[index]["team"][0]["troop"].length==0){
				var now:Number=ConfigServer.getServerTimer();
				if(log_time_obj.hasOwnProperty(index+"")){
					var n:Number=log_time_obj[index+""];
					//trace(now-n);
					if(now-n<30000){
						cell.setFightIcon(true);
						if(index==this.list.selectedIndex){
							ViewManager.instance.closePanel();
						} 
						timer.once(30000-(now-n),this,time_once_fun,[index],false);
					}
				}
			}
			cell.setSelection(curIndex==index);
			cell.off(Event.CLICK,this,this.itemClick);
			cell.on(Event.CLICK,this,this.itemClick,[index]);
			
		}

		public function selectRender(index:int):void{
			if(index>-1){
				curIndex=this.list.selectedIndex;
			}
		}

		public function getAlienLog():void{
			alien_log={};
			log_time_obj={};
			var now:Number=ConfigServer.getServerTimer();
			if(curData.alien_log!=null){
				alien_log=curData.alien_log;
				for(var s:String in alien_log)
				{	
					var n:Number=Tools.getTimeStamp(alien_log[s].fight_time);
					log_time_obj[s]=n;
				}
			}
		}

		public function time_once_fun(index:int):void{
			if(this.list.getCell(index)){
				(this.list.getCell(index) as Item).setFightIcon(false);
				if(index==curIndex){
					setUI();
				}
			}
			
		}

		public function time_tick():void{
			var now:Number=ConfigServer.getServerTimer();
			for(var i:int=0;i<3;i++){
				var img:bagItemUI=(box_arr[i] as Box).getChildByName("comIcon") as bagItemUI;
				img.mCanClick=true;
				var l:Label=(box_arr[i] as Box).getChildByName("boxText1") as Label;
				//var l2:Label=(box_arr[i] as Box).getChildByName("boxText2") as Label;
				if(time_arr[i]==0){
					ModelGame.redCheckOnce(img,true,[img.width-30,10]);
					l.text = Tools.getMsgById("_guild_text54");//"可打开";
					l.color = '#33FF00';
					//l2.text="";
					img.mCanClick=false;
				}else if(time_arr[i]==-1){
					ModelGame.redCheckOnce(img,false,[img.width-30,10]);
					l.text = Tools.getMsgById("_guild_text53");//"空闲";
					l.color = '#cadfff';
					//l2.text="";
					//img.setData("",0,"","");
					img.setIcon("");
					img.setName("");
					img.mCanClick=false;
				}else{
					if(now<time_arr[i]){
						ModelGame.redCheckOnce(img,false,[img.width-30,10]);
						l.text=Tools.getTimeStyle(time_arr[i]-now,3);
						//l2.text=Tools.getMsgById("_guild_text65");//"开启时间:";
					}else{
						ModelGame.redCheckOnce(img,true,[img.width-30,10]);
						l.text=Tools.getMsgById("_guild_text54");//"可打开";
						//l2.text="";
						time_arr[i]=0;
						img.mCanClick=false;
					}
				}
			}
		}


		public function boxClick(index:int):void{
			var n:Number=0;
			if(index==1){
				n=1;
				if(time_arr[0]==-1){
					n=0;
				}
			}else if(index==2){
				n=2;
				if(time_arr[0]==-1 && time_arr[1]==-1){
					n=0;
				}
				if(time_arr[0]!=-1 && time_arr[1]==-1){
					n=1;
				}
				if(time_arr[0]==-1 && time_arr[1]!=-1){
					n=1;
				}

			}
			if(time_arr[index]==0){
				NetSocket.instance.send("get_alien_reward",{"index":n},Handler.create(this,socketCallBack,[index]));
			}else{

			}
		}

		public function socketCallBack(index:int,np:NetPackage):void{
			time_arr[index]=-1;
			ModelManager.instance.modelUser.updateData(np.receiveData);
			ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
			ModelManager.instance.modelGuild.event(ModelGuild.EVENT_UPDATE_RED);
		}

		

		public function itemClick(index:int):void{
			if(index<0){
				return;
			}
			if(this.list.selectedIndex!=index){
				this.list.selectedIndex=index;
			}
			
			/*
			var now:Number=ConfigServer.getServerTimer();
			if(alien_log && alien_log.hasOwnProperty(index)){
				var n:Number=Tools.getTimeStamp(alien_log[index].fight_time);
				//trace(now-n);
				if(now>n+30000){
					goToTeam(index);
				}else{
					goTofight();
				}
			}else{
				goToTeam(index);
			}*/

			var arr:Array=curData["alien"][index]["team"][0]["troop"];
			lock_num=curData["alien"][index]["auto"];
			
			team_length=arr.length;
			my_join_length=0;
			user_arr=[];
			isLeader=arr.length!=0&&arr[0].uid==ModelManager.instance.modelUser.mUID;
			for(var i:int=0;i<arr.length;i++){
				var uid:Object=arr[i].uid;
				if(user_arr.indexOf(uid)==-1){
					user_arr.push(uid);
				}
				if(uid==ModelManager.instance.modelUser.mUID){
					my_join_length+=1;
				}
			}
			setUI();
			this.btnSelet.selected=(lock_num==1);
			this.comHero.setHeroIcon(curData["alien"][index]["team"][1]["troop"][0].hid,false);
			setHTMLLabel(index);
		}


		public function setHTMLLabel(index:int):void{
			this.htmlLabel.style.fontSize=16;
			this.htmlLabel.style.wordWrap=false;
			if(team_length==0){
				this.htmlLabel.innerHTML=StringUtil.htmlFontColor(Tools.getMsgById("_guild_text38",[ModelManager.instance.modelGuild.alien_max_hero]),"#fff998");
			}else{
				this.htmlLabel.style.color="#ffffff";
				var s1:String=curData["alien"][index]["team"][0]["troop"][0].uname;
				s1=StringUtil.htmlFontColor(s1,"#FFA050");
				var s2:String=StringUtil.htmlFontColor(team_length+"","#10F010");
				var s:String=Tools.getMsgById("193003",[s1,s2,ModelManager.instance.modelGuild.alien_max_troops+""]);
				this.htmlLabel.innerHTML=s;
			}
			
		}

		public function setUI():void{
			//btnSelet.mouseEnabled=isLeader;
			var s:String="";
			//this.autoLabel.visible=this.btnSelet.visible=true;
			this.boxCheck.visible=isLeader;
			if(isLeader){
				s=Tools.getMsgById("_guild_text43");//"开始战斗";
			}else if(team_length==0){
				s=Tools.getMsgById("_guild_text44");//"创建队伍";
				//this.autoLabel.visible=this.btnSelet.visible=false;
			}else if(my_join_length<=config_alien.playertroops){
				s=Tools.getMsgById("_guild_text57");//"加入队伍";
			} 
			var now:Number=ConfigServer.getServerTimer();
			if(alien_log && alien_log.hasOwnProperty(curIndex)){
				var n:Number=Tools.getTimeStamp(alien_log[curIndex].fight_time);
				if(now<=n+30000){
					s=Tools.getMsgById("_guild_text66");//"查看战斗";
				}
			}
			this.btnJoin.label=s;
			var o:Object=curData["alien"][curIndex];
			this.btnTeam.visible=o["team"][0]["troop"].length!=0;
			var reward:Array=config_alien.instance[curIndex].reward;
			this.rewardList.array=reward;
			//for(var i:int=0;i<4;i++){
			//	var _box:bagItemUI=(this.box0.getChildByName("box0"+(i+1)) as Box).getChildByName("comBox") as bagItemUI;
			//	var it:ModelItem=ModelManager.instance.modelProp.getItemProp(reward[i][0]);
			//	_box.setData(it.icon,it.ratity,"","",it.type);
			//}
			this.heroLv.setNum(curIndex+1);
			//this.indexLabel.text=curIndex+1+"";
			var hmd:ModelHero=new ModelHero(true);
			hmd.setData(o["team"][1]["troop"][0]);
			this.nameLabel.text=hmd.getName();
			//this.atkLabel.text=hmd.getPower(hmd.getPrepare(false,o["team"][1]["troop"][0]))+"";
			this.comPower.setNum(hmd.getPower(hmd.getPrepare(false,o["team"][1]["troop"][0]))); 


			var weak_arr:Array=[];
			var weak:Array=o["team"][1]["troop"][0].weak;
			if(weak){
				var config_weak:Array=config_alien.weak.type;
				for(var i:int=0;i<weak.length;i++){
					var arr:Array=weak[i];
					for(var j:int=0;j<config_weak.length;j++){
						var a:Array=config_weak[j][0];
						if(a[0]==arr[0] && a[1]==arr[1]){
							weak_arr.push({"index":j,"icon":a[2],"text":a[3],"num":arr[2]});
							break;
						}
					}
				}
			}

			this.weakList.array=weak_arr;

		}

		public function rewardListRender(cell:bagItemUI,index:int):void{
			var it:ModelItem=ModelManager.instance.modelProp.getItemProp(this.rewardList.array[index][0]);
			cell.setData(it.id,1);

		}


		public function weakListRender(cell:Box,index:int):void{
			var obj:Object=this.weakList.array[index];
			var _img:Image=cell.getChildByName("img") as Image;
			var _label0:Label=cell.getChildByName("weak0") as Label;
			var _label1:Label=cell.getChildByName("weak1") as Label;
			
			_img.skin="icon/"+obj.icon+".png";
			_label0.text=Tools.getMsgById(obj.text);
			_label1.text=Tools.getMsgById("500081",[ModelHero.shogun_name[obj.index],StringUtil.numberToPercent(obj.num)]);
		}

		public function joinCLick():void{
			var now:Number=ConfigServer.getServerTimer();
			var b:Boolean=false;
			if(alien_log && alien_log.hasOwnProperty(curIndex)){
				var n:Number=Tools.getTimeStamp(alien_log[curIndex].fight_time);
				//trace(now-n);
				if(now<=n+30000){
					b=true;	
				}
			}

			if(b){
				goTofight();
			}else{
				if(isLeader){
					startFight();
				}else if(team_length==0){
					ViewManager.instance.showView(ConfigClass.VIEW_GUILD_TROOP,[null,curIndex]);
				}else if(my_join_length<config_alien.playertroops){
					ViewManager.instance.showView(ConfigClass.VIEW_GUILD_TROOP,[null,curIndex]);//teamClick();
				}else if(!isLeader && my_join_length==config_alien.playertroops){
					teamClick();
				} 
			}
		}

		public function teamClick():void{
			ViewManager.instance.showView(ConfigClass.VIEW_GUILD_TROOP_INFO,[null,curIndex]);
		}

		public function autoClick():void{
			if(!isLeader){
				return;
			}
			var sendData:Object={};
			sendData["alien_id"]=curIndex;
			sendData["auto"]=lock_num==0?1:0;
			NetSocket.instance.send("change_alien_auto",sendData,new Handler(this,function(np:NetPackage):void{
				lock_num=lock_num==0?1:0;
				this.btnSelet.selected=(lock_num==1);
				//setUI();
			}));
		}

		
		public function startFight():void{
			if(!isLeader){
				return;
			}
			if(user_arr.length<2){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_guild_tips04",[ModelManager.instance.modelGuild.alien_max_hero]));
				return;
			}
			var sendData:Object={};
			sendData["alien_id"]=curIndex;
			NetSocket.instance.send("begin_alien_fight",sendData,Handler.create(this,startCallBack));
		}

		public function startCallBack(np:NetPackage):void{
			var receiveData:* = np.receiveData;
			//异族入侵开始战斗
			FightMain.startBattle(receiveData, this, this.outFight, [receiveData]);
			ModelManager.instance.modelUser.updateData(np.receiveData);
			NetSocket.instance.send("get_guild_alien",{},Handler.create(this,function(pp:NetPackage):void{
				ModelManager.instance.modelUser.updateData(pp.receiveData);
				ModelManager.instance.modelGuild.event(ModelGuild.EVENT_ALIEN_MSG);	
			}));
		}
		private function outFight(receiveData:*):void{

		}


		public function goTofight():void{
			//trace("进入战斗场景");
			var obj:Object=ModelManager.instance.modelGuild.alien_log[this.list.selectedIndex];
			if(ModelManager.instance.modelGuild.alien_log[this.list.selectedIndex]){
				FightMain.startBattle(obj, this, this.outFight, [obj]);
			}
		}

		public function goToTeam(index:int):void{
			var o:Object=listData[index]["team"][0];
			if(o.troop.length!=0){
				ViewManager.instance.showView(ConfigClass.VIEW_GUILD_TROOP_INFO,[null,index]);
			}else{
				ViewManager.instance.showView(ConfigClass.VIEW_GUILD_TROOP,[null,index]);
			}
			//curIndex=index;
		}


		override public function onRemoved():void{
			this.list.selectedIndex=-1;
			timer.clear(this,time_tick);
			timer.clear(this,refresh_time_tick);
		}
	}

}

import ui.guild.guildAlienItemUI;
import sg.model.ModelItem;
import sg.manager.ModelManager;
import sg.utils.Tools;
import sg.cfg.ConfigServer;

class Item extends guildAlienItemUI{

	public function Item(){

	}

	public function setData(obj:Object,index:int):void{
		this.img1.visible=this.img2.visible=false;
		this.gray=false;
		this.boxLabel.text="";
		//this.numLabel.text="";
		if(obj.hasOwnProperty("lock")){
		//	atkLabel.text="击败"+obj.lock+"来使后可解锁";
			this.mouseEnabled=false;
			this.gray=true;
			this.img2.visible=true;
			this.comHero.setHeroIcon("hero000");
			this.boxLabel.text=Tools.getMsgById("_guild_text55",[obj.lock]);// "击败"+obj.lock+"来使后可解锁";
		}else{
			this.mouseEnabled=true;
			this.gray=false;
			//var it:ModelItem=ModelManager.instance.modelProp.getItemProp(boxId);
			if(obj.team[0].troop.length!=0){
				this.img1.visible=true;
				this.img1.skin="ui/icon_jiaobiao05.png";
				//this.numLabel.text="集结中"+obj.team[0].troop.length;
			}else{
				//this.numLabel.text="";
			}
			var hid:String=obj["team"][1]["troop"][0]["hid"];
			this.comHero.setHeroIcon(hid);
			this.boxLabel.text=Tools.getMsgById(ConfigServer.hero[hid].name);
		}
		this.heroLv.setNum(index+1);
		//this.indexLabel.text=index+1+"";
	}

	public function setFightIcon(b:Boolean):void{
		this.img1.visible=b;
		this.img1.skin=b?"ui/icon_jiaobiao19.png":"ui/icon_jiaobiao05.png";
	}

	public function setSelection(b:Boolean):void{
		this.imgSelect.visible=b;
	}

}