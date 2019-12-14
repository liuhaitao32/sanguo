package sg.map.view.entity {
	import laya.display.Sprite;
	import laya.maths.Point;
	import laya.utils.Handler;
	import laya.utils.Tween;
	import sg.cfg.ConfigServer;
	import sg.map.model.MapModel;
	import sg.map.model.entitys.EntityCity;
	import sg.map.utils.MapUtils;
	import sg.map.utils.TestUtils;
	import sg.map.utils.Vector2D;
	import sg.map.view.ThiefInfo;
	import sg.scene.SceneMain;
	import sg.scene.view.MapCamera;
	import sg.scene.view.entity.EntityClip;
	import sg.utils.Tools;
	import sg.festival.model.ModelFestival;
	
	/**
	 * 黄巾军。
	 * @author light
	 */
	public class ThiefClip extends EntityClip {
		
		public var thiefData:Object;
		
		public var thiefConfig:Object;
		
		public var dir:int;
		public var city:EntityCity;
		
		public var thiefInfo:ThiefInfo;
		
		public function ThiefClip(scene:SceneMain) {
			super(scene);			
		}
		
		override public function init():void {
			super.init();
			var content:Sprite;
			var dir2:int = (this.dir + 2) % 4;
			if (this.thiefConfig["model"][0] != "") {
				content = this.getHeroMatrix(this.thiefConfig["model"][2][0], this.thiefConfig["model"][1], dir2, this.thiefConfig["model"][0], "thief2");
			} else {
				content = this.getMatrix(this.thiefConfig["model"][2][0], this.thiefConfig["model"][1], dir2, "thief");
			}
			this._clip.addChild(content);
			
			//原点。
			var v1:Vector2D = Vector2D.TEMP;
			this._scene.mapLayer.getPos(this.city.mapGrid.col, this.city.mapGrid.row, Point.TEMP);
			v1.setTempPoint();			
			//起始点。
			var v2:Vector2D = MapUtils.getAroundHypotenuse(this.dir);
			v2.length = MapModel.instance.mapGrid.halfhypotenuse * this.city.size;
			
			//目标点。
			v1.add(v2);
			
			//起始点
			v2.length += MapModel.instance.mapGrid.hypotenuse * 0.8// - MapModel.instance.mapGrid.halfhypotenuse;			
			v2.add(v1);
			
			
			var startTime:Number = this.thiefData.start_time;
			
			var offsetTime:Number = ConfigServer.getServerTimer() - startTime * 1000;
			
			var totalTime:Number = this.thiefConfig.speed * 1000;
			
			var v3:Vector2D = new Vector2D();
			Vector2D.lerp(v2, v1, offsetTime / totalTime, v3);
			
			this.x = v3.x;
			this.y = v3.y;
			this._scene.mapLayer.topLayer.addChild(this);
			if (offsetTime < 0) {
				this.clear();
			} else {
				//Tween.to(this, {x:v1.x, y:v1.y}, 10000, null, Handler.create(this, this.clear));
				Tween.to(this, {x:v1.x, y:v1.y}, totalTime - offsetTime, null, Handler.create(this, this.clear));
			}
			
			
			if (this.thiefConfig.open_show) {
				this.thiefInfo = new ThiefInfo()
				this.thiefInfo.y = -this._scene.mapGrid.gridHalfH;
				this.addChild(this.thiefInfo);
				var arr:Array=ModelFestival.getRewardInterfaceByKey("attack_city_npc");
				if(this.thiefData.type!="thief_one" || arr.length==0)
				 	arr = this.thiefConfig["reward_" + this.thiefData.hid][0];
				//this.thiefInfo.setData({icon:this.thiefConfig["reward_" + this.thiefData.hid][0][0], num:this.thiefConfig["reward_" + this.thiefData.hid][0][1], time:totalTime - offsetTime});
				this.thiefInfo.setData({icon:arr[0], num:arr[1], time:totalTime - offsetTime});
			}
			
		}
		
		override public function clear():void {
			Tween.clearAll(this);
			super.clear();
		}
		
	}

}