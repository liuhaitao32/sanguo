package sg.fight.client.view
{
	import laya.ui.Box;
	import laya.utils.Handler;
	import sg.manager.ModelManager;
	import sg.model.ModelItem;
	import sg.model.ModelProp;
	import sg.utils.Tools;
	import ui.bag.bagItemUI;
	import ui.battle.fightRewardUI;
	
	/**
	 * 战斗中奖励面板
	 * @author zhuda
	 */
	public class ViewFightReward extends fightRewardUI
	{
		private var propModel:ModelProp;
		private var dataArr:Array;
		private var rewardData:Object;
		private var waveTotal:int;
		
		public function ViewFightReward(rewardData:Object, waveKill:int, waveTotal:int = -1)
		{
			this['noAlignByPC'] = 1;
			super();
			this.width = this._width;
			
			this.propModel = ModelManager.instance.modelProp;
			this.rewardData = rewardData;
			this.waveTotal = waveTotal;
			this.list.mouseEnabled = true;
			this.list.hScrollBarSkin = '';
			
			this.list.renderHandler = new Handler(this, this.onRender);
			
			this.onChange(waveKill);
		}
		
		///更新所有奖励数据
		override public function onChange(type:* = null):void
		{
			var waveKill:int;
			if (type != null)
			{
				waveKill = type;
			}
			else{
				waveKill = 100;
			}
			//this.dataArr = [];
			var tempData:Object = {};
			if(this.rewardData){
				for (var i:int = 0; i < waveKill; i++)
				{
					var rewardOne:* = this.rewardData[i.toString()];
					if (rewardOne){
						if (rewardOne is Array)
						{
							var itemId:String = rewardOne[0];
							if (!tempData.hasOwnProperty(itemId)){
								tempData[itemId] = 0;
							}
							tempData[itemId] += rewardOne[1];
						}
						else{
							for(var key:String in rewardOne){
								//对象
								if (!tempData.hasOwnProperty(key)){
									tempData[key] = 0;
								}
								tempData[key] += rewardOne[key];
							}
						}
					}
				}
			}
			this.dataArr = this.propModel.getRewardProp(tempData,true);
			this.list.array = this.dataArr;
			
			var info:String = Tools.getMsgById('fightKillWave',[waveKill]);
			if (this.waveTotal >= 0)
				info += ' / ' + this.waveTotal;
			this.textInfo.text = info;
			//this.list.scrollTo(Math.min(i,len-1));
		}
		
		
		private function onRender(cell:Box, index:int):void
		{
			var it:Array = this.list.array[index];
			var icon:bagItemUI = cell.getChildByName('icon') as bagItemUI;
			//icon.setData(it.icon, it.ratity, '', it.addNum + '', it.type);
			icon.setData(it[0],it[1],-1);
		}
	}

}