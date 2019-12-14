package sg.view.fight
{
	import sg.fight.FightMain;
    import ui.fight.pkDeployUI;
    import laya.ui.Box;
    import laya.events.Event;
    import laya.maths.Point;
    import sg.manager.ModelManager;
    import sg.model.ModelHero;
    import laya.maths.MathUtil;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import sg.net.NetPackage;
    import laya.utils.Handler;
    import sg.manager.ViewManager;
    import sg.model.ModelGame;
    import sg.cfg.ConfigClass;
    import sg.utils.Tools;
    import sg.model.ModelItem;
    import sg.manager.AssetsManager;
    import sg.view.effect.PKRankChange;
    import sg.model.ModelClimb;
    import sg.model.ModelUser;

    public class ViewPKDeploy extends pkDeployUI{
        private var mData:Object;
        private var mBox_me:Box;
        private var mBox_other:Box;
        private var mSelectItem:ItemPKhero;
        private var mTempTroop:Array;
        private var mTempMyData:Object;
        private var mTroopNum:int = -1;
        private var mStatus:Number = -1;
        public function ViewPKDeploy(){
            this.text0.text=Tools.getMsgById("_pk03");
            this.mBox_me = new Box();
            this.mBox_me.y = 90;
            this.mBox.addChild(this.mBox_me);
            //
            this.mBox_other = new Box();
            this.mBox_other.y = 90;
            this.mBox.addChild(this.mBox_other);
            //
            this.mSelectItem = new ItemPKhero();
            this.mSelectItem.mouseEnabled = false;
            this.mSelectItem.mouseThrough = true;
            this.mSelectItem.visible = false;
            this.mBox.addChild(this.mSelectItem);
            //
            this.on(Event.MOUSE_DOWN,this,this.onDown);
            this.on(Event.MOUSE_UP,this,this.onUp);
            // this.mSelectItem.on(Event.DRAG_MOVE,this,this.onDrag);
            this.btn.on(Event.CLICK, this, this.click_pk,[0]);
            this.btnClear.on(Event.CLICK,this,this.click_pk,[1]);
            this.btn.label = Tools.getMsgById("_lht65");
        }
        private function click_clear():void
        {
            
        }
        private function click_pk(type:Number):void{
            
            var n:Number=ModelManager.instance.modelClimb.getPKmyTimes();//可打的次数
            if(n==0){
                var buyMax:Number = ModelManager.instance.modelClimb.getPKbuyForIndex().length;
                var curr:Number = ModelManager.instance.modelClimb.getPKmyBuyTimes();
                if(curr<buyMax){
                    ViewManager.instance.showBuyTimes(1,ModelManager.instance.modelClimb.getPKtimesForBuyOne(),buyMax - curr,ModelManager.instance.modelClimb.getPKbuyForIndex()[curr]);
                    return;
                }
                else{
                    ViewManager.instance.showTipsTxt(Tools.getMsgById("_pve_tips08"));
                    return;
                }
            }

            var item:ItemPKhero;
            var len:int = this.mBox_me.numChildren;
            var arr:Array = [];
            var hids:Array = [];
            for(var i:int = 0; i < len; i++)
            {
                item = this.mBox_me.getChildAt(i) as ItemPKhero;
                if(item.mStatus == 1){
                    // arr.push({hid:item.mModel.id,index:item.mIndex});
                    hids.push(item.mModel.id);
                }
            }
            
            NetSocket.instance.send(NetMethodCfg.WS_SR_PK_USER,{rank_num:this.mData.rank,hids:hids,clear:type},Handler.create(this,this.ws_sr_pk_user));
        }
        private function ws_sr_pk_user(re:NetPackage):void{
			var receiveData:* = re.receiveData;	
            //

            ModelManager.instance.modelUser.updateData(receiveData);
			//群雄逐鹿战斗
            if(re.sendData.clear == 1){
                this.outFight(receiveData);
            }
            else{
                FightMain.startBattle(receiveData, this, this.outFight, [receiveData]);
            }
			
            //
			this.closeSelf();
        }
		/**
		 * 群雄逐鹿战斗，退出到面板后的处理
		 */
		private function outFight(receiveData:*):void{
            //
            ModelManager.instance.modelGame.event(ModelGame.EVENT_PK_TIMES_CHANGE,receiveData);
        }
        override public function initData():void{
            this.mData = this.currArg[0];
            this.mTempMyData = this.currArg[1];
            this.mStatus = this.currArg[2];
            this.mTempTroop = Tools.isNullObj(this.mTempMyData)?[]:this.mTempMyData.troop;
            //
            //this.tTitle.text = Tools.getMsgById("add_both");//"群雄逐鹿";
            this.comTitle.setViewTitle(Tools.getMsgById("add_both"));
            this.tName.text = ModelManager.instance.modelUser.uname;
            this.tOther.text = this.mData.uname;
            //
            this.btnClear.label = Tools.getMsgById("_pve_text04");
            this.btn.label = Tools.getMsgById("_lht65");
            this.btnClear.visible = (this.mStatus==1);
            //
            var award:Array = ModelManager.instance.modelClimb.getPKawardByOnec();
            this.award.setData(AssetsManager.getAssetsICON(ModelItem.getItemIcon(award[0])));
            this.award.setNum(award[1]);
            // this.award.setData(ModelItem.getItemIcon(award[0]),0,"",award[1]);
            // this.award.visibleOnlyIcon();
            //
            this.setHerosForMe();
            this.setHerosForOther();
        }

        private function eventCallBack(re:Object):void{
            if(re && re.pk_records){

            }
        }

        override public function onAdded():void{
            ModelManager.instance.modelUser.on(ModelUser.EVENT_USER_UPDATE,this,eventCallBack);
        }

        override public function onRemoved():void{
            ModelManager.instance.modelUser.off(ModelUser.EVENT_USER_UPDATE,this,eventCallBack);
            this.mBox_me.destroyChildren();
            //
            this.mBox_other.destroyChildren();
            //
            this.mSelectItem.visible = false;
        }
        private function setHerosForOther():void{
            var arr:Array = this.mData.troop as Array;
            var len:int = 5;//arr.length;
            var item:ItemPKhero;
            for(var i:int = 0; i < len; i++)
            {
                item = new ItemPKhero(false);
                if(i<arr.length){
                    item.setDataOther(i,arr[i]);            
                }                
                else{
                    item.setDataOther(i,null);
                }
                item.y = i*100;
                this.mBox_other.addChild(item);
            }
            this.mBox_other.right = 8;
        }
        private function setHerosForMe():void{
            var openLen:int = ModelClimb.getPKdeployMax();
            var arr:Array = [];
            var hmd:ModelHero;
            var len:int = this.mTempTroop.length;
            var saveHids:Array = [];
            for(var i:int = 0; i < len; i++)
            {  
                //存储的
                hmd = ModelManager.instance.modelGame.getModelHero(this.mTempTroop[i].hid);
                if(ModelManager.instance.modelUser.getCommander(hmd.id)){
                    continue;
                }
                hmd["sortPower"] = hmd.getPower();
                hmd["sortLv"] = hmd.getLv();   
                saveHids.push(hmd.id);
                arr.push(hmd);             
            }
            if(arr.length < openLen){
                //推荐的
                var moreHids:Array = [];
                for(var key:String in ModelManager.instance.modelUser.hero)
                {
                    
                    hmd = ModelManager.instance.modelGame.getModelHero(key);
                    if(ModelManager.instance.modelUser.getCommander(hmd.id)){
                        continue;
                    }                    
                    if(saveHids.indexOf(hmd.id)<0){
                        hmd["sortPower"] = hmd.getPower()
                        hmd["sortLv"] = hmd.getLv();
                        moreHids.push(hmd);
                    }
                }
                moreHids.sort(MathUtil.sortByKey("sortPower",true));
                len = moreHids.length;
                for(i = 0; i < len; i++)
                {
                    arr.push(moreHids[i]);
                    if(arr.length >= openLen){
                        break;
                    }
                }
            }
            else{
                
                if(arr.length>openLen){
                    arr = arr.slice(0,openLen);
                }
            }
            //
            len = 5;//arr.length;
            var item:ItemPKhero;
            this.mTroopNum = 0;
            for(i = 0; i < len; i++)
            {
                item = new ItemPKhero();
                item.offAll(Event.MOUSE_OVER);
                item.on(Event.MOUSE_OVER,this,this.onOver,[item]);
                item.offAll(Event.CLICK);
                item.on(Event.CLICK,this,this.click,[item]);
                if(i<arr.length){
                    this.mTroopNum+=1;
                    item.setDataMe(i,arr[i]);
                }
                else{
                    item.setDataMe(i,null);
                }
                item.y = i * 100;
                this.mBox_me.addChild(item);
            }
            this.mBox_me.x = 8;
        }
        private function click(item:ItemPKhero):void{
            if(item.mStatus>=0){
                ViewManager.instance.showView(ConfigClass.VIEW_PK_TROOP,[this.mBox_me,item,this.mTroopNum]);
            }
        }

        private var isDrag:Boolean = false;
        private function onDown(evt:Event):void{
            if(evt.target is ItemPKhero){
                var item:ItemPKhero = evt.target as ItemPKhero;
				if(!item.isMe){
                    return;
                }
				
                var point:Point = this.mBox_me.toParentPoint(new Point(item.x,item.y));
                if(item.mStatus!=1){
                    return;
                }
                this.mSelectItem.x = point.x;
                this.mSelectItem.y = point.y;
                this.mSelectItem.setDataMe(item.mIndex,item.mModel);
                this.mSelectItem.visible = true;
                this.mSelectItem.mDropItem = item;
                this.mSelectItem.startDrag();
                //
            }
        }

        private function onOver(item:ItemPKhero):void{
            if(item.mStatus!=1){
                return;
            }
            if(item.mIndex!=this.mSelectItem.mIndex){
                // 不一样
            }
            else{
                // 一样
            }
        }
        
        private function onUp(evt:Event):void{
            if(evt.target is ItemPKhero){
                var item:ItemPKhero = evt.target as ItemPKhero;
                if(item.isMe && item.mStatus == 1){
                    if(item.mIndex!=this.mSelectItem.mIndex){
                        //不一样up
                        var dInde:int = item.mIndex;
                        var dModel:ModelHero = item.mModel;
                        //
                        if(this.mSelectItem.mDropItem){
                            item.setDataMe(dInde,this.mSelectItem.mModel);
                        }
                        if(this.mSelectItem.mDropItem){
                            this.mSelectItem.mDropItem.setDataMe(this.mSelectItem.mIndex,dModel);
                        }
                    }
                    else{
                        //一样up
                    }
                }
            }
            this.mSelectItem.mDropItem = null;
            this.mSelectItem.stopDrag();
            this.mSelectItem.visible = false;
        }  
    }   
}