package sg.festival.model
{
    import sg.net.NetMethodCfg;
    import sg.activities.model.ModelDialBse;
    import sg.activities.model.ModelActivities;
    import laya.utils.Handler;
    import sg.manager.ModelManager;
    import sg.net.NetPackage;
    import sg.utils.ArrayUtil;
    import sg.utils.ObjectUtil;

    public class ModelFestivalDial extends ModelDialBse {

		private static var sModel:ModelFestivalDial = null;
		
		public static function get instance():ModelFestivalDial {
			return sModel ||= new ModelFestivalDial();
		}

        private var _cfg:Object = null;
        private var random_times:int = 0;
        private var random_list:Array = [];
        private var total_pay:int = 0;
        public function ModelFestivalDial() {
        }

        /**
         * 设置配置数据
         */
        public function initCfg():void {
            var actCfg:Object = ModelFestival.instance.actCfg;
            var cfgData:Object = actCfg.act[ModelFestival.TYPE_DIAL];
            _cfg = cfgData;
        }

        /**
         * 更新数据
         */
        public function checkData(dial:Object):void {
            random_times = dial.random_times;
            mRecrodList = dial.log_list;
            random_list = dial.random_list;
            total_pay = dial.total_pay;
            this.event(ModelActivities.UPDATE_DATA);
		}

        public function chooseReward(r_list:Array):void {
            this.sendMethod(NetMethodCfg.WS_SR_CHOOSE_FESTIVAL_DIAL, {r_list: r_list});
        }

        override public function drawReward(handler:Handler):void {
            this.sendMethod(NetMethodCfg.WS_SR_RANDOM_FESTIVAL_DIAL, {}, Handler.create(this, function(np:NetPackage):void {
				var receiveData:* = np.receiveData;
				ModelManager.instance.modelUser.updateData(np.receiveData);
				var gift_dict:* = receiveData && receiveData.gift_dict;
				var mIndex:int = ArrayUtil.findIndex(random_list, function(item:Array):Boolean {
                    return item[0][0] === ObjectUtil.keys(gift_dict)[0];
                });
				handler.runWith({mIndex: mIndex, gift_dict: gift_dict});
			}));
        }          

        override public function get active():Boolean {
            return Boolean(_cfg);
        }

        /**
         * 检测红点
         */
        override public function get redPoint():Boolean {
            return  active && canGetTimes > getTimes;
        }

        override public function get addCfg():Object{
            return _cfg.add;
        }

        override public function get giftArr():Array {
            return random_list.map(function(item:Array):Object {
                return [item[0], item[1] === _cfg.reward[2][0]];
            });
        }

        override public function get awardList():Array {
            return random_list;
		}

        override public function get awardCfg():Array {
            return _cfg.reward;
		}

        override public function get canGetTimes():int {
            return Math.floor(total_pay / _cfg.buy_num) + _cfg.free_times;
		}

        override public function get getTimes():int {
            return random_times;
		}

        override public function get buyNum():int {
            return Number(_cfg.buy_num) * 10;
		}

        override public function get payMoney():int {
            return total_pay;
		}

        override public function get tips():String {
            return _cfg.info;
        }

		/**
		 * 活动倒计时（剩余时间）
		 */
		override public function get remainTime():String {
            return ModelFestival.instance.remainTime;
        }
    }
}