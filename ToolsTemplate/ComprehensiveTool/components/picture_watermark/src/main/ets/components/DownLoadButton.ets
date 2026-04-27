import { image } from '@kit.ImageKit';
import { fileIo } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { loading } from './CommonLoading';
import { StyleConstants } from '../constants/Styles';
import { Logger } from '../utils/Logger';
import { PopViewUtils } from '../utils/PopViewUtils';
import { WaterMarksVM } from '../viewmodel/WaterMarksVM';

const TAG = '[DownloadButton]';

class SaveButtonConstant {
  // 背景颜色
  static readonly BG_COLOR: ResourceColor = $r('sys.color.comp_background_emphasize');
  // 按钮高度
  static readonly HEIGHT: Length = 40;
  // 按钮宽度
  static readonly WIDTH: Length = 'calc(50% - 12vp)';
  // 标题字体大小
  static readonly TITLE_SIZE: Resource = $r('sys.float.Body_L');
  // 标题字体颜色
  static readonly FONT_COLOR: ResourceColor = $r('sys.color.font_on_primary');
}

@ComponentV2
export struct DownloadButton {
  vm: WaterMarksVM = WaterMarksVM.instance;

  async save(pixelMap: image.PixelMap) {
    let file: fileIo.File | undefined = undefined;
    try {
      const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(this.getUIContext().getHostContext());
      let suffix = this.vm.suffix;
      if (suffix === 'jpg') {
        suffix = 'jpeg';
      }
      const filePath = await phAccessHelper.createAsset(photoAccessHelper.PhotoType.IMAGE, suffix);
      const imagePacker = image.createImagePacker();
      const imageBuffer = await imagePacker.packToData(pixelMap, { format: `image/${suffix}`, quality: 100 });
      const mode = fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE;
      file = fileIo.openSync(filePath, mode);
      fileIo.writeSync(file.fd, imageBuffer);
      PopViewUtils.closePopView();
      PopViewUtils.showPopView(wrapBuilder(downloaded), { alignment: DialogAlignment.Center }, this.vm.fileName);
    } catch (err) {
      PopViewUtils.closePopView();
      Logger.error(TAG, 'Save failed:' + JSON.stringify(err));
    } finally {
      if (file) {
        fileIo.close(file);
      }
    }
  }

  build() {
    SaveButton({ text: SaveDescription.DOWNLOAD })
      .size({ width: SaveButtonConstant.WIDTH, height: SaveButtonConstant.HEIGHT })
      .fontWeight(FontWeight.Medium)
      .fontSize(SaveButtonConstant.TITLE_SIZE)
      .fontColor(SaveButtonConstant.FONT_COLOR)
      .backgroundColor(SaveButtonConstant.BG_COLOR)
      .onClick(async (event: ClickEvent, result: SaveButtonOnClickResult) => {
        if (result === SaveButtonOnClickResult.SUCCESS && this.vm.pixelMapWithMarks) {
          PopViewUtils.showPopView(wrapBuilder(loading), { alignment: DialogAlignment.Center }, '正在下载...');
          this.save(this.vm.pixelMapWithMarks);
        }
      });
  }
}

@Builder
function downloaded(fileName: string) {
  Column({ space: StyleConstants.SPACE_12 }) {
    Text('下载完成')
      .height(56)
      .fontColor($r('sys.color.font_primary'))
      .fontSize($r('sys.float.Title_S'))
      .fontWeight(FontWeight.Bold)

    Text('已保存至：相册')
      .fontColor($r('sys.color.font_primary'))
      .fontSize($r('sys.float.Body_L'))
      .fontWeight(FontWeight.Medium)

    Text(`文件名：${fileName}`)
      .fontColor($r('sys.color.font_primary'))
      .fontSize($r('sys.float.Body_L'))
      .fontWeight(FontWeight.Medium)

    Text('我知道了')
      .alignSelf(ItemAlign.Center)
      .fontColor($r('sys.color.font_emphasize'))
      .fontSize($r('sys.float.Body_L'))
      .fontWeight(FontWeight.Medium)
      .margin({ top: StyleConstants.SPACE_8 })
      .onClick(() => {
        PopViewUtils.closePopView();
      })
  }
  .justifyContent(FlexAlign.Start)
  .alignItems(HorizontalAlign.Start)
  .width('calc(100% - 32vp)')
  .height(190)
  .padding({ left: StyleConstants.SPACE_24, right: StyleConstants.SPACE_24 })
  .backgroundColor($r('sys.color.comp_background_primary'))
  .borderRadius(StyleConstants.RADIUS_32)
}