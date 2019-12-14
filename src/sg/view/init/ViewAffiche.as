package sg.view.init
{
    import laya.display.Sprite;
    import laya.events.Event;
    import laya.html.dom.HTMLDivElement;
    import laya.ui.Button;
    import laya.utils.Handler;
    import sg.cfg.ConfigServer;
    import sg.manager.ViewManager;
    import sg.model.ModelGame;
    import sg.utils.SaveLocal;
    import sg.utils.Tools;
    import ui.init.affiche_mainUI;
    import sg.cfg.ConfigApp;

    public class ViewAffiche extends affiche_mainUI
    {
        public static const LOCAL_KEY:String = 'sg_affiche';
        private var _img:HTMLDivElement;
        private var _info:HTMLDivElement;
        private var _oriY:Number;
        private var _beginY:Number;
        private var _nameId:String;
        public var _idArr:Array = SaveLocal.getValue(LOCAL_KEY) as Array;
        private const titleMinY:Number = 6; // 标题容器的最小高度
        private var titleMaxY:Number = 0; // 标题容器的初始高度
        private var  infoOriH:Number = 0; // 文本容器的初始高度
        private var  offsetH:Number = 0; // 文本容器距标题容器的距离
        public function ViewAffiche() {
            titleMaxY = container_title.y;
            infoOriH = container_info.height;
            offsetH = container_info.y - container_title.y;

            // 图片
            _img = new HTMLDivElement();
            container_img.addChild(_img);

            // 描述
            _info = new HTMLDivElement();
            container_info.addChild(_info);
            container_info.vScrollBar.visible = false;
            _info.width = _info.style.width = container_info.width;
			_info.style.color = "#fff";
			_info.style.fontSize = 18;
			_info.style.leading = 12; // 行距
			_info.style.letterSpacing = 1; // 字符间距
            _info.y = 2;
            
            tabList.scrollBar.hide = true;
            tabList.renderHandler = new Handler(this, this.updateTab);
            tabList.array = tabData;

            com_title.setViewTitle(Tools.getMsgById("_jia0061"));
            btn_close.label = Tools.getMsgById("_jia0062");
            btn_close.on(Event.CLICK, this, this.closeSelf);
            // container_info.vScrollBar.showButtons = false;
            _idArr || (_idArr= []);
        }

        override public function onAdded():void{
            _info.on(Event.LINK,this,this.onLink);
        }

        override public function onRemoved():void{
            _info.off(Event.LINK,this,this.onLink);
        }

        private function onLink(url:*):void{
            Platform.other_fun(url);
        }

		override public function onAddedBase():void{
			super.onAddedBase();
            container_info.scrollTo(0, 0);
            tabList.selectedIndex = 0;
		}

        public static function get tabData():Array {
            var data:Array = ConfigServer.notice['notice'] || [];
            return data.filter(function(obj:Object):Boolean {
                return Tools.checkVisibleByPF(obj.pf);
            });
        }

        private function updateTab(btn:Button, index:int):void {
            var data:Object = btn.dataSource;
            var labelName:String = this._getMsgById(data.name);
            var middlePos:int = Math.floor(labelName.length * 0.5);
            if (labelName.length > 5) {
                labelName = labelName.slice(0, middlePos) + '\n' + labelName.slice(middlePos, labelName.length);
            }
            btn.label = labelName;
            var afficheId:* = data["id"];
            btn.off(Event.CLICK, this, this._onClickTab);
            if (tabList.selectedIndex === index) {
                btn.selected = true;
                this.setContent(data);
                if (_idArr.indexOf(afficheId) === -1) {
                    _idArr.push(afficheId);
                    SaveLocal.save(LOCAL_KEY, _idArr);
                }
            }
            else {
                btn.selected = false;
                btn.on(Event.CLICK, this, this._onClickTab, [index]);
            }
            ModelGame.redCheckOnce(btn, _idArr.indexOf(afficheId) === -1);
            
            var scene:* = ViewManager.instance.getCurrentScene();
            if (scene) {
                var btn_affiche:Sprite = scene.btn_affiche;
                btn_affiche && ModelGame.redCheckOnce(btn_affiche, redCheck());
            }
        }

        public static function redCheck():Boolean {
            var idArray:Array = SaveLocal.getValue(LOCAL_KEY) as Array || [];
            return tabData.some(function(obj:Object):Boolean {
                return idArray.indexOf(obj.id) === -1
            });
        }

        private function _onClickTab(index:int, event:Event):void
        {
            var btn:Button = event.currentTarget as Button;
            tabList.selectedIndex = index;
        }

        private function setContent(data:Object):void
        {
            if (_nameId === data.name)  return;
            _nameId = data.name;
            this._oriY = 0;
            this.title.text = this._getMsgById(data.name);
            if (data.image) {
                _img.visible = true;
                _img.innerHTML = "<img src='" + ConfigServer.system_simple.affiche_url + data.image + "'/>";//AssetsManager.getAssetsUI(data.image + ".png")
                container_title.y = titleMaxY;
                container_info.y = container_title.y + offsetH;
                container_info.height = infoOriH;
            }
            else {
                _img.visible = false;
                container_title.y = titleMinY;
                container_info.y = container_title.y + offsetH;
                container_info.height = infoOriH + titleMaxY;
            }
			_info.innerHTML=this._getMsgById(data.info);// 公告内容
            container_info.scrollTo(0, 0);
            // container_info.vScrollBar.max = _info.height = _info.contextHeight;
            _info.height = _info.contextHeight;
            container_info.refresh();

            // 检测是否需要显示滑动条
            // container_info.vScrollBar.visible = container_info.height < _info.height;
            // _info.style.width = container_info.width - (container_info.height < _info.height ? container_info.vScrollBar.width : 0);

            this.txt_date.text = this._getMsgById(data.dateshow);
        }

        private function _getMsgById(id:String, arg:Array = null):String {
            var msgs:Object = ConfigServer.notice['notice_cn'];
            return msgs[id] || '';
        }
    }
}