import { UtilLog } from '@hw-agconnect/util-log';
import { image } from '@kit.ImageKit';

export class ImageUtil {
  public static async getPixmapFromMedia(ctx: Context, resource: Resource) {
    let pixelMap: image.PixelMap | undefined = undefined;
    try {
      let unit8Array = ctx.resourceManager.getMediaContentSync(resource.id);

      let imageSource = image.createImageSource(unit8Array.buffer.slice(0, unit8Array.buffer.byteLength));
      pixelMap = await imageSource.createPixelMap({
        desiredPixelFormat: image.PixelMapFormat.RGBA_8888,
      });
      await imageSource.release();
    } catch (e) {
      UtilLog.error(`getPixmapFromMedia failed with error ${JSON.stringify(e)}`);
    }
    return pixelMap;
  }
}