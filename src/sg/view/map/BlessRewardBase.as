package sg.view.map
{
    import ui.map.bless_reward_baseUI;

    public class BlessRewardBase extends bless_reward_baseUI
    {
        public function BlessRewardBase()
        {
        }
        
        private function set dataSource(source:Array):void {
            item.setData(source[0], source[1], -1);
            box_finish.visible = source[2];
        }
    }
}