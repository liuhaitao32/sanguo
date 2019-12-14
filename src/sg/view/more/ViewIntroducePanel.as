package sg.view.more
{
    import laya.events.Event;
    import laya.ui.Button;
    import sg.manager.ViewManager;
    import ui.more.introducePanelUI;

    public class ViewIntroducePanel extends introducePanelUI
    {
	    private var btnBG:Button;
        public function ViewIntroducePanel()
        {
            btnBG=new Button;
            btnBG.alpha=0;
            btnBG.on(Event.CLICK,this,this.bgClick);
            this.addChild(btnBG);
            btnBG.height=this.height;
            btnBG.width=this.width;
            btnBG.centerX=btnBG.centerY=0;
            this.mBg.alpha = 0; 
        }

		override public function set currArg(v:*):void
		{
			this.mCurrArg = v;
            v is String && this.setIntroduce(v);
            v['title'] && this.setTitle(v['title']);
            v['intro'] && this.setIntroduce(v['intro']);
            this.lightPic.visible = this.panel2.visible = Boolean((/\S/).test(v['title']));
            this.panel1.visible = !this.panel2.visible;
		}

        private function setTitle(str:String):void
        {
            this.titleTxt.text = str;
        }

        private function setIntroduce(str:String):void
        {
            this.introduceTxt.text = str;
        }

        private function bgClick():void{
            ViewManager.instance.closePanel(this);
        }

    }
}