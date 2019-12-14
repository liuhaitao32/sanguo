package sg.view.country
{
	import ui.country.country_mayorUI;
	import sg.utils.Tools;
	import laya.utils.Handler;
	import ui.country.item_country_mayor_newUI;
	import sg.manager.ModelManager;
	import sg.model.ModelOfficial;
	import sg.model.ModelUser;
	import sg.cfg.ConfigServer;
	import laya.maths.MathUtil;
	import sg.model.ModelCityBuild;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import laya.events.Event;

	/**
	 * ...
	 * @author
	 */
	public class ViewCountryMayor extends country_mayorUI{

        private var mSelectIndex:Number;
		public function ViewCountryMayor(){
			this.comTitle.setViewTitle(Tools.getMsgById("_country69"));
			//this.tab0.dataSource = [Tools.getMsgById("_lht20"),,,Tools.getMsgById("_country13")];
            //this.tab1.dataSource = [Tools.getMsgById("_jia0099"),Tools.getMsgById("_country17")];
			//this.tab1.selectHandler = new Handler(this,this.tab_select);
            this.btn0.label=Tools.getMsgById("_lht20");
            this.btn1.label=Tools.getMsgById("_jia0099");
            this.btn2.label=Tools.getMsgById("_country17");
            this.btn3.label=Tools.getMsgById("_country13");
            
            this.btn1.on(Event.CLICK,this,tab_select,[0]);
            this.btn2.on(Event.CLICK,this,tab_select,[1]);

			this.list.itemRender = item_country_mayor_newUI;
            this.list.renderHandler = new Handler(this,this.list_render);
            this.list.scrollBar.hide = true;
            //
            
            //
            ModelManager.instance.modelOfficel.on(ModelOfficial.EVENT_SET_MAYOR_IS_OK,this,function():void{
                tab_select(mSelectIndex);
            });

            this.text0.text=Tools.getMsgById("_country46");
            this.text1.text=Tools.getMsgById("_country47");
		}


		override public function onAdded():void{
            mSelectIndex=0;
            this.list.dataSource = [];
            tab_select(mSelectIndex);
			//this.tab1.selectedIndex = 0;
		}

		public function setData(arr:Array):void{
			this.list.dataSource = arr;
            //
            var len:int = arr.length;
            var city:Object;
            var mayor:Object;
            //
            var ok:Number = 0;
            var no:Number = 0;
            for(var i:int = 0; i < len; i++)
            {
                city = arr[i];
                mayor = ModelOfficial.getCityMayor(city.cid);
                if(Tools.isNullObj(mayor)){
                    no +=1
                }
                else{
                    ok +=1;
                }
            }
            this.info0.text = ""+ok;
            this.info1.text = ""+no;
		}


		private function tab_select(index:int):void
        {
            if(index>-1){
                mSelectIndex=index;
                this.tabs0.rotation = (index == 0)?180:0;
                this.tabs1.rotation = (index == 1)?180:0;
                var arr:Array = ModelOfficial.getMyCities(ModelUser.getCountryID(), ConfigServer.world['cityTypeCanBuild']);

                var abc:Array = arr.concat();
                var len:int = abc.length;
                var element:Object;
                for(var i:int = 0; i < len; i++)
                {
                    element = abc[i];
                    element["sortType"] = index === 0 ? ModelOfficial.getCityCfg(element.cid).cityType : ModelCityBuild.getBuildRatio(element.cid);
                }
                abc.sort(MathUtil.sortByKey("sortType",true));
                this.setData(abc);
            }
        }

		private function list_render(item:item_country_mayor_newUI,index:int):void
        {
            var data:Object = this.list.array[index];
            item.tName.text = ModelOfficial.getCityName(data.cid);
            item.tType.text =  Tools.getMsgById("cityType"+ModelOfficial.getCityCfg(data.cid).cityType);
            item.tNum.text = ModelCityBuild.getBuildRatio(data.cid);
            //
            var noStr:String = Tools.getMsgById("_public76");//无
            var mayor:Array = ModelOfficial.getCityMayor(data.cid);
            item.tMayor.text = mayor?mayor[1]:noStr;
            Tools.textFitFontSize(item.tMayor);
            //item.tTeam.text = mayor?(Tools.isNullString(mayor[2])?noStr:mayor[2]):noStr;
            //
            item.icon.visible = mayor?(Tools.isNullString(mayor[1])?false:true):false;
            //
            item.off(Event.CLICK,this,this.click);
            item.on(Event.CLICK,this,this.click,[index]);
        }
        private function click(index:int):void
        {
            if(ModelOfficial.isKing(ModelManager.instance.modelUser.mUID)>-1 || ModelOfficial.isGovernor(ModelManager.instance.modelUser.mUID)>-1){
                var data:Object = this.list.array[index];
                //cid//uid
                if(data.cid==-1 && ModelManager.instance.modelCountryPvp.checkActive()){
                    ViewManager.instance.showTipsTxt(Tools.getMsgById("_country82"));//只有国王和郡丞能分配太守    
                    return;
                }
                ViewManager.instance.showView(ConfigClass.VIEW_COUNTRY_MAYOR_LIST,[null,data]);
            }
            else{
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_country1"));//只有国王和郡丞能分配太守
            }
            
        }

		override public function onRemoved():void{

		}
	}

}