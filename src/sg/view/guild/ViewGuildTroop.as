package sg.view.guild
{
	import sg.fight.FightMain;
	import ui.guild.guildTroopUI;
	import sg.view.fight.ItemTroop;
	import sg.net.NetPackage;
	import laya.utils.Handler;
	import laya.events.Event;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import sg.manager.ModelManager;
	import sg.net.NetSocket;
	import sg.model.ModelHero;
	import laya.maths.MathUtil;
	import sg.model.ModelGuild;
	import sg.utils.Tools;
	import sg.model.ModelClub;
	import sg.view.country.ViewAlienTroopInfo;

	/**
	 * ...
	 * @author
	 */
	public class ViewGuildTroop extends guildTroopUI{//弃用
		//
		public var isOnlyOne:Boolean=false;
		public var isCreat:Boolean=false;
		public var hero_arr:Array=[];
		public var listData:Array=[];
		public var curData:Object={};
		public var curLv:int=0;
		public var busy_hero_arr:Array=[];
		//
		public var type:int=0;//0.异邦来访   1.沙盘演义
		public var curHeroStr:String="";
		public function ViewGuildTroop(){
			this.list.scrollBar.visible=false;
			this.list.itemRender=ItemTroop;
			this.list.renderHandler=new Handler(this,this.listRender);
			this.list.selectHandler=new Handler(this,this.listSelect);
			this.btnOK.on(Event.CLICK,this,this.joinClick);
		}
		override public function onAdded():void{
			this.text2.text="";
			this.text3.text=Tools.getMsgById("_guild_text47");// "在异邦来访的战斗中，不会损耗兵力";
			this.text4.text=Tools.getMsgById("_guild_text114");
			this.box0.visible=false;
			setData();
		}
		public function setData():void{
			listData=ModelManager.instance.modelUser.getMyHeroArr(true,"",null,true);
			this.list.selectedIndex=-1;
			if(this.currArg[0]=="pve"){
				type=1;
				setPVEdata();
			}else{
				type=0;
				setAlienData();
			}
			
		}

		public function setPVEdata():void{
			//this.titleLabel.text=Tools.getMsgById("_guild_text81");//"选择英雄上阵";
			this.comTitle.setViewTitle(Tools.getMsgById("_guild_text81"));
			this.text2.text="";
			this.text3.text="";
			isOnlyOne=true;
			isCreat=false;
			var index:int=0;
			curHeroStr=this.currArg[1];
			for(var i:int=0;i<listData.length;i++){
				var hero:ModelHero=listData[i];
				if(curHeroStr==hero.id){
					index=i;
					break;
				}
			}
			this.list.array=listData;
			itemClick(index,this.list.getCell(index) as ItemTroop);
		}

		public function setAlienData():void{
			curData=ModelManager.instance.modelGuild;
			curLv=this.currArg[1];
			getBusyHeroArr();
			this.list.array=listData;
			this.btnOK.gray=true;
			this.comTitle.setViewTitle(isCreat?Tools.getMsgById("_guild_text52"):Tools.getMsgById("_guild_text57"));
			isCreat=false;
			this.btnOK.label=isCreat?Tools.getMsgById("_guild_text58"):Tools.getMsgById("_guild_text59");//"确认创建":"确认加入";
			var n:Number=ModelManager.instance.modelClub.getMyHeroNum(curLv);
			isOnlyOne=n==ModelManager.instance.modelClub.max_player_hero-1;
			setTextLabel(n);

		}

		public function getBusyHeroArr():void{
			busy_hero_arr=[];
			var all:Array=ModelManager.instance.modelClub.alien;
			for(var i:int=0;i<all.length;i++){
				if(all[i].lock==null){
					var team:Array=all[i]["team"][0]["troop"];
					for(var j:int=0;j<team.length;j++){
						var o:Object=team[j];
						if(o.uid==ModelManager.instance.modelUser.mUID){
							busy_hero_arr.push(o.hid);
						}
					}
				}
			}
		}

		public function setTextLabel(n:Number):void{
			this.box0.visible=true;
			this.text2.text=n+"/"+ModelManager.instance.modelClub.max_player_hero;
			btnOK.gray=!(n>=1);
		}

		public function listRender(cell:ItemTroop,index:int):void{
			cell.setData(hero_arr.indexOf(listData[index].id)!=-1,listData[index]);
			cell.boxState.visible=false;
			cell.gray=(busy_hero_arr.indexOf(listData[index].id)!=-1);
			cell.offAll(Event.CLICK);
			cell.on(Event.CLICK,this,this.itemClick,[index,cell]);
		}
		public function listSelect(index:int):void{

		}

		public function itemClick(index:int,item:ItemTroop):void{
			if(item.gray){
				return;
			}
			if(isOnlyOne){
				btnOK.gray=false;
				if(index==this.list.selectedIndex){
					return;
				}
				hero_arr=[];
				hero_arr.push(this.listData[index].id);
				this.setSelection(false);
				this.list.selectedIndex=index;
				if(!isCreat){
					setTextLabel(2);
				}
			}else{
				if(item.mSelected){
					var n:Number=hero_arr.indexOf(this.listData[index].id);
					if(n!=-1){
						hero_arr.splice(n,1);
					}
					item.setData(false,null);	
				}else{
					if(hero_arr.length==2){
						return;
					}
					hero_arr.push(this.listData[index].id);
					item.setData(true,null);
				}
				setTextLabel(hero_arr.length);
				
			}
		}

		
		public function setSelection(b:Boolean):void{
			if(this.list.selection){
                var tt:ItemTroop=this.list.selection as ItemTroop;
				tt.setData(b,null);
            }
		}

		public function joinClick():void{
			if(hero_arr.length==0){
				return;
			}

			if(type==0){
				var sendData:Object={};
				sendData["hids"]=hero_arr;
				sendData["alien_id"]=curLv;
				NetSocket.instance.send("club_alien_join",sendData,Handler.create(this,socketCallBack));
			}else{
				if(hero_arr[0]==curHeroStr){
					ViewManager.instance.closePanel(this);
					return;
				}
				ModelManager.instance.modelGuild.event(ModelGuild.EVENT_UPDATE_PVE,[curHeroStr,hero_arr[0]]);
				ViewManager.instance.closePanel(this);
			}

		}

		public function socketCallBack(np:NetPackage):void{
			ModelManager.instance.modelUser.updateData(np.receiveData);
			ViewManager.instance.closePanel(this);
			//异族入侵加入队伍，人满自动开战
			var receiveData:* = np.receiveData;
			if (receiveData.pk_data){
				FightMain.startBattle(receiveData, this, this.outFight, [receiveData]);
			}else{
				
			}
			
			if(isCreat){
				//ViewManager.instance.showView(ConfigClass.VIEW_GUILD_TROOP_INFO,[null,curLv]);
				//ModelManager.instance.modelGuild.event(ModelGuild.EVENT_UPDATE_ALIEN,null);
			}else{
				//ViewManager.instance.closePanel();
				//ModelManager.instance.modelGuild.event(ModelGuild.EVENT_UPDATE_ALIEN,null);								
			}
			ModelManager.instance.modelClub.event(ModelClub.EVENT_ALIEN_MSG);
		}
		private function outFight(receiveData:*):void{

		}


		override public function onRemoved():void{
			this.list.scrollBar.value=0;
			hero_arr=[];
		}
	}

}