package sg.view.map
{
	import ui.map.visitFinishUI;
	import laya.ui.ProgressBar;
	import sg.manager.EffectManager;
	import laya.ui.Image;
	import laya.utils.Tween;
	import laya.utils.Handler;
	import sg.model.ModelHero;
	import sg.manager.ModelManager;
	import sg.cfg.ConfigServer;
	import sg.utils.Tools;
	import sg.manager.ViewManager;
	import laya.events.Event;
	import sg.model.ModelItem;
	import sg.model.ModelCityBuild;
	import sg.manager.AssetsManager;
	import ui.bag.bagItemUI;

	/**
	 * ...
	 * @author
	 */
	public class ViewVisitFinish extends visitFinishUI{

		private var config_visit:Object;
		private var pro_arr:Array=[];
		private var img_arr:Array=[];
		private var get_num:Number=0;
		private var hid:String="";
		private var my_hid:String="";
		private var grade_index:Number=0;
		private var pro_num:Number=0;
		private var gift_dict:Object={};
		private var tween:Tween;
		public function ViewVisitFinish(){
			this.pro_arr=[this.pro0,this.pro1,this.pro2,this.pro3,this.pro4,this.pro5];
			this.img_arr=[this.img0,this.img1,this.img2,this.img3,this.img4];
			this.btn.on(Event.CLICK,this,this.btnClick);
			this.btn.label=Tools.getMsgById("_lht10");
			this.comTitle.setViewTitle(Tools.getMsgById("_visit_text06"));
			this.text0.text=Tools.getMsgById("_public210");

			this.list.renderHandler=new Handler(this,listRender);
		}

		public override function onAdded():void{
			config_visit=ConfigServer.visit;
			get_num=this.currArg?this.currArg.get_num:4;
			hid=this.currArg?this.currArg.hid:"hero701";
			my_hid=this.currArg?this.currArg.my_hid:"hero702";
			gift_dict=this.currArg?this.currArg.gift_dict:{"item701":get_num};
			for(var i:int=0;i<pro_arr.length;i++){
				var p:ProgressBar=pro_arr[i];
				p.value=0;
				EffectManager.changeSprColor(p.bar,i);
				var img:Image=img_arr[i];
				if(img){
					EffectManager.changeSprColor(img,i+1);
				}
			}
			//this.bg.skin="";//背景图
			this.imgBG.skin=AssetsManager.getAssetsAD(ConfigServer.visit.background);
			this.comBig.setHeroIcon(hid,false);
			this.btn.mouseEnabled=false;
			getVisitGrade();
			setTween(0);
			this.label.text=Tools.getMsgById(config_visit.visit_grade[grade_index][2]);
			//for(var s:String in gift_dict){
				//var item:ModelItem=ModelManager.instance.modelProp.getItemProp(s);
				//this.comHero.setData(item.id,gift_dict[s],-1);
				//break;
			//}
			var arr:Array=ModelManager.instance.modelProp.getRewardProp(gift_dict);
			this.list.repeatX=arr.length > 5 ? 5 : arr.length;
			this.list.array=arr;
			this.list.centerX=0;
		}

		private function listRender(cell:bagItemUI,index:int):void{
			cell.setData(this.list.array[index][0],this.list.array[index][1],-1);
		}

		public function setTween(index:int):void{
			if(pro_num<=0){
				this.btn.mouseEnabled=true;
				return;
			}
			if(index>=pro_arr.length){
				this.btn.mouseEnabled=true;
				return;
			}
			var max:Number=20;
			var n:Number=pro_num;
			var pro_value:Number=Math.floor(n/max)>1?1:Math.floor(n/max);
			var p:ProgressBar=pro_arr[index];
			if(p){
				tween = Tween.to(p,{value:pro_value},200,null,new Handler(this,function():void{				
					pro_num-=max;
					setTween(index+1);
				}),0,false,false);
			}
			
		}

		public function getVisitGrade():void{
			var n:Number=config_visit.base_score;
			var hmd:ModelHero=ModelManager.instance.modelGame.getModelHero(my_hid);
			var b:Boolean=hmd.isMyFate(hid);
			if(b){
				n+=config_visit.fate_score;
			}
			var hmd2:ModelHero=ModelManager.instance.modelGame.getModelHero(hid);
			var arr:Array=hmd2.getTopDimensional();
			var num_a:Number=arr[1];
			var num_b:Number=hmd.getOneDimensional(arr[2]);
			var num_c:Number=Math.floor((num_b/num_a)*config_visit.proportion);
			n+=num_c;

			var len:Number=config_visit.visit_grade.length;
			for(var i:int=len-1;i>=0;i--){
				var nn:Number=config_visit.visit_grade[i][0];
				if(n>=nn){
					grade_index=i;
					break;
				}
			}
			pro_num=n;
		}


		public function btnClick():void{
			ViewManager.instance.showRewardPanel(gift_dict);
			this.closeSelf();
		}

		public override function onRemoved():void{
			if(tween){
				tween.clear();
			}
		}
	}

}