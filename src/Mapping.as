
package {
public class Mapping {
    public var log2:Number = Math.log(2);

    public static const LINEAR:int = 0;
    public static const SQR:int = 1;
    public static const SQR_ROOT:int = 3;
    public static const CUBE:int = 2;
    public static const LOG:int = 5;
    public static const EXP:int = 6;

    private var _transfer:int = LINEAR;
    protected var _palette:Array;
    protected var _size:int = 200;
    private var _cycle:Boolean = true;
    private var _mapping:Array = [];

    public function Mapping(palette:Array = null, size:int = 0) {
        if (size > 0) _size = size;
        if (!palette) this.palette = [0xFF010101, 0xFFFFFFFF];
    }

    public function color(i:int):uint {
        var idx:Number = Math.round(transfer(i));

        if (_transfer > 2) {
            var c1 = _mapping[int(idx) % _size];
            var c2 = _mapping[(int(idx) + 1) % _size];
            return ColorUtil.blend(c1, c2, idx - int(idx));
        } else {
            return _mapping[int(idx) % _size];
        }
    }

    public function map(r:Number, i:Number, zz:Number, n:int):uint {
        return _mapping[n % _size];
    }

    private function generateMap():void {
        var steps:int = _size / (_palette.length + (_cycle ? 1 : -1));
        var i:int;
        _mapping = [];

        for (i = 1; i < _palette.length; i++) {
            _mapping = _mapping.concat(ColorUtil.blendArray(_palette[i - 1], _palette[i], (steps - 1), false));
        }

        if (_cycle) {
            steps = _size - _mapping.length;
            _mapping = _mapping.concat(ColorUtil.blendArray(_palette[i - 1], _palette[0], (steps - 1), false));
        }
    }

    public function get palette():Array {
        return _palette;
    }

    public function set palette(value:Array):void {
        _palette = value;
        generateMap();
    }

    protected function transfer(value:int):Number {
        switch (_transfer) {
            case LINEAR:
                return value;
            case SQR:
                return value * value;
            case SQR_ROOT:
                return Math.sqrt(value);
            case CUBE:
                return Math.pow(value, 3);
            case CUBE:
                return Math.pow(value, 1 / 3);
            case EXP:
                return Math.exp(value);
            case LOG:
                return Math.log(value);
            default:
                return value;
        }
    }

}
}
