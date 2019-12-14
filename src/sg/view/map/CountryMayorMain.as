package sg.view.map
{
    import ui.map.country_mayor_mainUI;
    import ui.map.item_country_mayorUI;
    import laya.utils.Handler;
    import sg.model.ModelOfficial;
    import sg.manager.ModelManager;
    import sg.utils.Tools;
    import laya.events.Event;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import sg.net.NetPackage;
    import laya.ui.ISelect;
    import laya.ui.Button;
    import laya.maths.MathUtil;
    import sg.model.ModelUser;
    import sg.cfg.ConfigServer;
    import sg.model.ModelCityBuild;

    public class CountryMayorMain extends country_mayor_mainUI
    {
        public function CountryMayorMain()
        {
            this.on(Event.REMOVED,this,this.onRemove);
            //
            this.tab0.dataSource = [Tools.getMsgById("_lht20"),,,Tools.getMsgById("_country13"),Tools.getMsgById("lvup05_2_name")];
            this.tab.dataSource = [Tools.getMsgById("_jia0099"),Tools.getMsgById("_country17")];
            this.tab.selectHandler = new Handler(this,this.tab_select);
            //
            this.list.itemRender = item_country_mayorUI;
            this.list.renderHandler = new Handler(this,this.list_render);
            this.list.scrollBar.hide = true;
            //
            this.tab.selectedIndex = 0;
            //
            ModelManager.instance.modelOfficel.on(ModelOfficial.EVENT_SET_MAYOR_IS_OK,this,this.tab_select,[this.tab.selectedIndex]);

            this.text0.text=Tools.getMsgById("_country46");
            this.text1.text=Tools.getMsgById("_country47");
        }
        private function tab_select(index:int):void
        {
            if(index>-1){
                this.tabs0.rotation = (index == 0)?180:0;
                this.tabs1.rotation = (index == 1)?180:0;
                var arr:Array = ModelOfficial.getMyCities(ModelUser.getCountryID(), ConfigServer.world['cityTypeCanBuild']);

                var abc:Array = arr.concat();
                var len:int = abc.length;
                var element:Object;
                for(var i:int = 0; i < len; i++)
                {
                    element = abc[i];
                    element["sortType"] = index === 0 ? ModelOfficial.getCityCfg(element.cid).cityType : ModelCityBuild.getBuildRatio(element.cid);
                }
                abc.sort(MathUtil.sortByKey("sortType",true));
                this.init(abc);
            }
        }
        private function onRemove():void{
            ModelManager.instance.modelOfficel.off(ModelOfficial.EVENT_SET_MAYOR_IS_OK,this,this.tab_select);
            this.tab.selectedIndex = -1;
            this.tab.destroy(true);
            this.list.destroy(true);
            this.destroyChildren();
            this.destroy(true);
        }
        private function init(arr:Array):void{
            this.list.dataSource = arr;
            //
            var len:int = arr.length;
            var city:Object;
            var mayor:Object;
            //
            var ok:Number = 0;
            var no:Number = 0;
            for(var i:int = 0; i < len; i++)
            {
                city = arr[i];
                mayor = ModelOfficial.getCityMayor(city.cid);
                if(Tools.isNullObj(mayor)){
                    no +=1
                }
                else{
                    ok +=1;
                }
            }
            this.tInfo1.text = ""+ok;
            this.tInfo2.text = ""+no;
        }
        private function list_render(item:item_country_mayorUI,index:int):void
        {
            var data:Object = this.list.array[index];
            item.tName.text = ModelOfficial.getCityName(data.cid);
            item.tType.text =  Tools.getMsgById("cityType"+ModelOfficial.getCityCfg(data.cid).cityType);
            item.tNum.text = ModelCityBuild.getBuildRatio(data.cid);
            //
            var noStr:String = Tools.getMsgById("_public76");//无
            var mayor:Array = ModelOfficial.getCityMayor(data.cid);
            item.tMayor.text = mayor?mayor[1]:noStr;
            item.tTeam.text = mayor?(Tools.isNullString(mayor[2])?noStr:mayor[2]):noStr;
            //
            item.icon.visible = mayor?(Tools.isNullString(mayor[1])?false:true):false;
            //
            item.off(Event.CLICK,this,this.click);
            item.on(Event.CLICK,this,this.click,[index]);
        }
        private function click(index:int):void
        {
            if(ModelOfficial.isKing(ModelManager.instance.modelUser.mUID)>-1 || ModelOfficial.isGovernor(ModelManager.instance.modelUser.mUID)>-1){
                var data:Object = this.list.array[index];
                //cid//uid
                ViewManager.instance.showView(ConfigClass.VIEW_COUNTRY_MAYOR_LIST,[null,data]);
            }
            else{
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_country1"));//只有国王和郡丞能分配太守
            }
            
        }
    }   
}