package sg.view.menu
{
	import ui.menu.topUI;
	import sg.view.ViewPanel;
	import sg.manager.AssetsManager;
	import sg.manager.ModelManager;
	import sg.model.ModelUser;
	import laya.ui.Label;
	import laya.utils.Tween;
	import laya.utils.Handler;
	import sg.utils.Tools;
	import laya.events.Event;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import sg.boundFor.GotoManager;
	import sg.model.ModelGame;
	import sg.cfg.ConfigServer;

	/**
	 * ...
	 * @author
	 */
	public class ViewMenuTop extends topUI{

		public var userModel:ModelUser;
		public var oldData:Array=[];
		public var newData:Array=[];
		public var com_arr:Array=[];
		public var str_arr:Array=[];
		public var btn_arr:Array=[];	
		public var num_arr:Array=[0,0,0,0,0,0];
		public function ViewMenuTop(){

			this.gold.on(Event.CLICK,this,this.click,[gold]);
			this.food.on(Event.CLICK,this,this.click,[food]);
			this.wood.on(Event.CLICK,this,this.click,[wood]);
			this.iron.on(Event.CLICK,this,this.click,[iron]);
			this.merit.on(Event.CLICK,this,this.click,[merit]);

			ModelManager.instance.modelUser.on(ModelUser.EVENT_TOP_UPDATE,this,listenCallBack);
			//
			com_arr=[this.gold_var,this.food_var,this.wood_var,this.iron_var,this.coin_var,this.merit_var];
			btn_arr=[this.gold,this.food,this.wood,this.iron,this.coin,this.merit];
			str_arr=["gold","food","wood","iron","coin","merit"];
			userModel=ModelManager.instance.modelUser;
			this.coin.on(Event.CLICK,this,this.coin_var_click);
			this.coin_red.visible = false;
			this.redTween();
			this.refresh();

		}

		/**
		 * 检查有没有快过期的抵扣券
		 */
		private function checkCoinRed():void{
			var user:ModelUser = ModelManager.instance.modelUser;
			if(user.sale_pay==null) return;

			var arr:Array = user.sale_pay;
			var now:Number = ConfigServer.getServerTimer();
			var b:Boolean = false;
			for(var i:int=0;i<arr.length;i++){
				var time:Number =Tools.getTimeStamp(arr[i][2]);
				if(now<time && time - now < 24*Tools.oneHourMilli){
					b = true;
					break;
				}
			}
			this.coin_red.visible = b && user.canPay;
			
			var tt:Number = 15;
			tt = ConfigServer.system_simple.npc_info_time?ConfigServer.system_simple.npc_info_time:tt;
			this.timer.clear(this,this.checkCoinRed);
			this.timer.once(tt*Tools.oneMillis,this,this.checkCoinRed);
		}

		private function redTween():void{
			Tween.to(this.coin_red,{"alpha":0.7},1000,null,new Handler(this,function():void{
				Tween.to(this.coin_red,{"alpha":1},1000,null,new Handler(this,function():void{
					redTween();
				}));
			}));
		}

		public function refresh():void{
			var user:ModelUser = ModelManager.instance.modelUser;
			this.coin_add.visible = !ModelGame.unlock(null,"pay").stop && user.canPay;
			if(oldData.length==0){
				this.gold_var.setData(AssetsManager.getAssetsUI(AssetsManager.IMG_GOLD),Tools.textSytle(user.gold));
				this.food_var.setData(AssetsManager.getAssetsUI(AssetsManager.IMG_FOOD),Tools.textSytle(user.food));
				this.wood_var.setData(AssetsManager.getAssetsUI(AssetsManager.IMG_WOOD),Tools.textSytle(user.wood));
				this.iron_var.setData(AssetsManager.getAssetsUI(AssetsManager.IMG_IRON),Tools.textSytle(user.iron));
				this.coin_var.setData(AssetsManager.getAssetsUI(AssetsManager.IMG_COIN),Tools.textSytle(user.coin));
				this.merit_var.setData(AssetsManager.getAssetsUI(AssetsManager.IMG_MERIT),Tools.textSytle(user.merit));
				oldData=[userModel.gold,userModel.food,userModel.wood,userModel.iron,userModel.coin,userModel.merit];
			}
			
			checkCoinRed();
		}

		public function click(obj:*):void{
			switch(obj){
				case gold:
					ViewManager.instance.showView(ConfigClass.VIEW_BAG_SOURSE,"gold");
				break;
				case wood:
					ViewManager.instance.showView(ConfigClass.VIEW_BAG_SOURSE,"wood");
				break;
				case food:
					ViewManager.instance.showView(ConfigClass.VIEW_BAG_SOURSE,"food");
				break;
				case iron:
					ViewManager.instance.showView(ConfigClass.VIEW_BAG_SOURSE,"iron");
				break;
				case merit:
					ViewManager.instance.showView(ConfigClass.VIEW_BAG_SOURSE,"merit");
				break;
			}
		}

		public function listenCallBack(arr:Array):void{
			
			//newData=[userModel.gold,userModel.food,userModel.wood,userModel.iron,userModel.coin,userModel.merit];
			//Trace.log("top监听到刷新消息",oldData,newData);
			for(var i:int = 0; i < arr.length; i++)
			{
				var o:Object=arr[i];
				for(var s:String in o)
				{
					var n:Number=str_arr.indexOf(s);
					if(n>=0){
						labelTween(n,o[s]);
					}
					
				}
				//var n1:Number=newData[i];
				//var n2:Number=oldData[i];
				//if(n1-n2!=0){
				//	labelTween(i,n1-n2);
				//}				
			}
			
		}

		public function labelTween(index:int,num:Number):void{
			var l:Label=new Label();
			l.x=(index==4)?btn_arr[index].x+btn_arr[index].width/2:btn_arr[index].x+30;
			l.y=btn_arr[index].height/2;
			l.fontSize=18;
			if(num<0){
				l.text=num+"";
				l.color="#ff1e00";
			}else if(num>0){
				l.text="+"+num;
				l.color="#3dff00";
			}
			var delayNum:Number=(num>0)?1200+num_arr[index]*150:0;
			if(delayNum!=0){
				Laya.timer.once(delayNum,this,tweenFunc,[l,index],false);
			}else{
				this.tweenFunc(l,index);
			}
			num_arr[index]+=1;
			//trace("==========",num_arr[index]);
		}

		private function tweenFunc(l:Label,index:int):void{
			this.addChild(l);
			Tween.to(l,{y:l.y-20},1200,null, Handler.create(this,tweenCallBack,[l,index]));
		}

		private function tweenCallBack(ll:Label,index:int):void{
			num_arr[index]=num_arr[index]>=0?num_arr[index]-1:0;
			//trace("------------",num_arr[index]);
			//this.removeChild(ll);
			ll.destroy();
			// this.com_arr[index].setData(AssetsManager.getAssetItemOrPayByID(str_arr[index]),Tools.textSytle(userModel[str_arr[index]]));
			this.com_arr[index].setNum(Tools.textSytle(userModel[str_arr[index]]));
			oldData=[userModel.gold,userModel.food,userModel.wood,userModel.iron,userModel.coin,userModel.merit];
		}


		public function coin_var_click():void{
			GotoManager.boundForPanel(GotoManager.VIEW_PAY_TEST);
		}
	}

}