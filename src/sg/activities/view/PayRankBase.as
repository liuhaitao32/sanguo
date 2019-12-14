package sg.activities.view
{
    import ui.activities.payRank.payRankBaseUI;
    import sg.utils.Tools;
    import sg.model.ModelHero;
    import sg.model.ModelUser;
    import sg.activities.model.ModelPayRank;
    import laya.events.Event;
    import sg.boundFor.GotoManager;
    import sg.manager.AssetsManager;
    import sg.manager.ModelManager;

    public class PayRankBase extends payRankBaseUI
    {
        public var model:ModelPayRank = ModelPayRank.instance;
        public function PayRankBase() {
            txt_hint.text = Tools.getMsgById('pay_rank3');
            img_bg.on(Event.CLICK, this, this._onClick);
            img_reward.on(Event.CLICK, this, this._onClick);
        }

        private function set dataSource(source:Object):void {
            if (!source) return;
			this._dataSource = source;
            txt_name.text = source.name;
            txt_name.color = ModelManager.instance.modelUser.mUID == source.uid ? '#00ff00' : '#ffffff';
            txt_point.text = source.point;
            comIndex.setRankIndex(source.rank, Tools.getMsgById("_public101"), true); //未上榜
            icon_hero.setHeroIcon(ModelUser.getUserHead(source.pic));
            var imgs:Array = model.cfg.reward_boximage;
            for(var i:int = 0, len:int = imgs.length; i < len; i++) {
                if (source.rank <= imgs[i][0]) {
                    img_reward.skin = AssetsManager.getAssetsICON(imgs[i][1]);
                    break;
                }
            }
        }

        private function _onClick(evt:Event):void {
             if (!_dataSource) return;
            if (evt.currentTarget === img_reward) {
                GotoManager.boundForPanel(GotoManager.VIEW_REWARD_PREVIEW, '', _dataSource.gift_dict);
            }
            else{
                ModelManager.instance.modelUser.selectUserInfo(_dataSource.uid);
            }
        }
    }
}