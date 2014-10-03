
package {
public class SmoothMapping extends Mapping {

    public function SmoothMapping(palette:Array = null, size:int = 0) {
        super(palette, size);
    }

    override public function map(re:Number, im:Number, zz:Number, n:int):uint {
        var p:Number = 1.005 - ((Math.log(Math.log(Math.sqrt(zz)))) / log2);
        var n1:int = Math.floor(n + p);
        var n2:int = Math.ceil(n + p);
        var p1:Number = (n + p) % n1;
        return ColorUtil.blend(color(n1), color(n2), p1);
    }

}
}
