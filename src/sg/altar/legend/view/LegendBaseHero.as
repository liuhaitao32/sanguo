package sg.altar.legend.view
{
    import ui.fight.legendBase_heroUI;
    import sg.manager.LoadeManager;
    import sg.manager.AssetsManager;
    import sg.model.ModelHero;
    import sg.manager.EffectManager;
    import laya.events.Event;
    import sg.utils.StringUtil;
    import sg.utils.Tools;
    import sg.manager.ViewManager;
    import sg.model.ModelPrepare;
    import sg.cfg.ConfigColor;
    import laya.particle.Particle2D;
    import sg.manager.ModelManager;
    import sg.model.ModelBuiding;
    import sg.view.com.ComPayType;
    import sg.model.ModelTalent;
    import sg.utils.ObjectUtil;

    public class LegendBaseHero extends legendBase_heroUI
    {
        private var mModel:ModelHero;
		private var mParticles:Array;
        public function LegendBaseHero() {
			box_prop.on(Event.CLICK,this,this._click_prop);
        }

        public function setData(md:ModelHero):void {
            mModel = md;
            heroIcon.setHeroIcon(mModel.id, false);
            LoadeManager.loadTemp(imgSuper, AssetsManager.getAssetsAD(ModelHero.super_hero_bg));
            EffectManager.changeSprColor(imgSuper, mModel.getStarGradeColor(), false);

            heroIcon.mParticlesBottom.visible = heroIcon.mParticles.visible = true;
            heroIcon.mParticles.removeChildren();
            heroIcon.mParticlesBottom.removeChildren();
            var particle_config:Array = particle_config = ConfigColor.PARTICLE_CONFIG_BY_HERO_RARITY[md.rarity];
            // 修改粒子位置并加载粒子特效
            particle_config = ObjectUtil.clone(particle_config, true) as Array;
            particle_config.forEach(function(arr:Array):void {
                arr[3] += this.x;
                arr[4] += this.y;
            }, this);
            mParticles = EffectManager.loadParticleByArr(particle_config, heroIcon.mParticles, heroIcon.mParticlesBottom);

            heroType.setHeroType(mModel.getType(true));
            imgRarity.skin = mModel.getRaritySkin();
            txt_name.text = mModel.getName();
			txt_name.color = EffectManager.getFontColor(mModel.getStarGradeColor());
            
            var hmp:ModelPrepare = this.mModel.getPrepare(true);
            heroStr.setHeroProp4(Tools.getMsgById("info_str"), mModel.getStr(hmp));//武力
            heroInt.setHeroProp4(Tools.getMsgById("info_agi"), mModel.getInt(hmp));//智力
            heroCha.setHeroProp4(Tools.getMsgById("info_cha"), mModel.getCha(hmp));//魅力
            heroLead.setHeroProp4(Tools.getMsgById("info_lead"), mModel.getLead(hmp));//统帅
            
            var mModelTalent:ModelTalent = ModelTalent.getModel(mModel.id);
            txt_legend.text = Tools.getMsgById('_hero31');
			txt_legend_info.text = Tools.getMsgById(mModelTalent.getLegendTalent(), [mModelTalent.getLegendValue(ModelHero.getStarMax())]);
            
            mModel.army.forEach(function(armyType:int, index:int):void {
                (box_army.getChildByName('armyIcon_' + index) as ComPayType).setArmyIcon(armyType, ModelBuiding.getArmyCurrGradeByType(armyType), true);
            }, this);
        }

        private function _click_prop():void {
            //var str:String = StringUtil.substitute('{0}<br/>{1}<br/>{2}<br/>{3}', [
                //Tools.getMsgById('tip_str'),
                //Tools.getMsgById('tip_agi'),
                //Tools.getMsgById('tip_cha'),
                //Tools.getMsgById('tip_lead')
            //]);
            //ViewManager.instance.showTipsPanel(str, 500);
			
			ViewManager.instance.showTipsPanel(Tools.getMsgById('tip_props'), 540);
        }
		
		private function clearParticles():void{
			if (this.mParticles){
				for (var i:int = 0,len:int = this.mParticles.length; i < len; i++) {
					var part:Particle2D = this.mParticles[i];
					part.stop();
				}
			}
            this.mParticles = null;   	
		}
    }
}