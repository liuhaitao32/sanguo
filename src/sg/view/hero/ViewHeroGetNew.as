package sg.view.hero
{
	import laya.display.Animation;
	import laya.particle.Particle2D;
	import sg.model.ModelBuiding;
	import sg.model.ModelTalent;
    import ui.hero.heroGetNewUI;
    import sg.model.ModelHero;
    import sg.model.ModelPrepare;
    import sg.manager.EffectManager;
    import laya.ui.Box;
    import sg.manager.ModelManager;
    import sg.model.ModelSkill;
    import sg.utils.Tools;
    import ui.com.skillItemUI;
    import laya.display.Animation;
    import laya.events.Event;
    import laya.utils.Tween;
    import laya.utils.Ease;
    import sg.utils.MusicManager;
    import sg.manager.LoadeManager;
    import sg.manager.AssetsManager;

    public class ViewHeroGetNew extends heroGetNewUI{
        private var mModel:ModelHero;
        //
        //private var mBoxSkill:Box;
		//private var mParticle:Particle2D;
        //
        private var mClipAni:Animation;
        //
        public function ViewHeroGetNew(){
            //
            this.test_clip_vis = false;
			this.guanbi.text = Tools.getMsgById("_public114");
            //
            //this.mBoxSkill = new Box();
            //this.mInfo.addChild(this.mBoxSkill);
        }
        override public function initData():void{
            this.mModel = ModelManager.instance.modelGame.getModelHero(this.currArg);
            //
            this.mFuncImg.visible = false;
            this.mFuncImg.y = this.height*0.5;
            //
            this.setUI();
        }
        override public function onAdded():void{
            //
            this.mClipAni = EffectManager.loadAnimation("glow032","",2);
            this.mClipAni.on(Event.COMPLETE,this,this.onClipAni);
            this.mClipAni.x = (this.width - this.mClipAni.width)/2;
            this.mClipAni.y = (this.height - this.mClipAni.height)/2;
            //
            this.addChild(this.mClipAni);
            //
            this.timer.once(900,this,this.clip0);
            MusicManager.playSoundHero(mModel.id);
        }
        private function clip0():void
        {
            this.mFuncImg.visible = true;
            this.mFuncImg.scale(0.8,0.8);
            Tween.to(this.mFuncImg,{scaleX:1,scaleY:1},200,Ease.backOut);
                       
        }
        override public function onRemoved():void{
            this.timer.clear(this,this.clip0);
            if(this.mFuncImg){
                Tween.clearTween(this.mFuncImg);
            }
            this.onClipAni();
            ViewAwakenHero.recruitOrAwaken(mModel.id);
        }
        private function onClipAni():void
        {
            if(this.mClipAni){
                this.mClipAni.destroy(true);
            }
            this.mClipAni = null;
            //
        }
        private function setUI():void{
            var hmp:ModelPrepare = this.mModel.getPrepare(true);
            //
            this.tName.text = this.mModel.getName();
            //
            //
            this.heroType.setHeroType(this.mModel.getType(true));
            this.heroType.x = this.tName.x + this.tName.displayWidth + 10;
            //
            this.imgRarity.skin = this.mModel.getRaritySkin();
            //
            this.heroStr.setHeroProp4(Tools.getMsgById("info_str"),this.mModel.getStr(hmp));
            this.heroInt.setHeroProp4(Tools.getMsgById("info_agi"),this.mModel.getInt(hmp));
            this.heroCha.setHeroProp4(Tools.getMsgById("info_cha"),this.mModel.getCha(hmp));
            this.heroLead.setHeroProp4(Tools.getMsgById("info_lead"),this.mModel.getLead(hmp));
            //
            this.army0.setArmyIcon(this.mModel.army[0], ModelBuiding.getArmyCurrGradeByType(this.mModel.army[0]));
            this.army1.setArmyIcon(this.mModel.army[1], ModelBuiding.getArmyCurrGradeByType(this.mModel.army[1]));
            //
            this.heroIcon.setHeroIcon(this.mModel.id, false);
			//英雄背景粒子
			//if (this.mParticle){
				//this.mParticle.destroy();
			//}
			//var ani:Animation = EffectManager.loadAnimation('glow008bg', '', 1);
			//ani.interval = 10;
			//this.heroIcon.addChildAt(ani, 0);
			//ani.pos(320, 0);
			//this.mParticle = EffectManager.loadParticleByHeroRarity(this.mModel.rarity, this.heroIcon.getImgPanel(), 5);
			
             if(this.mModel.rarity==4){
                this.heroIconBg.visible=false;
                this.imgSuper.visible=true;
                LoadeManager.loadTemp(this.imgSuper,AssetsManager.getAssetsAD(ModelHero.super_hero_bg));
                EffectManager.changeSprColor(this.imgSuper,this.mModel.getStarGradeColor(),false);
            }else{
                this.heroIconBg.visible=true;
                this.imgSuper.visible=false;
                EffectManager.changeSprColor(this.heroIconBg,this.mModel.getStarGradeColor(),false);
            }

            //
            this.setSkill();
			this.setTalent();
        }
        private function setSkill():void{
            this.boxSkill.destroyChildren();
            //
            var item:skillItemUI;
            var smd:ModelSkill;
			var arr:Array = ModelSkill.getSortSkillArr(this.mModel.skill,this.mModel);
			var len:int = arr.length;
			
            for (var i:int = 0; i < len;i++)
            {
                smd = arr[i];
                item = new skillItemUI();
                // item.nameLabel.text = smd.getName();
                // item.lvLabel.text = smd.getLv(this.mModel)+"";
                // item.btnCheck.visible = false;
                item.setSkillItem(smd,this.mModel);
                //
                item.x = (i%3)*(item.width + 8);
                item.y = Math.floor(i/3)*(item.height + 10) + 5;
                //
                this.boxSkill.addChild(item);
            }
            this.boxSkill.centerX = 0;
            this.boxSkill.visible = (len>0);
            this.tInfo.text = Tools.getMsgById(this.mModel.info);
        }
		
		private function setTalent():void{
			//更新天赋显示
            this.comTalent.setTalentIcon(this.mModel.id);
            /*
			var mt:ModelTalent = ModelTalent.getModel(this.mModel.id);
			if (mt){
				this.boxTalent.visible = true;
				this.tTalent.text = mt.getName();
			}else{
				this.boxTalent.visible = false;
			}*/
		}
    }   
}