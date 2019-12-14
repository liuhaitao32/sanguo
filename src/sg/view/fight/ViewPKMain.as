package sg.view.fight
{
    import ui.fight.pkMainUI;
    import laya.events.Event;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import laya.utils.Handler;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import sg.net.NetPackage;
    import sg.utils.Tools;
    import sg.manager.ModelManager;
    import sg.model.ModelGame;
    import ui.fight.itemPKcountryUI;
    import laya.maths.MathUtil;
    import sg.model.ModelUser;
    import sg.view.effect.PKRankChange;
    import sg.cfg.ConfigServer;
    import sg.boundFor.GotoManager;
    import laya.display.Sprite;

    public class ViewPKMain extends pkMainUI{
        private var timerGetUser:Number = 0;
        private var mTempMyData:Object;
        private var mPageIndex:int;
        public function ViewPKMain(){
            this.text0.text=Tools.getMsgById("_pk04");
            Tools.textLayout2(text0,img0,290,230);
            
            this.text1.text=Tools.getMsgById("_pk05");
            //
            this.btn_report.on(Event.CLICK,this,this.click,[0]);
            this.btn_rank.on(Event.CLICK,this,this.click,[1]);
            this.btn_re.on(Event.CLICK,this,this.click,[2]);
            this.btn_shop.on(Event.CLICK,this,this.click_shop);
            //
            this.btn_buy.on(Event.CLICK,this,this.click_buy);
            //
            this.btn_back.on(Event.CLICK,this,this.click_page,[-5,false]);
            this.btn_next.on(Event.CLICK,this,this.click_page,[5,false]);
            //
            this.list.itemRender = ItemPKopponent;
            this.list.scrollBar.touchScrollEnable = false;
            this.list.scrollBar.hide = true;
            this.list.renderHandler = new Handler(this,this.list_render);
            //
            this.listCountry.itemRender = itemPKcountryUI;
            this.listCountry.renderHandler = new Handler(this,this.listCountry_render);
            this.listCountry.scrollBar.hide = true;
			this.btn_re.label = Tools.getMsgById("ViewPKMain_1");
            //
        }
        private function listCountry_render(item:itemPKcountryUI,index:int):void{
            var data:Object = this.listCountry.array[index];
            // item.tCountry.text = ModelUser.country_name[data.index];
            item.country.setCountryFlag(data.index);
            var sd:Object = data.data;
            if (sd){
				item.heroIcon.setHeroIcon(sd.head?sd.head:ConfigServer.system_simple.init_user.head);
                item.tIndex.text = data.rank;
                item.tName.text = sd.uname;
                item.off(Event.CLICK,this,itemClick);
                item.on(Event.CLICK,this,itemClick,[sd.uid]);                
            }
            else{
                item.tIndex.text = "--";
                item.tName.text = Tools.getMsgById("_public101");//"未上榜";
                item.heroIcon.setHeroIcon("hero000");
            }
            Tools.textFitFontSize(item.tName);
			item.diming.text = Tools.getMsgById("ViewPKMain_2");
        }
        private function itemClick(uid:*):void{
            ModelManager.instance.modelUser.selectUserInfo(uid);
        }
        override public function onRemoved():void{
            ModelManager.instance.modelGame.off(ModelGame.EVENT_PK_TIMES_CHANGE,this,this.timeRunPKuser);
        }
        override public function initData():void{
            ModelManager.instance.modelGame.on(ModelGame.EVENT_PK_TIMES_CHANGE,this,this.timeRunPKuser);
            //
            this.setTitle(Tools.getMsgById("add_both"));//"群雄逐鹿"
            this.timeRunPKuser();
            //
            var cData:Object = this.currArg["receive_data"];
            var arr:Array = [];
            var d:Object;
            for(var key:String in cData)
            {
                d = cData[key];
                arr.push({index:Number(key),data:d,rank:(d?d["rank"]:ConfigServer.pk.pk_robot[ConfigServer.pk.pk_robot.length-1][0])});
            }
            arr.sort(MathUtil.sortByKey("rank"));
            this.tReTime.text = Tools.getMsgById("_climb51",[ConfigServer.pk.pk_day_settlement[0]]);//"每日"+ConfigServer.pk.pk_day_settlement[0]+"点结算个人奖励";
            this.listCountry.dataSource = arr;
        }
        private function click_shop():void
        {
            //ViewManager.instance.showShopScene(2);
            GotoManager.boundForPanel("shop","pk_shop");
        }
        private function click_buy():void{
            var buyMax:Number = ModelManager.instance.modelClimb.getPKbuyForIndex().length;
            var curr:Number = ModelManager.instance.modelClimb.getPKmyBuyTimes();
            if(curr<buyMax){
                ViewManager.instance.showBuyTimes(1,ModelManager.instance.modelClimb.getPKtimesForBuyOne(),buyMax - curr,ModelManager.instance.modelClimb.getPKbuyForIndex()[curr]);
            }
            else{
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_public63"));//"今日无法购买挑战次数"
            }
        }
        private function timeRunPKuser(re:* = null):void{
            //今日可以挑战次数 
            this.tTimes.text = ""+ModelManager.instance.modelClimb.getPKmyTimes()+"/"+ModelManager.instance.modelClimb.getPKtimesMax();
            
            this.timerGetUser = Tools.runAtTimer(this.timerGetUser,1000,Handler.create(this,this.getPKuser,[re]));
        }
        private function getPKuser(re:* = null):void{
            NetSocket.instance.send(NetMethodCfg.WS_SR_GET_PK_USER,{},Handler.create(this,this.ws_sr_get_pk_user),re);
        }
        private function ws_sr_get_pk_user(re:NetPackage):void{
            this.setPageData(re)
        }
        private function setPageData(re:NetPackage):void
        {
            var arr:Array = re.receiveData as Array;
            var len:int = arr.length;
            var myIndex:int = -1;
            var oldRank:int = this.mTempMyData?this.mTempMyData.rank:ConfigServer.pk.pk_robot[ConfigServer.pk.pk_robot.length-1][0];
            this.mTempMyData = null;
            for(var i:int = 0; i < len; i++)
            {
                if(arr[i].uid == ModelManager.instance.modelUser.mUID){
                    this.mTempMyData = arr[i];
                    myIndex = i;
                    break;
                }
            }
            //
            if(!this.mTempMyData){
                this.mTempMyData = {uname:ModelManager.instance.modelUser.uname,uid:ModelManager.instance.modelUser.mUID,rank:ConfigServer.pk.pk_robot[ConfigServer.pk.pk_robot.length-1][0]};
                arr.push(this.mTempMyData);
            }
            this.mPageIndex = arr.length - 5;
            if(myIndex>-1){
                if(this.mTempMyData.rank<21){
                    this.mPageIndex = myIndex - 4;
                }
                else{
                    // this.mPageIndex = arr.length - (5-(arr.length-myIndex-1));
                }
            }
            this.mPageIndex = (this.mPageIndex<=0)?0:this.mPageIndex;
            this.list.dataSource = arr;
            
            this.click_page(this.mPageIndex,true);
            //
            if(!Tools.isNullObj(re.otherData)){
                ViewManager.instance.showViewEffect(PKRankChange.getEffect([oldRank,this.mTempMyData.rank,re.otherData]));
            }            
        }
        private function click(type:int):void{
            if(type == 0){
                ViewManager.instance.showView(ConfigClass.VIEW_PK_REPORT);
            }
            else if(type == 1){
                ViewManager.instance.showView(ConfigClass.VIEW_PK_RANK,this.mTempMyData);
            }
            else{
                this.timeRunPKuser();
            }
        }
        private function click_page(n:int,toUse:Boolean = false):void{
            if(toUse){
                this.mPageIndex = n;
            }
            else{
                this.mPageIndex +=n;
            }
            var toIndex:int = this.mPageIndex;
            this.btn_back.visible = false;
            this.btn_next.visible = false;

            if(this.mPageIndex<=0){
                toIndex = 0;
            }
            else{
                this.btn_back.visible = true;
            }


            if((this.mPageIndex+5)>=this.list.array.length){
                toIndex = this.list.array.length-1;
            }
            else{
                this.btn_next.visible = true;
            }
            //
            this.tPage.text = (Math.ceil(this.mPageIndex/5)+1) + "/"+ Math.ceil(this.list.array.length/5);
            //
            this.list.scrollTo(toIndex);
        }
        private function list_render(item:ItemPKopponent,index:int):void{
            item.centerX = 0;
            item.setData(this.list.array[index],this.mTempMyData);
        }
		/**
		 * 根据名字获取界面中的对象
		 * @param	name
		 * @return 	Sprite || undefined
		 */
		override public function getSpriteByName(name:String):*
		{
            var reg:RegExp = /list_(\d)_(.+)/;
            var result:Array = name.match(reg);
            if (result) {
                var cell:Sprite = this.list.getCell(parseInt(result[1]) + 10);
                if (cell && cell[result[2]])   return cell[result[2]];
            }
            return super.getSpriteByName(name);
		}
    }   
}