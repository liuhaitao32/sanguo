package sg.view.hero
{
	import laya.html.dom.HTMLDivElement;
	import laya.ui.Box;
	import sg.cfg.ConfigServer;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.manager.ModelManager;
	import sg.model.ModelAwaken;
	import sg.model.ModelTalent;
	import ui.hero.heroTalentInfoUI;
    import sg.utils.Tools;
    import sg.model.ModelHero;
	import sg.utils.StringUtil;
	import sg.utils.MusicManager;

	/**
	 * 英雄天赋
	 * @author zhuda
	 */
    public class ViewHeroTalentInfo extends heroTalentInfoUI
    {
		private var mModelHero:ModelHero;
		private var mModelTalent:ModelTalent;
		private var mModelAwaken:ModelAwaken;
		
        public function ViewHeroTalentInfo()
        {
			//this.hTalent.style.fontSize = 20;
			//this.hTalent.style.leading = 8;
			//this.hTalent.style.color = '#FFFFFF';
			//this.boxTalent.y = 0;
            this.tInfoName.text = Tools.getMsgById("_hero23");
			this.mBg.alpha = 0;
        }
        override public function initData():void{
			this.mModelHero = this.currArg as ModelHero;
			this.mModelTalent = ModelTalent.getModel(this.mModelHero.id);
			
			this.tName.text = this.mModelHero.getName();
			Tools.textLayout2(this.tName,this.img_name,300,160);
			
			var info:String;
			var color:String;
			var sumY:Number = 70;
			if (this.mModelTalent){
				//有天赋
				this.tTalent.visible = true;
				this.boxTalent.visible = true;
				//this.imgLine.visible = true;
				
				this.tTalent.y = sumY;
				info = this.mModelTalent.getName();
				this.tTalent.text = Tools.getMsgById("_hero32", [info]);
				sumY += this.tTalent.height + 15;
				
				this.boxTalent.y = sumY;
				this.initTalentBox();
				sumY += this.boxTalent.height;
				//this.hTalent.y = sumY;
				//info = this.mModelTalent.getInfoHtml();
				//info = StringUtil.substituteWithLineAndColor(info, "#FCAA44", "#ffffff");
				//this.hTalent.innerHTML = info;
				//sumY += this.hTalent.contextHeight + 20;

				//如果是传奇天赋，特殊显示
				var arr:Array = ConfigFight.legendTalent[this.mModelHero.id]?ConfigFight.legendTalent[this.mModelHero.id]:ConfigFight.legendTalentFight[this.mModelHero.id];
				if (arr){
					this.boxLegend.y = sumY;
					this.boxLegend.visible = true;
					this.initLegendBox();
					sumY += this.boxLegend.height;
				}
				else
				{
					this.boxLegend.visible = false;
				}
				sumY += 10;
			}
			else{
				//无天赋
				this.tTalent.visible = false;
				this.boxTalent.visible = false;
				this.boxLegend.visible = false;
				//this.imgLine.visible = false;
			}
			sumY += this.initAwakenBox(sumY);
			
			this.imgLine.y = sumY;
			sumY += 20;
			
			MusicManager.playSoundHero(this.mModelHero.id);
			this.tInfoName.y = sumY;
			sumY += this.tInfoName.height + 15;
			
			this.tInfo.y = sumY;
			info = Tools.getMsgById(this.mModelHero.info);
			this.tInfo.text = info;
			this.tInfo.height = this.tInfo.textField.textHeight;
			sumY += this.tInfo.height + 20;

			this.mBox.height = sumY;
			var showHeight:Number = Laya.stage.height - 105 *2;
			if (showHeight < sumY) {
				mBox.centerY = 0;
			} else {
				var centerY:Number = (showHeight - sumY) * -0.5;
				centerY = centerY < -100 ? -100 : centerY;
				mBox.centerY = centerY;
			}
        }      
		
		public function initTalentBox():void{
			this.boxTalent.destroyChildren();

			var color0:String = '#EEEEEE';
			var color1:String = '#EEDDAA';
			var color2:String = '#FCAA44';
			var color3:String = '#88AACC';
			var sign:String = Tools.getMsgById('_hero33');
			var info:String = this.mModelTalent.getInfoHtml();
			var infoArr:Array = info.split('；');
			var len:int = infoArr.length;
			var sumY:Number = 0;
			var tempY:Number = 0;
			
			for (var i:int = 0; i < len; i++) 
			{
				info = infoArr[i];
				if (!info)
					continue;
					
				var html:HTMLDivElement = new HTMLDivElement;
				html.width = this.boxTalent.width;
				
				if (info.substr(0, 1) == '_'){
					//属于子项目
					info = info.substr(1);
					info = StringUtil.repeat('&nbsp;', 4) + StringUtil.substituteWithColor(info, color2, color3);
					tempY = 5;
					html.style.fontSize = 18;
				}
				else{
					info = StringUtil.substituteWithColor(sign + info, color2, (i % 2 == 0)?color0:color1);
					tempY = 15;
					html.style.fontSize = 20;
				}
				//html.style.fontSize = 20;
				html.style.leading = 8;

				html.innerHTML = info;
				html.y = sumY;
				this.boxTalent.addChild(html);
				
				sumY += html.contextHeight + tempY;
			}
			this.boxTalent.height = sumY;
		}
		
		public function initAwakenBox(yy:int):int{
			this.boxAwaken.visible = false;
			this.boxAwakenInfo.destroyChildren();
			
			
			if (this.mModelHero.getAwaken()){
				this.mModelAwaken = ModelAwaken.getModel(this.mModelHero.id);
				if (this.mModelAwaken){
					//有觉醒天赋
					
					var color0:String = '#FF9955';
					//var color1:String = '#EEDDAA';
					var color2:String = '#FCAA44';
					var color3:String = '#88AACC';
					var sign:String = Tools.getMsgById('_hero33');
					var info:String = this.mModelAwaken.getInfoHtml();
					var infoArr:Array = info.split('；');
					var len:int = infoArr.length;
					var sumY:Number = 0;
					var tempY:Number = 0;
					
					for (var i:int = 0; i < len; i++) 
					{
						info = infoArr[i];
						if (!info)
							continue;
							
						var html:HTMLDivElement = new HTMLDivElement;
						html.width = this.boxAwakenInfo.width;
						
						if (info.substr(0, 1) == '_'){
							//属于子项目
							info = info.substr(1);
							info = StringUtil.repeat('&nbsp;', 4) + StringUtil.substituteWithColor(info, color2, color3);
							tempY = 5;
							html.style.fontSize = 18;
						}
						else{
							info = StringUtil.substituteWithColor(sign + info, color2, color0);
							tempY = 15;
							html.style.fontSize = 20;
						}
						//html.style.fontSize = 20;
						html.style.leading = 8;

						html.innerHTML = info;
						html.y = sumY;
						this.boxAwakenInfo.addChild(html);
						
						sumY += html.contextHeight + tempY;
					}
					this.tAwaken.text = Tools.getMsgById('_hero38');
					this.boxAwakenInfo.height = sumY;
					
					this.boxAwaken.visible = true;
					this.boxAwaken.y = yy;
					
					sumY = sumY + this.boxAwakenInfo.y + 10;
					this.boxAwaken.height = sumY + this.boxAwakenInfo.y;
					
					return sumY;
				}
			}
			return 0;
		}
		
		public function initLegendBox():void{
			var mh:ModelHero = ModelManager.instance.modelGame.getModelHero(this.mModelTalent.id);
			var starLv:int = mh.getStar();
			var starLvMax:int = ModelHero.getStarMax();
			var sumY:Number = 25;
			
			var info:String = Tools.getMsgById(this.mModelTalent.getLegendTalent(), [this.mModelTalent.getLegendValue(starLv)]);
			this.tLegend.text = Tools.getMsgById('_hero31');
			this.tLegend.y = sumY;
			sumY += this.tLegend.height + 15;
			
			this.tLegend1.text = info;
			this.tLegend1.y = sumY;
			this.tLegend1.height = this.tLegend1.textField.height;
			sumY += this.tLegend1.height + 10;
			
			if (starLv < starLvMax){
				this.tLegend2.visible = true;
				this.tLegend2.text = Tools.getMsgById('_hero34', [this.mModelTalent.getLegendValue(starLv + 1)]);
				this.tLegend2.y = sumY;
				sumY += this.tLegend2.height + 5;
				this.tLegend3.text = Tools.getMsgById('_hero35', [this.mModelTalent.getLegendValue(starLvMax)]);
			}
			else{
				this.tLegend2.visible = false;
				this.tLegend3.text = Tools.getMsgById('skill_lv_max');
			}
			this.tLegend3.y = sumY;
			sumY += this.tLegend3.height + 10;
			
			this.tLegend4.text = Tools.getMsgById('_hero36');
			this.tLegend4.y = sumY;
			this.tLegend4.height = this.tLegend4.textField.height;
			sumY += this.tLegend4.height + 10;
			
			this.boxLegend.height = sumY;
		}
    }
}