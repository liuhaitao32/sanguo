package sg.explore.view
{
    import sg.view.map.ViewPVETroop;
    import sg.explore.model.ModelTreasureHunting;
    import sg.utils.Tools;

    public class ViewPKHunt extends ViewPVETroop
    {
        public function ViewPKHunt()
        {
        }

		override public function initData():void {
            super.initData();
            var magic_id:String = ModelTreasureHunting.instance.magic_id;
            var data:Object = ModelTreasureHunting.instance.cfg.magic_date[magic_id];
            if (data && data.attack_value && data.attack_value > 0) {
                txt_mine_name_magic.text = Tools.getMsgById('_explore018') + ':' + Tools.getMsgById(data ? data.name : '');
                txt_mine_info_magic.text = Tools.getMsgById(data ? data.info : '');
                box_pray_mine.visible = true;
                var offset:int = 70;
                mBox.height += offset;
                bar1.width += offset;
            } else {
                box_pray_mine.visible = false;
            }
        }
    }
}