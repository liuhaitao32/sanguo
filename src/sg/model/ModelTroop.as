package sg.model 
{
	import sg.manager.ModelManager;
	import sg.map.model.MapModel;
	import sg.map.model.entitys.EntityCity;
	import sg.utils.Tools;
	/**
	 * ...
	 * @author light
	 */
	public class ModelTroop extends ModelBase {	
		
		
		public static var TROOP_STATE_IDLE:int = 0;//0 待命/备战/战斗,
		public static var TROOP_STATE_MOVE:int = 1;//行军
		public static var TROOP_STATE_RECALL:int = 2;//撤回
		public static var TROOP_STATE_MONSTER:int = 3;//打野
		
		public var state:int = -1;
		
		public var id:String = "";//user&英雄
		
		public var uid:String;		
		
		
		public var hero:String = "";
		
		public var entityCity:EntityCity;
		
		public var index:int = -1;
		
		public var army:Array = [200, 200];
		public var hp:Array = [200, 200];
		// public var monster:Number = 0;
		public function ModelTroop(data:Object) {
			super();			
			this.setData(data);
		}
		
		public function reset():void {
			this.state = TROOP_STATE_IDLE;
			this.cityId = MapModel.instance.myCapital.cityId;
			this.uid = ModelManager.instance.modelUser.mUID;
			this.id = this.uid + "&" + this.hero;
		}
		
		public function get isReadyFight():Boolean{
			return this.index != -1 && this.cityInFire;
		}
		
		public function get cityInFire():Boolean{
			return EntityCity(MapModel.instance.citys[this.cityId.toString()]).fire;
		}
		
		public function setData(data:Object):void {
			if (null != data.status) this.state = data.status;
			if(data.uid) this.uid = data.uid;
			if(data.hid) this.hero = data.hid;
			if(data.city) this.cityId = data.city;
			this.id = this.uid + "&" + this.hero;
			this.index = ("index" in data) ? data["index"] : -1;
			if ("army" in data) this.army = data["army"];
			if(data.hp)this.hp = data["hp"];
			// this.monster = data.monster?data.monster:0;
			// trace("ModelTroop setData this.monster :",this.monster);
		}
		
		public function get deaded():Boolean {
			return (this.army == null || this.army[0] + this.army[1] == 0) && this.state!=TROOP_STATE_MONSTER;
		}
		
		public function get cityId():int {
			return this.entityCity.cityId;
		}
		
		public function set cityId(value:int):void {
			if (this.entityCity) {
				if (this.entityCity.cityId == value) return;
				this.entityCity.removeTroop(this);
			}
			
			this.entityCity = MapModel.instance.citys[value];
			if (this.entityCity) {
				this.entityCity.addTroop(this);
			}
			
		}
		
		public function getModelHero():ModelHero {
			return ModelManager.instance.modelGame.getModelHero(this.hero);
		}
		
		public function getName():String {
			var hmd:ModelHero = this.getModelHero();
			return hmd.getName();
		}
		
		public function getHpPer():Number {
			if(this.state  == ModelTroop.TROOP_STATE_MONSTER) {
                return this.hp[0] / this.hp[1];
            } else {
                var hb:Number = (this.army[0] + this.army[1]);
                var hbMax:Number = this.getHpMax();
                //
                return hb / hbMax;
            }
		}
		public function getHpMax():Number{
			return ModelManager.instance.modelGame.getModelHero(this.hero).getArmrHpmMax();
		}
		public function setDead():void {
			this.entityCity.removeTroop(this);
			this.army = null;
		}
		
	}

}