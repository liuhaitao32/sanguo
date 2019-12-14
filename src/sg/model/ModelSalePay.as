package sg.model
{
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;
	import sg.utils.Tools;
	import sg.manager.AssetsManager;
	import sg.map.utils.ArrayUtils;
	import sg.manager.ViewManager;

	/**
	 * ...
	 * @author
	 */
	public class ModelSalePay extends ModelBase{

		public static var salePayModels:Object = {};
		public static var saleObj:Object = {};//{pid("payId1"):[saleId1,saleId2...]}
		public static var selectedObj:Object = {};//{pid("payId1"):saleId}

		public var id:String;
		public var rarity:Number;
		public var payId1:String;//用于抵扣的档位
		public var payId2:String;//真实的购买档位

		public static var sTime:Number = 0;//点击充值的时间
		public static var sGap:Number = 2000;//点击充值的间隔

		public function ModelSalePay(){
			
		}

		public static function isCanClick():Boolean{
			var b:Boolean = false;
			if(sTime == 0){
				sTime = ConfigServer.getServerTimer();
				return true;
			}else{
				var now:Number = ConfigServer.getServerTimer();
				if(now - sTime > sGap){
					sTime = now;
					return true;
				}else{
					ViewManager.instance.showTipsTxt(Tools.getMsgById('_public248'));
				}
			} 
			return false;
		}

		/**
		 * 功能是否打开
		 */
		public static function isActive():Boolean{
			return ConfigServer.system_simple.sale_pay != null;
		}

		/**
		 * 
		 */
		public static function getSeletedByPid(pid:String):String{
			return selectedObj[pid] ? selectedObj[pid] : "";
		}

		/**
		 * 
		 */
		public static function setSeletedObj(pid:String,sid:String):void{
			selectedObj[pid] = sid;
		}

		public static function initModels():void{
			if(ConfigServer.system_simple.sale_pay){
				var cfg:Object = ConfigServer.system_simple.sale_pay;
				for(var s:String in cfg){
					var a:Array = cfg[s];
					var md:ModelSalePay = new ModelSalePay();
					md.payId1 = a[0];
					md.id = a[1];
					md.rarity = a[2];
					md.payId2 = s;
					salePayModels[a[1]] = md;
				}
			}

			setSaleObj();
		}

		public static function getModel(_id:String):ModelSalePay{
			if(salePayModels[_id]){
				return salePayModels[_id];
			}
			return null;
		}

		/**
		 * 获得节约的钱数
		 */
		public function getSaleMoney():Number{
			var cfg:Object = ConfigServer.pay_config;
			var n1:Number = Number(ModelManager.instance.modelUser.getPayMoney(payId1,cfg[payId1][0]));
			var n2:Number = Number(ModelManager.instance.modelUser.getPayMoney(payId2,cfg[payId2][0]));
			return n1-n2;
		}

		/**
		 * x元抵扣券（n天）
		 */
		public function getName(time:*=null):String{
			var n:Number = getSaleMoney();
			var m:Number = 1;
			if(time==null || time == 0){
				var arr:Array = ModelManager.instance.modelUser.sale_pay ? ModelManager.instance.modelUser.sale_pay : [];
				for(var i:int=0;i<arr.length;i++){
					if(arr[i][0]==this.id){
						//m = Math.round((Tools.getTimeStamp(arr[i][2]) - Tools.getTimeStamp(arr[i][1]))/Tools.oneDayMilli);
						m = Tools.getTimeStamp(arr[i][2]) - Tools.getTimeStamp(arr[i][1]);
					}
				}
			}else{
				//m = Math.round(time*Tools.oneMinuteMilli / Tools.oneDayMilli);
				m = time*Tools.oneMinuteMilli;
			}
			if(m>Tools.oneDayMilli){
				m = Math.round(m/Tools.oneDayMilli);
				return Tools.getMsgById("sale_pay_11",[n,m + Tools.getMsgById("sale_pay_15")]);
			}else{
				m = Math.round(m/Tools.oneMinuteMilli);
				return Tools.getMsgById("sale_pay_11",[n,m + Tools.getMsgById("sale_pay_14")]);
			}
		}

		/**
		 * 用于x元充值时抵扣
		 */
		public function getInfo():String{
			var cfg:Object = ConfigServer.pay_config;
			var n1:Number = Number(ModelManager.instance.modelUser.getPayMoney(payId1,cfg[payId1][0]));
			return Tools.getMsgById("sale_pay_08",[n1]);
		}

		public function getNum():Number{
			var m:Number = 0;
			var arr:Array = ModelManager.instance.modelUser.sale_pay ? ModelManager.instance.modelUser.sale_pay : [];
			for(var i:int=0;i<arr.length;i++){
				if(arr[i][0]==this.id){
					if(Tools.getTimeStamp(arr[i][2])>ConfigServer.getServerTimer()){
						m++;
					}
				}
			}
			return m;
		}

		public function getIcon():String{
			return AssetsManager.getAssetLater("pay_coupon_"+(this.rarity+1)+".png");
		}

		/**
		 * 剩余时间毫秒值
		 */
		public function get lastTimeStamp():Number{
			return 0;
		}

		/**
		 * 过期时间点
		 */
		public function get lastTime():String{
			return "";
		}

		/**
		 * 初始化时调用一次
		 * 充值列表中的pid:[可用抵扣券id,]
		 */
		public static function setSaleObj():void{
			if(ConfigServer.system_simple.sale_pay){
				var cfg:Object = ConfigServer.system_simple.sale_pay;
				for(var s:String in cfg){
					var a:Array = cfg[s];
					if(saleObj[a[0]]){
						var arr:Array = saleObj[a[0]];
						arr.push(a[1]);
						saleObj[a[0]] =  arr;
					}else{
						saleObj[a[0]] = [a[1]];
					}
				}
			}
		}


		/**
		 * 根据pid找到saleID的列表
		 */
		public static function getSaleArrByPId(pid:String):Array{
			if(saleObj[pid]){
				return saleObj[pid];
			}
			return [];
		}

		/**
		 * 根据pid找到兑换券数量
		 */
		public static function getNumByPId(pid:String):Number{
			var arr:Array = getSaleArrByPId(pid);
			var n:Number = 0;			
			for(var i:int=0;i<arr.length;i++){
				var md:ModelSalePay = ModelSalePay.getModel(arr[i]);
				if(md){
					n+=md.getNum();
				}
			}
			return n;
		}

		/**
		 * 获得当前pid的最大抵扣券（拥有的）
		 */
		public static function getMaxSaleByPId(pid:String):String{
			var s:String = getSeletedByPid(pid);
			if(s==pid) return s;

			if(s != ""){
				if(ModelSalePay.getModel(s)){
					if(ModelSalePay.getModel(s).getNum()!=0){
						return s;
					}else{
						s = "";
					}
				}
			}
			
			var arr:Array = saleObj[pid] ? saleObj[pid] : [];
			var n:Number = 0;//最大折扣的钱数
			for(var i:int=0;i<arr.length;i++){
				if(ModelSalePay.getModel(arr[i]).getNum()!=0){
					var m:Number = ModelSalePay.getModel(arr[i]).getSaleMoney();
					if(m>n){
						n = m;
					}	
				}
			}

			for(var j:int=0;j<arr.length;j++){
				if(ModelSalePay.getModel(arr[j]).getNum()!=0){
					if(n == ModelSalePay.getModel(arr[j]).getSaleMoney()){
						s = arr[j];
						break;
					}	
				}	
			}
			setSeletedObj(pid,s);
			return s;
		}

		/**
		 * 快过期的兑换券id
		 */
        public static function getNearlyOverSID(pid:String):String{
			var arr:Array = getSaleArrByPId(pid);
			var saleArr:Array = ModelManager.instance.modelUser.sale_pay ? ModelManager.instance.modelUser.sale_pay : [];
			var now:Number = ConfigServer.getServerTimer();
			for(var i:int=0;i<arr.length;i++){
				var sid:String = arr[i];
				for(var j:int=0;j<saleArr.length;j++){
					if(sid == saleArr[j][0]){
						var time:Number =Tools.getTimeStamp(saleArr[j][2]);
						if(now<time && time - now < 24*Tools.oneHourMilli){
							return sid;
						}
					}
				}
			}
			return "";
		}


		/**
		 * 根据pid返回充值的黄金数
		 */
		public static function getCoinNumByPID(pid:String,ab:Boolean =false):Number{
            var isSale:Boolean = false;//是否折扣档
			var newPid:String = pid;
            if(ConfigServer.system_simple.sale_pay){
                if(ConfigServer.system_simple.sale_pay[pid]){
                    newPid = ConfigServer.system_simple.sale_pay[pid][0];
                    isSale = true;
                }
            }
			return ConfigServer.pay_config[newPid] ? (ab?ConfigServer.pay_config[newPid][0]:ConfigServer.pay_config[newPid][1]) : 0; 
		}

		/**
		 * 获得即将过期的列表
		 */
		public static function getOverdueList():Array{
			if(!ConfigServer.system_simple.sale_tips || !ConfigServer.system_simple.sale_tips.open) 
				return [];
			
			var saleArr:Array = ModelManager.instance.modelUser.sale_pay ? ModelManager.instance.modelUser.sale_pay : [];
			if(saleArr.length == 0) return [];
			var arr:Array = [];
			var now:Number = ConfigServer.getServerTimer();
			var cfgTime:Number = ConfigServer.system_simple.sale_tips.time*Tools.oneMinuteMilli;
			for(var i:int=0;i<saleArr.length;i++){
				var md:ModelSalePay = ModelSalePay.getModel(saleArr[i][0]);
					var n1:Number = Tools.getTimeStamp(saleArr[i][1]);
					var n2:Number = Tools.getTimeStamp(saleArr[i][2]);
					if(n2 > now && n2 - now < cfgTime){
						arr.push({"id":md.id,
										"pid":md.payId2,
										"name":md.getName(),
										"n1":n1,
										"n2":n2,
										"skin":md.getIcon(),
										//原价
										"money":ModelManager.instance.modelUser.getPayMoney(md.payId1,ConfigServer.pay_config[md.payId1][0]),
										"sort2":9999-md.getSaleMoney(),
										"sort1":n2-now});
					}
			}
			arr = ArrayUtils.sortOn(["sort1","sort2"],arr,false);
			return arr;
		}

	}

}