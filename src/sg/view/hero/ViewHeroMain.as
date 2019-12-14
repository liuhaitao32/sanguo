package sg.view.hero
{
	import laya.ui.Button;
	import ui.hero.heroMainUI;
	import laya.ui.Box;
	import laya.utils.Handler;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import sg.manager.ModelManager;
	import laya.maths.MathUtil;
	import sg.model.ModelHero;
	import sg.net.NetSocket;
	import sg.net.NetMethodCfg;
	import sg.net.NetPackage;
	import sg.utils.Tools;
	import laya.utils.Byte;
	import laya.events.Event;
	import laya.ui.CheckBox;
	import sg.model.ModelGame;
	import sg.boundFor.GotoManager;
	import sg.model.ModelAlert;
	import sg.cfg.ConfigServer;
	import sg.utils.SaveLocal;
	import sg.guide.model.ModelGuide;
	import sg.model.ModelUser;
	import sg.utils.ObjectUtil;

	/**
	 * ...
	 * @author
	 */
	public class ViewHeroMain extends heroMainUI{
		private var mHeroArr_no:Array;
		private var mHeroArr_ok:Array;
		private var mHeroArr_ready:Array;
		private var mHeroArr:Array;
		private var mSelectTabIndex:int = -1;
		private var mIsMe:Boolean = false;
		private var mHid:String="";
		private var mLocalArr:Array;
		public function ViewHeroMain(){
			//
			this.tab.selectHandler = new Handler(this,this.tab_select);
			//
			//
			this.list.itemRender = ItemHero;
			this.list.scrollBar.hide = true;
			this.list.spaceX = 17;			
			//
			//this.c0.clickHandler = new Handler(this,this.click_checkBox,[3]);
			//this.c1.clickHandler = new Handler(this,this.click_checkBox,[2]);
			//this.c2.clickHandler = new Handler(this,this.click_checkBox,[1]);
			//this.c3.clickHandler = new Handler(this,this.click_checkBox,[0]);
			//
			this.btnC0.on(Event.CLICK, this, this.click_cb, [0]);
			this.btnC1.on(Event.CLICK, this, this.click_cb, [1]);
			this.btnC2.on(Event.CLICK, this, this.click_cb, [2]);
			this.btnC3.on(Event.CLICK, this, this.click_cb, [3]);
			this.btnC4.on(Event.CLICK, this, this.click_cb, [4]);
			//
			this.btn_pub.on(Event.CLICK, this, this.click_pub);
			this.btnC0.label = Tools.getMsgById("90002");
			this.btnC1.label = Tools.getMsgById("90003");
			this.btnC2.label = Tools.getMsgById("90004");
			this.btnC3.label = Tools.getMsgById("90005");
			this.btnC4.label = Tools.getMsgById("90103");
		}
		private function click_pub():void{
			if(this.btn_pub.gray){
				return;
			}
			GotoManager.boundForPanel(GotoManager.VIEW_PUB,"",null,{child:true});
		}
		private function click_cb(index:int):void{
			var btn:Button = this['btnC' + index] as Button;
			if(btn)
				btn.selected = !btn.selected;
			this.click_checkBox(index);
		}

		private function checkHeroStatus():void{
			//
			var o:Object = SaveLocal.getValue(SaveLocal.KEY_NEW_HERO+ModelManager.instance.modelUser.mUID,true);
			mLocalArr=o?o["heros"]:[];
			
			var heroNums:Array = ModelHero.getHeroNum();
			//
			this.mHeroArr_ok = [];
			this.mHeroArr_ready = [];
			this.mHeroArr_no = [];
			this.mHeroArr = [];
			var hero:ModelHero;
			for(var key:String in ConfigServer.hero)
			{
				hero = ModelManager.instance.modelGame.getModelHero(key);
				
				// trace(hero["sortLvStar"])
				if(!hero.isOpenState){
					continue;
				}
				if(!this.checkBox(hero.rarity)){
					continue;
				}
				if(hero.isMine()){
					hero["sortPower"] = hero.getPower(hero.getPrepare());
					this.mHeroArr_ok.push(hero);
				}
				else{
					if(hero.isReadyGetMine()){
						this.mHeroArr_ready.push(hero);
					}
					else{
						this.mHeroArr_no.push(hero);
					}
				}
			}
			
			this.mHeroArr_ready.sort(MathUtil.sortByKey("index"));
			this.mHeroArr_no.sort(MathUtil.sortByKey("index"));
			this.mHeroArr_ok.sort(MathUtil.sortByKey("sortPower",true));
			//
			this.mHeroArr = this.mHeroArr_ready.concat(this.mHeroArr_ok);
			this.tab.labels = Tools.getMsgById(90000,[this.mHeroArr_ok.length])+","+Tools.getMsgById(90001,[this.mHeroArr_no.length]);
		}
		override public function initData():void{


			this.setTitle(Tools.getMsgById("_hero1"));//英雄
			//
			ModelGame.unlock(this.btn_pub,"pub_gethero");
			//			
			this.list.renderHandler = new Handler(this,this.list_render);

			//
			this.list.height = this.height - 50 - 35-this.list.y;
			//
			this.checkHeroStatus();
			//
			this.tab.selectedIndex = (this.mSelectTabIndex<0)?0:this.mSelectTabIndex;
			//
		}
		override public function onAdded():void{
			this.redCheck();
			this.mIsMe = true;
			var user:ModelUser = ModelManager.instance.modelUser;
			if (!user.beast || ObjectUtil.keys(user.beast).length === 0) {
				ModelGame.unlock(null, 'beast').stop === false && user.mergeNum === 2 && mHeroArr_ready.length === 0 && ModelGuide.executeGuide('animal_guide');
			}
		}
		private function redCheck():void
		{
			ModelGame.redCheckOnce(this.tab.items[0],ModelAlert.red_hero_once(1));
		}
		override public function onRemoved():void{
			this.list.renderHandler.clear();
			var len:int = this.list.content.numChildren;
			for(var i:int = 0; i < len; i++)
			{
				(this.list.content.getChildAt(i) as ItemHero).clear();
			}
			//
			this.tab.selectedIndex = -1;
			//
			this.mHeroArr_ok = null;
			this.mHeroArr_ready = null;
			this.mHeroArr_no = null;
			this.mHeroArr = null;		
			this.mIsMe = false;	
		}
		private function click_checkBox(index:int):void{
			this.checkHeroStatus();
			this.tab_select(this.tab.selectedIndex);
		}
		private function checkBox(rarity:int):Boolean{
			var a:String = this.btnC0.selected?"1":"0";
			var b:String = this.btnC1.selected?"1":"0";
			var c:String = this.btnC2.selected?"1":"0";
			var d:String = this.btnC3.selected?"1":"0";
			var e:String = this.btnC4.selected?"1":"0";
			var i:int = parseInt("1"+e+d+c+b+a);
			//var i:int = parseInt("1"+a+b+c+d+e);
			if(i==100000){
				i = 111111;
			}
			//this.btnC0.selected = this.c0.selected;
			//this.btnC1.selected = this.c1.selected;
			//this.btnC2.selected = this.c2.selected;
			//this.btnC3.selected = this.c3.selected;

			var t:int = Math.floor(i/Math.pow(10,rarity));
			return ((t&1) == 1);
		}
		private function list_render(hero:ItemHero,index:int):void{
			var hmd:ModelHero=this.list.array[index] as ModelHero;
			hero.checkUI(this.tab.selectedIndex,hmd);
			hero.imgNew.visible=mLocalArr.indexOf(hmd.id)!=-1;
			hero.off(Event.CLICK,this,this.click);
			hero.on(Event.CLICK,this,this.click,[index]);
			hero.heroIcon.setHeroIcon(hmd.id);
		}
		private function click(index:int):void{
			if(!this.mIsMe)return;
			var md:ModelHero = this.list.array[index] as ModelHero;
			mHid=md.id;
			if(md.isReadyGetMine()){
				
				NetSocket.instance.send(NetMethodCfg.WS_SR_RECRUIT_HERO,{hid:md.id},Handler.create(this,this.ws_sr_recruit_hero));
			}
			else{
				SaveLocal.deleteArr(SaveLocal.KEY_NEW_HERO+ModelManager.instance.modelUser.mUID,"heros",mHid,true);
				var arr:Array = [];

				if(this.tab.selectedIndex == 0){
					arr = arr.concat(this.mHeroArr);
					arr = arr.concat(this.mHeroArr_no);					
				}
				else{
					arr = arr.concat(this.mHeroArr_no);
					arr = arr.concat(this.mHeroArr);
				}
				this.list.scrollBar.stopScroll();
				md.skillSelectIndexDic = 0;
				//
				GotoManager.boundForPanel(GotoManager.VIEW_HERO_FEATURES,"",[md,arr,index],{type:2,child:true});
			}
		}
		private function tab_select(index:int):void{
			//
			if(index>-1){
				this.mSelectTabIndex = index;
				if(index==1){
					this.list.array = this.mHeroArr_no;
				}
				else if(index==0){
					this.list.array = this.mHeroArr;
				}
			}
		}

		private function ws_sr_recruit_hero(re:NetPackage):void{
			ModelManager.instance.modelUser.recruit_hero_cb(re);
			//
			this.checkHeroStatus();
			this.tab_select(this.tab.selectedIndex);
			this.redCheck();
		}
	}

}
