package sg.altar.legend.view
{
    import sg.utils.Tools;
    import laya.utils.Handler;
    import sg.explore.view.ViewExploreTroop;

    public class ViewLegendTroop extends ViewExploreTroop
    {
        private var handler:Handler;
        public function ViewLegendTroop() {
            super();
            btn_fight.label=Tools.getMsgById("_climb48");
        }
        
        override protected function setUI():void{
            super.setUI();
            btn_fight.disabled = btn_fight.gray = mSelectArr.length < mMaxTroop;
        }
    }
}