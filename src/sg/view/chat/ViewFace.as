package sg.view.chat
{
	import ui.chat.chatFaceUI;
	import laya.utils.Handler;
	import laya.ui.Image;
	import sg.model.ModelChat;
	import laya.net.URL;
	import laya.events.Event;
	import sg.manager.ModelManager;
	import laya.ui.Box;
	import sg.manager.ViewManager;
	import sg.utils.Tools;
	import sg.cfg.ConfigServer;
	import sg.map.utils.ArrayUtils;

	/**
	 * ...
	 * @author
	 */
	public class ViewFace extends chatFaceUI{

		private var mIsMember:Boolean = false;//是否购买了永久卡
		private var mData:Array;
		public function ViewFace(){
			this.list.renderHandler = new Handler(this,listRender);
			this.list.scrollBar.visible = false;

			mData = [];
			var cfg:Object = ConfigServer.system_simple.cfg_face;
			for(var key:String in cfg){
				if(cfg[key].ids && cfg[key].ids.length > 0){
					var o:Object = {};
					o["index"] = Number(key);
					o["name"] = cfg[key].name;
					o["ids"] = cfg[key].ids;
					mData.push(o);
				}
			}
			mData = ArrayUtils.sortOn(["index"],mData,false);

			mIsMember = ModelManager.instance.modelUser.member_check==1;

			this.btn_close.on(Event.CLICK,this,function():void{
				ModelManager.instance.modelChat.event(ModelChat.EVENT_CLOSE_FACE);
			});

			var labels:String = '';
			for(var i:int=0;i<mData.length;i++){
				labels += Tools.getMsgById(mData[i].name);
				labels += i == mData.length-1 ? '' : ',';
			}
			this.tab.labels = labels;
			this.tab.selectHandler = new Handler(this,tabChange);
			this.tab.selectedIndex = -1;
			this.tab.selectedIndex = 0;
		}

		private function tabChange(index:int):void{
			if(index<0) return;
			this.list.array = mData[index].ids;
		}

		private function listRender(cell:Box,index:int):void{
			var s:String = this.list.array[index];
			var img:Image = cell.getChildByName('faceImg') as Image;
			img.skin ='face/'+s+'.png';
			
			cell.off(Event.CLICK,this,itemClick);
			cell.on(Event.CLICK,this,itemClick,[s]);
		}

		private function itemClick(id:String):void{
			if(this.tab.selectedIndex == 0 || mIsMember){
				var s:String = ModelChat.getFaceName(id);
				if(s == ''){
					trace("缺少表情文字配置");
					return;
				}
				s = '/' + s + '/';
				ModelManager.instance.modelChat.event(ModelChat.EVENT_ADD_FACE,s);
			}else{
				ViewManager.instance.showTipsTxt(Tools.getMsgById('face_tips0'));
			}
		}

	}

}