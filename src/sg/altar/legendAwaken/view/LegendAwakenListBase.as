package sg.altar.legendAwaken.view
{
    import ui.legendAwaken.legendAwakenListBaseUI;
    import sg.utils.Tools;
    import sg.manager.AssetsManager;
    import sg.altar.legendAwaken.model.ModelLegendAwaken;
    import sg.view.com.ComPayType;

    public class LegendAwakenListBase extends legendAwakenListBaseUI
    {
        public function LegendAwakenListBase() {
            txt_hint.text = Tools.getMsgById('500307');
        }

        private function set dataSource(source:Object):void {
            if (!source) return;
            _dataSource = source;
            icon.setHeroIcon(source.hid + '_1');
            box_hint.visible = source.awaken === true;
            img_select.visible = source.select;
            box_price.visible = source.awaken === false;
            img_item.skin = AssetsManager.getAssetsICON(ModelLegendAwaken.instance.itemId + '.png');
            txt_price.text = source.price;
        }
    }
}