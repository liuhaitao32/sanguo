package sg.view.init
{	
	import laya.events.Event;
	import sg.manager.ViewManager;
	import sg.utils.Tools;
	import laya.utils.Handler;
	import ui.map.eventTalk1UI;
	import sg.model.ModelHero;
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;
	import laya.maths.MathUtil;

	/**
	 * ...
	 * @author
	 */
	public class ViewHeroTalk extends eventTalk1UI{

		private var talk_list:Array=[];//[["英雄id","名字","内容"],[]...]
		private var click_count:Number=0;
		private var fun:*=null;
		public function ViewHeroTalk(){
			this.btn.on(Event.CLICK,this,this.btnClick);	
		}

		public override function onAdded():void{
			ViewManager.instance.on(ViewManager.EVENT_CLOSE_HERO_TALK,this,eventCallBack);
			click_count=0;
			talk_list=this.currArg[0];
			fun=this.currArg[1];
			if(!talk_list){
				// trace("heroTalk 对话内容为空！！！");
				ViewManager.instance.closePanel(this);
				return;
			}
			setData();
		}

		private function eventCallBack():void{
			this.closeSelf();
		}

		public function setData():void{
			if(click_count==talk_list.length){
				ViewManager.instance.closePanel(this);
				return;
			}
			var arr:Array = talk_list[click_count];
			var hid:String = arr[0];
			if (!isNaN(parseInt(hid))) { // 引导中用到的逻辑
				var mHeroArr_ok:Array = []
				var hero:ModelHero;
				for(var key:String in ConfigServer.hero) {
					hero = ModelManager.instance.modelGame.getModelHero(key);
					if(hero.isOpenState && hero.isMine()){
						hero["sortPower"] = hero.getPower(hero.getPrepare());
						mHeroArr_ok.push(hero);
					}
				}
				mHeroArr_ok.sort(MathUtil.sortByKey("sortPower",true));
				hero = mHeroArr_ok[hid] || mHeroArr_ok[0];
				if (hero) {
					arr[0] = hid = hero.id;
					arr[1] = hero.name;
					arr[3] = [Tools.getMsgById(hero.name)]
				}
			}

			var replace:Array = arr[3] ? arr[3] : null;
			//trace(hid,arr[1],arr[2]);
			this.titleLabel.text="";//Tools.getMsgById(arr[1]);
			this.infoLabel.text="";//Tools.getMsgById(arr[2]);
			
			this.htmlLabel0.style.fontSize=this.titleLabel.fontSize;
			this.htmlLabel0.style.color=this.titleLabel.color;
			this.htmlLabel0.innerHTML=(arr[1] == "1" || Tools.getMsgById(arr[1])=="1") ? ModelHero.getHeroName(hid) : Tools.getMsgById(arr[1]);

			this.htmlLabel1.style.fontSize=this.infoLabel.fontSize;
			this.htmlLabel1.style.color = this.infoLabel.color;
			this.htmlLabel1.style.leading = 6;
			this.htmlLabel1.innerHTML=Tools.getMsgById(arr[2],replace);

			
			this.comHero.setHeroIcon(hid,true,-1,true,true);
			this.comHero.left=this.comHero.right=NaN;
			if(click_count%2==0){
				this.comHero.left=50;
			//	this.comHero.scaleX=1;
			}else{
				this.comHero.right=50;//246;
				//this.comHero.scaleX=-1;
			}
		}


		public function btnClick():void{
			click_count+=1;
			setData();
		}

		public override function onRemoved():void{
			ViewManager.instance.off(ViewManager.EVENT_CLOSE_HERO_TALK,this,eventCallBack);
			if(this.fun){
				if(this.fun is Handler){
					(this.fun as Handler).runWith(null);
				}
				else{
					var handler:Handler = Handler.create(this,this.fun);
					handler && handler.run();
				}
			}
		}
	}

}