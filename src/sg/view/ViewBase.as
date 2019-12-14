package sg.view
{
	import laya.events.Event;
	import laya.display.Sprite;
	import laya.ui.Image;
	import laya.ui.Button;
	import laya.utils.Tween;
	import laya.ui.Component;
	import laya.display.Node;
	import laya.ui.Box;
	import sg.utils.Tools;
	import laya.utils.Handler;
	import laya.ui.List;

	/**
	 * ...
	 * @author
	 */
	public class ViewBase extends BaseSprite{
		public var id:String = "";
		public var mCurrArg:* = null;//额外参数
		public var mBg:Image;
		public var mBgType:int;
		public var mIsOpen:Boolean = false;
		public function set currArg(v:*):void
		{
			this.mCurrArg = v;
		}
		public function get currArg():*
		{
			return this.mCurrArg;
		}		
		public function ViewBase(){
			//继承ui自动生成的对应界面的as类,实现具体功能
			this.on(Event.DISPLAY, this, this._onDisplay);
		}
		private function _onDisplay():void{
		}
		private function onRemove():void{
			this.mIsOpen = false;
			this.onRemovedBase();
		}
		private function onAdd():void{
			this.mIsOpen = true;
			this.onAddedBase();
		}
		//
		public function init():void{
			this.once(Event.REMOVED,this,this.onRemove);
			this.once(Event.ADDED,this,this.onAdd);
			//
			this.initData();			
		}
		public function clearEvent():void{
			this.off(Event.REMOVED,this,this.onRemove);
			this.off(Event.ADDED,this,this.onAdd);			
		}
		/**
		 * 需要覆盖，初始化数据，变量用
		 */
		public function initData():void{}
		public function checkBg(type:int):void{}
		public function onAddedBase():void{
			
		}
		public function onRemovedBase():void {
		}
		/**
		 * 需要覆盖，处理显示对象，开始状态
		 */
		public function onAdded():void{
		}
		/**
		 * 需要覆盖，处理显示对象，清理
		 */
		public function onRemoved():void {
		}
		public function clear():void{
		}

		/**
		 * 根据名字获取界面中的对象
		 * @param	name
		 * @return 	Sprite || undefined
		 */
		public function getSpriteByName(name:String):*
		{
			var reg:RegExp = /(.+)_(\d+)/;
			if (reg.test(name)) {
				var result:Array = name.match(reg);
				var list:List = this[result[1]];
				if (list is List) {
					return list.getCell(parseInt(result[2]));
				}
			}
			if(this[name] is Sprite)	return this[name];
			if(this.getChildByName(name) is Sprite)	return this.getChildByName(name);
			// console.warn('Get sprite error ! Class: ' + this['constructor'].name + '   ' + name);
		}
	}

}