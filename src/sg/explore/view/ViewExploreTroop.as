package sg.explore.view
{
    import sg.utils.Tools;
    import laya.utils.Handler;
    import sg.view.fight.ViewClimbTroop;
    import sg.manager.ViewManager;

    public class ViewExploreTroop extends ViewClimbTroop
    {
        protected var handler:Handler;
        public function ViewExploreTroop() {
            super();
            this.text1.text = '';
            btn_fight.label = Tools.getMsgById("_explore023");
        }

        override public function initData():void {
            handler = currArg.handler;
            currArg.title && comTitle.setViewTitle(currArg.title);
            super.initData();
            box_hint.visible = mMaxTroop > 1;
            box_list.top = box_hint.visible ? 80 : 45;
        }

        override protected function chooseFinished(hidArr:Array):void {
            if (hidArr.length < mMaxTroop) {
                ViewManager.instance.showHintPanel(
                    Tools.getMsgById('_explore054', [mMaxTroop]), // 内容
                    null,
                    [
                        {'name': Tools.getMsgById('_explore023'), 'handler': Handler.create(this, function():void {handler.runWith([hidArr]), this.closeSelf();})},
                        {'name': Tools.getMsgById('_shogun_text03'), 'handler': null},
                    ]
                );
            }
            else {
                handler.runWith([hidArr]);
                this.closeSelf();
            }
        }
    }
}