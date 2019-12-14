package sg.view.init
{
    import ui.init.server_listUI;
    import ui.init.item_server_listUI;
    import laya.utils.Handler;
    import sg.cfg.ConfigServer;
    import sg.utils.SaveLocal;
    import laya.maths.MathUtil;
    import laya.events.Event;
    import sg.manager.ModelManager;
    import sg.model.ModelGame;
    import sg.model.ModelPlayer;
    import sg.utils.Tools;
    import sg.manager.ViewManager;

    public class ViewServerList extends server_listUI
    {
        public var mZonesHis:Array = [];
        public function ViewServerList()
        {
            this.listMine.itemRender = item_server_listUI;
            this.listMine.renderHandler = new Handler(this,this.listMine_render);
            this.listMine.scrollBar.hide = true;
            //
            this.list.itemRender = item_server_listUI;
            this.list.renderHandler = new Handler(this,this.list_render);
            this.list.scrollBar.hide = true;
			//this.xuanze.text = Tools.getMsgById("ViewServerList_1");
            this.comTitle.setViewTitle(Tools.getMsgById("ViewServerList_1"));
			this.zuijin.text = Tools.getMsgById("ViewServerList_2");
			this.zhengchang.text = Tools.getMsgById("ViewServerList_3");
			this.yiyou.text = Tools.getMsgById("ViewServerList_4");
			this.buke.text = Tools.getMsgById("ViewServerList_5");
			this.fuwu.text = Tools.getMsgById("ViewServerList_6");
        }
        override public function initData():void{
            var myZonesStr:String = ModelPlayer.instance.getServerZones();
            var myZones:Array = this.mZonesHis = myZonesStr.split("|");//
            var myZonesObj:Object = ModelPlayer.instance.getZoneList();
            var zArr:Array = [];
            var key:String;
            var len:int = myZones.length;
            var zcfg:Array;
            for(var i:int = 0; i < len; i++)
            {
                key = myZones[i];
                if(ConfigServer.zone.hasOwnProperty(key) && ConfigServer.zone[key][5]==0){
                    zArr.push({id:key,num:i});//(myZonesObj && myZonesObj[key])?myZonesObj[key]:0
                }                
            }
            zArr.sort(MathUtil.sortByKey("num",true));
            //
            this.listMine.dataSource = zArr;
            //
			var zArrAll:Array = [];
            
            var showTimer:Number = ConfigServer.system_simple.sever_showtime*Tools.oneMinuteMilli;
            var startTimer:Number = 0;
            var now:Number = ConfigServer.getServerTimer();
			for(key in ConfigServer.zone)
			{
                if(!ConfigServer.checkZonePfIsOK(key)){
                    continue;
                }
                zcfg = ConfigServer.zone[key];
                if(zcfg[5]>0){
                    continue;
                }
                startTimer = Tools.getTimeStamp(zcfg[2]);
                if(now>=(startTimer-showTimer)){
                    if(zcfg[7]!=""){
                        startTimer = startTimer*-1;
                    }
				    zArrAll.push({id:key,arr:zcfg,tms:startTimer});	
                }
			}
			zArrAll.sort(MathUtil.sortByKey("tms",true));
            //
            this.list.dataSource = zArrAll;
        }
        private function list_render(item:item_server_listUI,index:int):void
        {
            var data:Object = this.list.array[index];
            item.txt.text = ConfigServer.zone[data.id][0]+ConfigServer.checkServerIsMadeTxt(data.id);

            var status:Number = this.checkIcon(data.id);
            var s2:Number = this.checkIcon2(data.id);
            var myZonesStr:String = ModelPlayer.instance.getServerZones();
            var myZones:Array = myZonesStr.split("|");//
            // trace(myZones);
            //
            item.s1.visible = myZones.indexOf(data.id+"")>-1;
            //
            item.s0.visible = (status==0 && !item.s1.visible);
            item.s2.visible = (status==2 && !item.s1.visible);
            //
            item.tag0.visible = (s2==1);
            item.tag1.visible = (s2==2);
            item.tag2.visible = (s2==3);
            item.tag3.visible = (s2==4);
            //
            item.off(Event.CLICK,this,this.click);          
            item.on(Event.CLICK,this,this.click,[data.id,item.s0.visible]);            
        }
        private function listMine_render(item:item_server_listUI,index:int):void
        {
            var data:Object = this.listMine.array[index];
            item.txt.text = ConfigServer.zone[data.id][0]+ConfigServer.checkServerIsMadeTxt(data.id);

            var s2:Number = this.checkIcon2(data.id);
            //
            item.s0.visible = false;
            item.s2.visible = false;
            item.s1.visible = true;    
            item.tag0.visible = (s2==1);
            item.tag1.visible = (s2==2);   
            item.tag2.visible = (s2==3);   
            item.tag3.visible = (s2==4);   
            //
            item.off(Event.CLICK,this,this.click);          
            item.on(Event.CLICK,this,this.click,[data.id,false]); 
        }     
        private function click(id:String,vis:Boolean):void
        {
            if(vis){
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_lht52"));
                return;
            }
            ModelManager.instance.modelGame.event(ModelGame.EVENT_SERVER_SELECT_CHANGE,id);
            this.closeSelf();
        }   
        private function checkIcon(zid:*):Number{
            var zcfg:Array = ConfigServer.zone[""+zid];
            var status:Number = 0;
            var isMyZone:Boolean = this.mZonesHis.indexOf(zid+"")>-1;
            if(isMyZone){
                status = 2;//我的区全开
            }
            else{
                if(zcfg[7]!=""){
                    status = 0;//非我合服区全关
                }
                else{
                    if(zcfg[3]==1){
                        status = 2;//非我非合服强开
                    }
                    else{
                        var now:Number = ConfigServer.getServerTimer();
                        var ends:Number = Tools.getTimeStamp(zcfg[2])+ConfigServer.getForbidNewTime();
                        if(now<ends){
                            status = 2;
                        }
                        else{
                            status = 0;
                        }
                    }
                }
            }
            return status;
        }
        private function checkIcon2(zid:*):Number{
            var zcfg:Array = ConfigServer.zone[""+zid];
            var status:Number = 0;
            var now:Number = ConfigServer.getServerTimer();
            var ends:Number = Tools.getTimeStamp(zcfg[2]);//+ConfigServer.system_simple.sever_new*Tools.oneMinuteMilli;
            if(zcfg && zcfg[7]!=""){
                return 4;
            }
            if(now<ends){
                status = 3;
            }
            else{
                if(zcfg[4]==0){
                    ends = Tools.getTimeStamp(zcfg[2])+ConfigServer.system_simple.sever_new*Tools.oneMinuteMilli;
                    if(now<ends){
                        status = 1;
                    }
                    else{
                        status = 2;
                    }
                } 
                else if(zcfg[4]==1){
                    status = 2;
                }          
                else{
                    status = 1;
                }
            }
            return status;
        }
    }
}