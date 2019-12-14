package sg.view.more
{
    import laya.events.Event;
    import sg.model.ModelSettings;
    import ui.more.settings_baseUI;

    public class SettingBase extends settings_baseUI
    {
        private var _buttonState:Boolean;
        public function SettingBase()
        {
            
        }

        private function set dataSource(source:Object):void
        {
            if (!source) return;
			this._dataSource = source;
            switchName.text = source.name;
            _buttonState = source.value;
            switchOn.visible = switchOnPanel.visible = _buttonState;
            switchOff.visible = switchOffPanel.visible = !_buttonState;
            switchOn.off(Event.CLICK, this, this._switchChange);
            switchOff.off(Event.CLICK, this, this._switchChange);
            switchOn.on(Event.CLICK, this, this._switchChange);
            switchOff.on(Event.CLICK, this, this._switchChange);
        }

        private function _switchChange():void
        {
            _buttonState = !_buttonState;
            switchOn.visible = switchOnPanel.visible = _buttonState;
            switchOff.visible = switchOffPanel.visible = !_buttonState;

            var state:Boolean = _buttonState;
            switch(this._dataSource.type) {
                case ModelSettings.TYPE_MUSIC:
                    ModelSettings.instance.musicActive = state;
                    break;
                case ModelSettings.TYPE_SOUND:
                    ModelSettings.instance.soundActive = state;
                    break;
                case ModelSettings.TYPE_MODEL:
                    ModelSettings.instance.modelActive = state;
                    break;
                case ModelSettings.TYPE_NOTIFY:
                    ModelSettings.instance.notifyActive = state;
                    break;
            }
            ModelSettings.instance.saveSettings();
        }
    }
}