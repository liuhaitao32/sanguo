package sg.view.season
{
    import ui.menu.seasonPanelUI;
    import sg.utils.Tools;
    import laya.utils.Handler;
    import sg.cfg.ConfigServer;
    import sg.manager.AssetsManager;
    import sg.manager.LoadeManager;
    import sg.manager.ModelManager;

    public class ViewSeasonPanel extends seasonPanelUI
    {
        private var mTabData:Array;
        private var cfg:Object;
        public function ViewSeasonPanel()
        {
            mTabData = [
                Tools.getMsgById("510052"), 
                Tools.getMsgById("510067"), 
                Tools.getMsgById("510068"), 
                Tools.getMsgById("510069")
            ];
            this.tab.selectHandler = new Handler(this,this.tab_select);
            this.list.itemRender = SeasonBase;
			this.list.scrollBar.hide = true;
        }

        override public function initData():void
        {
            super.initData();
            this.tab.labels = mTabData.join();
            this.cfg = ConfigServer.system_simple['season'];
            comTitle.setViewTitle(Tools.getMsgById("_jia0091"));
            txt_tips.text = Tools.getMsgById("510050");
        }

        override public function onAddedBase():void
        {
            super.onAddedBase();
            tab.selectedIndex = ModelManager.instance.modelUser.getGameSeason();
        }

        private function tab_select(index:int):void
        {
            img_icon.skin = AssetsManager.getAssetsUI('icon_season' + (index + 1) + '.png');
            var data:Object = cfg[index];
            // TODO 添加插画
            if (data['scenery']) {
                LoadeManager.loadTemp(this.img_bg, AssetsManager.getAssetsUI(data['scenery']));
            }
            list.array = data['entry'];
            list.scrollTo(0);
        }
    }
}