package sg.view.map
{
	import laya.display.Animation;
	import laya.html.dom.HTMLDivElement;
	import laya.ui.Box;
	import sg.model.ModelPrepare;
	import sg.utils.StringUtil;
	import sg.cfg.ConfigApp;
	import sg.fight.logic.utils.FightUtils;
	import sg.manager.EffectManager;
	import sg.map.utils.TestUtils;
	import sg.model.ModelAwaken;
	import sg.model.ModelEquip;
	import ui.map.heroInfoUI;
	import sg.model.ModelHero;
	import sg.model.ModelSkill;
	import sg.manager.ModelManager;
	import laya.utils.Handler;
	import ui.com.skillItemUI;
	import laya.events.Event;
	import sg.manager.ViewManager;
	import sg.model.ModelBuiding;
	import sg.utils.Tools;
	import sg.view.com.comIcon;
	import ui.hero.heroEquipItemUI;
	import sg.cfg.ConfigColor;
	import sg.model.ModelBeast;
	import sg.manager.AssetsManager;
	import sg.model.ModelGame;

	/**
	 * ...
	 * @author
	 */
	public class ViewHeroInfo extends heroInfoUI{

		public var mData:*;
		private var hmd:ModelHero;
		//技能列数
		public var columnNum:int;
		
		public function ViewHeroInfo(){
			//this.list.itemRender=skillItemUI;
			this.list.renderHandler=new Handler(this,listRender);
			this.list.scrollBar.visible=false;
			//this.btnClose.on(Event.CLICK,this,function():void{
				//ViewManager.instance.closePanel(this);
			//})
			this.armyLabel0.text = Tools.getMsgById("rslt_army[0]");
			this.armyLabel1.text = Tools.getMsgById("rslt_army[1]");
		}

		override public function onAdded():void{
			
			this.comTitle.setViewTitle(Tools.getMsgById("_hero28"));
			mData=this.currArg;//字符串表示自己的英雄  [{}]表示不是自己的
			
			var isArr:Boolean;
			var o:Object;
			var armyLv0:int;
			var armyLv1:int;
			var armyRank0:int;
			var armyRank1:int;
			var skillData:Object;
			var equipData:Array;

			if(mData is String){
				o = {};
				isArr = true;
				this.hmd = ModelManager.instance.modelGame.getModelHero(mData);
				armyLv0 = this.hmd.armyLv[0];
				armyLv1 = this.hmd.armyLv[1];
				armyRank0 = this.hmd.armyRank[0];
				armyRank1 = this.hmd.armyRank[1];
			}else{
				if (mData is Array){
					o = mData[0];
					o = new ModelPrepare(o).data;
					isArr = true;
				}
				else{
					//通过user_info返回
					o = FightUtils.clone(mData);
					//如果没有proud，说明此数据为非战斗转化，则删除o.power重建模型来对比战力
					if(!o.hasOwnProperty('proud')){
						delete o.power;
					}
					isArr = false;
				}

				if (o.hasOwnProperty('army')){
					armyLv0 = o.army[0].lv?o.army[0].lv:0;
					armyLv1 = o.army[1].lv?o.army[1].lv:0;
					armyRank0 = o.army[0].rank;
					armyRank1 = o.army[1].rank;
				}
				else{
					if (o.hasOwnProperty('armyLv')){
						armyLv0 = armyLv1 = o.armyLv;
					}
					if (o.hasOwnProperty('armyRank')){
						armyRank0 = armyRank1 = o.armyRank;
					}
				}
				if(!o.beast) o['beast'] = [];

				this.hmd = new ModelHero(true);
				this.hmd.setData(o);
				this.hmd.getPrepare(true, o);
			}
			var modelPrepare:ModelPrepare = this.hmd.getPrepare();
			var clientPower:int = modelPrepare.data.power;
			var serverPower:int = mData.power?mData.power:0;
			

			
			if (o.skill){
				skillData = o.skill;
			}
			else{
				skillData = this.hmd.isMine()?this.hmd.getMySkills():this.hmd.skill;
			}

			if(o.equip){
				equipData = o.equip;
			}else{
				equipData = this.hmd.isMine()?this.hmd.getEquipData():[];
			}
			for(var i:int=0;i<5;i++){
				var emd:ModelEquip = null;
				var elv:Number = 0;
				var enhanceLv:Number = 0;
				for(var j:int=0;j<equipData.length;j++){
					var e:ModelEquip=ModelManager.instance.modelGame.getModelEquip(equipData[j][0]);
					if(e.type==i){
						emd=e;
						elv=equipData[j][1];
						enhanceLv = equipData[j][3] ? equipData[j][3] : 0;
						break;
					}
				}
				var com:heroEquipItemUI=this["equip"+i];
				if(emd){
					com.com.setHeroEquipType(emd,emd.type,false,elv,true);
					com.tEquipped.text="";
					com.tName.text=ModelEquip.getName(emd.id,enhanceLv);
					com.tName.color = ConfigColor.FONT_COLORS[elv];
				}else{
					com.com.setHeroEquipType(null,i,false,-1,true);
					com.tName.text=ModelEquip.equip_type_name[i];
					com.tEquipped.text=Tools.getMsgById("_equip11");
					com.tName.color = ConfigColor.FONT_COLORS[0];
				}
				Tools.textFitFontSize(com.tName);
			}
			
			this.labelName.text = this.hmd.getName();
			var group:String = modelPrepare.getGroupId();
			if (group){
				this.tGroup.text = ModelEquip.getGroupEquipName2(group);
				EffectManager.addUIAnimation(this.tGroup, 'glow043', 0.6, this.tGroup.width/2, this.tGroup.height/2, true);
			}
			this.tGroup.visible = group;
			
			this.comStar.setHeroStar(this.hmd.getStar());
			this.imgRatity.skin = this.hmd.getRaritySkin();

			this.armyIcon0.setArmyIcon(this.hmd.army[0], armyRank0);
			this.armyIcon1.setArmyIcon(this.hmd.army[1], armyRank1);
			
			this.amryName0.text=Tools.getMsgById("_hero16",[armyLv0])+ModelHero.army_type_name[this.hmd.army[0]];
			this.armyName1.text=Tools.getMsgById("_hero16",[armyLv1])+ModelHero.army_type_name[this.hmd.army[1]];

			this.armyLabel0.width = this.armyLabel0.textField.textWidth;
			this.armyIcon0.x = this.armyLabel0.x + this.armyLabel0.width + 4;
			this.amryName0.x = this.armyIcon0.x + (this.armyIcon0.width * this.armyIcon0.scaleX) + 4;

			this.armyLabel1.width = this.armyLabel1.textField.textWidth;
			this.armyIcon1.x = this.armyLabel1.x + this.armyLabel1.width + 4;
			this.armyName1.x = this.armyIcon1.x + (this.armyIcon1.width * this.armyIcon1.scaleX) + 4;


			this.comHero.setHeroIcon(this.hmd.getHeadId(), true, this.hmd.getStarGradeColor());
			
			var powerStr:String;
			if (isArr || !serverPower){
				powerStr = clientPower + '';
			}
			else{
				powerStr = serverPower + '';
				if (TestUtils.isTestShow && !ConfigApp.testFightType){
					if (serverPower != clientPower){
						powerStr += ' 服!=客 ' + clientPower;
					}
				}
			}
			this.comPower.setNum(powerStr);
			//this.labelAtk.text = powerStr;
			var lv:int = this.hmd.getLv();
			this.heroLv.setNum(lv?lv:1);
			//this.labelLv.text = hmd.getLv() + '';
			
			//this.heroType.x = this.labelName.x + this.labelName.textField.textWidth + 10;
			this.heroType.setHeroType(hmd.getType());
			this.attr1.text = ModelHero.hero_4d_name[0] + " " + hmd.getStr(modelPrepare);
			this.attr2.text = ModelHero.hero_4d_name[1] + " " + hmd.getInt(modelPrepare);
			this.attr3.text = ModelHero.hero_4d_name[2] + " " + hmd.getCha(modelPrepare);
			this.attr4.text = ModelHero.hero_4d_name[3] + " " + hmd.getLead(modelPrepare);
			
			var listData:Array = ModelSkill.getSortSkillArr(skillData, hmd, true);
			//listData = listData.concat(listData);
			//listData = listData.concat(listData);
			//listData = listData.concat(listData);
			//listData = listData.concat(listData);
			
			//行高
			var rowHeight:Number;
			//行数
			var rowNum:int;
			//列数
			this.columnNum = listData.length > 18?4:3;
			
			if (listData.length > 18){
				this.columnNum = 4;
				rowHeight = 38;
				this.list.width = 466;
				this.list.spaceX = -13;
				this.list.spaceY = -3;
			}
			else
			{
				this.columnNum = 3;
				rowHeight = 41;
				this.list.width = 436;
				this.list.spaceX = 25;
				this.list.spaceY = 0;
			}
			rowNum = Math.ceil(listData.length / this.columnNum);
			this.list.repeatX = this.columnNum;
			this.list.repeatY = rowNum;
			this.list.height = Math.max(1,rowHeight * rowNum -2);
			
			boxList.top = initBeastBox(o);
			//一行放置3个
			//var h:Number=Math.max(1,Math.ceil(listData.length/3));
			this.list.array = listData;
			var sumY:int = boxList.top + 16 + (rowHeight * rowNum);
			
			
			sumY += this.initAwakenBox(sumY);
			this.all.height = sumY;
		}

		public function listRender(cell:Box, index:int):void{
			//技能图标
			var item:skillItemUI = cell.getChildByName('skillItem') as skillItemUI;
			var scale:Number = this.columnNum > 3?0.9:1;
			cell.scale(scale, scale);
			
			var smd:ModelSkill = this.list.array[index];
			item.setSkillItem(smd, this.hmd);
		}

		public function initBeastBox(o:Object):int{
			var n:Number = boxBeast.y;
			var beastData:Array;
			if(ModelBeast.isOpen() && !ModelGame.unlock(null,"beast").stop){
				if(o.beast){
					beastData = hmd.getBeastResonanceArr(o.beast);
				}else{
					beastData = hmd.getBeastResonanceArr();
				}
			}

			boxBeast.visible = beastData && beastData.length>=0;
			beastImg0.destroyChildren();
			beastImg1.destroyChildren();

			if(boxBeast.visible){
				beastImg0.visible = beastData[0]!=null;
				beastImg1.visible = beastData[1]!=null;
				if(beastImg0.visible) beastImg0.skin = AssetsManager.getAssetLater(ModelBeast.getIconByType(beastData[0][0]));
				if(beastImg1.visible) beastImg1.skin = AssetsManager.getAssetLater(ModelBeast.getIconByType(beastData[1][0]));				

				var s1:String = ConfigApp.lan() == 'cn' ? '四' : '4';
				var s2:String = ConfigApp.lan() == 'cn' ? '八' : '8';
				beastTxt0.text = beastImg0.visible ? (beastData[0][1] == 4 ? s1 : s2) : '';
				beastTxt1.text = beastImg1.visible ? (beastData[1][1] == 4 ? s1 : s2) : '';

				var ani1:Animation = beastData[0] ? EffectManager.loadAnimation(beastData[0][1] == 4 ? 'beast_level4' : 'beast_level8') : null;
				var ani2:Animation = beastData[1] ? EffectManager.loadAnimation(beastData[1][1] == 4 ? 'beast_level4' : 'beast_level8') : null;

				if(beastImg0.visible && ani1) EffectManager.changeSprColor(ani1,beastData[0][2]+1);
				if(beastImg1.visible && ani2) EffectManager.changeSprColor(ani2,beastData[1][2]+1);

				if(beastImg0.visible && ani1) beastImg0.addChild(ani1);
				if(beastImg0.visible && ani2) beastImg1.addChild(ani2);

				if(ani1) ani1.x = beastImg0.width/2;
				if(ani1) ani1.y = beastImg0.height/2;

				if(ani2) ani2.x = beastImg1.width/2;
				if(ani2) ani2.y = beastImg1.height/2;

				n = boxBeast.y + boxBeast.height;
			}
				

			return n;
		}
		
		
		public function initAwakenBox(yy:int):int{
			this.boxAwaken.visible = false;
			this.boxAwakenInfo.destroyChildren();
			
			
			if (this.hmd.getAwaken()){
				var modelAwaken:ModelAwaken = ModelAwaken.getModel(this.hmd.id);
				if (modelAwaken){
					//有觉醒天赋
					
					var color0:String = '#FF9955';
					//var color1:String = '#EEDDAA';
					var color2:String = '#FCAA44';
					var color3:String = '#88AACC';
					var sign:String = Tools.getMsgById('_hero33');
					var info:String = modelAwaken.getInfoHtml();
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
							tempY = 3;
							html.style.fontSize = 14;
						}
						else{
							info = StringUtil.substituteWithColor(sign + info, color2, color0);
							tempY = 6;
							html.style.fontSize = 16;
						}
						//html.style.fontSize = 20;
						html.style.leading = 3;

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
					this.boxAwaken.height = sumY;
					this.boxAwaken.y = yy
					
					this.boxList.bottom = sumY;
					
					return sumY;
				}
			}
			this.boxList.bottom = 6;
			return 0;
		}


		override public function onRemoved():void{
			
		}
	}

}