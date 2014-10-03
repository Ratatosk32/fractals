package {
public class ColorUtil {

    public static function toHex(r:uint, g:uint, b:uint, a:uint = 0xFF):uint {
        if (r > 0xFF) r = 0xFF;
        if (g > 0xFF) g = 0xFF;
        if (b > 0xFF) b = 0xFF;
        if (a > 0xFF) a = 0xFF;

        return (a << 24) | (r << 16) | (g << 8) | b;
    }


    public static function red(c:uint):uint {
        return c >> 16 & 0xFF;
    }

    public static function green(c:uint):uint {
        return c >> 8 & 0xFF;
    }

    public static function blue(c:uint):uint {
        return c & 0xFF;
    }

    public static function alpha(c:uint):uint {
        return c >> 24 & 0xFF;
    }

    public static function blend(c1:uint, c2:uint, p:Number = 0.5, bc:uint = 0xFFFFFFFF):uint {
        if (p >= 1) return c2;
        if (p <= 0) return c1;

        var r:uint = (red(c1) + (red(c2) - red(c1)) * p);
        var g:uint = (green(c1) + (green(c2) - green(c1)) * p);
        var b:uint = (blue(c1) + (blue(c2) - blue(c1)) * p);
        var a:uint = (c1 == bc) ? alpha(c2) : Math.min(alpha(c1) + alpha(c2), 255);

        return toHex(r, g, b, a);
    }

    public static function blendArray(c1:uint, c2:uint, n:int, last:Boolean = true):Array {
        var a:Array = [];
        var p:Number = 1 / (n + 1);

        for (var i:int = 0; i <= n; i++) {
            a.push(blend(c1, c2, i * p))
        }
        if (last) a.push(c2);

        return a;
    }

    public static function average(colors:Array):uint {
        var l:int = colors.length;
        var r:uint = 0;
        var g:uint = 0;
        var b:uint = 0;

        if (l == 1) return colors[0];

        for (var i:int = 0; i < l; i++) {
            r += red(colors[i]);
            g += green(colors[i]);
            b += blue(colors[i]);
        }
        return toHex(int(r / l), int(g / l), int(b / l))
    }

}
}