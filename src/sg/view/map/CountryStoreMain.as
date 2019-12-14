package sg.view.map
{
    import ui.map.country_store_mainUI;
    import ui.map.item_country_storeUI;
    import laya.utils.Handler;
    import laya.ui.Button;
    import laya.events.Event;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import sg.manager.ModelManager;
    import sg.model.ModelOfficial;
    import sg.cfg.ConfigServer;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import sg.net.NetPackage;
    import sg.utils.Tools;
    import ui.map.item_country_store_cityUI;
    import sg.outline.view.OutlineViewMain;
    import laya.maths.MathUtil;
    import sg.utils.ObjectSingle;
    import sg.model.ModelUser;

    public class CountryStoreMain extends country_store_mainUI
    {
        private var _outline:OutlineViewMain;
        private var mCountryData:Object;
        private var mStoreBudget:Array = [];
        public function CountryStoreMain()
        {
            this.on(Event.REMOVED,this,this.onRemove);
            ModelManager.instance.modelOfficel.on(ModelOfficial.EVENT_UPDATE_COUNTRY_DATA,this,this.event_update_country_data);
            //
            this.list.itemRender = item_country_storeUI;
            this.list.renderHandler = new Handler(this,this.list_render);
            this.list.scrollBar.hide = true;
            //
            this.listCity.itemRender = item_country_store_cityUI
            this.listCity.renderHandler = new Handler(this,this.listCity_render);
            // this.listCity.scrollBar.hide = true;
            //
			this._outline = new OutlineViewMain(this,false);			
			this.scene_container.addChild(this._outline);
            this.scene_container.scale(0.45,0.38);
            this.scene_container.mouseEnabled = false;
            this.scene_container.mouseThrough = false;
            this._outline.tMap.moveViewPort(0,0);
            //
            // trace(this._outline.width,this._outline.height);
            //
            this.init();
        }
        public function click_closeScenes():void
        {
            Tools.destroy(this._outline);
        }
        private function onRemove():void{
            ModelManager.instance.modelOfficel.off(ModelOfficial.EVENT_UPDATE_COUNTRY_DATA,this,this.event_update_country_data);
            this.click_closeScenes();
            this.list.destroy(true);
            this.listCity.destroy(true);
            this.destroyChildren();
            this.destroy(true);
        }        
        private function event_update_country_data():void
        {
            this.init();
        }
        private function init():void
        {
            this.mStoreBudget = [0,0,0];
            //
            var cities:Array = ModelOfficial.getMyCities(ModelUser.getCountryID());
            var ctd:Object = {0:0,1:0,2:0,3:0,4:0};
            var len:int = cities.length;
            var ccfg:Object;
            var ctdArr:Array = [];
            var pArr:Array;
            for(var i:int = 0; i < len; i++)
            {
                ccfg = ModelOfficial.getCityCfg(cities[i].cid);
                pArr = ModelOfficial.getStoreToSeason(ModelOfficial.getCityStoreToCountry(cities[i].cid));
                //
                this.mStoreBudget[0]+=pArr[0];
                this.mStoreBudget[1]+=pArr[1];
                this.mStoreBudget[2]+=pArr[2];
                if(ccfg.cityType>=0 && ccfg.cityType<=4){
                    if(ctd.hasOwnProperty(ccfg.cityType)){
                        ctd[ccfg.cityType] +=1;
                    }
                    else{
                        ctd[ccfg.cityType] = 1;
                    }
                }
            }
            for(var key:String in ctd)
            {
                ctdArr.push({type:key,num:ctd[key]});
                
            }
            ctdArr.sort(MathUtil.sortByKey("type",true));
            this.listCity.array = ctdArr;
            //
            this.getDataToCountry();
            //
            this.getCountryInfo();
        }
        private function getCountryInfo():void
        {
            NetSocket.instance.send(NetMethodCfg.WS_SR_GET_COUNTRY_INFO,{tid:ModelUser.getCountryID()},Handler.create(this,this.reCountryInfo));
            
        }
        private function getDataToCountry():void{
            this.mCountryData = ModelOfficial.getMyCountryCfg();
            var arr:Array = ["coin","gold","food"];
            this.list.array = arr;
        }
        private function reCountryInfo(re:NetPackage):void
        {
            ModelOfficial.countries[re.sendData.tid] = re.receiveData;

            this.getDataToCountry();
        }
        private function list_render(item:item_country_storeUI,index:int):void
        {
            var type:String = this.list.array[index];
            //
            item.tTimesHint.text = Tools.getMsgById("_estate_text03", [Tools.getMsgById('_jia0095')]);
            item.btn.label = Tools.getMsgById('_jia0095');
            if(type == "coin"){
                item.tNum.text = Tools.getMsgById("_public80")+":"+Math.floor(this.mCountryData[type]);//黄金库存
                item.tTips.text = "";
            }
            else if(type == "gold"){
                item.tNum.text = Tools.getMsgById("_public81")+":"+Math.floor(this.mCountryData[type]);//钱币库存
                item.tTips.text = Tools.getMsgById("_public83")+":"+Math.floor(this.mStoreBudget[1]);//预计收入
            }
            else if(type == "food"){
                item.tNum.text = Tools.getMsgById("_public82")+":"+Math.floor(this.mCountryData[type]);//粮食库存
                item.tTips.text = Tools.getMsgById("_public83")+":"+Math.floor(this.mStoreBudget[2]);//预计收入
            }
            //
            var max:int = ConfigServer.country.warehouse.grant_second;
            var arr:Array = ModelOfficial.getStoreTimes(type);
            var used:int = arr[1];
            var storeMax:Number = ModelOfficial.getMyCountryCfg()[type];
            var everyNum:Number = ModelOfficial.getStoreNum(type)[1];
            var b:Boolean = (used<max && storeMax >= everyNum && ModelOfficial.isKing(ModelManager.instance.modelUser.mUID)>-1);
            var status:Number = 0;  
            if(ModelOfficial.isKing(ModelManager.instance.modelUser.mUID)<0){
                status = 1;
            }    
            else{
                if(used >= max){
                    status = 2;
                }
                else{
                    if(storeMax<everyNum){
                        status = 3;
                    }
                }
            }     
            //
            item.tTimes.text = (max-used)+" / "+max;
            item.tInfo.text = Tools.getMsgById(ConfigServer.country.warehouse.info[index]);

            item.btn.gray = !b;//ModelOfficial.isKing(ModelManager.instance.modelUser.mUID)<0 || (used>=max);
            item.btn.offAll(Event.CLICK);   
            item.btn.on(Event.CLICK,this,this.click,[type,status]);
        }
        private function click(type:String,status:Number):void
        {
            if(status>0)
            {
                var tips:Array = ["","_country3","_country3_1","_country3_2"];
                ViewManager.instance.showTipsTxt(Tools.getMsgById(tips[status]));//只有王可以封赏
                return;
            }
            // if(ModelOfficial.isKing(ModelManager.instance.modelUser.mUID)>-1){
                var max:int = ConfigServer.country.warehouse.grant_second;
                var arr:Array = ModelOfficial.getStoreTimes(type);
                var used:int = arr[1];
                if(used<max){
                    // if(ModelOfficial.isKing(ModelManager.instance.modelUser.mUID)>-1){
                        //
                        NetSocket.instance.send(NetMethodCfg.WS_SR_GET_GUILD_LIST,{},Handler.create(this,this.ws_sr_get_guild_list),type);
                    // }
                }
            // }else {
            //     ViewManager.instance.showTipsTxt(Tools.getMsgById("_country3"));//只有王可以封赏
            // }
        }
        private function ws_sr_get_guild_list(re:NetPackage):void
        {
            ViewManager.instance.showView(ConfigClass.VIEW_COUNTRY_STORE_LIST,[re.otherData,re.receiveData]);
        }
        private function listCity_render(item:item_country_store_cityUI,index:int):void
        {
            var data:Object = this.listCity.array[index];
            item.tName.text = Tools.getMsgById("cityType"+data.type);
            item.tNum.text = data.num;
        }

    }   
}