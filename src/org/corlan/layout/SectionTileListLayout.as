package org.corlan.layout {

	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import mx.collections.IList;
	import mx.core.ILayoutElement;
	import mx.rpc.events.HeaderEvent;
	
	import spark.components.DataGroup;
	import spark.components.supportClasses.GroupBase;
	import spark.layouts.BasicLayout;
	import spark.layouts.VerticalLayout;
	
	public class SectionTileListLayout extends BasicLayout {

		private var _sectionLabel:String = "section";
		private var _lastIndexInView:int;
		private var _firstIndexInView:int;
		private var yToIndex:Vector.<int>; 
		private var indexToY:Vector.<int>; 
		private var currentFirstIndex:int;
		private var currentLastIndex:int;
		private var _containerWidth:Number;
		private var _containerHeight:Number;

		private var _horizontalGap:Number = 0;
		private var _verticalGap:Number = 0;
		private var _columnWidth:Number = 200;
		private var _sectionHeight:Number = 40;
		private var _tileHeight:Number = 60;
		private var addExtraItems:int;
		
		public function SectionTileListLayout() {
			super();
		}
		
		public function get sectionHeight():Number {
			return _sectionHeight;
		}

		public function set sectionHeight(value:Number):void {
			if (value == _sectionHeight)
				return;
			_sectionHeight = value;
			var layoutTarget:GroupBase = target;
			if (layoutTarget) {
				layoutTarget.invalidateSize();
				layoutTarget.invalidateDisplayList();
			}
		}

		public function get tileHeight():Number {
			return _tileHeight;
		}

		public function set tileHeight(value:Number):void {
			if (value == _tileHeight)
				return;
			_tileHeight = value;
			var layoutTarget:GroupBase = target;
			if (layoutTarget) {
				layoutTarget.invalidateSize();
				layoutTarget.invalidateDisplayList();
			}
		}

		public function set sectionLabel(value:String):void {
			_sectionLabel = value;
		}
		
		public function set horizontalGap(value:Number):void {
			if (_horizontalGap == value)
				return;
			_horizontalGap = value;
			
			// We must invalidate the layout
			var layoutTarget:GroupBase = target;
			if (layoutTarget) {
				layoutTarget.invalidateSize();
				layoutTarget.invalidateDisplayList();
			}
		}
		
		public function set verticalGap(value:Number):void {
			if (_verticalGap == value)
				return;
			_verticalGap = value;
			
			// We must invalidate the layout
			var layoutTarget:GroupBase = target;
			if (layoutTarget) {
				layoutTarget.invalidateSize();
				layoutTarget.invalidateDisplayList();
			}
		}
		
		public function set columnWidth(value:Number):void {
			if (value == _columnWidth)
				return;
			
			_columnWidth = value;
			var layoutTarget:GroupBase = target;
			if (layoutTarget) {
				layoutTarget.invalidateSize();
				layoutTarget.invalidateDisplayList();
			}
		}	
		
		/**
		 * 
		 */ 
		override public function measure():void {
			if (!useVirtualLayout)
				return;
			var layoutTarget:GroupBase = target;
			if (!layoutTarget)
				return;
			var dataGroupTarget:DataGroup = layoutTarget as DataGroup;
			if (dataGroupTarget.width == 0 || dataGroupTarget.height == 0) {
				_containerWidth = _containerHeight = -1;
				return;
			}
			trace("measure()");
				
			var totalWidth:Number = 0;
			var totalHeight:Number = 0;
			var dataProvider:IList = dataGroupTarget.dataProvider;
			if (!dataProvider || !dataProvider.length)
				return;
			var count:int = dataProvider.length;
			var rowWidth:Number = dataGroupTarget.width;
			var sectionHeight:Number = _sectionHeight;
			var tileHeight:Number = _tileHeight;
			var tileWidth:Number = _columnWidth;
			
			totalWidth = rowWidth;
			
			var elementWidth:Number, elementHeight:Number;
			var x:Number = 0;
			yToIndex = new Vector.<int>();
			indexToY = new Vector.<int>();
			var d:Object = d = dataProvider.getItemAt(0);
			if (_sectionLabel in d) {
				addToVectorY(0, 0, sectionHeight);
				totalHeight = sectionHeight + _verticalGap;
			} else {
				addToVectorY(0, 0, tileHeight);
				totalHeight = tileHeight + _verticalGap;
			}
			//loop though all the elements elements
			for (var i:int = 0; i < count; i++) {
				d = dataProvider.getItemAt(i);
				if (!d) {
					elementWidth = tileWidth;
					elementHeight = tileHeight;
				} else if (_sectionLabel in d) {
					elementWidth = rowWidth;
					elementHeight = sectionHeight;
				} else {
					elementWidth = tileWidth;
					elementHeight = tileHeight;
				}
				// Would this element fit on this line, or should we move it
				// to the next line?
				if (x + elementWidth > rowWidth) {
					x = 0;
					//add the index to vector
					addToVectorY(i, totalHeight + 1, elementHeight);
					totalHeight += elementHeight + _verticalGap;
				}
				addToVectorIndex(i, totalHeight - elementHeight - _verticalGap);
				// Update the current position, add the gap
				x += elementWidth + _horizontalGap;
			}
			layoutTarget.measuredWidth = totalWidth;
			layoutTarget.measuredHeight = totalHeight;
			layoutTarget.measuredMinWidth = totalWidth;
			layoutTarget.measuredMinHeight = totalHeight; 
			layoutTarget.setContentSize(totalWidth, totalHeight);
		}
		
		private function addToVectorY(index:int, startHeight:Number, elementHeight:Number):void {
			var end:int = startHeight + elementHeight + _verticalGap + 1;
			for (var i:int = startHeight; i < end; i++) {
				yToIndex[i] = index;
			}
		}

		private function addToVectorIndex(index:int, y:int):void {
			indexToY[index] = y;
		}
		
		override protected function scrollPositionChanged():void {
			trace("scrollPositionChanged()");
			if (!useVirtualLayout) {
				super.scrollPositionChanged();
				return;
			}
				
			var g:GroupBase = target;
			if (!g)
				return;     
			updateScrollRect(g.width, g.height);
			
			var n:int = g.numElements - 1;
			if (n < 0) {
				setIndexInView(-1, -1);
				return;
			}
			
			var scrollR:Rectangle = getScrollRect();
			if (!scrollR) {
				setIndexInView(0, n);
				return;    
			}
			
			var y0:Number = scrollR.top;
			var y1:Number = scrollR.bottom - .0001;
			if (y1 <= y0) {
				setIndexInView(0, n);
				return;
			}

			var i0:int, i1:int;
			if (y0 < 0) {
				i0 = 0;
				i1 = yToIndex.length - 1 > g.height ? yToIndex[g.height + 1]  : g.numElements - 1;
				setIndexInView(i0, i1);
				return;	
			}
			
			if (y1 < yToIndex.length - 1) {
				i0 = yToIndex[Math.floor(y0)];
				i1 = yToIndex[Math.ceil(y1)];
			} else {
				if (yToIndex.length - 1 - g.height < 0)
					i0 = 0;
				else
					i0 = yToIndex[yToIndex.length - 1 - g.height];
				i1 = yToIndex[yToIndex.length - 1];
			}
//			trace("y0, y1: " + y0 + " | " + y1);
//			trace("i0, i1: " + i0 + " | " + i1);
//			trace("currentFirstIndex, currentLastIndex : " + currentFirstIndex + " | " + currentLastIndex);
			setIndexInView(i0, i1);
			//invalidate display list only if we have items that are not already renderered
			if (i0 < currentFirstIndex || i1 > currentLastIndex) {
				trace("g.invalidateDisplayList()");
				g.invalidateDisplayList();
			}
		}
		
		override public function updateDisplayList(containerWidth:Number, containerHeight:Number):void {
			trace("updateDisplayList(" + containerWidth + "," + containerHeight  + ")");
			if (useVirtualLayout)
				updateVirtual(containerWidth, containerHeight);
			else
				updateNonVirtual(containerWidth, containerHeight);
			
		}
		
		/**
		 * Lay down all the items - this is used when useVirtualLayout is set to false
		 */ 
		private function updateNonVirtual(containerWidth:Number, containerHeight:Number):void {
			var layoutTarget:GroupBase = target;
			if (!(layoutTarget as DataGroup).dataProvider || (layoutTarget as DataGroup).dataProvider.length == 0)
				return;
			
			if (!_containerWidth)
				_containerWidth = containerWidth;
			if (!_containerHeight)
				_containerHeight = containerHeight;
			
			var x:Number = 0;
			var y:Number = 0;
			var maxWidth:Number = 0;
			var maxHeight:Number = 0;
			var elementWidth:Number, elementHeight:Number, prevElementHeight:Number;
			
			y = 0;
			var count:int = layoutTarget.numElements;
			var element:ILayoutElement;
			
			for (var i:int = 0; i < count; i++) {
				// get the current element, we're going to work with the
				// ILayoutElement interface
				element = layoutTarget.getElementAt(i);
				// Resize the element to its preferred size by passing
				// NaN for the width and height constraints
				element.setLayoutBoundsSize(NaN, NaN);
				if (element["data"] && _sectionLabel in element["data"]) {
					elementWidth = containerWidth;
					elementHeight = _sectionHeight;
				} else {
					elementWidth = _columnWidth;
					elementHeight = _tileHeight;
				}				
				element.setLayoutBoundsSize(elementWidth, elementHeight);
				
				// Would the element fit on this line, or should we move
				// to the next line?
				if (x + elementWidth > containerWidth) {
					x = 0;
					//move to the next row
					y += prevElementHeight + _verticalGap;
				}
				// Position the element
				element.setLayoutBoundsPosition(x, y);
				prevElementHeight = elementHeight;
				// Update the current position, add the gap
				x += elementWidth + _horizontalGap;
			}
			// Scrolling support - update the content size
			layoutTarget.setContentSize(containerWidth, y);
		}
		
		/**
		 * Lay down the current items in the view - this is used when useVirtualLayout is set to true
		 */
		private function updateVirtual(containerWidth:Number, containerHeight:Number):void {
			var layoutTarget:GroupBase = target;
			if (!(layoutTarget as DataGroup).dataProvider || (layoutTarget as DataGroup).dataProvider.length == 0)
				return;
			
			if (!_containerWidth)
				_containerWidth = containerWidth;
			if (!_containerHeight)
				_containerHeight = containerHeight;
			//a resize of the component occured
			if (_containerWidth != containerWidth || _containerHeight != containerHeight) {
				_containerWidth = containerWidth;
				_containerHeight = containerHeight;
				addExtraItems = 0;
				measure();
				//set the new _firstIndex and _lastIndex
				scrollPositionChanged();
				trace("return from updateDisplayList()");
			}
			trace(layoutTarget.numElements);
			var x:Number = 0;
			var y:Number = 0;
			var maxWidth:Number = 0;
			var maxHeight:Number = 0;
			var elementWidth:Number, elementHeight:Number, prevElementHeight:Number;
			
			//provide the initial values
			if (!_firstIndexInView) 
				_firstIndexInView = 0;
			if (!_lastIndexInView) 
				_lastIndexInView = yToIndex.length - 1 > layoutTarget.height ? yToIndex[layoutTarget.height + 1]  : layoutTarget.numElements - 1;
			
			//add some extra rows after the current view
			currentFirstIndex = _firstIndexInView;
			if (currentFirstIndex < 0 )
				currentFirstIndex = 0;
			if (!addExtraItems) {
				addExtraItems = Math.ceil(containerWidth / (_columnWidth + _horizontalGap)) * Math.ceil(containerHeight / ((_tileHeight + _sectionHeight) / 2)); 
			}
			currentLastIndex = _firstIndexInView + addExtraItems;
			if (currentLastIndex > layoutTarget.numElements - 1)
				currentLastIndex = layoutTarget.numElements - 1;
			
			y = indexToY[currentFirstIndex];
			var count:int = currentLastIndex + 1;
			var element:ILayoutElement;
			
			for (var i:int = currentFirstIndex; i < count; i++) {
				// get the current element, we're going to work with the
				// ILayoutElement interface
				element = layoutTarget.getVirtualElementAt(i);
				// Resize the element to its preferred size by passing
				// NaN for the width and height constraints
				element.setLayoutBoundsSize(NaN, NaN);
				if (element["data"] && _sectionLabel in element["data"]) {
					elementWidth = containerWidth;
					elementHeight = _sectionHeight;
				} else {
					elementWidth = _columnWidth;
					elementHeight = _tileHeight;
				}				
				element.setLayoutBoundsSize(elementWidth, elementHeight);
				
				// Would the element fit on this line, or should we move
				// to the next line?
				if (x + elementWidth > containerWidth) {
					x = 0;
					//move to the next row
					y += prevElementHeight + _verticalGap;
				}
				// Position the element
				element.setLayoutBoundsPosition(x, y);
				prevElementHeight = elementHeight;
				// Update the current position, add the gap
				x += elementWidth + _horizontalGap;
			}
		}
		
		private function setIndexInView(firstIndex:int, lastIndex:int):void {
			if ((_firstIndexInView == firstIndex) && (_lastIndexInView == lastIndex))
				return;
//			trace("setIndexInView(" + firstIndex + ", " + lastIndex + ")");
			_firstIndexInView = firstIndex;
			_lastIndexInView = lastIndex;
			dispatchEvent(new Event("indexInViewChanged"));
		}
	}
}