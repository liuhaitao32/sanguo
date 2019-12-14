package sg.festival.model
{
    import sg.model.ViewModelBase;
    import sg.cfg.ConfigServer;
    import sg.manager.ModelManager;
    import sg.utils.TimeHelper;
    import sg.utils.Tools;
    import sg.net.NetMethodCfg;
    import sg.utils.ObjectUtil;
    import sg.model.ModelUser;

    public class ModelFestivalLogin extends ViewModelBase
    {
		public static const TYPE_VALID:int          = 0; // 可领奖
		public static const TYPE_ALREADY:int        = 1; // 已领奖
		public static const TYPE_INVALID:int        = 2; // 已过期
		public static const TYPE_UNACTIVATED:int    = 3; // 未到时间

		// 单例
		private static var sModel:ModelFestivalLogin = null;
		
		public static function get instance():ModelFestivalLogin {
			return sModel ||= new ModelFestivalLogin();
		}
		
        private var _cfg:Object = null;
        private var _login_time:Object = null;
        private var _login_day:Object = null;
        private var _index:int = 0;
        public function ModelFestivalLogin() {
        }

        /**
         * 设置配置数据
         */
        public function initCfg():void {
            var actCfg:Object = ModelFestival.instance.actCfg;
            var cfgData:Object = actCfg.act[ModelFestival.TYPE_LOGIN];
            _cfg = cfgData;
        }

        /**
         * 更新数据
         */
        public function checkData(login_time:Object, login_day:Object):void {
            _login_time = login_time;
            _login_day = login_day;
            if (!_login_time) return; // 数据不存在
            var modelUser:ModelUser = ModelManager.instance.modelUser;
            _index = modelUser.getGameDate() - ModelFestival.instance.startDay; // 获取是第几天登陆(从0开始计算)
        }

        public function get rewardData():Array {
            var reward:Array = _cfg.reward;
            return reward.map(function(item:Array, index:int):Object {
                return {id:index,  today: index === _index, state: this.getState(index), selected: index === loginDay};
            }, this);
        }

        /**
         * 获取某一天的领奖状态
         */
        public function getState(index:int):int {
            if (index > _index) return TYPE_UNACTIVATED;
            if (_login_day[index] is Number) {
                return _login_day[index];
            }
            else return TYPE_INVALID;
        }

        public function get cfg():Object {
            return _cfg;
        }

        public function get loginDay():int {
            return _index;
        }

        public function get haveReward():Boolean {
            return this.rewardData.some(function(item:Object):Boolean {
                return item.state === TYPE_VALID;
            });
        }

        override public function get active():Boolean {
            return Boolean(_cfg);
        }

        /**
         * 检测红点
         */
        override public function get redPoint():Boolean {
            return active && haveReward;
        }

        /**
         * 领奖
         */
        public function getReward(index:int):void {
            this.haveReward && ModelFestival.instance.sendMethod(NetMethodCfg.WS_SR_FESTIVAL_LOGIN_REWARD, {day_num: index});
        }
    }
}