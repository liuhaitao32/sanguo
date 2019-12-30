package sg.festival.view
{
    import sg.activities.view.ViewDialChoose;
    import sg.festival.model.ModelFestivalDial;
    import sg.utils.Tools;

    public class FestivalDialChoose extends ViewDialChoose {
        public function FestivalDialChoose() {
            super();
			this.btn0.label=Tools.getMsgById("dial_text07");//"普通密藏";
			this.btn1.label=Tools.getMsgById("dial_text08");//"传说密藏";
			this.btn2.label=Tools.getMsgById("dial_text09");//"史诗密藏";
		}

		override public function okClick():void{
            if (btn.gray) {
                super.okClick();
            } else {
                ModelFestivalDial.instance.chooseReward(mSelectArr);
                closeSelf();
            }
        }

		override public function btnClick(index:int):void{
            super.btnClick(index);
			this.infoLabel.text = Tools.getMsgById("dial_text12",[(mData[0] * 0.1)+"%"]);//"概率"+(mData[0]*100)+"%";
		}
    }
}