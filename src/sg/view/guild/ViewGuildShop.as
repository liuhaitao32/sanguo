package sg.view.guild
{
	import ui.guild.guildShopUI;
	import ui.guild.guildShopItemUI;
	import laya.events.Event;
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;
	import sg.model.ModelItem;
	import laya.maths.MathUtil;
	import sg.manager.AssetsManager;
	import sg.utils.Tools;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.manager.ViewManager;
	import ui.bag.bagItemUI;
	import sg.manager.EffectManager;
	import sg.cfg.ConfigClass;
	import laya.ui.Label;
	import laya.utils.Tween;
	import sg.model.ModelUser;

	/**
	 * ...
	 * @author
	 */
	public class ViewGuildShop extends guildShopUI{

		public var listData:Array=[];
		public var configData:Object={};
		public var userData:Object={};
		public var curShopData:Object={};
		public var costId:String="";
		public var costNum:Number=0;
		public var curItemIndex:Number=0;
		public var cost_type_num:Number=0;
		public function ViewGuildShop(){
			this.itemList.scrollBar.visible=false;
			this.itemList.itemRender=Item;
			this.itemList.renderHandler=new Handler(this,listRender);
			this.costCom.on(Event.CLICK,this,this.addClick);
			
		}

		public function addClick():void{
			//ModelManager.instance.modelProp.curProp=ModelManager.instance.modelProp.getItemProp(curShopData.cost_type);
			ViewManager.instance.showView(ConfigClass.VIEW_BAG_SOURSE,curShopData.cost_type);
		}

		override public function onAdded():void{
			ModelManager.instance.modelUser.on(ModelUser.EVENT_IS_NEW_DAY,this,setData);
			setData();
		}

		public function setData():void{
			configData=ConfigServer.shop.guild_shop;
			userData=ModelManager.instance.modelUser.shop.guild_shop;
			listData=[];
			curShopData={};
			//下次刷新时间
			curShopData["refresh_time"]=userData.refresh_time;
			//是否每日刷新
			var sec:Number=configData["day_fresh"][0][1];
			var _sec:String=sec<10?"0"+sec:sec+"";
			curShopData["day_refresh"]=(configData["day_fresh"].length==1)?configData["day_fresh"][0][0]+":"+_sec:"";
			//手动刷新时间
			curShopData["shop_time"]=userData.shop_time;
			//该商店限购次数
			curShopData["all_limit"]=configData.all_limit;
			//已经购买次数
			curShopData["buy_times"]=userData.buy_times;
			//是否专用货币
			curShopData["cost_type"]=configData.hasOwnProperty("cost_type")?configData["cost_type"]:"";
			cost_type_num=ModelManager.instance.modelUser.property[curShopData["cost_type"]]?ModelManager.instance.modelUser.property[curShopData["cost_type"]]:0;
			//已刷新次数
			curShopData["user_refresh_times"]=userData.user_refresh_times;
			if(!configData.hasOwnProperty("cost_refresh") || configData["cost_refresh"].length==0){
				curShopData["cost_refresh"]=[];
				curShopData["refresh_num"]=0;
			}else{
				var cost_refresh_num:int=0;
				curShopData["cost_refresh"]=configData.cost_refresh;//刷新按钮花费
				var len:int =configData.hasOwnProperty("cost_refresh")?configData.cost_refresh.length:0;
				for(var i:int = 0; i < len; i++)
				{
					if(configData.cost_refresh[i][1]==0){
						cost_refresh_num+=1;
					}else{
						break;
					}
				}
				curShopData["refresh_num"]=cost_refresh_num;
			}
			
			var configGoods:Object=configData.goods;
			var userGoods:Object=userData.goods;
			for (var s:String in userGoods)
			{
				var d:Object={};
				var u:Array=userGoods[s];
				var cItem:Object=configGoods[s][u[0]];
				d["index"]=s;
				d["limit"]=cItem.limit;
				d["num"]=cItem.reward[1];
				var itemModel:ModelItem=ModelManager.instance.modelProp.getItemProp(cItem.reward[0]);
				d["name"]=itemModel.name;
				d["icon"]=itemModel.icon;
				d["ratity"]=itemModel.ratity;
				d["id"]=itemModel.id;
				var p1:Number=0;
				var p2:Number=0;
				p1=u[1]*cItem.price[3]+cItem.price[1];
				p2=p1/cItem.price[2]*10;
				p2.toFixed(1);
				d["price"]=[cItem.price[0],p1,p2];
				d["buy_num"]=u[1];
				listData.push(d);
			}
			listData.sort(MathUtil.sortByKey("index",false,true));
			setPanel();
		}

		public function setPanel():void{
			//timer.clear(this,this.timerUpdateRefresh);
			this.itemList.array=listData;
			if(curShopData["day_refresh"]!=""){
				this.text1.text=Tools.getMsgById("msg_ViewGuildShop_0")+curShopData["day_refresh"]+Tools.getMsgById("_public78");
				//this.costCom.visible=false;
			}
			//else{
				if(curShopData["all_limit"]==-1){
					this.costCom.visible=true;
					this.text1.text="";
					//this.costIcon.skin="icon/"+ModelManager.instance.modelProp.getItemProp(configData.cost_type).icon;
					if(ModelManager.instance.modelUser.property.hasOwnProperty(curShopData["cost_type"])){
					//	this.haveText.text=ModelManager.instance.modelUser.property[curShopData["cost_type"]]+"";
					}else{
						if(ModelManager.instance.modelUser.hasOwnProperty(curShopData["cost_type"])){
					//		this.haveText.text=ModelManager.instance.modelUser[curShopData["cost_type"]]+"";
						}else{
					//		this.haveText.text="0";
						}
					}
					this.comNum.setData(AssetsManager.getAssetItemOrPayByID(curShopData.cost_type),ModelItem.getMyItemNum(curShopData["cost_type"])+"");
					//this.btnAdd.on(Event.CLICK);
				}else{
					this.text1.text=Tools.getMsgById("msg_ViewGuildShop_1")+(curShopData["all_limit"]-curShopData["buy_times"])+"/"+curShopData["all_limit"]+")";
					this.costCom.visible=false;
				}
			//}

			costId="";
			costNum=0;
			if(curShopData.hasOwnProperty("cost_refresh") && curShopData["cost_refresh"].length!=0){
				this.refreshCom.visible=true;
				this.text2.text=Tools.getMsgById("_shop_text02");
				if(Tools.getTimeStamp(curShopData["refresh_time"])-ConfigServer.getServerTimer()<0){
					this.timerText.text="";
				}else{
					this.timerText.text=Tools.getTimeStyle(Tools.getTimeStamp(curShopData["refresh_time"])-ConfigServer.getServerTimer());
				}
				var len:int=0;
				len=curShopData["user_refresh_times"];
				if(curShopData["user_refresh_times"]>=curShopData["cost_refresh"].length){
					len=curShopData["cost_refresh"].length-1;
				}
				costId=curShopData["cost_refresh"][len][0];
				costNum=curShopData["cost_refresh"][len][1];
				if(curShopData["refresh_num"]>curShopData["user_refresh_times"]){
					this.btnRefresh.setData("",Tools.getMsgById("msg_ViewGuildShop_2")+(curShopData["refresh_num"]-curShopData["user_refresh_times"])+"/"+curShopData["refresh_num"]+")",-1,1);
				}else{

					this.btnRefresh.setData(AssetsManager.getAssetItemOrPayByID(costId),costNum);
				}
			}else{
				this.refreshCom.visible=false;
			}	
			//timer.loop(5000,this,this.timerUpdateRefresh);
		}
		/*
		public function timerUpdateRefresh():void{
			if(Tools.isNewDay(curShopData["shop_time"])){
				
				Trace.log("--------is new day");
			}
		}*/

		public function buy_shop():void{
			var sendData:Object={};
			sendData["shop_id"]="guild_shop";
			sendData["goods_id"]=curItemIndex+"";
			NetSocket.instance.send("buy_shop",sendData,Handler.create(this,this.buyShopCallBack));
		}

		public function buyClick(cell:Item):void{
			if(!Tools.isCanBuy(cell.price[0],cell.price[1])){
				return;
			}
			if(curShopData["all_limit"]!=-1 && curShopData["all_limit"]-curShopData["buy_times"]<=0){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_shop_tips01"));//"已达今日可购次数");
				return;
			}
			//if(cell.btnBuy.gray){
			//	ViewManager.instance.showTipsTxt("这个今天不能买了");
			//	return;
			//}
			curItemIndex=cell.index;
			buy_shop();
		}

		public function buyShopCallBack(np:NetPackage):void{
			ModelManager.instance.modelProp.getRewardProp(np.receiveData.gift_dict,true);//获得的增量
			ModelManager.instance.modelUser.updateData(np.receiveData);
			textTween();
			setData();
			//var com:bagItemUI=new bagItemUI();
			//var d:Object=this.itemList.getItem(curItemIndex-1);
			//com.setData(d.icon,d.ratity);
			//com.x=this.mouseX-100;
			//com.y=this.mouseY-100;
			//EffectManager.itemFlight(com,this.width/2,this.height,this);
			ViewManager.instance.showIcon(np.receiveData.gift_dict,this.mouseX-120,this.mouseY+100);
		}

		public function textTween():void{
			if(curShopData["cost_type"]!=""){
				var n:Number=ModelManager.instance.modelUser.property[curShopData["cost_type"]]-cost_type_num;
				var l:Label=new Label();
				this.costCom.addChild(l);
				l.x=100;
				l.y=-10;
				l.fontSize=18;
				l.text=n+"";
				l.color="#ff1e00";
				Tween.to(l,{y:l.y-20},1200,null, Handler.create(this,function():void{
					costCom.removeChild(l);
				}));
			}
		}

		
		public function listRender(cell:Item,index:int):void{
			cell.setData(listData[index],index);
			cell.com.off(Event.CLICK,this,this.itemClick);
			cell.com.on(Event.CLICK,this,this.itemClick,[index]);
			cell.btnBuy.off(Event.CLICK,this,this.buyClick);
			cell.btnBuy.on(Event.CLICK,this,this.buyClick,[cell]);
		}

		public function itemClick(index:int):void{
			ViewManager.instance.showItemTips(listData[index].id);
		}

		override public function onRemoved():void{
			ModelManager.instance.modelUser.off(ModelUser.EVENT_IS_NEW_DAY,this,setData);
			//timer.clear(this,timerUpdateRefresh);
		}
	}

}


import ui.guild.guildShopItemUI;
import sg.manager.AssetsManager;
import sg.utils.Tools;
import ui.bag.bagItemUI;
import sg.model.ModelHero;
import sg.manager.ModelManager;

class Item extends guildShopItemUI{
	public var index:int;
	public var price:Array=[];
	public var id:String;

	public function Item(){

	}

	public function setData(obj:*,ix:int):void{
		index=ix+1;
		price=[obj.price[0],obj.price[1]];
		id=obj.id;


		(this.com as bagItemUI).setData(obj["id"],obj["num"],-1);
		if(obj.type==7){
			var s:String=obj.id.replace("item","hero");
			var heroModel:ModelHero=ModelManager.instance.modelGame.getModelHero(s);
			//this.rarityIcon.skin=heroModel.getRaritySkin();
		}else{
			//this.rarityIcon.visible=false;
		}
		
		//this.costLabel.text=obj.price[2]>=10?"":obj.price[2]+"折";
		this.goodName.text=obj.name;
		this.btnBuy.setData(AssetsManager.getAssetItemOrPayByID(obj.price[0]),obj.price[1]);
		if(obj.limit!=-1 && obj.buy_num>=obj.limit){
			this.btnBuy.gray=true;
		}else{
			this.btnBuy.gray=false;
		}
	}
}