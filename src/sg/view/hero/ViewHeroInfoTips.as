package sg.view.hero
{
    import ui.hero.hero_infoUI;
    import sg.model.ModelHero;
    import sg.utils.Tools;

    public class ViewHeroInfoTips extends hero_infoUI
    {
        public function ViewHeroInfoTips()
        {
            // this.mouseEnabled = false;
            this.mBg.alpha = 0;
        }
        override public function initData():void{
            this.tInfo.text = Tools.getMsgById((this.currArg as ModelHero).info);
        }
    }
}