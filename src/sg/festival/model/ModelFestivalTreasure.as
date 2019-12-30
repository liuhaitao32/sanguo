package sg.festival.model
{
    import sg.activities.model.ModelTreasureBase;
    import sg.net.NetMethodCfg;
    import sg.activities.model.ModelActivities;

    public class ModelFestivalTreasure extends ModelTreasureBase {

		private static var sModel:ModelFestivalTreasure = null;
		
		public static function get instance():ModelFestivalTreasure {
			return sModel ||= new ModelFestivalTreasure();
		}

        public function ModelFestivalTreasure() {
			key = ModelTreasureBase.KEY_FES_TREASURE;
			buy_method = NetMethodCfg.WS_SR_RANDOM_FESTIVAL_TREASURE;
			buy_method_shop = NetMethodCfg.WS_SR_FESTIVAL_TREASURE_SHOP;
        }

        /**
         * 设置配置数据
         */
        public function initCfg():void {
            var actCfg:Object = ModelFestival.instance.actCfg;
            var cfgData:Object = actCfg.act[ModelFestival.TYPE_TREASURE];
            cfg = cfgData;
        }

        /**
         * 更新数据
         */
        public function checkData(treasure:Object):void {
            mBuyTimesOne = treasure.buy_one;
            mBuyTimesFive = treasure.buy_five;
            mScore = treasure.score;
            mShopObj = treasure.shop_log;
            this.event(ModelActivities.UPDATE_DATA);
        }

        override public function get addCfg():Object{
            return cfg.add;
        }

        override public function get shopCfg():Object{
            return cfg.treasure_shop;
        }

        override public function get awardCfg():Array {
            return cfg.reward;
		}

        override public function get awardList():Array {
			return cfg.reward.map(function(arr:Array):Array {
                var result:Array = arr[0];
                result[2] = result[2] === 1;
                return result;
            });
        }

        override public function get active():Boolean {
            return Boolean(cfg);
        }

		/**
		 * 活动倒计时（剩余时间）
		 */
		override public function get remainTime():String {
            return ModelFestival.instance.remainTime;
        }

        override public function get tips():String {
            return cfg.info;
        }
    }
}