package sg.altar.legendAwaken.model
{
    import sg.cfg.ConfigServer;
    import sg.manager.ModelManager;
    import sg.model.ViewModelBase;
    import sg.model.ModelGame;
    import sg.utils.Tools;
    import sg.model.ModelHero;
    import sg.utils.StringUtil;
    import sg.utils.ObjectUtil;
    import sg.net.NetMethodCfg;
    import laya.utils.Handler;
    import sg.net.NetPackage;
    import sg.fight.FightMain;
    import sg.manager.ViewManager;
    import sg.altar.legend.view.ViewLegendKillNum;
    import sg.altar.legend.view.ViewLegendKillRate;
    import sg.net.NetSocket;
    import sg.utils.ArrayUtil;
    import sg.model.ModelItem;
    import sg.model.ModelUser;
    import sg.utils.TimeHelper;

    public class ModelLegendAwaken extends ViewModelBase
    {
        public static const UPDATE_DATA:String = 'update_data';         // 根据数据刷新界面

		// 单例
		private static var sModel:ModelLegendAwaken = null;
		public var hids:Array = null;
		public static function get instance():ModelLegendAwaken {
			return sModel ||= new ModelLegendAwaken();
		}
		public var cfg:Object = null; // 总配置
		public var cfg_draw:Array = null; // 抽奖库
		public var cfg_show_chance:Array = null; // 掉率显示
		public var cfg_legend_reward:Array = null; // 觉醒库
		public var draw_times:int = 0;  // 抽将次数
		public var open_days:int = 0;   // 刷新时间
		public var pay_money:int = 0;   // 当期充值
		public var score:int = 0;       // 累计积分
		public var start_day:int = 0;   // 开始天数
		public var end_day:int = 0;     // 结束天数
		public var end_time:int = 0;    // 结束时间
		public var draw_start_time:int = 0;     // 今天抽将开始时间
		public var draw_end_time:int = 0;       // 今天抽将结束时间
		public var shopData:Array = []; // 商店数据
		public const itemId:String = 'item808'; // 玉璜素材ID
        public function ModelLegendAwaken() {
            cfg = ConfigServer.legend_awaken;
            var mergeNum:int = ModelManager.instance.modelUser.mergeNum;
            if (mergeNum !== cfg.merge) {
                return;
            }

            cfg_draw = cfg['draw_' + mergeNum];
            cfg_show_chance = cfg['show_chance_' + mergeNum];
            cfg_legend_reward = cfg['legend_reward_' + mergeNum];
            hids = ArrayUtil.flat(cfg_draw, 4).filter(function(iid:String):Boolean {
                return iid is String && ModelItem.getItemType(iid) === 7;
            }, this).map(function(iid:String):String {
                return iid.replace('item', 'hero');
            }, this);
            hids = ArrayUtil.distinct(hids); // 去重
        }

        override protected function initData():void {
        }

        override public function refreshData(legend_awaken:*):void {
            legend_awaken = legend_awaken || ModelManager.instance.modelUser.legend_awaken;
            if (!legend_awaken.open_days || !this.open)   return;
            draw_times = legend_awaken.draw_times; 
            open_days = legend_awaken.open_days;   
            pay_money = legend_awaken.pay_money;  
            score = legend_awaken.score;

            // 刷新时间
            this._checkAct();
            this.event(UPDATE_DATA); 
        }

        private function _checkAct():void {
            var user:ModelUser = ModelManager.instance.modelUser;
            var gameDate:int = user.getGameDate();
            var data:Array = ArrayUtil.find(cfg_legend_reward, function(arr:Array):Boolean {
                return arr[0][0] <= gameDate && gameDate <= arr[0][1];
            }, this);

            if (open) {
                draw_start_time = Tools.getTodayMillWithHourAndMinute(cfg.time[0]);
                draw_end_time = Tools.getTodayMillWithHourAndMinute(cfg.time[1]);
            } else {
                draw_start_time    = 0;
                draw_end_time    = 0;
            }

            if (data) {
                start_day   = data[0][0];
                end_day     = data[0][1];
                end_time    = user.gameServerStartTimer + Tools.oneDayMilli * end_day; // 结束时间点 
                shopData    = data[1];
            } else {
                start_day   = 0;
                end_day     = 0;
                end_time    = 0;
                shopData    = [];
            }
        }

        public function get listData():Array {
            return shopData.map(function(arr:Array, index:int):Object {
                var hid:String = arr[2].awaken[0];
                var hero:Object = ModelManager.instance.modelUser.hero[hid];
                var awaken:Boolean = Boolean(hero && hero.awaken === 1);
                return {
                    index: index,
                    hid: hid,
                    select: false,
                    awaken: awaken, // 是否已经觉醒
                    need: arr[0],   // 开启条件（需充值金额）
                    canBuy: awaken === false && pay_money >= arr[0],  // 是否满足购买条件
                    price: arr[1]   // 价格 花费多少积分
                };
            }, this);
        }

        /**
         * 获取活动剩余时间（字符串）
         */
        public function getTimeString(isShop:Boolean):String {
            return TimeHelper.formatTime(this.getRemainingTime(isShop));
        }

        /**
         * 获取活动剩余时间
         */
        public function getRemainingTime(isShop:Boolean):int {
            var currentTime:int = ConfigServer.getServerTimer();
            var remainingTime:int = 0;
            if (isShop) {
                remainingTime = end_time - currentTime;
            } else if (currentTime > draw_start_time) {
                remainingTime = draw_end_time - currentTime;
            }
            return remainingTime <= 0 ? 0 : remainingTime;
        }

        public function get bubbleSkin():String {
            var hid:String = '';
            try {
                hid = shopData[0][2]['awaken'][0];
            } catch (e) {
                // trace(e);
            }
            return hid;
        }

        public function get needGuide():Boolean {
            var obj:Object = ModelManager.instance.modelInside.getBuildingModel('building026').checkMyStatus();
            return open && obj.visible === 0;
        }

        override public function get active():Boolean {
            return open && getRemainingTime(true) && ModelManager.instance.modelInside.getBuildingModel('building026').lv >= 1;
        }
        
        public function get open():Boolean {
            var mergeNum:int = ModelManager.instance.modelUser.mergeNum;
            return cfg.merge === mergeNum;
        }
        
        public function get shopOpen():Boolean {
            return active && this.getRemainingTime(true) > 0;
        }
        
        public function get drawOpen():Boolean {
            return this.getRemainingTime(false) > 0;
        }

        override public function get redPoint():Boolean {
            return active && false;
        }
    }
}