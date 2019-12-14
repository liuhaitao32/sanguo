package sg.view.init
{
    import laya.events.Event;
    import laya.ui.Button;
    import laya.utils.Handler;
    import sg.utils.Tools;
    import ui.init.viewHintUI;
    import sg.guide.model.ModelGuide;

    public class ViewHintPanel extends viewHintUI
    {
        private var oriX_0:Number = 0;
        private var oriX_1:Number = 0;
        public function ViewHintPanel()
        {
            oriX_0 = btn0.x;
            oriX_1 = btn1.x;
        }
		override public function initData():void {
            var title:String = currArg['title'];
            var content:String = currArg['content'];
            var dataArr:Array = currArg['dataArr'];
            txt_content.text = content;

            // 重置按钮
            btn0.x = oriX_0;
            btn1.x = oriX_1;
            btn0.clearEvents();
            btn1.clearEvents();
            btn0.visible = btn1.visible = false;

            comTitle.setViewTitle(title ? title : Tools.getMsgById("_jia0082"));
            btn0.label = Tools.getMsgById('_public183');
            btn1.label = Tools.getMsgById('_shogun_text03');
            this._setButton(dataArr);
        }

		override public function onAdded():void{
            if (ModelGuide.forceGuide()) {
                this.closeSelf();
            }
        }

        private function _setButton(dataArr:Array):void
        {
            if (!dataArr is Array) {
                btn0.visible = true;
                btn0.centerX = 0;
                btn0.clearEvents();
                btn0.once(Event.CLICK, this, this._onClickButton);
                return;
            }
            for(var i:int = 0; i < 2; ++i) {
                var obj:Object = dataArr[i];
                var btn:Button = this['btn' + i];
                if (obj) {
                    btn.visible = true;
                    btn.label = obj.name;
                    btn.clearEvents();
                    btn.once(Event.CLICK, this, this._onClickButton, [obj && obj.handler ? obj.handler : null]);
                }
            }
            dataArr.length < 2 && (btn0.centerX = 0);
        }

        private function _onClickButton(handler:Handler):void {
            this.closeSelf();
            handler is Handler && handler.run();
        }
    }
}