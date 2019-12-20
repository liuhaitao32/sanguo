package sg.view.qqdt {
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Button;
	import laya.ui.HBox;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.ui.List;
	import laya.utils.Browser;
	import laya.utils.Handler;
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.map.utils.ArrayUtils;
	import sg.model.ModelQQDT;
	import sg.net.NetPackage;
	import sg.net.NetSocket;
	import sg.utils.ArrayUtil;
	import sg.utils.TimeHelper;
	import sg.utils.Tools;
	import ui.lanzhuanguizuUI;
	import ui.bag.bagItemUI;
	
	/**
	 * ...
	 * @author light
	 */
	public class ViewQQDT extends lanzhuanguizuUI {
		
		public static var isTest:Boolean = true;
		
		public function get dtData():Object{return ConfigServer.system_simple.qq_blue; }
		
		public function get appId():String{return this.dtData.appId}
		
		public function get dtUserData():Object {
			return ModelManager.instance.modelUser.data["qqgame_records"];
		}
		
		public function set dtUserData(value:Object):void {
			ModelManager.instance.modelUser.data["qqgame_records"] = value;
		}
		
		public function ViewQQDT() {
			
		}
		
		override public function init():void {
			super.init();			
		}
		
		private function init2():void {
			this.kaitong_btn.clickHandler = new Handler(this, function():void {
				Platform.h5_sdk_obj.NewOpenGameVIPService.show(this.appId,
																function():void {trace("11111111")},  
																null,  //统计ID
																3,  //开通那种蓝钻
																5   //开通时长
																);
			});
			
			this.nianfei_btn.clickHandler = new Handler(this, function():void {
				Platform.h5_sdk_obj.NewOpenGameVIPService.show(this.appId,
																function():void {trace("11111111")},  
																null,  //统计ID
																1  //开通那种蓝钻
																);
			});
			this.tabs.on(Event.CHANGE, this, function():void {
				this.showIndex(this.tabs.selectedIndex);
			});
			this.tabs.selectedIndex = 0;
		}
		
		public function showIndex(index:int):void {
			for (var i:int = 0, len:int = 4; i < len; i++) {
				this["content_" + i].visible = false;
			}
			
			this["content_" + index].visible = true;
			
			if (!this["content_" + index].inited) {
				this["update" + index]();
				this["content_" + index].inited = true;
			}
			
		}
		
		public function update0():void {
			this.herf_txt.on(Event.CLICK, this, function():void {
				Browser.window.open(this.dtData.blue_link);
			});
		}
		
		override public function test_clip_int(type:int):void {
			this.alpha = 0;
			ModelQQDT.instance.loadDT(new Handler(this, function():void {
				this.alpha = 1;
				this.init2();
				testShow2(type);
			}));	
			
		}
		
		private function testShow2(type:int):void {
			super.test_clip_int(type);
		}
		
		public function update1():void {
			this.lingqu_btn.clickHandler = new Handler(this, function():void {
				NetSocket.instance.send("qqgame_blue_new_reward", {}, new Handler(this, function(data:NetPackage):void {
					this.showReward(data);
					this.update1();
				}));				
			});
			
			this.container.destroyChildren();
			var i:int = 0;
			for (var name:String in this.dtData.blue_new_reward) {
				var item:bagItemUI = new bagItemUI();
				this.container.addChild(item);
				item.setData(name);
				item.scale(0.6, 0.6);
			}
			
			this.lingqu_btn.gray = !(this.lingqu_btn.mouseEnabled = (ModelQQDT.instance.data.is_blue_vip && !this.dtUserData.new_reward));
			
			if (this.lingqu_btn.gray && this.dtUserData.new_reward) {
				this.lingqu_btn.label = Tools.getMsgById("_jia0034");
			} else {
				this.lingqu_btn.label = Tools.getMsgById("member_06");
			}
			
			//Box(this.container.parent).centerX = -1;
			//Box(this.container.parent).centerX = 0;
		}
		
		public function update2():void {
			var arr:Array = [];
			for (var name:String in this.dtData.blue_lvup_reward) {
				arr.push({name:parseInt(name), data:this.dtData.blue_lvup_reward[name]});
			}
			arr = ArrayUtils.sortOn(["name"], arr);
			this.content_2.array = arr;
			this.content_2.renderHandler = new Handler(this, onRenderHandler);
		}
		
		private function onRenderHandler(box:Box, index:int):void {
			var obj:Object = this.content_2.array[index];
			var level:int = obj.name;
			var data:Object = obj.data;
			
			Label(box.getChildByName("level_txt")).text = level.toString();
			var btn:Button = Button(box.getChildByName("lingqu_btn"));
			btn.gray = !(btn.mouseEnabled = (ModelManager.instance.modelInside.getBase().lv >= level && this.dtUserData.lvup_records.indexOf(level) == -1));
			if (btn.gray && !(this.dtUserData.lvup_records.indexOf(level) == -1)) {
				btn.label = Tools.getMsgById("_jia0034");
			} else {
				btn.label = Tools.getMsgById("_jia0035");
			}
			
			btn.clickHandler = new Handler(this, function():void {
				NetSocket.instance.send("qqgame_blue_lvup_reward", {reward_lv:level}, new Handler(this, function(data:NetPackage):void {
					this.showReward(data);
					btn.gray = !(btn.mouseEnabled = (ModelManager.instance.modelInside.getBase().lv >= level && this.dtUserData.lvup_records.indexOf(level) == -1));
					if (btn.gray && !(this.dtUserData.lvup_records.indexOf(level) == -1)) {
						btn.label = Tools.getMsgById("_jia0034");
					} else {
						btn.label = Tools.getMsgById("_jia0035");
					}
				}));
			});
			
			for (var name:String in data) {
				var item:bagItemUI = new bagItemUI();
				item.setData(name);
				HBox(box.getChildByName("content")).addChild(item);
				item.scale(0.5, 0.5);
			}			
		}
		
		
		private function showReward(data:NetPackage):void {		
			this.dtUserData = data.receiveData.qqgame_records;
			if (data.receiveData.gift_dict) ViewManager.instance.showRewardPanel(data.receiveData.gift_dict);
			ModelManager.instance.modelUser.updateData(data.receiveData);
		}
		
		public function update3():void {
			var list:List = this.content_3.getChildByName("list") as List;
			var arr:Array = [];
			for (var name:String in this.dtData.blue_day_reward) {
				arr.push({name:parseInt(name), data:this.dtData.blue_day_reward[name]});
			}
			arr = ArrayUtils.sortOn(["name"], arr);
			
			
			list.array = arr;
			list.renderHandler = new Handler(this, function(box:Box, index:int):void {
				this.onRenderHandler2(box, index, arr[index]);
			});
			
			//var item1:bagItemUI = new bagItemUI();
			//item1.setData("bag1");
			//this.dengjibao1_content.addChild(item1);
			//
			//var item2:bagItemUI = new bagItemUI();
			//item2.setData("bag2");
			//this.dengjibao2_content.addChild(item2);
			
			this.ling1_btn.gray = !(this.ling1_btn.mouseEnabled = (ConfigServer.getServerTimer() / 1000 < ModelQQDT.instance.data.year_vip_valid_time) && this.isTodayReward("year_time"));
			if (this.ling1_btn.gray && !this.isTodayReward("year_time")) {
				this.ling1_btn.label = Tools.getMsgById("_jia0034");
			} else {
				this.ling1_btn.label = Tools.getMsgById("_jia0035");
			}
			this.ling1_btn.clickHandler = new Handler(this, function():void {
				NetSocket.instance.send("qqgame_blue_daily_reward", {blue_lv: -1}, new Handler(this, function(data:NetPackage):void {
					this.showReward(data);
					this.ling1_btn.gray = !(this.ling1_btn.mouseEnabled = (ConfigServer.getServerTimer() / 1000 < ModelQQDT.instance.data.year_vip_valid_time) && this.isTodayReward("year_time"));
					if (this.ling1_btn.gray && !this.isTodayReward("year_time")) {
						this.ling1_btn.label = Tools.getMsgById("_jia0034");
					} else {
						this.ling1_btn.label = Tools.getMsgById("_jia0035");
					}
				}));
				
			});
			
			this.ling2_btn.gray = !(this.ling2_btn.mouseEnabled = (ConfigServer.getServerTimer() / 1000 < ModelQQDT.instance.data.super_vip_valid_time) && this.isTodayReward("super_time"));
			if (this.ling2_btn.gray && !this.isTodayReward("super_time")) {
				this.ling2_btn.label = Tools.getMsgById("_jia0034");
			} else {
				this.ling2_btn.label = Tools.getMsgById("_jia0035");
			}
			this.ling2_btn.clickHandler = new Handler(this, function():void {
				NetSocket.instance.send("qqgame_blue_daily_reward", {blue_lv: -2}, new Handler(this, function(data:NetPackage):void {
					this.showReward(data);
					this.ling2_btn.gray = !(this.ling2_btn.mouseEnabled = (ConfigServer.getServerTimer() / 1000 < ModelQQDT.instance.data.super_vip_valid_time) && this.isTodayReward("super_time"));					
					if (this.ling2_btn.gray && !this.isTodayReward("super_time")) {
						this.ling2_btn.label = Tools.getMsgById("_jia0034");
					} else {
						this.ling2_btn.label = Tools.getMsgById("_jia0035");
					}
				}));
			});
		}
		
		private function onRenderHandler2(box:Box, index:int, obj:Object):void {
			var level:int = obj.name;
			var data:Object = obj.data;
			
			
			Image(box.getChildByName("level_img")).skin = "lanzuan/nianl_1_" + level + ".png";;
			
			var enable:Boolean = ModelQQDT.instance.data["blue_vip_level"] == level && this.isTodayReward("blue_time");
			var btn:Button = Button(box.getChildByName("lingqu_btn"));
			btn.gray = !(btn.mouseEnabled = enable);
			if (ModelQQDT.instance.data["blue_vip_level"] == level) {
				if (btn.gray && !this.isTodayReward("blue_time")) {
					btn.label = Tools.getMsgById("_jia0034");
				} else {
					btn.label = Tools.getMsgById("_jia0035");
				}
			} else {
				btn.label = Tools.getMsgById("_jia0035");
			}
			
			
			btn.clickHandler = new Handler(this, function():void {				
				NetSocket.instance.send("qqgame_blue_daily_reward", {blue_lv:ModelQQDT.instance.data["blue_vip_level"]}, new Handler(this, function(data:NetPackage):void {
					this.showReward(data);
					var enable2:Boolean = ModelQQDT.instance.data["blue_vip_level"] == level && this.isTodayReward("blue_time");
					btn.gray = !(btn.mouseEnabled = enable2);
					if (ModelQQDT.instance.data["blue_vip_level"] == level) {
						if (btn.gray && !this.isTodayReward("blue_time")) {
							btn.label = Tools.getMsgById("_jia0034");
						} else {
							btn.label = Tools.getMsgById("_jia0035");
						}
					} else {
						btn.label = Tools.getMsgById("_jia0035");
					}
				}));
			});
			HBox(box.getChildByName("content")).destroyChildren();
			for (var name:String in data) {
				var item:bagItemUI = new bagItemUI();
				item.setData(name);
				HBox(box.getChildByName("content")).addChild(item);
				item.scale(0.5, 0.5);
				item.y = -2;
			}
			
			
		}
		
		public function isTodayReward(type:String):Boolean {
			return (this.dtUserData.daily[type] == null || Tools.isNewDay(this.dtUserData.daily[type]));
		}
	}

}