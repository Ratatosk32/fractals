
package {
import flash.display.BitmapData;

public class Mandelbrot extends FractalBitmap {

    public function Mandelbrot(b:BitmapData = null, mapping:Mapping = null) {
        super(b, mapping);
    }

    override protected function formula(x:Number, y:Number):Object {
        var n:int = 0;
        var a:Number = x;
        var b:Number = y;
        var c:Number;
        var zz:Number, aa:Number, bb:Number, twoab:Number;

        while (n < _maxIterations) {
            aa = a * a;
            bb = b * b;

            c = bailoutCondition(aa, bb);
            if (c > _bailout) {
                zz = c;
                break;
            }

            twoab = 2.0 * a * b;
            a = aa - bb + x;
            b = twoab + y;
            n++;
        }

        return {n: n, a: a, b: b, zz: zz};
    }

      protected function bailoutCondition(aa:Number, bb:Number):Number {
        if (_bailoutType == 'spiky') {
            return (aa - bb);
        } else if (_bailoutType == 'puffy') {
            return (bb - aa);
        } else {
            return (aa + bb);
        }
    }
}
}