package sg.view.map
{
    import ui.map.bless_hero_rankUI;
    import sg.utils.Tools;
    import sg.model.ModelBlessHero;
    import sg.net.NetMethodCfg;
    import sg.net.NetPackage;
    import laya.utils.Handler;
    import sg.model.ModelUser;
    import sg.manager.ModelManager;

    public class ViewBlessHeroRank extends bless_hero_rankUI
    {
        private var model:ModelBlessHero = ModelBlessHero.instance;
        private var rankData:Array;
        private var myData:Array;
        public function ViewBlessHeroRank()
        {
            list.scrollBar.hide = true;
            list.itemRender = BlessHeroRankBase;
            com_title.setViewTitle(Tools.getMsgById('bless_hero_04'), true);
            txt_title_rank.text = Tools.getMsgById('_more_rank06');
            txt_title_name.text = Tools.getMsgById('_public205');
            txt_title_time.text = Tools.getMsgById('bless_hero_14');
            txt_title_hurt.text = Tools.getMsgById('bless_hero_15');
            txt_tips.text = Tools.getMsgById('bless_hero_05', [model.show_num]);
            txt_none.text = Tools.getMsgById('bless_hero_12');
        }

        override public function onAdded():void {
            rankData = currArg[0];
            myData = currArg[1];
            list.array = rankData;
            box_hint.visible = rankData.length === 0;
            var user:ModelUser = ModelManager.instance.modelUser;
            var myRank:int = myData[2];
            my_rank.setData(user.mUID, user.uname, user.country, myRank, myData[1] * Tools.oneMillis, myData[0]);
        }
    }
}