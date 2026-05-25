import { ImageAttachmentSerializer, SerializedImageAttachment } from '../handler/ImageAttachmentSerializer';
import { StyledStringSerializer } from '../handler/StyledStringSerializer';
import { image } from '@kit.ImageKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { util } from '@kit.ArkTS';
import { SerializedMutableStyledString, SerializedStyleOptions } from '../types/Types';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

export class SerializeUtil {
  static async serialize(styledString: MutableStyledString, uiContext: UIContext): Promise<string> {
    const content = styledString.getString();
    const styles: Array<SpanStyle> = styledString.getStyles(0, content.length);

    const options: Array<SerializedStyleOptions> = [];
    for (let style of styles) {
      // 图片类型
      if (style.styledKey === StyledStringKey.IMAGE) {
        const imageAttachment = style.styledValue as ImageAttachment;
        let context = uiContext.getHostContext() as Context;
        let sandboxPath = context.filesDir + '/' + util.generateRandomUUID() + '.png';
        await SerializeUtil.pixelMapToSandBoxFile(imageAttachment.value, sandboxPath);
        options.push({
          start: style.start,
          length: style.length,
          styledKey: style.styledKey,
          styledValue: ImageAttachmentSerializer.serialize(imageAttachment, sandboxPath, uiContext),
        });
        continue;
      }

      // 其他类型
      options.push({
        start: style.start,
        length: style.length,
        styledKey: style.styledKey,
        styledValue: StyledStringSerializer.serialize(style.styledKey, style.styledValue),
      });
    }

    // obj转string
    const obj: SerializedMutableStyledString = {
      content: styledString.getString(),
      options: options,
    };
    return JSON.stringify(obj);
  }

  static async deserialize(data: string): Promise<MutableStyledString> {
    // string转obj
    const obj: SerializedMutableStyledString = JSON.parse(data) as SerializedMutableStyledString;
    const styleOptions: Array<StyleOptions> = [];
    const imageOptions: Array<StyleOptions> = [];

    for (let option of obj.options) {
      // 图片类型
      if (option.styledKey === StyledStringKey.IMAGE) {
        const serializedImageAttachment = option.styledValue as SerializedImageAttachment;

        imageOptions.push({
          start: option.start,
          length: option.length,
          styledKey: option.styledKey,
          styledValue: ImageAttachmentSerializer.deserialize(serializedImageAttachment),
        });
        continue;
      }
      // 其他类型
      styleOptions.push({
        start: option.start,
        length: option.length,
        styledKey: option.styledKey,
        styledValue: StyledStringSerializer.deserialize(option.styledValue, option.styledKey),
      });
    }

    let mss = new MutableStyledString(obj.content, styleOptions);
    // 添加图片
    for (let imageOption of imageOptions) {
      mss.insertStyledString(imageOption.start, new MutableStyledString(imageOption.styledValue as ImageAttachment));
    }
    return mss;
  }

  private static async pixelMapToSandBoxFile(pixelMap: image.PixelMap, pngPath: string): Promise<void> {
    let fd: number | null = null;
    const imagePacker = image.createImagePacker();

    imagePacker.packToData(pixelMap, {
      format: 'image/png',
      quality: 100,
    })
      .then((data: ArrayBuffer) => {
        const mode = fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE;
        try {
          fd = fs.openSync(pngPath, mode).fd;
          fs.truncateSync(fd);
          fs.writeSync(fd, data);
        } finally {
          fs.close(fd);
        }
      }).catch((error: BusinessError) => {
      hilog.error(0x0000, 'SerializeUtil',
        `Failed to pack the image.code ${error.code},message is ${error.message}`);
    });
  }
}