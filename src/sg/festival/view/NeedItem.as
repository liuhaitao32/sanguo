package sg.festival.view
{
    import ui.festival.needItemUI;
    import sg.model.ModelItem;

    public class NeedItem extends needItemUI
    {
        public function NeedItem()
        {
            
        }

        override public function set dataSource(source:*):void {
            if (source is Array) {
                _dataSource = source;
                var itemId:String = source[0];
                itemIcon.setData(itemId, -1, -1);
                var haveNum:int = ModelItem.getMyItemNum(itemId);
                var needNum:int = source[1];
                var enough:Boolean = haveNum >= needNum;
                // haveNum = enough ? needNum : haveNum;
                txt_need.color = enough ? '#a4ff67' : '#ff683f';
                txt_need.text = haveNum + '/' + needNum;
            }
        }
    }
}