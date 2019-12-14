package sg.view.arena
{
	import sg.model.ModelHero;
	import ui.arena.itemArenaheroUI;
	import laya.events.Event;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;
	import sg.utils.Tools;
	import sg.manager.EffectManager;
	import sg.model.ModelPrepare;

	/**
	 * ...
	 * @author
	 */
	public class ItemArenaHero extends itemArenaheroUI{

		private var mIsMe:Boolean = false;
        public var mIndex:int = -1;
        public var mModel:ModelHero;
        public var mId:String = "";
        public var mStatus:int = -1;
        public var mDropItem:ItemArenaHero;

		public function get isMe():Boolean{
			return this.mIsMe;
		}

		public function ItemArenaHero(isMe:Boolean = true){
			mIsMe = isMe;
		}

		private function set dataSource(source:Object):void {
            if (!source)    return;
            source.mine && this.setDataMe(source.index, source.data);
            source.mine || this.setDataOther(source.index, source.data);
        }

		public function setDataMe(index:int,hmd:ModelHero,type:int=0):void{
            this.mIndex = index;
            if(hmd){
                this.mModel = hmd;
            }
            this.armyPro.value = 1;
            this.setUI();
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
            var arr:Array = ModelPrepare.getHpAndHpm(data);
            this.armyPro.value = arr[0]/arr[1];
            this.setUI();
        }
        private function _click(data:*):void{
            this.mModel && ViewManager.instance.showView(ConfigClass.VIEW_HERO_INFO,[data]);
        }

		public function setUI():void{
            if(this.mModel){
                this.mHave.visible = true;
                this.tName.text = this.mModel.getName() + "";
                Tools.textFitFontSize(this.tName);
				this.heroLv.setNum(this.mModel.getLv());

                this.mStatus = 1;
                var mpr:ModelPrepare;

                if(this.mModel.isOther){
                    mpr = this.mModel.getPrepare(true,this.mModel.mData);
                }
                else{
                    mpr = this.mModel.getPrepare(true);
                }
				this.comPower.setNum(this.mModel.getPower());
				var colorType:int = this.mModel.getStarGradeColor(mpr);
                EffectManager.changeSprColor(this.colorBg, colorType, false);
				this.heroStar.setHeroStar(this.mModel.getStar(mpr));
                this.heroIcon.setHeroIcon(this.mModel.getHeadId(),true, colorType);
                this.heroType.setHeroType(this.mModel.getType());
            //
            }
            else{
                this.mHave.visible = false;
                this.mStatus = -1;
            }

        }
	}

}