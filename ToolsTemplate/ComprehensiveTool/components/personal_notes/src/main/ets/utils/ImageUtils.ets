import { UtilLog } from '@hw-agconnect/util-log';
import { image } from '@kit.ImageKit';
import { WindowUtil } from './WindowUtil';

export class ImageUtils {
  /**
   * Read the screenshot PixelMap object into the buffer area
   * @param {PixelMap} pixelMap - Screenshot PixelMap
   * @param {number[]} scrollYOffsets - Component scrolls an array of y-axis offsets
   * @param {number} listWidth - List component width
   * @param {number} listHeight - List component height
   * @returns {image.PositionArea} Picture buffer area
   */
  // [Start get_snapshot_area]
  static async getSnapshotArea(pixelMap: PixelMap, scrollYOffsets: number[], listWidth: number,
    listHeight: number): Promise<image.PositionArea> {
    // Gets the number of bytes per line of image pixels.
    let stride = pixelMap.getBytesNumberPerRow();
    // Get the total number of bytes of image pixels.
    let bytesNumber = pixelMap.getPixelBytesNumber();
    let buffer: ArrayBuffer = new ArrayBuffer(bytesNumber);
    // 	Region size, read based on region.   PositionArea represents the data within the specified area of the image.
    let len = scrollYOffsets.length;

    // // Except for the first screenshot, you don't need to crop it, and you need to crop the new parts
    if (scrollYOffsets.length >= 2) {
      // Realistic roll distance
      let realScrollHeight = scrollYOffsets[len-1] - scrollYOffsets[len-2];
      if (listHeight - realScrollHeight > 0) {
        let cropRegion: image.Region = {
          x: 0,
          y: WindowUtil.uiContext.vp2px(listHeight - realScrollHeight),
          size: {
            height: WindowUtil.uiContext.vp2px(realScrollHeight),
            width: WindowUtil.uiContext.vp2px(listWidth)
          }
        };
        // Crop roll area
        await pixelMap.crop(cropRegion);
      }
    }

    let imgInfo = pixelMap.getImageInfoSync();
    // Region size, read based on region. PositionArea represents the data within the specified area of the image.
    let area: image.PositionArea = {
      pixels: buffer,
      offset: 0,
      stride: stride,
      region: {
        size: {
          width: imgInfo.size.width,
          height: imgInfo.size.height
        },
        x: 0,
        y: 0
      }
    }
    // Write data to a specified area
    pixelMap.readPixelsSync(area);
    return area;
  }
  // [End get_snapshot_area]

  /**
   * Merge image area array into long screenshots
   * @param {image.PositionArea[]} areaArray - screenshot area
   * @param {number} lastOffsetY - The offset Y of the last screenshot
   * @param {number} listWidth - List component width
   * @param {number} listHeight - List component height
   * @returns {PixelMap} Long image after merge
   */
  // [Start merge_image]
  static async mergeImage(areaArray: image.PositionArea[], lastOffsetY: number, listWidth: number,
    listHeight: number): Promise<PixelMap | undefined> {
    // Create a long screenshot PixelMap
    let opts: image.InitializationOptions = {
      editable: true,
      pixelFormat: 4,
      size: {
        width: WindowUtil.uiContext.vp2px(listWidth),
        height: WindowUtil.uiContext.vp2px(lastOffsetY + listHeight)
      }
    };

    try {
      let longPixelMap = image.createPixelMapSync(opts);
      let imgPosition: number = 0;

      for (let i = 0; i < areaArray.length; i++) {
        let readArea = areaArray[i];
        let area: image.PositionArea = {
          pixels: readArea.pixels,
          offset: 0,
          stride: readArea.stride,
          region: {
            size: {
              width: readArea.region.size.width,
              height: readArea.region.size.height
            },
            x: 0,
            y: imgPosition
          }
        }
        imgPosition += readArea.region.size.height;
        longPixelMap.writePixelsSync(area);
      }
      return longPixelMap;
    } catch (e) {
      UtilLog.error(`mergeImage failed with error ${JSON.stringify(e)}`)
      return undefined;
    }
  }
  // [End merge_image]
}