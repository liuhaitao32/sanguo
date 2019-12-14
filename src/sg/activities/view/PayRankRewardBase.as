package sg.activities.view
{
    import ui.activities.payRank.payRankRewardBaseUI;
    import sg.utils.Tools;
    import sg.manager.ModelManager;

    public class PayRankRewardBase extends payRankRewardBaseUI
    {
        public function PayRankRewardBase() {
            reward_list.itemRender = RewardItem;
            txt_hint.text = Tools.getMsgById('pay_rank3');
        }

        private function set dataSource(source:Object):void {
            if (!source) return;
			this._dataSource = source;
            txt_name.text = source.name;
            txt_name.color = ModelManager.instance.modelUser.mUID == source.uid ? '#00ff00' : '#ffffff';
            txt_point.text = source.point;
            comIndex.setRankIndex(source.rank, Tools.getMsgById("_public101"), true); //未上榜
            reward_list.array = ModelManager.instance.modelProp.getRewardProp(source.gift_dict);
        }
    }
}