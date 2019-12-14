package sg.view.hero
{
    import ui.hero.lvUpgradeUI;
    import sg.model.ModelHero;
    import laya.ui.Box;
    import sg.model.ModelItem;
    import sg.cfg.ConfigServer;
    import laya.maths.MathUtil;
    import sg.utils.Tools;
    import laya.display.Animation;
    import sg.manager.EffectManager;
    import laya.events.Event;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import laya.utils.Handler;
    import sg.manager.ViewManager;
    import sg.net.NetPackage;
    import sg.manager.ModelManager;
    import sg.cfg.ConfigClass;
    import sg.utils.MusicManager;

    public class ViewLvUpgrade extends lvUpgradeUI{
        private var mModel:ModelHero;
        private var mBox_item:Box;
        private var mItemArr:Array;
        private var mRunClick:Boolean = false;
        private var mClickDownTime:Number=0;
        private var mTime:Number=0;
        private var cfgLvSpeed:Array;
        private var mLv:Number=0;
        public function ViewLvUpgrade():void{
            this.mBox_item = new Box();
            this.mBox.addChild(this.mBox_item);
            //
            //txt_title.text = Tools.getMsgById('_building23');
            this.comTitle.setViewTitle(Tools.getMsgById('_building23'));
            txt_hint.text = Tools.getMsgById('_jia0100');
            Laya.stage.on(Event.MOUSE_OUT,this,function():void{
				this.mRunClick = false;
			});
        }
        override public function initData():void{
            cfgLvSpeed=ConfigServer.system_simple.lv_speed;
            this.mModel = this.currArg as ModelHero;
            mLv=this.mModel.getLv();
            //
            var cfg:Object = ConfigServer.system_simple.exp_book;
            this.mItemArr = [];
            var item:ModelItem;
            //
            for(var key:String in cfg)
            {
                item = new ModelItem();
                item.initDataByCfg(key,ConfigServer.property[key]);
                this.mItemArr.push(item);
            }
            this.mItemArr.sort(MathUtil.sortByKey("id"));
            //
            var len:int = this.mItemArr.length;
            var book:ItemExpBook;
            //
            this.mBox_item.destroyChildren();
            //
            for(var i:int = 0; i < len; i++)
            {
                item = this.mItemArr[i];
                book = new ItemExpBook();
                book.x = i*(book.width+20);
                book.init(this.mModel,item);
                book.off(Event.CLICK,this,this.click_null);
                book.on(Event.CLICK,this,this.click_null);

                book.off(Event.MOUSE_DOWN,this,this.mouseDown);
                //book.off(Event.MOUSE_OUT,this,this.mouseUp);
                book.on(Event.MOUSE_DOWN,this,this.mouseDown,[i,book]);
                //book.on(Event.MOUSE_OUT,this,this.mouseUp);

                book.name = 'book_' + i;
                this.mBox_item.addChild(book);
            }     
            this.mBox_item.centerX = 0;
            this.mBox_item.centerY = 30;
            //            
            this.heroIcon.setHeroIcon(this.mModel.getHeadId(),true,this.mModel.getStarGradeColor());       
            //
            this.changeUI();
            //
            this.setBookUI(0);
        }
        private function click_null():void
        {
            
        }
        private function mouseDown(index:int,book:ItemExpBook):void{
            this.mRunClick = true;
            mClickDownTime=0;
            timeTick();
            timer.frameLoop(1,this,timeTick);
            Laya.stage.once(Event.MOUSE_UP,this,this.mouseUp);
            this.click(index,book);
        }
        private function mouseUp():void{
            this.mRunClick = false;
            timer.clear(this,timeTick);
        }        
        private function click(index:int,book:ItemExpBook):void{
            var item:ModelItem = this.mItemArr[index];
            if(ModelItem.getMyItemNum(item.id)<=0){
                ViewManager.instance.showView(ConfigClass.VIEW_BAG_SOURSE,item.id);
                this.mRunClick = false;
                return;
            }
            if(this.mModel.getLv()<ModelHero.getMaxLv()){
                
                NetSocket.instance.send(NetMethodCfg.WS_SR_HERO_LV_UP,{hid:this.mModel.id,item_id:item.id},Handler.create(this,this.ws_sr_hero_lv_up),[book,index]);
            }
            else{
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_public13"));//无法升级,需要提升官邸等级
            }
            this.setBookUI(index);
        }
        private function setBookUI(index:int):void{
            // var item:ModelItem = this.mItemArr[index]; 
            // this.book.setData(item.icon,item.ratity);
            // this.tExpAdd.text = Tools.getMsgById("_public14",[ConfigServer.system_simple.exp_book[item.id]]);//提供经验
            // this.tInfo.text = Tools.getMsgById(item.info);
        }
        private function ws_sr_hero_lv_up(re:NetPackage):void{
            //
            var olv:int = this.mModel.getLv();
            ModelManager.instance.modelUser.updateData(re.receiveData);
            var nlv:int = this.mModel.getLv();
            //
            var book:ItemExpBook = re.otherData[0];
            var index:int = re.otherData[1];
            var item:ModelItem = this.mItemArr[index];
            book.init(this.mModel,item);
            //
            this.checkClip(nlv!=olv);
            this.changeUI();
            //
            this.timer.once(mTime,this,function():void{
                if(this.mRunClick){
                    this.click(index,book);
                }
                else{
                    //
                    // this.mModel.event(ModelHero.EVENT_HERO_EXP_CHANGE);
                }
            });
            if(mLv!=this.mModel.getLv()){
                MusicManager.playSoundUI(MusicManager.SOUND_HERO_LV_UP);
                mLv=this.mModel.getLv();
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

        private function changeUI():void{
            var cexp:Number = this.mModel.getExp();
            var nexp:Number = this.mModel.getLvExp(this.mModel.getLv()+1);
            //
            this.barExp.value = cexp/nexp;
            this.tLv.text = Tools.getMsgById(90007,[this.mModel.getLv(),ModelHero.getMaxLv()]);
            this.tExp.text = Tools.getMsgById(90008,[cexp,nexp]);
            //
        }
        override public function onAdded():void{

        }
        override public function onRemoved():void{
            this.mBox_item.destroyChildren();
            this.clipBox.destroyChildren();
            //
            this.mRunClick = false;
            this.mModel.event(ModelHero.EVENT_HERO_EXP_CHANGE);
        }
        private function checkClip(lvUp:Boolean = false):void{
            this.clipBox.destroyChildren();
            //
            var aniExp:Animation = EffectManager.loadAnimation("glow007","",2);
            aniExp.x = this.barExp.x;
            aniExp.y = this.barExp.y;
            this.clipBox.addChild(aniExp);
            //
            if(lvUp){
                var aniLv:Animation = EffectManager.loadAnimation("glow010","",2);
                aniLv.x = this.heroIcon.x;
                aniLv.y = this.heroIcon.y; 
                this.clipBox.addChild(aniLv);           
            }
        }
        private function click_go():void
        {
            
        }

		/**
		 * 根据名字获取界面中的对象
		 * @param	name
		 * @return 	Sprite || undefined
		 */
		override public function getSpriteByName(name:String):*
		{
            if(name.indexOf('list') !== -1) {
                var objName:String = 'book_' + name.match(/\d/)[0];
                if (this.mBox_item.getChildByName(objName))   return this.mBox_item.getChildByName(objName);
            }
            return super.getSpriteByName(name);
		}
    }   
}