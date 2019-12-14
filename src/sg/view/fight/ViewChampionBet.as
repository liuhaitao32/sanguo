package sg.view.fight
{
    import ui.fight.championBetUI;
    import ui.fight.itemChampionBetUI;
    import laya.utils.Handler;
    import sg.manager.ModelManager;
    import sg.utils.Tools;
    import laya.events.Event;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import sg.model.ModelGame;
    import sg.cfg.ConfigServer;
    import laya.maths.MathUtil;
    import sg.manager.AssetsManager;
    import sg.model.ModelItem;
    import sg.manager.LoadeManager;
    import sg.utils.StringUtil;

    public class ViewChampionBet extends championBetUI{
        private var mGroupData:Object;
        private var mBetData:Object;
        private var mAllBet:Number;
        private var mMe:String = "";
        public function ViewChampionBet(){
            this.comTitle.setViewTitle(Tools.getMsgById("_climb24"));
            this.list.itemRender = itemChampionBetUI;
            this.list.renderHandler = new Handler(this,this.list_render);
            this.list.scrollBar.hide = true;
            //
            ModelManager.instance.modelGame.on(ModelGame.EVENT_CHAMPION_BET_CHANGE,this,this.event_champion_bet_change);
            this.text0.text=Tools.getMsgById("_champion03");
        }
        override public function initData():void{
            this.mGroupData = this.currArg[0];
            this.mBetData = this.currArg[1];
            //
            var arr:Array = this.mGroupData.log_list;
            var dataArr:Array = [];
            if(this.mGroupData.if_log>0){
                var len:int = arr.length;
                for(var i:int = 0; i < 4; i++){
                    dataArr.push(arr[i][0]);
                    dataArr.push(arr[i][1]);
                }
            }
            else{
                dataArr = arr;
            }
            this.setAllBet();
            //
            this.list.dataSource = dataArr;
        }
        private function event_champion_bet_change(data:Object):void{
            this.mBetData = data;
            this.setAllBet();
            this.list.dataSource = this.list.array;
        }
        private function list_render(item:itemChampionBetUI,index:int):void{
            var data:Object = this.list.array[index];
            LoadeManager.loadTemp(item.adImg,AssetsManager.getAssetsUI("bg_19.png"));
            item.text0.text=Tools.getMsgById("_champion07");
            item.text1.text=Tools.getMsgById("_champion05");
            item.tName.text = data.uname;
			item.comPower.setNum(data.power);
            item.mCountry.setCountryFlag(data.country);
            //item.tPower.text = ""+data.power;
            item.heroIcon.setHeroIcon(Tools.isNullObj(data.head)?(data.troop?data.troop[0].hid:ConfigServer.system_simple.init_user.head):data.head);
            //
            var uid:String = data.uid +"";
            var num:Number = 0;
            var betUsers:Object = this.mBetData[uid];
            for(var key:String in betUsers){
                num = num + Number(this.mBetData[uid][key]); 
            }
            var isMe:Boolean = this.mMe!="";//betUsers.hasOwnProperty(ModelManager.instance.modelUser.mUID);

            item.btn.gray = isMe;
            item.btn.label = (this.mMe == uid)?Tools.getMsgById("_climb16"):Tools.getMsgById("_climb17");//"已押注":"押注";
            //
            var bs:Number = this.mAllBet/Math.max(num,1);
            bs = (bs>10)?10:bs;
            item.tBet.text = Tools.getMsgById("_climb63",[Tools.numberFormat(bs,2)]);//"赔率:1赔"+bs;
            item.tNum.text = ""+num;
            //
            item.btn.off(Event.CLICK,this,this.click);
            item.btn.on(Event.CLICK,this,this.click,[data]);
        }
        private function setAllBet():void{
            this.mAllBet = 0;
            this.mMe = "";
            for(var key:String in this.mBetData)
            {
                for(var key2:String in this.mBetData[key]){
                    if(key2==ModelManager.instance.modelUser.mUID){
                        this.mMe = key;
                    }
                    this.mAllBet = this.mAllBet + Number(this.mBetData[key][key2]);
                }
            }     
            this.mAllBet = this.mAllBet+Number(ConfigServer.pk_yard.chip);
            //
            this.itemIcon.setData(AssetsManager.getAssetItemOrPayByID("item078"),ModelItem.getMyItemNum("item078")+"");
        }
        private function click(data:Object):void{
            if(this.mGroupData.if_log<=0){

                ViewManager.instance.showView(ConfigClass.VIEW_CHAMPION_BET_EDIT,[data,this.mBetData,this.mAllBet]);
            }
            else{
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_climb38"));//无法押注,只能在八强期准备期押注
            }
        }
    }   

}