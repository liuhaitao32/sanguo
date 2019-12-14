package sg.view.hero
{
    import ui.hero.heroSkillUI;
    import sg.model.ModelHero;
    import laya.utils.Handler;
    import sg.manager.ModelManager;
    import sg.cfg.ConfigServer;
    import laya.maths.MathUtil;
    import sg.model.ModelSkill;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import laya.events.Event;
    import sg.model.ModelGame;
    import sg.utils.Tools;
    import sg.model.ModelUser;

    public class ViewHeroSkill extends heroSkillUI{
        private var mModel:ModelHero;
        private var mTabSelectIndex:int = -1;
		static public var lastTabSelectIndex:int = -1;
		
        public function ViewHeroSkill(md:ModelHero):void{
            this.mModel = md as ModelHero;
            this.mModel.on(ModelGame.EVENT_HERO_SKILL_CHANGE,this,this.event_hero_skill_change);
            ModelManager.instance.modelUser.on(ModelUser.EVENT_UPDATE_SKILL_NUM,this,update_skill_num);
        }

        private function update_skill_num():void{
            this.updateTabLabels();
            this.list.refresh();
        }

        private function event_hero_skill_change():void{
			this.updateTabLabels();
            this.tab.selectedIndex = -1;
            this.tab.selectedIndex = this.mTabSelectIndex;
        }
        override public function init():void{
            this.tab.selectHandler = new Handler(this, this.tab_select);
			
			this.updateTabLabels();
            //this.tab.labels = '已学技能,'
			//+Tools.getMsgById("_hero1")+str1+","
            //+ModelHero.army_type_name[this.mModel.army[0]]+str1+","
            //+ModelHero.army_type_name[this.mModel.army[1]]+str1+","
            //+ModelHero.army_type_name[5]+str1+","
            //+ModelHero.army_type_name[6]+str1+"";
            //
            this.list.itemRender = ItemHeroSkill;
            this.list.scrollBar.hide = true;
            this.list.renderHandler = new Handler(this,this.list_render);
            //
			//this.event_hero_skill_change();
			//if (this.mTabSelectIndex < 0)
				//this.mTabSelectIndex = 0;
			this.tab.selectedIndex = lastTabSelectIndex;
            //this.tab.selectedIndex = this.getHMDselectIndex();
        }
		
		public function updateTabLabels():void{
            var str1:String = Tools.getMsgById("_public2");
			var labelArr:Array = [Tools.getMsgById('skill_have_learned')];
			labelArr.push(Tools.getMsgById("_hero1") + str1 + this.getCurrAndLimitStr(4));
			labelArr.push(ModelHero.army_type_name[this.mModel.army[0]] + str1 + this.getCurrAndLimitStr(this.mModel.army[0]));
			labelArr.push(ModelHero.army_type_name[this.mModel.army[1]] + str1 + this.getCurrAndLimitStr(this.mModel.army[1]));
			labelArr.push(ModelHero.army_type_name[5] + str1 + this.getCurrAndLimitStr(5));
			labelArr.push(ModelHero.army_type_name[6] + str1 + this.getCurrAndLimitStr(6));
			this.tab.labels = labelArr.join(',');
			var types:Array = [ -1, 4, this.mModel.army[0], this.mModel.army[1], 5, 6];			
			for (var i:int = 0, len:int = labelArr.length; i < len; i++) {
				ModelGame.redCheckOnce(this.tab.getChildByName("item" + i), this.mModel.checkSkillWill2(types[i]));
			}
        }
		
        private function setHMDselectIndex(index:int):void{
            if(this.mModel.isMine() && index>-1){
                this.mModel.skillSelectIndexDic = index;
            }
        }
        private function getHMDselectIndex():int
        {
            if(this.mModel.isMine()){
                return (this.mModel.skillSelectIndexDic<0)?0:this.mModel.skillSelectIndexDic;
            }
            return (this.tab.selectedIndex>=0)?this.tab.selectedIndex:0;
        }
        private function tab_select(index:int):void{
            if(index>-1){
                this.mTabSelectIndex = index;
				lastTabSelectIndex = index;
                this.setHMDselectIndex(index);
                this.setUI();
            }
        }
        private function list_render(item:ItemHeroSkill,index:int):void{
            var skill:ModelSkill = this.list.array[index];
            item.initData(this.mModel,skill);
            item.off(Event.CLICK,item,item.click);
            item.on(Event.CLICK,item,item.click);
        }
		private function getCurrAndLimitStr(type:int):String{
			return '\n' + this.mModel.getMySkillsNum(type) + "/" + this.mModel.getMySkillLimit(type);
		}
		
        private function setUI():void{
            var type:int = this.getCfgType();
            //
            // trace("英雄技能类型",type);
            //this.tSkill.text = Tools.getMsgById("_hero22")+this.mModel.getMySkillsNum(type)+"/"+this.mModel.getMySkillLimit(type);//当前英雄技能
            this.tSkill.visible = false;
            //
            var smd:ModelSkill;

			var skills:Object;
			var skillArr:Array = [];
			var skill:Object;
			var lv:Number = 0;
			var key:String;
			var mySkills:Object = mModel.getMySkills();
			if (type < 0){
				//已学技能标签
				this.tSkillNext.visible = false;
				skills = mySkills;
			}
			else{
				//特定类别标签
				this.tSkillNext.visible = true;
				this.tSkillNext.text = this.mModel.getMySkillNextString(type);
				skills = {};
				//再按照开服时间屏蔽一些技能
				
				var temp:Object = ConfigServer.skill_type_dic[type];
				for (key in temp){
					smd = ModelSkill.getModel(key);
					if (smd.isOpenState){
						skill = temp[key];
						skills[key] = skill;
					}
					
					//if(!mySkills[key]){
						//if (skill.hasOwnProperty('state')){
							//var state:int = skill.state;
							//var day:int = ModelManager.instance.modelUser.getGameDate();
							//if (state > 1 && day < state){
								//continue;
							//}
						//}
						//if (skill.hasOwnProperty('open_date')){
							//var open_date:Object = skill.open_date;
							//if (ConfigServer.getServerTimer() < Tools.getTimeStamp(open_date)){
								//continue;
							//}
						//}
					//}
					//skills[key] = skill;
				}
				//skills = ConfigServer.skill_type_dic[type];
			}
			skillArr = ModelSkill.getSortSkillArr(skills,this.mModel);
			
			this.list.array = skillArr;
        }
			
		
		
        override public function clear():void{
            this.mModel.off(ModelGame.EVENT_HERO_SKILL_CHANGE,this,this.event_hero_skill_change);
            ModelManager.instance.modelUser.on(ModelUser.EVENT_UPDATE_SKILL_NUM,this,update_skill_num);
            // this.tab.selectHandler.clear();
            this.tab.destroy(true);
            //
            this.list.destroy(true);
        }
        private function getCfgType():int{
            var type:int = -1;
			if(this.tab.selectedIndex==0){
                type = -1;
            }
            else if(this.tab.selectedIndex==1){
                type = 4;
            }
            else if(this.tab.selectedIndex==2){
                type = this.mModel.army[0];
            }
            else if(this.tab.selectedIndex==3){
                type = this.mModel.army[1];
            }
            else if(this.tab.selectedIndex==4){
                type = 5;
            }
            else if(this.tab.selectedIndex==5){
                type = 6;
            }
            return type;
        }
    }
}