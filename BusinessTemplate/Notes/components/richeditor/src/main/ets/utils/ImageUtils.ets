/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { image } from '@kit.ImageKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

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
  static async getSnapshotArea(_uiContext: UIContext, pixelMap: PixelMap, scrollYOffsets: number[], _listWidth: number,
    listHeight: number): Promise<image.PositionArea> {
    const len = scrollYOffsets.length;

    if (len >= 2 && listHeight > 0) {
      const imgBefore = pixelMap.getImageInfoSync();
      const snapW = imgBefore.size.width;
      const snapH = imgBefore.size.height;
      if (snapH > 0 && snapW > 0) {
        const realScrollHeightVp = scrollYOffsets[len - 1] - scrollYOffsets[len - 2];
        if (listHeight - realScrollHeightVp > 0) {
          const realScrollPx = Math.min(snapH, Math.max(1, Math.round((realScrollHeightVp / listHeight) * snapH)));
          const cropY = Math.max(0, snapH - realScrollPx);
          const cropH = Math.min(realScrollPx, snapH - cropY);
          if (cropH > 0 && cropY < snapH) {
            const cropRegion: image.Region = {
              x: 0,
              y: cropY,
              size: {
                height: cropH,
                width: snapW,
              },
            };
            await pixelMap.crop(cropRegion);
          }
        }
      }
    }

    const stride = pixelMap.getBytesNumberPerRow();
    const bytesNumber = pixelMap.getPixelBytesNumber();
    const buffer: ArrayBuffer = new ArrayBuffer(bytesNumber);
    const imgInfo = pixelMap.getImageInfoSync();
    const area: image.PositionArea = {
      pixels: buffer,
      offset: 0,
      stride: stride,
      region: {
        size: {
          width: imgInfo.size.width,
          height: imgInfo.size.height,
        },
        x: 0,
        y: 0,
      },
    };
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

  static async mergeImage(_uiContext: UIContext, areaArray: image.PositionArea[], _lastOffsetY: number,
    _listWidth: number, _listHeight: number): Promise<PixelMap> {
    if (!areaArray || areaArray.length === 0) {
      throw new Error('mergeImage: areaArray 为空');
    }
    let outW = 0;
    let sumH = 0;
    for (let i = 0; i < areaArray.length; i++) {
      const ra = areaArray[i];
      const w = ra.region.size.width;
      const h = ra.region.size.height;
      if (w > outW) {
        outW = w;
      }
      sumH += h;
    }
    if (outW <= 0 || sumH <= 0) {
      throw new Error(`mergeImage: 无效输出尺寸 width=${outW} height=${sumH}`);
    }

    const opts: image.InitializationOptions = {
      editable: true,
      pixelFormat: 4,
      size: {
        width: outW,
        height: sumH,
      },
    };

    let longPixelMap: PixelMap | null = null;
    try {
      longPixelMap = image.createPixelMapSync(opts);
    } catch (err) {
      hilog.error(0x0000, 'ImageUtils', `createPixelMapSync失败: ${(err as Error).message}`);
      throw new Error(`创建长截图失败: ${(err as Error).message}`);
    }
    if (longPixelMap === null) {
      throw new Error('创建长截图失败');
    }

    let imgPosition = 0;
    for (let i = 0; i < areaArray.length; i++) {
      const readArea = areaArray[i];
      const area: image.PositionArea = {
        pixels: readArea.pixels,
        offset: 0,
        stride: readArea.stride,
        region: {
          size: {
            width: readArea.region.size.width,
            height: readArea.region.size.height,
          },
          x: 0,
          y: imgPosition,
        },
      };
      imgPosition += readArea.region.size.height;
      longPixelMap.writePixelsSync(area);
    }
    return longPixelMap;
  }

  // [End merge_image]
}