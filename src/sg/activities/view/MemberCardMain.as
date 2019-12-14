package sg.activities.view {
    import ui.activities.memberCard.memberCardUI;
    import sg.activities.model.ModelMemberCard;
    import laya.events.Event;
    import sg.manager.ViewManager;
    import sg.utils.Tools;
    import sg.manager.ModelManager;
    import sg.utils.ArrayUtil;
    import sg.model.ModelGame;
    import ui.bag.bagItemUI;
    import sg.model.ModelUser;
    import sg.manager.AssetsManager;
    import sg.cfg.ConfigServer;

    public class MemberCardMain extends memberCardUI {
        private var model:ModelMemberCard = ModelMemberCard.instance;
        private var state:Boolean = false;
        private var day_reward:Array;
        public function MemberCardMain() {
            txt_hint.text = Tools.getMsgById('member_04');
            txt_tips.text = Tools.getMsgById('member_05');
            btn_pay.on(Event.CLICK, this, this._onClickPay);
            btn_help.on(Event.CLICK, this, this._onClickHelp);
            reward_list_day.itemRender = RewardBase;
            reward_list_total.itemRender = bagItemUI;
            var cost:String = ModelManager.instance.modelUser.getPayMoney(model.pid, ConfigServer.pay_config_pf[model.pid][0])
            txt_price.text = ModelUser.getPayMoneyStr(cost) + Tools.getMsgById('_public44');
            this._initPanel();
        }

        private function _initPanel():void {
            day_reward = ModelManager.instance.modelProp.getRewardProp(model.cfg.day_reward);
            reward_list_day.array = day_reward;
            var user:ModelUser = ModelManager.instance.modelUser;
            state = Boolean(user.member_check);
            var ratio:int = Math.min(user.getGameDate(), model.cfg.limit_count);
            btn_pay.label = Tools.getMsgById(state ? 'member_02': 'member_01');
            img_hint.skin = AssetsManager.getAssetLater(state ? 'actPay3_58.png' : 'actPay3_55.png')
            img_activate.visible = state;
            txt_price.visible = !state;

            reward_list_total.array = day_reward.map(function(arr:Array):Array {
                var arr_new:Array = [arr[0], arr[1] * ratio, -1];
                arr[0] === 'coin' && (arr_new[1] += ConfigServer.pay_config_pf[model.pid][1]);
                return arr_new;
            }, this);
        }

        private function _onClickPay():void {
            state && model.getReward();
            state || ModelGame.toPay(model.pid);
        }
        
        private function _onClickHelp():void {
            ViewManager.instance.showTipsPanel(Tools.getMsgById(model.cfg.help_info));
        }
    }
}

import ui.activities.memberCard.memberRewardBaseUI;
import sg.model.ModelItem;

class RewardBase extends memberRewardBaseUI{
	public function RewardBase() {
	}

	private function set dataSource(source:Array):void {
        img_icon.skin = ModelItem.getItemIconAssetUI(source[0], false);
        txt_name.text = ModelItem.getItemName(source[0]);
        txt_num.text = 'X' + source[1];
	}
}