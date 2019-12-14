package sg.view.map
{
    import laya.events.Event;
    import laya.ui.Button;
    import laya.ui.Label;
    import laya.utils.Handler;

    import sg.manager.ModelManager;
    import sg.model.ModelOfficial;
    import sg.net.NetMethodCfg;
    import sg.net.NetPackage;
    import sg.net.NetSocket;
    import sg.utils.Tools;

    import ui.map.item_officer_listUI;
    import ui.map.view_appoint_officerUI;
    import sg.model.ModelUser;
    import sg.cfg.ConfigServer;
    import sg.map.utils.ArrayUtils;

    public class ViewCountryOfficerList extends view_appoint_officerUI
    {
        private var mArrData:Array;
        private var mId:int;
        private var mPage:Number = 0;
        private var mData:Object;
        public function ViewCountryOfficerList()
        {
            this.tab.renderHandler = new Handler(this,this.tab_render);
            this.tab.selectEnable = true;
            this.tab.selectHandler = new Handler(this,this.tab_select);
            this.btn.on(Event.CLICK,this,this.click);
            //
            this.list.itemRender = item_officer_listUI;
            this.list.renderHandler = new Handler(this,this.list_render);
            this.list.selectEnable = true;
            this.list.scrollBar.hide = true;
            this.list.selectHandler = new Handler(this,this.list_select);
            
            // 设置列表标题
            (list_title.getChildByName('txt_rank') as Label).text = Tools.getMsgById('_public214');
            (list_title.getChildByName('txt_player') as Label).text = Tools.getMsgById('_more_rank07');
            (list_title.getChildByName('txt_city') as Label).text = Tools.getMsgById('_country10');//官职
            (list_title.getChildByName('txt_online') as Label).text = Tools.getMsgById('_country60');
            this.comTitle.setViewTitle(Tools.getMsgById('_country21'));
            this.btn.label = Tools.getMsgById("_lht27");
        }
        override public function initData():void{
            this.mId = this.currArg[1];
            this.tab.dataSource = [Tools.getMsgById("add_building001"),Tools.getMsgById("_public89"),Tools.getMsgById("_public90"),Tools.getMsgById("_public91"),Tools.getMsgById("_public92")];
            //
            this.mData = {};
            this.mPage = 0;
            this.tab.selectedIndex = 0;
            this.list.dataSource = [];            
        }
        override public function onAdded():void{
            ModelManager.instance.modelOfficel.on(ModelOfficial.EVENT_SET_OFFICER_IS_OK,this,this.event_set_officer_is_ok);
        }
        override public function onRemoved():void{
            ModelManager.instance.modelOfficel.off(ModelOfficial.EVENT_SET_OFFICER_IS_OK,this,this.event_set_officer_is_ok);
            this.list.selectedIndex = -1;
            this.tab.selectedIndex = -1;
        }
        private function tab_render(item:Button,index:int):void{
            item.label = this.tab.array[index];
            item.selected = this.tab.selectedIndex == index;
        }
        private function tab_select(index:int):void
        {
            if(index>-1){
                this.list.selectedIndex = -1;
                (list_title.getChildByName('txt_tab') as Label).text = this.tab.array[index];
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
                NetSocket.instance.send(NetMethodCfg.WS_SR_GET_CITIZEN,{official:this.mId,type:this.tab.selectedIndex,page:this.mPage},Handler.create(this,this.ws_sr_get_citizen));
            }            
        }        
        private function ws_sr_get_citizen(re:NetPackage):void
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
            this.mArrData = obj.data.concat();
            var n:Number=ConfigServer.getServerTimer();
            var arr:Array = [];
            var len:int = this.mArrData.length;
            for(var i:int = 0;i < len;i++){
                if(this.mArrData[i][0] != ModelManager.instance.modelUser.mUID){
                    this.mArrData[i]["sortKey"]=this.tab.selectedIndex==0 ? this.mArrData[i][3] : 0;
                    this.mArrData[i]["sortTime"]=this.mArrData[i][2]==true ? n+1000 : Tools.getTimeStamp(this.mArrData[i][2]);
                    arr.push(this.mArrData[i]);
                }
            }            
            if(this.tab.selectedIndex==0){
                arr=ArrayUtils.sortOn(["sortKey","sortTime"],arr,true);
            }
            this.list.dataSource = arr;
            this.list.selectedIndex = 0;
        }           
        private function list_render(item:item_officer_listUI,index:int):void
        {
            //[175, "安定史大鹏", null, 1, 0, 0, 0, 0]
            var data:Array = this.list.array[index];
            var uid:int = data[0];
            var uname:String = data[1];
            //var team:String = data[2];
            var online:* = data[2];

            item.tOnline.text=online===true?Tools.getMsgById("_guild_text29"):Tools.howTimeToNow(Tools.getTimeStamp(online));
            item.tOnline.color=online===true?"#10F010":"#828282";
            //
            item.tName.text = uname;//+uid;
            //item.tTeam.text = Tools.isNullString(team)?Tools.getMsgById("_public79"):team;//无军团
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
            //item.tNum.text = data[3+this.tab.selectedIndex];
            item.cRank.setRankIndex(index+1);
            //item.power.visible = this.tab.selectedIndex == 1;
            //
            item.mSelect.visible = (this.list.selectedIndex == index);

            var n:Number=ModelOfficial.getUserOfficer(uid+"");
			if(n>=0){
				item.comOfficer.visible = true;
				item.comOfficer.setOfficialIcon(n,ModelOfficial.getInvade(ModelUser.getCountryID()), ModelUser.getCountryID());
			}else{
				item.comOfficer.visible = false;
			}
            //
            item.off(Event.CLICK,this,this.click_item);
            item.on(Event.CLICK,this,this.click_item,[index]);
        }
        private function click_item(index:int):void
        {
            if(index!=this.list.selectedIndex){
                if(this.list.selection){
                    (this.list.selection as item_officer_listUI).mSelect.visible = false;
                }
                this.list.selectedIndex = index;
            }
        }
        private function list_select(index:int):void
        {
            if(index>-1){
                if(this.list.selection){
                    (this.list.selection as item_officer_listUI).mSelect.visible = true;
                }                
            }
        }
        private function click():void{
            if(this.list.selection){
                var data:Array = this.list.array[this.list.selectedIndex];
                NetSocket.instance.send(NetMethodCfg.WS_SR_SET_OFFICIAL,{official:this.mId,uid:data[0],leader:ModelManager.instance.modelUser.mUID});
            }
        }
        private function event_set_officer_is_ok():void
        {
            this.closeSelf();
        }

    }   
}