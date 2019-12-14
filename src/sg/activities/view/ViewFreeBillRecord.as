package sg.activities.view
{
    import laya.html.dom.HTMLDivElement;

    import sg.activities.model.ModelFreeBill;
    import sg.model.ModelItem;
    import sg.utils.ObjectUtil;
    import sg.utils.Tools;

    import ui.activities.freeBill.freeBillRecordUI;

    public class ViewFreeBillRecord extends freeBillRecordUI
    {
        private var model:ModelFreeBill = ModelFreeBill.instance;
        private var _info:HTMLDivElement;
        public function ViewFreeBillRecord()
        {
            //this.title.text = Tools.getMsgById('_jia0063'); // 免单记录
            this.comTitle.setViewTitle(Tools.getMsgById("_jia0063"));
            // this.title.text = Tools.getMsgById('_jia0067', ['xxx']); // 购买xxx获得免单！
            
            // 描述
            _info = new HTMLDivElement();
            container_info.addChild(_info);
            _info.pos(10, 10);
            _info.style.width = 500;  
			_info.style.color = "#fff";
			_info.style.fontSize = 18;
			_info.style.leading = 5; // 行距
			_info.style.letterSpacing = 1; // 字符间距
        }

        override public function onAddedBase():void
        {
            super.onAddedBase();
            this.refreshInfo();
        }

        private function refreshInfo():void
        {
            var arr:Array = model.freeList;
            var temp:Array = [];
            var len:int = arr.length;
            for(var i:int = 0; i < len; i++)
            {
                var data:Object = arr[i];
                var iId:String = ObjectUtil.keys(data[0])[0];
                temp.push(Tools.dateFormat(data[1], 1) + ' ' + Tools.getMsgById('_jia0067', [ModelItem.getItemName(iId) + '*' + data[0][iId]]));
            }
			_info.innerHTML = temp.join('<br />');
            container_info.scrollTo(0, 0);
            // container_info.vScrollBar.max = _info.contextHeight;
            _info.height = _info.contextHeight;
            container_info.refresh();

            // 检测是否需要显示滑动条
            // container_info.vScrollBar.visible = container_info.height < _info.height;  
            container_info.vScrollBar.visible = false;  
        }
    }
}