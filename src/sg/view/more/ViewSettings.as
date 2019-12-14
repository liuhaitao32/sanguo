package sg.view.more
{
    import ui.more.settings_mainUI;
    import sg.model.ModelSettings;
    import sg.utils.Tools;
    import laya.events.Event;

    public class ViewSettings extends settings_mainUI
    {
        private var model:ModelSettings = ModelSettings.instance;
        public function ViewSettings()
        {
			this.list.itemRender = SettingBase;
            //this.title.text = Tools.getMsgById('_settings001');
            this.comTitle.setViewTitle(Tools.getMsgById('_settings001'));
        }

        override public function onAdded():void {
            this.list.array = model.getListData();
        }


    }
}