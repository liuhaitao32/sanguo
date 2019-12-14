package sg.fight.client.view
{
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Button;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;
	import sg.fight.FightMain;
	import sg.fight.client.unit.ClientTroop;
	import sg.fight.test.TestCopyright;
	import sg.fight.test.TestCopyrightData;
	import sg.manager.EffectManager;
	import sg.manager.ModelManager;
	import sg.model.ModelPrepare;
	import sg.utils.Tools;
	import ui.battle.fightCountryTurnItemUI;
	import ui.battle.fightTestHeroesUI;
	
	/**
	 * ...
	 * @author zhuda
	 */
	public class ViewFightTestHeroes extends fightTestHeroesUI
	{
		private var dataArr:Array;
		
		public function ViewFightTestHeroes()
		{
			//this.dataArr = TestCopyrightData.heroInitArr;
			
			this.list.mouseEnabled = true;
			this.list.hScrollBarSkin = '';
			
			this.list.renderHandler = new Handler(this, this.onRender);
			this.list.mouseHandler = new Handler(this, this.onMouse);
			
			this.onChange();
		}
		
		override public function onChange(type:* = null):void
		{
			//更新每个英雄的数据
			if (type == null)
			{
				this.dataArr = [];
				var len:int = TestCopyrightData.heroInitArr.length;
				for (var i:int = 0; i < len; i++)
				{
					var data:Object = this.getOneHeroData(i);
					this.dataArr.push(data);
					if (data.type == 0)
					{
						break;
					}
				}
				this.list.array = this.dataArr;
				this.list.scrollTo(Math.min(i,len-1));
			}
			else
			{
				var index:int = type;
				this.list.changeItem(index, this.getOneHeroData(index));
			}
		
			//this.gold_var.setData(AssetsManager.getAssetsUI(AssetsManager.IMG_GOLD),Tools.textSytle(ModelManager.instance.modelUser.gold));
		}
		
		private function getOneHeroData(index:int):Object
		{
			var hid:String = TestCopyrightData.heroInitArr[index].hid;
			var arr:Array = TestCopyright.checkUpgradeHero(hid);
			var canUpgrade:Boolean = ModelManager.instance.modelUser.gold >= arr[2];
			var troop:ClientTroop = FightMain.instance.client.findTroop(0, hid) as ClientTroop;
			var troopIndex:int = -1;
			var hpPer:Number = 0;
			if (troop)
			{
				troopIndex = troop.troopIndex + 1;
				hpPer = troop.getHpPer();
			}
			
			var power:Number = 0;
			if (arr[0] == 1)
			{
				power = new ModelPrepare(TestCopyright.getPrepareObj(hid)).data.power;
			}
			
			var data:Object = {hid: hid, type: arr[0], lv: arr[1], gold: arr[2], canUpgrade: canUpgrade, index: troopIndex, hpPer: hpPer, power: power};
			return data;
		}
		
		private function onRender(cell:Box, index:int):void
		{
			//如果索引不再可索引范围，则终止该函数
			if (index > this.dataArr.length) return;
			//获取当前渲染条目的数据
			var data:Object = this.dataArr[index];
			var item:fightCountryTurnItemUI = cell.getChildByName('heroItem') as fightCountryTurnItemUI;
			item.heroItem.setHeroIcon(data.hid);
			item.textLv.text = data.lv.toString();
			
			var str:String;
			var fontSize:int = 16;
			var colorStr:String;
			if (data.type == 1)
			{
				if (data.index == 0){
					str = '战斗中';
					colorStr = '#DD6600';
					fontSize = 25;
				}else if (data.index > 0){
					str = '顺序'+ data.index;
					colorStr = '#334488';
				}
				else{
					str = '已阵亡';
					colorStr = '#660000';
				}
			}
			else{
				str = '未招募';
				colorStr = '#008800';
			}
			
			item.textIndex.text = str;
			item.textIndex.fontSize = fontSize;
			item.textIndex.strokeColor = colorStr;
			
			item.textPower.text = data.power == 0 ? '' : '战力 ' + Tools.textSytle(data.power);
			item.hpBar.value = data.type ? data.hpPer : 1;
			
			var btnBox:Box = cell.getChildByName('btnBox') as Box;
			var btn:Button = btnBox.getChildByName('btn') as Button;

			if (data.canUpgrade && data.index != 0)
			{
				btn.disabled = false;
				btnBox.alpha = 1;
				if (!Tween.hasTween(btnBox)){

					//EffectManager.tweenLoop( btnBox, {y:100}, 400, Ease.sineInOut, null, 0, 2, 400);
					Tween.to(btnBox, {scaleX:1, scaleY:1},300,Ease.backOut);
					EffectManager.tweenShake( btnBox, {rotation:5}, 100, Ease.sineInOut, null, Math.random() * 2000 + 300, -1, 2000);
					
				}
			}
			else
			{
				btnBox.rotation = 0;
				btnBox.scale(0.8, 0.8);
				btnBox.y = 117;
				Tween.clearAll(btnBox);
				btn.disabled = true;
				btnBox.alpha = 0.5;
			}
			
			//var goldItem:ComPayType = btnBox.getChildByName('gold') as ComPayType;
			//goldItem.setData(AssetsManager.getAssetsUI(AssetsManager.IMG_GOLD), Tools.textSytle(data.gold));
			
			var imgUpgrade:Image = btnBox.getChildByName('imgUpgrade') as Image;
			imgUpgrade.skin = data.type ? (data.lv % 10 == 9 ? 'ui/home_28.png':'ui/home_04.png') : 'ui/home_06.png';
			
			var textGold:Label = btnBox.getChildByName('textGold') as Label;
			textGold.text = Tools.textSytle(data.gold);
		}
		
		private function onMouse(e:Event, index:int):void
		{
			//鼠标单击事件触发
			if (e.type == Event.CLICK)
			{
				//判断点击事件类型,如果点中的是checkBox组件执行
				if ((e.target) is Button)
				{
					//记录当前条目所包含组件的数据信息(避免后续删除条目后数据结构显示错误)
					var tempObj:Object = this.dataArr[index];
					var hid:String = tempObj.hid;
					TestCopyright.sendUpgradeHero(hid);
					
					EffectManager.popAnimation('glow011',Laya.stage.mouseX,Laya.stage.mouseY,FightMain.instance.ui.effectLayer);
					
					
				}
			}
		}
	}

}