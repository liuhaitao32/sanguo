package sg.view.country
{
	import sg.outline.view.OutlineCity;
	import ui.country.country_store_main_newUI;
	import sg.outline.view.OutlineViewMain;
	import laya.events.Event;
	import sg.model.ModelOfficial;
	import sg.manager.ModelManager;
	import ui.country.item_country_stroe_newUI;
	import laya.utils.Handler;
	import sg.utils.Tools;
	import sg.manager.AssetsManager;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.ui.Label;

	/**
	 * ...
	 * @author
	 */
	public class CountryStoreMainNew extends country_store_main_newUI{
		
		private var _outline:OutlineViewMain;
		private var mMaxArr:Array=[];
		public function CountryStoreMainNew(){
			this.on(Event.REMOVED,this,this.onRemove);
            ModelManager.instance.modelOfficel.on(ModelOfficial.EVENT_UPDATE_COUNTRY_DATA,this,this.event_update_country_data);
            //
            this.list.itemRender = item_country_stroe_newUI;
            this.list.renderHandler = new Handler(this,this.list_render);
            //this.list.scrollBar.hide = true;
            //
			this._outline = new OutlineViewMain(this,false);			
			this.scene_container.addChild(this._outline);
            this.scene_container.scale(0.45,0.38);
            this.scene_container.mouseEnabled = false;
            this.scene_container.mouseThrough = false;
			this.rect_img.visible = false;
            this._outline.tMap.moveViewPort(0, 0);
			for (var i:int = 0, len:int = this._outline.citySprite.numChildren; i < len; i++) {
				var city:OutlineCity = this._outline.citySprite.getChildAt(i) as OutlineCity;
				if (city && city.info) city.info.visible = false;
			}
			this._outline.fireCotnent.visible = false;
            this.init();
		}

		private function init():void
        {
            var len:int = 3;
            var arr:Array = [];
			mMaxArr=[];
			var max_arr:Array=[];
            for(var i:int = 0;i < len;i++){
				var n1:Number=ModelOfficial.getMyCities(i,[4]).length;
				var n2:Number=ModelOfficial.getMyCities(i,[3]).length;
				var n3:Number=ModelOfficial.getMyCities(i,[2]).length;
				var n4:Number=ModelOfficial.getMyCities(i,[1]).length;
				var n5:Number=ModelOfficial.getMyCities(i,[0]).length;

                arr.push({num:ModelOfficial.getMyCities(i).length,
				         ct5:n5,
						 ct4:n4,
						 ct3:n3,
						 ct2:n2,
						 ct1:n1,	 
						 country:i});
				max_arr.push([n1,n2,n3,n4,n5]);
            }
            //arr.sort(MathUtil.sortByKey("num",true));

			getMax(max_arr,0,[0,0,0]);
            this.list.array = arr;
        }

		private function getMax(arr:Array,index:int,max:Array):void{
			if(arr[0][index]==null){
				return;
			}
			var a:Array=[];
			for(var k:int=0;k<max.length;k++){
				if(max[k]==0){
					a.push(arr[k][index]);
				}else{
					a.push(-1);
				}
			}
			var n:Number=-1;
			for(var i:int=0;i<a.length;i++){
				if(a[i]>n){
					n=a[i];
				}
			}
			var m:Number=0;
			for(var j:int=0;j<a.length;j++){
				if(a[j]==n){
					a[j]=0;
					m+=1;
				}else{
					a[j]=-1;
				}
			}
			mMaxArr=a;
			getMax(arr,index+1,a);
			if(m==1){
				return;
			}
		}

		private function event_update_country_data():void{
			this.init();
		}



		private function list_render(item:item_country_stroe_newUI,index:int):void
        {
			var data:Object=this.list.array[index];
            item.imgFlag.skin=AssetsManager.getAssetsUI("icon_country"+(1+index)+".png");
			for(var i:int=0;i<5;i++){
				var box:Box=item["box"+i];
				var label:Label=box.getChildByName("label") as Label;
				label.text=Tools.getMsgById("cityType"+(4-i))+"："+data["ct"+(i+1)];				
			}
			item.bestBox.visible=(mMaxArr[index]==0);
        }

		private function onRemove():void{
            ModelManager.instance.modelOfficel.off(ModelOfficial.EVENT_UPDATE_COUNTRY_DATA,this,this.event_update_country_data);
            this.click_closeScenes();
            this.list.destroy(true);
            this.destroyChildren();
            this.destroy(true);
        }

		 public function click_closeScenes():void
        {
            Tools.destroy(this._outline);
        }
	}

}