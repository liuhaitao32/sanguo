package sg.map.edit 
{
	import laya.display.Sprite;
	import laya.display.Text;
	import mx.core.TextFieldAsset;
	import sg.map.model.MapModel;
	import sg.map.view.MapViewMain;
	import sg.scene.constant.ConfigConstant;
	import sg.scene.model.MapGrid;
	/**
	 * ...
	 * @author light
	 */
	public class TestFlag 
	{
		
		public function TestFlag() 
		{
			
		}
		
		
		
		public static function init():void {
			
			var sp:Sprite = new Sprite();
			MapViewMain.instance.mapLayer.bubbleLayer.addChild(sp)
			for (var name:String in MapModel.instance.citys) {
				if (ConfigConstant.mapData["city"][name]["heroCatch"]) {					
					var mapGrid:MapGrid = MapModel.instance.mapGrid.getGrid(parseInt(ConfigConstant.mapData["city"][name]["heroCatch"].x), parseInt(ConfigConstant.mapData["city"][name]["heroCatch"].y));
					var iso:Sprite = new Sprite();
					iso.graphics.drawCircle(mapGrid.toScreenPos().x, mapGrid.toScreenPos().y, 30, "#FF0000");	
					var text:Text = new Text();
					text.text = "切磋";
					iso.addChild(text);
					text.pos(mapGrid.toScreenPos().x - 30, mapGrid.toScreenPos().y)
					
					sp.addChild(iso);	
					sp.addChild(text);
				}
				
				
				if (ConfigConstant.mapData["city"][name]["monster"]){
					mapGrid = MapModel.instance.mapGrid.getGrid(parseInt(ConfigConstant.mapData["city"][name]["monster"].x), parseInt(ConfigConstant.mapData["city"][name]["monster"].y));			
					
					iso = new Sprite();
					iso.graphics.drawCircle(mapGrid.toScreenPos().x, mapGrid.toScreenPos().y, 30, "#FFFF00");	
					text = new Text();
					text.text = "野怪";
					text.pos(mapGrid.toScreenPos().x - 30, mapGrid.toScreenPos().y)
					sp.addChild(iso);
					sp.addChild(text);
				}
			}
			
			
			Laya.stage.addChild(text);
			text.scale(5, 5)
			
		}
		
	}

}