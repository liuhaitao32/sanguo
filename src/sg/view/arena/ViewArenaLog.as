package sg.view.arena
{
	import ui.arena.arenaLogUI;
	import laya.utils.Handler;
	import ui.arena.itemArenaLogUI;
	import ui.arena.itemArenaLog1UI;
	import sg.model.ModelArena;
	import sg.utils.Tools;
	import sg.manager.AssetsManager;
	import laya.events.Event;
	import sg.net.NetSocket;
	import sg.fight.FightMain;
	import sg.net.NetPackage;
	import sg.manager.ModelManager;

	/**
	 * ...
	 * @author
	 */
	public class ViewArenaLog extends arenaLogUI{

		public var model:ModelArena;
		private var mData:Object;
		public function ViewArenaLog(){
			this.tab1.selectHandler = new Handler(this,tabChange1);
			this.tab2.selectHandler = new Handler(this,tabChange2);

			this.list.scrollBar.visible = false;
		}

		override public function onAdded():void{
			mData = this.currArg;
			this.setTitle(Tools.getMsgById("arena_text18"));//"擂台战报");

			model = ModelArena.instance;
			this.tab1.labels = Tools.getMsgById("arena_text19")+","+Tools.getMsgById("arena_text18");//"个人战报,擂台战报";
			this.tab1.selectedIndex = 0;

			var arr:Array = model.getArenaGroup();
			var s:String = "";
			for(var i:int=0;i<arr.length;i++){
				s += Tools.getMsgById(ModelArena.textArr[arr[i]]);
				s += i==arr.length-1 ? "" : ",";
			}
			this.tab2.labels = s;
			this.tab2.selectedIndex = 0;
		}

		private function tabChange1(index:int):void{
			if(index>-1){
				var n:Number = this.tab2.selectedIndex;	
				this.tab2.selectedIndex = -1;
				this.tab2.selectedIndex = n;
			}
		}

		private function tabChange2(index:int):void{
			if(index>-1){
				if(mData[index]!=null){
					checkList();
				}else{
					var n:Number = index;
					NetSocket.instance.send("get_arena_log_list",{"arena_index":n},Handler.create(this,function(np:NetPackage):void{
						mData[n+""] = np.receiveData;
						checkList();
					}));
				}
			}
		}

	    private function checkList():void
        {
            if(this.list.renderHandler){
                this.list.renderHandler.clear();
            }
            this.list.array = [];
			var a:Array = [];
			var arr:Array = [];
			if(this.tab1.selectedIndex == 0){
				this.list.itemRender = itemArenaLogUI;
				this.list.renderHandler = new Handler(this,listRender1);
				a = mData[this.tab2.selectedIndex][1];
				for(var i:int=a.length-1;i>=0;i--){
					arr.push(a[i]);
				}

				this.list.array = arr;
			}else{
				this.list.itemRender = itemArenaLog1UI;
				this.list.renderHandler = new Handler(this,listRender2);
				a = mData[this.tab2.selectedIndex][0];
				for(var j:int=a.length-1;j>=0;j--){
					
					if(a[j].winner==0){
						arr.push({data:a[j],win:1});	
					}

					arr.push({data:a[j],win:0});

					if(j==0){
						arr.push({data:a[j],win:2});
					}
				}
				if(arr.length == 0){
					var o:Object=model.arena.arena_list[this.tab2.selectedIndex].user_list[0];
					if(o){
						arr.push({data:{"done_time":o.win_time,
									"team":[{"country":o.country,"uname":o.uname},
											{"country":o.country,"uname":o.uname}]},
								  win:2});
					}
					
				}
				
				this.list.array = arr;
			}
            
			this.textTips.text = this.list.array.length==0 ? Tools.getMsgById('_explore061'):"";
        }

		private function listRender1(cell:itemArenaLogUI,index:int):void{
			var o:Object = this.list.array[index];			
			cell.img.skin =  o.team[o.winner].uid==ModelManager.instance.modelUser.mUID ? "ui/icon_win06.png" : "ui/icon_win07.png";
			cell.imgItem.skin = AssetsManager.getAssetItemOrPayByID(model.mItemId);
			if(o.team[1].uid==ModelManager.instance.modelUser.mUID){//我防守
				cell.imgItem.visible = false;
				cell.tNum.text = "";
			}else{
				cell.imgItem.visible = o.attack_item_num != 0;
				cell.tNum.text = o.attack_item_num==0 ? "" : "+"+o.attack_item_num;
			}
			cell.txtImg.visible = cell.tNum.text!="";

			cell.text0.text = Tools.getMsgById(ModelArena.textArr[model.getArenaGroup()[this.tab2.selectedIndex]]);
			var s1:String = Tools.getMsgById("arena_text09");
			var s2:String = Tools.getMsgById("arena_text10");
			cell.text1.text = o.team[0].uid == ModelManager.instance.modelUser.mUID ? s1:s2;//"攻擂" : "守擂";
			cell.tTime.text =  Tools.dateFormat(o.done_time,2);//"时间：---";
			cell.text1.color = o.team[0].uid == ModelManager.instance.modelUser.mUID ? "#ff2a2a" : "#61d4ff";

			cell.country0.setCountryFlag(o.team[0].country);
			cell.text01.text = o.team[0].uname;
			cell.text02.text = s1;//"攻擂";

			cell.country1.setCountryFlag(o.team[1].country);
			cell.text11.text = o.team[1].uname;
			cell.text12.text = s2;//"守擂";

			cell.imgCheck.off(Event.CLICK,this,itemClick);
			cell.imgCheck.on(Event.CLICK,this,itemClick,[index]);

		}

		private function itemClick(index:int):void{
			var o:Object = this.list.array[index];
			var _this:* = this;
			NetSocket.instance.send("get_arena_log",{"arena_index":this.tab2.selectedIndex,"log_index":o.login_index},Handler.create(_this,function(np:NetPackage):void{
				if(np.receiveData["pk_data"]){
					np.receiveData["pk_data"]["is_mine"] = true;
				}
				FightMain.startBattle(np.receiveData, _this, null);
			}));
		}

		private function listRender2(cell:itemArenaLog1UI,index:int):void{
			var o:Object = this.list.array[index].data;
			cell.tTime.text = Tools.dateFormat(o.done_time,2);//"时间---";
			cell.text0.text = Tools.getMsgById("arena_text14");//"挑战";
			cell.text1.text = Tools.getMsgById("arena_text11");//"擂主";
			
			cell.text2.text = o.winner==0 ? Tools.getMsgById("arena_text15"):Tools.getMsgById("arena_text16");//"成功" : "失败";//"成为擂主"
			cell.text2.bold = o.winner==0;
			cell.text2.color = o.winner==0 ? "#ffffff":"#828282";
			cell.text2.x = 547;

			cell.country0.setCountryFlag(o.team[0].country);
			cell.name0.text = o.team[0].uname;

			cell.country1.setCountryFlag(o.team[1].country);
			cell.name1.text = o.team[1].uname;
			if(this.list.array[index].win>0){
				if(this.list.array[index].win==2){//第一个加入的  直接成为擂主  时间往前去10秒
					cell.country0.setCountryFlag(o.team[1].country);
					cell.name0.text = o.team[1].uname;
					cell.tTime.text = Tools.dateFormat(Tools.getTimeStamp(o.done_time)-10*1000,2);
				}
				
				cell.text2.text = Tools.getMsgById("arena_text17");//"成为擂主！";
				cell.text2.bold = false;
				cell.text2.color = "#ffed53";
				
				cell.text0.visible = cell.text1.visible = cell.country1.visible = cell.name1.visible = false;
				cell.name0.x = cell.box1.x + cell.box1.width + 8;
				cell.text2.x = cell.name0.x + cell.name0.width + 8;
			}else{
				cell.text0.visible = cell.text1.visible = cell.country1.visible = cell.name1.visible = true;
				cell.name0.x = cell.box1.x + cell.box1.width + 8;
				cell.text0.x = cell.name0.x + cell.name0.width + 8; 
				cell.text1.x = cell.text0.x + cell.text0.width + 8;
				cell.box2.x = cell.text1.x + cell.text1.width + 8;
				cell.name1.x = cell.box2.x + cell.box2.width + 8;
				cell.text2.x = cell.name1.x + cell.name1.width + 8;
			}

		}

		override public function onRemoved():void{
			this.tab1.selectedIndex = this.tab2.selectedIndex = -1;
		}
	}

}