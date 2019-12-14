package sg.view.menu
{
	import ui.menu.baseUI;
	import sg.view.menu.ViewMenuBottom;
	import sg.view.menu.ViewMenuTop;
	import sg.view.menu.ViewMenuUser;
	import sg.view.menu.ViewMenuLeft;
	import laya.events.Event;
	import sg.manager.ViewManager;
	import laya.ui.Box;
	import sg.model.ModelBuiding;
	import sg.view.menu.ItemBuilder;
	import sg.model.ModelInside;
	import sg.manager.ModelManager;
	import sg.model.ModelTroopManager;
	import sg.model.ModelTroop;
	import sg.model.ModelHero;
	import laya.maths.MathUtil;
	import sg.scene.constant.EventConstant;
	import sg.cfg.ConfigApp;
	import sg.view.ViewScenes;
	import sg.utils.Tools;
	import sg.cfg.ConfigServer;
	import sg.model.ModelUser;
	import sg.model.ModelGame;
	import sg.model.ModelOffice;
	import laya.display.Sprite;
	import laya.webgl.utils.IndexBuffer2D;
	import sg.model.ModelOfficial;
	import sg.guide.model.GuideChecker;
	import sg.cfg.HelpConfig;

	/**
	 * 主界面UI
	 * @author
	 */
	public class ViewMenuMain extends baseUI{

		public var view_bottom:ViewMenuBottom;
		public var view_top:ViewMenuTop;
		public var view_user:ViewMenuUser;
		public var view_left:ViewMenuLeft;
		public var view_troop:ViewTroopList;
		public var box_right_builder:Box;//建造队列
		public var box_right_equip:Box;//宝物队列
		public var box_right_science:Box;//科技队列
		public var box_right_autotrain:Box;//自动训练兵按钮
		//
		public var typeStyle:int = -1;
		
		public var rightLength:Number=0;//
		//
		public function ViewMenuMain(){
			//
			this.mouseThrough = true;
		}

		public function actCallBack():void{
			initFreeBuy();
		}
		override public function init():void{
			//
			instance_guide = this;
			//
			this.y = ConfigApp.topVal;
			this.height = Laya.stage.height - this.y;

			if(ConfigApp.isPC){
				this.width = Laya.stage.width;
			}			
			
			//
			this.cacheAs = "normal";
			//
			this.visible = false;
			//
			this.box_right_builder = new Box();
			this.initBuilder();
			//
			this.box_right_equip = new Box();
			this.box_right_equip.name="11111";
			this.initEquip();
			//
			this.box_right_science = new Box();
			this.initScience();
			//
			this.box_right_autotrain = new Box();
			this.initAutoTrain();
			//
			this.view_top = new ViewMenuTop();
			this.view_top.cacheAs = "normal";

			//
			this.view_user = new ViewMenuUser();
			//
			this.view_left = new ViewMenuLeft();
			//
			this.view_bottom = new ViewMenuBottom();				
			//
			this.view_troop = new ViewTroopList();		
			//
			this.addChild(this.box_right_builder);
			this.addChild(this.box_right_equip);
			this.addChild(this.box_right_science);
			this.addChild(this.box_right_autotrain);
			//
			this.addChild(this.view_left);
			this.addChild(this.view_bottom);
			this.addChild(this.view_top);
			this.addChild(this.view_user);
			this.addChild(this.view_troop);			
			//
			ModelManager.instance.modelInside.off(ModelInside.BUILDING_BUILDER_ADD,this,this.building_builder_add);
			ModelManager.instance.modelInside.on(ModelInside.BUILDING_BUILDER_ADD,this,this.building_builder_add);
			//
			ModelManager.instance.modelGame.off(ModelGame.EVENT_OFFICE_RIGHT_CHANGE,this,this.officeRightChange);
			ModelManager.instance.modelGame.on(ModelGame.EVENT_OFFICE_RIGHT_CHANGE,this,this.officeRightChange);
			//
			ModelManager.instance.modelUser.off(ModelUser.EVENT_USER_UPDATE,this,this.checkRightBox);
			ModelManager.instance.modelUser.on(ModelUser.EVENT_USER_UPDATE,this,this.checkRightBox);
			
			rightLength=0;
			//宝物cd按钮
			if(ModelManager.instance.modelInside.getBuilding002().lv>0) rightLength++;
			//科技cd按钮
			if(ModelManager.instance.modelInside.getBuilding003().lv>0) rightLength++;

				
		}

		private function checkRightBox():void{
			var n:Number=0;
			if(ModelManager.instance.modelInside.getBuilding002().lv>0) n++;
			if(ModelManager.instance.modelInside.getBuilding003().lv>0) n++;
			if(n!=rightLength){
				rightLength=n;
				setRightBox();
			}
		}

		public function officeRightChange():void{
			initBuilder(1);
			initAutoTrain();
				
		}
		public function initFunc():void
		{
			this.view_bottom.init();
			this.view_user.checkNpcInfo();
			this.view_user.checkOrders();
			this.view_left.initList();	
			this.layout();//ui导出后,排版滞后在这里		
		}
		private function layout():void{
			this.view_bottom.bottom = 0;
			//
			this.view_top.top = 0;
			//			
			this.view_user.top = ViewScenes.TOP_HEIGHT;
			this.view_user.left = 0;
			//
			this.view_left.top = 160;// + (HelpConfig.type_app === HelpConfig.TYPE_WW ? 90 : 0);
			this.view_left.left = 0;
			//
			this.box_right_builder.top = ViewScenes.TOP_HEIGHT + 70;

			
			setRightBox();
			//
			this.box_right_builder.x = 530;
			this.box_right_equip.x = 530;
			this.box_right_science.x = 530;
			this.box_right_autotrain.x = 530;
			//			
			this.view_troop.top = ViewScenes.TOP_HEIGHT + 152;//+230;
			this.view_troop.right = 10;

			if(ConfigApp.isPC){
				this.view_top.centerX = 0;
				this.view_user.top = 0;
				this.view_user.left = this.view_user.right = 0;

				this.box_right_builder.x = this.width - 100;
				this.box_right_equip.x = this.width - 100;
				this.box_right_science.x = this.width - 100;
				this.box_right_autotrain.x = this.width - 100;

				this.view_bottom.left = this.view_bottom.right = 0;
			}
		}
		override public function onChange(type:* = null):void{
			if(this.typeStyle == type){
				return;
			}
			this.typeStyle = type;
			this.visible = true;
			//
			this.view_bottom.onChange(type);
			this.view_top.onChange(type);
			this.view_user.onChange(type);
			this.view_left.onChange(type);
			//
			this.view_troop.visible = false;
			this.box_right_builder.visible = false;
			this.box_right_equip.visible = false;
			this.box_right_science.visible = false;
			this.box_right_autotrain.visible = false;
			//
			var b:Boolean = false;
			if(type == 1){
				this.checkBuilder_outside();
			}
			else if(type == 2){
				this.checkBuilder_inside();
			}
			else if(type == 3){
				b = true;
			}
			// this.btn_close_box.visible = b;
			//
		}
		private function checkBuilder_inside():void{
			this.box_right_builder.visible = true;
			this.box_right_equip.visible = true;
			this.box_right_science.visible = true;
			this.box_right_autotrain.visible = true;
			this.view_troop.visible = false;
		}
		private function checkBuilder_outside():void{
			this.view_troop.visible = true;
		}
		private function onClick():void{
			ViewManager.instance.closeScenes();
		}
		//
		//
		//
		//
		//
		//
		//
		//
		//
		/**
		 * 
		 */
		private function setRightBox():void{
			if(rightLength==0){
				this.box_right_autotrain.top = this.box_right_builder.top + this.box_right_builder.height;
			}else if(rightLength==1){
				this.box_right_equip.top = this.box_right_builder.top + this.box_right_builder.height;
				this.box_right_science.top = this.box_right_builder.top + this.box_right_builder.height;
				this.box_right_autotrain.top = this.box_right_science.top + this.box_right_science.height;
			}else if(rightLength==2){
				this.box_right_equip.top = this.box_right_builder.top + this.box_right_builder.height;
				this.box_right_science.top = this.box_right_equip.top + this.box_right_equip.height;
				this.box_right_autotrain.top = this.box_right_science.top + this.box_right_science.height;
			}
		}

		private function initBuilder(type:int = 0):void{
			//
			//
			var arr:Array = ModelManager.instance.modelInside.mBuildingArr;
			var item:ItemBuilder;			
			var i:int = 0;
			if(type == 1){
				for(i = 0;i<this.box_right_builder.numChildren;i++){
					item = this.box_right_builder.getChildAt(i) as ItemBuilder;
					if(i<arr.length){
						item.initData(arr[i]);
					}
					else{
						item.initData(null);
					}					
				}
				return;
			}
			//
			this.box_right_builder.width = 120;
			//
			for(i = 0;i<2;i++){
				item = new ItemBuilder();
				item.name = "itemBuilder_"+i;
				if(i<arr.length){
					item.initData(arr[i]);
				}
				else{
					item.initData(null);
				}
				item.y = i*(item.height);
				// item.left = 0;
				this.box_right_builder.addChild(item);
			}
		}
		private function building_builder_add(model:ModelBuiding):void{
			var item:ItemBuilder;
			for(var i:int=0;i<this.box_right_builder.numChildren;i++){
				item = this.box_right_builder.getChildAt(i) as ItemBuilder;
				if(!item.mModel){
					item.initData(model);
					break;
				}
			}
		}
		/**
		 * 
		 * 
		 * 
		 */
		private function initEquip():void{
			var arr:Array = ModelManager.instance.modelInside.mEquipArr;
			var len:int = 1;
			var item:ItemEquip;
			for(var i:int = 0; i < len; i++)
			{
				item = new ItemEquip();
				if(i<arr.length){
					item.initData(arr[i]);
				}
				else{
					item.initData(null);
				}
				item.y = i*(item.height);

				item.name="itemEquip_"+i;
				// item.left = 0;
				this.box_right_equip.addChild(item);
				if(i==len-1)
					this.box_right_equip.height=item.y+item.height;
			}
			
		}
		private function initScience():void
		{
			var arr:Array = ModelManager.instance.modelInside.mScienceArr;
			var len:int = 1;
			var item:ItemScience;
			for(var i:int = 0; i < len; i++)
			{
				item = new ItemScience();
				if(i<arr.length){
					item.initData(arr[i]);
				}
				else{
					item.initData(null);
				}
				item.y = i*(item.height);
				// item.left = 0;
				item.name="itemScience";
				this.box_right_science.addChild(item);
				if(i==len-1)
					this.box_right_science.height=item.y+item.height;
			}
		}

		private function initAutoTrain():void{
			if(this.box_right_autotrain.getChildByName("itemAutotrain")==null){
				var item:ItemAutoTrain = new ItemAutoTrain();
				item.initData(null);
				item.name="itemAutotrain";
				this.box_right_autotrain.addChild(item);
			}else{
				(this.box_right_autotrain.getChildByName("itemAutotrain") as ItemAutoTrain).updateData();
			}
			
		}

		private function setBoxRight():void{
			
		}

		/**
		 * free buy 活动的按钮
		 */
		private function initFreeBuy():void{//弃用
			return;
			for(var j:int=0;j<4;j++){
				if(this.view_left.getChildByName("act"+i)){
					this.view_left.removeChild(this.view_left.getChildByName("act"+i));
				}
			}
			if(ViewManager.instance.mScenesArr.length!=0){
				return;
			}
			var free_buy:Object=ModelManager.instance.modelUser.records.free_buy;
			var listData:Array=[];

			
			for(var s:String in free_buy)
			{	
				if(free_buy[s]){
					var o:Object={};
					o["id"]=s;
					o["type"]=free_buy[s][0];
					o["time"]=free_buy[s][1];
					if(Tools.getTimeStamp(o["time"])>ConfigServer.getServerTimer()){
						listData.push(o);
					}
				}
			}
			for(var i:int=0;i<listData.length;i++){
				var item:ItemAct=new ItemAct();
				item.name="act"+i;
				//this.addChild(item);
				this.view_left.addChild(item);
				item.initData(listData[i]);
				item.x=0;
				item.y=i*item.height+10;
			}
		}
		private static var instance_guide:ViewMenuMain;
		
		public static function getButton(name:String):Sprite
		{
			var _this:ViewMenuMain = instance_guide;
			var sp:Sprite = null;
			sp = _this.view_bottom[name];
			sp || (sp = _this.view_top[name]);
			sp || (sp = _this.view_troop[name]);
			sp || (sp = _this.view_user[name]);
			sp || (sp = _this.view_left.getSpriteByName(name));
			return sp;
		}
		
		public static function getTroop(index:int):Sprite
		{
			var _this:ViewMenuMain = instance_guide;
			var sp:Sprite = _this.view_troop.getCellByIndex(index);
			return sp;
		}
		
		public static function getActButton(index:int):Sprite
		{
			var _this:ViewMenuMain = instance_guide;
			return _this.view_troop.getCellByIndex(index);
		}
	}

}