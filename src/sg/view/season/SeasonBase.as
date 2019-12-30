package sg.view.season
{
    import ui.menu.seasonBaseUI;
    import sg.utils.Tools;
    import sg.cfg.ConfigServer;
    import sg.manager.ModelManager;

    public class SeasonBase extends seasonBaseUI
    {
        public function SeasonBase()
        {
        }

        override public function set dataSource(source:*):void {
            if (!source) return;
			this._dataSource = source;
            var cfg:Object = ConfigServer.system_simple['season'];
			txt_title.text = Tools.getMsgById(source['name']);
			txt_info.text = Tools.getMsgById(source['info']);
            var limit:Array = source['limit'];
            txt_tips.visible = false;
            if (limit && limit.length) {
                var limitLv:int = limit[1];
                if (ModelManager.instance.modelInside.getBase().lv < limitLv) {
                    txt_tips.visible = true;
                    txt_tips.text = Tools.getMsgById(cfg['limit'], [Tools.getMsgById(limit[0]), limitLv]);
                }
            }
        }
    }
}