package sg.view.fight
{
    import ui.fight.menuMainUI;
    import laya.events.Event;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import laya.utils.Handler;
    import sg.net.NetPackage;
    import sg.manager.ModelManager;
    import sg.model.ModelGame;
    import laya.ui.Button;
    import sg.boundFor.GotoManager;
    import sg.manager.LoadeManager;
    import sg.manager.AssetsManager;
    import sg.utils.Tools;
    import sg.model.ModelAlert;
    import sg.cfg.ConfigServer;
    import sg.model.ModelClimb;
    import laya.ui.Image;
    import sg.model.ModelUser;
    import sg.explore.model.ModelTreasureHunting;
    import sg.explore.model.ModelExplore;
    import sg.altar.legend.model.ModelLegend;
    import sg.festival.model.ModelFestival;
    import ui.bag.bagItemUI;

    public class ViewMenu extends menuMainUI{
        public function ViewMenu(){
            this.btn_climb1.on(Event.CLICK,this,this.click,[GotoManager.VIEW_CLIMB, this.btn_climb]);
            this.btn_pk.on(Event.CLICK,this,this.click,[GotoManager.VIEW_PK, this.btn_pk]);
            this.btn_pve1.on(Event.CLICK,this,this.click,[GotoManager.VIEW_PVE, this.btn_pve]);
            this.btn_champion.on(Event.CLICK,this,this.click,[GotoManager.VIEW_PK_YARD, this.btn_champion]);
            //
            this.tab.selectHandler = new Handler(this,this.tab_select);
        }
        override public function initData():void{
            this.text0.text=this.text2.text=this.text3.text = txt_legend_times_hint.text = Tools.getMsgById("_pve_text01");
            //演武场 pve
			LoadeManager.loadTemp(this.adImg0,AssetsManager.getAssetsAD("climb_map.jpg"));
			LoadeManager.loadTemp(this.adImg1,AssetsManager.getAssetsAD("pk_map.jpg"));
			LoadeManager.loadTemp(this.adImg2,AssetsManager.getAssetsAD("pve_map.jpg"));
			LoadeManager.loadTemp(this.adImg3,AssetsManager.getAssetsAD("pk_yard.jpg"));
			LoadeManager.loadTemp(this.adImg4,AssetsManager.getAssetsAD("explore_map.jpg"));
			LoadeManager.loadTemp(this.adImg5,AssetsManager.getAssetsAD("legend_map.jpg"));
            this.title_climb.text = Tools.getMsgById("add_climb");
            this.title_pve.text   = Tools.getMsgById("add_pve");
            this.title_pk.text    = Tools.getMsgById("add_both");
            this.title_cham.text  = Tools.getMsgById("add_pk_yard");
            txt_title_explore.text = Tools.getMsgById('_explore010');
            txt_title_legend.text = Tools.getMsgById('add_legend');

            var model:ModelTreasureHunting = ModelTreasureHunting.instance;
            var modelUser:ModelUser = ModelManager.instance.modelUser;
            txt_hunt_hint.text = model.openWords;
            txt_hunt_times_hint.text = Tools.getMsgById('_explore058');
            this.txt_hunt_times.text = (model.cfg.grab_num - model.grab_num) + '/' + model.cfg.grab_num;

            this.txt_legend_times.text = ModelLegend.instance.remainTimesTxt;

            // 演武场, 武馆, 探险;
            var arr:Array = [Tools.getMsgById("60006"), Tools.getMsgById("60007")];
            ModelExplore.instance.active && arr.push(Tools.getMsgById("_explore009"));
            tab.labels = arr.join();
            this.setTitle(Tools.getMsgById("_climb50"));
            this.pk_times.text = ModelManager.instance.modelClimb.getPKmyTimes()+"/"+ModelManager.instance.modelClimb.getPKtimesMax(); 
            //
            this.climb_times.text = ModelManager.instance.modelClimb.getMyClimbTimes()+"/"+(ModelManager.instance.modelClimb.getFightTimesByDay()+ModelManager.instance.modelClimb.getBuyTimesGet());
            //
            //this.pve_times.text = ModelManager.instance.modelUser.pve_records.combat_times+"";
            this.pve_times.text = modelUser.pveTimes().join("/");
            this.tab.selectedIndex = this.tab.selectedIndex>-1?this.tab.selectedIndex:0;
            //
            ModelGame.unlock(this.btn_climb,"pve_climb");
            ModelGame.unlock(this.btn_pve,"pve_pve");
            ModelGame.unlock(this.btn_pk,"pvp_pk");
            ModelGame.unlock(this.btn_champion,"pvp_champion");
            ModelGame.unlock(btn_treasureHunting,"mining");
            ModelGame.unlock(btn_legend,"legend");

            // 蓬莱寻宝
            this.setTreasureHuntingEntrance();
            // 见证传奇
            this.setLegendEntrance();
            //
			this.checkRed();
            //
            this.checkTime();

            var fest0:Array=ModelFestival.getRewardInterfaceByKey("climb");
            var c0:bagItemUI=this.btn_climb.getChildByName("fest") as bagItemUI;
            c0.visible=fest0.length!=0;
            if(fest0.length!=0){
                c0.setData(fest0[0],-1,-1);
            }

            var fest1:Array=ModelFestival.getRewardInterfaceByKey("pve");
            var c1:bagItemUI=this.btn_pve.getChildByName("fest") as bagItemUI;
            c1.visible=fest1.length!=0;
            if(fest1.length!=0){
                c1.setData(fest1[0],-1,-1);
            }

            c0.mouseThrough=c1.mouseThrough=false;

            Tools.textLayout(text2,                climb_times,     img_climb, box_climb_times);
            Tools.textLayout(text3,                pve_times,       img_pvp,   box_pve_times);
            Tools.textLayout(text0,                pk_times,        img_pk,    box_pk_times);
            Tools.textLayout(txt_hunt_times_hint,  txt_hunt_times,  img_hunt,  box_hunt_times);
            Tools.textLayout(txt_legend_times_hint,txt_legend_times,img_legend,box_legend_times);
            box_climb_times.right = box_pve_times.right = box_pk_times.right = box_hunt_times.right = box_legend_times.right = 20;

            Tools.textLayout2(title_climb,       title_climb_img,340,150,600);
            Tools.textLayout2(title_pve,         title_pve_img,340,150,600);
            Tools.textLayout2(title_pk,          title_pk_img,340,150,600);
            Tools.textLayout2(title_cham,        title_champion_img,340,150,600);
            Tools.textLayout2(txt_title_explore, title_explore_img,340,150,600);
            Tools.textLayout2(txt_title_legend,  title_lengend_img,340,150,600);
        } 
        override public function onRemoved():void{
            this.timer.clear(this,this.checkTime);
        }

        /**
         * 设置蓬莱寻宝入口
         */
        private function setTreasureHuntingEntrance():void {
            var model:ModelTreasureHunting = ModelTreasureHunting.instance;
            var modelUser:ModelUser = ModelManager.instance.modelUser;
            var active:Boolean = ModelTreasureHunting.instance.active;
            box_hunt_hint.visible = !model.openDaysEnough;
            box_hunt_times.visible = active;
            btn_treasureHunting.gray = !active;
            btn_treasureHunting.offAll(Event.CLICK);
            if (box_hunt_hint.visible) {
                btn_treasureHunting.on(Event.CLICK, this, function():void {
                    ViewManager.instance.showTipsTxt(model.openWords);
                } );
            }
            else {
                btn_treasureHunting.on(Event.CLICK,this,this.click,[GotoManager.VIEW_TREASURE_HUNTING, btn_treasureHunting]);
            }
        }

        /**
         * 设置见证传奇入口
         */
        private function setLegendEntrance():void {
            var model:ModelLegend = ModelLegend.instance;
            btn_legend.gray = false;
            btn_legend.visible = model.active;
            btn_legend.offAll(Event.CLICK);
            if (!model.active) {
                if (model.forshow) {
                    btn_legend.visible = btn_legend.gray = true;
                    var unlockObj:Object = ModelGame.unlock('',"legend");
                    unlockObj.gray && btn_legend.on(Event.CLICK, this, function():void {
                        ViewManager.instance.showTipsTxt(unlockObj.text);
                    } );
                    unlockObj.gray || btn_legend.on(Event.CLICK, this, function():void {
                        ViewManager.instance.showTipsTxt(model.openWords);
                    } );
                }
            }
            else {
                btn_legend.on(Event.CLICK,this,this.click,[GotoManager.VIEW_LEGEND, btn_legend]);
            }
            box_legend_times.visible = !btn_legend.gray;
        }

        private function checkTime():void
        {
            var nextDate:Date;
            var nextms:Number;
            var now:Number = ConfigServer.getServerTimer();
            var str1:String;
            var str2:String;
            if(ModelClimb.isChampionStartSeason()){//是开赛赛季
                var startms:Number = ModelClimb.getChampionStartTimer();
                var des:Number = ModelClimb.getChampionIngTime();
                var endms:Number =(startms+ModelClimb.getChampionUseTimer()-now);
                nextDate = ModelClimb.getChampionStarTime(true,ConfigServer.pk_yard.begin_time[0]);
                nextms = ModelClimb.getChampionStartTimer(nextDate.getTime());
                str1 = (des<0)?Tools.getMsgById("_climb35"):((endms>0)?Tools.getMsgById("_climb36"):Tools.getMsgById("_climb37"));//"本届开启倒计时":((endms>0)?"距离结束":"距离下届");
                str2 = (des<0)?Tools.getTimeStyle(Math.abs(des),4):((endms>0)?Tools.getTimeStyle(endms):Tools.getTimeStyle(nextms-now,4));   
                //
            }
            else{
                nextDate = ModelClimb.getChampionStarTime(false,ConfigServer.pk_yard.begin_time[0]);
                nextms = ModelClimb.getChampionStartTimer(nextDate.getTime());
                str1 = Tools.getMsgById("_climb37");
                str2 = Tools.getTimeStyle(nextms-now);
            }
            this.champion_times.text = str1+str2;
            //
            // (this.champion_times.parent as Image).width = this.champion_times.displayWidth;
            //
            this.timer.once(1000,this,this.checkTime);
        }        
		
		public function checkRed():void {
			var red1:Boolean = ModelAlert.red_pve_pvp_check(0);
			var red2:Boolean = ModelAlert.red_pve_pvp_check(1);
			var red3:Boolean = ModelAlert.red_pve_pvp_check(2);
			var red4:Boolean = ModelAlert.red_pve_pvp_check(3);
			var red5:Boolean = ModelAlert.red_pve_pvp_check(4);
            ModelGame.redCheckOnce(this.btn_climb,red1);
            ModelGame.redCheckOnce(this.btn_pve,red2);
            ModelGame.redCheckOnce(this.btn_pk,red3);
            ModelGame.redCheckOnce(this.btn_champion, red4);
            ModelGame.redCheckOnce(this.btn_treasureHunting, ModelTreasureHunting.instance.redPoint);
            ModelGame.redCheckOnce(this.btn_legend, ModelLegend.instance.redPoint);
			
			ModelGame.redCheckOnce(this.tab.getChildByName("item0"), red1 || red2);
			ModelGame.redCheckOnce(this.tab.getChildByName("item1"), red3 || red4);
			ModelGame.redCheckOnce(this.tab.getChildByName("item2"), red5);
			
		}
		
        private function tab_select(index:int):void{
            this.mStack.selectedIndex = index;
        }

        private function click(id:*,btn:Button):void{
            btn.gray || GotoManager.boundForPanel(id, "" , null, {child:true});
        }
    }   
}