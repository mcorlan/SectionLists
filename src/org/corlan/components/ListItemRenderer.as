package org.corlan.components {
	import mx.states.SetStyle;
	import spark.components.IconItemRenderer;

	
	/**
	 *  Section Title font size
	 */
	[Style(name="sectionFontSize", type="Number", format="Length", inherit="no")]
	
	public class ListItemRenderer extends IconItemRenderer {
		
		private var _backgroundSection:Number = 0xDDDDDD;
		
		public function set sectionFontSize(value:int):void {
			setStyle("sectionFontSize", value);
		}
		
		public function set backgroundSection(value:Number):void {
			_backgroundSection = value;
		}
		
		private var _sectionLabel:String = "section";
		
		public function set sectionLabel(value:String):void {
			if (value == _sectionLabel)
				return;
			
			_sectionLabel = value;
			invalidateProperties();
		}
		
		private var _normalLabelField:String = "label";
		
		public function set normalLabelField(value:String):void {
			_normalLabelField = value;
		}
		
		/**
		 * Change the style based on the data: section item or regular item
		 */ 
		override public function set data(value:Object):void {
			if (value) {
				if (value[_sectionLabel]) {
					label = value[_sectionLabel];
					labelDisplay.setStyle("textAlign", "center");
					labelDisplay.setStyle("fontWeight", "bold");
					labelDisplay.setStyle("fontSize", getStyle("sectionFontSize"));
					iconWidth = 0;
				} else {
					iconWidth = iconHeight;
					label = value[_normalLabelField];
					labelDisplay.setStyle("fontSize", getStyle("fontSize"));
					labelDisplay.setStyle("textAlign", "left");
					labelDisplay.setStyle("fontWeight", "normal");
				}
			}
			super.data = value;	
		}
		
		/**
		 * Change the background color for section items
		 */ 
		override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void {
			super.drawBackground(unscaledWidth, unscaledHeight);
			
			if (data[_sectionLabel]) {
				graphics.beginFill(_backgroundSection, 1);
				graphics.lineStyle();
				graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
				graphics.endFill();
			} 
		}
	}
}