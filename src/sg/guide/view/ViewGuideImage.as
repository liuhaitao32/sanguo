package sg.guide.view
{
    import laya.events.Event;
    import laya.ui.Button;
    import laya.utils.Ease;
    import laya.utils.Handler;
    import laya.utils.Tween;

    import sg.guide.model.ModelGuide;
    import sg.manager.AssetsManager;
    import sg.manager.LoadeManager;
    import sg.manager.ViewManager;
    import sg.utils.Tools;

    import ui.guide.guideImageUI;
    import sg.manager.ModelManager;

    public class ViewGuideImage extends guideImageUI
    {
	    private var autoNext:Boolean = true;;
        public function ViewGuideImage()
        {
        }

		override public function set currArg(v:*):void {
            autoNext = Boolean(v.next);
            var url:* = v.url;
            if (url is Array) {
                url = url[ModelManager.instance.modelUser.country];
            }
            this.showImage(url, v.txt);
            autoNext && (ModelGuide.instance.lockScreen = true);
		}

        private function showImage(url:String, txt:String = ''):void
        {
            this.img.alpha = 0;
            LoadeManager.loadTemp(this.img, AssetsManager.getAssetsAD(url + '.jpg'));
            this.words.text = Tools.getMsgById(txt);
            this.img.alpha = 0;
            Tween.to(this.img, {alpha:1}, 1000, Ease.linearNone, Handler.create(this, this.onImgIn));
        }

        private function bgClick():void{
            Tween.to(this.img, {alpha:0}, 300, Ease.linearNone, Handler.create(this, this.onImgOut));
        }

        private function onImgIn():void {
            Laya.stage.once(Event.CLICK,this,this.onImgOut);
        }

        private function onImgOut():void
        {
            this.removeSelf();
            autoNext && ModelGuide.instance.nextStep();
        }
    }
}