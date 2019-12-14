package sg.view.inside
{
	import ui.inside.baggageMainUI;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import laya.net.Socket;
	import sg.net.NetPackage;
	import sg.cfg.ConfigServer;
	import laya.events.Event;
	import sg.manager.ModelManager;
	import laya.maths.MathUtil;
	import sg.manager.ViewManager;
	import sg.utils.Tools;
	import sg.cfg.ConfigClass;
	import sg.manager.EffectManager;
	import sg.manager.AssetsManager;
	import sg.model.ModelOffice;
	import laya.display.Sprite;
	import laya.resource.Texture;
	import ui.com.item_flyUI;
	import sg.model.ModelBuiding;
	import sg.model.ModelUser;
	import sg.utils.MusicManager;
	import sg.festival.model.ModelFestival;
	import sg.cfg.ConfigApp;
	import laya.maths.Point;

	/**
	 * ...
	 * @author
	 */
	
	public class ViewBaggageMain extends baggageMainUI{

		public var configData:Object={};
		public var userData:Object={};		
		public var listData:Array;
		public var lv:int=0;
		public var is_fresh_time:Boolean=false;
		public var refresh_time:Number=0;
		public var now_time:Number=0;
		public var total_free_time:Number;
		public var use_free_time:Number;
		private var mHasFestArr:Array;
		public function ViewBaggageMain(){
			this.list.scrollBar.visible=false;
			this.list.scrollBar.touchScrollEnable=false;
			this.list.itemRender=Item;
			this.list.renderHandler=new Handler(this,updateItem);
			//this.btn.on(Event.CLICK,this,this.onClick);
			//this.btn.visible=false;
						
		}

		override public function onAdded():void{
			mHasFestArr=ModelFestival.getRewardInterfaceByKey("baggage");
			ModelManager.instance.modelUser.on(ModelUser.EVENT_IS_NEW_DAY,this,isNewDayCallBack);
			this.setTitle(Tools.getMsgById(60003));
			lv=ModelManager.instance.modelInside.getBuildingModel("building004").lv;
			configData=ConfigServer.system_simple.baggage;
			setData();
			setTime();
			//setData();
			time_tick();
			
			this.imgBG.y=this.height/2-this.imgBG.height/2;
			this.list.y=this.height/2-this.list.height/2;
			
			var top:Sprite = new Sprite();
			var textrue:Texture = Laya.loader.getRes(AssetsManager.getAssetsUI("bg_006.png"));
			
			top.graphics.fillTexture(textrue, 0, 0, this.width,138);
			top.y = this.imgBG.y-138;
			
			this.addChild(top);
			var bottom:Sprite = new Sprite();
			bottom.graphics.fillTexture(textrue, 0, 0, this.width,138);
			bottom.scaleY = -1;
			bottom.y = this.imgBG.y+this.imgBG.height+138;//+178;
			this.addChild(bottom);
			this.setChildIndex(top,1);
			this.setChildIndex(bottom,1);
			
			//this.comTop.y=this.imgBG.y-138;
			//this.comBot.y=this.imgBG.y+this.imgBG.height;
			
		}

		public function isNewDayCallBack():void{
			setData();
		}

		public function setTime():void{
			refresh_time=Tools.getTimeStamp(userData.refresh_time);
			now_time=ConfigServer.getServerTimer();
			if(refresh_time<now_time){
				var arr:Array=configData.fresh_time;
				var dt:Date=new Date(now_time);
				var n:Number=dt.getHours()*Tools.oneHourMilli + dt.getMinutes()*Tools.oneMinuteMilli + dt.getSeconds()*Tools.oneMillis + dt.getMilliseconds();
				for(var i:int=0;i<arr.length;i++){
					var m:Number=arr[i][0]*Tools.oneHourMilli + arr[i][1]*Tools.oneMinuteMilli;
					if(n<m){
						refresh_time=Tools.getToDayHourMill(arr[i]);
						
						break;
					}
					if(i==arr.length-1){
						refresh_time=Tools.getToDayHourMill(arr[0])+Tools.oneDayMilli;
						break;
					}
				}
				is_fresh_time=true;
				setData();
			}
			//trace("刷新时间:",Tools.dateFormat(refresh_time),"服务器时间:",Tools.dateFormat(now_time));
		}

		public function time_tick():void{
			var n1:Number=refresh_time;
			var n2:Number=ConfigServer.getServerTimer();
			if(n1-n2<=0){
				//Laya.timer.clear(this,this.time_tick);
				is_fresh_time=true;
				setData();
				setTime();
				this.nextTime.text="";
				// trace("辎重站刷新...");
				
			}else{
				is_fresh_time=false;
				var str:String=Tools.getTimeStyle(n1-n2);
				this.nextTime.text=str + Tools.getMsgById("_public29");//"重置购买次数";
			}
			Laya.timer.once(1000,this,this.time_tick);
		}



		public function setData():void{
			if(!configData)
			{
				Trace.log("have no config");
				return;
			}
			userData=ModelManager.instance.modelUser.baggage;
			use_free_time=Tools.isNewDay(userData.refresh_free_time)?0:userData.free_times;//使用过的免费次数
			total_free_time=configData.free_buy+ModelOffice.func_baggagefree();//总的免费次数
			listData=[];
			var id_arr:Array=["gold","food","wood","iron"];
			var times:int=configData.limit[0]+lv*configData.limit[1];//每一种的购买次数
			for(var i:int = 0; i < 4; i++)
			{
				var obj:Object={};
				var o:Object=configData["buy_"+id_arr[i]];
				var useNum:Number=userData.material[i][0];//material[i]=["已购买次数","百分百暴击次数"]
				var critNum:Number=userData.material[i][1];//免费必暴击次数
				if(is_fresh_time){
					useNum=0;
				}
				obj["crit"]=critNum;
				obj["id"]=id_arr[i];
				obj["index"]=i;
				obj["num"]="+"+(o[0]+(o[1]*lv)+((o[2]+lv*o[3]))*useNum);
				var costNum:int=0;
				if(critNum>0){
					obj["cost"]=["",-1];//免费购买
					obj["times"]=critNum;//"特惠购买次数：" +critNum;//特惠购买次数：
					obj["text"]= Tools.getMsgById("_building18",[critNum]);//"特惠购买次数：" +critNum;//特惠购买次数：
				}else if(total_free_time > use_free_time){
					obj["cost"]=["",-1];//"免费购买"
					obj["times"]=total_free_time-use_free_time;//"剩余免费次数：" +;
					obj["text"]=Tools.getMsgById("_public32",[(total_free_time-use_free_time)]);//"剩余免费次数：" +;
				}else{
					var s:Number = useNum < configData.use_coin.length ? configData.use_coin[useNum] : configData.use_coin[configData.use_coin.length-1];
					obj["cost"]=["coin",s];
					obj["times"]=(times-useNum);//"剩余次数:" + (times-useNum);
					obj["text"]=Tools.getMsgById("_public31",[(times-useNum)]);//"剩余次数:" + (times-useNum);
				}

				if(o.length>7){
					obj["free"]=[o[6],o[7]];
					obj["other"]=Tools.getMsgById("_building19",[o[6],o[7]]);//"必送："+o[6]+" x"+o[7];
				}else{
					obj["free"]=[o[6],o[7]];
					obj["other"]="";
				}
				
				listData.push(obj);
			}
			this.list.array=listData;
			//listData.sort(MathUtil.sortByKey("index",false,false));
		}

		public function updateItem(cell:Item,index:int):void{
			var d:Object=this.list.array[index];
			//Trace.log("-render",d.id,d.num,d.times,d.cost);
			cell.setData(d);
			cell.cFest.visible=mHasFestArr.length!=0;
			if(cell.cFest.visible) 
				cell.cFest.setData(mHasFestArr[0],mHasFestArr[1],-1);
			
			cell.btnBuy.off(Event.CLICK,this,this.onClick);
			cell.btnBuy.on(Event.CLICK,this,this.onClick,[index]);
		}

		public function onClick(index:int):void{
			var d:Object=this.list.array[index];
			if(lv==0){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_building20"));//0级不让买
				return;
			}
			if(d["times"]<=0){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_public33"));//次数不足
				return;
			}
			var arr:Array=d["cost"];
			if(arr[0]!="" && !Tools.isCanBuy(arr[0],arr[1])){
				return;
			}
			MusicManager.playSoundUI(MusicManager.SOUND_GET_BAGGAGE);
			var sendData:Object={};
			sendData["material_index"]=index;
			NetSocket.instance.send("baggage_buy",sendData,Handler.create(this,SocketCallBack,[index]));
		}

		public function SocketCallBack(index:int,np:NetPackage):void{
			
			var aaa:Array=[1,3,1,3];
			var bbb:Array=[1,1,3,3];
			var xx:Number=this.list.x+((this.list.width/4)*aaa[index]);
			var yy:Number=this.list.y+((this.list.height/4)*bbb[index]);

			var _id:String=this.listData[index].id;
			var _num:String=this.listData[index].num;			
			ModelManager.instance.modelUser.updateData(np.receiveData);
			//var s:String="";
			var o:Object=np.receiveData.gift_dict;
			ModelManager.instance.modelProp.getRewardProp(o,true);
			var oo:Object={};
			var ooo:Object={};
			for(var s:String in o){
				if(ModelBuiding.material_type.indexOf(s)==-1){
					oo[s]=o[s];
				}else{
					ooo[s]=o[s];
				}
			}
			var item:Item = this.list.getCell(index) as Item;
			if(o.hasOwnProperty(_id)){
				//s=(o[_id]==_num)?"":"暴击";
				var com:item_flyUI=new item_flyUI();
				com.num.text="+"+o[_id];
				com.img.visible=true;
				if(o[_id]==_num){
					com.img.visible=false;
				}

				var pos:Point = Point.TEMP.setTo(item.x + item.width/2, item.y+item.height/2);
				pos = item['parent'].localToGlobal(pos, true);

				EffectManager.comFlight(com,pos.x-com.width/2,pos.y);
				
				ViewManager.instance.showIcon(ooo,pos.x,pos.y - 20,false," ");
			}

			(this.list.getCell(index) as Item).playAni();

			var comFest:* = item.cFest;
			var pos2:Point = Point.TEMP.setTo(comFest.x + comFest.width/4, comFest.y+comFest.height/4);
			pos2 = comFest['parent'].localToGlobal(pos2, true);

			ViewManager.instance.showIcon(oo,pos2.x,pos2.y,false,"",true,0.5);
			setData();
		}

		override public function onRemoved():void{
			ModelManager.instance.modelUser.off(ModelUser.EVENT_IS_NEW_DAY,this,isNewDayCallBack);
			Laya.timer.clear(this,this.time_tick);
		}
	}

}

import ui.inside.baggageItemUI;
import sg.manager.AssetsManager;
import sg.utils.Tools;
import sg.model.ModelItem;
import sg.manager.ModelManager;
import laya.display.Animation;
import sg.manager.EffectManager;

 class Item extends baggageItemUI
{
	public function Item()
	{
		
	}

	public function setData(d:Object):void{
		this.text1.text=Tools.getNameByID(d.id);
		this.text2.text=d.num;
		this.text3.color="#c3ebff";
		this.imgBao.visible=false;
		this.imgBG.visible=false;
		this.imgBG.mouseThrough=true;
		if(d.crit!=0){
			this.text3.color="#fffbc1";
			this.imgBao.visible=true;
			this.imgBG.visible=true;
		}
		this.text3.text=d.text;
		this.imgIcon.skin=AssetsManager.getAssetPayIconBig(d.id);
		this.freeItem.visible=false;
		this.imgFree.visible=false;
		if(d.other!=""){
			//var tem:ModelItem=ModelManager.instance.modelProp.getItemProp(d.free[0]);
			//this.freeItem.setData(tem.icon,tem.ratity,"",d.free[1]);
			//this.freeItem.visible=true;
			this.imgFree.visible=true;
		}
		this.text4.text="";//d.other;“必送什么什么的”
		if(d.cost[0]==""){
			this.btnBuy.setData("",Tools.getMsgById("_public30"),-1,1);
		}else{
			this.btnBuy.setData(AssetsManager.getAssetItemOrPayByID(d.cost[0]),d.cost[1]);
		}
		

	}

	public function playAni():void{
		var ani:Animation=EffectManager.loadAnimation("glow011","",1);
		ani.name="ani";
		ani.pos(this.imgIcon.x,this.imgIcon.y);				
		this.addChild(ani);
	}
}