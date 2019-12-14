package sg.view.hero
{
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.logic.utils.FightUtils;
    import ui.hero.heroAdjutantArmyUI;
    import sg.model.ModelHero;
    import sg.cfg.ConfigServer;
    import sg.model.ModelSkill;
    import sg.utils.Tools;
    import sg.manager.ModelManager;
    import laya.events.Event;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import laya.utils.Handler;
    import sg.net.NetPackage;
    import sg.model.ModelGame;
    import sg.manager.AssetsManager;
    import sg.utils.ObjectUtil;
    import sg.model.ModelBuiding;
    import sg.manager.EffectManager;
    import laya.display.Sprite;
    import sg.utils.StringUtil;
    import sg.model.ModelEquip;
    import sg.cfg.HelpConfig;
    import laya.ui.Image;

    public class ViewAdjutantArmy extends heroAdjutantArmyUI
    {
        private var mModel:ModelHero;
        private var fb:int = 0;
        private var hid:String;
        private var mArmyItems:Array;
        private var posStr:String;
        private var armyStr:String;
        private var skill_hero:Array;
        private var skill_army:Array;
        private var lock:Boolean = false;
        private var armyId:String;
        public function ViewAdjutantArmy(fbType:int):void{
            this.fb = fbType;
            var system_simple:Object = ConfigServer.system_simple; // 系统杂项
            skill_hero = system_simple['adjutant_skill_hero']; //主动技能类型
            skill_army = system_simple['adjutant_skill_army']; //兵种技能

            posStr = ModelHero.army_seat_name[this.fb];
            heroIcon.on(Event.CLICK, this, this._onClickIcon);
            btn_go.label = Tools.getMsgById('_country7');
            btn_go.on(Event.CLICK, this, this._onClickGo);
        }

        public function setModel(heroModel:ModelHero):void {
            var system_simple:Object = ConfigServer.system_simple;
            var modelGame:ModelGame = ModelManager.instance.modelGame;
            this.mModel = heroModel;
            armyStr = ModelHero.army_type_name[mModel.army[this.fb]];
            txt_title.text = posStr + armyStr + Tools.getMsgById('_jia0076'); // 前军弓兵副将
            this.setArmyImg();
            this.hid = mModel.getAdjutant()[this.fb];
            var armyType:int = mModel.army[this.fb];
            typeIcon.setArmyIcon(armyType, ModelBuiding.getArmyCurrGradeByType(armyType));
            if (mModel.getStar() < system_simple.adjutant_level) {
                this._initNull();
                lock = true;
                return;
            }
            img_lock.visible = false;
            if (hid === null) {
                this._initNull();
                return;
            }
            var md:ModelHero = modelGame.getModelHero(hid);
            txt_hero.text = md.getName(); // 英雄名字
            var skillHeroNum:int = mModel.getSkillHeroNum(hid, fb);
            var skillArmyNum:int = mModel.getSkillArmyNum(hid, fb);
			var skillId_0:String = skill_hero[md.type][this.fb];
            var skillId_1:String = skill_army[armyType];
			var ms_0:ModelSkill = ModelSkill.getModel(skillId_0);
			var ms_1:ModelSkill = ModelSkill.getModel(skillId_1);

            // 副将主动技能
			skillName_0.setSkillLineVisible(true);
			skillName_0.setSkillItem(ms_0, skillHeroNum);
			skillName_0.setSkillBgColor(ms_0.getColor(skillHeroNum), true);
			
			
            // 副将兵种技能
			skillName_1.setSkillLineVisible(true);
			skillName_1.setSkillItem(ms_1, skillArmyNum);
			skillName_1.setSkillBgColor(ms_1.getColor(skillArmyNum), false);
			
			
            skillName_0.on(Event.CLICK, this, this._showSkill, [skillId_0,skillHeroNum,armyType,md]);
            skillName_1.on(Event.CLICK, this, this._showSkill, [skillId_1,skillArmyNum,armyType,md]);
            heroIcon.setHeroIcon(md.getHeadId(),true, md.getStarGradeColor());
            img_add.visible = false;
            ModelGame.redCheckOnce(heroIcon, false);
			
			var army_values_0:Array = ms_0.getAdjutantArmyValues(armyType, skillHeroNum);
			var army_values_1:Array = ms_1.getAdjutantArmyValues(armyType, skillArmyNum);
			
            // TODO 兵种属性加成
            txt_attack.text = armyStr + ModelHero.army_prop_name[0] +" + " + (army_values_0[0]+army_values_1[0]); // 弓兵攻击+5000
            txt_defense.text = armyStr + ModelHero.army_prop_name[1] +" + " + (army_values_0[1] + army_values_1[1]); // 弓兵防御+5000
			

            //副将技评分威力
            var score:int = md.getEquipScore();
			this.txt_score_equip.text = Tools.getMsgById("_jia0132",[score]);
			this.txt_ratio_hero.text = Tools.getMsgById("_jia0133", [Tools.percentFormat(FightUtils.getAdjutantEquipDmgFinal(score) / ConfigFight.ratePoint, 0), ms_0.getName()]);
			this.btn_go.label = txt_hero.text;
			this.btn_go.visible = true;
        }

        private function setArmyImg():void{
            var len:int = 4;
            var a:int = mModel.army[fb];
            var b:int = ModelBuiding.getArmyCurrGradeByType(a);
            var tempId:String = "army" + a +""+ b;
            if (armyId !== tempId) {
                armyId = tempId;
                imgBox.destroyChildren();
                imgBox.visible = true;
                var img:*;
                if(HelpConfig.type_app == HelpConfig.TYPE_WW){
                    img = new Image();
                    img.skin = AssetsManager.getAssetsArmy(armyId);
                    img.pos(0, 0);
                    img.width = img.height = imgBox.width;
                    this.imgBox.addChild(img);
                }else{
                    img = EffectManager.loadArmysIcon(armyId);
                    img.pos(imgBox.width * 0.5, imgBox.height * 0.5);
                    imgBox.addChild(img);
                }
                

                //var img:Sprite = EffectManager.loadArmysIcon(armyId);
                //img.pos(imgBox.width * 0.5, imgBox.height * 0.5)
                //imgBox.addChild(img);
            }
        }

        private function _initNull():void
        {
            txt_hero.text = Tools.getMsgById('_jia0078'); // 英雄名字
            
            var armyType:int = mModel.army[this.fb];
			var skillId_0:String = skill_hero[mModel.type][this.fb];
            var skillId_1:String = skill_army[armyType];
			var ms_0:ModelSkill = ModelSkill.getModel(skillId_0);
			var ms_1:ModelSkill = ModelSkill.getModel(skillId_1);

            // 副将主动技能
            skillName_0.setSkillBgColor(-1, true);
            skillName_0.setSkillLineVisible(false);
			skillName_0.setSkillItem(ms_0);
            skillName_0.getChildByName('nameLabel')['text'] = Tools.getMsgById('_jia0081');
            skillName_0.offAll(Event.CLICK);
			
            // 副将兵种技能
            skillName_1.setSkillBgColor(-1, true);
            skillName_1.setSkillLineVisible(false);
			skillName_1.setSkillItem(ms_1);
            skillName_1.getChildByName('nameLabel')['text'] = Tools.getMsgById('_jia0087');
            skillName_1.offAll(Event.CLICK);
            
            txt_attack.text = armyStr + ModelHero.army_prop_name[0] +" + " + 0; // 弓兵攻击+0
            txt_defense.text = armyStr + ModelHero.army_prop_name[1] +" + " + 0; // 弓兵防御+0
			
			//副将技评分威力
			this.txt_score_equip.text = Tools.getMsgById("_jia0132", [0]);
			this.txt_ratio_hero.text = Tools.getMsgById("_jia0134");
			this.btn_go.visible = false;
			
            var flag:Boolean = mModel.checkAdjutantCanInstallByType(fb);
            heroIcon.gray = !flag;
            img_add.visible = flag;
            heroIcon.setHeroIcon('');
            ModelGame.redCheckOnce(heroIcon, flag);
        }

        private function _onClickIcon(event:Event):void {
            if(lock) {
                var colorStr:String = ModelHero.getHeroStarColorName(ConfigServer.system_simple.adjutant_level);
                ViewManager.instance.showTipsTxt(Tools.getMsgById('_jia0090', [colorStr]));
                return;
            } else if (mModel.idle) {
                ViewManager.instance.showView(ConfigClass.VIEW_HERO_COMMISSION, [mModel, fb]);
            } else {
                mModel.busyHint();
            }
        }

        private function _showSkill(skillId:String,skillLv:int,armyType:int,md:ModelHero):void {
            // TODO 展示副将技能
			var ms:ModelSkill = ModelSkill.getModel(skillId);
			ViewManager.instance.showView(ConfigClass.VIEW_SKILL_UPGRADE, [
				md,
				ms,
				[skillLv,armyType],
				true
			]);
        }

        private function _onClickGo(event:Event):void {
            hid && ModelManager.instance.modelGame.event(ModelHero.EVENT_HERO_LOOK_UP, hid);            
        }
    }
}