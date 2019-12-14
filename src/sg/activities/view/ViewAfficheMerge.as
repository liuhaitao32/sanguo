package sg.activities.view
{
    import ui.init.affiche_mergeUI;
    import sg.cfg.ConfigServer;
    import sg.utils.TimeHelper;
    import laya.html.dom.HTMLDivElement;
    import sg.utils.Tools;
    import sg.activities.model.ModelAfficheMerge;
    import laya.events.Event;

    public class ViewAfficheMerge extends affiche_mergeUI
    {
        private var _info:HTMLDivElement;
        private var model:ModelAfficheMerge = ModelAfficheMerge.instance;
        private var  infoOriH:Number = 0; // 文本容器的初始高度
        public function ViewAfficheMerge()
        {
            // 描述
            _info = new HTMLDivElement();
            infoOriH = container_info.height;
            container_info.addChild(_info);
            container_info.vScrollBar.visible = false;
            _info.width = _info.style.width = container_info.width;
			_info.style.color = "#fff";
			_info.style.fontSize = 18;
			_info.style.leading = 12; // 行距
			_info.style.letterSpacing = 1; // 字符间距
            btn_close.on(Event.CLICK, this, this.closeSelf);
        }

        override public function set currArg(v:*):void {
			this.mCurrArg = v;
		}

        override public function initData():void {
        }

        override public function onAdded():void {
            this.setContent();
            this.refreshTime();
            Laya.timer.loop(1000, this, this.refreshTime);
        }

        private function setContent():void {
			_info.innerHTML = model.info;// 公告内容
            container_info.scrollTo(0, 0);
            _info.height = _info.contextHeight;
            container_info.refresh();
        }

        private function refreshTime():void {
            txt_time.text = Tools.getMsgById('_jia0130') + TimeHelper.formatTime(model.remainTime);
        }

        override public function onRemoved():void {
            Laya.timer.clear(this, this.refreshTime);
        }
    }
}