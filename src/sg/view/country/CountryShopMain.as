package sg.view.country
{
	import ui.country.country_shop_mainUI;
	import sg.manager.ModelManager;
	import sg.model.ModelUser;
	import laya.events.Event;
	import sg.manager.ViewManager;
	import sg.utils.Tools;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import laya.ui.Label;
	import laya.utils.Tween;
	import sg.cfg.ConfigClass;
	import sg.cfg.ConfigServer;
	import sg.model.ModelItem;
	import laya.maths.MathUtil;
	import sg.manager.AssetsManager;
	import sg.model.ModelShop;
	import sg.boundFor.GotoManager;
	import laya.maths.Point;
	import sg.model.ModelEquip;

	/**
	 * ...
	 * @author
	 */
	public class CountryShopMain extends country_shop_mainUI{

		public var configData:Object = ConfigServer.shop;

		public var curShopID:String;//当前商店id

		private var mModel:ModelShop;
		private var shopType:String="";
		private var barData:Array=[];
		private var mCostArr:Array;//花费的资源

		public function CountryShopMain(){
			curShopID = this.shopType = 'guild_shop';
			this.itemList.scrollBar.visible=false;
			this.itemList.itemRender=Item;
			this.itemList.renderHandler=new Handler(this,this.itemListRender);
			ModelManager.instance.modelUser.on(ModelUser.EVENT_IS_NEW_DAY,this,eventCallBack);
			this.costCom.on(Event.CLICK,this,this.addClick);

			this.text2.text=Tools.getMsgById("_shop_text02");
			
			this.on(Event.REMOVED,this,this.removeFun);
			this.initUI();
		}
		
		public function addClick():void{
			ViewManager.instance.showView(ConfigClass.VIEW_BAG_SOURSE,mModel.cfgCostType);
		}

		private function initUI():void{
			mModel=ModelManager.instance.modelGame.getModelShop("guild_shop");
			setUI();
		}

		public function eventCallBack():void{
			setUI();
		}


		public function socketCallBack(np:NetPackage):void{
			ModelManager.instance.modelUser.updateData(np.receiveData);
			setUI();
			
		}

		private function setUI():void{
			
			this.text1.text="";
			if(mModel.cfgCostType!=""){
				this.costCom.visible=true;
				this.comNum.setData(AssetsManager.getAssetItemOrPayByID(mModel.cfgCostType),ModelItem.getMyItemNum(mModel.cfgCostType));
			}else{
				this.costCom.visible=false;
				if(mModel.cfgAllLimit!=-1){
					//今日可购买次数
					this.text1.text=Tools.getMsgById("_shop_text04",[(mModel.cfgAllLimit-mModel.buy_times)+"",mModel.cfgAllLimit]);
				}else{
					//每日几点刷新
					var arr:Array=mModel.cfg.day_fresh[0];
					this.text1.text=Tools.getMsgById("_shop_text03",[arr[0]+":"+(arr[1]<10?"0"+arr[1]:arr[1])]);
				}
			}

			var cost:Array=mModel.cfgCostRefresh;
			if(cost){
				this.refreshCom.visible=true;	
				if(cost[1]==0){
					var free_num:Number=0;
					for(var i:int=0;i<mModel.cfg.cost_refresh.length;i++){
						if(mModel.cfg.cost_refresh[i][1]==0){
							free_num+=1;
						}else{
							break;
						}
					}
					var t:String=Tools.getMsgById("_shop_text05",[free_num-mModel.userData.user_refresh_times,free_num]);
					this.btnRefresh.setData("",t,-1,1);
				}else{
					this.btnRefresh.setData(AssetsManager.getAssetItemOrPayByID(cost[0]),cost[1],-1,0);
				}
			}else{
				this.refreshCom.visible=false;
			}
			timer.clear(this,updateRefreshTime);
			updateRefreshTime();
			setList();
		}

		public function updateRefreshTime():void{
			var n:Number=Tools.getTimeStamp(mModel.userData.refresh_time)-ConfigServer.getServerTimer();
			if(n<0){//当前时间大于刷新时间则刷新
				this.timerText.text="";
				NetSocket.instance.send("get_shop",{"shop_id":curShopID},Handler.create(this,this.socketCallBack));
			}else{
				this.timerText.text=Tools.getTimeStyle(n);
			}
			timer.once(1000,this,updateRefreshTime);
		}

		private function setList():void{
			this.itemList.array=mModel.getGoodsList();
		}

		public function shopOnSelect(index:int):void{
			if(index>=0){
                
            }
		}


		public function itemListRender(cell:Item,index:int):void{
			var o:Object=this.itemList.array[index];
			cell.setData(o,index);

			var b1:Boolean=mModel.cfgAllLimit!=-1 && mModel.buy_times>=mModel.cfgAllLimit;
			var b2:Boolean=ModelItem.getMyItemNum(o.price[0])<o.price[1];

			if(b1 || b2){
				cell.btnBuy.gray=true;
			}
			cell.btnBuy.off(Event.CLICK,this,this.itemClick);
			cell.btnBuy.on(Event.CLICK,this,this.itemClick,[index]);
			cell.com.off(Event.CLICK,this,this.iconClick);
			cell.com.on(Event.CLICK,this,this.iconClick,[o.id]);
			
		}

		public function itemClick(index:Number):void{
			var o:Object=this.itemList.array[index];
			mCostArr=[o.price[0],o.price[1]];
			if(mModel.cfgAllLimit!=-1 && mModel.buy_times>=mModel.cfgAllLimit){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_shop_tips01"));//已达该物品购买次数
				return;
			}
			if(o["limit"]!=-1 && o["buy_num"]>=o["limit"]){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_shop_tips02"));//已达该物品购买次数
				return;
			}
			if(!Tools.isCanBuy(mCostArr[0],mCostArr[1])){
				return;
			}
			
			if(ModelEquip.canBuyEquipItem(o.id,true)==false){
				return;
			}
			var sendData:Object={};
			sendData["shop_id"]=curShopID;
			sendData["goods_id"]=o.index+"";
			var item:* = (this.itemList.getCell(index) as Item).com;
			var pos:Point = Point.TEMP.setTo(item.x + item.width/2, item.y+item.height/2);
			pos = item['parent'].localToGlobal(pos, true);
			NetSocket.instance.send("buy_shop",sendData,Handler.create(this,this.socketCallBack3,[pos]));
		}

		public function socketCallBack3(pos:Point,np:NetPackage):void{
			ModelManager.instance.modelUser.updateData(np.receiveData);
			ModelManager.instance.modelProp.getRewardProp(np.receiveData.gift_dict,true);
			textTween();
			ViewManager.instance.showIcon(np.receiveData.gift_dict,pos.x,pos.y,false,"",true,1);
			setUI();
		}

		public function iconClick(s:String):void{
			ViewManager.instance.showItemTips(s);			
		}


		public function textTween():void{
			if(mModel.cfgCostType!=""){
				var n:Number=mCostArr[1];
				var l:Label=new Label();
				this.costCom.addChild(l);
				l.x=100;
				l.y=-10;
				l.fontSize=18;
				l.text="-"+n;
				l.color="#ff1e00";
				Tween.to(l,{y:l.y-20},1200,null, Handler.create(this,function():void{
					costCom.removeChild(l);
				}));
			}
		}

		private function removeFun():void{
			ModelManager.instance.modelUser.off(ModelUser.EVENT_IS_NEW_DAY,this,eventCallBack);
            this.destroyChildren();
            this.destroy(true);
        }    

	}

}

import sg.manager.AssetsManager;
import sg.utils.Tools;
import ui.bag.bagItemUI;
import sg.model.ModelHero;
import sg.manager.ModelManager;
import ui.shop.shopItemUI;
import sg.cfg.ConfigServer;
import sg.model.ModelItem;

class Item extends shopItemUI{
	public function Item(){

	}

	public function setData(obj:Object,ix:int):void{
		this.lockLabel.text="";
		this.box.visible=true;
		this.costIcon.visible=false;
		this.goodName.text=ModelItem.getItemName(obj["id"]);// obj.name;
		this.costLabel.text=obj.price[2]>=10?"":Tools.getMsgById("_shop_text06",[obj.price[2]+""]); 
		(this.com as bagItemUI).setData(obj["id"],obj["num"],-1);			
		if(obj.type==7){
			var s:String=obj.id.replace("item","hero");
			var heroModel:ModelHero=ModelManager.instance.modelGame.getModelHero(s);
			this.rarityIcon.visible=true;
			this.rarityIcon.skin=heroModel.getRaritySkin(true);
			this.goodName.x = this.rarityIcon.x+40;
			this.goodName.width = 100;
			this.goodName.align = 'left';
		}else{
			this.rarityIcon.visible=false;
			this.goodName.x = this.goodBG.x;
			this.goodName.width = this.goodBG.width;
			this.goodName.align = 'center';
		}
		this.btnBuy.setData(AssetsManager.getAssetItemOrPayByID(obj.price[0]),obj.price[1]);
		
		this.btnBuy.gray=obj.limit!=-1 && obj.buy_num>=obj.limit;
		Tools.textFitFontSize(this.goodName);
	}

}