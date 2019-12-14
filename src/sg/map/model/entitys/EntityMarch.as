package sg.map.model.entitys {
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;
	import sg.model.ModelFightTask;
	import sg.model.ModelHero;
	import sg.model.ModelTroop;
	import sg.scene.constant.EventConstant;
	import sg.map.model.MapModel;
	import sg.scene.model.entitys.EntityBase;
	import sg.model.ModelUser;
	import sg.utils.Tools;
	
	/**
	 * 行军的逻辑类。
	 * @author light
	 */
	public class EntityMarch extends EntityBase {
		
		public var marchData:Array = [["0", 200], ["1", 200], ["2", 200], ["3", 200], ["4"]];
		
		public var uid:String = "";
		
		public var hero:String = "";
		
		public var position:Number = 5000;
		
		public var rate:Number = 1;
		public var rate2:Number = 1;
		
		public var startTime:Number;
		
		public var index:int;
		
		private var _maxPath:Number = 0;
		
		public var city:int = 0;
		
		public var country:int;
		
		public var title:String = null;
		///套装
		public var group:String = null;
		///觉醒
		public var awaken:int = 0;
		
		public var state:int = -1;
		
		public var moveType:int = 0;
		
		public function EntityMarch(map:MapModel, netId:int=-1) {
			super(netId);			
		}
		
		public function get startCity():EntityCity {
			return MapModel.instance.citys[this.marchData[0][0]];
		}
		
		public function get endCity():EntityCity {
			return MapModel.instance.citys[this.marchData[this.marchData.length - 1][0]];
		}
		
		public function get isCountry_army():Boolean {
			return this._data.xtype == "country_army";
		}
		
		override public function initConfig(data:* = null):void {
			super.initConfig(data);	
			this.uid = data.uid;
			this.hero = data.hid;
			this.city = data.city;
			this.id = this.uid + "&" + this.hero;
			this.state = data.status;
			//护国军
			if (this.isCountry_army){
				this.hero = ConfigServer.country_army["model"][0];
			}
			if (data.data.title && ModelHero.checkTitleIsOK(Tools.getTimeStamp(data.data.title[1]))) this.title = data.data.title[0];
			if (data.data.group) this.group = data.data.group;
			if (data.data.awaken) this.awaken = data.data.awaken;
			this.moveType = data.data.type;
			//this.title = "title001";
			this.country = data.country;
			var arr:Array = data.data.city_list;
			this.setMarchData(data.data.city_list);//测试用。
			
			this.position = Math.min(this.maxPath - 1, data.data.have_dis + this.getDistByIndex(data.data.index - 1));
			
			this.changeIndex();
			this.startTime = data.data.start_time;
			this.setRate(data.data.speedup);
			
			Laya.timer.loop(1000, this, this.update, null, true, true);
		}
		
		
		public function get currSpeed():Number{
			var speed:Number = this.marchData[this.index][1];
			return speed * this.rate;
		}
		
		private function update():void {
			this.position = Math.min(this.position + this.currSpeed, this.maxPath);
			this.changeIndex();
			if (this.position >= this.maxPath) {
				Laya.timer.clear(this, this.update);
				this.event(EventConstant.MARCH_COMPLETE);
				Laya.timer.once(3000, this, this.clear);
			}
		}
		
		public function remainTime(pos:int = -1):Number {
			this.changeIndex();
			var time:Number = 1;
			if (pos == -1) pos = this.position;
			
			for (var i:int = 0, len:int = this.marchData.length - 1; i < len; i++) {
				var dist:Number = this.marchData[i][2];
				var speed:Number = this.marchData[i][1];
				var p:Number = dist;
				if(pos > 0) {
					p = dist - pos;
				}
				
				if(p > 0) {
					time += p / (speed * this.rate);
				}
				pos -= dist;
			}
			return time;
		}
		
		
		
		
		public function changeIndex():int {
			var sum:int = 0;
			this.index = -1;
			for (var i:int = 0, len:int = this.marchData.length - 1; i < len; i++) {
				var dist:Number = this.marchData[i][2];
				sum += dist;
				if(this.position < sum) {
					this.index = i;
					break;
				}
			}
			if (this.index == -1) this.index = this.marchData.length - 1;
			return this.index;
		}
		
		
		public function getDistByIndex(index:int):Number {
			var result:Number = 0;
			for (var i:int = 0, len:int = index + 1; i < len; i++) {
				var dist:Number = this.marchData[i][2];
				result += dist;
			}
			return result;
		}
		
		public function get isFinish():Boolean {
			return this.position == this.maxPath;
		}
		
		
		public function currCity():Array{
			var index:int = this.changeIndex();
			if ( this.marchData.length - 1 != index){
				return [this.marchData[index][0], this.marchData[index + 1][0]];
			} else {
				return null;
			}
			
		}
		
		public function setMarchData(data:Array):void {
			this.marchData = data;
			for (var i:int = this.index, len:int = this.marchData.length - 1; i < len; i++) {				
				var cityId1:int = parseInt(this.marchData[i][0]);
				var cityId2:int = parseInt(this.marchData[i + 1][0]);
				
				this.marchData[i].push(EntityCity.getPathDistById(cityId1, cityId2));
			}
		}
		
		public function setRate(r:Number):void {
			this.rate2 = r;
			if (this.startCity.cityId < 0) {
				r *= ModelManager.instance.modelCountryPvp.getSpeedNum();
			}
			var buff2:Array = ModelFightTask.instance.buff;
			r *= (buff2[1] || 0) + 1;
			
			var change:Number = r / this.rate;
			this.rate = r;
			this.event(EventConstant.MARCH_RATE_CHANGE, change);
		}
		
		public function get maxPath():Number {
			if (this._maxPath == 0) {
				this._maxPath = this.getDistByIndex(this.marchData.length - 2);
			}
			return _maxPath;
		}
		
		override public function clear():void {	
			if (this._cleared) return;
			Laya.timer.clear(this, this.update);
			Laya.timer.clear(this, this.clear);
			super.clear();
		}
		
		public function recall():void {
			this.state = ModelTroop.TROOP_STATE_RECALL;
			Laya.timer.clear(this, this.update);
			this.event(EventConstant.TROOP_MARCH_RECALL);
		}
		
		public function get isMine():Boolean {
			return this.country == ModelUser.getCountryID() && ModelManager.instance.modelTroopManager.troops[this.id];
		}
		
	}

}