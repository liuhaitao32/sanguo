package sg.festival.view
{
    import ui.festival.festival_list_day_baseUI;
    import sg.festival.model.ModelFestivalLogin;
    import sg.utils.Tools;
    import laya.ui.Label;
    import laya.ui.Image;

    public class FestivalLoginDayBase extends festival_list_day_baseUI
    {
		private var _counter:int;
        public function FestivalLoginDayBase() {
			Laya.timer.frameLoop(1, this, this._onTimer);
            txt_0.text = Tools.getMsgById('_festival011');
            Tools.textFitFontSize(txt_0);
            txt_1.text = Tools.getMsgById('_festival012');
            Tools.textFitFontSize(txt_1);
        }
        
        override public function set dataSource(source:*):void {
            if (!source) {
                return;
            }
            txt_day.text = source.id + 1;
            img_shadow.visible = img_receive.visible = img_overdue.visible = img_red.visible = false;
            img_blue.alpha = 1;
            box_current.visible = source.selected;
            switch(source.state) {
                case ModelFestivalLogin.TYPE_VALID: // 可领奖
                    img_red.visible = true;
                    break;
                case ModelFestivalLogin.TYPE_ALREADY: // 已领奖
                    img_blue.alpha = 0.7;
                    img_shadow.visible = img_receive.visible = true;
                    break;
                case ModelFestivalLogin.TYPE_INVALID: // 过期
                    img_blue.alpha = 0.7;
                    img_shadow.visible = img_overdue.visible = true;
                    break;
                case ModelFestivalLogin.TYPE_UNACTIVATED: // 未到时间
                    break;
            }
        }
		
		private function _onTimer():void {
            this._counter++;
            var speed:Number = 0.08;
            box_current.alpha = Math.sin(_counter * speed) * 0.4 + 0.6;
        }
    }
}