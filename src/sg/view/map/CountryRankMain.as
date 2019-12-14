package sg.view.map
{
    import ui.map.country_rank_mainUI;
    import ui.map.item_country_rankUI;
    import laya.utils.Handler;
    import laya.events.Event;
    import laya.maths.MathUtil;
    import sg.utils.Tools;
    import sg.manager.ModelManager;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import sg.net.NetPackage;

    public class CountryRankMain extends country_rank_mainUI
    {
        private var mPage:Number = 0;
        private var mData:Object;
        public function CountryRankMain(data:Array)
        {
            // this.mData = data;
            //
            this.on(Event.REMOVED,this,this.onRemove);
            //
            this.tab.dataSource = [Tools.getMsgById("add_building001"),Tools.getMsgById("_public89"),Tools.getMsgById("_public90"),Tools.getMsgById("_public91"),Tools.getMsgById("_public92")];
            this.tab.selectHandler = new Handler(this,this.tab_select);
            //
            this.list.itemRender = item_country_rankUI;
            this.list.renderHandler = new Handler(this,this.list_render);
            this.list.scrollBar.hide = true;
            //
            this.mData = {};
            this.mPage = 0;
            this.tab.selectedIndex = 0;
            this.list.dataSource = [];
        }
        
        private function onRemove():void{
            this.tab.selectedIndex = -1;
            this.tab.destroy(true);
            this.list.destroy(true);
            this.destroyChildren();
            this.destroy(true);
        }
        private function tab_select(index:int):void
        {
            if(index>-1){
                // var abc:Array = this.mData.concat();
                // abc.sort(MathUtil.sortByKey((3+index)+"",true));
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
                NetSocket.instance.send(NetMethodCfg.WS_SR_GET_USERS,{type:this.tab.selectedIndex,page:this.mPage},Handler.create(this,this.ws_sr_get_users));
            }            
        }
        private function ws_sr_get_users(re:NetPackage):void
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
            this.setItemData(this.mSelf,obj.self,obj.rank-1);
            this.list.dataSource = obj.data;
        }
        private function list_render(item:item_country_rankUI,index:int):void
        {
            var data:Array = this.list.array[index];
            this.setItemData(item,data,index);
        }
        private function setItemData(item:item_country_rankUI,data:Array,index:int):void
        {
            var uid:int = data[0];
            var uname:String = data[1];
            //var team:String = data[2];
            var online:* = data[2];
            //
            item.tName.text = uname;//+uid;
            item.cRank.setRankIndex(index+1);
            //item.tTeam.text = Tools.isNullString(team)?Tools.getMsgById("_public79"):team;//无军团
            item.tTeam.text=online===true?Tools.getMsgById("_guild_text29"):Tools.howTimeToNow(Tools.getTimeStamp(online));
            item.tTeam.color=online===true?"#10F010":"#828282";
			if (this.tab.selectedIndex == 1){
				item.comPower.visible = true;
				item.comPower.setNum(data[3 + this.tab.selectedIndex]); 
			}
			else{
				item.comPower.visible = false;
				item.tNum.text = data[3 + this.tab.selectedIndex]; 
			}
			item.tNum.visible = !item.comPower.visible;
            //item.power.visible = this.tab.selectedIndex == 1;         
        }
    }
}