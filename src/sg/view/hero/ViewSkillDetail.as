package sg.view.hero 
{
	import laya.display.Sprite;
	import laya.maths.MathUtil;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.logic.utils.FightUtils;
	import sg.fight.logic.utils.PassiveStrUtils;
	import sg.model.ModelHero;
	import sg.model.ModelPrepare;
	import sg.model.ModelSkill;
	import sg.utils.StringUtil;
	import sg.utils.Tools;
	import ui.hero.heroSkillDetailUI;
	/**
	 * 技能面板详细信息
	 * @author zhuda
	 */
	public class ViewSkillDetail extends heroSkillDetailUI
	{
		public var mModel:ModelHero;
		public var mModelSkill:ModelSkill;
		
		public var maxItemSpr:Sprite;
		private var _space:String;
		private var _arr:Array;
		//public var maxItemArr:Array;
		
		public function ViewSkillDetail() 
		{
			var w:Number = 580;//this.measureWidth;
			
			this.panel.vScrollBar.hide = true;
			this.hBaseInfo.style.fontSize = 20;
			this.hBaseInfo.style.leading = 8;
			this.hBaseInfo.width = w;
			this.hBaseNext.style.fontSize = 20;
			this.hBaseNext.style.leading = 8;
			this.hBaseNext.width = w;
			this.hHighInfo.style.fontSize = 20;
			this.hHighInfo.style.leading = 8;
			this.hHighInfo.width = w;
			
			this.txtBaseTitle.text = Tools.getMsgById('skill_base');
			//this.txtHighTitle.text = Tools.getMsgById('skill_high');
			this.txtMaxTitle.text = Tools.getMsgById('skill_max');
			
			
			this._space = StringUtil.repeat('&nbsp;', 18);
			//for (var i:int = 0; i < 18; i++) 
			//{
				//this._space += '&nbsp;';
			//}
			
			this.maxItemSpr = new Sprite();
			this.panel.addChild(this.maxItemSpr);
		}
		public function initData(ms:ModelSkill, mh:ModelHero, arr:Array = null):void{
            this.mModelSkill = ms;
			this.mModel = mh;
			this._arr = arr;
			//trace('本英雄宝物部队加速 ' + mh.getAllEquipArmyGo());

            this.setUI();
        }
		
		
		private function setUI():void{
			var info:String;
			var color:String;
			var sumY:Number = this.txtBaseTitle.y + this.txtBaseTitle.height + 10;
			var highHtmlInfo:String;
			var skillLv:int;
			//var spaceInfo:String;
			
			this.imgLineBase.visible = this.txtHighTitle.visible = this.txtHighUnlock.visible = this.hHighInfo.visible = this.imgLineHigh.visible = this.txtMaxTitle.visible = true;
			
			if (this.mModelSkill.type < 7){
				skillLv = this.mModelSkill.getLv(this.mModel);
				this.txtHighTitle.text = Tools.getMsgById('skill_high');
				if (this.mModelSkill.type == 5 || this.mModelSkill.type == 6){
					//内政/辅助技能没有进阶效果
					this.imgLineHigh.visible = this.txtMaxTitle.visible = false;
				}
				color = this.mModelSkill.checkHigh(this.mModel)?'#ffffff':'#666666';
				highHtmlInfo = this._space + StringUtil.substituteWithColor(this.mModelSkill.getHighHtml(), '#FFAA33', color);
			}
			else{
				//副将部队效果
				skillLv = this._arr[0];
				this.txtHighTitle.text = Tools.getMsgById('skill_army');
				this.txtHighUnlock.visible = this.imgLineHigh.visible = this.txtMaxTitle.visible = false;
				
				highHtmlInfo = this.getAdjutantArmyHtml();
				//highHtmlInfo = StringUtil.substituteWithColor(this.mModelSkill.getAdjutantArmyHtml(), '#FFAA33', '#ffffff');
			}
			
			this.hBaseInfo.y = sumY;
			info = this.mModelSkill.getInfoHtml(skillLv);
			this.hBaseInfo.innerHTML = StringUtil.substituteWithColor(info, '#FCAA44', '#ffffff');
			sumY += this.hBaseInfo.contextHeight + 20;
			
			this.hBaseNext.y = sumY;
			info = this.mModelSkill.getNextHtml(skillLv);
			this.hBaseNext.innerHTML = StringUtil.substituteWithColor(info, '#33FF33', '#ffffff');
			sumY += this.hBaseNext.contextHeight + 20;
			
			this.imgLineBase.y = sumY;
			sumY += 20;
			///////////////////////////////////////////////////////////////////
			this.txtHighTitle.y = sumY;
			sumY += this.txtBaseTitle.height + 10;
			
			this.txtHighUnlock.y = sumY;
			this.txtHighUnlock.text = this.mModelSkill.getHighUnlockStr();
			
			this.hHighInfo.y = sumY;
			this.hHighInfo.innerHTML = highHtmlInfo;
			sumY += this.hHighInfo.contextHeight + 20;
			
			this.imgLineHigh.y = sumY;
			sumY += 20;
			///////////////////////////////////////////////////////////////////
			this.txtMaxTitle.y = sumY;
			sumY += this.txtBaseTitle.height + 10;
			
			this.maxItemSpr.destroyChildren();
			this.maxItemSpr.height = 0;
			//加上15级以后的进阶属性效果
            if (ConfigFight.skillTypeLv.hasOwnProperty(this.mModelSkill.type)) {
				var obj:* = ConfigFight.skillTypeLv[this.mModelSkill.type];
				var temp:Object;
				var arr:Array = [];
				for (var lv:String in obj){
					temp = FightUtils.clone(obj[lv]);
					temp.lv = lv;
					arr.push(temp);
				}
				arr.sort(MathUtil.sortByKey('lv', false, true));
				 
				var len:int = arr.length;
				//刨除掉和上一项相同的内容
				var last:Array;
				for (var i:int = 0; i < len; i++) 
				{
					temp = arr[i];
					if (!last || last.length == 0){
						last = FightUtils.objectToArray(temp,false);
					}else{
						delete temp[last[0]];
						last = FightUtils.objectToArray(temp,false);
					}
					var item:ViewSkillDetailItem = new ViewSkillDetailItem(temp, this.mModelSkill.type, skillLv >= temp.lv);
					item.y = sumY;
					sumY += 30; 
					//this.maxItemSpr.height += 30;
					this.maxItemSpr.addChild(item);
				}
			}
			this.box.height = sumY;

			this.panel.scrollTo(0, 0);
		}
		

		/**
		 * 得到副将部队效果说明
		 */
		private function getAdjutantArmyHtml():String
        {
			var armyType:int = this._arr[1];
			var currLv:int = this._arr[0];
			var nextLv:int = currLv + 1;
			
			var currArr:Array = this.mModelSkill.getAdjutantArmyValues(armyType, currLv);
			var nextArr:Array = this.mModelSkill.getAdjutantArmyValues(armyType, nextLv);
			
            //var lv:int = this.getHighUnlockLv();
			var info:String;
			var temp:String;
			var currObj:Object = {};
			currObj.cond = ['army[' + Math.floor(armyType / 2) + '].type', '=', armyType];
			var nextObj:Object = FightUtils.clone(currObj);
			
			currObj.rslt = {atk:currArr[0],def:currArr[1]};
			nextObj.rslt = {atk:nextArr[0],def:nextArr[1]};
			
			info = PassiveStrUtils.translatePassiveInfo(currObj, true, false, 2);
			info = StringUtil.substituteWithLineAndColor(info, '#FFAA33', '#ffffff');
			if (nextLv <= this.mModelSkill.getMaxLv()){
				temp = '\n\n' +Tools.getMsgById('skill_next_2') +'\n';
				temp = StringUtil.substituteWithLineAndColor(temp, '#FFAA33', '#999999');
				
				info += temp;
				
				temp = PassiveStrUtils.translatePassiveInfo(nextObj, true, false, 2);
				temp = StringUtil.substituteWithLineAndColor(temp, '#33FF33', '#ffffff');
				
				info += temp;
				//info += '\n\n' +Tools.getMsgById('skill_next_2') +'\n';
				//info += PassiveStrUtils.translatePassiveInfo(nextObj, true, false, true);
			}
			
			//info = StringUtil.substituteWithLineAndColor(info, '#FFAA33', '#ffffff');
			return info;
			
			
			//return '步兵攻击 [+111]\n步兵防御 [+111]\n\n下一级\n步兵攻击 [+113]\n步兵防御 [+113]';
        }
	}

}