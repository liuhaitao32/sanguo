package sg.view.effect
{
	import ui.com.effect_credit_resultUI;
	import laya.utils.Tween;
	import laya.utils.Handler;
	import sg.utils.Tools;
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;

	/**
	 * ...
	 * @author
	 */
	public class CreditResult extends effect_credit_resultUI{
		public function CreditResult(data:Object){
			setData(data);
		}

		private function setData(data:Object):void{
			this.mouseEnabled=false;
			

			var n0:Number=data.num0+1;
			var n1:Number=data.num1+1;
			//this.num0.text=n0+"";
			this.num0.text=n0==n1 ? n0+"" : (n1-1)+"";
			this.num1.text=n0==n1 ? (n0+1)+"" : n1+"";
			
			this.img0.visible=n0==n1;
			this.img1.visible=n0!=n1;
			this.textLabel.text=n0==n1 ? Tools.getMsgById("_effect2") : Tools.getMsgById("_effect3");//"未达到进阶要求,维持原阶" : "战功等级升级";
			var n:Number=480;
			var cfg:Object=ModelManager.instance.modelUser.isMerge ? ConfigServer.credit['merge_'+ModelManager.instance.modelUser.mergeNum] : ConfigServer.credit;
			var max:Number=cfg.clv_up[data.num1];
			if(data.num0==data.num1){
				n*=(data.credit_num/max);
			}
			Tween.to(this.pro,{width:n},1000,null,new Handler(this,function():void{
				mouseEnabled=true;
			}));
		}

		 public static function getCreditResult(data:Object):CreditResult{
            var eff:CreditResult = new CreditResult(data);
            return eff;
        }
	}

}