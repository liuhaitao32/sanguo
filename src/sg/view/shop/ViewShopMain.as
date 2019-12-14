package sg.view.shop
{
	import laya.events.Event;
	import laya.maths.MathUtil;
	import laya.ui.Label;
	import laya.utils.Handler;
	import laya.utils.Tween;

	import sg.boundFor.GotoManager;
	import sg.cfg.ConfigClass;
	import sg.cfg.ConfigServer;
	import sg.manager.AssetsManager;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.model.ModelGame;
	import sg.model.ModelItem;
	import sg.model.ModelOffice;
	import sg.net.NetPackage;
	import sg.net.NetSocket;
	import sg.utils.ArrayUtil;
	import sg.utils.ObjectUtil;
	import sg.utils.Tools;

	import ui.shop.shopMainUI;
	import sg.model.ModelShop;
	import sg.model.ModelUser;
	import sg.explore.model.ModelTreasureHunting;
	import sg.model.ModelArena;
	import laya.maths.Point;
	import sg.model.ModelEquip;

	/**
	 * ...
	 * @author
	 */
	public class ViewShopMain extends shopMainUI{

		public var configData:Object = ConfigServer.shop;
		//public var userData:Object={};
		//public var curShopData:Object;

		public var curShopIndex:int;//当前商店索引
		public var curShopID:String;//当前商店id
		//public var curItemIndex:int;//购买的商品的索引
		
		/*
		public var buyType:int=0;//购买类型：0:每日固定刷新  1:每日限购  2:专用货币购买
		public var isAutoRefresh:Boolean;//是否自动刷新
		public var isFirst:Boolean=false;
		public var barData:Array=[];//标签页数据
		public var listData:Array=[];
		
		public var costId:String="";
		public var costNum:Number=0;
		public var isInitList:Boolean=false;//是否初始化列表
		public var lock_obj:Object={};
		public var cost_type_num:Number=0;//专属消费币
		*/
		private var mModel:ModelShop;
		private var lock_obj:Object={};
		private var shopType:String="";
		private var barData:Array=[];
		private var mCostArr:Array;//花费的资源
		

		public function ViewShopMain(){
			this.shopType = 'hero_shop';
			this.itemList.scrollBar.visible=false;
			this.itemList.itemRender=listItem;
			this.itemList.renderHandler=new Handler(this,this.itemListRender);
			this.barList.itemRender=shopItem;
			this.barList.scrollBar.visible=false;
			this.barList.renderHandler=new Handler(this,this.shopListRender);
			this.barList.selectHandler=new Handler(this,this.shopOnSelect);
			this.btnRefresh.on(Event.CLICK,this,this.refreshClick);
			this.costCom.on(Event.CLICK,this,this.addClick);

			this.barList.scrollBar.changeHandler=new Handler(this,listScroll);

			this.text2.text=Tools.getMsgById("_shop_text02");
		}

		private function listScroll():void{
			var v:Number = barList.scrollBar.value;
            var max:Number = barList.scrollBar.max;
            arrow_l.visible = arrow_r.visible = true;
            if (v === 0) arrow_l.visible = false;
            if (v === max) arrow_r.visible = false;
		}
				
		override public function set currArg(value:*):void 
		{
			super.currArg = value;
			if (value is Object) {
				var type:* = value['curr_arg'];
				if (type is String) this.shopType = type;
				else this.shopType = ArrayUtil.find(ObjectUtil.keys(configData), function(shopData:Object):Boolean { return shopData.index - 1 === type;});
			}

		}

		override public function onAdded():void{
			arrow_l.visible = arrow_r.visible = false;
			this.costCom.visible=this.refreshCom.visible=false;
			ModelManager.instance.modelUser.on(ModelUser.EVENT_IS_NEW_DAY,this,eventCallBack);
			this.barList.selectedIndex=-1;
			curShopIndex=-1;
			
			this.itemList.array=[];
			this.setTitle(Tools.getMsgById("_shop_text01"));			
			setBarLabel();
			this.barList.scrollBar.touchScrollEnable=this.barList.repeatX>5;
			listScroll();
			lock_obj=ModelOffice.func_shoppos();
			shopItemClick(curShopIndex==-1?0:curShopIndex,true);	

		}

		public function eventCallBack():void{
			setUI();
		}

		public function setBarLabel():void{
			if(this.shopType != ""){
				curShopID = this.shopType;
			}
			barData=[];
			var i:Number=0;
			for(var s:String in configData){
				var d:Object = configData[s];
				var o:Object = {};
				if(d.hasOwnProperty("index") || s!="guild_shop"){
					o["index"] = d.index;
					o["id"]    = s;
					o["name"]  = d.name;
					var _text:String = "";
					var _visible:Boolean = true;
					var _gray:Boolean = false;
					if(ConfigServer.system_simple.func_open.hasOwnProperty(s)){
						var obj:Object = ModelGame.unlock(null,s);
						_text    = obj.text;
						_visible = obj.visible;
						_gray    = obj.gray;
					}
					o["text"]    = _text;
					o["visible"] = _visible;
					o["gray"]    = _gray;
					if(_visible){
						if (o.id === 'mining_shop') {
							ModelTreasureHunting.instance.active && barData.push(o);
						}else if(o.id === 'arena_shop'){
							ModelArena.instance.openShop() && barData.push(o);
						}
						else barData.push(o);
					}
				}
			}
			barData.sort(MathUtil.sortByKey("index",false,false));
			for(var index:int = 0; index < barData.length; index++)
			{
				var element:Object = barData[index];
				if(element.id==curShopID){
					curShopIndex=index;
				}
			}
			this.barList.array=barData;
		}

		public function shopListRender(cell:shopItem,index:int):void{
			var d:Object=barData[index];
			cell.setData(d);
			cell.setSelcetion(this.barList.selectedIndex==index);
			cell.off(Event.CLICK,this,this.shopItemClick);
			cell.on(Event.CLICK,this,this.shopItemClick,[index,false]);
		}

		public function shopItemClick(index:int,scroll:Boolean=false):void{
			if(this.barList.selectedIndex==index)
				return;

			if(barData[index].gray){
				ViewManager.instance.showTipsTxt(barData[index].text);
				return;
			}
			this.barList.selectedIndex=index;
			curShopIndex=index;
			curShopID=barData[index].id;
			mModel=ModelManager.instance.modelGame.getModelShop(curShopID);
			timer.clear(this,updateRefreshTime);
			NetSocket.instance.send("get_shop",{"shop_id":curShopID},Handler.create(this,this.socketCallBack));
			if(scroll){
				this.barList.scrollTo(index);
			}
			
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

		private function setList():void{
			this.itemList.array=mModel.getGoodsList();
		}

		public function shopOnSelect(index:int):void{
			if(index>=0){
                
            }
		}


		public function itemListRender(cell:listItem,index:int):void{
			var o:Object=this.itemList.array[index];
			cell.setData(o,index);

			var b1:Boolean=mModel.cfgAllLimit!=-1 && mModel.buy_times>=mModel.cfgAllLimit;
			var b2:Boolean=ModelItem.getMyItemNum(o.price[0])<o.price[1];

			if(b1 || b2){
				cell.btnBuy.gray=true;
			}

			if(lock_obj.hasOwnProperty(curShopID)){
				if((index+1)+""== lock_obj[curShopID][0]){
					cell.setLock(lock_obj[curShopID]);
				}
			}

			cell.btnBuy.off(Event.CLICK,this,this.itemClick);
			cell.btnBuy.on(Event.CLICK,this,this.itemClick,[index]);
			cell.com.off(Event.CLICK,this,this.iconClick);
			cell.com.on(Event.CLICK,this,this.iconClick,[o.id]);
			
			cell.off(Event.CLICK,this,this.itemClick2);
			cell.on(Event.CLICK,this,this.itemClick2,[index,cell]);
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
			var item:* = (this.itemList.getCell(index) as listItem).com;
			var pos:Point = Point.TEMP.setTo(item.x + item.width/2, item.y+item.height/2);
			pos = item['parent'].localToGlobal(pos, true);
			NetSocket.instance.send("buy_shop",sendData,Handler.create(this,this.socketCallBack3,[pos]));
		}

		public function socketCallBack3(pos:Point,np:NetPackage):void{
			ModelManager.instance.modelUser.updateData(np.receiveData);
			
			var o:Object=this.itemList.array[Number(np.sendData["goods_id"])-1];
			if(o && o.id.indexOf("equip")!=-1){
				ModelManager.instance.modelUser.checkUserData(["equip"]);
			}

			ModelManager.instance.modelProp.getRewardProp(np.receiveData.gift_dict,true);
			textTween();
			
			ViewManager.instance.showIcon(np.receiveData.gift_dict,pos.x,pos.y,false,"",true,1);
			setUI();
			
		}

		public function itemClick2(index:int,cell:listItem):void{
			if(cell.box.visible==false){
				if(lock_obj[curShopID]){
					GotoManager.boundForPanel(lock_obj[curShopID][2]["panelID"],lock_obj[curShopID][2]["secondMenu"]);
				}
			}
		}


		public function textTween():void{
			if(mModel.cfgCostType!=""){
				var n:Number=mCostArr[1];
				var l:Label=new Label();
				this.allBox.addChild(l);
				l.x=this.costCom.x+100;
				l.y=this.costCom.y+this.comNum.y-10;
				l.fontSize=18;
				l.text="-"+n;
				l.color="#ff1e00";
				Tween.to(l,{y:l.y-20},1200,null, Handler.create(this,function():void{
					allBox.removeChild(l);
				}));
			}
		}


		public function iconClick(s:String):void{
			ViewManager.instance.showItemTips(s);			
		}

		public function addClick():void{
			ViewManager.instance.showView(ConfigClass.VIEW_BAG_SOURSE,mModel.cfgCostType);
		}

		public function refreshClick():void{
			var arr:Array=mModel.cfgCostRefresh;
			if(arr){
				if(!Tools.isCanBuy(arr[0],arr[1])){
					return;
				}
			}
			var sendData:Object={};
			sendData["shop_id"]=curShopID;
			NetSocket.instance.send("user_refresh_shop",sendData,Handler.create(this,this.socketCallBack2));
		}

		public function socketCallBack2(np:NetPackage):void{
			ModelManager.instance.modelUser.updateData(np.receiveData);
			setUI();
		}

		public function updateRefreshTime():void{
			var n:Number=Tools.getTimeStamp(mModel.userData.refresh_time)-ConfigServer.getServerTimer();
			if(n<0){//当前时间大于刷新时间则刷新
				this.timerText.text="";
				timer.clear(this,updateRefreshTime);
				NetSocket.instance.send("get_shop",{"shop_id":curShopID},Handler.create(this,this.socketCallBack));
			}else{
				this.timerText.text=Tools.getTimeStyle(n);
				timer.once(1000,this,updateRefreshTime);
			}
			
		}

		override public function onRemoved():void{
			//timer.clear(this,this.timerUpdateList);
			//timer.clear(this,this.timerUpdateRefresh);
			this.barList.scrollBar.value=0;
			this.itemList.scrollBar.value=0;
			ModelManager.instance.modelUser.off(ModelUser.EVENT_IS_NEW_DAY,this,eventCallBack);
		}


		/*
		public function refreshClick():void{
			//Trace.log("刷新按钮");
			if(costId==""){
				return;
			}
			if(!Tools.isCanBuy(costId,costNum)){
				return;
			}
			user_refresh_shop();
		}

		public function setBarLabel():void{
			if(this.shopType != ""){
				curShopStr = this.shopType;
			}
			barData=[];
			var i:Number=0;
			for(var s:String in configData){
				var d:Object=configData[s];
				var o:Object={};
				if(d.hasOwnProperty("index") || s!="guild_shop"){
					o["index"]=d.index;
					o["id"]=s;
					o["name"]=d.name;
					var _text:String="";
					var _visible:Boolean=true;
					var _gray:Boolean=false;
					if(ConfigServer.system_simple.func_open.hasOwnProperty(s)){
						var obj:Object=ModelGame.unlock(null,s);
						_text=obj.text;
						_visible=obj.visible;
						_gray=obj.gray;
					}
					o["text"]=_text;
					o["visible"]=_visible;
					o["gray"]=_gray;
					if(_visible){
						barData.push(o);
					}
				}
			}
			barData.sort(MathUtil.sortByKey("index",false,false));
			for(var index:int = 0; index < barData.length; index++)
			{
				var element:Object = barData[index];
				if(element.id==curShopStr){
					curShopIndex=index;
				}
			}
			isInitList=false;
			this.barList.array=barData;
			this.barList.selectedIndex=curShopIndex;
			
			if(isFirst){
				getListData();
				if(this.barList.getCell(curShopIndex)){
					(this.barList.getCell(curShopIndex) as shopItem).setSelcetion(true);
					this.barList.scrollTo(curShopIndex);
				}else{
					// trace("---------error: error curIndex:",curShopIndex);
				}
			}else{
				shopItemClick(0);
				isFirst=false;
			}
			//
		}

		public function shopItemClick(index:int):void{
			if(index==curShopIndex)
				return;

			if(barData[index].gray){
				ViewManager.instance.showTipsTxt(barData[index].text);
				return;
			}
			this.setSelection(false);
			this.barList.selectedIndex=index;
			curShopStr=barData[index].id;
			curShopIndex=index;
			//Trace.log(curShopStr);
			get_shop();
		}

		public function socektCallBack(np:NetPackage):void{
			ModelManager.instance.modelUser.updateData(np.receiveData);
			getListData();
		}

		public function shopListRender(cell:shopItem,index:int):void{
			var d:Object=barData[index];
			cell.setData(d);
			cell.setSelcetion(this.barList.selectedIndex==index);
			cell.off(Event.CLICK,this,this.shopItemClick,[index]);
			cell.on(Event.CLICK,this,this.shopItemClick,[index]);
		}



		public function shopOnSelect(index:int):void{
			if(index>=0){
                //this.setSelection(true);
            }
		}

		public function setSelection(b:Boolean):void{
			if(this.barList.selection){
                //var item:shopItem = this.barList.selection as shopItem;
                //item.setSelcetion(b);
            }
		}

		public function getListData():void{
			listData=[];
			curShopData={};
			userData=ModelManager.instance.modelUser.shop;
			var curShopUser:Object={};
			curShopUser=userData[curShopStr];
			var curShopConfig:Object={};
			curShopConfig=configData[curShopStr];
			//下次刷新时间
			curShopData["refresh_time"]=curShopUser.refresh_time;
			//是否每日刷新
			var sec:Number=curShopConfig["day_fresh"][0][1];
			var _sec:String=sec<10?"0"+sec:sec+"";
			curShopData["day_refresh"]=(curShopConfig["day_fresh"].length==1)?curShopConfig["day_fresh"][0][0]+":"+_sec:"";
			//手动刷新时间
			curShopData["shop_time"]=curShopUser.shop_time;
			//该商店限购次数

			
			
			curShopData["all_limit"]=getLimitTimes();//curShopConfig.all_limit;
			//已经购买次数
			curShopData["buy_times"]=curShopUser.buy_times;
			//是否专用货币
			curShopData["cost_type"]=curShopConfig.hasOwnProperty("cost_type")?curShopConfig["cost_type"]:"";
			cost_type_num=ModelManager.instance.modelUser.property[curShopData["cost_type"]]?ModelManager.instance.modelUser.property[curShopData["cost_type"]]:0;
			//已刷新次数
			curShopData["user_refresh_times"]=curShopUser.user_refresh_times;
			if(!curShopConfig.hasOwnProperty("cost_refresh") || curShopConfig["cost_refresh"].length==0){
				curShopData["cost_refresh"]=[];
				curShopData["refresh_num"]=0;
			}else{
				var cost_refresh_num:int=0;
				curShopData["cost_refresh"]=curShopConfig.cost_refresh;//刷新按钮花费
				var len:int =curShopConfig.hasOwnProperty("cost_refresh")?curShopConfig.cost_refresh.length:0;
				for(var i:int = 0; i < len; i++)
				{
					if(curShopConfig.cost_refresh[i][1]==0){
						cost_refresh_num+=1;
					}else{
						break;
					}
				}
				curShopData["refresh_num"]=cost_refresh_num;
			}
			
			var configGoods:Object=curShopConfig.goods;
			var userGoods:Object=curShopUser.goods;
			for (var s:String in userGoods)
			{
				var d:Object={};
				var u:Array=userGoods[s];
				var cItem:Object=configGoods[s][u[0]];
				d["index"]=s;
				d["limit"]=cItem.limit;
				var itemModel:ModelItem=ModelManager.instance.modelProp.getItemProp(cItem.reward[0]);
				d["name"]=itemModel.name;
				d["icon"]=itemModel.icon;
				d["ratity"]=itemModel.ratity;
				d["type"]=itemModel.type;
				d["id"]=itemModel.id;
				d["num"]=cItem.reward[1];
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
			setPanelData();
		}

		public function setPanelData():void{
			timer.clear(this,this.timerUpdateRefresh);
			this.itemList.array=listData;

			if(curShopData["day_refresh"]!=""){
				this.text1.text=Tools.getMsgById("_shop_text03",[curShopData["day_refresh"]+""]);
			//	this.costCom.visible=false;
			}
			//else{
				if(curShopData["all_limit"]==-1){
					var s:String="";
					this.costCom.visible=curShopData.cost_type!="";
					//this.haveText.text=ModelItem.getMyItemNum(curShopData["cost_type"])+"";
					//this.costTypeIcon.skin=AssetsManager.getAssetItemOrPayByID(curShopData.cost_type);
					this.comNum.setData(AssetsManager.getAssetItemOrPayByID(curShopData.cost_type),Tools.textSytle(ModelItem.getMyItemNum(curShopData["cost_type"])));
					if(this.costCom.visible){
						text1.text="";
					}
				}else{
					this.text1.text=Tools.getMsgById("_shop_text04",[(curShopData["all_limit"]-curShopData["buy_times"])+"",curShopData["all_limit"]+""]);
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
					var t:String=Tools.getMsgById("_shop_text05",[(curShopData["refresh_num"]-curShopData["user_refresh_times"])+"",curShopData["refresh_num"]+""]);
					this.btnRefresh.setData("",t,-1,1);
				}else{
					this.btnRefresh.setData(AssetsManager.getAssetItemOrPayByID(costId),costNum,-1,0);
					//trace("++++++++++++++++++",AssetsManager.getAssetItemOrPayByID(costId));
				}
				
				timer.loop(5000,this,this.timerUpdateRefresh);
			}else{
				this.refreshCom.visible=false;
			}
			
			timer.loop(1000,this,this.timerUpdateList);
		}

		public function itemListRender(cell:listItem,index:int):void{
			//if(index==itemList.array.length){
			//	isInitList=true;
			//}
			cell.setData(this.itemList.array[index],index,!isInitList);
			cell.btnBuy.off(Event.CLICK,this,this.itemClick,[cell]);
			cell.btnBuy.on(Event.CLICK,this,this.itemClick,[cell]);
			cell.com.off(Event.CLICK,this,this.iconClick,[cell]);
			cell.com.on(Event.CLICK,this,this.iconClick,[cell]);
			
			if(lock_obj.hasOwnProperty(curShopStr)){
				if((index+1)+""== lock_obj[curShopStr][0]){
					cell.setLock(lock_obj[curShopStr]);
				}
			}
			cell.off(Event.CLICK,this,this.itemClick2,[index,cell]);
			cell.on(Event.CLICK,this,this.itemClick2,[index,cell]);
		}

		public function itemClick2(index:int,cell:listItem):void{
			if(cell.box.visible==false){
				if(lock_obj[curShopStr]){
					GotoManager.boundForPanel(lock_obj[curShopStr][2]["panelID"]);
				}
				
			}
		}

		public function timerUpdateList():void{
			if(ConfigServer.getServerTimer()>Tools.getTimeStamp(curShopData["refresh_time"])){//当前时间大于刷新时间则刷新
				this.timerText.text="";
				timer.clear(this,this.timerUpdateList);
				get_shop();
			}else{
				if(curShopData["day_refresh"]=="" && curShopData.hasOwnProperty("cost_refresh") && curShopData["cost_refresh"].length!=0){
					this.timerText.text=Tools.getTimeStyle(Tools.getTimeStamp(curShopData["refresh_time"])-ConfigServer.getServerTimer());
				}
			}
		}

		public function timerUpdateRefresh():void{
			if(Tools.isNewDay(curShopData["shop_time"])){
				get_shop();
				Trace.log("--------is new day");
			}
		}

		public function get_shop():void{
			var sendData:Object={};
			sendData["shop_id"]=curShopStr;
			NetSocket.instance.send("get_shop",sendData,Handler.create(this,this.socektCallBack));
		}

		public function user_refresh_shop():void{
			var sendData:Object={};
			sendData["shop_id"]=curShopStr;
			NetSocket.instance.send("user_refresh_shop",sendData,Handler.create(this,this.socketCallBack2));
		}

		public function socketCallBack2(np:NetPackage):void{
			ModelManager.instance.modelUser.updateData(np.receiveData);
			curShopData["user_refresh_times"]=np.receiveData.user.shop[curShopStr].user_refresh_times;
			getListData();
		}

		public function buy_shop():void{
			var sendData:Object={};
			sendData["shop_id"]=curShopStr;
			sendData["goods_id"]=curItemIndex+"";
			NetSocket.instance.send("buy_shop",sendData,Handler.create(this,this.socketCallBack3));
		}

		public function socketCallBack3(np:NetPackage):void{
			ModelManager.instance.modelProp.getRewardProp(np.receiveData.gift_dict,true);//获得的增量
			ModelManager.instance.modelUser.updateData(np.receiveData);//更新user数据
			textTween();
			getListData();
			//ModelManager.instance.modelProp.getRewardProp(np.receiveData.gift_dict);
			//ViewManager.instance.showView(ConfigClass.VIEW_GET_REWARD);
			//var com:bagItemUI=new bagItemUI();
			//var d:Object=this.itemList.getItem(curItemIndex-1);
			//com.setData(d.icon,d.ratity);
			//com.x=this.mouseX-100;
			//com.y=this.mouseY-100;
			//EffectManager.itemFlight(com,this.width/2,this.height, this);
			ViewManager.instance.showIcon(np.receiveData.gift_dict,this.mouseX-120,this.mouseY+80);
			
		}

		public function textTween():void{
			if(curShopData["cost_type"]!=""){
				var n:Number=ModelManager.instance.modelUser.property[curShopData["cost_type"]]-cost_type_num;
				var l:Label=new Label();
				this.allBox.addChild(l);
				l.x=this.costCom.x+100;
				l.y=this.costCom.y+this.comNum.y-10;
				l.fontSize=18;
				l.text=n+"";
				l.color="#ff1e00";
				Tween.to(l,{y:l.y-20},1200,null, Handler.create(this,function():void{
					allBox.removeChild(l);
				}));
			}
		}

		public function itemClick(cell:listItem):void{
			
			if(curShopData["all_limit"]!=-1 && curShopData["all_limit"]-curShopData["buy_times"]<=0){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_shop_tips01"));
				return;
			}
			if(cell.btnBuy.gray){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_shop_tips02"));
				return;
			}
			if(!Tools.isCanBuy(cell.price[0],cell.price[1])){
				return;
			}
			curItemIndex=cell.index;
			buy_shop();
		}

		

		public function getLimitTimes():Number{
			if(configData[curShopStr].add_limit){
				var arr:Array=configData[curShopStr].add_limit;//["id",1]
				var bId:String=arr[0];
				var blv:Number=ModelManager.instance.modelInside.getBuildingModel(bId).lv;
				return configData[curShopStr].all_limit + arr[1]*blv;
			}
			return configData[curShopStr].all_limit;
			
		}*/



	}

}

import sg.manager.AssetsManager;
import sg.manager.ModelManager;
import sg.model.ModelHero;
import sg.model.ModelItem;
import sg.model.ModelOffice;
import sg.model.ModelOfficeRight;
import sg.utils.Tools;

import ui.bag.bagItemUI;
import ui.shop.shopItemUI;
import ui.shop.shop_icon_textUI;


class listItem extends shopItemUI{

	public function listItem(){
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

	public function setLock(arr:Array):void{
		this.box.visible=false;
		var s:String=Tools.getMsgById(ModelOfficeRight.getCfgRight()[arr[1]].name);
		this.lockLabel.text=Tools.getMsgById("_shop_text07",[s+""]);//"“"++"”特权解锁后开启";
	}
}

class shopItem extends shop_icon_textUI{
	public function shopItem(){
		this.box1.visible=false;
	}

	public function setData(obj:*):void{
		this.img0.skin="ui/"+obj.id+".png";//=this.img1.skin
		this.label0.text=this.label1.text=Tools.getMsgById(obj.name);
	}


	

	public function setSelcetion(b:Boolean):void{
		this.box1.visible=b;
		this.label0.visible=!b;
	}
}