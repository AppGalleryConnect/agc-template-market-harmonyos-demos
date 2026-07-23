import { hilog } from '@kit.PerformanceAnalysisKit';
import { image } from '@kit.ImageKit';
import { effectKit } from '@kit.ArkGraphics2D';
import { BusinessError } from '@kit.BasicServicesKit';

export class CommonUtil {
  private static _domain: number = 0xff00;
  private static _prefix: string = 'Theme';
  private static _format: string = '%{public}s, %{public}s';

  public static info(...args: string[]): void {
    hilog.info(CommonUtil._domain, CommonUtil._prefix, CommonUtil._format, args);
  }

  public static error(...args: string[]): void {
    hilog.error(CommonUtil._domain, CommonUtil._prefix, CommonUtil._format, args);
  }

  public static getTimeIntervalIndex(): number {
    const now = new Date();
    const currentHours = now.getHours() + now.getMinutes() / 60 + now.getSeconds() / 3600;
    const intervalSize = 24 / 5;
    return Math.min(Math.floor(currentHours / intervalSize), 4);
  }

  public static getPixelmap(s: Resource): image.PixelMap | null {
    let uiContext: UIContext = AppStorage.get('theme_uiContext') as UIContext
    try {
      const unit8Array = uiContext.getHostContext()!.resourceManager.getMediaContentSync(s.id);
      const imageSource: image.ImageSource =
        image.createImageSource(unit8Array?.buffer.slice(0, unit8Array.buffer.byteLength));
      const info = imageSource.getImageInfoSync();

      let opts: image.DecodingOptions =
        { editable: false, desiredSize: info.size };
      return imageSource.createPixelMapSync(opts);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      CommonUtil.error(`Failed to get pixelmap. Code: ${err.code}, message: ${err.message}`);
      return null;
    }
  }

  public static getLargestColor(pic: image.PixelMap, callback: (res: string) => void) {
    try {
      effectKit.createColorPicker(pic, (error, colorPicker) => {
        if (error) {
          CommonUtil.error('Failed to create color picker.Cause:' + JSON.stringify(error));
        } else {
          CommonUtil.info('Succeeded in creating color picker.');
          const color = colorPicker.getLargestProportionColor();
          const res = `rgba(${color.red},${color.green},${color.blue},${color.alpha / 255})`;
          callback(res);
        }
      });
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      CommonUtil.error(`Failed to create color picker. Code: ${err.code}, message: ${err.message}`);
    }
  }
}