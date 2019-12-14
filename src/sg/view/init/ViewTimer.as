package sg.view.init
{
	import ui.init.viewTimerUI;
	import ui.init.itemTimerUI;
	import sg.manager.ModelManager;
	import sg.model.ModelBuiding;
	import sg.model.ModelHero;
	import sg.utils.Tools;
	import sg.cfg.ConfigServer;
	import sg.model.ModelScience;
	import sg.activities.model.ModelOnlineReward;
	import sg.boundFor.GotoManager;
	import sg.manager.AssetsManager;
	import sg.utils.StringUtil;

	/**
	 * ...
	 * @author
	 */
	public class ViewTimer extends viewTimerUI{

		public var listData:Array=[];
		public var buildingData:Object={};//建筑队列
		public var armyData:Object={};//部队队列
		public var sienceData:Object={};//科技队列
		public var wharfData:Object={};//码头装卸
		public var guildData:Object={};//军团宝箱
		public var now:Number=0;
		public var army_icon_arr:Array=["home_20.png","home_23.png","home_21.png","home_22.png"];
		public function ViewTimer(){
			
		}

		override public function onAdded():void{
			this.comTitle.setViewTitle(Tools.getMsgById("_public204"));
			setData();
			setUI();
			Laya.timer.loop(1000,this,time_tick);
		}

		public function setData():void{
			now=ConfigServer.getServerTimer();
			getBuildingData();
			getarmyData();
			getSienceData();
			getWharfData();
			//getGuildData();

			listData=[];
			listData.push(buildingData);
			listData.push(armyData);
			listData.push(sienceData);
			listData.push(wharfData);
			//listData.push(guildData);
		
			//trace(buildingData);
			//trace(armyData);
			//trace(sienceData);
			//trace(wharfData);
			//trace(guildData);
			
		}

		public function getBuildingData():void{
			var arr:Array = ModelManager.instance.modelInside.mBuildingArr;
			var maxLenth:Number=ModelManager.instance.modelInside.buildingUpgradeMax();//最大队列数
			buildingData={};
			var a:Array=[];			
			var upBMD:ModelBuiding = ModelBuiding.checkUpgradeBuild();
			for(var i:int=0;i<maxLenth;i++){
				var o:Object={};
				o["name"]=Tools.getMsgById("_view_timer01",[""]);//"队列"+i;
				o["skin"]=AssetsManager.getAssetsUI("home_03.png");
				o["text1"] = Tools.getMsgById("_public161");//"空闲中";
				o["color1"] = '#00FF00';
				o["max"]=0;
				o["time"]=0;
				o["gotoArr"]=upBMD==null?Tools.getMsgById("_public184"):{"type":2,"buildingID":upBMD.id};
				
				if(i<arr.length){
					var mb:ModelBuiding=arr[i];				
					o["time"]=mb.getLastCDtimer();
					o["max"]=mb.getLvCD(mb.lv)*Tools.oneMillis;
					o["text2"]=Tools.getMsgById("_view_timer02",[mb.getName()]);//"升级"+mb.getName();
				}
				else{
					o["text2"]="";
				}
				o["btn"]=o["max"]==0;
				a.push(o);
			}
			buildingData["data"]={"icon":AssetsManager.getAssetsUI("home_03.png"),"title":Tools.getMsgById("_view_timer03")};
			buildingData["arr"]=a;
		}


		public function getarmyData():void{
			var a:Array=ModelBuiding.army_type_building;
			armyData={};
			var aa:Array=[];
			for(var i:int=0;i<a.length;i++){
				var bim:ModelBuiding=ModelManager.instance.modelInside.getBuildingModel(a[i]);
				var n:Number=bim.getArmyNum();//兵营库存
				var m:Number=bim.getArmyNumMax(bim.lv);
				var nn:Number=bim.getMakingArmyLastTimer();//造兵cd
				var nnn:Number=bim.getArmyMakingNum();//
				var o:Object={};
				o["name"]=bim.getName();
				o["skin"]=AssetsManager.getAssetsUI(army_icon_arr[i]);//ModelHero.army_icon_ui[i];
				o["text1"]="";
				o["text2"]="";
				o["time"]=0;
				o["max"]=bim.getArmyMakeCDms(bim.getArmyMakingNum());
				o["gotoArr"]={"type":2,"buildingID":bim.id};
				o["btn"]=nn<=0;
				if(nn>0){
					o["time"]=nn;//有 训练兵 需要秒 cd
					o["text2"]=Tools.getMsgById("_view_timer05");//"训练中";
					
				}else{
					if(nnn>0){
						o["text1"]=Tools.getMsgById("_view_timer06");//"训练完成";//准备收获
					}else{
						var str:String = StringUtil.fillSpace(n.toString(), 7) + ' / ' + StringUtil.fillSpace(m.toString(), 7, false);
						o["text1"] = Tools.getMsgById("_public22", [""]) + str;// "库存："+n+"/"+m;//可以训练,兵营类正常模式
					}
				}
				aa.push(o);
				armyData["data"]={"icon":AssetsManager.getAssetsUI("home_46.png"),"title":Tools.getMsgById("_view_timer04")};// "部队"};
				armyData["arr"]=aa;

			}
		}

		public function getSienceData():void{
			sienceData={};
			var ms:ModelScience=ModelScience.getCDingModel();
			var o:Object={};
			o["name"]=Tools.getMsgById("_view_timer01",[""]);//"队列";
			o["skin"]=AssetsManager.getAssetsUI("home_07.png");
			o["text1"] = Tools.getMsgById("_public161");//"空闲中";
			o["color1"] = '#00FF00';
			o["max"]=ms?ms.getLvCD(ms.getLv()+1)*1000:0;
			o["time"]=ms?ms.getLastCDtimer():0;
			o["text2"]=ms?Tools.getMsgById("_view_timer07",[ms.getName()]):"";//"研究“"+ ms.getName()+"”":"";
			var s:String=Tools.getMsgById("_public24");//"科技";
			var blv:Number=ModelManager.instance.modelInside.getBuilding003().lv;
			if(blv==0){
				s=Tools.getMsgById("60002")//"军府";
				o["text1"] = Tools.getMsgById("_view_timer08");//"需要解锁";
				o["color1"] = '#00FF00';
				o["btn"]=true;
			}
			o["gotoArr"]={"type":2,"buildingID":ModelManager.instance.modelInside.getBuilding003().id};
			sienceData["data"]={"icon":AssetsManager.getAssetsUI("home_07.png"),"title":s};
			sienceData["arr"]=[o];
		}

		public function getWharfData():void{
			wharfData={};
			var o:Object={};
			o["name"]=Tools.getMsgById("_view_timer11");//"卸货";
			o["skin"]=AssetsManager.getAssetsUI("home_56.png");
			
			var arr:Array=ModelOnlineReward.getRemainingTime();
			o["max"] = arr[1];
			if (arr[1] == 0){
				o["text1"] = Tools.getMsgById("_view_timer12")//"今日已领完"
				o["color1"] = '#999999';
			}
			else{
				o["text1"] = Tools.getMsgById("_view_timer13");//"可领奖";
				o["color1"] = '#00FF00';
			}

			o["btn"]=arr[0]==0;
			o["time"]=arr[0];
			o["text2"]=Tools.getMsgById("_view_timer10");//"卸货中";
			o["gotoArr"]={"type":2};
			wharfData["data"]={"icon":AssetsManager.getAssetsUI("home_56.png"),"title":Tools.getMsgById("_view_timer09")};//"码头"};
			wharfData["arr"]=[o];
		}

		public function getGuildData():void{
			guildData={};
			var a:Array=[];
			var arr:Array=ModelManager.instance.modelUser.alien_reward;
			var isHaveGuild:Boolean=ModelManager.instance.modelUser.guild_id!=null;
			for(var i:int=0;i<3;i++){
				var o:Object={};
				o["name"]=Tools.getMsgById("_view_timer16",[""]);//"贡品"+i;
				o["skin"]=AssetsManager.getAssetsUI("home_33.png");
				o["time"]=0;
				o["max"]=0;
				o["text1"]="";
				o["text2"]="";
				o["max"]=0;
				o["value"]=0;
				if(isHaveGuild){
					o["btn"]=true;
					o["gotoArr"]={"panelID":"guild"};
				
					if(i<arr.length){
						var aa:Array=arr[i];
						var s_time:Number=Tools.getTimeStamp(aa[2]);
						var e_time:Number=Tools.getTimeStamp(aa[1]);
						o["max"]=e_time-s_time;
						if(now>=e_time){
							o["text1"]=Tools.getMsgById("_guild_text54");//"可开启";
							o["time"]=0;
						}else{
							o["text2"]=Tools.getMsgById("_view_timer15");//"开启中";
							o["time"]=e_time-now;
						}
					}
					else{
						o["text1"] = Tools.getMsgById("_public161");//"空闲中";
						o["color1"] = '#00FF00';
					}
				}else{
					o["text1"] = Tools.getMsgById("_chat_tips05");//"请先加入一个军团";
					o["color1"] = '#FFFF00';
				}
				a.push(o);
			}
			guildData["data"]={"icon":AssetsManager.getAssetsUI("home_33.png"),"title":Tools.getMsgById("_view_timer14")};//"军团贡品"};
			guildData["arr"]=a;			
		}

		public function setUI():void{
			var _y:Number=0;
			for(var i:int=0;i<listData.length;i++){
				var item:Item=new Item();
				item.setData(listData[i]);
				item.name="item"+i;
				if(i==0){
					item.y=50;
				}else{
					item.y=_y;
				}
				item.centerX=0;
				_y=item.y+item.height;
				this.box.addChild(item);
			}
			this.box.height=_y+50;	
			
		}

		public function time_tick():void{
			setData();
			for(var i:int=0;i<listData.length;i++){
				if(this.box.getChildByName("item"+i)){
					var item:Item=this.box.getChildByName("item"+i) as Item;
					item.setTimeData(listData[i]);
				}
			}
		}

		override public function onRemoved():void{
			Laya.timer.clear(this,time_tick);
			for(var i:int=0;i<this.listData.length;i++){
				if(this.box.getChildByName("item"+i)){
					this.box.removeChild(this.box.getChildByName("item"+i));
				}
			}
		}
	}

}


import ui.init.itemTimerUI;
import ui.init.renderTimerUI;
import sg.utils.Tools;
import sg.boundFor.GotoManager;
import laya.events.Event;
import sg.manager.ViewManager;

class Item extends itemTimerUI{

	public function Item(){

	}

	public function setData(o:Object):void{
		var d:Object=o.data;
		this.titleImg.skin=d.icon;
		this.titleLabel.text=d.title;
		var a:Array=o.arr;
		var _height:Number=0;
		var _y:Number=0;		
		for(var i:int=0;i<a.length;i++){
			var render:renderItem=new renderItem();
			_height=render.height;
			render.initData(a[i]);
			render.setData(a[i]);
			if(i==0){
				render.y=titleImg.height;
			}else{
				render.y=_y;
			}
			render.name="render"+i;
			render.centerX=0;
			_y=render.y+render.height;
			this.addChild(render);
		}
		this.height=titleImg.height+a.length*_height;
	}

	public function setTimeData(o:Object):void{
		var a:Array=o.arr;	
		for(var i:int=0;i<a.length;i++){
			var render:renderItem=this.getChildByName("render"+i) as renderItem;
			render.setData(a[i]);
		}
	}
}


class renderItem extends renderTimerUI{
	public function renderItem(){
		this.goBtn.label = Tools.getMsgById("_jia0032");
	}

	public function initData(obj:Object):void{
		this.imgIcon.skin=obj.skin;
		this.nameLabel.text=obj.name;
		this.rightLabel.text=obj.text2;
		if(obj.max>0){
			pro.value=(obj.max-obj.time)/obj.max;
		}
		this.goBtn.off(Event.CLICK,this,this.click);
		this.goBtn.on(Event.CLICK,this,this.click,[obj]);
	}

	public function setData(obj:Object):void{
		if(obj.max>0){
			if(pro.value>=1){
				this.pro.visible=false;
				this.midLabel.text=obj.text1;
				this.rightLabel.text=this.timeLabel.text="";
				this.goBtn.visible=true;
			}else{
				this.pro.value=(obj.max-obj.time)/obj.max;
				this.timeLabel.text=Tools.getTimeStyle(obj.time,3);	
				this.pro.visible=true;
				this.goBtn.visible=false;
				this.midLabel.text="";
			}
		}else{
			this.midLabel.text=obj.text1;
			this.goBtn.visible=false;
			this.timeLabel.text="";
			this.pro.visible=false;
			this.rightLabel.text="";
		}
		if (obj.color1){
			this.midLabel.color = obj.color1;
		}
		else{
			this.midLabel.color = '#EEEEEE';
		}
		if(obj.btn){
			this.goBtn.visible=true;
		}
	}

	public function click(obj:Object):void{
		if(obj.hasOwnProperty("gotoArr")){
			if(obj.gotoArr is String){
				ViewManager.instance.showTipsTxt(obj.gotoArr);
			}else{
				ViewManager.instance.closePanel();
				GotoManager.boundFor(obj.gotoArr);
			}
			
		}
		
	}
}