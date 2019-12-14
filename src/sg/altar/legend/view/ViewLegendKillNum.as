package sg.altar.legend.view
{
    import ui.fight.legendKillNumUI;
    import sg.utils.Tools;
    import laya.events.Event;

    public class ViewLegendKillNum extends legendKillNumUI
    {
        public function ViewLegendKillNum() {
            txt_hint.text = Tools.getMsgById('legend2');
            this.on(Event.CLICK, this, this.closeSelf);
        }
		override public function initData():void {
            txt_kill.text = currArg;
        }

		override public function onAdded():void {
        }

		override public function onRemoved():void {
        }
    }
}