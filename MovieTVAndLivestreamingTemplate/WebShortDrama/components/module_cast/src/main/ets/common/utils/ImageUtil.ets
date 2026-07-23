import { image } from '@kit.ImageKit';
import { window } from '@kit.ArkUI';

const windowStage: window.WindowStage = AppStorage.get('windowStage')!

export class ImageUtil {
  public static async getPixmapFromMedia(resource: Resource) {
    try {
      let unit8Array =
        await windowStage.getMainWindowSync()
          .getUIContext()
          .getHostContext()!.resourceManager?.getMediaContent(resource.id)
      let imageSource = image.createImageSource(unit8Array.buffer.slice(0, unit8Array.buffer.byteLength));
      let pixelMap: image.PixelMap = await imageSource.createPixelMap({
        desiredPixelFormat: image.PixelMapFormat.RGBA_8888
      });
      await imageSource.release();
      return pixelMap;
    } catch (e) {
      return null;
    }
  }
}