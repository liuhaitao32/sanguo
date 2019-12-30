package sg.festival.view
{
    import ui.festival.festival_act_buttonUI;
    import sg.utils.Tools;
    import sg.model.ModelGame;
    import sg.manager.AssetsManager;
    import sg.festival.model.ModelFestival;

    public class FestivalTabButton extends festival_act_buttonUI
    {
        private var model:ModelFestival = ModelFestival.instance;
        public function FestivalTabButton() {
        }

        override public function set dataSource(source:*):void {
            if (!source)    return;
            btn.skin = AssetsManager.getAssetsUI(source.button);
            var actName:String = Tools.getMsgById(source ? source.icon_name : '');
            if (source && source.icon_name_size) {
                txt_name.fontSize = source.icon_name_size;
            }
            txt_name.text = actName;
            Tools.textFitFontSize2(txt_name);
            txt_name.color = model.actCfg.font_color[source.selected ? 1 : 0];
            btn.selected = source.selected;
            ModelGame.redCheckOnce(btn, source.red);
        }
    }
}