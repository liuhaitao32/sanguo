package sg.view.map
{
    import laya.events.Event;
    import laya.ui.Label;
    import laya.utils.Handler;
    import sg.cfg.ConfigServer;
    import sg.manager.ModelManager;
    import sg.map.model.MapModel;
    import sg.map.model.entitys.EntityCity;
    import sg.model.ModelCityBuild;
    import sg.model.ModelOfficial;
    import sg.model.ModelUser;
    import sg.net.NetMethodCfg;
    import sg.net.NetPackage;
    import sg.net.NetSocket;
    import sg.utils.Tools;
    import ui.map.item_mayor_listUI;
    import ui.map.view_appoint_mayorUI;
    import sg.manager.ViewManager;
    import sg.view.country.ViewCountryMayor;
    import sg.map.utils.ArrayUtils;

    public class ViewCountryMayorList extends view_appoint_mayorUI
    {
        private var mArrData:Object;
        private var mCityData:Object;
        private var mCid:String;
        private var mTabStr:Array;
        private var mPage:Number = 0;
        private var mData:Object;    
        //private var mayorsData:Object;  
        private var mMayorCD:Number;  
        private var mSortArr:Array=[];
        public function ViewCountryMayorList()
        {
            this.tab.dataSource = [Tools.getMsgById("add_building001"),Tools.getMsgById("_public89"),Tools.getMsgById("_public90"),Tools.getMsgById("_public91"),Tools.getMsgById("_public92")];
            this.tab.selectHandler = new Handler(this,this.tab_select);
            this.btnGo.on(Event.CLICK,this,this.click);
            //
            this.list.itemRender = item_mayor_listUI;
            this.list.renderHandler = new Handler(this,this.list_render);
            this.list.selectEnable = false;
            this.list.scrollBar.hide = true;
            this.list.selectHandler = new Handler(this,this.list_select);
            //
            // 设置列表标题
            (list_title.getChildByName('txt_rank') as Label).text = Tools.getMsgById('_public214');
            (list_title.getChildByName('txt_player') as Label).text = Tools.getMsgById('_more_rank07');
            (list_title.getChildByName('txt_city') as Label).text = Tools.getMsgById('_country13');//太守
            (list_title.getChildByName('txt_online') as Label).text = Tools.getMsgById('_country60');
            
            this.comTitle.setViewTitle(Tools.getMsgById('_country62'));
            this.btnGo.label = Tools.getMsgById("_lht27");
        }


        private function setTimerLabel():void{
            var n:Number=this.mMayorCD-ConfigServer.getServerTimer();
            if(n>0){
                //this.btnGo.gray=true;
                this.btnGo.visible=false;
                this.timerLabel.text=Tools.getMsgById("_country63",[Tools.getTimeStyle(n)]);
                this.timerLabel.centerX=this.timerLabel.centerY=0;
            }else{
                //this.btnGo.gray=false;
                this.btnGo.visible=true;
                this.timerLabel.text="";
            }
            timer.once(1000,this,setTimerLabel);
        }

        override public function onAdded():void{
             this.mArrData = this.currArg[0];
            this.mCityData = this.currArg[1];
            this.mCid = this.mCityData.cid;
            this.mMayorCD =  ModelOfficial.getMayorCD(this.mCid);
            
            this.mTabStr = this.tab.labels.split(",");
            //
            this.tName.text = ModelOfficial.getCityName(this.mCid);
            this.tType.text = ModelOfficial.getCityType(this.mCid);
            this.tNum.text = Tools.getMsgById("_public86",[ModelCityBuild.getBuildRatio(this.mCid)])//建设值:
            var mayor:Array = ModelOfficial.getCityMayor(this.mCid);
            this.tMayor.text = Tools.getMsgById("_public74",[(mayor?mayor[1]:Tools.getMsgById("_public76"))]);//"太守:"+;
            //this.btnGo.disabled = true;
            //
            this.mData = {};
            this.mPage = 0;
            this.tab.selectedIndex = 0;
            this.list.dataSource = [];  

            ModelManager.instance.modelOfficel.on(ModelOfficial.EVENT_SET_MAYOR_IS_OK,this,this.event_set_mayor_is_ok);

            // 缓存城市太守信息
            /*
            var arr:Array = ModelOfficial.getMyCities(ModelUser.getCountryID(), ConfigServer.world['cityTypeCanBuild']);
            mayorsData = {};
            for(var i:int = 0, len:int = arr.length; i < len; i++)
            {
                var data:Object = arr[i];
                //var mayor:Array = ModelOfficial.getCityMayor(data.cid);
                if (mayor) {
                    mayorsData[mayor[0]] = MapModel.instance.citys[data.cid];
                }
            }*/
            setTimerLabel();   
        }
        override public function onRemoved():void{
            ModelManager.instance.modelOfficel.off(ModelOfficial.EVENT_SET_MAYOR_IS_OK,this,this.event_set_mayor_is_ok);
            timer.clear(this,setTimerLabel);
            this.list.selectedIndex = -1;
            this.tab.selectedIndex = -1;
        }        
        private function event_set_mayor_is_ok():void
        {
            this.closeSelf();
        }
        private function tab_select(index:int):void
        {
            if(index>-1){                
                (list_title.getChildByName('txt_tab') as Label).text = this.tab.dataSource[index];
                this.list.selectedIndex = -1;
                this.mPage = 0;
                this.checkPage();
            }
        }
        private function checkPage():void
        {
            var b:Boolean = false;
            if(this.mData.hasOwnProperty(this.tab.selectedIndex)){
                if(this.mPage<this.mData[this.tab.selectedIndex].page){
                    b = true;
                }
            }   
            if(b){
                this.setListData(this.mData[this.tab.selectedIndex]);
            }
            else{
                NetSocket.instance.send(NetMethodCfg.WS_SR_GET_MAYOR_LIST,{type:this.tab.selectedIndex,page:this.mPage},Handler.create(this,this.ws_sr_get_mayor_list));
            }            
        }    
        private function ws_sr_get_mayor_list(re:NetPackage):void
        {
            if(this.mData.hasOwnProperty(re.sendData.type)){
                if(re.receiveData.data && re.receiveData.data.length>0){
                    this.mData[re.sendData.type].page+=1;
                    this.mData[re.sendData.type].self = re.receiveData.self;
                    this.mData[re.sendData.type].rank = re.receiveData.rank;
                    this.mData[re.sendData.type].data = this.mData[re.sendData.type].data.concat(re.receiveData.data);
                } //re.receiveData.rank;
            }
            else{
                this.mData[re.sendData.type] = re.receiveData;
                this.mData[re.sendData.type]["page"] = 1;
            }
            
            this.setListData(this.mData[re.sendData.type]);
        }     
        private function setListData(obj:Object):void
        {
            var n:Number=ConfigServer.getServerTimer();
            var mayor:Array = ModelOfficial.getCityMayor(this.mCityData.cid);
            var arr:Array=[];
            for(var i:int=0;i<obj.data.length;i++){
                if(!mayor || mayor[0]!=obj.data[i][0]){
                    obj.data[i]["sortKey"]=this.tab.selectedIndex==0 ? obj.data[i][3] : 0;
                    obj.data[i]["sortTime"]=obj.data[i][2]==true ? n+1000 : Tools.getTimeStamp(obj.data[i][2]);
                    arr.push(obj.data[i]);
                }
            }
            if(this.tab.selectedIndex==0){
                arr=ArrayUtils.sortOn(["sortKey","sortTime"],arr,true);
            }
            
            this.list.dataSource = arr;//(obj.data as Array).filter(function(item:*):Boolean{return !(mayor && mayor[0] === item[0])});
            this.btnGo.disabled = obj.data.length<=0;
            this.list.selectedIndex = 0;
        }             
        private function list_render(item:item_mayor_listUI,index:int):void
        {
            var data:Array = this.list.array[index];
            var uid:int = data[0];
            var uname:String = data[1];
            //var team:String = data[2];
            var online:* = data[2];
            //
            item.cRank.setRankIndex(index+1);
            item.tName.text = uname;//+uid;
            Tools.textFitFontSize(item.tName);
            //item.tTeam.text = Tools.isNullString(team)?Tools.getMsgById("_public76"):team;
            item.tOnline.text=online===true?Tools.getMsgById("_guild_text29"):Tools.howTimeToNow(Tools.getTimeStamp(online));
            item.tOnline.color=online===true?"#10F010":"#828282";
			if (this.tab.selectedIndex == 1)
			{
				item.comPower.visible = true;
				item.comPower.setNum(data[3+this.tab.selectedIndex]);
			}
			else{
				item.comPower.visible = false;
				item.tNum.text = data[3+this.tab.selectedIndex];
			}
			item.tNum.visible = !item.comPower.visible;
            //item.tCity.visible = false;
            //if (mayorsData[uid]) {
            //    item.tCity.visible = true;
            //    item.tCity.text = (mayorsData[uid] as EntityCity).name + Tools.getMsgById('_country13');
            //}
            //
            item.mSelect.visible = (this.list.selectedIndex == index);  
            
            //ps 看代码好像是只显示本城的太守 但是数据看来本城太守被过滤出去了  所以永远显示不了啊
            //var mayor:Array = ModelOfficial.getCityMayor(this.mCid);  
            //item.icon.visible = mayor?(mayor[0]?mayor[0] == uid:false):false;

            var s:String=ModelOfficial.getMayorByUID(uid);
            if(s==""){
                item.tCity.text="";
                item.icon.visible=false;
            }else{
                item.tCity.text=ModelOfficial.getCityName(s)+Tools.getMsgById('_country13');
                item.icon.visible=true;
            }

            item.off(Event.CLICK,this,click_item);
            item.on(Event.CLICK,this,click_item,[index]);

        }
        private function click_item(index:int):void
        {
            if(index<0) return;

            if(index!=this.list.selectedIndex){
                this.list.selectedIndex = index;
            }else{
                ModelManager.instance.modelUser.selectUserInfo(this.list.array[index][0]);
            }
        }
        private function list_select(index:int):void
        {

        }
        private function click():void{
            var n:Number=this.mMayorCD-ConfigServer.getServerTimer();
            if(n>0){
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_country64",[Tools.getTimeStyle(n)]));
                return;
            }
            if(this.list.array[this.list.selectedIndex]==null) return;
            //if(this.list.selection){
                var data:Array = this.list.array[this.list.selectedIndex];
                
                if(!(data[2] is Boolean)){
                    var time:Number = Tools.getTimeStamp(data[2]);
                    if(ConfigServer.getServerTimer()-time > ConfigServer.country.mayor.vanish*Tools.oneHourMilli){
                        ViewManager.instance.showTipsTxt(Tools.getMsgById("_country85"));
                        return;
                    }
                }
                NetSocket.instance.send(NetMethodCfg.WS_SR_SET_MAYOR,{cid:this.mCid,uid:data[0]},new Handler(this,ws_sr_set_mayor));
            //}
        }

        private function ws_sr_set_mayor(np:NetPackage):void{
            //trace("================",np.receiveData);
            this.closeSelf();
        }
    }   
}