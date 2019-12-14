package sg.view.hero
{
    import ui.hero.heroRuneSetUI;
    import sg.model.ModelHero;
    import sg.manager.ModelManager;
    import sg.cfg.ConfigServer;
    import laya.utils.Handler;
    import laya.events.Event;
    import sg.model.ModelRune;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import sg.net.NetPackage;
    import laya.maths.MathUtil;
	import sg.utils.StringUtil;
	import sg.utils.Tools;
	import sg.map.utils.ArrayUtils;

    public class ViewHeroRuneSet extends heroRuneSetUI{
        private var mModel:ModelHero;
        private var mType:int = -1;
        private var mSelectType:int = -1;
        private var mSelectRuneModel:ModelRune;
        private var mOutOff:Boolean = false;
        public function ViewHeroRuneSet():void{
            this.list.itemRender = ItemHeroRune;
            this.list.scrollBar.visible=false;
            this.list.renderHandler = new Handler(this,this.list_render);
            this.list.selectHandler  = new Handler(this,this.list_select);   
            this.list.selectEnable = true;         
            this.btn_set.on(Event.CLICK, this, this.click);
			
			this.hInfo.style.fontSize = 20;
			this.hInfo.style.align = 'center';
            //tTitle.text = Tools.getMsgById('540163') + Tools.getMsgById('_equip4');
            var s:String = Tools.getMsgById('540163') + Tools.getMsgById('_equip4');
            this.comTitle.setViewTitle(s);
            tProp.text = Tools.getMsgById('540163') + Tools.getMsgById('_public1');
        }
        override public function initData():void{
            this.mModel = this.currArg[0] as ModelHero;
            var str:String = this.currArg[1];
            this.mSelectType = parseInt(str.charAt(str.length-1));
            this.mType = this.currArg[2];
        }
        override public function onAdded():void{
            var fixtype:int = ModelRune.pageAndTypeToPosValue(this.mType,this.mSelectType);
            var dtype:int = ModelRune.pageAndTypeToPosIndex(this.mType,this.mSelectType);
            //
            var arr:Array = ModelRune.getMyRunesByType(fixtype,this.mModel,dtype);
            //
            ArrayUtils.sortOn(["sortNum","sortId"],arr,true);
            //
            if(fixtype==0){
                var newArr:Array = [];
                var currRun:ModelRune = this.mModel.getRuneByIndex(dtype);
                var len:int = arr.length;
                var i:int = 0;

                if(!Tools.isNullObj(currRun))
                    newArr.push(arr[i]);
                    
                var myAll:Object = this.mModel.getRune();
                var pb:Boolean = true;
                
                for(i = 0;i < len;i++){
                    pb = true;
                    if(!Tools.isNullObj(currRun) && i!=0){
                        if(currRun.id.split("|")[0] == (arr[i] as ModelRune).id.split("|")[0]){
                            newArr.push(arr[i]);
                            continue;
                        }
                    }

                    for(var key:String in myAll){
                        if(myAll[key].split("|")[0] == (arr[i] as ModelRune).id.split("|")[0]){
                            pb = false;
                            break;
                        }
                    }

                    pb && newArr.push(arr[i]);
                }

                this.list.array = newArr;
            }
            else{
                //
                this.list.array = arr;
            }
            //
            this.list.scrollBar.value=0;
            if(this.list.array.length>0){
                if(this.list.selectedIndex<0){
                    this.list.selectedIndex = 0;
                }
            }
        }
        override public function onRemoved():void{
            this.list.selectedIndex = -1;
            // this.list.renderHandler.clear();
            // this.list.selectHandler.clear();
        }
        private function setUI(rmd:ModelRune):void{
            this.mSelectRuneModel = rmd;
            //
            this.tName.text = rmd.getName(true);
			this.tOnly.text =  this.mSelectRuneModel.getOnlyInfo();
			this.hInfo.innerHTML = StringUtil.substituteWithColor(this.mSelectRuneModel.getInfoHtml(), "#FCAA44", "#ffffff");
			
            this.tLv.text = Tools.getMsgById("_public6",[rmd.getLv()]);//等级
            var exp:Number = rmd.getExp();
            var max:Number = rmd.getLvExp(rmd.getLv() - 1);
			var maxStr:String;
			if (max > 0){
				maxStr = max + '';
				this.bar.value = exp/max;
			}
			else{
				maxStr = '---';
				this.bar.value = 1;
			}

            this.tExp.text = Tools.getMsgById("_public7",[exp+"/"+maxStr]);//经验
            //
            var hmd:ModelHero = rmd.getHeroModel();
            var b:Boolean = false;
            if(hmd){
                if(hmd.id == this.mModel.id){
                    b = true;
                }
            }
            this.mOutOff = b;
            this.btn_set.label = b?Tools.getMsgById("_equip2"):Tools.getMsgById("_equip3");//"卸载":"安装"
            //
            //this.runeIcon.runeIcon.setIcon(rmd.getImgName());
            this.runeIcon.runeIcon.setData(rmd.id,-1,-1);
            this.runeIcon.imgSelect.visible = false;
            this.runeIcon.imgCurr.visible = b;
            this.runeIcon.boxLv.visible = false;
        }
        
        private function list_render(item:ItemHeroRune,index:int):void{
            item.setData(this.list.array[index],this.mModel);
            item.setName();
            item.showSelect(this.list.selectedIndex == index);

            item.off(Event.CLICK,this,this.click_item);
            item.on(Event.CLICK,this,this.click_item,[index]);
        }
        private function list_select(index:int):void{
            if(index>-1){
                this.setUI(this.list.array[index]);
            }
        }
        private function click_item(index:int):void{
            if(index>-1 && this.list.selectedIndex!=index){
                this.list.selectedIndex = index;
            }
        }
        private function click():void{
            // ViewManager.instance.showView(ConfigClass.VIEW_HERO_RUNE_UPGRADE,[this.mModel,this.mSelectRuneModel]);
            var rmd:ModelRune = this.list.array[this.list.selectedIndex];
            var sd:Object;
            var index:int = ModelRune.pageAndTypeToPosIndex(this.mType,this.mSelectType);
            if(!this.mModel.idle){
                this.mModel.busyHint();
                return;
            }
            if(this.mOutOff){
                sd = {hid:this.mModel.id,star_id:rmd.id,position:index};
                NetSocket.instance.send(NetMethodCfg.WS_SR_HERO_STAR_UNINSTALL,sd,Handler.create(this,this.ws_sr_hero_star_uninstall));
            }
            else{
                sd = {hid:this.mModel.id,star_id:rmd.id,position:index};
                NetSocket.instance.send(NetMethodCfg.WS_SR_HERO_STAR_INSTALL,sd,Handler.create(this,this.ws_sr_hero_star_install));
            }
            
        }
        private function ws_sr_hero_star_install(re:NetPackage):void{
            ModelManager.instance.modelUser.updateData(re.receiveData);
            ModelManager.instance.modelGame.event(ModelRune.EVENT_SET_IN_OUT);
            //
            this.mModel.event(ModelHero.EVENT_HERO_RUNE_CHANGE,false);
            //
            this.closeSelf();
        }
        private function ws_sr_hero_star_uninstall(re:NetPackage):void{
            // Trace.log("ws_sr_hero_star_uninstall",re.receiveData);
            this.ws_sr_hero_star_install(re);
        }
    }   
}