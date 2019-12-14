package sg.view.map
{
	import sg.model.ModelPrepare;
	import ui.map.heroCatchUI;
	import laya.utils.Handler;
	import laya.events.Event;
	import sg.manager.ModelManager;
	import sg.model.ModelHero;
	import sg.net.NetSocket;
	import sg.net.NetPackage;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigServer;
	import sg.utils.Tools;
	import sg.cfg.ConfigClass;
	import sg.manager.AssetsManager;
	import ui.bag.bagItemUI;
	import sg.model.ModelItem;
	import laya.maths.MathUtil;
	import sg.model.ModelUser;
	import sg.model.ModelScience;
	import sg.utils.StringUtil;
	import sg.model.ModelOffice;
	import sg.model.ModelGame;

	/**
	 * ...
	 * @author
	 */
	public class ViewHeroCatch extends heroCatchUI{

		private var userData:Object={};
		private var mData:Array=[];
		
		private var curIndex:int=0;
		private var cur_catch_times:int=0;//今日剩余
		//private var free_catch_times:int=0;//免费pk次数
		//private var total_catch_times:int=0;//总的pk次数
		private var init_catch_times:int=0;//初始次数
		private var refresh_times:int=0;
		private var total_refresh_times:int=0;//免费刷新次数
		private var isUnlock:Boolean=false;
		private var refresh_cost_arr:Array=[];//刷新花费
		private var catch_cost_arr:Array=[];//pk花费  （弃用）
		private var config_buy_count:Array=[];
		private var config_catch_hero:Array=[];

		private var total_buy_times:Number=0;//可买次数
		private var cur_buy_times:Number = 0;//已买次数
		private var powerValue:int;
		
		private var v:*;
		public function ViewHeroCatch(){
			this.list.scrollBar.visible=false;
			this.list.scrollBar.touchScrollEnable=false;
			this.list.itemRender=bagItemUI;
			this.list.renderHandler=new Handler(this,list_render);
			this.btn.on(Event.CLICK,this,this.btnClick);
			this.btnUnlock.on(Event.CLICK,this,this.unlockCLick,[false]);
			this.btnRefresh.on(Event.CLICK,this,this.refreshClick);
			this.btnAdd.on(Event.CLICK,this,this.buyClick,[0]);
			this.btnCatch.on(Event.CLICK,this,this.catchClick);

			ModelManager.instance.modelUser.on(ModelUser.EVENT_USER_UPDATE,this,function():void{
				userData=ModelManager.instance.modelUser.hero_catch;
				cur_buy_times=Tools.isNewDay(userData.buy_time)?0:userData.buy_times;
				cur_catch_times=Tools.isNewDay(userData.pk_time)?init_catch_times:userData.pk_times;
				labelCount.text=Tools.getMsgById("_hero_chatch_text04",[cur_catch_times,init_catch_times + cur_buy_times]);// "今日剩余次数："+cur_catch_times+"/"+(init_catch_times + cur_buy_times);
				this.btnCatch.gray=cur_catch_times==0;
			});
		}

		private function buyClick(type:int):void{
			if(total_buy_times-cur_buy_times>0){
				ViewManager.instance.showBuyTimes(3,1,total_buy_times-cur_buy_times,ConfigServer.system_simple.catch_buy_count[cur_buy_times]);
			}else{
				if(type==0){
					ViewManager.instance.showTipsTxt(Tools.getMsgById("_public63"));
				}else{
					ViewManager.instance.showTipsTxt(Tools.getMsgById("_pve_tips10"));//次数不足
				}
				
			}
		}

		override public function onAdded():void{
			this.comTitle.setViewTitle(Tools.getMsgById("_hero_chatch_text01"));
			//this.title.text=Tools.getMsgById("_hero_chatch_text01");
			this.text0.text=Tools.getMsgById("_hero_chatch_text07");
			this.text1.text=Tools.getMsgById("_public187");
			config_buy_count=ConfigServer.system_simple.catch_buy_count;
			config_catch_hero = ConfigServer.system_simple.catch_hero;
			total_refresh_times=config_catch_hero[6];
			init_catch_times=ConfigServer.system_simple.catch_intial_num + ModelScience.func_sum_type(ModelScience.catch_times);
			//total_catch_times=config_buy_count.length;
			//free_catch_times=0;
			/*
			for(var i:int=0;i<config_buy_count.length;i++){
				if(config_buy_count[i]==0){
					free_catch_times+=1;
				}else{
					break;
				}
			}*/
			total_buy_times=config_buy_count.length;//total_catch_times-free_catch_times;
			setData();
			setUI();
			time_tick();
			timer.loop(1000,this,time_tick);

			this.box0.visible=true;
			this.box1.centerX=146;
			if(ModelGame.unlock(null,"hero_catch_refresh").stop){
				this.box0.visible=false;
				this.box1.centerX=0;
			}
		}

		public function unlockCLick(isAlert:Boolean=false):void{
			if(!isUnlock && !isAlert){
				ViewManager.instance.showAlert(Tools.getMsgById("_hero_chatch_text06"),function(index:int):void{
					if(index==0){
						unlockCLick(true);
					}else if(index==1){

					}
				},["coin",config_catch_hero[7]],"");
				return;
			}
			var s:String=!isUnlock?"hero_catch_block":"hero_catch_unblock";
			NetSocket.instance.send(s,{"hero_index":curIndex},Handler.create(this,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				setData();
				setUI();
			}));	
		}

		public function refreshClick():void{
			if(isUnlock){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_hero_chatch_text08"));
				return;
			}
			if(!Tools.isCanBuy(refresh_cost_arr[0],refresh_cost_arr[1])){
				return;
			}
			NetSocket.instance.send("hero_catch_refresh",{"hero_index":curIndex},Handler.create(this,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				setData();
				setUI();
			}));
		}


		public function btnClick():void{
			
			ViewManager.instance.showView(ConfigClass.VIEW_HERO_INFO,mData);

		}

		public function catchClick():void{
			//if(!Tools.isCanBuy(catch_cost_arr[0],catch_cost_arr[1])){
			//	return;
			//}
			if(cur_catch_times==0){
				buyClick(1);
				return;
			}
			//NetSocket.instance.send("hero_catch_pk",{"hero_index":curIndex,"fight":0},Handler.create(this,function(np:NetPackage):void{
				var obj:Object={"index":curIndex,"v":v}
				var b:Number=ModelOffice.func_flycatch()?-2:0;
				ModelManager.instance.modelGame.checkTroopToAction(userData.hero_list[curIndex][1],["ViewCatchHeroSend",ViewCatchHeroSend],obj,true,b,-this.powerValue);
				//ModelManager.instance.modelUser.updateData(np.receiveData);
				//ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
				//ViewManager.instance.closePanel();
				//setData();
				//setUI();
			//}));
			
		}

		public function setData():void{
			
			curIndex=this.currArg[0]?this.currArg[0]:0;
			v=this.currArg[1];
			userData=ModelManager.instance.modelUser.hero_catch;
			mData=userData.hero_list[curIndex];
			isUnlock=(mData[3]==1);
			//total_catch_times=0;
			
			cur_catch_times=Tools.isNewDay(userData.pk_time)?init_catch_times:userData.pk_times;
			cur_buy_times=Tools.isNewDay(userData.buy_time)?0:userData.buy_times;
			refresh_times=Tools.isNewDay(userData.cost_refresh_time)?0:userData.cost_refresh_times;
			
			var listData:Array=ModelManager.instance.modelProp.getRewardProp(mData[2]);
			this.list.repeatX=listData.length;
			this.list.centerX=0;
			this.list.array=listData;
			
		}
		

		public function setUI():void{
			var o:Object=mData[0];
			var hmd:ModelHero=new ModelHero(true);
			hmd.setData(o);
			this.heroType.setHeroType(hmd.getType());
			this.comHero.setHeroIcon(o.hid);
			this.comStar.setHeroStar(hmd.getStar());
			//计算推荐战力
			this.powerValue = hmd.getPower(hmd.getPrepare(false, o));
			this.powerValue = ModelPrepare.getFormatPower(powerValue, ConfigServer.system_simple.catch_enemy_power);
			this.comPower.setNum(this.powerValue);
			//this.labelAtk.text = this.powerValue+"";
			this.imgRatity.skin=hmd.getRaritySkin();
			//this.imgType.setHeroType(hmd.getType());
			this.nameLabel.text=hmd.getName();
			this.btnUnlock.skin=isUnlock?"ui/btn_suo.png":"ui/btn_suo1.png";			
			this.labelInfo.text = Tools.getMsgById(hmd.info);
			this.heroLv.setNum(hmd.getLv());
			//this.labelLv.text=hmd.getLv()+"";
			//if(free_catch_times-cur_catch_times<0){
			//	this.labelCount.text="今日剩余次数："+"0/"+cur_catch_times;
			//}else{
			//	this.labelCount.text="今日剩余次数："+(free_catch_times-cur_catch_times)+"/"+free_catch_times;
			//}
			this.labelCount.text=Tools.getMsgById("_hero_chatch_text04",[cur_catch_times,init_catch_times + cur_buy_times]);// "今日剩余次数："+cur_catch_times+"/"+(init_catch_times + cur_buy_times);
			var n:Number=cur_catch_times>=config_buy_count.length-1?config_buy_count.length-1:cur_catch_times;
			//catch_cost_arr=["coin",config_buy_count[n]];
			//if(catch_cost_arr[1]==0){
				this.btnCatch.setData("",Tools.getMsgById("_hero_chatch_text02"),-1,1);
			//}else{
				//this.btnCatch.setData(AssetsManager.getAssetItemOrPayByID("coin"),config_buy_count[n]+" 切磋");
			//}
			//this.btnCatch.mouseEnabled=!(cur_catch_times>=config_buy_count.length);
			this.btnCatch.gray=cur_catch_times==0;//(cur_catch_times>=config_buy_count.length);

			var m:Number=refresh_times>=total_refresh_times?config_catch_hero[7]:0;
			refresh_cost_arr=["coin",m];
			if(m==0){
				//this.btnRefresh.setData("","免费刷新("+(total_refresh_times-refresh_times)+"/"+total_refresh_times+")",-1,1);
				this.btnRefresh.setData("",Tools.getMsgById("_shop_text05",[total_refresh_times-refresh_times,total_refresh_times]),-1,1);
			}else{
				this.btnRefresh.setData(AssetsManager.getAssetItemOrPayByID("coin"),m+" "+Tools.getMsgById("_public78"));
			}
			
			
		}

		public function time_tick():void{
			var now:Number=ConfigServer.getServerTimer();
			//var dt:Date=new Date(now);
			var m:Number=Tools.getFullHourDis();//Tools.oneHourMilli - (dt.getMinutes()*Tools.oneMinuteMilli+dt.getSeconds()*Tools.oneMilliS+dt.getMilliseconds());
			if(m>0){
				this.labelTime.text=Tools.getMsgById("_hero_chatch_text03",[Tools.getTimeStyle(m)]);// "对手刷新："+Tools.getTimeStyle(m);
			}else{
				// trace("hero catch close panel");
				//ViewManager.instance.closePanel();
				this.closeSelf();
			}
			
		}
		public function list_render(cell:bagItemUI,index:int):void{
			var it:Array=this.list.array[index];
			if(it.type==7){
				var nn:Number=ModelScience.func_sum_type("catch_apart");//科技增加固定值
				it.addNum+=nn;
			}
			//cell.setData(it.icon,it.ratity,it.name,it.addNum+"",it.type);
			cell.setData(it[0],it[1]);
			if(it.type==2){
				cell.off(Event.CLICK,this,itemClick);
				cell.on(Event.CLICK,this,itemClick,[index]);
			}
			
			
		}

		public function itemClick(index:int):void{
			var it:ModelItem=this.list.array[index];
			if(it.type==2){
				ViewManager.instance.showView(ConfigClass.VIEW_SHOP_SKILL_TIPS,it.id);
			}
		}



		override public function onRemoved():void{
			timer.clear(this,time_tick);
		}
	}

}