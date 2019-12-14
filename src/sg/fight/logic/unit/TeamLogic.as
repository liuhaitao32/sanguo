package sg.fight.logic.unit 
{
	import sg.cfg.ConfigServer;
	import sg.fight.logic.BattleLogic;
	import sg.fight.logic.FightLogic;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.logic.unit.LogicBase;
	import sg.map.model.entitys.EntityCity;
	import sg.utils.Tools;
	/**
	 * 双方排队
	 * @author zhuda
	 */
	public class TeamLogic extends LogicBase
	{
		public var uid:int;
		public var uname:String;
		//所属国家
		public var country:int;
		
		///卜卦效果，只有包含attack_value的才会继续传递
		public var magic:String;
		///整体队伍或特殊稳定祝福效果，提升等量含真实伤害免伤
		public var bless:Number;
		
		//以下属性不直接在data中
		///备战部队列表
		public var troops:Array;
		public var battleLogic:BattleLogic;
		
		///队伍编号0攻方 1守方
		private var _teamIndex:int;
		///队伍编号0攻方 1守方
		override public function get teamIndex():int { 
			return this._teamIndex; 
		}
		
		/**
		 * 得到不包含当前正在作战的，部队数组的uid_hid(keyId)，纯客户端对比用
		 */
		public function getTroopKeyIds(isServer:Boolean = false, hasInsertId:Boolean = false):Array
		{
			//var tempArr:Array = this.getTroops(isServer);
			////var tempArr:Array = this.getTroopsContainFight(isServer);
			var arr:Array = [];
			//var len:int = tempArr.length;
			//for (var i:int = 0; i < len; i++) 
			//{
				//var troop:TroopLogic = tempArr[i];
				//if(troop){
					//arr.push(troop.getKeyId(hasInsertId));
				//}
				//else{
					//arr.push(null);
				//}
			//}
			return arr;
		}
		
		public function TeamLogic(data:*,battleLogic:BattleLogic,teamIndex:int) 
		{
			this._teamIndex = teamIndex;
			this.battleLogic = battleLogic;
			super(data);
		}

		/**
		 * new之前包装部队数据
		 */
		protected function packTroopData(data:*):void
		{
			if (this.data.hasOwnProperty('uid')){
				data.uid = this.data.uid;
				if (this.battleLogic.isNoNPC && data.uid < 0){
					data.uid = 0;
				}
			}
			else if (this.battleLogic.isNoNPC && !data.hasOwnProperty('uid'))
			{
				//只能PVP的模式，所有对战都按PVP进行
				data.uid = 0;
			}
			
			if (this.data.hasOwnProperty('uname')){
				data.uname = this.data.uname;
			}
			if (this.data.hasOwnProperty('country')){
				data.country = this.data.country;
			}
			if (this.battleLogic.isCountry)
			{
				if (data.uid == null || data.uid < 0){
					//NPC
					this.packCountryNPCTroopName(data);
				}else{
					if (data.official >= 0 && data.official <= 4){
						data.milepost = this.battleLogic.country_logs[data.country].milepost;
					}
					if (this.battleLogic.user_logs[data.uid]){
						data.uname = this.battleLogic.user_logs[data.uid].uname;
					}
				}
			}
			else if (this.battleLogic.isMagic)
			{
				//只有攻方才考虑
				if (this.teamIndex == 0)
				{
					var magicId:String = this.data['magic'];
					if (magicId){
						var magicCfg:Object = ConfigServer.mining.magic_date[magicId];
						if(magicCfg && magicCfg.attack_value){
							data.magic = magicId;
						}
					}
				}
			}
			
			if (this.data['bless'])
			{
				//擂台战才有的队伍祝福
				data.bless = this.data['bless'];
			}
		}
		

		
		/**
		 * 重新包装国战中NPC的名字
		 */
		public function packCountryNPCTroopName(data:*):void
		{
			if (this.battleLogic.isCountry)
			{
				if (data.uid == null || data.uid < 0){
					//NPC
					var isXYZ:Boolean = false;
					var cityCfg:Object = ConfigServer.city[this.battleLogic.city];
					if (cityCfg.cityType >= 7 && cityCfg.cityType <= 9){
						isXYZ = true;
					}	
					
					if (isXYZ){
						//如果是襄阳NPC。不论攻防都显示黄巾
						if (data.official == -1){
							data.uname = Tools.getMsgById(90104);
						}else if (data.official == -2){
							data.uname = Tools.getMsgById(90105);
						}else if (data.official == -3){
							//攻城车，不删除uname
						}
						else{
							delete data.uname;
						}
					}
					else if (data.xtype){
						//护国军，保持
					}
					else{
						if (this.teamIndex == 1)
						{
							//守方NPC
							if (data.official == -1){
								data.uname = Tools.getMsgById(90101);
							}else if (data.official == -2){
								data.uname = Tools.getMsgById(90102);
							}else{
								data.uname = Tools.getMsgById(90100);
							}
						}
						else{
							delete data.uname;
						}
					}
				}
			}
		}
		
		
		/**
		 * Troop生成后，告知国战部队参战信息变化（登入信息实体或变更最强战力）
		 */
		protected function askBattle(troop:TroopLogic):void
		{
			if (troop.uid >= 0){
				var user_logs:Object = this.battleLogic.user_logs;
				var userLog:Object;
				var uid:int = troop.uid;
				var uidStr:String = uid.toString();
				if (!user_logs.hasOwnProperty(uidStr)){
					if (this.battleLogic.isCountry){
						//国战下，登入信息 uid uname head official country power kill
						user_logs[uidStr] = {uname:troop.uname, head:null, official:troop.official, country:troop.country, power:troop.power, powerHid:troop.getHeadId(), kill:0};
						
						//var country_logs:Object = this.battleLogic.country_logs;
						//if (!country_logs.hasOwnProperty(troop.country))
						//{
							//country_logs[troop.country] = {};
						//}
					}else{
						user_logs[uidStr] = {};
					}
				}
				userLog = user_logs[uidStr];
				if (!userLog.hasOwnProperty('attends')){
					userLog.attends = {};
				}

				if (this.battleLogic.isCountry){
					//国战下，更新最高战力
					if(troop.power > userLog.power){
						userLog.power = troop.power;
						userLog.powerHid = troop.getHeadId();
					}
					this.battleLogic.checkTeamBest(teamIndex, uid);
				}			
				userLog.attends[troop.hid] = 1;
			}
		}
		
		public function newTroop(data:*,troopIndex:int):TroopLogic
		{
			this.packTroopData(data);
			var troop:TroopLogic = new TroopLogic(data, this._teamIndex, troopIndex);
			this.askBattle(troop);
			return troop;
		}
		
		public function addTroop(troopLogic:TroopLogic):TroopLogic
		{
			this.troops.splice(troopLogic.troopIndex, 0, troopLogic);
			this.updateTroopIndex(troopLogic.troopIndex);
			return troopLogic;
			//this.troops.push(troopLogic);
		}
		
		
		/**
		 * 得到新进玩家部队应该被插入的位置，如果有偷跑的战斗，插入N-1
		 */
		public function getTroopInsertIndex(forgeFight:Boolean = false):int
		{
			var i:int;
			//len全部部队数量
			var len:int = this.troops.length;
			//playerEnd玩家尾部序号
			var playerEnd:int = 0;
			for (i = len-1; i >= 0; i-- ){
				var troopLogic:TroopLogic = this.troops[i];
				if (!troopLogic.isNpc){
					playerEnd = i + 1;
					break;
				}
			}
			var n:int = ConfigFight.troopInsertIndex;
			if (forgeFight)
				n--;
			var index:int = Math.max(playerEnd, Math.min(len,n));
			return index;
		}
		/**
		 * 更新所有部队位序(起点)
		 */
		public function updateTroopIndex(i:int = 0):void
		{
			var len:int = this.troops.length;
			for (; i < len; i++) 
			{
				var troop:TroopLogic = this.troops[i];
				troop.troopIndex = i;
			}
		}
				
		override public function setData(data:*):void{
			super.setData(data);
			
			this.troops = [];
			var i:int;
			var len:int;
			var troopData:Array = this.data.troop;
			for (i = 0, len = troopData.length; i < len; i++){
				this.addTroop(this.newTroop(troopData[i], i));
			}
		}
		
		
		/**
		 * 返回当前数据副本(用于客户端中途加入战斗时，恢复到从某一场开始)
		 */
		public function getCurrData():*{
			var reData:Object = {};
			
			if(this.uid)
				reData.uid = this.uid;
			reData.uname = this.uname;
			//reData.country = this.country;
			reData.troop = [];
			var i:int;
			var len:int = this.troops.length;
			for (i = 0; i < len; i++)
			{
				var troop:TroopLogic = this.troops[i];
				reData.troop.push(troop.getCurrData());
			}

			return reData;
		}
		
		override public function clear():void
		{
			var i:int;
			var len:int = this.troops.length;
			for (i = 0; i < len; i++)
			{
				var troop:TroopLogic = this.troops[i];
				troop.clear();
			}
			this.troops = [];
			super.clear();
		}
	}

}