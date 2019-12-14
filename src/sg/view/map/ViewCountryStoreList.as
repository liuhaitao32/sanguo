package sg.view.map
{
    import laya.events.Event;
    import laya.ui.Label;
    import laya.utils.Handler;

    import sg.cfg.ConfigServer;
    import sg.manager.ModelManager;
    import sg.manager.ViewManager;
    import sg.model.ModelOfficial;
    import sg.net.NetMethodCfg;
    import sg.net.NetPackage;
    import sg.net.NetSocket;
    import sg.utils.Tools;

    import ui.map.country_store_listUI;
    import ui.map.item_store_listUI;

    public class ViewCountryStoreList extends country_store_listUI
    {
        private var mGuildArr:Array;
        private var mType:String;
        private var mTabArr:Array;
        public function ViewCountryStoreList()
        {
            this.tab.dataSource = [Tools.getMsgById("_public89"),Tools.getMsgById("_public90"),Tools.getMsgById("_public91"),Tools.getMsgById("_public92")];
            this.tab.selectHandler = new Handler(this,this.tab_select);
            this.btn.on(Event.CLICK,this,this.click);
            this.mTabArr = this.tab.labels.split(",");

            this.list.itemRender = item_store_listUI;
            this.list.renderHandler = new Handler(this,this.list_render);
            this.list.scrollBar.hide = true;
            this.list.selectEnable = true;
            this.list.selectHandler = new Handler(this,this.list_select);
            //
            // 设置列表标题
            (list_title.getChildByName('txt_rank') as Label).text = Tools.getMsgById('_public214');
            (list_title.getChildByName('txt_guild') as Label).text = Tools.getMsgById('lvup05_2_name');
            (list_title.getChildByName('txt_member') as Label).text = Tools.getMsgById('_guild_text109');
            txt_title.text = Tools.getMsgById('_jia0095');
            this.iNum.text = Tools.getMsgById("_lht26");
        }
        override public function initData():void{
            this.mType = this.currArg[0];
            this.mGuildArr = this.currArg[1];
            //
            this.tab.selectedIndex = 0;
            //
            this.setUI();
        }
        private function tab_select(index:int):void
        {
            if(index>-1){
                this.list.dataSource = this.mGuildArr;
                if(this.mGuildArr.length>0){
                    this.list.selectedIndex = 0;
                }
                (list_title.getChildByName('txt_tab') as Label).text = this.mTabArr[index];
            }
        }
        override public function onRemoved():void{
        }
        private function list_render(item:item_store_listUI,index:int):void
        {
            var data:Object = this.list.array[index];
            item.cRank.setRankIndex(index+1);
            item.tName.text = data.guild_name;
            item.tTeam.text = data.user_len+"";
            var num:Number = 0;
			item.comPower.visible = false;
            switch(this.tab.selectedIndex)
            {
                case 0:
					num = data.power;
					item.comPower.visible = true;
					item.comPower.setNum(num);
                    break;
                case 1:
                    num = data.kill_num;
                    break; 
                case 2:
                    num = data.build_num;
                    break; 
                case 3:
                    num = data.die_num;
                    break;                                                   
                default:
                    break;
            }
			item.tNum.visible = !item.comPower.visible;

            item.tNum.text = num+"";
            item.mSelect.visible = (this.list.selectedIndex == index);
            //item.icon.visible = (this.tab.selectedIndex == 0);
            item.off(Event.CLICK,this,this.click_item);
            item.on(Event.CLICK,this,this.click_item,[index]);
        }
        private function click_item(index:int):void
        {
            if(index!=this.list.selectedIndex){
                if(this.list.selection){
                    (this.list.selection as item_store_listUI).mSelect.visible = false;
                }
                this.list.selectedIndex = index;
            }
        }
        private function list_select(index:int):void
        {
            if(index>-1){
                if(this.list.selection){
                    (this.list.selection as item_store_listUI).mSelect.visible = true;
                }                
            }
        }
        private function setUI():void
        {
            var type:String = this.mType;
            var max:int = ConfigServer.country.warehouse.grant_second;
            var arr:Array = ModelOfficial.getStoreTimes(type);
            var used:int = arr[1];
            var storeMax:Number = ModelOfficial.getMyCountryCfg()[type];
            var everyNum:Number = ModelOfficial.getStoreNum(type)[1];
            var b:Boolean = (used<max && storeMax >= everyNum && ModelOfficial.isKing(ModelManager.instance.modelUser.mUID)>-1);
            this.btn.gray = !b;
            //
            this.tNum.text = everyNum+""
            this.tTimes.text =  (max-used)+"/"+max;
        }
        private function click():void{
            if(this.btn.gray){
                // ViewManager.instance.showTipsTxt(Tools.getMsgById("_country3"));//"只有王可以封赏"
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_country3_2"));//"国库储备不足"
                return;
            }
            if(this.list.selection){
                var data:Object = this.list.array[this.list.selectedIndex];
                // if(ModelOfficial.isKing(ModelManager.instance.modelUser.mUID)>-1){
                    NetSocket.instance.send(NetMethodCfg.WS_SR_GIVE_TEAM_AWARD,{gid:data.guild_id,type:this.mType},Handler.create(this,this.ws_sr_give_team_award));
                // 
            }
            else{
                
            }
        }
        private function ws_sr_give_team_award(re:NetPackage):void
        {
            ModelOfficial.updateCountryData(re.receiveData);
            ModelManager.instance.modelOfficel.event(ModelOfficial.EVENT_UPDATE_COUNTRY_DATA);
            //
            this.setUI();
            ViewManager.instance.showTipsTxt(Tools.getMsgById("_country25"));//封赏成功
        }
    }   
}