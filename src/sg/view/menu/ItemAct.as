package sg.view.menu
{
	import ui.menu.ItemActUI;
	import laya.events.Event;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import sg.cfg.ConfigServer;
	import sg.utils.Tools;
	import sg.manager.ModelManager;
	import sg.model.ModelUser;
	import sg.utils.SaveLocal;

	/**
	 * ...
	 * @author
	 */
	public class ItemAct extends ItemActUI{//弃用
		public var curId:String="";
		public var curTime:Number=0;
		public function ItemAct(){
			//this.on(Event.CLICK,this,this.click);
		}

		public function initData(obj:Object):void{
			curId=obj.id;
			curTime=Tools.getTimeStamp(obj.time);
			//this.nameLabel.text=curId+"_"+obj.type;
			this.timeLabel.text="";
			//this.imgIcon.skin="";
			time_tick();
			Laya.timer.loop(1000,this,time_tick);
			//var o:Object=SaveLocal.getValue("free_buy");
			//if(o){
			//	var oTime:Number=!o.hasOwnProperty(curId)?0:o[curId].time;
			//	var mark:int=!o.hasOwnProperty(curId)?1:o[curId].mark;
			//	if(oTime!=curTime || mark==0){
					//ViewManager.instance.showView(ConfigClass.VIEW_FREE_BUY,curId);
			//	}
			//}else{
				//ViewManager.instance.showView(ConfigClass.VIEW_FREE_BUY,curId);
			//}
		}

		public function time_tick():void{
			var now:Number=ConfigServer.getServerTimer();
			if(now>curTime){
				Laya.timer.clear(this,time_tick);
				ModelManager.instance.modelUser.event(ModelUser.EVENT_ACT_TIME_OUT);
			}else{
				this.timeLabel.text=Tools.getTimeStyle(curTime-now);
			}
		}


		public function click():void{
			ViewManager.instance.showView(ConfigClass.VIEW_FREE_BUY,curId);
		}
		
	}

}