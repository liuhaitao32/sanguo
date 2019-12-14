package sg.fight.client.view 
{
	import laya.display.Sprite;
	import laya.maths.Rectangle;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.utils.Tween;
	import laya.utils.Utils;
	import sg.cfg.ConfigApp;
	import sg.fight.client.cfg.ConfigFightView;
	import sg.fight.client.spr.FEffect;
	import sg.fight.client.spr.FImage;
	import sg.fight.client.spr.FSpriteBase;
	import sg.fight.logic.utils.FightRandom;
	import sg.fight.test.TestFightData;
	import sg.manager.AssetsManager;
	import sg.manager.LoadeManager;
	import sg.view.ViewBase;
	/**
	 * 战斗场景基础
	 * @author zhuda
	 */
	public class FightSceneBase extends ViewBase
	{

		//摄像机偏移
		public var cameraOffset:Number;
		
		public var grounds:Array;
		public var skys:Array;
		public var curtains:Array;
		public var centerImg:Image;
		private var seed:int;
		public var items:Array;
		//震屏层
		public var allLayer:Sprite;
		//背景图层
		public var bgLayer:Sprite;
		//单位图层
		public var unitLayer:Sprite;
		//伤血等文本图层
		public var infoLayer:Sprite;
		
		//public var id:String;
		
		public function FightSceneBase(id:String = null) 
		{
			if (id == null){
				id = '';
			}
			this.id = id;
			this.init();
		}
		
		override public function onAddedBase():void
		{
			Laya.stage.on('resize', this, this.onResize);
			this.onResize();

			this.initUI();
		}
		override public function onRemovedBase():void
		{
			Laya.stage.off('resize', this, this.onResize);
		}
		
		private	function onResize():void
		{
			var w:Number = Laya.stage.width;
			var h:Number = Laya.stage.height;
			this.x = w * 0.5;
			
			if (ConfigApp.isPC){
				this.reCache();
				this.scale(1.05, 1.05);
				this.y = h * 0.55;
			}
			else
			{
				if (h > w * 2){
					this.y = h * 0.5;
				}
				else
				{
					//this.y = h * 0.6 - 128;
					this.y = h * 0.4 + 128;
				}
				//this.y = h * 0.5;

				var temp:Number = w / h;
				if (temp > 0.6){
					//胖屏
					temp = 1-(temp - 0.6);
					this.scale(temp, temp);
					//Trace.log(Laya.stage.width+','+ Laya.stage.height);
					w /= temp;
					h /= temp;
				}
				else
				{
					this.scale(1, 1);
				}
				
				//this.setBounds(new Rectangle(0, 0, w, h));	
			}
			this.hitArea = new Rectangle(-w*0.5, -h*0.5, w, h);
		}
		public function initUI() :void
		{
			if (TestFightData.testMode == -3){
				//不加载
				return;
			}
			//this.alpha = 0;
			//Tween.to(this, {alpha:1}, 100);
			
			this.cameraOffset = 0;
			//this.box.centerX = this.box.centerY = 0;
			//this.box.blendMode = 'lighter';
			//this.box.x = this.width / 2;
			//this.box.y = this.height / 2;
			//new FightImage(this.getItemId(5),0,0,false);
			
			this.allLayer = new Sprite();
			this.addChild(this.allLayer);
			this.bgLayer = new Sprite();
			this.allLayer.addChild(this.bgLayer);
			this.unitLayer = new Sprite();
			this.unitLayer.y = 30;
			this.allLayer.addChild(this.unitLayer);
			this.infoLayer = new Sprite();
			this.infoLayer.y = 30;
			this.allLayer.addChild(this.infoLayer);
			
			
			this.grounds = [];
			
			var i:int;
			var img:Image;
			var groundSkin:String = this.getSkinUrl('00');
			var groundBox:Box;
			for (i = 0; i < ConfigFightView.SCENE_GROUND_NUM; i++)
			{
				//为了layaBox 手机模拟器bug才包了groundBox
				img = LoadeManager.getLargeImage(groundSkin);
				//img = new Image(groundSkin);
				img.scaleX = i % 2 == 0?1: -1;
				img.anchorX = 0.5;
				img.anchorY = 0.5;
				//img.alpha = 0.5;
				groundBox = new Box();
				groundBox.addChild(img);
				groundBox.y = ConfigFightView.SCENE_GROUND_Y;
				this.bgLayer.addChild(groundBox);
				this.grounds.push(groundBox);
			}
			
			this.skys = [];
			var skySkin:String = this.getSkinUrl('01',false);
			for (i = 0; i < ConfigFightView.SCENE_SKY_NUM; i++)
			{
				img = new Image(skySkin);
				//img = LoadeManager.getLargeImage(skySkin);
				//img.scaleX = i % 2 == 0?1: -1;
				img.anchorX = 0.5;
				img.anchorY = 0.5;
				img.scale(2.01, 2);
				img.y = ConfigFightView.SCENE_SKY_Y;
				//img.alpha = 0.5;
				this.bgLayer.addChild(img);
				this.skys.push(img);
			}
			
			this.curtains = [];
			var curtainSkin:String = this.getSkinUrl('02');
			for (i = 0; i < ConfigFightView.SCENE_CURTAIN_NUM; i++)
			{
				img = LoadeManager.getLargeImage(curtainSkin);
				//img.scaleX = i % 2 == 0?1: -1;
				img.anchorX = 0.5;
				img.anchorY = 0.5;
				img.y = ConfigFightView.SCENE_CURTAIN_Y;
				//img.alpha = 0.5;
				this.bgLayer.addChild(img);
				this.curtains.push(img);
			}
			this.centerImg = LoadeManager.getLargeImage(this.getSkinUrl('03'));
			//this.centerImg = new Image();
			this.centerImg.anchorX = 0.5;
			this.centerImg.anchorY = 0.5;
			this.centerImg.y = ConfigFightView.SCENE_CENTER_Y;
			this.bgLayer.addChild(this.centerImg);
			

			//杂物随着box单位一起运动
			this.initItems();
			
			this.updatePos();
		}
		
		static public function getSceneSkinUrl(res:String, isPng:Boolean = true) :String
		{
			return AssetsManager.getAssetsFight( FightSceneBase.getItemId(res,''),isPng);
		}
		public function getSkinUrl(res:String, isPng:Boolean = true) :String
		{
			return AssetsManager.getAssetsFight( FightSceneBase.getItemId(res,this.id),isPng);
		}
		public static function getItemId(res:String, id:String) :String
		{
			return 'bg_fight_' + id + res;
		}
		
		//public function clearBox():void
		//{
			//this.box.removeChildren();
		//}
		public function initItems():void
		{
			this.items = [];
			this.seed = parseInt((Math.random() * 20000).toString());
			
			var i:int;
			var item:FImage;
			var arr:Array;
			var res:String;
			//var indexY:int;
			var tempX:Number;
			var tempY:Number;
			var rand:FightRandom = new FightRandom(this.seed);
			//地表
			for (i = 0; i < ConfigFightView.SCENE_SURFACE_NUM; i++)
			{
				res = ConfigFightView.SCENE_SURFACE_IDS[rand.getRandomIndex(ConfigFightView.SCENE_SURFACE_IDS.length)];
				res = FightSceneBase.getItemId(res, this.id);
				tempX = i * ConfigFightView.SCENE_SURFACE_INTERVAL -ConfigFightView.SCENE_SURFACE_HALF + rand.getRandomRange(ConfigFightView.SCENE_SURFACE_X_RANGE[0],ConfigFightView.SCENE_SURFACE_X_RANGE[1])
				arr = ConfigFightView.SCENE_SURFACE_Y_RANGE;
				//indexY = rand.getRandomIndex(arr.length);
				tempY = rand.getRandomRange(arr[0],arr[1]);
				
				item = new FImage(this, res, tempX, tempY, rand.getRandomBoolean(), ConfigFightView.SCENE_SURFACE_SCALE, 1, true, 120);
				item.img.alpha = ConfigFightView.SCENE_SURFACE_ALPHA[0] + rand.getRandom() * (ConfigFightView.SCENE_SURFACE_ALPHA[1]-ConfigFightView.SCENE_SURFACE_ALPHA[0]);
				item.img.anchorX = 0.5;
				item.img.anchorY = 0.5;
			}
			//远景
			for (i = 0; i < ConfigFightView.SCENE_FAR_NUM; i++)
			{
				res = ConfigFightView.SCENE_FAR_IDS[rand.getRandomIndex(ConfigFightView.SCENE_FAR_IDS.length)];
				res = FightSceneBase.getItemId(res, this.id);
				tempX = i * ConfigFightView.SCENE_FAR_INTERVAL -ConfigFightView.SCENE_FAR_HALF + rand.getRandomRange(ConfigFightView.SCENE_FAR_X_RANGE[0],ConfigFightView.SCENE_FAR_X_RANGE[1])
				arr = ConfigFightView.SCENE_FAR_Y_RANGE;
				//indexY = rand.getRandomIndex(arr.length);
				tempY = rand.getRandomRange(arr[0], arr[1]);
				
				item = new FImage(this, res, tempX, tempY, rand.getRandomBoolean(), ConfigFightView.SCENE_FAR_SCALE, 1, true, 30);
				item.img.anchorX = 0.5;
				item.img.anchorY = 0.5;
			}
			//近景
			for (i = 0; i < ConfigFightView.SCENE_NEAR_NUM; i++)
			{
				res = ConfigFightView.SCENE_NEAR_IDS[rand.getRandomIndex(ConfigFightView.SCENE_NEAR_IDS.length)];
				res = FightSceneBase.getItemId(res, this.id);
				tempX = i * ConfigFightView.SCENE_NEAR_INTERVAL -ConfigFightView.SCENE_NEAR_HALF + rand.getRandomRange(ConfigFightView.SCENE_NEAR_X_RANGE[0],ConfigFightView.SCENE_NEAR_X_RANGE[1])
				arr = ConfigFightView.SCENE_NEAR_Y_RANGE;
				//indexY = rand.getRandomIndex(arr.length);
				tempY = rand.getRandomRange(arr[0],arr[1]);
				
				item = new FImage(this, res, tempX, tempY, rand.getRandomBoolean(), ConfigFightView.SCENE_NEAR_SCALE, 1, false, 50);
				item.img.anchorX = 0.5;
				item.img.anchorY = 0.5;
			}
		}
		public function clearItems():void
		{
			if (!this.items)
				return;
			while(this.items.length > 0)
			{
				var item:FSpriteBase;
				//trace('clearItems',item,this.items.length);
				item = this.items[0];
				item.clear();
			}
		}

		public function setItemIndex(item:FSpriteBase, index:int):void
		{
			this.unitLayer.setChildIndex(item.spr, index);
		}
		public function addItem(item:FSpriteBase):void
		{
			this.unitLayer.addChild(item.spr);
			this.items.push(item);
		}
		public function addBgItem(item:FSpriteBase):void
		{
			this.bgLayer.addChild(item.spr);
			this.items.push(item);
		}
		public function addInfoItem(item:FSpriteBase):void
		{
			this.infoLayer.addChild(item.spr);
			this.items.push(item);
		}
		public function removeItem(item:FSpriteBase):void
		{
			item.spr.removeSelf();
			//this.box.removeChild(item.spr);
			var index:int = this.items.indexOf(item);
			if(index != -1)
				this.items.splice(index,1);
		}
		/**
		 * 移除所有特效
		 */
		public function removeEffects():void
		{
			var i:int;
			for (i = this.items.length -1; i >=0; i--)
			{
				var item:FSpriteBase = this.items[i];
				if (item is FEffect)
				{
					this.unitLayer.removeChild(item.spr);
					this.items.splice(i,1);
				}
			}
		}
		
		
		/**
		 * 更新所有位置
		 */
		public function updatePos():void
		{
			if (this.destroyed)
				return;
			var i:int;
			var offset:Number;
			var img:Image;
			var tempX:Number;
			var groundBox:Box;
			var cameraOffset:Number = this.cameraOffset;
			
			offset = -cameraOffset * ConfigFightView.SCENE_GROUND_RATE;
			while (offset < ConfigFightView.SCENE_GROUND_CACHE)
			{
				offset += ConfigFightView.SCENE_GROUND_CACHE*100;
			}
			//TestPrint.instance.clear();
			for (i = 0; i < ConfigFightView.SCENE_GROUND_NUM; i++)
			{
				groundBox = this.grounds[i];
				img = groundBox.getChildAt(0) as Image;
				
				tempX = (i * ConfigFightView.SCENE_GROUND_INTERVAL + offset) % ConfigFightView.SCENE_GROUND_CACHE - ConfigFightView.SCENE_GROUND_HALF;
				groundBox.x = tempX;
				var radians:Number = Math.atan(tempX * ConfigFightView.SCENE_GROUND_ATAN_RATE);
				var angle:Number = Utils.toAngle(radians);//Math.PI;
				groundBox.skewX = angle;
				img.scaleY = 1 / Math.cos(radians);
				
				//TestPrint.instance.print('i:' + i + ' ,radians:'+radians+' ,angle:'+angle+' ,skewX:'+img.skewX);
			}
			
			offset = -cameraOffset * ConfigFightView.SCENE_SKY_RATE;
			while (offset < ConfigFightView.SCENE_SKY_CACHE)
			{
				offset += ConfigFightView.SCENE_SKY_CACHE*100;
			}
			for (i = 0; i < ConfigFightView.SCENE_SKY_NUM; i++)
			{
				img = this.skys[i];
				tempX = (i * ConfigFightView.SCENE_SKY_INTERVAL + offset) % ConfigFightView.SCENE_SKY_CACHE - ConfigFightView.SCENE_SKY_HALF;
				img.x = tempX;
			}
			
			offset = -cameraOffset * ConfigFightView.SCENE_CURTAIN_RATE;
			while (offset < ConfigFightView.SCENE_CURTAIN_CACHE)
			{
				offset += ConfigFightView.SCENE_CURTAIN_CACHE*100;
			}
			for (i = 0; i < ConfigFightView.SCENE_CURTAIN_NUM; i++)
			{
				img = this.curtains[i];
				tempX = (i * ConfigFightView.SCENE_CURTAIN_INTERVAL + offset) % ConfigFightView.SCENE_CURTAIN_CACHE - ConfigFightView.SCENE_CURTAIN_HALF;
				img.x = tempX;
			}
			
			this.centerImg.x = -cameraOffset * ConfigFightView.SCENE_CENTER_RATE + ConfigFightView.SCENE_CENTER_X;
			
			//所有的单位都放到这里
			var item:FSpriteBase;
			for (i = this.items.length-1; i >=0; i--)
			{
				item = this.items[i];
				item.updatePos();
			}
			
			//FightMain.instance.event.event('updatePos');
		}
	}

}