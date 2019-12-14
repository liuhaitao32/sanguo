package sg.fight.test 
{
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.CheckBox;
	import laya.ui.ComboBox;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.utils.Handler;
	import sg.fight.logic.utils.FightUtils;
	import sg.utils.StringUtil;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.manager.EffectManager;
	import sg.model.ModelBeast;
	import sg.utils.Tools;
	import ui.battle.fightTestBeastUI;
	import ui.battle.fightTestTroopBeastItemUI;
	/**
	 * 测试兽灵数据
	 * @author zhuda
	 */
	public class TestBeast extends fightTestBeastUI
	{
		public var testFightTroop:TestFightTroop;
		public var currEdit:int;
		public var currModelBeast:ModelBeast;
		///当前的八门兽灵数据数组，未经modelPrepare转化的
		//public var beastDataArr:Array;
		
		public function TestBeast(testFightTroop:TestFightTroop) 
		{
			this.testFightTroop = testFightTroop;
			//this.currEdit = 0;
			
			//this.initData();
			//this.beastDataArr = TestFightTroop.beastArr[this.testFightTroop.troopIndex];
			//this.list.array = this.beastDataArr;
			//return;
			this.once(Event.ADDED, this, this.initUI);
		}
		//public function initData():void
		//{
			//this.beastDataArr = TestFightTroop.beastArr[this.testFightTroop.troopIndex];
		//}
		
		public function initUI():void
		{
			//EffectManager.bindMouseTips(this.tName, '右键整套更换共鸣');
			//this.tName.on(Event.RIGHT_CLICK, this, this.onChangeResonance, [1]);
			//this.tResonance.on(Event.RIGHT_CLICK, this, this.onChangeResonance, [ -1]);
			this.btnResonanceL.on(Event.CLICK, this, this.onChangeResonance, [-1]);
			this.btnResonanceR.on(Event.CLICK, this, this.onChangeResonance, [1]);
			this.btnStarL.on(Event.CLICK, this, this.onChangeStar, [-1]);
			this.btnStarR.on(Event.CLICK, this, this.onChangeStar, [1]);
			this.btnLvL.on(Event.CLICK, this, this.onChangeLv, [-1]);
			this.btnLvR.on(Event.CLICK, this, this.onChangeLv, [1]);
			this.btnClone.on(Event.CLICK, this, this.onCloneOne, [1]);
			
			this.checkBoxU.selected = true;
			this.checkBoxD.selected = true;
			this.checkBoxU.on(Event.CLICK, this, this.onCheckBox, [true]);
			this.checkBoxD.on(Event.CLICK, this, this.onCheckBox, [false]);
			
			this.list.renderHandler = new Handler(this, this.listRender);
			this.list.selectEnable = true;
			this.list.selectHandler = new Handler(this, this.onlistSelect);
			
			
			this.tTest.visible = this.htmlTest.visible = false;
			if (1){
				this.hsTest.on(Event.CHANGE, this, this.onChangeHsTest);
			}
			else{
				this.hsTest.visible = false;
			}


			//this.beastDataArr = FightUtils.clone(TestFightTroop.beastArr[this.testFightTroop.troopIndex]);
			
			this.currEdit = 0;
			this.updateEdit();
			
			//this.beastDataArr = [{}, {}, {a:1}];
			this.list.array = this.beastDataArr;
		}
		/**
		 * 测试适配文本字号初始化
		 */
		public function initHsTest():void
		{
			this.tTest.visible = this.htmlTest.visible = true;
			
			this.tValueArrInfo.width = 200;
			Tools.textScale(this.tValueArrInfo);
			Tools.textScale(this.testFightTroop.statistics.testFight.btnTroop);
			Tools.textScale(this.htmlInfo);
			
			Tools.textScale(this.tTest);
			Tools.textScale(this.testFightTroop.btnBeast);
			this.htmlTest.style.fontSize = 50;
			Tools.textScale(this.htmlTest);
		}
		

		

		public function get beastDataArr():Array
		{
			return TestFightTroop.beastArr[this.testFightTroop.troopIndex];
		}
		
		/**
		 * 测试适配文本字号修改
		 */
		public function onChangeHsTest():void
		{
			if (!this.tTest.visible){
				this.initHsTest();
			}
			var minSize:int = 11;
			var info:String;
			var num:int = this.hsTest.value;

			
			//单行Label
			info = JSON.stringify(this.currModelBeast.getValueArr(false)) + StringUtil.repeat('w', Math.floor(num / 4));
			if (this.tValueArrInfo.hasListener(Event.CHANGE)){
				this.tValueArrInfo.text = info;
			}
			else{
				Tools.textFitFontSize(this.tValueArrInfo, info, 0, minSize);
			}

			
			//单行Button
			info = '调整属性(Z)' + StringUtil.repeat('z', Math.floor(num/4));
			Tools.textFitFontSize(this.testFightTroop.statistics.testFight.btnTroop, info, 0, minSize);
			
			//单行HTML
			info = this.currModelBeast.getLvInfo(this.currModelBeast.lv, true) + StringUtil.repeat('m', Math.floor(num/2));
			info = StringUtil.substituteWithColor(info, '#ffaa00', '#ffffff');
			Tools.textFitFontSize(this.htmlInfo, info, 0, minSize);
			
			
			//多行Label
			info = 'test' + StringUtil.repeat('Test', num);
			if(this.tTest.hasListener(Event.CHANGE)){
				this.tTest.text = info;
			}
			else{
				Tools.textFitFontSize2(this.tTest, info, 0, 0, minSize);
			}
			
			//多行Button
			info = 'I have one dream,you have two dream';
			if (num <= info.length){
				info = info.substr(0, num);
			}
			else{
				info += StringUtil.repeat('W', num - info.length);
			}
			Tools.textFitFontSize2(this.testFightTroop.btnBeast, info, 0, 0, minSize);
			
			//多行HTML
			info = StringUtil.substituteWithColor('html' + StringUtil.repeat(' [H]T[M]L', num), '#33ff00', '#ffff66');
			Tools.textFitFontSize2(this.htmlTest, info, 0, 0, minSize);
		}
		
		
		public function updateEdit():void{
			this.currModelBeast = new ModelBeast(this.currEdit, this.beastDataArr[this.currEdit]);
			this.updateBaseInfo();
			this.initComboType();
			this.initComboStar();
			this.initComboLv();
			this.initComboSuper(0);
			this.initComboSuper(1);
			this.initComboSuper(2);
			this.updateResonance();
		}
		
		
		private function listRender(cell:Box, index:int):void
		{
			var dataArr:Array = this.list.array[index];
			var modelBeast:ModelBeast = new ModelBeast(0, dataArr);

			var item:fightTestTroopBeastItemUI = cell.getChildByName('item') as fightTestTroopBeastItemUI;
			item.setSkillBgColor(modelBeast.star + 1, false);
			EffectManager.bindMouseTips(item, '右键装卸');
			
			var nameLabel:Label = item.getChildByName('nameLabel') as Label;
			var lvLabel:Label = item.getChildByName('lvLabel') as Label;
			var bgKuang:Image = item.getChildByName('bgKuang') as Image;
			
			nameLabel.text = modelBeast.typeName;
			lvLabel.text = modelBeast.lv + '/' +modelBeast.maxLv() + '级';

			var len:int = 3;
			for (var i:int = 0; i < len; i++) 
			{
				var superLabel:Label = item.getChildByName('super' + i) as Label;
				var infoAndColor:Array = modelBeast.getSuperInfoAndColor(i);
				var arr:Array = modelBeast.superArr[i];
				
				if(arr){
					superLabel.text = arr[0] + ' ' + arr[1];
					superLabel.color = EffectManager.getFontColor(ModelBeast.getSuperValueArr(arr[1])[1]);
				}
				else{
					superLabel.text = '';
				}
				
				if (modelBeast.isUnlockSuper(i)){
					superLabel.alpha = 1;
				}
				else{
					//未达到解锁等级
					superLabel.alpha = 0.3;
				}
			}
			
			bgKuang.visible = index == this.currEdit;
			item.alpha = modelBeast.ban?0.3:1;
			
			
			item.off(Event.RIGHT_CLICK, this, this.openSelect);
			item.on(Event.RIGHT_CLICK, this, this.openSelect, [index]);
			
			//item.checkBoxOpen.selected = TestTable.heroesOpenArr[index];
			//if(!item.checkBoxOpen.clickHandler)
				//item.checkBoxOpen.clickHandler = new Handler(this, this.onChangeCheckBoxOpen, [index]);
		}
		private function onlistSelect(index:int):void
		{
			this.currEdit = index;
			this.updateEdit();
			this.list.array = this.beastDataArr;
		}
		private function openSelect(index:int):void
		{
			//禁用/启用右键选择的兽灵
			this.beastDataArr[index][5] = this.beastDataArr[index][5]?false:true;
			this.updateData(index);
			
			if (index == this.currEdit){
				this.currModelBeast.ban = this.beastDataArr[index][5];
			}
		}
		
		
		private function initComboType():void
		{
			this.comboType.off(Event.CHANGE, this, this.onChangeData);
			this.comboType.scrollBar.hide = true;
			var i:int;
			var len:int = ConfigFight.testBeastTypes.length;
			var str:String = '';
			var key:String;
			for (i = 0; i < len; i++)
			{
				key = ConfigFight.testBeastTypes[i];
				str += key +' '+ Tools.getMsgById('_beastType_' +key);
				
				if (i < len - 1)
				{
					str += ',';
				}
			}
			this.comboType.labels = str;
			i = ConfigFight.testBeastTypes.indexOf(this.currModelBeast.type);
			if (i < 0) i = 0;
			this.comboType.selectedIndex = i;
			this.comboType.on(Event.CHANGE, this, this.onChangeData);
		}
		private function initComboStar():void
		{
			this.comboStar.off(Event.CHANGE, this, this.onChangeData);
			this.comboStar.scrollBar.hide = true;
			var i:int;
			var len:int = ConfigFight.testBeastStars.length;
			var str:String = '';
			var value:int;
			for (i = 0; i < len; i++)
			{
				value = ConfigFight.testBeastStars[i];
				str += value +' '+ Tools.getColorInfo(value+1);
				
				if (i < len - 1)
				{
					str += ',';
				}
			}
			this.comboStar.labels = str;
			i = ConfigFight.testBeastStars.indexOf(this.currModelBeast.star);
			if (i < 0) i = 0;
			this.comboStar.selectedIndex = i;
			this.comboStar.on(Event.CHANGE, this, this.onChangeData);
		}
		private function initComboLv():void
		{
			this.comboLv.off(Event.CHANGE, this, this.onChangeLvData);
			this.comboLv.scrollBar.hide = true;
			var i:int;
			var len:int = ConfigFight.testBeastLvs.length;
			var str:String = '';
			for (i = 0; i < len; i++)
			{
				str += ConfigFight.testBeastLvs[i] +' '+ '级';
				
				if (i < len - 1)
				{
					str += ',';
				}
			}
			this.comboLv.labels = str;
			i = ConfigFight.testBeastLvs.indexOf(this.currModelBeast.lv);
			if (i < 0) i = 0;
			this.comboLv.selectedIndex = i;
			this.comboLv.on(Event.CHANGE, this, this.onChangeLvData);
		}
		private function initComboSuper(superIndex:int, hasValue:Boolean = true):void
		{
			var comboBox:ComboBox = this['comboSuper' + superIndex];
			var comboBoxValue:ComboBox = this['comboSuperValue' + superIndex];
			
			comboBox.off(Event.CHANGE, this, this.onChangeData);
			//comboBox.scrollBar.hide = true;
			if (hasValue){
				comboBoxValue.off(Event.CHANGE, this, this.onChangeValueData);
				comboBoxValue.off(Event.CHANGE, this, this.onChangeData);
				comboBoxValue.scrollBar.hide = true;
			}
			
			var i:int;
			var len:int;
			var str:String;
			var value:*;
			var arr:Array = this.currModelBeast.superArr[superIndex];
			var superRank:int = arr?arr[1]:0;
	
			//按等级刷新说明
			len = ConfigFight.testBeastSupers.length;
			str = '';
			for (i = 0; i < len; i++)
			{
				value = ConfigFight.testBeastSupers[i];
				str += value+ ' | ' + ModelBeast.getSuperInfoAndColorArr(value, superRank)[0];
				if (i < len - 1)
				{
					str += ',';
				}
			}
			comboBox.labels = str;

			if(hasValue){
				len = ConfigFight.testBeastSuperValues.length;
				str = '';
				for (i = 0; i < len; i++)
				{
					value = ConfigFight.testBeastSuperValues[i];
					var tempArr:Array = ModelBeast.getSuperValueArr(value);
					str += value +Tools.getColorInfo(tempArr[1]) + Tools.percentFormat(tempArr[0]) ;
					if (i < len - 1)
					{
						str += ',';
					}
				}
				comboBoxValue.labels = str;
			}

			if(arr){
				i = ConfigFight.testBeastSupers.indexOf(arr[0]);
				if (i < 0) i = 0;
				comboBox.selectedIndex = i;
				
				if(hasValue){
					i = ConfigFight.testBeastSuperValues.indexOf(arr[1]);
					if (i < 0) i = 0;
					comboBoxValue.selectedIndex = i;
				}
			}
			else{
				comboBox.selectedIndex = 0;
				if(hasValue)
					comboBoxValue.selectedIndex = 0;
			}
			
			if (this.currModelBeast.isUnlockSuper(superIndex)){
				comboBox.alpha = comboBoxValue.alpha = 1;
			}
			else{
				//未达到解锁等级
				comboBox.alpha = comboBoxValue.alpha = 0.6;
			}

			
			comboBox.on(Event.CHANGE, this, this.onChangeData);
			if(hasValue)
				comboBoxValue.on(Event.CHANGE, this, this.onChangeValueData, [superIndex] );
		}
		private function updateBaseInfo():void
		{
			this.updateCurrName();
			this.updateCurrInfo();
			this.updateValueArrInfo();
		}
		private function updateCurrName():void
		{
			this.tName.text = this.currModelBeast.getName(false);
			this.tName.color = EffectManager.getFontColor(this.currModelBeast.star + 1);
		}
		private function updateCurrInfo():void
		{
			this.htmlInfo.style.fontSize = 14;
            //this.htmlInfo.style.align = 'center';
			var info:String = this.currModelBeast.getLvInfo(this.currModelBeast.lv, true);
			info = StringUtil.substituteWithColor(info,'#ffaa00','#ffffff');

			this.htmlInfo.innerHTML = info;
			//this.tInfo.text = this.currModelBeast.getLvInfo(this.currModelBeast.lv);
			//this.tName.color = EffectManager.getFontColor(this.currModelBeast.star + 1);
		}
		private function updateValueArrInfo():void
		{
			var arr:Array = this.currModelBeast.getValueArr(false);
			this.tValueArrInfo.text = JSON.stringify(arr);
			//this.tValueArrInfo.color = '#AAAAAA';
			//this.tName.color = EffectManager.getFontColor(this.currModelBeast.star + 1);
		}

		private function onChangeLvData():void
		{
			this.onChangeData();
			this.initComboSuper(0, false);
			this.initComboSuper(1, false);
			this.initComboSuper(2, false);
		}
		private function onChangeValueData(superIndex:int):void
		{
			this.onChangeData();
			this.initComboSuper(superIndex, false);
		}
		/**
		 * 修改当前兽灵，更新保存数据
		 */
		private function onChangeData():void
		{
			this.currModelBeast.type = ConfigFight.testBeastTypes[this.comboType.selectedIndex];
			this.currModelBeast.star = ConfigFight.testBeastStars[this.comboStar.selectedIndex];
			this.currModelBeast.lv = ConfigFight.testBeastLvs[this.comboLv.selectedIndex];
			for (var i:int = 0; i < 3; i++) 
			{
				var selectedIndex:int = this['comboSuper' + i].selectedIndex;
				var type:String = ConfigFight.testBeastSupers[selectedIndex];
				if (type.indexOf('-') >= 0){
					this.currModelBeast.superArr[i] = null;	
				}
				else{
					this.currModelBeast.superArr[i] = [type, ConfigFight.testBeastSuperValues[this['comboSuperValue'+i].selectedIndex]];	
				}
			}
			this.beastDataArr[this.currEdit] = this.currModelBeast.getValueArr(true);
			this.updateAnyData();
			//this.updateData(this.currEdit);
			this.updateBaseInfo();
		}
		/**
		 * 选择更换部分
		 */
		public function onCheckBox(isUp:Boolean):void
		{
			var currCheckBox:CheckBox = isUp?this.checkBoxU:this.checkBoxD;
			var otherCheckBox:CheckBox = isUp?this.checkBoxD:this.checkBoxU;
			//this.currCheckBox.selected = !this.currCheckBox.selected;
			if (!currCheckBox.selected && !otherCheckBox.selected){
				otherCheckBox.selected = true;
			}
		}
		/**
		 * 获得当前选择更换的范围
		 */
		public function get selectRange():Array
		{
			var rangeMin:int = this.checkBoxU.selected?0:4;
			var rangeMax:int = this.checkBoxD.selected?8:4;
			return [rangeMin,rangeMax];
		}
		/**
		 * 整套更换共鸣
		 */
		private function onChangeResonance(addNum:int):void
		{
			var range:Array = this.selectRange;
			
			var beastArr:Array = this.beastDataArr;
			var typeLen:int = ConfigFight.testBeastTypes.length;

			for (var i:int = range[0]; i < range[1] ; i++  ){
				var beastOneArr:Array = beastArr[i];
				var index:int = ConfigFight.testBeastTypes.indexOf(beastOneArr[0]);
				if (index < 0) index = 0;
				var selectedIndex:int = (index + addNum + typeLen) % typeLen;
				//beastOneArr[0] = ConfigFight.testBeastTypes[selectedIndex];
				
				var mb:ModelBeast = new ModelBeast(i, beastOneArr);
				mb.type = ConfigFight.testBeastTypes[selectedIndex];
				this.beastDataArr[i] = mb.getValueArr(true);
				
				if (i == this.currEdit){
					this.currModelBeast = mb;
					this.comboType.selectedIndex = selectedIndex;
				}
			}
			
			this.updateAnyData();
		}
		/**
		 * 整套更换品质
		 */
		private function onChangeStar(addNum:int):void
		{
			var range:Array = this.selectRange;
			
			var beastArr:Array = this.beastDataArr;
			var starLen:int = ConfigFight.testBeastStars.length;

			for (var i:int = range[0]; i < range[1] ; i++  ){
				var beastOneArr:Array = beastArr[i];
				var index:int = ConfigFight.testBeastStars.indexOf(beastOneArr[2]);
				if (index < 0) index = 0;
				var selectedIndex:int = Math.min(starLen-1,Math.max(0,index + addNum));
				//beastOneArr[0] = ConfigFight.testBeastTypes[selectedIndex];
				
				var mb:ModelBeast = new ModelBeast(i, beastOneArr);
				mb.star = ConfigFight.testBeastStars[selectedIndex];
				this.beastDataArr[i] = mb.getValueArr(true);
				
				if (i == this.currEdit){
					this.currModelBeast = mb;
					this.comboStar.selectedIndex = selectedIndex;
				}
			}
			
			this.updateAnyData();
		}
		/**
		 * 整套更换等级
		 */
		private function onChangeLv(addNum:int):void
		{
			var range:Array = this.selectRange;
			
			var beastArr:Array = this.beastDataArr;
			var lvLen:int = ConfigFight.testBeastLvs.length;

			for (var i:int = range[0]; i < range[1]; i++  ){
				var beastOneArr:Array = beastArr[i];
				var index:int = ConfigFight.testBeastLvs.indexOf(beastOneArr[3]);
				if (index < 0) index = 0;
				var selectedIndex:int =  Math.min(lvLen-1,Math.max(0,index + addNum));
				//beastOneArr[0] = ConfigFight.testBeastTypes[selectedIndex];
				
				var mb:ModelBeast = new ModelBeast(i, beastOneArr);
				mb.lv = ConfigFight.testBeastLvs[selectedIndex];
				this.beastDataArr[i] = mb.getValueArr(true);
				
				if (i == this.currEdit){
					this.currModelBeast = mb;
					this.comboLv.selectedIndex = selectedIndex;
				}
			}
			
			this.updateAnyData();
		}
		/**
		 * 整套克隆当前
		 */
		private function onCloneOne():void
		{
			var range:Array = this.selectRange;
			
			var beastArr:Array = this.beastDataArr;
			var arr:Array = this.currModelBeast.getValueArr(false);

			for (var i:int = range[0]; i < range[1]; i++  ){
				if (i == this.currEdit){
					continue;
				}
				
				var beastOneArr:Array = beastArr[i];
				
				var mb:ModelBeast = new ModelBeast(i, FightUtils.clone(arr));
				mb.pos = i;
				mb.ban = beastOneArr[5]?true:false;
				this.beastDataArr[i] = mb.getValueArr(true);
			}
			
			this.updateAnyData();
		}
		

		private function updateData(index:int):void
		{
			var mb:ModelBeast = new ModelBeast(index, this.beastDataArr[index]);
			this.beastDataArr[index] = mb.getValueArr(true);
			this.updateAnyData();
		}
		public function updateAnyData():void
		{
			//TestFightTroop.beastArr[this.testFightTroop.troopIndex] = this.beastDataArr;
			this.list.array = this.beastDataArr;
			this.updateResonance();
			
			if (TestFightTroop.openBeastArr[this.testFightTroop.troopIndex]){
				this.testFightTroop.statistics.updateAllData(this.testFightTroop.troopIndex);
			}
			TestFightTroop.saveLocalJsonOption();
		}
		/**
		 * 判断并显示共鸣
		 */
		private function updateResonance():void
		{
			var beastArr:Array = TestFightTroop.beastArr[this.testFightTroop.troopIndex];
			var resonanceArr:Array = ModelBeast.getResonanceArr(beastArr);
			var arr:Array;

			if (resonanceArr.length > 1){
				arr = resonanceArr[1];
				this.tResonance1.text = '';
				this.tResonance1.color = EffectManager.getFontColor(arr[2] + 1);
				this.tResonance1.text = '※' + Tools.getMsgById('_beastType_' +arr[0]) + arr[1];
				EffectManager.bindMouseTips(this.tResonance1, ModelBeast.getResonanceInfo(arr[0], arr[1], arr[2], true, true), true);
			}
			else{
				this.tResonance1.text = '';
				EffectManager.bindMouseTips(this.tResonance1, '');
			}
			
			if (resonanceArr.length > 0){
				arr = resonanceArr[0];
				this.tResonance0.text = '';
				this.tResonance0.color = EffectManager.getFontColor(arr[2] + 1);
				this.tResonance0.text = '※' + Tools.getMsgById('_beastType_' +arr[0]) + arr[1];
				EffectManager.bindMouseTips(this.tResonance0, ModelBeast.getResonanceInfo(arr[0], arr[1], arr[2], true, true), true);
				
				//全套共鸣
				EffectManager.bindMouseTips(this.tResonance, ModelBeast.getAllResonanceInfo(resonanceArr, false, true), true);
			}
			else{
				this.tResonance0.text = '';
				EffectManager.bindMouseTips(this.tResonance0, '');
				
				EffectManager.bindMouseTips(this.tResonance, Tools.getMsgById('_beastResonanceNull'));
			}
			
			//显示全套副属性
			this.tSuper.text = '属性总览';
			var lvInfo:String = ModelBeast.getAllLvInfo(beastArr);
			var superInfo:String = ModelBeast.getAllSuperInfo(beastArr);
			var info:String = superInfo?(lvInfo + '\n\n' + superInfo):lvInfo;
			EffectManager.bindMouseTips(this.tSuper, info);
		}
	}

}