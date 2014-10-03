/**
 * Fractal.as
 *
 * Copyright (c) 2008 Tom Beddard
 * http://www.subblue.com
 *
 * Licensed under the MIT License: http://www.opensource.org/licenses/mit-license.php
 */

package {
import flash.display.*;
import flash.events.*;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Point;
import flash.geom.Vector3D;
import flash.text.TextField;

import mx.core.DesignLayer;
import mx.core.IVisualElement;
import mx.geom.TransformOffsets;

public class Fractal extends Sprite implements IVisualElement {

    public var activeLayer:FractalBitmap;
    private var _zoomFactor:Number = 2;
    private var dragging:Boolean = false;
    private var dragPoint:Point;
    private var _status:TextField;

    public function Fractal(fractalBitmap:FractalBitmap = null) {
        addLayer(fractalBitmap);
        addEventListener(Event.ADDED_TO_STAGE, initialiseEvents);
        fractalBitmap.addEventListener(FractalBitmap.RENDER_QUEUE_COMPLETE, renderCompleteListener);
    }

    public function addLayer(fractalBitmap:FractalBitmap = null):void {
        if (fractalBitmap) {
            addChild(fractalBitmap);
            activeLayer = fractalBitmap;
        }
    }

    public function render():void {
        activeLayer.render();
    }

    public function resize(w:Number, h:Number):void {
        for (var i:int = 0; i < numChildren; i++) {
            FractalBitmap(getChildAt(i)).resize(w, h);
            FractalBitmap(getChildAt(i)).render();
        }
    }

    public function move(dx:int, dy:int):void {
        for (var i:int = 0; i < numChildren; i++)
            FractalBitmap(getChildAt(i)).pan(dx, dy);
    }

    public function zoom(dz, mx:Number, my:Number):void {
        for (var i:int = 0; i < numChildren; i++)
            FractalBitmap(getChildAt(i)).zoom(dz, mx, my);
    }


    private function initialiseEvents(e:Event):void {
        addEventListener(MouseEvent.MOUSE_DOWN, mouseDownListener);
        addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveListener);
        addEventListener(MouseEvent.MOUSE_UP, mouseUpListener);
        stage.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelListener);
    }

    private function mouseDownListener(e:MouseEvent):void {
        if (!dragging && e.ctrlKey) {
            dragging = true;
            dragPoint = new Point(mouseX, mouseY);
        }
        else if (e.shiftKey) {
            zoom(1 / _zoomFactor, mouseX, mouseY);
        }
        else {
            zoom(_zoomFactor, mouseX, mouseY);
        }
    }

    private function mouseMoveListener(e:MouseEvent):void {
        if (!dragging) return;

        x = int(stage.mouseX - dragPoint.x);
        y = int(stage.mouseY - dragPoint.y);
        e.updateAfterEvent();
    }

    private function mouseUpListener(e:MouseEvent):void {
        if (!dragging) return;
        dragging = false;
        x = y = 0;
        move(dragPoint.x - stage.mouseX, dragPoint.y - stage.mouseY);
    }

    private function mouseWheelListener(e:MouseEvent):void {
        trace("Mouse wheel");
        var dz:Number = e.delta > 0 ? _zoomFactor : 1 / _zoomFactor;

        for (var i:int = 0; i < numChildren; i++)
            FractalBitmap(getChildAt(i)).zoom(dz, mouseX, mouseY);
    }

    private function renderCompleteListener(e:Event):void {
        if (_status) {
            _status.text = 'Complete';
        }
    }

    public function get left():Object {
        return null;
    }

    public function set left(value:Object):void {
    }

    public function get right():Object {
        return null;
    }

    public function set right(value:Object):void {
    }

    public function get top():Object {
        return null;
    }

    public function set top(value:Object):void {
    }

    public function get bottom():Object {
        return null;
    }

    public function set bottom(value:Object):void {
    }

    public function get horizontalCenter():Object {
        return null;
    }

    public function set horizontalCenter(value:Object):void {
    }

    public function get verticalCenter():Object {
        return null;
    }

    public function set verticalCenter(value:Object):void {
    }

    public function get baseline():Object {
        return null;
    }

    public function set baseline(value:Object):void {
    }

    public function get baselinePosition():Number {
        return 0;
    }

    public function get percentWidth():Number {
        return 0;
    }

    public function set percentWidth(value:Number):void {
    }

    public function get percentHeight():Number {
        return 0;
    }

    public function set percentHeight(value:Number):void {
    }

    public function get includeInLayout():Boolean {
        return false;
    }

    public function set includeInLayout(value:Boolean):void {
    }

    public function getPreferredBoundsWidth(postLayoutTransform:Boolean = true):Number {
        return 0;
    }

    public function getPreferredBoundsHeight(postLayoutTransform:Boolean = true):Number {
        return 0;
    }

    public function getMinBoundsWidth(postLayoutTransform:Boolean = true):Number {
        return 0;
    }

    public function getMinBoundsHeight(postLayoutTransform:Boolean = true):Number {
        return 0;
    }

    public function getMaxBoundsWidth(postLayoutTransform:Boolean = true):Number {
        return 0;
    }

    public function getMaxBoundsHeight(postLayoutTransform:Boolean = true):Number {
        return 0;
    }

    public function getBoundsXAtSize(width:Number, height:Number, postLayoutTransform:Boolean = true):Number {
        return 0;
    }

    public function getBoundsYAtSize(width:Number, height:Number, postLayoutTransform:Boolean = true):Number {
        return 0;
    }

    public function getLayoutBoundsWidth(postLayoutTransform:Boolean = true):Number {
        return 0;
    }

    public function getLayoutBoundsHeight(postLayoutTransform:Boolean = true):Number {
        return 0;
    }

    public function getLayoutBoundsX(postLayoutTransform:Boolean = true):Number {
        return 0;
    }

    public function getLayoutBoundsY(postLayoutTransform:Boolean = true):Number {
        return 0;
    }

    public function setLayoutBoundsPosition(x:Number, y:Number, postLayoutTransform:Boolean = true):void {
    }

    public function setLayoutBoundsSize(width:Number, height:Number, postLayoutTransform:Boolean = true):void {
    }

    public function getLayoutMatrix():Matrix {
        return null;
    }

    public function setLayoutMatrix(value:Matrix, invalidateLayout:Boolean):void {
    }

    public function get hasLayoutMatrix3D():Boolean {
        return false;
    }

    public function getLayoutMatrix3D():Matrix3D {
        return null;
    }

    public function setLayoutMatrix3D(value:Matrix3D, invalidateLayout:Boolean):void {
    }

    public function transformAround(transformCenter:Vector3D, scale:Vector3D = null, rotation:Vector3D = null, translation:Vector3D = null, postLayoutScale:Vector3D = null, postLayoutRotation:Vector3D = null, postLayoutTranslation:Vector3D = null, invalidateLayout:Boolean = true):void {
    }

    public function get layoutDirection():String {
        return "";
    }

    public function set layoutDirection(value:String):void {
    }

    public function invalidateLayoutDirection():void {
    }

    public function get owner():DisplayObjectContainer {
        return null;
    }

    public function set owner(value:DisplayObjectContainer):void {
    }

    public function get depth():Number {
        return 0;
    }

    public function set depth(value:Number):void {
    }

    public function get designLayer():DesignLayer {
        return null;
    }

    public function set designLayer(value:DesignLayer):void {
    }

    public function get postLayoutTransformOffsets():TransformOffsets {
        return null;
    }

    public function set postLayoutTransformOffsets(value:TransformOffsets):void {
    }

    public function get is3D():Boolean {
        return false;
    }
}
}