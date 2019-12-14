package sg.festival.model {
    import sg.model.ViewModelBase;
    import sg.net.NetMethodCfg;
    import sg.manager.ModelManager;
    import sg.utils.ObjectUtil;
    public class ModelFestivalOnce extends ViewModelBase {
        
		// 单例
		private static var sModel:ModelFestivalOnce = null;
		
		public static function get instance():ModelFestivalOnce {
			return sModel ||= new ModelFestivalOnce();
		}
		
        public var cfg:Object = null;
        public var data:Object;
        public function ModelFestivalOnce() {
        }

        /**
         * 设置配置数据
         */
        public function initCfg():void {
            var actCfg:Object = ModelFestival.instance.actCfg;
            var cfgData:Object = actCfg.act[ModelFestival.TYPE_ONCE];
            cfg = cfgData;
            data = {};
            for(var key:String in cfg.reward) {
                var limit_num:int = cfg.reward[key][0];
                var reward:Array = ModelManager.instance.modelProp.getRewardProp(cfg.reward[key][1]);
                reward.forEach(function(arr:Array):Array{ arr[2] = -1 });
                data[key] = {
                    key: key,
                    need_num: parseInt(key) * 10,
                    reward: reward,
                    limit_num: limit_num,
                    reward_num: [0, limit_num],
                    can_get_num: 0,
                    complete: false
                };
            }
        }

        /**
         * 更新数据
         */
        public function checkData(once_pay:Object):void {
            for(var key:String in once_pay) {
                var sData:Object = data[key];
                var sOnce:Object = once_pay[key];
                if (sData) {
                    sData.reward_num = sOnce;
                    sData.can_get_num = Math.min(sOnce[1], sData.limit_num) - sOnce[0];
                    sData.complete = sOnce[0] >= sData.limit_num;
                } 
            }
        }

        override public function get active():Boolean {
            return ModelManager.instance.modelUser.canPay && Boolean(cfg);
        }

        /**
         * 检测红点
         */
        override public function get redPoint():Boolean {
            return ObjectUtil.values(data).some(function(obj:Object):Boolean {
                return obj.can_get_num > 0;
            });
        }

        /**
         * 领奖
         */
        public function getReward(key:String):void {
            ModelFestival.instance.sendMethod(NetMethodCfg.WS_SR_FESTIVAL_ONCE_REWARD, {once_key: key});
        }
    }
}