package sg.view.hero
{
    import ui.hero.commissionBaseUI;
    import sg.model.ModelHero;
    import sg.manager.ModelManager;
    import sg.manager.AssetsManager;
    import sg.utils.Tools;
    import sg.model.ModelSkill;
    import sg.cfg.ConfigServer;

    public class CommissionBase extends commissionBaseUI
    {
        public static const STATE_NULL:String = 'STATE_NULL';
        public static const STATE_CURRENT:String = 'state_current';
        public static const STATE_IN_USE:String = 'state_in_use';

        private var mModel:ModelHero;
        private var hid:String;
        private var mc:ViewHeroCommission;
        private var fb:int;
        public function CommissionBase() {
        }

        override public function set dataSource(source:*):void {
            if (!source) return;
			this._dataSource = source;
            hid = source.id;
            fb = source.fb;
            mc = source.panel;
            mModel = source.model;
            switch(source.state) {
                case STATE_NULL:
                    box_tips.visible = false;
                    break;
                case STATE_IN_USE:
                    txt_tips.text = Tools.getMsgById('_jia0080');
                    txt_tips.color = '#ffea7f'
                    img_tips.skin = AssetsManager.getAssetsUI('bar_17_1.png');
                    box_tips.visible = true;
                    break;
                case STATE_CURRENT:
                    txt_tips.text = Tools.getMsgById('_public207');
                    txt_tips.color = '#fff'
                    img_tips.skin = AssetsManager.getAssetsUI('bar_17_2.png');
                    box_tips.visible = true;
                    break;
            }
            var system_simple:Object = ConfigServer.system_simple; // 系统杂项
            var skill_hero:Array = system_simple['adjutant_skill_hero']; //主动技能类型
            var skill_army:Array = system_simple['adjutant_skill_army']; 
            var data:Object = ModelManager.instance.modelUser.hero[hid];
            var md:ModelHero = ModelManager.instance.modelGame.getModelHero(hid);
            heroIcon.setHeroIcon(md.getHeadId(),true, md.getStarGradeColor());
            txt_name.text = md.getName();
			this.comPower.setNum(data['power']);
            //txt_power.text = data['power'];
			this.heroLv.setNum(data['lv']);
            //txt_level.text = data['lv'];
            icon_type.setHeroType(md.getType(true));
            
            var armyType:int = mModel.army[this.fb];
            var skillId_0:String = skill_hero[md.type][this.fb];
            var skillId_1:String = skill_army[armyType];
			var ms_0:ModelSkill = ModelSkill.getModel(skillId_0);
			var ms_1:ModelSkill = ModelSkill.getModel(skillId_1);
            var skillHeroNum:int = mModel.getSkillHeroNum(hid, fb);
            var skillArmyNum:int = mModel.getSkillArmyNum(hid, fb);

            // 副将主动技能
			skillName_0.setSkillItem(ms_0, skillHeroNum);
			skillName_0.setSkillBgColor(ms_0.getColor(skillHeroNum), true);
			
            // 副将兵种技能
			skillName_1.setSkillItem(ms_1, skillArmyNum);
			skillName_1.setSkillBgColor(ms_1.getColor(skillArmyNum), false);
            var selectedItem:Object = mc.list.selectedItem;
            img_choose.visible = false;
            if (selectedItem && (selectedItem['id'] === hid)) {
                img_choose.visible = true;
                if (selectedItem.state === STATE_CURRENT) {
                    mc.btn.label = Tools.getMsgById('_jia0075');
                }
                else {
                    mc.btn.label = Tools.getMsgById('_jia0074');
                }
            }

        }
    }
}