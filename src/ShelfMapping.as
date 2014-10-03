package {
public class ShelfMapping extends Mapping {

    public function ShelfMapping(palette:Array = null, size:int = 0) {
        super(palette, size);
    }

    override public function map(re:Number, im:Number, zz:Number, n:int):uint {
        var p:Number = ((Math.log(Math.log(zz))) / log2) * 6;
        var n1:int = Math.floor(n + p);
        var n2:int = Math.ceil(n + p);
        var p1:Number = (n + p) % n1;
        return ColorUtil.blend(color(n1), color(n2), p1);
    }

}
}
