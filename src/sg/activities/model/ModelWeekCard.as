package sg.activities.model
{
    import sg.model.ViewModelBase;
    import sg.activities.view.ViewActivities;
    import sg.cfg.ConfigClass;
    import sg.cfg.ConfigServer;
    import sg.manager.ViewManager;
    import sg.utils.Tools;
    import sg.manager.ModelManager;

    public class ModelWeekCard extends ViewModelBase
    {
		// 单例
		private static var sModel:ModelWeekCard = null;
		
		public static function get instance():ModelWeekCard
		{
			return sModel ||= new ModelWeekCard();
		}
		
        public var cfg:Object;
        public var needPop:Boolean = false; // 是否需要弹板
        private var _active:Boolean = false;
        private var _remainDays:int = 0;
        private var _open:Boolean = false; // 是否开启周卡活动
        public function ModelWeekCard()
        {
            // 获取配置
            this.cfg = ConfigServer.ploy['week_card'];
            haveConfig = Boolean(cfg);
            _open = Boolean(ConfigServer.system_simple.is_week_card);
        }

        /**
         * 数据更新
         */
        override public function refreshData(data:*):void {
            if (!haveConfig)    return;
            var week_card:Object = data.week_card;
            if (!week_card)    return;
            var totalDays:int = cfg['cycle'];
            this._remainDays = totalDays - week_card.receive_num;
            if (!week_card.time) { // 压根没买过，则可以购买
                this._remainDays = 0;
            }
            if (_remainDays) {
                _active = false; // 有可领奖天数则不能购买
                if (week_card.time && _remainDays === totalDays) { // 买完没领奖
                    ViewManager.instance.showView(ConfigClass.VIEW_WEEK_CARD);
                    ViewActivities.resetScene();
                }
                else if (week_card.last_receive_time && Tools.isNewDay(week_card.last_receive_time)) { // 今天没领过奖，登录弹板
                    needPop = _open;
                }
            }
            else {
                _active = Tools.isNewDay(week_card.last_receive_time); // 今天没领过奖就显示周卡入口
            }
        }

        override public function get active():Boolean { // 是否可以购买周卡;
            return ModelManager.instance.modelUser.canPay && haveConfig && _open && _active;
        }

        override public function get redPoint():Boolean {
            return false;
        }

        /**
         * 剩余可领奖天数
         */
        public function getRemainDays():int {
            return _remainDays;
        }
    }
}