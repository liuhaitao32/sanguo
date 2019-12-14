package sg.view.shop
{
	import laya.html.dom.HTMLDivElement;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.model.ModelPrepare;
	import sg.model.ModelTalent;
	import ui.shop.shopHeroTipsUI;
	import ui.bag.bagItemUI;
	import sg.model.ModelHero;
	import sg.manager.ModelManager;
	import sg.model.ModelSkill;
	import laya.utils.Handler;
	import sg.model.ModelItem;
	import sg.cfg.ConfigServer;
	import ui.com.skillItemUI;
	import sg.view.com.ComPayType;
	import sg.utils.Tools;
	import sg.utils.StringUtil;

	/**
	 * 英雄tips
	 * @author
	 */
	public class ViewShopHeroTips extends shopHeroTipsUI{

		
		public var heroModel:ModelHero;
		public var skillModel:ModelSkill;
		private var mModelTalent:ModelTalent;
		
		public var listData:Array=[];
		public var iconData:Array=[];
		public var curHeroId:String="";
		public var isOther:Boolean = false;
		//技能列数
		public var columnNum:int;
		public function ViewShopHeroTips(){
			
		}

		override public function onAdded():void{
			isOther=false;
			var it:ModelItem;
			if(this.currArg is String){
				var s:String=this.currArg.replace("item","hero");
				heroModel=ModelManager.instance.modelGame.getModelHero(s);
				it=ModelManager.instance.modelProp.getItemProp(this.currArg);
				
			}else{
				var data:Object=this.currArg;
				heroModel = new ModelHero(true);
            	heroModel.initData(data.id,ConfigServer.hero[data.id]);
            	heroModel.setData(data);
				isOther=data.id!=ModelManager.instance.modelUser.mUID;
				it=ModelManager.instance.modelProp.getItemProp(heroModel.id.replace("hero","item"));
			}
			this.boxTop.y=10;
			//this.comHero.setData(it.icon,it.ratity,"","",it.type);
			this.comHero.setData(it.id,-1,-1);
			//(this.icon as bagItemUI).setData("",0,"","");
			this.nameLabel.text = it.getName(true);
			this.nameLabel.color = heroModel.getNameColor();
			//this.typeLabel.text=heroModel.getType();
			this.rarityIcon.skin = heroModel.getRaritySkin();
			this.heroType.setHeroType(heroModel.getType());
			this.armsIcon1.setArmyIcon(heroModel.army[0],0,true);
			this.armsIcon2.setArmyIcon(heroModel.army[1],0,true);
			
			starCom.setHeroStar(heroModel.getStar());
			this.textLabel2.text=Tools.getMsgById("_public18",[""]);// "拥有:";

			if(heroModel.getStar()==ModelHero.getStarMax()){
				this.numLabel.text=heroModel.getMyItemNum()+"/-";	
			}else{
				this.numLabel.text=heroModel.getMyItemNum()+"/"+heroModel.getStarUpItemNum();
			}
			if(isOther)
				this.textLabel2.text = this.numLabel.text = "";
			
			var mp:ModelPrepare = heroModel.getPrepare(true);
				
			this.attr1.text=ModelHero.hero_4d_name[0]+":"+heroModel.getStr(mp);
			this.attr2.text=ModelHero.hero_4d_name[1]+":"+heroModel.getInt(mp);
			this.attr3.text=ModelHero.hero_4d_name[2]+":"+heroModel.getCha(mp);
			this.attr4.text=ModelHero.hero_4d_name[3]+":"+heroModel.getLead(mp);

			var skillData:Object = heroModel.isMine()?heroModel.getMySkills():heroModel.skill;
			listData = ModelSkill.getSortSkillArr(skillData, heroModel);
			this.skillList.itemRender=skillItemUI;
			this.skillList.renderHandler=new Handler(this,skillListRender);
			
			this.skillList.y = boxTop.y + boxTop.height;
			
			//行高
			var rowHeight:Number;
			//行数
			var rowNum:int;
			//列数
			this.columnNum = listData.length > 18?4:3;
			if (listData.length > 18){
				this.columnNum = 4;
				rowHeight = 44;
				this.skillList.spaceX = -32;
				this.skillList.spaceY = -6;
			}
			else
			{
				this.columnNum = 3;
				rowHeight = 60;
				this.skillList.spaceX = 15;
				this.skillList.spaceY = 10;
			}
			rowNum = Math.ceil(listData.length / this.columnNum);
			this.skillList.repeatX = this.columnNum;
			this.skillList.repeatY = rowNum;
			this.skillList.height = Math.max(1,rowHeight * rowNum -2);
			this.skillList.array = listData;
			
			this.mModelTalent = ModelTalent.getModel(this.heroModel.id);
			var info:String;
			var color:String;
			var sumY:Number = this.skillList.y + this.skillList.height;
			this.boxMid.y = sumY;
			sumY = 0;
			if (this.mModelTalent){
				//有天赋
				this.tTalent.visible = true;
				this.imgLine.visible = true;
				this.boxTalent.visible = true;
				
				sumY += 10;
				this.tTalent.y = sumY;
				info = this.mModelTalent.getName();
				this.tTalent.text = Tools.getMsgById("_hero32", [info]);
				sumY += this.tTalent.height + 10;
				
				this.boxTalent.y = sumY;
				this.initTalentBox();
				sumY += this.boxTalent.height + 10;
			}
			else{
				//无天赋
				this.tTalent.visible = false;
				this.imgLine.visible = false;
				this.boxTalent.visible = false;
				this.boxTalent.height = 1;
			}		
			this.boxInfo.y = sumY;
			this.tInfoName.text=Tools.getMsgById("_hero23");//"传记";
			this.tInfo.text = Tools.getMsgById(heroModel.info);
			//this.boxInfo.height = this.tInfo.height + 20;
			sumY += this.boxInfo.height;
			this.boxMid.height = sumY;
			sumY += this.skillList.y + this.skillList.height;

			//
			this.boxBottom.y = sumY;
			this.textLabel.text = Tools.getMsgById("_shop_text08");//"问道获得";
			sumY += this.boxBottom.height + 10;
			
			//this.iconList.itemRender=bagItemUI;
			this.iconList.renderHandler=new Handler(this,iconListRender);
			iconData=heroModel.resolve;
			this.iconList.array=iconData;
			//
			this.viewBG.height = sumY;
			
			this.all.height = sumY;
			//this.all.centerY=0;
		}


		public function skillListRender(cell:skillItemUI,index:int):void{
			var d:ModelSkill = this.skillList.array[index];
			var scale:Number = this.columnNum > 3?0.7:1;
			cell.scale(scale, scale);
			
			cell.setSkillItem(d, heroModel);
		}

		public function iconListRender(cell:bagItemUI,index:int):void{
			var a:Array=this.iconList.array[index][0];
			var itemModel:ModelItem=ModelManager.instance.modelProp.getItemProp(a[0]);
			itemModel.addNum=a[1];
			//cell.setData(itemModel.icon,itemModel.ratity,itemModel.name,a[1]+"",2);
			cell.setData(itemModel.id,-1);
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
			var html:HTMLDivElement;
			
			for (var i:int = 0; i < len; i++) 
			{
				info = infoArr[i];
				if (!info)
					continue;
				//info = StringUtil.substituteWithColor(sign + info, color2, (i % 2 == 0)?color0:color1);
				
				html = new HTMLDivElement;
				html.width = this.boxTalent.width;
				
				if (info.substr(0, 1) == '_'){
					//属于子项目
					info = info.substr(1);
					info = StringUtil.repeat('&nbsp;', 4) + StringUtil.substituteWithColor(info, color2, color3);
					tempY = 5;
					html.style.fontSize = 14;
				}
				else{
					info = StringUtil.substituteWithColor(sign + info, color2, (i % 2 == 0)?color0:color1);
					tempY = 10;
					html.style.fontSize = 16;
				}
				
				//html.style.fontSize = 16;
				html.style.leading = 6;

				html.innerHTML = info;
				html.y = sumY;
				this.boxTalent.addChild(html);
				
				sumY += html.contextHeight + tempY;
			}
			
			//有传奇天赋
			var arr:Array = ConfigFight.legendTalent[this.heroModel.id]?ConfigFight.legendTalent[this.heroModel.id]:ConfigFight.legendTalentFight[this.heroModel.id];
			if (arr){
				sumY += 10;
				var s0:String = heroModel.getStar()==18 ? "" : Tools.getMsgById("talent_else");
				info = Tools.getMsgById(this.mModelTalent.getLegendTalent(), [this.mModelTalent.getLegendValue(this.heroModel.getStar())]);
				info = StringUtil.substituteWithLineAndColor(info, color2, '#66ffff')+s0;
				html = new HTMLDivElement;
				html.x = 15;
				html.width = this.boxTalent.width-30;
				html.style.fontSize = 16;
				html.style.leading = 6;
				html.innerHTML = info;
				html.y = sumY;
				this.boxTalent.addChild(html);
				
				sumY += html.contextHeight + 10;
			}
			
			this.boxTalent.height = sumY;
		}

		override public function initData():void{
			
		}

		override public function onRemoved():void{

		}
	}

}