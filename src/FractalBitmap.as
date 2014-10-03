
package {
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.PixelSnapping;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.utils.Timer;
import flash.utils.getTimer;

public class FractalBitmap extends Bitmap {
    static public const BUCKET_SIZE:int = 64;
    static public const BUCKET_COMPLETE:String = "bucketComplete";
    static public const RENDER_QUEUE_STARTED:String = "renderQueueStarted";
    static public const RENDER_QUEUE_COMPLETE:String = "renderQueueComplete";
    static public const MAX_MAGNIFICATION:Number = 8e12;

    private var DEFAULT_MAGNIFICATION = 1;
    private var X_ORIGIN = -0.5;
    private var Y_ORIGIN = 0;

    private var _mapping:Mapping;
    protected var _maxIterations:int = 250;				// Maximum number of iterations
    protected var _bailout:Number = 128;				// Bailout value
    protected var _bailoutType:String = 'standard';		// Bailout type
    private var _ox:Number = X_ORIGIN;				// x origin in imaginary plane
    private var _oy:Number = Y_ORIGIN;				// y origin in imaginary plane
    private var _magnification:Number = 1;			// magnification amount
    private var _sampling:int = 1;					// Pixel sampling
    private var _dx:Number;
    private var _dy:Number;
    private var _bucketSize:int = BUCKET_SIZE;

    private var bucketQueue:Array = [];
    private var rendering:Boolean = false;
    private var bucketComplete:Boolean = false;
    private var bucketCount:int = 0;

    private var minReal:Number = 0.0;
    private var minImaginary:Number = 0.0;

    private var timer:Timer;
    private var startTime:Number = 0.0;
    private var _elapsedTime:Number = 0.0;

    public function FractalBitmap(bitmapData:BitmapData = null, mapping:Mapping = null) {
        super(bitmapData, PixelSnapping.ALWAYS, true);
        _mapping = mapping;
        initialiseTimer();
        addEventListener(BUCKET_COMPLETE, bucketCompleteListener);
    }

    public function render(region:Rectangle = null):void {
        if (!region) region = new Rectangle(0, 0, bitmapData.width, bitmapData.height);
        stopRenderQueue();
        prepareRenderQueue(region);
        startTimer();
        processRenderQueue();
    }

    protected function formula(x:Number, y:Number):Object {
        return {};
    }

    public function pan(dx:int, dy:int, dz:Number = 1, scrollBitmap:Boolean = true):void {
        if (dx != 0 || dy != 0) {
            if (scrollBitmap) bitmapData.scroll(-dx, -dy);
            _ox += (_dx / dz) * dx;
            _oy += (_dy / dz) * dy;

            if (rendering) {
                render();

            } else {
                var r1:Rectangle;
                var r2:Rectangle;

                if (dx != 0) {
                    if (dx > 0) {
                        r1 = new Rectangle(width - dx, 0, dx, height);
                    } else {
                        r1 = new Rectangle(0, 0, -dx, height);
                    }
                    prepareRenderQueue(r1);
                    clear(r1);
                }

                if (dy != 0) {
                    if (dy > 0) {
                        r2 = new Rectangle(0, height - dy, width, dy);
                    } else {
                        r2 = new Rectangle(0, 0, width, -dy);
                    }

                    if (r1) {
                        if (r1.x == 0) r2.x = r1.width;
                        r2.width = width - r1.width;
                        prepareRenderQueue(r2, false);
                    } else {
                        prepareRenderQueue(r2);
                    }

                    clear(r2);
                }
            }
            startTimer();
            processRenderQueue();
        }
    }

    public function zoom(dz:Number, mx:Number, my:Number):void {
        magnification *= dz;
        if (_magnification == MAX_MAGNIFICATION) return;
        bitmapData.lock();
        var dx:int = bitmapData.width / 2 - mx;
        var dy:int = bitmapData.height / 2 - my;
        var zoomed:BitmapData = bitmapData.clone();
        var m:Matrix = new Matrix();
        m.scale(dz, dz);
        m.translate(mx - mx * dz, my - my * dz);

        if (dz < 1) {
            clear();
            dz = -(1 / (2 * dz));
        }

        bitmapData.draw(zoomed, m);
        zoomed.dispose();
        bitmapData.unlock();
        pan(-dx, -dy, dz, false);
        render();
    }

    public function resize(w:int, h:int):void {
        bitmapData.lock();
        var original:BitmapData = bitmapData.clone();
        bitmapData = new BitmapData(w, h);
        bitmapData.draw(original);
        original.dispose();
        bitmapData.unlock();
    }

    private function clear(r:Rectangle = null):void {
        if (!r) r = new Rectangle(0, 0, bitmapData.width, bitmapData.height);
        bitmapData.fillRect(r, 0x00000000);
    }

    private function prepareRenderQueue(region:Rectangle, clear:Boolean = true):void {
        stage.focus = null;
        if (clear) bucketQueue = [];

        var bs:int = _bucketSize / _sampling;
        var xBuckets:int = Math.ceil(region.width / bs);
        var yBuckets:int = Math.ceil(region.height / bs);
        var l:int = region.left
        var t:int = region.top;
        var w:int, h:int;

        if (xBuckets > 1 && yBuckets > 1) {
            for (var i:int = 0; i < yBuckets; i++) {
                l = region.left;
                h = bs;
                if (t + bs > region.bottom) h = region.bottom - t;

                for (var j:int = 0; j < xBuckets; j++) {
                    w = bs;
                    if (l + bs > region.right) w = region.right - l;
                    bucketQueue.push({x: l, y: t, w: w, h: h});
                    l += w;
                }
                t += h;
            }
        } else {
            bucketQueue.push({x: region.x, y: region.y, w: region.width, h: region.height});
        }

        rendering = true;
        bucketCount = 0;
    }

    private function processRenderQueue():void {

        if (bucketCount < bucketQueue.length) {
            if (bucketCount == 0)
                dispatchEvent(new Event(RENDER_QUEUE_STARTED));
            var b:Object = bucketQueue[bucketCount];
            renderBucket(new Rectangle(b.x, b.y, b.w, b.h));
            bucketCount++;
        } else {
            stopRenderQueue();
        }
    }

    private function stopRenderQueue():void {
        stopTimer();
        bucketComplete = true;
        rendering = false;
        bucketCount = 0;
        dispatchEvent(new Event(RENDER_QUEUE_COMPLETE));
    }

    private function bucketCompleteListener(e:Event):void {
        bucketComplete = true;
    }

    private function renderQueueListener(e:TimerEvent):void {
        if (bucketComplete && rendering) {
            bucketComplete = false;
            processRenderQueue();
            e.updateAfterEvent();
        }
    }

    private function renderBucket(r:Rectangle = null):void {
        var i:int, j:int, n:int, ii:int, jj:int;
        var a:Number, b:Number, aa:Number, bb:Number, sdx:Number, sdy:Number;
        var samples:Array;
        var w:int = bitmapData.width;
        var h:int = bitmapData.height;
        var x1:Number = _ox - 2 / _magnification;			// Left limit of x
        var x2:Number = _ox + 2 / _magnification;			// Right limit of x
        var spanX:Number = x2 - x1;
        var spanY:Number = spanX * (h / w);
        var y1:Number = _oy - spanY / 2;
        var y2:Number = _oy + spanY / 2;
        var z:Object;

        _dx = (spanX / w);								// x increment
        _dy = (spanY / h);								// y increment
        sdx = _dx / _sampling;							// x increment when super-sampling
        sdy = _dy / _sampling;							// y increment when super-sampling
        x1 += r.left * _dx;
        y1 += r.top * _dy;

        if (r.left == 0 && r.top == 0) {
            minReal = x1;
            minImaginary = y1;
        }

        bitmapData.lock();
        bitmapData.fillRect(r, 0xFF000000);

        b = y1;
        for (j = r.top; j < r.bottom; j++) {
            a = x1;
            for (i = r.left; i < r.right; i++) {
                // Super sampling loop
                samples = [];
                aa = a;
                bb = b;

                for (jj = 0; jj < _sampling; jj++) {
                    aa = a;
                    for (ii = 0; ii < _sampling; ii++) {

                        z = formula(aa, bb);

                        if (z.n < _maxIterations) {

                            samples.push(_mapping.map(z.a, z.b, z.zz, z.n))
                        } else {
                            samples.push(0xFF000000);
                        }
                        aa += sdx;
                    }
                    if (_sampling > 1) {
                        bb += sdy;
                    }
                }

                if (_sampling > 1) {
                    bitmapData.setPixel32(i, j, ColorUtil.average(samples));
                } else {
                    bitmapData.setPixel32(i, j, samples[0]);
                }

                a += (_sampling * sdx);
            }
            b += (_sampling * sdy);
        }

        bitmapData.unlock();
        dispatchEvent(new Event(BUCKET_COMPLETE));
    }

    private function initialiseTimer():void {
        timer = new Timer(1, 0);
        timer.addEventListener(TimerEvent.TIMER, renderQueueListener);
    }

    private function startTimer():void {
        timer.reset();
        timer.start();
        startTime = getTimer();
    }

    private function checkTimer():Number {
        return getTimer() - startTime;
    }

    private function stopTimer(msg:String = "Execution Time"):void {
        _elapsedTime = checkTimer();
        timer.stop();

        if (rendering) {
            if (_elapsedTime > 1000) {
                trace(msg, String(_elapsedTime / 1000) + "s");
            } else {
                trace(msg, String(_elapsedTime) + "ms");
            }
        }
    }

    public function get bailout():int {
        return _bailout;
    }

    public function set bailout(value:int):void {
        if (value !== _bailout) _bailout = value;
    }

    public function get bailoutType():String {
        return _bailoutType;
    }

    public function set bailoutType(value:String):void {
        if (value !== _bailoutType) _bailoutType = value;
    }

    public function get ox():Number {
        return _ox;
    }

    public function set ox(value:Number):void {
        if (value !== _ox) _ox = value;
    }


    public function get oy():Number {
        return _oy;
    }

    public function set oy(value:Number):void {
        if (value !== _oy) _oy = value;
    }


    public function get magnification():Number {
        return _magnification;
    }

    public function set magnification(value:Number):void {
        if (value !== _magnification) _magnification = value;
        if (_magnification > MAX_MAGNIFICATION * _sampling) _magnification = MAX_MAGNIFICATION / _sampling;
    }

    public function get dx():Number {
        return _dx;
    }

    public function get dy():Number {
        return _dy;
    }

    public function get mapping():Mapping {
        return _mapping;
    }

    public function set mapping(value:Mapping):void {
        if (value !== _mapping) _mapping = value;
    }

    public function get imageData():BitmapData {
        return bitmapData;
    }
}
}