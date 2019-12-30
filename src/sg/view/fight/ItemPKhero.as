package sg.view.fight
{
    import ui.fight.itemPKheroUI;
    import ui.inside.pubHeroItemUI;
    import laya.utils.Utils;
    import sg.model.ModelHero;
    import sg.manager.ModelManager;
    import sg.cfg.ConfigServer;
    import sg.model.ModelPrepare;
    import sg.manager.EffectManager;
    import sg.utils.Tools;
    import laya.events.Event;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;

    public class ItemPKhero extends itemPKheroUI{

        public static const GID:String = "pk_hero_deploy_";
        private var mIsMe:Boolean = false;
        
		public function get isMe():Boolean{
			return this.mIsMe;
		}
		
        public var mIndex:int = -1;
        public var mModel:ModelHero;
        public var mId:String = "";
        public var mType:String = "";
        public var mStatus:int = -1;
        public var mDropItem:ItemPKhero;
        public var mIsFriend:Boolean=false;//是否是援军
        public function ItemPKhero(isMe:Boolean = true){
            this.mIsMe = isMe;
            if(this.mIsMe){
                this.mType = GID+Utils.getGID();
            }
        }

        override public function set dataSource(source:*):void {
            if (!source)    return;
            source.mine && this.setDataMe(source.index, source.data);
            source.mine || this.setDataOther(source.index, source.data);
        }

        public function setDataMe(index:int,hmd:ModelHero,type:int=0):void{
            this.mIndex = index;
            if(hmd){
                this.mModel = hmd;
            }
            this.setUI(type);
        }
        public function setDataOther(index:int,data:*,type:int=0):void{
            this.mIndex = index;
            this.mIsMe = false;
            if(data){
                this.mModel = new ModelHero(true);
                this.mModel.setData(data);
            }
			if(!this.mIsMe){
				this.off(Event.CLICK,this, this._click);
				this.on(Event.CLICK,this, this._click, [data]);
			}
            this.setUI(type);
        }
        private function _click(data:*):void{
            this.mModel && ViewManager.instance.showView(ConfigClass.VIEW_HERO_INFO,[data]);
        }
        public function setIsFriend(b:Boolean=false):void{
            mIsFriend=b;
        }
        public function setUI(t:int):void{//0 pk   1 沙盘
            if(this.mModel){
                this.mHave.visible = true;
                // this.tStatus.visible = false;
                this.mLock.visible = false;
                this.tName.text = this.mModel.getName() + "";
                Tools.textFitFontSize(this.tName);
				this.heroLv.setNum(this.mModel.getLv());
                //this.tLv.text = this.mModel.getLv()+"";

                this.mStatus = 1;
                var mpr:ModelPrepare;
                //
                if(this.mModel.isOther){
                    mpr = this.mModel.getPrepare(true,this.mModel.mData);
                }
                else{
                    mpr = this.mModel.getPrepare(true);
                }
				this.comPower.setNum(this.mModel.getPower());
                //this.tPower.text = this.mModel.getPower()+"";
				var colorType:int = this.mModel.getStarGradeColor(mpr);
                EffectManager.changeSprColor(this.colorBg, colorType, false);
				this.heroStar.setHeroStar(this.mModel.getStar(mpr));
                this.heroIcon.setHeroIcon(this.mModel.getHeadId(),true, colorType);
                this.heroType.setHeroType(this.mModel.getType());
            //
            }
            else{
                this.mHave.visible = false;
                // this.tStatus.visible = this.mIsMe;
                this.mLock.visible = this.mIsMe;
                //
                if(t==0 && this.mIsMe){
                    var max:int = ConfigServer.pk["pk_hero"][this.mIndex];
                    var myLv:int = ModelManager.instance.modelUser.getLv();
                    this.mStatus = (myLv>=max)?0:-1;
                    this.tLock.visible = this.mStatus!=0;
                    this.tStatus.text = (this.mStatus==0)?Tools.getMsgById("_climb14"):Tools.getMsgById("_public47",[max]);//"选择英雄":"需要官邸"+max+"级解锁";
                }
                else{
                    this.mStatus = -1;
                }
            }
        }
    }   
}