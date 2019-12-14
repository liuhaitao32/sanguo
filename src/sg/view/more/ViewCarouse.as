package sg.view.more
{
	import sg.view.com.ItemBase;
	import laya.html.dom.HTMLDivElement;
	import ui.com.item_carouseUI;
	import laya.utils.Tween;
	import sg.utils.Tools;
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;

	/**
	 * ...
	 * @author
	 */
	public class ViewCarouse extends ItemBase{

		private var label_arr:Array;
		private var index_content:int;
		private var tween_label_arr:Array;
		private var _time:Array;
		private var _content:Array;
		private var item:item_carouseUI;
		private var is_next_one:Boolean=false;
		private var next_count:Number=0;
		private var out_count:Number=0;

		public function ViewCarouse(){
			
		}


		public function input(data:Object):void{
			try{
				clerMyTimer();
				_time=data.interval_time ? data.interval_time : [10,20];
				_content = data.content;

				label_arr=[];
				item=new item_carouseUI();
				item.name="carouse";
				this.addChild(item);		
				item.panel.removeChildren();
				for(var i:int=0;i<_content.length;i++){
					createLabel();
					var html:HTMLDivElement=label_arr[i] as HTMLDivElement;
					item.panel.addChild(html);
					html.innerHTML=_content[i];
					html.x=item.panel.width;
					html.y=(item.panel.height-html.contextHeight)/2 +2;
				}
				item.left=86;
				item.top=80;

				next_count=out_count=0;
				tween_label_arr=[0];
				tweenLabel();
			}catch(e){
				// trace("try catch",e);
				this.visible = false;
			}
		}


		public function tweenLabel():void{
			for(var i:int=0;i<tween_label_arr.length;i++){
				var index_label:int=tween_label_arr[i];
				label_arr[index_label].x-=1;
				var _x:Number=label_arr[index_label].x;
				var _width:Number=label_arr[index_label].width;
				if(_x + _width <= item.panel.width && !is_next_one){
					is_next_one=true;
					labelChange(index_label,1);
				}
				if(_x + _width <= 0){
					is_next_one=false;
					labelChange(index_label,2);	
				}
			}
			timer.frameOnce(1,this,tweenLabel);
		}

		public function labelChange(index:int,type:int):void{
			if(type==1){
				next_count+=1;
				if(next_count==_content.length){
					return;
				}
				// trace("下一条");
				var n:Number=label_arr[index+1]==null ? 0 : index+1;
				timer.once(_time[0]*1000,this,fun1,[n]);
			}else if(type==2){
				out_count+=1;
				if(out_count==_content.length){
					// trace("下一轮");
					out_count=next_count=0;
					timer.clear(this,tweenLabel);
					for(var i:int=0;i<_content.length;i++){
						label_arr[i].innerHTML=_content[i];
						label_arr[i].x=item.panel.width;
					}
					this.visible=false;
					timer.once(_time[1]*1000,this,fun2);
				}

				var ddd:HTMLDivElement=label_arr[index];
				if(ddd!=null){
					ddd.x=item.panel.width;
				}
				if(tween_label_arr.indexOf(index)!=-1){
					tween_label_arr.splice(tween_label_arr.indexOf(index),1);	
				}
			}
		}

		public function fun1(n:Number):void{
			if(tween_label_arr.indexOf(n)==-1){
				tween_label_arr.push(n);
			}
		}

		public function fun2():void{
			this.visible=true;
			tween_label_arr=[0];
			tweenLabel();
		}

		public function createLabel():void{
			var txt:HTMLDivElement=new HTMLDivElement();
			txt.style.color = "#FFFFFF";
			txt.style.align = "left";
			txt.style.valign = "center";
			txt.style.fontSize = 18;
			txt.style.leading = 6;
			txt.style.wordWrap = false;
			label_arr.push(txt);
		}

		public function clerMyTimer():void{
			timer.clear(this,tweenLabel);
			timer.clear(this,fun1);
			timer.clear(this,fun2);
		}

	}

}