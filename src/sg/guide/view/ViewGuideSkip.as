package sg.guide.view
{
    import ui.guide.guideSkipUI;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import laya.utils.Handler;
    import sg.net.NetPackage;
    import sg.manager.ModelManager;
    import laya.events.Event;
    import sg.guide.model.GuideChecker;
    import sg.manager.LoadeManager;
    import sg.manager.AssetsManager;
    import sg.utils.Tools;

    public class ViewGuideSkip extends guideSkipUI
    {
        public function ViewGuideSkip()
        {
            this.isAutoClose = false;
            box_skip.once(Event.CLICK, this, this._skipGuide);
            box_back.once(Event.CLICK, this, this._continueGuide);
        }

        override public function onAddedBase():void {
            super.onAddedBase();
            LoadeManager.loadTemp(btn_back, AssetsManager.getAssetsAD('actPay1_12.png'));
            LoadeManager.loadTemp(btn_skip, AssetsManager.getAssetsAD('actPay1_13.png'));
            txt_title_new.text  = Tools.getMsgById('_jia0111');
            txt_title_old.text  = Tools.getMsgById('_jia0112');
            txt_tips_new.text   = Tools.getMsgById('_jia0113');
            txt_tips_old.text   = Tools.getMsgById('_jia0114');
        }

        private function _continueGuide():void {
            ModelManager.instance.modelUser.records.guide = ['g001', 0];
            GuideChecker.instance.startGuide();
            this.isAutoClose = true;
            this.closeSelf();
        }

        private function _skipGuide():void {
            GuideChecker.instance.skipGuide();
            this.isAutoClose = true;
            this.closeSelf();
        }
    }
}