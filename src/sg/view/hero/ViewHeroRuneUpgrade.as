package sg.view.hero
{
    import ui.hero.heroRuneUpgradeUI;
    import sg.model.ModelRune;
    import sg.model.ModelHero;
    import laya.ui.Box;
    import laya.maths.MathUtil;
    import ui.bag.bagItemUI;
    import laya.events.Event;
    import sg.model.ModelItem;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import laya.utils.Handler;
    import sg.net.NetPackage;
    import sg.manager.ModelManager;
    import sg.manager.ViewManager;
    import laya.display.Animation;
    import sg.manager.EffectManager;
	import sg.utils.StringUtil;
	import sg.utils.Tools;
	import sg.cfg.ConfigClass;
	import sg.cfg.ConfigServer;

    public class ViewHeroRuneUpgrade extends heroRuneUpgradeUI{
        private var mModel:ModelHero;
        private var mSelectRuneModel:ModelRune;
        private var mBox_items:Box;
        private var mRunClick:Boolean;
        private var mLvMax:Number = 0;
        private var mClickDownTime:Number=0;
        private var mTime:Number=0;
        private var cfgLvSpeed:Array;
        public function ViewHeroRuneUpgrade():void{
            this.mBox_items = new Box();
            
            this.mBox.addChild(this.mBox_items);
			
			this.hInfo.style.fontSize = 20;
			this.hInfo.style.align = 'center';
			this.hNext.style.fontSize = 20;
			this.hNext.style.align = 'center';
        	Laya.stage.on(Event.MOUSE_OUT,this,function():void{
				this.mRunClick = false;
			});
			//this.tTitle.text = Tools.getMsgById("ViewHeroRuneUpgrade_1");
            this.comTitle.setViewTitle(Tools.getMsgById("ViewHeroRuneUpgrade_1"));
			this.tProp.text = Tools.getMsgById("ViewHeroRuneUpgrade_2");
			this.tClick.text = Tools.getMsgById("ViewHeroRuneUpgrade_3");
			this.tDown.text = Tools.getMsgById("_jia0100");
        }
        override public function initData():void{
            cfgLvSpeed=ConfigServer.system_simple.lv_speed;
            this.mModel = this.currArg[0] as ModelHero;
            this.mSelectRuneModel = this.currArg[1] as ModelRune;
            //
        }
        private function setUI():void{
            this.mLvMax =mSelectRuneModel.getMaxLv();
            //this.runeIcon.runeIcon.setIcon(this.mSelectRuneModel.getImgName());
            this.runeIcon.runeIcon.setData(this.mSelectRuneModel.id,-1,-1);
            this.runeIcon.boxLv.visible = false;
            this.runeIcon.imgSelect.visible = false;
            this.tName.text =  this.mSelectRuneModel.getName(true);
			this.tOnly.text =  this.mSelectRuneModel.getOnlyInfo();

			var info:String;
			info = Tools.getMsgById("_public8",[this.mSelectRuneModel.getInfoHtml()]);//当前等级：
			this.hInfo.innerHTML = StringUtil.substituteWithColor(info, "#FCAA44", "#ffffff");
			info = this.mSelectRuneModel.getNextHtml();
			info = (info == '')?'':Tools.getMsgById("_public10",[info]);//'已经满级':'下一级：'
			this.hNext.innerHTML = StringUtil.substituteWithColor(info, "#33FF33", "#ffffff");
			
            this.tLv.text = Tools.getMsgById("_public6",[this.mSelectRuneModel.getLv()]);//等级
            var exp:Number =  this.mSelectRuneModel.getExp();
            var max:Number =  this.mSelectRuneModel.getLvExp(this.mSelectRuneModel.getLv()-1);
            this.tExp.text = (this.mSelectRuneModel.getLv()>=this.mLvMax)?Tools.getMsgById("_public11"):Tools.getMsgById("_public7",[exp+"/"+max]);//"最大经验":经验
            this.bar.value = (this.mSelectRuneModel.getLv() >= this.mLvMax)?1:(exp / max);
			
            //
            var items:Object = this.mSelectRuneModel.getUpgradeItems();
            var arr:Array = [];
            for(var key:String in items)
            {
                arr.push({id:key,num:items[key]});
            }
            arr.sort(MathUtil.sortByKey("num"));
            //
            var item:bagItemUI;
            var obj:Object;
            //
            this.mBox_items.destroyChildren();
            //
            for(var i:int = 0;i<arr.length;i++){
                item = new bagItemUI();
                item.x = i*(item.width + 30);
                obj = arr[i];
                item.off(Event.CLICK,this,this.click);
                item.on(Event.CLICK,this,this.click,[i,arr[i]]);
                item.off(Event.MOUSE_DOWN,this,this.mouseDown);
                //item.off(Event.MOUSE_UP,this,this.mouseUp);
                //item.off(Event.MOUSE_OUT,this,this.mouseUp);
                //item.off(Event.MOUSE_OVER,this,this.mouseUp);
                item.on(Event.MOUSE_DOWN,this,this.mouseDown,[i,arr[i]]);
                //item.on(Event.MOUSE_UP,this,this.mouseUp);
                //item.on(Event.MOUSE_OUT,this,this.mouseUp);
                //item.on(Event.MOUSE_OVER,this,this.mouseUp);                
                //item.setData(ModelItem.getItemIcon(obj.id));
                //item.setNum(ModelItem.getMyItemNum(obj.id));
                //item.setName(ModelItem.getItemName(obj.id));
                item.setData(obj.id,ModelItem.getMyItemNum(obj.id));
                this.mBox_items.addChild(item);
            }
            this.mBox_items.top = 280;
            this.mBox_items.centerX = 0;
        }
        override public function onAdded():void{
            this.setUI();
            //
        }
        override public function onRemoved():void{
            this.clipBox.destroyChildren();
            //
            this.mRunClick = false;
            this.mModel.event(ModelHero.EVENT_HERO_RUNE_CHANGE,false);
            ModelManager.instance.modelGame.event(ModelRune.EVENT_SET_IN_OUT);
        }
        private function mouseDown(index:int,obj:Object):void{
            this.mRunClick = true;
            mClickDownTime=0;
            timeTick();
            timer.frameLoop(1,this,timeTick);
            Laya.stage.once(Event.MOUSE_UP,this,this.mouseUp);
            this.click(index,obj);
        }
        private function mouseUp():void{
            this.mRunClick = false;
        }        
        private function click(index:int,obj:Object):void{          
            //
            if(this.mSelectRuneModel.getLv()>=this.mLvMax){
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_public12"));
                return;
            }
            var num:Number = ModelItem.getMyItemNum(obj.id);
            if(num>0){
                NetSocket.instance.send(NetMethodCfg.WS_SR_STAR_LV_UP,{star_id:this.mSelectRuneModel.id,item_id:obj.id},Handler.create(this,this.ws_sr_star_lv_up),[obj,index]);               
            }
            else{
                ViewManager.instance.showView(ConfigClass.VIEW_BAG_SOURSE,obj.id);
                this.mRunClick = false;                
            }
        }
        private function ws_sr_star_lv_up(re:NetPackage):void{
            // Trace.log("ws_sr_star_lv_up",re.receiveData);
            var olv:int = this.mSelectRuneModel.getLv();
            ModelManager.instance.modelUser.updateData(re.receiveData);
            //
            var nlv:int = this.mSelectRuneModel.getLv();
            //
            this.checkClip(olv!=nlv);
            //
            this.setUI();
            //
            var obj:Object = re.otherData[0];
            var index:int = re.otherData[1];   
            this.timer.once(mTime,this,function():void{
                if(this.mRunClick){
                    this.click(index,obj);
                }
                else{
                    //
                    // this.mModel.event(ModelHero.EVENT_HERO_RUNE_CHANGE,false);
                }
            });                     
        }
        private function checkClip(lvUp:Boolean = false):void{
            this.clipBox.destroyChildren();
            //
            var aniExp:Animation = EffectManager.loadAnimation("glow007","",2);
            aniExp.x = this.bar.x;
            aniExp.y = this.bar.y;
            this.clipBox.addChild(aniExp);
            //
            if(lvUp){
                var aniLv:Animation = EffectManager.loadAnimation("glow010","",2);
                aniLv.x = this.runeIcon.x;
                aniLv.y = this.runeIcon.y; 
                this.clipBox.addChild(aniLv);           
            }
        }    

        private function timeTick():void{
            mClickDownTime+=1;
            if(mClickDownTime<30){
                mTime=cfgLvSpeed[0];
            }else{
                mTime=cfgLvSpeed[0] * (Math.pow(cfgLvSpeed[1],Math.floor(mClickDownTime/30)));
            }
            mTime=mTime<10?10:mTime;
            
        }    
    }
}