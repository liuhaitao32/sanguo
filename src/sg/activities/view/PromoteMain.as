package sg.activities.view
{
    import laya.events.Event;
    import laya.utils.Handler;

    import sg.activities.model.ModelActivities;
    import sg.activities.model.ModelPromote;
    import sg.boundFor.GotoManager;
    import sg.utils.ObjectUtil;
    import sg.utils.Tools;

    import ui.activities.promote.promoteUI;
    import sg.manager.AssetsManager;

    public class PromoteMain extends promoteUI
    {
        private var model:ModelPromote = ModelPromote.instance;
        public function PromoteMain()
        {
            this.rewardList.scrollBar.hide = true;
			this.rewardList.itemRender = ListBase;
            this.rewardList.renderHandler = new Handler(this, this._updateItem);
            this.model.on(ModelActivities.UPDATE_DATA, this, this.refreshPanel);
            this.btn_pay.label = Tools.getMsgById('_public104');
            // this.payHintTxt.text = Tools.getMsgById('_jia0014', [Tools.getMsgById('502051')]);
            this.btn_pay.on(Event.CLICK, this, GotoManager.boundForPanel, [GotoManager.VIEW_PAY_TEST]);
			this.character.setHeroIcon('hero401');
            this.refreshPanel();
        }

        private function refreshPanel():void {
            if (model.getPayMoney() >= model.cfg.pay_money ) {
                this.payIcon.setData(AssetsManager.getAssetsUI(AssetsManager.IMG_COIN), Tools.getMsgById('_jia0143'));
            } else {
                this.payIcon.setData(AssetsManager.getAssetsUI(AssetsManager.IMG_COIN), model.getPayMoney() * 10);
            }

            var arr:Array = ObjectUtil.clone(this.model.getRewardKeys()) as Array;
            arr.sort(function (a:String, b:String):Boolean { // 排序
                var flagA:int = ModelPromote.instance.getFlagWithGrade(a);
                var flagB:int = ModelPromote.instance.getFlagWithGrade(b);
                if (flagA === 2 && flagB !== 2) {
                    return true;
                }
                return Number(a) - Number(b);
            });
            this.rewardList.array = arr;
        }

        private function _updateItem(item:ListBase, index:int):void {
            var grade:int = item.dataSource;
            var reward:Object = this.model.getRewardObject(String(grade));
            var flag:int = this.model.getFlagWithGrade(grade);
            item.setData(grade, reward, flag);
        }

		public function removeCostumeEvent():void 
		{
			this.model.off(ModelActivities.UPDATE_DATA, this, this.refreshPanel);
		}
    }
}

import laya.events.Event;

import sg.activities.model.ModelPromote;
import sg.activities.view.RewardItem;
import sg.model.ModelOffice;
import sg.utils.ObjectUtil;

import ui.activities.promote.promoteRewardBaseUI;
import sg.utils.Tools;
class ListBase extends promoteRewardBaseUI
{
    private var rewardData:Object;
    public function ListBase()
    {
        this.on(Event.DISPLAY, this, this._onDisplay);
    }

    /**
     * @param 官职名称
     * @param 奖励数据
     * @param flag  0: 不可领取， 1： 可领取， 2：已领取
     */
	public function setData(grade:int, rewardData:Object, flag:int = 0):void {
        this.officialName.text = ModelOffice.getOfficeName(grade);
        this.rewardData = rewardData;
        if (this.rewardIcon is RewardItem) {
            this._onDisplay();
        }
        this.btn_get.gray = flag === 0;
        this.btn_get.visible = flag !== 2;
        this.alreadyGet.visible = !this.btn_get.visible;
        this.btn_get.off(Event.CLICK, this, this._getReward);
        this.btn_get.label = Tools.getMsgById("_jia0035");
        flag === 1 && this.btn_get.on(Event.CLICK, this, this._getReward);
	}
    
    private function _onDisplay():void
    {
        if (this.rewardData) {
            var key:String = ObjectUtil.keys(this.rewardData)[0];
            this.rewardIcon.setReward([key, this.rewardData[key]]);
        }
    }    

    private function _getReward(event:Event):void {
        ModelPromote.instance.getReward(this.dataSource);
    }
}