package sg.view.countryPvp
{
	import ui.countryPvp.country_tributary_tipsUI;
	import sg.manager.ModelManager;
	import sg.utils.Tools;
	import sg.model.ModelOfficial;
	import sg.utils.SaveLocal;
	import sg.cfg.ConfigServer;

	/**
	 * ...
	 * @author
	 */
	public class ViewCountryTributaryTips extends country_tributary_tipsUI{//年度进贡报告
		public function ViewCountryTributaryTips(){
			this.tTitle.text=Tools.getMsgById("_countrypvp_text38");//"年度进贡报告";
			this.text0.text=Tools.getMsgById("_public114");
			Tools.textLayout2(tTitle,imgTitle,378,150);
		}


		override public function onAdded():void{
			
			var n:Number=ModelOfficial.cities["-1"].country;
			this.tText.text=Tools.getMsgById("_countrypvp_text39",[Tools.getMsgById("country_"+n)]);// +"统治天下";

			this.tContent.style.color="#ffffff";
			this.tContent.style.fontSize=20;
			this.tContent.style.align="center";
			this.tContent.style.leading=5;
			
			var s:String=Math.round(ConfigServer.country.warehouse.tribute[2]*100)+"%";
			
			var n1:Number;
			var n2:Number;
			if(n==0){
				n1=1;
				n2=2;
			}else if(n==1){
				n1=0;
				n2=2;
			}else if(n==2){
				n1=0;
				n2=1;
			}
			// "{0}国库{1}的税收，{2}国库的{3}的税收  纳入{4}国库，以作岁供";
			this.tContent.innerHTML=Tools.getMsgById("_countrypvp_text37",[Tools.getMsgById("country_"+n1),s,Tools.getMsgById("country_"+n2),s,Tools.getMsgById("country_"+n)]);
			this.tContent.height=this.tContent.contextHeight;
			this.tContent.y=(this.infoBox.height-this.tContent.height)/2;

			SaveLocal.save(SaveLocal.KEY_COUNTRY_TRUBUTR + ModelManager.instance.modelUser.mUID,{"login_num":ModelManager.instance.modelUser.loginDateNum},true);
		}


		override public function onRemoved():void{
			
		}
	}

}