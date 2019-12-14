package sg.view.map
{
    import ui.map.country_rank_powerUI;
    import laya.events.Event;
    import ui.map.item_country_powerUI;
    import laya.utils.Handler;
    import sg.model.ModelOfficial;
    import laya.maths.MathUtil;
    import sg.model.ModelBuiding;
    import sg.utils.Tools;

    public class CountryRankPower extends country_rank_powerUI
    {
        public function CountryRankPower()
        {
            this.on(Event.REMOVED,this,this.onRemove);
            this.list.itemRender = item_country_powerUI;
            this.list.renderHandler = new Handler(this,this.list_render);
            this.list.scrollBar.hide = true;
            //
            this.initData();
        }
        private function initData():void
        {
            var len:int = 3;
            var arr:Array = [];
            for(var i:int = 0;i < len;i++){
                arr.push({num:ModelOfficial.getMyCities(i).length,ct1:ModelOfficial.getMyCities(i,[1]).length,ct2:ModelOfficial.getMyCities(i,[2]).length,ct3:ModelOfficial.getMyCities(i,[3]).length,ct4:ModelOfficial.getMyCities(i,[4]).length,country:i});
            }
            arr.sort(MathUtil.sortByKey("num",true));
            //
            this.list.array = arr;
        }
        private function onRemove():void{
            this.list.destroy(true);
            this.destroyChildren();
            this.destroy(true);
        }        
        private function list_render(item:item_country_powerUI,index:int):void
        {
            var data:Object = this.list.array[index];
            item.tNum.text = data.num;
            item.tct1.text = data.ct1+"";
            item.tct2.text = data.ct2+"";
            item.tct3.text = data.ct3+"";
            item.tct4.text = data.ct4+"";
            item.txt_title.text = Tools.getMsgById('_jia0096');
            item.txt_hint0.text = Tools.getMsgById('_jia0097');
            item.txt_hint1.text = Tools.getMsgById('_jia0098');
            var len:int = 3;
            for(var i:int = 0;i < len;i++){
                item["c"+i].visible = (data.country==i);
            }
            var store:Object = ModelOfficial.getMyCountryCfg(data.country);
            item.goldIcon.setData(ModelBuiding.getMaterialTypeUI("gold"),Tools.textSytle(store["gold"])+"");
            item.foodIcon.setData(ModelBuiding.getMaterialTypeUI("food"),Tools.textSytle(store["food"])+"");
        }        
    }
}