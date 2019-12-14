package sg.view.guild
{
	import ui.guild.guildResourceUI;
	import sg.view.com.ComPayType;
	import sg.manager.AssetsManager;
	import sg.manager.ModelManager;
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.ui.ProgressBar;
	import laya.ui.Label;
	import sg.model.ModelGuild;
	import sg.cfg.ConfigServer;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.manager.ViewManager;
	import sg.utils.Tools;
	import laya.display.Animation;
	import sg.manager.EffectManager;
	import laya.display.Node;

	/**
	 * ...
	 * @author
	 */
	public class ViewGuildResource extends guildResourceUI{

		public var config_guild_achi:Object;
		public var ani:Animation;
		public function ViewGuildResource(){
			this.btnGet.on(Event.CLICK,this,this.getClick);
			this.btnInfo.on(Event.CLICK,this,function():void{
				ViewManager.instance.showTipsPanel(Tools.getMsgById(ConfigServer.guild.configure.info));
			});
			this.rewardList.renderHandler=new Handler(this,listRender);
		}

		override public function onAdded():void{
			this.textLabel01.text=Tools.getMsgById("_guild_text70");
			this.textLabel02.text=Tools.getMsgById("_guild_text71");
			this.textLabel03.text=Tools.getMsgById("_guild_text72");
			this.textLabel04.text=Tools.getMsgById("_guild_text73");
			this.textLabel05.text=Tools.getMsgById("_guild_text74");
			this.btnGet.label=Tools.getMsgById("_jia0035");

			config_guild_achi=ConfigServer.guild.achievement;
			
			(this.Box0.getChildByName("com0") as ComPayType).setData(AssetsManager.getAssetItemOrPayByID("coin"),ModelManager.instance.modelGuild.coin+"");
			(this.Box0.getChildByName("com1") as ComPayType).setData(AssetsManager.getAssetItemOrPayByID("gold"),ModelManager.instance.modelGuild.gold+"");
			(this.Box0.getChildByName("com2") as ComPayType).setData(AssetsManager.getAssetItemOrPayByID("food"),ModelManager.instance.modelGuild.food+"");

			(this.Box1.getChildByName("com0") as ComPayType).setData(AssetsManager.getAssetItemOrPayByID("coin"),ModelManager.instance.modelGuild.daily_coin+"");
			(this.Box1.getChildByName("com1") as ComPayType).setData(AssetsManager.getAssetItemOrPayByID("gold"),ModelManager.instance.modelGuild.daily_gold+"");
			(this.Box1.getChildByName("com2") as ComPayType).setData(AssetsManager.getAssetItemOrPayByID("food"),ModelManager.instance.modelGuild.daily_food+"");


			var arr:Array=ModelManager.instance.modelGuild.depot_reward[0];
			if(arr[0]==0 && arr[1]==0 && arr[2]==0){
				this.btnGet.visible=false;	
			}else{
				this.btnGet.visible=(ModelManager.instance.modelGuild.depot_reward[1]).indexOf(Number(ModelManager.instance.modelUser.mUID))!=-1;
			}
			
			if(this.btnGet.visible){
				if(ani==null){
					var ani:Animation=EffectManager.loadAnimation("glow038");
					ani.pos(this.btnGet.width/2,this.btnGet.height/2);
					this.btnGet.addChild(ani);
				}
			}
			
			(this.Box2.getChildByName("com0") as ComPayType).setData(AssetsManager.getAssetItemOrPayByID("coin"),arr[1]+"");
			(this.Box2.getChildByName("com1") as ComPayType).setData(AssetsManager.getAssetItemOrPayByID("gold"),arr[0]+"");
			(this.Box2.getChildByName("com2") as ComPayType).setData(AssetsManager.getAssetItemOrPayByID("food"),arr[2]+"");
		

			this.weekKillLabel.text=Tools.getMsgById("_guild_text34");// "周杀敌";
			this.weekKillNum.text=ModelManager.instance.modelGuild.week_kill+"";
			this.weekBuildLabel.text=Tools.getMsgById("_guild_text35");//"周建设";
			this.weekBuildNum.text=ModelManager.instance.modelGuild.week_build+"";

			for(var i:int=0;i<3;i++){
				var k_box:Box=boxWeekKill.getChildByName("com"+i) as Box;
				var b_box:Box=boxWeekBuild.getChildByName("com"+i) as Box;

				k_box.on(Event.CLICK,this,boxClick,[ModelGuild.kill_achi_arr[i],[0,i]]);
				b_box.on(Event.CLICK,this,boxClick,[ModelGuild.build_achi_arr[i],[1,i]]);
				
				var _img0:Image=k_box.getChildByName("igGet") as Image;
				var _imgLock0:Image=k_box.getChildByName("imgLock") as Image;
				var _pro0:ProgressBar=k_box.getChildByName("pro") as ProgressBar;
				var _label0:Label=k_box.getChildByName("num") as Label;
				_label0.text=config_guild_achi[ModelGuild.kill_achi_arr[i]].need[0];
				var max_kill_num:Number=config_guild_achi[ModelGuild.kill_achi_arr[i]].need[0];
				var cur_kill_num:Number=ModelManager.instance.modelGuild.week_kill;	
				var n:Number=ConfigServer.guild.achievement[ModelGuild.kill_achi_arr[i]].days;
				_imgLock0.visible=!(ModelManager.instance.modelGuild.getAddDays()>=n);
				
				
				

				var _img1:Image=b_box.getChildByName("igGet") as Image;
				var _imgLock1:Image=b_box.getChildByName("imgLock") as Image;
				var _pro1:ProgressBar=b_box.getChildByName("pro") as ProgressBar;
				var _label1:Label=b_box.getChildByName("num") as Label;
				_label1.text=config_guild_achi[ModelGuild.build_achi_arr[i]].need[0];
				_pro1.value=ModelManager.instance.modelGuild.week_build/config_guild_achi[ModelGuild.build_achi_arr[i]].need[0];
				
				var max_guild_num:Number=config_guild_achi[ModelGuild.build_achi_arr[i]].need[0];
				var cur_guild_num:Number=ModelManager.instance.modelGuild.week_build;	

				var nn:Number=ConfigServer.guild.achievement[ModelGuild.build_achi_arr[i]].days;
				_imgLock1.visible=!(ModelManager.instance.modelGuild.getAddDays()>=nn);
				

				if(i==0){
					_pro0.value=cur_kill_num/max_kill_num;
					_pro1.value=cur_guild_num/max_guild_num;		
				}else{
					var max_num2:Number=config_guild_achi[ModelGuild.kill_achi_arr[i-1]].need[0];
					if(cur_kill_num>max_num2){
						_pro0.value=cur_kill_num/max_kill_num;
					}else{
						_pro0.value=0;
					}

					var max_num3:Number=config_guild_achi[ModelGuild.build_achi_arr[i-1]].need[0];
					if(cur_guild_num>max_num3){
						_pro1.value=cur_guild_num/max_guild_num;
					}else{
						_pro1.value=0;
					}
				}	
				
				_img0.visible=(_pro0.value==1 && !_imgLock0.visible);
				_img1.visible=(_pro1.value==1 && !_imgLock1.visible);

				
			}
			boxClick(ModelGuild.kill_achi_arr[0],[0,0]);
			setTimerLabel();
		}

		public function boxClick(id:String,pos:Array):void{
			for(var j:int=0;j<3;j++){
				var k_box:Box=boxWeekKill.getChildByName("com"+j) as Box;
				var b_box:Box=boxWeekBuild.getChildByName("com"+j) as Box;
				((k_box.getChildByName("imgSelect")) as Image).visible=false;
				((b_box.getChildByName("imgSelect")) as Image).visible=false;
				
			}
			if(pos[0]==0){
				((boxWeekKill.getChildByName("com"+pos[1]) as Box).getChildByName("imgSelect") as Image).visible=true;
			}else{
				((boxWeekBuild.getChildByName("com"+pos[1]) as Box).getChildByName("imgSelect") as Image).visible=true;
			}

			var obj:Object=ConfigServer.guild.achievement[id];
			this.info0.text=Tools.getMsgById(obj.info);
			this.info1.text=Tools.getMsgById("guild_achi_"+obj.type,[obj.need[0]+""]);

			var nn:Number=obj.days;
			this.info2.text=(ModelManager.instance.modelGuild.getAddDays()>=nn)?"":Tools.getMsgById("guild_achi_days",[nn]);
			if(this.info2.text==""){
				conditionBoxLayout([this.info0,this.info1,boxReeward],25,8);
			}else{
				conditionBoxLayout([this.info2,this.info0,this.info1,boxReeward],13,0);
			}
			if(obj.reward && obj.reward.length!=0){
				var _reward:Array=[["coin",obj.reward[1]],["gold",obj.reward[0]],["food",obj.reward[2]]];
				var arr:Array=[];
				for(var i:int=0;i<_reward.length;i++){
					if(_reward[i][1]!=0){
						arr.push(_reward[i]);
					}
				}
				this.rewardList.array=arr;
				this.rewardList.repeatX=arr.length;
				this.boxReeward.x=(this.conditionBox.width-this.boxReeward.width)/2;
			}else{
				this.boxReeward.visible=false;
			}
		}

		public function conditionBoxLayout(arr:Array,m1:Number,m2:Number):void{
			var n:Number=0;
			arr[0].y=m2;
			n=arr[0].height+arr[0].y;
			for(var i:int=1;i<arr.length;i++){
				arr[i].y=n+m1;
				n=arr[i].height+arr[i].y;
			}
		}


		public function listRender(cell:Box,index:int):void{
			var _com:ComPayType=cell.getChildByName("reward0") as ComPayType;
			_com.setData(AssetsManager.getAssetItemOrPayByID(this.rewardList.array[index][0]),this.rewardList.array[index][1]+"");
		}

		
		public function getClick():void{
			NetSocket.instance.send("get_guild_depot_reward",{},new Handler(this,function(np:NetPackage):void{
				ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
				ModelManager.instance.modelUser.updateData(np.receiveData);
				ModelManager.instance.modelGuild.depot_reward=np.receiveData.guild.depot_reward;
				btnGet.visible=false;
				setTimerLabel();
			}));
		}

		public function setTimerLabel():void{
			var t:String=Tools.getTimeStyle(Tools.getSeasonTimes(ConfigServer.guild.configure.reserve));
			this.timerLabel.text=this.btnGet.visible?"":Tools.getMsgById("_guild_text33",[t]);// Tools.getTimeStyle(Tools.getSeasonTimes(ConfigServer.guild.configure.reserve))+"后可领取";
		}


		override public function onRemoved():void{
			
		}



	}

}