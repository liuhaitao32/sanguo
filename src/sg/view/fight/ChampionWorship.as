package sg.view.fight
{
    import ui.fight.championWorshipUI;
    import laya.utils.Handler;
    import laya.events.Event;
    import sg.manager.ModelManager;
    import sg.model.ModelHero;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import sg.net.NetPackage;
    import sg.manager.ViewManager;
    import sg.model.ModelClimb;
    import sg.manager.LoadeManager;
    import sg.utils.Tools;
    import sg.model.ModelUser;

    public class ChampionWorship extends championWorshipUI{
        private var mGroupData:Object;
        public function ChampionWorship(data:Object){
            this.mGroupData = data;
            //
            this.list.itemRender = ItemWorship;
            this.list.renderHandler = new Handler(this,this.list_render);
            this.list.scrollBar.hide = true;
            //
            this.btn.on(Event.CLICK,this,this.click);
            //
            this.on(Event.REMOVED,this,this.onRemove);
            //
            this.init();
        }
        private function init():void{
            //
            var arr:Array = this.mGroupData.log_list;
            var len:int = arr.length;
            var endArr:Array = [];
            if(arr[8][2]==0){
                endArr.push(arr[8][0]);
                endArr.push(arr[8][1]);
            }
            else{
                endArr.push(arr[8][1]);
                endArr.push(arr[8][0]);
            }
            if(arr[9][2]==0){
                endArr.push(arr[9][0]);
            }
            else{
                endArr.push(arr[9][1]);
            }
            //
            this.list.dataSource = endArr;
            //
            ModelManager.instance.modelClimb.send_WS_SR_GET_MY_PK_YARD_HIDS(null,this.btn);
        }
        private function list_render(item:ItemWorship,index:int):void{
            var data:Object = this.list.array[index];
            item.setUI(data,index);

            item.heroIcon.off(Event.CLICK,this,this.click_head);
            item.heroIcon.on(Event.CLICK,this,this.click_head,[data.uid]);

            item.btn.off(Event.CLICK,this,this.click_worship);
            item.btn.on(Event.CLICK,this,this.click_worship,[index]);
        }
        private function click_head(_uid:*):void{
            ModelManager.instance.modelUser.selectUserInfo(_uid);
        }

        private function click_worship(index:int):void{
            var data:Object = this.list.array[index];
            if(ModelClimb.isChampionWorship()){
                NetSocket.instance.send(NetMethodCfg.WS_SR_PK_YARD_WORSHIP,{},Handler.create(this,this.ws_sr_pk_yard_worship));
            }
            else{
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_climb11"));//"每天只能膜拜一次"
            }
        }
        private function ws_sr_pk_yard_worship(re:NetPackage):void{
            ModelManager.instance.modelUser.updateData(re.receiveData);
            //
            ViewManager.instance.showIcon(re.receiveData.gift_dict,Laya.stage.mouseX,Laya.stage.mouseY);
            //
            this.list.dataSource = this.list.array;
        }
        private function click():void{
            var arr:Array = ModelClimb.getChampionHeroRecommend(ModelClimb.getChampionHeroNum());
            //
            var len:int = arr.length;
            var hmd:ModelHero;
            var sArr:Array = [];
            for(var i:int = 0; i < len; i++)
            {
                hmd = arr[i];
                sArr.push(hmd.id);
            }
            ModelManager.instance.modelClimb.send_WS_SR_JOIN_PK_YARD(sArr,Handler.create(this,this.ws_sr_join_pk_yard));
        }
        private function ws_sr_join_pk_yard(re:NetPackage):void{
            ModelManager.instance.modelClimb.event(ModelClimb.EVENT_CHAMPION_SIGN_OK);
            ViewManager.instance.showTipsTxt(Tools.getMsgById("_climb12"));//报名成功了
            this.btn.disabled = true;
            this.btn.label = Tools.getMsgById("_climb13");//已报名
        }
        override public function clear():void{
            this.list.destroy();
            this.btn.destroy();
            //
            this.destroy(true);
        }
    }   
}