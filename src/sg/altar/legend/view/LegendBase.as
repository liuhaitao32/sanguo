package sg.altar.legend.view
{
    import ui.fight.legendBaseUI;
    import sg.altar.legend.model.ModelLegend;
    import laya.events.Event;
    import sg.boundFor.GotoManager;
    import sg.model.ModelGame;
    import sg.utils.Tools;

    public class LegendBase extends legendBaseUI
    {
        public function LegendBase()
        {
            txt_info_experience.text = Tools.getMsgById('legend4');
            this.on(Event.CLICK, this, this._onClick);
        }

        private function set dataSource(source:Object):void {
            if (!source) return;
            _dataSource = source;
            this.disabled = img_foreshow.visible = box_road.visible = box_experience.visible = false;
            bar.visible = true;
            ModelGame.redCheckOnce(this, source.reward);
            switch(source.type) {
                case ModelLegend.TYPE_ROAD:
                    box_road.visible = true;
                    txt_name_road.text = source.name;
                    txt_info_road.text = source.info;
                    character_road.setHeroIcon(source.hid);
                    bar.value = source.value;
                    if (!Boolean(source.hid)) {
                        img_foreshow.visible = true;
                        this.disabled = true;
                        txt_info_road.visible = bar.visible = false;
                        character_road.setHeroIcon('hero000');
                    }
                    break;
                case ModelLegend.TYPE_EXPERIENCE:
                    box_experience.visible = true;
                    txt_name_experience.text = source.name;
                    character_experience.setHeroIcon(source.hid);
                    break;
            }
        }

        private function _onClick():void {
            var hid:String = _dataSource.hid;
            var type:String = _dataSource.type;
            switch(type) {
                case ModelLegend.TYPE_ROAD:
                    GotoManager.boundForPanel(GotoManager.VIEW_LEGEND_ROAD, '', hid);
                    break;
                case ModelLegend.TYPE_EXPERIENCE:
                    GotoManager.boundForPanel(GotoManager.VIEW_LEGEND_EXPERIENCE, '', hid);
                    break;
            }
        }
    }
}