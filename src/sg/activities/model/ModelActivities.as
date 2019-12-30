package sg.activities.model
{
    import laya.events.EventDispatcher;
    import laya.maths.Point;
    import laya.utils.Handler;

    import sg.activities.ActivityHelper;
    import sg.model.ViewModelBase;
    import sg.cfg.ConfigServer;
    import sg.manager.ModelManager;
    import sg.manager.ViewManager;
    import sg.model.ModelUser;
    import sg.net.NetMethodCfg;
    import sg.net.NetPackage;
    import sg.net.NetSocket;
    import sg.utils.SaveLocal;
    import sg.utils.Tools;
    import sg.model.ViewModelBase;
    import sg.festival.model.ModelFestival;
    import sg.utils.ObjectUtil;
    import sg.zmPlatform.ModelFocus;
    import sg.zmPlatform.ModelVerify;
    import sg.festival.model.ModelFestivalPayAgain;
    import sg.view.hero.ViewAwakenHero;

    public class ModelActivities extends EventDispatcher
    {
		public static var sModel:ModelActivities = null;
        public static const UPDATE_DATA:String = 'update_data';         // 根据数据刷新界面
        public static const REFRESH_TAB:String = 'refresh_tab';         // 刷新导航栏
        public static const REFRESH_LIST:String = 'refresh_list';       // 刷新左侧列表

        public static const TYPE_WONDER_ACT:String = 'wonder_act';      // 精彩活动
        public static const TYPE_LIMIT_ACT:String = 'limittime_act';    // 限时活动
        public static const TYPE_FREE_BUY:String = 'free_buy';          // 福利兑换
        public static const TYPE_PAYMENT:String = 'independ_buy';       // 特惠充值
        public static const TYPE_BASE_UP:String = 'act_base_up';        // 官邸升级
        public static const TYPE_SHARE_REWARD:String = 'share_reward';  // 分享有礼
        public static const TYPE_HAPPY_BUY:String = 'happy_buy';        // 七日嘉年华
        public static const TYPE_PAY_AGAIN:String = 'pay_again';        // 充值福利
        public static const TYPE_LIMIT_FREE:String = 'limit_free';      // 限时免单
        public static const TYPE_EXCHANGE_SHOP:String = 'exchange_shop';// 限时兑换
        public static const TYPE_PHONE:String = 'phone';                // 手机绑定
        public static const TYPE_FOCUS:String = 'focus';                // 关注公众号
        public static const TYPE_VERIFY:String = 'verify';              // 实名认证
        public static const TYPE_ROOL_PAY:String = 'rool_pay';          // 循环充值
        public static const TYPE_FESTIVAL:String = 'festival';          // 节日活动
        public static const TYPE_AUCTION:String = 'auction';            // 拍卖活动
        public static const TYPE_PAY_RANK:String = 'pay_rank';          // 消费榜
        public static const TYPE_EQUIP_BOX:String = "equip_box";        // 轩辕铸宝
        public static const TYPE_SURPRISE_GIFT:String = "surprise_gift";// 惊喜礼包
		
		// 单例
		public static function get instance():ModelActivities {
			return sModel ||= new ModelActivities();
		}
		
        private var modelOnlineReward:ModelOnlineReward;
        private var modelPayment:ModelPayment;
        private var modelBaseLevelUp:ModelBaseLevelUp;
        private var modelHappy:ModelHappy;
        private var modelFreeBill:ModelFreeBill;
        private var modelFreeBuy:ModelFreeBuy;
        private var modelWXShare:ModelWXShare;
        private var modelPhone:ModelPhone;
        private var modelFocus:ModelFocus;
        private var modelVerify:ModelVerify;
        private var modelRoolPay:ModelRoolPay;
        private var modelFestival:ModelFestival;
        private var modelAuction:ModelAuction;
        private var modelPayRank:ModelPayRank;
        private var modelEquipBox:ModelEquipBox;
        private var modelSurpriseGift:ModelSurpriseGift;

        private var actDataList:Array = null;
        private var act_left:Array = null;
        private var inited:Boolean = false;


        public function ModelActivities() {

            // 合服公告
            ModelAfficheMerge.instance;
        }
		public static function clear():void{
            sModel.clearEvents();
            sModel = null;
        }

        /**
         * 获取左侧活动入口的数据
         */
        public function getLeftIconsData():Array {
            var data:Array = [];
            var system_simple:Object = ConfigServer.system_simple; // 杂项全配置
            var currentTime:int = ConfigServer.getServerTimer();
            var user:ModelUser = ModelManager.instance.modelUser;
            act_left || (act_left = ObjectUtil.clone(system_simple.act_left, true) as Array);

            var len:int = act_left.length;
            for(var i:int = 0; i < len; i++) {
                var element:Object = act_left[i];
                var active:Boolean = false;
                var showTime:Boolean = false;
                var mergeTime:int = ModelAfficheMerge.instance.mergeTime;
                if (element.merge_hide && currentTime > mergeTime && mergeTime > 0) {
                    continue;
                }
                switch(element.type) {
                    case TYPE_WONDER_ACT:
                    case TYPE_LIMIT_ACT:
                        active = getActDataBytype(element.type).length > 0;
                        break;
                    case TYPE_FREE_BUY:
                        showTime = true;
                        element.model = modelFreeBuy; // 设置model 用于获取时间
                        active = modelFreeBuy ? modelFreeBuy.checkData() : false;
                        break;
                    case TYPE_PAYMENT:
                        active = modelPayment ? modelPayment.active : false;
                        break;
                    case TYPE_BASE_UP:
                        active = modelBaseLevelUp ? modelBaseLevelUp.active : false;
                        break;
                    case TYPE_SHARE_REWARD:
                        showTime = true;
                        element.model = modelWXShare;
                        active = modelWXShare ? modelWXShare.checkActive() : false;
                        break;
                    case TYPE_PAY_AGAIN:
                        active = ModelFestivalPayAgain.instance.active;
                        break;
                    case TYPE_LIMIT_FREE:
                        active = modelFreeBill ? modelFreeBill.active : false;
                        break;
                    case TYPE_HAPPY_BUY:
                        active = modelHappy ? modelHappy.checkActive() : false;
                        break;
                    case TYPE_PHONE:
                        active = modelPhone ? modelPhone.active : false;
                        break;
                    case TYPE_FOCUS:
                        active = modelFocus ? modelFocus.active : false;
                        break;
                    case TYPE_VERIFY:
                        active = modelVerify ? modelVerify.active : false;
                        break;
                    case TYPE_ROOL_PAY:
                        active = modelRoolPay ? modelRoolPay.active : false;
                        break;
                    case TYPE_FESTIVAL:
                        active = modelFestival ? modelFestival.active : false;
                        break;
                    case TYPE_AUCTION:
                        showTime = true;
                        element.model = modelAuction;
                        active = modelAuction ? modelAuction.active : false;
                        break;
                    case TYPE_PAY_RANK:
                        showTime = true;
                        element.model = modelPayRank;
                        active = modelPayRank ? modelPayRank.active : false;
                        break;
                    case TYPE_EQUIP_BOX:
                        showTime = true;
                        element.model = modelEquipBox;
                        active = modelEquipBox ? modelEquipBox.active : false;
                        break;
                    case TYPE_SURPRISE_GIFT:
                        showTime = true;
                        element.model = modelSurpriseGift;
                        active = modelSurpriseGift ? modelSurpriseGift.active : false;
                        break;
                }
                if (active) {
                    element.showTime = showTime;
                    data.push(element);
                }
            }
            return data;            
        }

        /**
         * 获取精彩活动或限时活动的活动数据
         */
        public function getActDataBytype(type:String):Array {
            var data:Array = [];
            var dataList:Array = ConfigServer.system_simple[type];
            var len:int = dataList.length;
            for(var i:int = 0; i < len; i++) {
                var element:Object = dataList[i];
                var active:Boolean = true;
                switch(element.type) {
                    case ActivityHelper.TYPE_ONCE:
                        active = ModelPayOnce.instance.checkActiveByType(element.timeType);
                        break;
                    case ActivityHelper.TYPE_ADD_UP:
                        active = ModelPayTotal.instance.checkActiveByType(element.timeType);
                        break;
                    default:
                        var md:* = ActivityHelper.instance.getModelByType(element.type);
                        active =  !md.mIsTestClose && md.active;
                        break;
                }
                active && data.push(element);
            }
            return data;
        }

        // 初始化各个活动模型
        public function initModel():void {
            if (this.inited)    return;
            this.inited = true;

			// 初始化在线奖励
			this.modelOnlineReward = ModelOnlineReward.instance;
            
			// 初始化活动Model
            var data1:Array = ConfigServer.system_simple[ModelActivities.TYPE_WONDER_ACT]; // 精彩活动
            var data2:Array = ConfigServer.system_simple[ModelActivities.TYPE_LIMIT_ACT]; // 限时活动
            actDataList || (actDataList = data1.concat(data2));
            var len:int = actDataList.length;
            for(var i:int = 0; i < len; i++) {
                ActivityHelper.instance.getModelByType(actDataList[i].type)
            }

			// 初始化节日活动模型
			ModelFestival.instance.initModel();	

            // 官邸升级
            this.modelBaseLevelUp = ModelBaseLevelUp.instance;
            this.modelBaseLevelUp.on(UPDATE_DATA, this, this.refreshLeftList);

            // 充值
            this.modelPayment = ModelPayment.instance;

            //七日嘉年华
            this.modelHappy = ModelHappy.instance;
            
            // 限时免单
            this.modelFreeBill = ModelFreeBill.instance;
            
            //福利兑换
            this.modelFreeBuy = ModelFreeBuy.instance;
            this.modelFreeBuy.on(ModelFreeBuy.EVENT_ChANGE_FREE_BUY, this, this.refreshLeftList);
            
            //微信分享
            this.modelWXShare = ModelWXShare.instance;
            this.modelWXShare.on(ModelWXShare.EVENT_ChANGE_SHARE, this, this.refreshLeftList);

            //手机注册
            this.modelPhone = ModelPhone.instance;

            // 关注公众号
            this.modelFocus = ModelFocus.instance;

            // 实名认证
            this.modelVerify = ModelVerify.instance;

            //循环充值
            this.modelRoolPay = ModelRoolPay.instance;

            // 节日活动
            this.modelFestival = ModelFestival.instance;

            // 拍卖活动
            this.modelAuction = ModelAuction.instance;

            // 消费榜
            this.modelPayRank = ModelPayRank.instance;

            //轩辕铸宝
            this.modelEquipBox = ModelEquipBox.instance;

            // 惊喜礼包
            this.modelSurpriseGift = ModelSurpriseGift.instance;

            ModelCostly.instance;
            
            // 刷新数据
            var modelUser:ModelUser = ModelManager.instance.modelUser;
            modelUser.on(ModelUser.EVENT_IS_NEW_DAY, this, this.sendMethod, [NetMethodCfg.WS_SR_GET_RECORDS]);
            this.refreshActivitiesData(modelUser.records);

            modelVerify.checkReward();
        }

        /**
         * 刷新活动数据
         */
        public function refreshActivitiesData(records: Object):void {
            if (!this.inited)    return;
			ModelFreeBuy.instance.checkData();
            var len:int = actDataList.length;
            for(var i:int = 0; i < len; i++) {
                var model:ViewModelBase = ActivityHelper.instance.getModelByType(actDataList[i].type);
                model && model.refreshData(records);
            }
            records.online_reward   && modelOnlineReward.refreshData(records.online_reward);
            records.pay_reward      && modelPayment.refreshData(records.pay_reward);
            records.lvup_reward     && modelBaseLevelUp.refreshData(records.lvup_reward);
            records.limit_free      && modelFreeBill.refreshData(records.limit_free);
			records.festival	    && modelFestival.refreshData(records);
			records.auction	        && modelAuction.refreshData(records.auction);
			records.pay_rank_gift	&& modelPayRank.refreshData(records.pay_rank_gift);
            records.equip_box	    && modelEquipBox.refreshData(records);
            records.surprise_gift   && modelSurpriseGift.refreshData(records.surprise_gift);
            records.pay_again       && ModelFestivalPayAgain.instance.checkData(records.pay_again);
            this.event(REFRESH_TAB);
            this.event(REFRESH_LIST);
        }

        public function refreshLeftList():void {
            this.event(REFRESH_LIST);
        }

        /**
         * @param 方法
         * @param 数据
         */
        public function sendMethod(method:String, data:Object = null, handler:Handler = null):void {
            data || (data = {});
            NetSocket.instance.send(method, data, handler || Handler.create(this, this.sendCB));
        }
        
		/**
		 * @param	re
		 */
		private function sendCB(re:NetPackage):void {
			var gift_dict:* = re.receiveData.gift_dict;
			ModelManager.instance.modelUser.updateData(re.receiveData);
			gift_dict && ViewManager.instance.showRewardPanel(gift_dict);
		}

        /**
         * 直接购买商品，不显示奖励弹板
		 * @param	pos 商品的飞行起点
         */
        public function buyGoodsWithoutHint(method:String, data:Object, pos:Point):void {
            data || (data = {});
            NetSocket.instance.send(method, data, Handler.create(this, this.butGoodsCB), pos);
        }

        
		/**
		 * 
		 * @param	re
		 */
		private function butGoodsCB(re:NetPackage):void {
			var gift_dict:* = re.receiveData['gift_dict'];
            var pos:Point = re.otherData;
            ViewAwakenHero.checkGiftDict(gift_dict);
			ModelManager.instance.modelUser.updateData(re.receiveData);
            if (gift_dict.awaken) {
                ViewManager.instance.showRewardPanel(gift_dict);
            } else {
                ViewManager.instance.showIcon(gift_dict, pos.x, pos.y);
            }
		}

        public function checkWonderActRed(type:String):Boolean {
            var dataArr:Array =  this.getActDataBytype(type);
            var len:int = dataArr.length;
            for(var i:int = 0; i < len; i++) {
                var data:Object = dataArr[i];
                var notClicked:Boolean = !Boolean(SaveLocal.getValue(SaveLocal.KEY_ACT + data.type, true));
                switch(data.type) {
                    case ActivityHelper.TYPE_ONCE:
                        if (notClicked || ModelPayOnce.instance.checkRewardByType(data.timeType))    return true;
                        break;
                    case ActivityHelper.TYPE_ADD_UP:
                        if (notClicked || ModelPayTotal.instance.checkRewardByType(data.timeType))   return true;
                        break;
                    default:
                        if(notClicked || ActivityHelper.instance.getModelByType(data.type).redPoint) return true;
                        break;                  
                }
            }
            return false;
        }
    }
}