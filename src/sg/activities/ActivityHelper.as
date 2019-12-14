package sg.activities
{
    import laya.events.EventDispatcher;
    import sg.activities.model.ModelConsumeTotal;
    import sg.activities.model.ModelDial;
    import sg.activities.model.ModelExchange;
    import sg.activities.model.ModelFund;
    import sg.activities.model.ModelPayOnce;
    import sg.activities.model.ModelPayTotal;
    import sg.activities.model.ModelPromote;
    import sg.activities.model.ModelSaleShop;
    import sg.activities.model.ModelTreasure;
    import sg.activities.model.ModelWeekCard;
    import sg.activities.model.ModelWish;
    import sg.activities.view.ConsumeTotalMain;
    import sg.activities.view.DialMain;
    import sg.activities.view.ExchangeShop;
    import sg.activities.view.FundMain;
    import sg.activities.view.PromoteMain;
    import sg.activities.view.SaleShopMain;
    import sg.activities.view.TreasureMain;
    import sg.activities.view.WeekCardMain;
    import sg.activities.view.WishMain;
    import sg.view.com.ItemBase;
    import sg.activities.model.ModelpayChoose;
    import sg.activities.view.PayChooseMain;
    import sg.model.ViewModelBase;
    import sg.activities.model.ModelEquipBox;
    import sg.activities.view.EquipBoxMain;
    import sg.activities.model.ModelActivities;
    import sg.activities.model.ModelMemberCard;
    import sg.activities.view.MemberCardMain;

    public class ActivityHelper extends EventDispatcher
    {
        public static const TYPE_DIAL:String        = 'dial';           // 三国密藏
        public static const TYPE_TREASURE:String    = 'treasure';       // 天下珍宝
        public static const TYPE_WISH:String        = 'act_wish';       // 许愿
        public static const TYPE_ADD_UP:String      = 'addup';          // 累计充值
        public static const TYPE_ONCE:String        = 'once';           // 单笔充值
        public static const TYPE_SALE_SHOP:String   = 'act_sale_shop';  // 折扣商店
        public static const TYPE_MEMBER_CARD:String = 'member_card';    // 永久卡活动
        public static const TYPE_WEEK_CARD:String   = 'week_card';      // 周卡活动
        public static const TYPE_OFFICE_UP:String   = 'act_officeup';   // 加官进爵
        public static const TYPE_FUND:String        = 'fund';           // 超级基金
        public static const TYPE_CONSUME:String     = 'consume';        // 累计消费
        public static const TYPE_EXCHANGE:String    = 'exchange_shop';  // 兑换商店
        public static const TYPE_PAY_CHOOSE:String  = 'pay_choose';     // 充值自选
        public static const TYPE_EQUIP_BOX:String   = 'equip_box';      // 轩辕铸宝

		// 单例
		private static var _instance:ActivityHelper = null;
		
		public static function get instance():ActivityHelper
		{
			return _instance ||= new ActivityHelper();
		}
		
        private var popArr:Array = [];
        public function ActivityHelper() {
        }

        public function getModelByType(type:String):ViewModelBase {
            var model:ViewModelBase = null;
            switch(type)
            {
                case TYPE_DIAL:
                    model = ModelDial.instance as ViewModelBase;
                    break;
                case TYPE_TREASURE:
                    model = ModelTreasure.instance as ViewModelBase;
                    break;
                case TYPE_ONCE:
                    model = ModelPayOnce.instance as ViewModelBase;
                    break;
                case TYPE_ADD_UP:
                    model = ModelPayTotal.instance as ViewModelBase;
                    break;
                case TYPE_WISH:
                    model = ModelWish.instance as ViewModelBase;
                    break;
                case TYPE_SALE_SHOP:
                    model = ModelSaleShop.instance as ViewModelBase;
                    break;
                case TYPE_OFFICE_UP:
                    model = ModelPromote.instance as ViewModelBase;
                    break;
                case TYPE_FUND:
                    model = ModelFund.instance as ViewModelBase;
                    break;
                case TYPE_MEMBER_CARD:
                    model = ModelMemberCard.instance as ViewModelBase;
                    break;
                case TYPE_WEEK_CARD:
                    model = ModelWeekCard.instance as ViewModelBase;
                    break;
                case TYPE_CONSUME:
                    model = ModelConsumeTotal.instance as ViewModelBase;
                    break;
                case TYPE_EXCHANGE:
                    model = ModelExchange.instance as ViewModelBase;
                    break;
                case TYPE_PAY_CHOOSE:
                    model = ModelpayChoose.instance as ViewModelBase;
                    break;
                case TYPE_EQUIP_BOX:
                    model = ModelEquipBox.instance as ViewModelBase;
                    break;
                default:
                    model = new ViewModelBase();
                    console && console.warn("ActivityHelper.getModelByType()  warning!!");
                    break;
            }
            return model;
        }

        /**
         * 测试关闭某个活动
         */
        public function testClose(key:String):void{
            getModelByType(key).mIsTestClose=true;
            ModelActivities.instance.event("refresh_tab");
        }

        /**
         * 测试打开个活动(必须通过testClose关闭的才行)
         */
        public function testOpen(key:String):void{
            getModelByType(key).mIsTestClose=false;
            ModelActivities.instance.event("refresh_tab");
        }

        public function getItemBaseByType(type:String):ItemBase {
            var view:ItemBase = null;
            switch(type)
            {
                case TYPE_DIAL:
                    view = new DialMain();
                    break;
                case TYPE_TREASURE:
                    view = new TreasureMain();
                    break;
                case TYPE_WISH:
                    view = new WishMain();
                    break;
                case TYPE_SALE_SHOP:
                    view = new SaleShopMain();
                    break;
                case TYPE_OFFICE_UP:
                    view = new PromoteMain();
                    break;
                case TYPE_FUND:
                    view = new FundMain();
                    break;
                case TYPE_MEMBER_CARD:
                    view = new MemberCardMain();
                    break;
                case TYPE_WEEK_CARD:
                    view = new WeekCardMain();
                    break;
                case TYPE_CONSUME:
                    view = new ConsumeTotalMain();
                    break;
                case TYPE_EXCHANGE:
                    view = new ExchangeShop();
                    break;
                case TYPE_PAY_CHOOSE:
                    view = new PayChooseMain();
                    break;
                case TYPE_EQUIP_BOX:
                    view = new EquipBoxMain();
                    break;
            }
            return view;
            
        }
    }
}