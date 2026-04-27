export class MakerCanvasUtil {
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private offCanvas: OffscreenCanvas = new OffscreenCanvas(200, 32);

  getMakerIcon(text: string): PixelMap {
    let offContext: OffscreenCanvasRenderingContext2D = this.offCanvas.getContext('2d', this.settings);

    offContext.clearRect(0, 0, 100, 32);

    let radius = 8; //圆角弧度
    let x = 0; //左上角坐标x
    let y = 0; //左上角坐标y
    let width = 100; //矩形宽
    let height = 32; //矩形高
    offContext.fillStyle = 'rgb(10, 89, 247)';
    offContext.strokeStyle = 'rgb(10, 89, 247)';
    offContext.beginPath();
    offContext.moveTo(x + radius, y);
    offContext.lineTo(x + width - radius, y);
    offContext.arcTo(x + width, y, x + width, y + radius, radius);
    offContext.lineTo(x + width, y + height - radius);
    offContext.arcTo(x + width, y + height, x + width - radius, y + height, radius);
    offContext.lineTo(x + radius, y + height);
    offContext.arcTo(x, y + height, x, y + height - radius, radius);
    offContext.lineTo(x, y + radius);
    offContext.arcTo(x, y, x + radius, y, radius);
    offContext.stroke();
    offContext.fill();
    offContext.save();
    offContext.closePath();

    offContext.font = '12vp sans-serif';
    offContext.textAlign = 'center';
    offContext.textBaseline = 'middle';
    offContext.fillStyle = '#ffffff';
    offContext.fillText(text, 50, 16, 100);
    offContext.restore();
    let iconPixelMap = offContext.getPixelMap(0, 0, 100, 32);
    return iconPixelMap;
  }
}