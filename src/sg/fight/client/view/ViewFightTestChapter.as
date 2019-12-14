package sg.fight.client.view 
{
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Button;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.utils.Handler;
	import sg.fight.FightMain;
	import sg.fight.client.utils.FightViewUtils;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.test.TestCopyrightData;
	import sg.manager.ModelManager;
	import ui.battle.fightTestChapterUI;
	/**
	 * 章节选择
	 * @author zhuda
	 */
	public class ViewFightTestChapter extends fightTestChapterUI
	{
		private var dataArr:Array;
		
		public function ViewFightTestChapter() 
		{
			this.list.mouseEnabled = true;
			//
			this.list.renderHandler = new Handler(this, this.onRender);
			this.list.mouseHandler = new Handler(this, this.onMouse);
			this.btnClose.on(Event.CLICK, this, this.onClose);

			this.onChange();
		}
		public function onClose():void
		{
			//this.mouseEnabled = false;
			//this.removeSelf();
			//Tools.destroy(this);
			//this.dataArr = null;
			FightMain.instance.ui.closePopView();
			//this.destroy();
		}
		
		override public function onChange(type:* = null):void
		{
			//更新每个章节的数据
			if (type == null)
			{
				this.dataArr = [];
				var len:int = ConfigFight.testChapter.length;
				for (var i:int = 0; i < len; i++)
				{
					var data:Object = this.getOneChapterData(i);
					this.dataArr.push(data);
					if (!data.isOpen)
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
				this.list.changeItem(index, this.getOneChapterData(index));
			}
		
			//this.gold_var.setData(AssetsManager.getAssetsUI(AssetsManager.IMG_GOLD),Tools.textSytle(ModelManager.instance.modelUser.gold));
		}

		
		private function getOneChapterData(index:int):Object
		{
			var configObj:Object = ConfigFight.testChapter[index];
			var troopArr:Array = configObj.troop;

			
			var data:Object = {title: configObj.title, lv: troopArr[troopArr.length-1].lv, num: troopArr.length, isCurr: index == TestCopyrightData.currChapter, isOpen: index <= ModelManager.instance.modelUser.records.testChapter, index: index+1};
			return data;
		}
		
		private function onRender(cell:Box, index:int):void
		{
			//如果索引不再可索引范围，则终止该函数
			if (index > this.dataArr.length) return;
			//获取当前渲染条目的数据
			var data:Object = this.dataArr[index];
			var btn:Button = cell.getChildByName('btn') as Button;
			var imgCurr:Image = btn.getChildByName('imgCurr') as Image;
			var img:Image = btn.getChildByName('img') as Image;
			var textNum:Label = img.getChildByName('textNum') as Label;
			var textName:Label = btn.getChildByName('textName') as Label;
			var textTroop:Label = btn.getChildByName('textTroop') as Label;
			var textLv:Label = btn.getChildByName('textLv') as Label;
			
			imgCurr.visible = data.isCurr;
			textNum.text = data.index;
			textName.text = data.title;
			textTroop.text = '敌军数量 ' + data.num;
			textLv.text = '敌首等级 ' + data.lv;
			if (data.isOpen)
			{
				btn.disabled = false;
				btn.alpha = 1;
			}
			else{
				btn.disabled = true;
				btn.alpha = 0.5;
			}
			
		}
		
		private function onMouse(e:Event, index:int):void
		{
			//鼠标单击事件触发
			if (e.type == Event.CLICK)
			{
				//判断点击事件类型,如果点中的是checkBox组件执行
				if ((e.target) is Button)
				{
					TestCopyrightData.currChapter = index;
					this.onClose();
					FightViewUtils.onExit();
				}
			}
		}
	}

}