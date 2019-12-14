package sg.activities.model
{
	import sg.manager.ModelManager;
	import sg.utils.Tools;
	import sg.cfg.ConfigServer;
	import sg.model.ModelUser;
	import laya.maths.MathUtil;	
	import laya.events.EventDispatcher;
	import sg.cfg.ConfigClass;
	import sg.manager.ViewManager;

	/**
	 * ...
	 * @author
	 */
	public class ModelFreeBuy extends EventDispatcher{
		private static var sModel:ModelFreeBuy = null;
		public static const EVENT_ChANGE_FREE_BUY:String="event_change_free_buy";

		public var mData:Array=[];
		public var curKey:String="";
		public var gtaskTime:int = 0;
		public var gtaskJustRefresh:Boolean = false;

		public static function get instance():ModelFreeBuy
		{
			return sModel ||= new ModelFreeBuy();
		}
		
		public function ModelFreeBuy(){
			this.initData();
		}

		public function initData():void{
			gtaskTime = Tools.getTimeStamp(ModelManager.instance.modelUser.records.pay_gtask_reward[1]);
		}

		public function addData():void{
			checkData();
			if(mData.length!=0){
				this.event(ModelFreeBuy.EVENT_ChANGE_FREE_BUY);
			}
		}

		/**
		 * 检查是否有数据
		 */
		public function checkData():Boolean{
			mData=[];
			var now:Number=ConfigServer.getServerTimer();
			var user_free_buy:Object=ModelManager.instance.modelUser.records.free_buy;
			for(var s:String in user_free_buy){
				if(user_free_buy[s]!=null && Tools.getTimeStamp(user_free_buy[s][1])>now){
					var n:Number=ModelUser.cost_id_arr.indexOf(s);
					var o:Object=user_free_buy[s];
					var info:Array=ConfigServer.ploy.free_buy.show_info[o[0]+"_"+s];
					mData.push({"id":o[0],
					            "key":s,//钱粮木铁
								"index":n,
								"title":info[0],
								"info":info[1],
								"hero":info[2],
								"time":o[1],
								"pay_num":o[0]=="pay" ? o[3] : 0,    //需要充值的数额
								"my_num" :o[0]=="pay" ? o[2] : 0,    //我已经充值的数额
								"buy_num":o[0]=="pay" ? 0 : o[2],     //购买数额
								"get_num":o[0]=="pay" ? o[4]:o[3]     //获得的数额 
								});
				}
			}

			// 判断凤雏理政
			var pay_gtask_reward:Array = ModelManager.instance.modelUser.records.pay_gtask_reward;
			var buy_gtask:Object = ConfigServer.ploy.buy_gtask;
			if (pay_gtask_reward is Array && buy_gtask) {
				var gtaskEndTime:* = pay_gtask_reward[1];
				if (pay_gtask_reward[2] === 1 || Tools.getRemainTime(gtaskEndTime) > 0) {
					var id:String = 'gtask';
					mData.push({
						"id": id,
						"key":"",
						"index": mData.length,
						"title": buy_gtask['name'],
						"time": (pay_gtask_reward[2] === 1 ? 0 : gtaskEndTime),
						"info": buy_gtask['info'],
						"hero": buy_gtask['hero'],
						"my_num":pay_gtask_reward[3] * 10,
						"pay_num" :buy_gtask['pay_money'] * 10,
						"buy_num":0,
						"get_num":0
					});
					//user_free_buy[id] = ["gtask",gtaskEndTime,pay_gtask_reward[3] * 10,buy_gtask['pay_money'] * 10, buy_gtask['mulit']];
				}
			}
            var st:Number= 0;
			// 判断购买武器
			var buy_weapon:Object = ModelManager.instance.modelUser.records.buy_weapon;
			var cfg_buy_weapon:Object=ConfigServer.ploy.buy_weapon;
			if (cfg_buy_weapon && buy_weapon) {
				for(var w:String in buy_weapon){
					if(buy_weapon[w][0]==1) continue;
					st=Tools.getTimeStamp(buy_weapon[w][2]);
					//时间之内 或者 已经达成充值标准
					if(now<st || buy_weapon[w][1]>=cfg_buy_weapon.para[w][0]){
						mData.push({
							"id"     : "buy_weapon",
							"key"    : w,
							"index"  : mData.length,
							"title"  : cfg_buy_weapon['name'],
							"time"   : (buy_weapon[w][1]>=cfg_buy_weapon.para[w][0] ? 0 : buy_weapon[w][2]),
							"info"   : cfg_buy_weapon['info'],
							"hero"   : cfg_buy_weapon['hero'],
							"pay_num": cfg_buy_weapon.para[w][0] * 10,
							"my_num" : buy_weapon[w][1] * 10,
							"reward" : cfg_buy_weapon.para[w][1]
						});
					}
					//user_free_buy["buy_weapon_"+w] = ["buy_weapon",buy_weapon[w][2], buy_weapon[w][1],cfg_buy_weapon.para[w][0]];
				}
			}

			var loginNum:Number = ModelManager.instance.modelUser.loginDateNum;
			var cfg_day_buy_weapon:Object = ConfigServer.ploy.day_buy_weapon;
			var day_buy_weapon:Object = ModelManager.instance.modelUser.records.day_buy_weapon;
			if (cfg_day_buy_weapon) {
				for(var ww:String in cfg_day_buy_weapon){
					if(day_buy_weapon && day_buy_weapon[ww] && day_buy_weapon[ww][1]==1) continue;
					//时间之内 或者 已经达成充值标准
					var wo:Object = cfg_day_buy_weapon[ww];
					var open_day:Array = wo.open_day;
					if((loginNum>=open_day[0] && loginNum<=open_day[1])){// || "达到充值额度"
						mData.push({
							"id"     : "day_buy_weapon",
							"key"    : ww,
							"index"  : mData.length,
							"title"  : wo['name'],
							"time"   : Tools.getTimeDate(ConfigServer.getServerTimer()+Tools.getDayDisTime()+(open_day[1]-loginNum)*Tools.oneDayMilli),
							"info"   : wo['info'],
							"hero"   : wo['hero'],
							"buy_num":0,
							"pay_num": wo.need_pay * 10,//要求的充值额度
							"my_num" : day_buy_weapon && day_buy_weapon[ww] ? day_buy_weapon[ww][0] * 10 : 0,//当前充值
							"reward" : wo.reward
						});
					}
				}
			}

			var len:Number = mData.length;
			if(mData.length==0){
				return false;
			}else{
				mData.sort(MathUtil.sortByKey("index",false));
				return true;
			}
		}

		/**
		 * 返回剩余时间
		 */
		public function getTime():Number{
			if(mData.length==0){

			}else{
				if (this.red_point()) {
					return 0;
				}
				var time:Number=0;
				var now:Number=ConfigServer.getServerTimer();
				for(var i:int=0;i<mData.length;i++){
					var n:Number=Tools.getTimeStamp(mData[i].time);
					if(n>now){
						if(time==0){
							time=n;
						}
						if(n<time){
							time=n;
						}
					}
				}
				if(time==0){
					var len:Number = this.mData.length;
					this.checkData();
					if(len != mData.length){
						this.event(ModelFreeBuy.EVENT_ChANGE_FREE_BUY);
					}
				}else{
					var t:Number=time-now;
					return t;
				}
			}
			
			return 0;
		}

		public function red_point():Boolean{
			var obj:Object=ModelManager.instance.modelUser.records.free_buy;
			for(var s:String in obj){
				if(obj[s]){
					var arr:Array=obj[s];
					if(arr[1]=="pay" && arr[1]>=arr[2]){//充值 且可领取
						return true;
					}
				}
			}
			var pay_gtask_reward:Object = ModelManager.instance.modelUser.records.pay_gtask_reward;
			if (pay_gtask_reward[2] === 1)	return true;

			var buy_weapon:Object = ModelManager.instance.modelUser.records.buy_weapon;
			if(buy_weapon && ConfigServer.ploy.buy_weapon){
				for(var k:String in buy_weapon){
				//未领取 && 达到充值数额
					if(buy_weapon[k][0]==0 && buy_weapon[k][1]>=ConfigServer.ploy.buy_weapon.para[k][0]){
						return true;
					}
				}
			}

			var day_buy_weapon:Object = ModelManager.instance.modelUser.records.day_buy_weapon;
			if(day_buy_weapon && ConfigServer.ploy.day_buy_weapon){
				for(var dbw:String in day_buy_weapon){
				//未领取 && 达到充值数额
					if(day_buy_weapon[dbw][1]==0){
						if(ConfigServer.ploy.day_buy_weapon[dbw]){
							if(day_buy_weapon[dbw][0]>=ConfigServer.ploy.day_buy_weapon[dbw].need_pay){
								return true;
							}
						}
					}
				}
			}

			return false;
		}

		public function click():void{
			ViewManager.instance.showView(ConfigClass.VIEW_FREE_BUY);	
		}
	}

}