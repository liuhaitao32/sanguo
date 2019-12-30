package sg.activities.model
{
    import sg.model.ViewModelBase;
    import laya.maths.MathUtil;
    import sg.manager.ViewManager;
    import laya.maths.Point;
    import sg.utils.Tools;
    import sg.utils.ObjectUtil;

    public class ModelTreasureBase extends ViewModelBase {
        public static const KEY_TREASURE:String = 'treasure';
        public static const KEY_FES_TREASURE:String = 'fesvital_treasure';

        public var cfg:Object = null;
		public var mBuyTimesOne:Number=0;
		public var mBuyTimesFive:Number=0;
		public var mScore:Number=0;
		public var mShopObj:Object;
		protected var mShopList:Array;
		protected var key:String;
		public var buy_method:String;
		public var buy_method_shop:String;
        public function ModelTreasureBase() {
        }

		/**
		 * 额外奖励列表
		 */
		public function get addList():Array {
			var obj:Object = addCfg;
			var arr:Array=[];
			for(var s:String in obj){
				arr.push([Number(s),obj[s]]);
			}
			arr.sort(MathUtil.sortByKey("0",false,false));
			return arr;
		}

		/**
		 * 奖池数据
		 */
		public function getAwradList():Array{
			var arr:Array=[];
			var award:Array = awardCfg;
			for(var i:int=0;i<award.length;i++){
				var b:Boolean=award[i][3] && award[i][3]==1;
				arr.push([award[i][1],award[i][2],b]);
			}
			return arr;
		}

		override public function get redPoint():Boolean{
			if (!active) return false;
			if(red_point_free_time()){
				return true;
			}
			return shopRedPoint;
		}

		/**
		 * 是否可以免费抽取
		 */
		public function red_point_free_time():Boolean{
			if (!active) return false;
			var n1:Number=this.cfg.buy_one[0]-this.mBuyTimesOne;
			var n5:Number=this.cfg.buy_five[0]-this.mBuyTimesFive;
			if(n1>0 || n5>0){
				return true;
			}
			return false;
		}

		/**
		 * 商店物品数据
		 */
		public function getShopData():Array{
			var arr:Array=[];
			var cfgData:Array = shopCfg;
			for (var i:int = 0, len:int = cfgData.length; i < len; ++i) {
                var source:Object = {};
                var data:Array = cfgData[i];
				var n:Number=mShopObj.hasOwnProperty(i)?mShopObj[i]:0;
                source.goods_id      = String(i+1);
                source.limitTimes    = data[3];				
                source.reward        = [data[0],data[1]];
                source.buyTimes      = n;
                source.price         = data[2];
                source.originalPrice = data[2];
                source.needMoney     = 0;
                source.state         = n>=data[3]?2:1;   // 0:不可购买，1：可购买，2：已售罄
                source.key           = key;
				source.itemId        = "";
				source.totalMoney    = this.mScore;
				if (data[0] === 'awaken') {
					source.awaken = data[1][0];
				}
                arr.push(source);
            }
			mShopList=arr;
			return arr;
		}

		public function buyGoods(index:Number, pos:Point):void{
			var obj:Object=mShopList[index];
			if(obj.price>obj.totalMoney){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("treasure_tips01"));//积分不足
				return ;
			}
			if(obj.limitTimes - obj.buyTimes==0){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("treasure_tips02"));//次数不足
				return ;
			}
			ModelActivities.instance.buyGoodsWithoutHint(buy_method_shop, {"shop_index":index}, pos);
		}

		/**
		 * 商店红点
		 */
		public function get shopRedPoint():Boolean{
			if (!active) return false;
			var arr:Array = ObjectUtil.clone(shopCfg) as Array;
			arr.sort(MathUtil.sortByKey("2"),false,false);
			var min:Number=arr[0][2];
			if(mScore>=min){
				return true;
			}
			return false;
		}

        public function get awardList():Array{
            return [];
        }

        public function get shopCfg():Array{
            return [];
        }

        public function get addCfg():Object{
            return {};
        }

        public function get awardCfg():Array{
            return [];
        }

        public function get remainTime():String {
            return '';
        }

        public function get tips():String {
            return '';
        }
    }
}