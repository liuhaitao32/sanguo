package sg.view.fight
{
    import ui.fight.championBetEditUI;
    import sg.manager.ModelManager;
    import sg.utils.Tools;
    import laya.utils.Handler;
    import sg.cfg.ConfigServer;
    import sg.model.ModelItem;
    import sg.manager.AssetsManager;
    import laya.events.Event;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import sg.net.NetPackage;
    import sg.model.ModelGame;
    import sg.manager.LoadeManager;
    import sg.utils.StringUtil;

    public class ViewChampionBetEdit extends championBetEditUI{
        private var mData:Object;
        private var mMin:Number;
        private var mMax:Number;
        private var mBetData:Object;
        private var mAllBet:Number;
        public function ViewChampionBetEdit(){
            this.comTitle.setViewTitle(Tools.getMsgById("_climb24"));
            this.bar.changeHandler = new Handler(this,this.bar_change);
            this.btn.on(Event.CLICK,this,this.click);
            this.text0.text=Tools.getMsgById("_champion04");
            this.text1.text=Tools.getMsgById("_champion05");
            this.text2.text=Tools.getMsgById("_champion06");
            this.btn.label = Tools.getMsgById('_climb17');
        }
        override public function initData():void{
            this.mData = this.currArg[0];
            this.mBetData = this.currArg[1];
            this.mAllBet = this.currArg[2];
            //
            LoadeManager.loadTemp(this.adImg,AssetsManager.getAssetsUI("bg_17.png"));
            this.tName.text = this.mData.uname;
			this.comPower.setNum(this.mData.power);
            //this.tPower.text = ""+this.mData.power;
            this.heroIcon.setHeroIcon(Tools.isNullObj(this.mData.head)?ModelManager.instance.modelUser.getHead():this.mData.head);
            // player.btn.visible = false;
            var uid:String = this.mData.uid +"";
            var num:Number = 0;
            var myBet:Number = 0;
            var myUid:String = ModelManager.instance.modelUser.mUID;
   
            for(var key2:String in this.mBetData[uid]){
                num = num + Number(this.mBetData[uid][key2]);
            }
            //
            var playerbet:Object;
            var myBetUid:String = "";
            for(var key:String in this.mBetData)
            { 
                playerbet = this.mBetData[key];
                if(playerbet.hasOwnProperty(myUid)){
                    myBetUid = key;
                    myBet = playerbet[myUid];
                    break;
                }
            }

            var bs:Number = this.mAllBet/Math.max(num,1);
            bs = (bs>10)?10:bs;
            this.tBet.text = Tools.getMsgById("_climb63",[Tools.numberFormat(bs,2)]);//"赔率:1赔"+bs;
            this.tNum.text = ""+num;
            //
            var item078:Number = ModelItem.getMyItemNum("item078");
            //
            this.mMin = Math.min(item078,ConfigServer.pk_yard.stake[0]);
            this.mMax = Math.min(item078,ConfigServer.pk_yard.stake[1]);
            //
            this.bar.min = this.mMin;
            this.bar.max = this.mMax;
            this.bar.value = this.mMin;
            this.bar.showLabel = false;
            //
            this.mBet.visible = (myBet<=0);
            this.btn.visible = this.mBet.visible;
            this.tMyBet.visible = !this.mBet.visible;
            this.tMyBet.text = (myBetUid == uid)?Tools.getMsgById("_climb16")+":"+myBet:Tools.getMsgById("_climb19");//"已押注:"+myBet:"已经押注其他人";
            //
            this.cost.setData(AssetsManager.getAssetItemOrPayByID("item078"),item078+"");
        }
        private function bar_change(v:Number):void{
            this.tNum.text = v+"";
        }
        private function click():void{
            ViewManager.instance.showAlert(Tools.getMsgById("_climb20",[this.mMax]),Handler.create(this,this.funcOk));//"只可以押注一次,最多押注"+this.mMax
        }
        private function funcOk(type:int):void{
            if(type==0){
                NetSocket.instance.send(NetMethodCfg.WS_SR_PK_YARD_GAMBLE,{uid:this.mData.uid,coin_num:this.bar.value},Handler.create(this,this.WS_SR_PK_YARD_GAMBLE));
            }
        }
        private function WS_SR_PK_YARD_GAMBLE(re:NetPackage):void{
            ModelManager.instance.modelUser.updateData(re.receiveData);
            ModelManager.instance.modelGame.event(ModelGame.EVENT_CHAMPION_BET_CHANGE,re.receiveData.gamble);
            this.closeSelf();
        }
    }   
}