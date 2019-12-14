package sg.view.fight
{
    import ui.fight.championMatchBUI;
    import sg.manager.ModelManager;
    import sg.view.com.ComPayType;
    import sg.utils.Tools;
    import ui.fight.itemChampion8UI;
    import sg.model.ModelClimb;
    import laya.display.Sprite;
    import laya.ui.Button;
    import laya.events.Event;
    import sg.manager.ViewManager;
    import sg.fight.FightMain;
    import laya.ui.Component;
    import laya.display.Animation;
    import sg.manager.EffectManager;
    import sg.cfg.ConfigServer;
    import laya.utils.Handler;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import sg.net.NetPackage;

    public class ChampionMatchB extends championMatchBUI{
        private var mGroupData:Object;
        private var mBetData:Object;
        public static const group012arr:Array = [
            ["00","03"],["01","02"],["04","07"],["05","06"],["11","12"],[],["13","14"],[],["21","22"],[],[],[]
        ];
        public static const groupAll:Array = ["00","03","01","02","04","07","05","06","11","12","13","14","21","22","31"];
        public function ChampionMatchB(data:Object){
            //
            this.mGroupData = data;
            //
            this.panel.vScrollBar.hide = true;
            //
            this.init();
            this.text0.text=Tools.getMsgById("_champion02");
        }
        override public function clear():void{
            //
            this.destroy(true);
        }
        private function init():void{
            //
            this.setUI();
            //
            NetSocket.instance.send(NetMethodCfg.WS_SR_GET_PK_YARD_GAMBLE,{},Handler.create(this,this.ws_sr_get_pk_yard_gamble));
        }
        private function ws_sr_get_pk_yard_gamble(re:NetPackage):void{
            var betUID:String = "";
            this.mBetData = re.receiveData;
            for(var key:String in this.mBetData)
            {
                for(var key2:String in this.mBetData[key]){
                    if(key2==ModelManager.instance.modelUser.mUID){
                        // this.mMe = key;
                        betUID = key;
                        break;
                    }
                    // this.mAllBet = this.mAllBet + Number(this.mBetData[key][key2]);
                }
            } 
            // betUID="8083"
            if(betUID!=""){
                var len:int = groupAll.length;
                var item:itemChampion8UI;
                for(var i:int = 0; i < len; i++){
                    item = (this["p"+groupAll[i]] as itemChampion8UI);
                    if(item.hasOwnProperty("heroId")){
                        if(item["heroId"] == betUID){
                            item.betImg.visible = true;
                        }
                    }
                }
            }
        }
        private function setUI():void{
            this.setUInormal();
            //
            if(this.mGroupData.if_log>0){
                this.setUIlog();
            }
            else{
                this.setUIReady();
            }
        }
        private function setUInormal():void
        {
            var len:int = groupAll.length;
            for(var i:int = 0; i < len; i++){
                (this["p"+groupAll[i]] as itemChampion8UI).boxTag.visible = true;
                (this["p"+groupAll[i]] as itemChampion8UI).mCountry.visible = false;
                (this["p"+groupAll[i]] as itemChampion8UI).heroIcon.visible = false;
                (this["p"+groupAll[i]] as itemChampion8UI).tInfo.text = this.getIndexStr(groupAll[i]);
                (this["p"+groupAll[i]] as itemChampion8UI).betImg.visible = false;
                // (this["l"+groupAll[i]] as Sprite).visible = false;
                if(this["l"+groupAll[i]]){
                    (this["l"+groupAll[i]] as Component).alpha = 0.3;
                }
            }
        }
        private function getIndexStr(str:String):String
        {
            var re:String = "";
            switch(str.charAt(0))
            {
                case "0":
                    re = Tools.getMsgById("_climb6");
                    break;
                case "1":
                    re = Tools.getMsgById("_climb7");
                    break; 
                case "2":
                    re = Tools.getMsgById("_climb8");
                    break;
                case "3":
                    re = Tools.getMsgById("_climb9");
                    break;                                                             
            
                default:
                    break;
            }
            return re;
            
        }
        private function setUIlog():void{
            var arr:Array = this.mGroupData.log_list;
            var len:int = arr.length;
            var round:int = 0;
            var pkArr:Array;
            var pName:Array;
            for(var i:int = 0; i < len; i++){
                round = Math.floor(i/4);
                pkArr = arr[i];
                pName = group012arr[i];
                if(pName.length>1){
                    this.setPlayerUI(this["p"+pName[0]] as itemChampion8UI,pkArr[0]);
                    this.setPlayerUI(this["p"+pName[1]] as itemChampion8UI,pkArr[1]); 
                    (this["l"+pName[0]] as Component).alpha = (pkArr[2]==0)?1:0.3;
                    (this["l"+pName[1]] as Component).alpha = (pkArr[2]==1)?1:0.3;
                    //
                    if(len == 4){
                        this.setPlayerUI(this["p1"+(i+1)] as itemChampion8UI,(pkArr[2]==0)?pkArr[0]:pkArr[1]);
                    }
                    else if(len == 8){
                        if(i==4){
                            this.setPlayerUI(this["p21"] as itemChampion8UI,(pkArr[2]==0)?pkArr[0]:pkArr[1]);
                        }
                        else if(i==6){
                            this.setPlayerUI(this["p22"] as itemChampion8UI,(pkArr[2]==0)?pkArr[0]:pkArr[1]);
                        }
                    }
                    else{
                        if(round==2){
                            this.setPlayerUI(this["p31"] as itemChampion8UI,(pkArr[2] == 0)?pkArr[0]:pkArr[1],true);
                        } 
                    }
                    if(this["f"+i]){
                        this["f"+i].visible = true;
                        (this["f"+i] as Button).offAll(Event.CLICK);
                        (this["f"+i] as Button).on(Event.CLICK,this,this.click_fight,[pkArr]);
                    }                  
                }
            }
            this.winner.visible = len>9;
        }
        private function click_fight(pkArr:Array):void
        {
			var fightData:Object = ModelClimb.getChampionFightData(pkArr);
			
			if (FightMain.checkPlayback(fightData.time)){
				FightMain.startBattle(fightData);
			}
			else{
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_explore073"));
			}
        }
        private function setPlayerUI(item:itemChampion8UI,data,isWin:Boolean = false):void{
            item.bg0.visible = !isWin;
            item.bg1.visible = isWin;
            if(isWin){
                item.boxGlow.destroyChildren();
                var glow:Animation = EffectManager.loadAnimation("glow034");
                glow.x = item.width*0.5;
                glow.y = item.height*0.5;
                item.boxGlow.addChild(glow);
            }
            // trace(data);
            item.boxTag.visible = false;
            item.heroIcon.visible = true;
            item.mCountry.visible = true;
            item.mCountry.setCountryFlag(data.country);
            item.heroIcon.setHeroIcon(Tools.isNullObj(data.head)?(data.troop?data.troop[0].hid:ConfigServer.system_simple.init_user.head):data.head);
            item.tName.text = data.uname;
            Tools.textFitFontSize(item.tName);
            item["heroId"] = data.uid;
            item.off(Event.CLICK,this,this.click_hero);
            item.on(Event.CLICK,this,this.click_hero,[data.uid ? data.uid : -1]);
        }
        private function click_hero(_uid:*):void
        {
            ModelManager.instance.modelUser.selectUserInfo(_uid);
        }
        private function setUIReady():void{
            var arr:Array = this.mGroupData.log_list;
            var len:int = arr.length;
            for(var i:int = 0; i < len; i++)
            {
                this.setPlayerUI(this["p0"+i],arr[i]);
            }
            this.winner.visible = false;
        }
    }   
}