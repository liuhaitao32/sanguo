package sg.view.hero 
{
	import laya.display.Sprite;
	import laya.maths.MathUtil;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.logic.utils.FightUtils;
	import sg.fight.logic.utils.PassiveStrUtils;
	import sg.model.ModelHero;
	import sg.model.ModelSkill;
	import sg.utils.StringUtil;
	import sg.utils.Tools;
	import ui.hero.heroSkillDetailItemUI;
	/**
	 * 技能面板进阶效果信息
	 * @author zhuda
	 */
	public class ViewSkillDetailItem extends heroSkillDetailItemUI
	{

		public function ViewSkillDetailItem(data:Object, type:int, isOpen:Boolean) 
		{
			this.txtUnlock.text = Tools.getMsgById('skill_unlock', [data.lv]);
			this.hInfo.style.fontSize = 20;
			
			var condStr:String;
			if (type < 4){
				condStr = 'cond_army[' + Math.floor(type / 2) + '].type=' + type;
			}
			else{
				condStr = 'cond';
			}
			
			var info:String = PassiveStrUtils.translateRsltInfo(Tools.getMsgById(condStr),data);
			var color:String = isOpen?"#ffffff":"#666666";
			this.hInfo.innerHTML = StringUtil.substituteWithColor(info, "#FCAA44", color);
			

		}
	}

}