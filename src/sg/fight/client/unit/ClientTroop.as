package sg.fight.client.unit {
	import laya.display.Sprite;
	import laya.maths.MathUtil;
	import sg.cfg.ConfigApp;
	import sg.cfg.ConfigServer;
	import sg.fight.FightMain;
	import sg.fight.client.ClientBattle;
	import sg.fight.client.ClientFight;
	import sg.fight.client.cfg.ConfigFightView;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.logic.utils.FightUtils;
	import sg.manager.ViewManager;
	import sg.map.utils.TestUtils;
	import sg.model.ModelFormation;
	import sg.fight.client.interfaces.IClientUnit;
	import sg.fight.client.spr.FPerson;
	import sg.fight.client.spr.FTroopFlag;
	import sg.fight.client.spr.FTroopInfo;
	import sg.fight.client.unit.ClientAdjutant;
	import sg.fight.client.unit.ClientArmy;
	import sg.fight.client.unit.ClientHero;
	import sg.fight.client.unit.ClientTeam;
	import sg.fight.client.utils.FightTime;
	import sg.fight.client.view.FightScene;
	import sg.fight.logic.unit.AdjutantLogic;
	import sg.fight.logic.unit.ArmyLogic;
	import sg.fight.logic.unit.HeroLogic;
	import sg.fight.logic.unit.TeamLogic;
	import sg.fight.logic.unit.TroopLogic;
    
    /**
     * 战斗场景中的，由单个主将率领的部队，包含英雄hero，前军army，后军army
     * @author zhuda
     */
    public class ClientTroop extends TroopLogic {
        public var fight:ClientFight;
        public var teamLogic:TeamLogic;
        
        public var fightTroopFlag:FTroopFlag;
        public var fightTroopInfo:FTroopInfo;
        public var posX:Number;
        ///初始化坐标
        private var _posX:Number;
        public var persons:Array;
        ///是否已初始化过
        public var isInit:Boolean;
        ///是否已显示
        public var isShow:Boolean;
		///设定固定的开场白，有此值时优先发言
		public var speak:String;
		
		///回放当前回合
		public var playbackRound:int;

        
        public function getCenterX():Number {
            return this.posX + (this.isFlip ? 50 : -50);
        }
        
        /**
         * 得到对手，如果不在战斗返回空
         */
        public function getEnemyTroop():ClientTroop {
            if (this.fight == null) {
                return null;
            }
            return this.fight.getClientTroop(this.enemyTeamIndex);
        }
        
		public function getScene():FightScene {
            return this.getClientTeam().getClientBattle().fightMain.scene;
        }
		
        public function getClientTeam():ClientTeam {
            return this.teamLogic as ClientTeam;
        }
        
        public function getClientHero():ClientHero {
            return this.heroLogic as ClientHero;
        }
        
        public function getClientAdjutant(adjutantIndex:int):ClientAdjutant {
            return this.adjutants[adjutantIndex] as ClientAdjutant;
        }
		/**
		 * 得到指定hid的副将
		 */
		public function getClientAdjutantById(hid:String):ClientAdjutant
		{
			var adjutant:ClientAdjutant;
			adjutant = this.getClientAdjutant(0);
			if(adjutant && adjutant.id==hid)
				return adjutant;
			adjutant = this.getClientAdjutant(1);
			if(adjutant && adjutant.id==hid)
				return adjutant;
			return null;
		}
        
        public function getClientArmy(armyIndex:int):ClientArmy {
            return this.armys[armyIndex] as ClientArmy;
        }
        
        public function getClientUnit(armyIndex:int):IClientUnit {
            if (armyIndex == 2)
                return this.getClientHero();
			else if (armyIndex < 2)
                return this.getClientArmy(armyIndex);
            return this.getClientAdjutant(armyIndex-3);
        }
        
        public function get isFlip():Boolean {
            return this.teamIndex == 1;
        }
        
		/**
		 * 得到当前阵法的特效配置数据
		 */
		public function getFormation():ModelFormation
		{
			return ModelFormation.getModel(this.formationType);
		}
		
		
        public function ClientTroop(data:*, teamLogic:TeamLogic, troopIndex:int) {
            this.teamLogic = teamLogic;
            super(data, teamLogic.teamIndex, troopIndex);
        }
        /**
         * 追加部队资源ok，但此时可能已退出战斗
         */
        public function checkShow():void {
			if (!this.isCleared){
				if (this.troopIndex < ConfigFightView.TROOP_SHOW_MAX) {
					this.show();
				}
				else {
					this.back(true);
				}
			}
        }
        
		/**
         * 获得服务器数据，与当前状况对比，不同处刷新
         */
        public function resetDataAndLogic(data:*):void {
			this.teamLogic.packCountryNPCTroopName(data);
			if (!this.checkCompData(data)){
				//如果uid hid或任意army hp hpm不同，认为是核心不同，必须刷新
				this.clearSelf();
				this.setData(data);
				this.isInit = false;
				this.initShow();
				if (TestUtils.isTestShow || ConfigApp.testFightType){
					ViewManager.instance.showTipsTxt('参战部队变更');
				}
			}else{
				//核心相同，只刷新关键数据，不重置对象
				this.resetLogicData(data);
			}
        }
		/**
         * 对比部分数据，如果uid hid或任意army hp hpm不同，认为是核心不同，返回false必须刷新显示
         */
        private function checkCompData(data:*):Boolean {
			if(data.uid != this.uid)
				return false;
			if(data.hid != this.hid)
				return false;
			for (var i:int = 0; i < 2; i++) 
			{
				var army:ArmyLogic = this.getArmy(i);
				if (army.hp != data.army[i].hp || army.hpm != data.army[i].hpm){
					return false;
				}
			}
			return true;
        }
		private function resetLogicData(data:*):void
		{
			this.resetData(data);
			this.updateLogicData();
		}
		
		
        /**
         * 显示部队并排序
         */
        public function show():void {
            if (this.isInit) {
				FightTime.timer.clear(this, this.back);
                if (!this.isShow) {
                    //隐藏过，重新显示
                    this.reShow();
                }
            }
            else {
                this.initShow();
            }
        }
        
        /**
         * 初始化显示
         */
        public function initShow():void {
            this.isInit = true;
            this.isShow = true;
            
            this.updatePosX();
            
            this.getClientHero().show();
            var i:int;
            for (i = this.adjutants.length - 1; i >= 0; i--) {
                var adjutant:ClientAdjutant = this.getClientAdjutant(i);
				if(adjutant)
					adjutant.show();
            }
            for (i = this.armys.length - 1; i >= 0; i--) {
                var army:ClientArmy = this.armys[i];
                army.show();
            }
            this.initAllPersons();
            this.sortAllPersons();
            
            this.fightTroopFlag = new FTroopFlag(this);
            this.fightTroopInfo = new FTroopInfo(this);
            this.updateHp();
        }
        
        /**
         * 更新位置和显示位序
         */
        private function updatePosX():void {
            var clientBattle:ClientBattle = this.getClientTeam().getClientBattle();
            //显示位序
            var showTroopIndex:int = (clientBattle.fightLogic == null ? 0 : 1) + this.troopIndex;
            //更新位置
            this._posX = this.posX = clientBattle.fightMain.scene.centerCameraOffset + (this.teamLogic.teamIndex == 0 ? 1 : -1) * (ConfigFightView.ROUND_OFFSET[0] - ConfigFightView.TROOP_INTERVAL * showTroopIndex);
        }
        
        private function initAllPersons():void {
            //var person:FightPerson;
            this.persons = [];
            var i:int;
            var j:int;
            this.persons.push(this.getClientHero().person);
            
            for (i = this.adjutants.length - 1; i >= 0; i--) {
				var adjutant:ClientAdjutant = this.getClientAdjutant(i);
				if(adjutant){
					this.persons.push(adjutant.person);
				}
            }
            for (i = this.armys.length - 1; i >= 0; i--) {
                var army:ClientArmy = this.armys[i];
                for (j = army.persons.length - 1; j >= 0; j--) {
                    this.persons.push(army.persons[j]);
                }
            }
        }
        
        /**
         * 更新显示排序
         */
        private function sortAllPersons():void {
            this.persons.sort(MathUtil.sortByKey('sortValue', true));
            var len:int = this.persons.length;
            var unitLayer:Sprite = FightMain.instance.scene.unitLayer;
            for (var i:int = 0; i < len; i++) {
                var person:FPerson = this.persons[i];
                unitLayer.setChildIndex(person.spr, len - i - 1);
            }
        }
        
        override public function newArmy(data:*, armyIndex:int, initHp:int):ArmyLogic {
            var army:ArmyLogic = new ClientArmy(data, this, armyIndex, initHp);
            return army;
        }
        
        override public function newHero(data:*):HeroLogic {
            var hero:HeroLogic = new ClientHero(data, this);
            return hero;
        }
        
        override public function newAdjutant(data:*, adjutantIndex:int):AdjutantLogic {
            var adjutant:AdjutantLogic = new ClientAdjutant(data, this, adjutantIndex);
            return adjutant;
        }
        
        public function allPersonTo(funName:String, args:Array = null):void {
            var person:FPerson;
            var i:int;
            var len:int;
            var method:Function;
            len = this.persons.length;
            for (i = 0; i < len; i++) {
                person = this.persons[i];
                method = person[funName] as Function;
                method.apply(person, args);
            }
        }
        
		
		/**
         * 初始血量百分比
         */
        public function getInitHpPer():Number {
            var hp:int = 0;
            var hpMax:int = 0;
            
            for (var i:int = this.armys.length - 1; i >= 0; i--) {
                var army:ClientArmy = this.armys[i];
                hpMax += army.hpm;
                hp += army.initHp;
            }
            return hp / hpMax;
        }
        /**
         * 当前血量百分比
         */
        override public function getHpPer(isEnd:Boolean = false):Number {
            var hp:int = 0;
            var hpMax:int = 0;
            
            for (var i:int = this.armys.length - 1; i >= 0; i--) {
                var army:ClientArmy = this.armys[i];
                hpMax += army.hpm;
                if (isEnd) {
                    hp += army.hp;
                }
                else {
                    hp += army.lastHp;
                }
            }
            return hp / hpMax;
        }
        
        /**
         * 更新血量
         */
        public function updateHp(isEnd:Boolean = false):void {
            //this.fightTroopInfo.updateHp(this.getHpPer(isEnd));
			this.fightTroopInfo.updateArmysHp(this.getClientArmy(0),this.getClientArmy(1),isEnd);

			var clientBattle:ClientBattle = this.getClientTeam().getClientBattle();
			if(clientBattle.isCountry){
				FightMain.instance.ui.updateLowerPanel(this);
			}
        }
		/**
         * 更新能量(增量)
         */
        public function changeEnergy(energyType:String, energyNum:int):void
		{
			this.fightTroopInfo.changeEnergy(energyType,energyNum);
		}
        
        /**
         * 全军同时前进，指定速率为0时直接到达
         */
        public function moveForward(dis:Number, speedRate:Number = 1):void {
            var offset:Number = (this.isFlip ? -1 : 1) * dis;
            this.move(offset, speedRate);
        }
		
        
        /**
         * 全军同时偏移移动，指定速率为0时直接到达
         */
        public function move(offset:Number, speedRate:Number = 1):void {
            if (offset == 0)
                return;

            this.posX += offset;
            this.allPersonTo('move', [offset, speedRate]);
            this.fightTroopFlag.move(offset, speedRate);
            this.fightTroopInfo.move(offset, speedRate);
        }
        
        /**
         * 全军同时移动到目标地，指定速率为0时直接到达
         */
        public function moveTo(x:Number, speedRate:Number = 1):void {
            this.move(x - this.posX, speedRate);
        }
        
        /**
         * 全军再次显现
         */
        private function reShow():void {
			this.isShow = true;
            this.updatePosX();
            var i:int;
			var clientHero:ClientHero = this.getClientHero();
								
            clientHero.reShow();    
            for (i = this.adjutants.length - 1; i >= 0; i--) {
				var adjutant:ClientAdjutant = this.getClientAdjutant(i);
				if(adjutant)
					adjutant.reShow();
            }
            for (i = this.armys.length - 1; i >= 0; i--) {
                var army:ClientArmy = this.armys[i];
                army.changeHp(army.hp, null, false);
                army.reShow();
            }
            this.fightTroopFlag.reShow();
            this.fightTroopInfo.reShow();
            this.updateHp();
        }
        
        /**
         * 全军重置位置（仅回放用）
         */
        public function resetPos():void {
            this.posX = this._posX;
            var i:int;
            this.getClientHero().resetPos();
            
            for (i = this.adjutants.length - 1; i >= 0; i--) {
				var adjutant:ClientAdjutant = this.getClientAdjutant(i);
				if(adjutant)
					adjutant.resetPos();
            }
            for (i = this.armys.length - 1; i >= 0; i--) {
                var army:ClientArmy = this.armys[i];
                army.changeHp(army.initHp, null, false);
                army.resetPos();
            }
            this.fightTroopFlag.resetPos();
            this.fightTroopInfo.resetPos();
            this.updateHp();
        }
        
        /**
         * 跳过到最后状态
         */
        public function skip():void {
            var i:int;
            //this.getClientHero().changeHp(0, null, false);
            for (i = this.armys.length - 1; i >= 0; i--) {
                var army:ClientArmy = this.armys[i];
                army.allPersonTo('recovery', null);
                army.changeHp(army.hp, null, false);
            }
            this.updateHp(true);
        }
        
        /**
         * 战败退场并被清理
         */
        public function lose():void {
            //this.getClientHero().changeHp(0, null, false);
			if (this.getHpPer(true) == 0){
				var i:int;
				for (i = this.adjutants.length - 1; i >= 0; i--) {
					var adjutant:ClientAdjutant = this.getClientAdjutant(i);
					if(adjutant)
						adjutant.person.dead(null);
				}
				this.isInit = false;
				this.allPersonTo('disappear', [true]);
				this.fightTroopFlag.disappear(true);
				this.fightTroopInfo.disappear(true);
			}
			else{
				//胜负未完全决出，规则令失败方败走，但也无法回归
				this.back(true);
			}
        }
        
        /**
         * 战胜返场
         */
        public function winBack():void {
            this.winCheer();
            FightTime.delayTo(1000, this, this.back);
        }
        
        /**
         * 返场，isClear意味着清理资源，重新整队
         */
        public function back(isClear:Boolean = true):void {
            if (this.isInit) {
                this.moveForward( -100);
				this.isShow = false;
				if(isClear)
					this.isInit = false;

                this.allPersonTo('disappear',[isClear]);
                this.fightTroopFlag.disappear(isClear);
                this.fightTroopInfo.disappear(isClear);
            }
        }
        
        /**
         * 战胜欢呼(较为整齐)
         */
        public function winCheer():void {
            this.allPersonTo('cheer');
        }
		
		/**
         * 判断是否会响应某种弱点抗性
         */
        public function checkWeak(key:String):Boolean {
			var index:int;
			var value:int = parseInt(key.substr(key.length-1));
			index = key.indexOf('resArmy');
			if (index >-1){
				if (this.getArmyIndexByType(value) > -1){
					return true;
				}
				else{
					return false;
				}
			}
			index = key.indexOf('resType');
			if (index >-1){
				if (this.heroLogic.type == value){
					return true;
				}
				else{
					return false;
				}
			}
			index = key.indexOf('resSex');
			if (index >-1){
				if (this.heroLogic.sex == value){
					return true;
				}
				else{
					return false;
				}
			}
            return false;
        }
		
		/**
		 * 战斗结束重置
		 */
		override public function resetEnd():void
		{
			super.resetEnd();
			this.allPersonTo('removeAllAnimation');
		}
		
		public function clearSelf():void {
            super.clear();
			if (this.isInit) {
				this.fightTroopFlag.clear();
				this.fightTroopFlag = null;
				
				this.fightTroopInfo.clear();
				this.fightTroopInfo = null;
				
				this.allPersonTo('clear');
				this.persons = null;
			}
        }
        
        override public function clear():void {
            //可能被清理多次，先判断
            if (!this.isCleared) {
				this.clearSelf();
                this.fight = null;
                this.teamLogic = null;
            }
        }
    }

}