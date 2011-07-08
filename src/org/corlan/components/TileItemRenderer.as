package org.corlan.components {
	import flash.display.Sprite;
	import mx.core.FlexGlobals;
	import mx.events.FlexEvent;
	import mx.graphics.BitmapFillMode;
	import mx.graphics.BitmapScaleMode;
	import spark.components.Image;
	import spark.components.LabelItemRenderer;
	import spark.core.ContentCache;
	import spark.utils.MultiDPIBitmapSource;
	
	
	/**
	 *  Section Title font size
	 */
	[Style(name="sectionFontSize", type="Number", format="Length", inherit="no")]
	
	public class TileItemRenderer extends LabelItemRenderer {
		
		private static var _imageCache:ContentCache;
		
		public function TileItemRenderer() {
			super();
			if (_imageCache == null) {
				_imageCache = new ContentCache();
				_imageCache.enableCaching = true;
				_imageCache.maxCacheEntries = 100;
			}
		}
		
		private var _backgroundSection:Number = 0xDDDDDD;
		
		public function set backgroundSection(value:Number):void {
			_backgroundSection = value;
		}
		
		public function set sectionFontSize(value:int):void {
			setStyle("sectionFontSize", value);
		}

		public function set fontSize(value:int):void {
			setStyle("fontSize", value);
		}
		
		private var _backgroundRegular:Number = 0xF4DD06;
		private var _backgroundLabel:Number = 0xEAEAE8;
		
		private var _normalLabelField:String = "label";
		
		public function set normalLabelField(value:String):void {
			_normalLabelField = value;
		}
		
		private var _sectionLabel:String = "section";
		
		public function set sectionLabel(value:String):void {
			if (value == _sectionLabel)
				return;
			
			_sectionLabel = value;
			invalidateProperties();
		}

		private var _iconField:String;
		
		/**
		 *  The name of the field in the data item to display as the icon. 
		 *  By default <code>iconField</code> is <code>null</code>, and the item renderer 
		 *  does not display an icon.
		 *
		 *  @default null
		 * 
		 *  @langversion 3.0
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function get iconField():String {
			return _iconField;
		}
		
		/**
		 *  @private
		 */ 
		public function set iconField(value:String):void {
			if (value == _iconField)
				return;
			
			_iconField = value;
			invalidateProperties();
		}
		
		/**
		 * Change the style based on the data: section item or regular item
		 */ 
		override public function set data(value:Object):void {
			if (value) {
				if (value[_sectionLabel]) {
					if (image)
						image.visible = false;
					if (labelBg)
						labelBg.visible = false;
					label = value[_sectionLabel];
					labelDisplay.setStyle("textAlign", "center");
					labelDisplay.setStyle("fontWeight", "bold");
					labelDisplay.setStyle("fontSize", getStyle("sectionFontSize"));
				} else {
					if (_iconField && value[_iconField]) {
						if (image)
							image.visible = true;
						image.source = value[_iconField];
					} else {
						if (image) {
							image.visible = false;
							image.source = "";
						}
					}
					if (labelBg)
						labelBg.visible = true;
					label = value[_normalLabelField];
					labelDisplay.setStyle("fontSize", getStyle("fontSize"));
					labelDisplay.setStyle("textAlign", "left");
					labelDisplay.setStyle("fontWeight", "normal");
				}
			}
			super.data = value;	
		}
		
		//destroyIconDisplay() todo;
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			// clear the graphics before calling super.updateDisplayList()
			graphics.clear();
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			//the following methods are called in super.updateDisplayList();
			//drawBackground(unscaledWidth, unscaledHeight);
			//layoutContents(unscaledWidth, unscaledHeight);
		}
		
		private var image:Image;
		private var labelBg:Sprite;
		private var drawn:Boolean;

		override protected function createChildren():void {
			if (!image) {
				image = new Image();
				image.smooth = true;
				image.scaleMode = BitmapScaleMode.STRETCH;
				image.fillMode = BitmapFillMode.SCALE;
				image.contentLoader = _imageCache;
				addChild(image);
			}
			//create the background for label
			if (!labelBg) {
				labelBg = new Sprite();
				addChild(labelBg);
			}
			super.createChildren();
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
			} else {
				//add a vertical line to the right of the item			
				var rightSeparatorColor:uint = 0x000000;
				var rightSeparatorAlpha:Number = .3;
				graphics.beginFill(rightSeparatorColor, rightSeparatorAlpha);
				graphics.drawRect(unscaledWidth - 1, 0, 1, unscaledHeight);
				graphics.endFill();
				//draw a rounded corner place holder for text and icon
				//let a padding around for seeing through the selection
				graphics.beginFill(_backgroundRegular, 1);
				graphics.lineStyle();
				graphics.drawRoundRect(3, 3, unscaledWidth - 6, unscaledHeight - 6, 10, 10);
				graphics.endFill();
			}
		}
		
		override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void {
			super.layoutContents(unscaledWidth, unscaledHeight);
			
			//position the image
			if (!data[_sectionLabel] && _iconField && data[_iconField]) {
				setElementPosition(image, 5, 5);
				setElementSize(image, unscaledWidth - 10, unscaledWidth - 10);
			}
			
			if (!data[_sectionLabel] && labelDisplay) {
				labelDisplay.commitStyles();
				var h:Number = labelDisplay.height;
				
				//draw for holding the text
				if (!drawn) {
					drawn = true;
					labelBg.graphics.clear();
					labelBg.graphics.beginFill(_backgroundLabel, 1);
					labelBg.graphics.lineStyle();
					labelBg.graphics.drawRoundRect(3, unscaledHeight - 10 - h, unscaledWidth - 6, h + 6, 10, 10);
					labelBg.graphics.endFill();
					//					setElementPosition(labelBg, 0, unscaledHeight - 10 - h);
				}
				var paddingLeft:Number = getStyle("paddingLeft");
				//reposition the label at the bottom of the item
				setElementPosition(labelDisplay, paddingLeft, unscaledHeight - h);
			}
		}
		
	}
}