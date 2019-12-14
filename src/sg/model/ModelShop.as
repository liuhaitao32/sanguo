package sg.model
{
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;
	import laya.maths.MathUtil;

	/**
	 * ...
	 * @author
	 */
	public class ModelShop extends ModelBase{

		public static var shopModels:* = {};
		public var cfg:Object;
		//public var user:Object;
		public var shopID:String;
		public function ModelShop(){
			
		}

		public function initData(key:String):void{
			shopID=key;
			cfg=ConfigServer.shop[key];
			//user=ModelManager.instance.modelUser.shop[key];
		}

		public function get userData():Object{
			return ModelManager.instance.modelUser.shop[shopID];
		}
		/**
		 * 已购买次数
		 */
		public function get buy_times():Number{
			return ModelManager.instance.modelUser.shop[shopID]["buy_times"];
		}

		/**
		 * 总的限制购买次数 -1表示无限
		 */
		public function get cfgAllLimit():Number{
			return cfg.all_limit ? cfg.all_limit + addBuyNum : -1;
		}	
		/**
		 * 
		 */
		public function get cfgCostRefresh():Array{
			var arr:Array=cfg.cost_refresh;
			var n:Number=ModelManager.instance.modelUser.shop[shopID].user_refresh_times;
			if(arr && arr.length>0){
				if(n>=arr.length){
					return arr[arr.length-1];
				}else{
					return arr[n];
				}
			}
			return null;
		}

		/**
		 * 统一购买货币
		 */
		public function get cfgCostType():String{
			return cfg.cost_type ? cfg.cost_type : "";
		}

		/**
		 * 别的条件增加的购买次数
		 */
		public function get addBuyNum():Number{
			var arr:Array=cfg.add_limit;//["封地建筑id",个数]
			if(arr){
				var bId:String=arr[0];
				var blv:Number=ModelManager.instance.modelInside.getBuildingModel(bId).lv;
				return arr[1]*blv;
			}
			return 0;
		}

		/**
		 * 商店购买列表
		 */
		public function getGoodsList():Array{
			var arr:Array=[];
			var configGoods:Object=cfg.goods;
			var user:Object=ModelManager.instance.modelUser.shop[shopID];
			var userGoods:Object=user.goods;
			for (var s:String in userGoods)
			{
				var d:Object={};
				var u:Array=userGoods[s];
				var cItem:Object;
				var c_first:Object=configGoods[s].first_buy;
				var c_n:Number=user.first_buy && user.first_buy[s] ? user.first_buy[s] : 0;
				if(c_first){
					if(user.first_buy && c_n<c_first.limit){
						cItem=c_first;
						d["buy_num"]=c_n;
						d["first_buy"]=true;
					}else{
						cItem=configGoods[s][u[0]];
						d["buy_num"]=u[1];
						d["first_buy"]=false;
					}
				}else{
					cItem=configGoods[s][u[0]];
					d["buy_num"]=u[1];
					d["first_buy"]=false;
				}
				
				d["index"]=s;
				d["limit"]=cItem.limit;
				d["type"]=0;
				if(cItem.reward[0]=="equip"){
					d["id"]=cItem.reward[1];
					d["num"]=1;
				}else{
					d["id"]=cItem.reward[0];
					d["num"]=cItem.reward[1];
					d["type"]=ModelItem.getItemType(d["id"]);
				}
				var p1:Number=0;
				var p2:Number=0;
				p1=u[1]*cItem.price[3]+cItem.price[1];
				p2=p1/cItem.price[2]*10;
				p2.toFixed(1);
				d["price"]=[cItem.price[0],p1,p2];
				arr.push(d);
			}
			arr.sort(MathUtil.sortByKey("index",false,true));
			return arr;
		}
	}

}