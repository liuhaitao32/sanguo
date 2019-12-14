package sg.view.inside
{
    import sg.view.menu.ItemEquip;
    import ui.inside.equipItemUI;
    import sg.model.ModelEquip;
    import laya.ui.Label;
    import laya.ui.Image;
    import sg.model.ModelHero;
    import sg.cfg.ConfigColor;
    import sg.utils.Tools;
    import sg.model.ModelItem;
    import sg.model.ModelBuiding;

    public class ItemEquip extends equipItemUI{
        public var mModel:ModelEquip;
        public var mStatus:int = 0;
        public function ItemEquip():void{
            
        }
        public function setData(emd:ModelEquip,type:int = -1):void{
            this.mModel = emd;
            //
            this.mStatus = 0;
            //
            var nameB:Boolean = false;
            var grayB:Boolean = false;
            if(type>=5){
                nameB = true;
            }
            //
            if(this.mModel.isMine()){
                this.item.setHeroEquipType(this.mModel, this.mModel.type);
				this.item.setHeroEquipMaster(mModel);
                this.mStatus = 2;
                nameB = true;
            }else{
                this.item.setHeroEquipType(type>=5?this.mModel:null,type>=5?-1:this.mModel.type);
                if(this.mModel.isInQueue()){
                    this.mStatus = 1;
                }
                else{
                    grayB = true;
                }
            }
            //
            this.item.gray = grayB;
            //
            if(nameB){
                this.item.label.visible = true;
                this.item.label.color = ConfigColor.FONT_COLORS[this.mModel.getLv()];
                this.item.label.text = this.mModel.getName();
                Tools.textFitFontSize(this.item.label);
            }
            this.item.imgName.visible = this.item.label.visible;

        }

        public function setShow(emd:ModelEquip,showName:Boolean=false):void{
            this.mModel=emd;
            this.item.setHeroEquipType(this.mModel,this.mModel.type,false,-1,true);
            if(showName){
                this.item.label.visible = true;
                this.item.label.color = ConfigColor.FONT_COLORS[this.mModel.getLv()];
                this.item.label.text = this.mModel.getName();
                Tools.textFitFontSize(this.item.label);
            }else{
                this.item.label.visible = false;
            }
            this.item.imgName.visible = this.item.label.visible;
            
        }


        public function setDataChange(emd:ModelEquip):void{
            this.mModel = emd;
            this.item.setHeroEquipType(this.mModel,-1);
            this.item.label.visible = true;
            this.item.label.color = ConfigColor.FONT_COLORS[this.mModel.getLv()];
            this.item.label.text = this.mModel.getName();
            Tools.textFitFontSize(this.item.label);
            //
			this.item.setHeroEquipMaster(emd);
            this.item.imgName.visible = this.item.label.visible;
        }
        public function showSelect(b:Boolean):void{
            this.select.visible = b;
        }
        /**
         * 检查是否能制作
         */
        public function checkCanMake():void{
            var b:Boolean = true;
            if(this.mModel && !this.mModel.isMine() && this.mModel.make_item){
                var pay:Object = this.mModel.make_item;
                var payArr:Array = Tools.getPayItemArr(pay);
                var len:int = payArr.length;
                var payItem:Object;
                var itemNo:Number = 0;
                for(var i:Number = 0; i < len; i++){
                    payItem = payArr[i];
                    if(payItem.id.indexOf("item")>-1){
                        if(ModelItem.getMyItemNum(payItem.id)<payItem.data){
                            b = false;
                            break;
                        }
                    }else{
                        if(!ModelBuiding.getMaterialEnough(payItem.id,payItem.data)){
                            b = false;
                            break;
                        }
                    }
                }
            }
            if(this.mModel && this.mModel.isMine()){
                b = false;
            }
            this.imgSuc.visible = b;
        }

        /**
         * 检查是否能突破
         */
        public function checkCanUpgrade():void{
            var b:Boolean = false;
            if(this.mModel && this.mModel.isMine() && this.mModel.upgrade){
                var _lv:Number = this.mModel.getLv();
                if(_lv<this.mModel.getMaxLv()){
                    b = true;
                    var pay:Object = this.mModel.upgrade[_lv+1].cost;
                    var payArr:Array = Tools.getPayItemArr(pay);
                    var len:int = payArr.length;
                    var payItem:Object;
                    var itemNo:Number = 0;
                    for(var i:Number = 0; i < len; i++){
                        payItem = payArr[i];
                        if(payItem.id.indexOf("item")>-1){
                            if(ModelItem.getMyItemNum(payItem.id)<payItem.data){
                                b = false;
                                break;
                            }
                        }else{
                            if(!ModelBuiding.getMaterialEnough(payItem.id,payItem.data)){
                                b = false;
                                break;
                            }
                        }
                    }
                }
            }

            this.imgSuc.visible = b;
        }
    }
}