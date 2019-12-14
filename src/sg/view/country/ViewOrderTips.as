package sg.view.country
{
	import ui.country.order_tipsUI;
	import sg.cfg.ConfigServer;
	import sg.manager.AssetsManager;
	import sg.utils.Tools;
	import sg.model.ModelOfficial;
	import sg.task.model.ModelTaskCountry;
	import sg.model.ModelFightTask;

	/**
	 * ...
	 * @author
	 */
	public class ViewOrderTips extends order_tipsUI{

		private var mKey:String;
		private var mN1:Number;
		private var mN2:Number;
		public function ViewOrderTips(){
			
		}

		override public function onAdded():void{
			mKey=this.currArg;
			tInfo.style.wordWrap=true;
			tInfo.style.fontSize=20;
			tInfo.style.color="#c8daff";
			tInfo.style.leading=6;

			if(mKey == "task_buff"){
				img.skin        = AssetsManager.getAssetsUI("icon_duilie14_6.png");
				var a:Array     = ModelFightTask.instance.buff;
				mN1 = a[2] + ConfigServer.getServerTimer();
				tTitle.text     = Tools.getMsgById("fight_task11",[""]);
				var s1:String   = Math.round(a[0]*100)+"%";
				var s2:String   = Math.round(a[1]*100)+"%";
				tInfo.innerHTML = Tools.getMsgById("fight_task12",[s1,s1,s2]);
			}else{
				var obj:Object  = ConfigServer.country[mKey];
				img.skin        = AssetsManager.getAssetsUI(obj.buff_icon);
				tTitle.text     = Tools.getMsgById(obj.name);
				tInfo.innerHTML = Tools.getMsgById(obj.info);

				var arr:Array   = ModelOfficial.get_country_order_data(mKey);
				mN1 = arr ? Tools.getTimeStamp(arr[2]) : 0;
				mN2 = ConfigServer.country[mKey].time*Tools.oneMinuteMilli;
			}
			
			setTimeLabel();
			this.tTime.x = this.tTitle.x + this.tTitle.width + 4;
		}

		private function setTimeLabel():void{
			var now:Number=ConfigServer.getServerTimer();
            var n3:Number=0;
			if(mKey == "task_buff"){
				n3 = mN1 - now;
			}else{
				n3 = mN1==0 ? 0 : mN2 - (now - mN1);
			}
            var time:Number = n3<=0 ? 0 : Math.ceil(n3/Tools.oneMinuteMilli);
			if(time==0){
				this.closeSelf();
			}
			this.tTime.text = Tools.getMsgById("501023",[time]);
			Laya.timer.once(1000,this,setTimeLabel);
		}
		

		override public function onRemoved():void{
			Laya.timer.clear(this,setTimeLabel);
		}
	}

}