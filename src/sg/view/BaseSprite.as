package sg.view
{
    import laya.ui.Dialog;
    import laya.display.Node;
    import laya.utils.Tween;
    import laya.ui.View;
    import laya.display.Animation;
    import sg.manager.EffectManager;
    import laya.utils.Handler;
    import laya.maths.Rectangle;
    import laya.ui.Box;
    import laya.utils.Ease;

    public class BaseSprite extends View
    {
        private var test_clip_max_parent:Node;
		private var test_clip_num_max:Number = 0;
		public var test_clip_vis:Boolean = true;
		public var test_clip_max:Number = 0;
		private var mAni:Animation;
		public var mRect:Rectangle;
		private static var test_clip_de:Number = 1;
        public function BaseSprite()
        {
            
        }
		public function test_clip_effict_panel(xx:Number,yy:Number):void{
			this.mAni = EffectManager.loadAnimation("glow030","",1);
			this.mAni.x = xx;
			this.mAni.y = yy;
			this.addChild(this.mAni);
		}
		public function clear_clip_effict_panel(xx:Number,yy:Number):void{
			if(this.mAni){
				this.mAni.removeSelf();
				this.mAni.destroy(true);
			}
			this.mAni = null;
		}		
        public function test_clip_int(type:int):void{
			if(!test_clip_vis)return;
			this.test_clip_num_max = 0;
			// this.test_clip_max = 10;
			// var len:int = 0;
			// var i:int = 0;
			// var c1:Boolean = false;
			if(type == 1){
				this.test_clip_max_parent = null;
				//
				this.test_clip_int_f1(this);
				//		
			}
			else{
				// c1 = true;
				// this.test_clip_max_parent = this;
				if(this.parent){
					// test_clip_de*=-1;
					this.parent["x"] = -50*test_clip_de;
					Tween.to(this.parent,{x:0},100);//Ease.backOut
					// this.hitArea = this.mRect;
				}
			}
			// if(this.test_clip_max_parent){
			// 	len = this.test_clip_max_parent.numChildren;
			// 	//
			// 	for(i=0; i < len; i++)
			// 	{
			// 		// if(i<=this.test_clip_max){
			// 			this.test_clip_check(this.test_clip_max_parent.getChildAt(i),i,c1);
			// 		// }
			// 	}
			// }
			// this.test_clip_max_parent = null;				
			//实验用的动画 len;
		}
		//
		private function test_clip_int_f1(cp:Node):void{
			//
			var ch:Box;
			var i:int = 0;
			
			if(cp.numChildren>this.test_clip_num_max){
				this.test_clip_max_parent = cp;
				this.test_clip_num_max = cp.numChildren;
			}
			
			for(i=0; i < cp.numChildren; i++)
			{
				ch = cp.getChildAt(i) as Box;
				if(ch.name !="_$_bg_mask_$_"){
					ch.anchorX = 0.5;
					ch.anchorY = 0.5;
					ch.scaleX = 0.95;
					ch.scaleY = 0.95;
					Tween.to(ch,{scaleX:1,scaleY:1},100,Ease.backOut);
				}
				// if(ch.numChildren > this.test_clip_num_max){
				// 	this.test_clip_int_f1(ch);
				// }
			}
		}
		// private function test_clip_check(sp:Node,index:int,cs:Boolean = false):void{
		// 	if(sp["alpha"]){
		// 		if(sp["alpha"]>=1){
		// 			// if(sp["myBaseY"])
		// 			if(index!=0){
		// 				sp["alpha"] = 0;
		// 				Tween.to(sp,{alpha:1},70,null,null,index<=0?-1*index:((index+1)*30));
		// 			}
		// 		}
		// 		if(cs){
		// 			if(sp.numChildren>1){
		// 				for(var i:int = 0; i < sp.numChildren; i++)
		// 				{
		// 					this.test_clip_check(sp.getChildAt(i),-(i+index+1)*30);
		// 				}
		// 			}
		// 		}
		// 	}
		// }
    }
}