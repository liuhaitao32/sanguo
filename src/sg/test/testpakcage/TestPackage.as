package sg.test.testpakcage 
{
	import laya.display.Input;
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Button;
	import laya.ui.Label;
	import laya.utils.Handler;
	import sg.manager.ViewManager;
	import sg.map.utils.TestUtils;
	import sg.net.NetSocket;
	import sg.utils.SaveLocal;
	import ui.test.TestPakcageUI;
	
	/**
	 * ...
	 * @author light
	 */
	public class TestPackage extends TestPakcageUI {
		
		private static var shoucang:Array = [];//{type, time, send, title, content, beizhu}
		
		private static var all:Array = [];
		
		private static var instance:TestPackage;
		
		public var selelctItem:Object;
		
		public function TestPackage() {
			instance = this;
			var str:Object = SaveLocal.getValue("lichuang/shoucang");;
			shoucang = str ? JSON.parse(str.toString()) as Array : [];
			
			this.log_list.renderHandler = new Handler(this, this.renderItem);
			
			this.tab.selectHandler = new Handler(this, this.changeSelete);
			
			this.back.clickHandler = new Handler(this, function():void{
				this.selectContent.visible = true;
				this.editContent.visible = false;
				
				try {
					var item:Object = JSON.parse(this.inputText.text);
					selelctItem.content = item;
					this.save();
				} catch (e) {
					ViewManager.instance.showTipsTxt("有错误！");
				}
			});
			this.tab.selectedIndex = 0;
			this.editContent.visible = false;
			this.log_list.scrollBar.visible = false;
			this.send.clickHandler = new Handler(this, function():void {
				sendPackage(selelctItem);
			})
			this.mouseThrough = false;
		}
		
		private function save():void {
			var str:String = JSON.stringify(shoucang);
			SaveLocal.save("lichuang/shoucang", str);
		}
		
		private function changeSelete():void {			
			if (this.tab.selectedIndex == 3) {
				this.log_list.dataSource = shoucang.concat();
			} else {
				this.log_list.dataSource = all.filter(function(item:Object):Boolean {
					if (tab.selectedIndex == 0) return true;
					return  tab.selectedIndex == item.type;
				});
			}
		}
		
		
		
		private function renderItem(box:Box, index:int):void {
			box.mouseThrough = true;
			var item:Object = this.log_list.dataSource[index];
			Input(box.getChildByName("beizhu")).offAll(Event.CHANGE);
			Label(box.getChildByName("name")).text = item.title;
			Input(box.getChildByName("beizhu")).text = item.beizhu ? item.beizhu : "备注无";
			
			Input(box.getChildByName("beizhu")).on(Event.CHANGE, this, function(e):void {
				item.beizhu = Input(box.getChildByName("beizhu")).text;
			});
			
			Button(box.getChildByName("go")).visible = item.send;
			
			Button(box.getChildByName("go")).clickHandler = new Handler(this, function():void {
				//发送数据。
				sendPackage(item);
			});
			
			Button(box.getChildByName("save")).label = shoucang.indexOf(item) == -1 ? "收藏" : "取出";
			Button(box.getChildByName("save")).clickHandler = new Handler(this, function():void {
				var index:int = shoucang.indexOf(item);
				if (index == -1) {
					shoucang.push(item);
				} else {
					shoucang.splice(index, 1);					
					if (tab.selectedIndex == 3) {
						callLater(changeSelete);
					}
				}
				this.save();
				Button(box.getChildByName("save")).label = shoucang.indexOf(item) == -1 ? "收藏" : "取出";
				
			});
			
			Label(box.getChildByName("time")).text = new Date(item.time).toLocaleDateString() + " " + new Date(item.time).toLocaleTimeString();
			
			Button(box.getChildByName("edit")).clickHandler = new Handler(this, function():void {
				selectContent.visible = false;
				editContent.visible = true;
				this.showContent(item);
			});
		}
		
		public function showContent(item:Object):void {
			//{type, time, send, title, content, beizhu}
			this.inputText.text = JSON.stringify(item.content);
			this.title_txt.text = item.title;
			this.beizhu_txt.text = item.beizhu || "";
			this.selelctItem = item;
			
		}
		
		private function sendPackage(item:Object):void  {
			NetSocket.instance.send(item.title, item.content);
		}
		
		public function show():void {
			this.visible = true;			
			this.changeSelete();
		}
		
		public function hide():void {
			this.visible = false;			
			this.changeSelete();
		}
		
		public static function addPackage(title:String, obj:Object, send:Boolean):void  {
			if (!TestUtils.isTestShow) return;
			all.push({type:send ? 1 : 2, time:new Date().getTime(), send:send, content:obj, beizhu:"", title:title});
		}
		
	}

}

