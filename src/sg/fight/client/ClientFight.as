package sg.fight.client
{
	import laya.display.Sprite;
	import laya.maths.MathUtil;
	import sg.cfg.ConfigApp;
	import sg.cfg.ConfigServer;
	import sg.fight.FightMain;
	import sg.fight.client.ClientBattle;
	import sg.fight.client.interfaces.IClientUnit;
	import sg.fight.client.spr.FPerson;
	import sg.fight.client.unit.ClientTroop;
	import sg.fight.client.utils.FightPlayback;
	import sg.fight.client.utils.FightTime;
	import sg.fight.client.utils.FightViewUtils;
	import sg.fight.logic.FightLogic;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.logic.fighting.TroopFighting;
	import sg.fight.logic.unit.TroopLogic;
	import sg.fight.logic.utils.FightInterface;
	import sg.fight.logic.utils.FightPrint;
	import sg.fight.logic.utils.FightUtils;
	import sg.fight.test.TestFightData;
	import sg.fight.test.TestPrint;
	import sg.model.ModelFormation;
	import sg.model.ModelSkill;
	import sg.utils.Tools;
	
	/**
	 * 正在对战的双方
	 * @author zhuda
	 */
	public class ClientFight extends FightLogic
	{
		public var fightMain:FightMain;
		public var fightPlayback:FightPlayback;
		public var playbackRound:int;
		///这场战斗结束的秒数时间点，如果设置了，则不能在此前跳过
		//public var endTime:Number;
		///是否已经和服务端对比过战报
		public var hasCheckRecord:Boolean;
		
		//国战返回的奖励
		public var npc_reward:Object;
		
		public function get isEnd():Boolean
		{
			if (this.fightPlayback == null){
				return true;
			}
			return false;
		}
		
		public function getClientBattle():ClientBattle
		{
			return this.fightMain.client;
		}
		
		/**
		 * 得到正在作战的部队，0左1右
		 */
		public function getClientTroop(teamIndex:int):ClientTroop
		{
			return this.getTroop(teamIndex) as ClientTroop;
		}
		/**
		 * 得到指定部队的对应单位
		 */
		public function getClientUnit(teamIndex:int,armyIndex:int):IClientUnit
		{
			var troop:ClientTroop = this.getClientTroop(teamIndex);
			return troop.getClientUnit(armyIndex);
		}
		/**
		 * 是否是客户端版
		 */
		override public function get isClient():Boolean
		{
			return true;
		}
		
		public function ClientFight(fightMain:FightMain, data:Object)
		{
			this.fightMain = fightMain;
			super(data);
			this.npc_reward = data.npc_reward;
			this.playbackRound = 0;
			
			//trace('这是第' + this.fightCount + '战！');
			//this.testStatisticsPrint();
		}
		
		/**
		 * 对比前后端战报结果
		 */
		public function checkRecord(serverRecord:Object):void
		{
			if(!this.hasCheckRecord && !ConfigApp.testFightType){
				var clientRecord:Object = this.getRecord();
				var b:Boolean = FightUtils.compareObj(clientRecord, serverRecord);
				FightPrint.showFightRecordCompare(b, clientRecord, serverRecord);
				this.hasCheckRecord = true;
			}
		}
		
		override public function initTroopLogicArr():Array
		{
			var troop0:ClientTroop = this.fightMain.client.getClientTeam(0).getClientTroop(0);
			var troop1:ClientTroop = this.fightMain.client.getClientTeam(1).getClientTroop(0);
			return [troop0, troop1];
		}
		

		private function initTroops():void
		{
			var arr:Array = [];
			for (var i:int = 0; i < 2; i++){
				var clientTroop:ClientTroop = this.getClientTroop(i);
				clientTroop.fight = this;
				arr.push(clientTroop);
				
				//clientTroop.show();
				//FightTime.timer.clear(clientTroop, clientTroop.back);
			}	
			//初始化双方英雄信息
			if(this.fightMain.ui.heroUI)
				this.fightMain.ui.heroUI.initData(arr);
			
			this.sortTroops();
		}
		/**
		 * 排序当前对战双方单位
		 */
		public function sortTroops():void
		{
			var clientTroop0:ClientTroop = this.getClientTroop(0);
			var clientTroop1:ClientTroop = this.getClientTroop(1);
			
			var personList:Array = clientTroop0.persons.concat(clientTroop1.persons);
			personList.sort(MathUtil.sortByKey('sortValue', true));
			var len:int = personList.length;
			var unitLayer:Sprite = FightMain.instance.scene.unitLayer;
			for (var i:int = 0; i < len; i++)
			{
				var person:FPerson = personList[i];
				if (person.spr != null)
				{
					person.forcedRender = true;
					unitLayer.setChildIndex(person.spr, len - i - 1);
				}
			}
		}

		/**
		 * 战斗逻辑执行完毕后，自动加载并播放战报
		 */
		override public function start():void
		{
			//战斗逻辑开始，并结束
			super.start();
			//逻辑结束
			this.initTroops();
			
			//if (this.isWavePVE){
				//this.endTime = ConfigServer.getServerTimer() / 1000 + this.getRecordTime();
			//}
			
			var troop0:ClientTroop = this.getClientTroop(0);
			var troop1:ClientTroop = this.getClientTroop(1);
			
			troop0.fightTroopInfo.updateFirst(this.priorityIndex == 0);
			troop1.fightTroopInfo.updateFirst(this.priorityIndex == 1);
			troop0.fightTroopInfo.updateAdept(ModelFormation.checkAdept(troop0.formationType,troop1.formationType,troop0.formationStar));
			troop1.fightTroopInfo.updateAdept(ModelFormation.checkAdept(troop1.formationType,troop0.formationType,troop1.formationStar));
			
			//测试回放数据
			//this.playbacks = TestFightData.getPlaybacks();
			this.getClientBattle().fightLoad.initLoadPlayback();
		}
		/**
		 * 完全加载好资源，开始战报播放
		 */
		public function startPlaybacks():void
		{
			//this.playbacks = TestFightData.getPlaybacks();
			this.fightPlayback = new FightPlayback(this);
			
			if (this.speedUp){
				Laya.timer.frameOnce(1, this, this.skip);
			}
		}
		/**
		 * 重播战斗回放
		 */
		public function replay():void
		{
			if (this.fightPlayback != null)
			{
				this.fightPlayback.replay();
				this.sortTroops();
				this.fightMain.scene.removeEffects();
			}
		}
		/**
		 * 跳过一场战斗回放
		 */
		public function skip():void
		{
			if (this.fightPlayback != null)
			{
				this.fightPlayback.skip();
				this.fightMain.scene.removeEffects();
				//trace('skipskipskip!!!!!BBBBBBBB');
				
				FightTime.timer.clear(null, FightViewUtils.shockSpr);
			}
		}
		
		private static var JSON_STRINGIFY_ARR:Array = ['uid', 'hid', 'skill', 'army'];
		
		private function sortUp(x:*,y:*):*{
			return x[0].localeCompare(y[0]);
		}
		/**
		 * 测试显示初始化数据打印(纯客户端使用)
		 */
		override public function testPrint(troopFighting:TroopFighting, index:int):void
		{
			if (FightLogic.canPrint || ConfigApp.testFightType == 1)
			{
				TestPrint.instance.clear(index * 2);
				var data:Object = troopFighting.getCurrData();
				delete data.special;
				delete data.str;
				delete data.agi;
				delete data.cha;
				delete data.lead;
				
				delete data.special;
				delete data.armyRank;
				delete data.country;
				delete data.lv;
				delete data.proud;
				delete data.rarity;
				delete data.sex;
				delete data.title;
				delete data.type;
				delete data.uid;
				delete data.uname;
				
				var skills:Object = data.skill;
				for (var key:String in skills){
					var name:String = ModelSkill.getSkillName(key);
					if (name){
						skills[key + ' ' + name] = skills[key];
						delete skills[key];
					}
				}
	
				var arr:Array = FightUtils.toArray(data, 1);
				arr.sort(sortUp);
				TestPrint.instance.print(JSON.stringify(arr, null, 3), index * 2);
			}
			
		}
		
		override public function clear():void
		{
			super.clear();
			this.fightMain = null;

			//this.fightPlayback.clear();
			this.fightPlayback = null;
		}
	}

}