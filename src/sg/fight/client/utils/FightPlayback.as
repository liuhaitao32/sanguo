package sg.fight.client.utils
{
	import sg.cfg.ConfigApp;
	import sg.fight.client.ClientBattle;
	import sg.fight.client.ClientFight;
	import sg.fight.client.cfg.ConfigFightView;
	import sg.fight.client.interfaces.IClientUnit;
	import sg.fight.client.spr.FEffect;
	import sg.fight.client.unit.ClientArmy;
	import sg.fight.client.unit.ClientHero;
	import sg.fight.client.unit.ClientTroop;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.logic.utils.FightPrint;
	import sg.fight.test.TestCopyright;
	import sg.fight.test.TestFightData;
	
	/**
	 * 战斗回放相关
	 * @author zhuda
	 */
	public class FightPlayback
	{
		public var step:int;
		public var fight:ClientFight;
		
		public function FightPlayback(fight:ClientFight)
		{
			this.fight = fight;
			this.step = -1;
			
			var isSkip:Boolean = false;
			var clientBattle:ClientBattle = fight.getClientBattle();
			if (clientBattle.checkSkip()){
				isSkip = true;
			}
			//if (fight.speedUp){
				//isSkip = true;
			//}
			//trace('战报：',this.fight.playbacks);
			
			
			this.nextPlayback(isSkip);
		}
		
		/**
		 * 播放回放
		 */
		private function nextPlayback(isSkip:Boolean = false):void
		{
			if (this.fight.isCleared) return;
			this.step++;
			var clientBattle:ClientBattle = this.fight.getClientBattle();
			
			//if (isSkip){
				////直接跳过所有步骤，更新为最终状态
			//}

			if (this.fight.playbacks.length == this.step)
			{
				print('回放完成！');
				clientBattle.playbackEnd();
					//this.endPlayback();
			}
			else
			{
				var obj:Object = this.fight.playbacks[this.step];
				this.doPlayback(obj, isSkip);
				
				//特殊测试，掉落银币
				//if (TestFightData.isTestCopyright){
					//TestCopyright.sendGainGold(this.step *this.step *this.step * 100 +50);
				//}
			}
		}
		
		/**
		 * 重播回放
		 */
		public function replay():void
		{
			FightTime.clearAll();
			this.fight.getClientTroop(0).resetPos();
			this.fight.getClientTroop(1).resetPos();
			
			this.step = -1;
			this.nextPlayback();
		}
		
		/**
		 * 跳过回放
		 */
		public function skip():void
		{
			if (this.fight.isCleared) return;
			
			FightTime.clearAll();
			this.fight.getClientTroop(0).skip();
			this.fight.getClientTroop(1).skip();
			
			this.nextPlayback(true);
		}
		
		/**
		 * 播放一条回放
		 */
		private function doPlayback(obj:Object, isSkip:Boolean = false):void
		{
			//FightUtils.traceStr('播放回放 ' + JSON.stringify(obj));
			//trace(this.step,obj);
			if (obj == null)
			{
				return;
			}
			var key:String = obj.key;
			var time:int = 0;
			if (key == 'start')
			{
				time = obj.time;
			}
			else if (key == 'round')
			{
				time = this.playbackRound(obj.time, obj.value, isSkip);
			}
			else if (key == 'act')
			{
				time = this.playbackAct(obj.time, obj.value, isSkip);
			}
			else if (key == 'removeBuff')
			{
				time = this.playbackRemoveBuff(obj.value);
			}
			else if (key == 'shogun') 
			{
				time = this.playbackShogun(obj.time, obj.value, isSkip);
			}
			else if (key == 'spirit') 
			{
				time = this.playbackSpirit(obj.time, obj.value, isSkip);
			}
			else if (key == 'cut') 
			{
				time = this.playbackCut(obj.time, isSkip);
			}
			else if (key == 'wait')
			{
				time = this.playbackWait(obj.time);
			}
			else
			{
				//不能识别的回放
				print(' ！！！不能识别的回放');
			}
			//结束后到下一步
			if (isSkip)
			{
				this.nextPlayback(isSkip);
			}
			else
			{
				FightTime.delayTo(time, this, this.nextPlayback);
					//FightTime.timer.once(time, this, this.nextPlayback);
			}
		
		}
		
		/**
		 * 回放：主行动， 返回真实等待时间
		 */
		private function playbackAct(time:int, value:Object, isSkip:Boolean = false):int
		{
			print(' 主行动 ' + time, value);
			var srcArr:Array = value.src;
			var tgtArr:Array = value.tgt;
			var fateArr:Array = value.fate;
			var energyArr:Array;
			
			var atkEffObj:Object = FightViewUtils.getEffectObj(value.effs);
			var tempObj:Object;
			var tempArr:Array;
			var tempStr:String;
			var unitObj:Object;
			var unitArr:Array;
			var srcUnit:IClientUnit;
			var tgtUnit:IClientUnit;
			
			var baseTime:int = time;
			var actTime:int = 0;
			var len:int;
			var i:int;
			var fireObj:Object = atkEffObj.fire;
			var hurtObj:Object = atkEffObj.hurt;
			var hitTime:int = 0;
			var comboTime:int = ConfigFightView.HURT_COMBO_TIME;
			var endTime:int = ConfigFightView.HURT_END_TIME;
			if (hurtObj)
			{
				if (hurtObj.hasOwnProperty('hitTime'))
					hitTime = hurtObj.hitTime;
				if (hurtObj.hasOwnProperty('time'))
					comboTime = hurtObj.time;
				if (hurtObj.hasOwnProperty('endTime'))
					endTime = hurtObj.endTime;
			}
			


			
			unitObj = srcArr[0];
			//var srcIsHero:Boolean = srcUnit.getArmyIndex() == 2;
			
			
			if (!isSkip)
			{
				unitArr = unitObj.unit;
				srcUnit = this.fight.getClientUnit(unitArr[0], unitArr[1]);
				var startEffObj:Object = {};
				if (fateArr){
					startEffObj.fate = fateArr;
				}
				if (atkEffObj.noImg){
					startEffObj.noImg = 1;
				}
				if (atkEffObj.bannerTime){
					startEffObj.bannerTime = atkEffObj.bannerTime;
				}
				if (value.comp){
					startEffObj.comp = value.comp;
				}
				if (value.bash){
					startEffObj.bash = value.bash;
				}
				//动作兽灵目标描述，用于兽灵净化驱散必中等
				if (value.beast){
					startEffObj.beast = value.beast;
				}
				else{
					len = tgtArr.length;
					if (len > 0){
						tempArr = tgtArr[0].removeBuffs;
						if (tempArr){
							tempStr = tempArr[0];
							if (ConfigFight.buffDefault[tempStr]){
								tempStr = ConfigFight.buffDefault[tempStr].name;
							}
							startEffObj.beast = tempStr;
						}
					}
				}
				if (startEffObj.beast){
					len = tgtArr.length;
					if (len > 0){
						startEffObj.beastTgt = tgtArr[0].unit;
					}
				}
				
				
				actTime += FightViewUtils.showInfo(srcUnit, unitObj, startEffObj, 0);
				if (fireObj)
				{
					//前摇  原地施法，放出特效
					FightTime.delayTo(actTime, srcUnit, srcUnit.fire, [fireObj]);
					FightViewUtils.autoPlaySound(fireObj, actTime);
					actTime += fireObj.time;
				}
				var timeArr:Array = FightViewUtils.doAction(srcUnit, unitObj, tgtArr, atkEffObj, fateArr, actTime);
				actTime += timeArr[0];
				endTime += timeArr[1] + hitTime;
				
				time = Math.max(time, actTime + endTime);
				
				var shock:int = atkEffObj.hurt ? (atkEffObj.hurt.shock ? atkEffObj.hurt.shock : 0) : 0;
				//shock = 200;
				//if (shock && this.fight.fightMain.ui.popLayer.numChildren == 0)
				if (shock && FightTime.timer.scale <= ConfigFight.fightShockSpeed)
				{
					//震屏
					FightTime.delayTo(actTime + hitTime, null, FightViewUtils.shockSpr, [shock, this.fight.fightMain.scene.allLayer]);
				}
				
				energyArr = unitObj.energy;
				if (energyArr)
				{
					//消耗能量
					srcUnit.getClientTroop().changeEnergy(energyArr[0],energyArr[1]);
				}
			}

			len = tgtArr.length;
			var hurtTimes:Object = {};
			for (i = 0; i < len; i++)
			{
				unitObj = tgtArr[i];
				unitArr = unitObj.unit;
				tgtUnit = this.fight.getClientUnit(unitArr[0], unitArr[1]);
				
				var fid:String = tgtUnit.getFightId();
				if (!hurtTimes.hasOwnProperty(fid)){
					hurtTimes[fid] = 0;
				}
				hurtTimes[fid]++;
				
				if (!isSkip)
				{
					var defEffObj:Object = atkEffObj;
					var arr:Array = unitObj.effs;
					if (arr){
						defEffObj = FightViewUtils.getEffectObj([atkEffObj].concat(arr));
					}

					FightViewUtils.showInfo(tgtUnit, unitObj, defEffObj, actTime, hurtTimes[fid]);
					actTime += comboTime;
					time += comboTime;
				}
				else
				{
					var hurtArr:Array = unitObj.hurt;
					tgtUnit.changeHp(hurtArr[2], null);
				}
				
				energyArr = unitObj.energy;
				if (energyArr)
				{
					//获得能量
					tgtUnit.getClientTroop().changeEnergy(energyArr[0],energyArr[1]);
				}
			}
			
			//败者英雄要和其他人一起死
			//if(tgtUnit){
				//var clientTroop:ClientTroop = tgtUnit.getClientTroop();
				//if(clientTroop.getHpPer(isSkip) == 0){
					//var clientHero:ClientHero = clientTroop.getClientHero();
					//FightTime.delayTo(actTime, clientHero, clientHero.changeHp, [0, null, false]);
				//}
			//}
			//else{
				////trace('playbackAct丢失了目标！！！' + value);
			//}
			
			
			//最后一回合，败者英雄要和其他人一起死
			if (this.fight.playbacks.length - 1 == this.step)
			{
				var clientTroop:ClientTroop = this.fight.getClientTroop(this.fight.loser);
				if(clientTroop.getHpPer(true) == 0){
					var clientHero:ClientHero = clientTroop.getClientHero();
					FightTime.delayTo(actTime, clientHero, clientHero.changeHp, [0, null, false]);
				}else{
					//胜负未完全决出，失败方败走
					//clientTroop = this.fight.getClientTroop(this.fight.loser);
					//clientTroop.back(true);
				}
			}

			//else{
				////trace('playbackAct丢失了目标！！！' + value);
			//}
			if (baseTime == 0){
				//trace('noHurt计算时间:  ' + time);
				time = 0;
			}
			return time;
		
		}
		
		/**
		 * 回放：修改回合
		 */
		private function playbackRound(time:int, value:int, isSkip:Boolean = false):int
		{
			print(' 修改回合 ' + time + '   ' + value);
			if (!isSkip)
			{
				this.fight.playbackRound = value;
				if (value < ConfigFightView.ROUND_OFFSET.length)
				{
					var oldRound:int = Math.max(value - 1, 0);
					var offset:int = ConfigFightView.ROUND_OFFSET[value] - ConfigFightView.ROUND_OFFSET[oldRound];
					//向前移动
					if (offset > 0)
					{
						var i:int;
						for (i = 0; i < 2; i++)
						{
							var clientTroop:ClientTroop = this.fight.getClientTroop(i);
							clientTroop.moveForward(offset);
							clientTroop.playbackRound = value;
						}
					}
				}
			}
			if (this.fight.fightMain.ui.roundUI)
				this.fight.fightMain.ui.roundUI.updateData(value);
			//new FWord(this.fightMain.scene, '第' + value + '回合', 0, 50, 290,false,0,0);
			
			return time;
		}
		
				
		/**
		 * 回放：移除指定buff
		 */
		private function playbackRemoveBuff(valueObj:Object):int
		{
			print(' 移除指定buff ' + valueObj.id);
			var unitArr:Array = valueObj.unit;
			var unit:IClientUnit = this.fight.getClientUnit(unitArr[0], unitArr[1]);
			unit.removeBuff(valueObj.id);
			return 0;
		}
		
		
		/**
		 * 回放：双方激励加成
		 */
		private function playbackSpirit(time:int, arr:Array, isSkip:Boolean = false):int
		{
			print(' 激励加成 ' + time + '   ' + arr);
			if (!isSkip)
			{
				var i:int;
				for (i = 0; i < 2; i++)
				{
					var troopObj:Object = arr[i];
					if (troopObj){
						FightViewUtils.showSpirit(this.fight,this.fight.getClientTroop(i), troopObj);
					}
				}
			}
			return time;
		}
		/**
		 * 回放：双方幕府加成
		 */
		private function playbackShogun(time:int, arr:Array, isSkip:Boolean = false):int
		{
			print(' 幕府加成 ' + time + '   ' + arr);
			if (!isSkip)
			{
				var i:int;
				for (i = 0; i < 2; i++)
				{
					var troopArr:Array = arr[i];
					if (troopArr){
						FightViewUtils.showShogun(this.fight,this.fight.getClientTroop(i), troopArr, 500);
					}
				}
			}
			return time;
		}
		
		/**
		 * 回放：最终互怼
		 */
		private function playbackCut(time:int, isSkip:Boolean = false):int
		{
			print(' 最终互怼 ' + time);
			if (!isSkip)
			{
				var winTroop:ClientTroop = this.fight.getClientTroop(this.fight.winner);
				var loseTroop:ClientTroop = this.fight.getClientTroop(this.fight.loser);
					
				var loseHero:ClientHero = loseTroop.getClientHero();
				FightTime.delayTo(0, loseHero, loseHero.changeHp, [0, null, false]);
				
				var i:int;
				for (i = 0; i < 2; i++)
				{
					var winArmy:ClientArmy = winTroop.getClientArmy(i);
					var loseArmy:ClientArmy = loseTroop.getClientArmy(i);
					FightTime.delayTo(0, winArmy, winArmy.changeHp, [winArmy.hp, null, i==1]);
					FightTime.delayTo(0, loseArmy, loseArmy.changeHp, [loseArmy.hp, null, i==1]);
				}
			}
			return time;
		}
		
		/**
		 * 回放：只是暂停
		 */
		private function playbackWait(time:int):int
		{
			print(' 暂停 ' + time);
			return time;
		}
		
		/**
		 * 打印(纯客户端使用)
		 */
		public static function print(str:String, data:Object = null):void
		{
			FightPrint.checkPrint('FightPlayback', str, data);
		}
	}

}