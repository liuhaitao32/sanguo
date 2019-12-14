package sg.activities.model
{
    import sg.model.ViewModelBase;
    import sg.cfg.ConfigServer;
    import sg.manager.ModelManager;
    import sg.net.NetMethodCfg;
    import sg.utils.ObjectUtil;
    import sg.utils.Tools;

    public class ModelWish extends ViewModelBase
    {
		public static const MAKE_WISH:String = "make_wish";	// 许愿

		// 单例
		private static var sModel:ModelWish = null;
		
		public static function get instance():ModelWish
		{
			return sModel ||= new ModelWish();
		}
		
        private var data:Object = {};
        private var cfg:Object = null;
        private var rewardArr:Array = [];
        private var wishArr:Array = [];
        private var wish_reward:Object;
        public var wishState:int = 0; // 0:未领奖、1:未许愿、2:已许愿
        private var wish_rewchoo_num:int;
        private var login_reward_days:int;
        private var _loginReward:Boolean = false;
        public function ModelWish()
        {
            // 获取配置
            this.cfg = ConfigServer.ploy['act_wish'];
            haveConfig = Boolean(cfg);
            if (haveConfig) {
                this.wish_rewchoo_num = cfg['wish_rewchoo_num'];
                this.refreshData(ModelManager.instance.modelUser.records.wish_reward);
            }
        }

        override public function refreshData(data:*):void {
            if (!haveConfig)    return;
            var reward:Object = data.wish_reward;
            if (!reward)    return;
            this.wish_reward = reward;
            if (reward === -1) { //没领过奖
                this.wishState = 0;
                this.rewardArr = [this.cfg['wish_initrew']];
            }
            else if (reward is Array && (reward.length === 0 || reward[2])) { //已领奖，未许愿
                this.wishState = 1;
                this.rewardArr = [];
            }
            else if (!Tools.isNewDay(reward[0])) { //已许愿
                this.wishState = 2;
                this.rewardArr = this.wish_reward[1];
            }
            else { //可领奖
                this.wishState = 0;
                this.rewardArr = this.wish_reward[1];
            }

            var rewardArrTemp:Array = [];
            if (reward is Array && reward[1]) {
                rewardArrTemp = ObjectUtil.clone(reward[1]) as Array;
            }
            // 转换为wishArr
            this.wishArr.splice(0, this.wishArr.length);
            var wish_rewpond:Array = this.cfg['wish_rewpond'];
            var len:int = wish_rewpond.length;
            for(var i:int = 0; i < len; i++)
            {
                var item:Array = wish_rewpond[i];
                item['imgSelected'] = false;
                for(var j:int = rewardArrTemp.length - 1; j >= 0; j--)
                {
                    var item2:Array = rewardArrTemp[j];
                    if (item[0] == item2[0] && item[1] == item2[1]) {
                        this.wishArr.push(i);
                        rewardArrTemp.splice(j, 1);
                        break;
                    } 
                    
                }
            }
            this.event(ModelActivities.UPDATE_DATA);
        }

        public function isDouble():Boolean
        {
            return this.wish_reward && this.wish_reward[3] === 2;
        }

        public function makeAWish():void
        {
            ModelActivities.instance.sendMethod(NetMethodCfg.WS_SR_SET_WISH_REWARD, {index_list: this.wishArr});
            Laya.timer.once(200, this, function():void {
                this.event(MAKE_WISH);
            });
        }

        public function getConfig():Object {
            return this.cfg;            
        }

        public function getLoginRewardList():Object {
            return this.cfg['wish_daysrew'][(ModelManager.instance.modelUser.records.login_days / 7 > 1) ? 1 : 0];       
        }

        /**
         * 获取连续登录天数（<=7）
         */
        public function getLoginDays():int
        {
            var records:Object = ModelManager.instance.modelUser.records;
            login_reward_days = this.cfg['wish_days'];
            var login_days:int = records.login_days % login_reward_days;
            if (login_days === 0 && records.login_days !== records.login_reward_day) {
                login_days = login_reward_days;
                _loginReward = true;
            }
            else {
                _loginReward = false;
            }
            return login_days;
        }
        
        /**
         * 获取连续登录天数（<=7）
         */
        public function checkLoginReward():Boolean
        {
            return _loginReward;
        }

		/**
		 * 领取奖励
		 * @param	type
		 * @param	id
		 */
		public function getReward():void {
			ModelActivities.instance.sendMethod(NetMethodCfg.WS_SR_GET_WISH_REWARD);
		}

        public function getReward2():void {
			ModelActivities.instance.sendMethod(NetMethodCfg.WS_SR_GET_LOGIN_REWARD);
        }
		
        public function getWishArray():Array {
            return this.wishArr;            
        }
        public function getRewardArray():Array {
            return this.rewardArr; 
        }

		override public function get active():Boolean {
			return haveConfig;
		}
        
		override public function get redPoint():Boolean {
            return this.wishState !== 2 || this.checkLoginReward();
        }
    }
}