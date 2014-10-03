package {
public class Decomposition extends Mapping {
    public function Decomposition(palette:Array = null, size:int = 0) {
        super(palette, size);
    }

    override public function map(re:Number, im:Number, zz:Number, n:int):uint {
        return Math.atan2(im, re) > 0 ? 0xFFFFFFFF : 0xFF000000;
    }


}
}
