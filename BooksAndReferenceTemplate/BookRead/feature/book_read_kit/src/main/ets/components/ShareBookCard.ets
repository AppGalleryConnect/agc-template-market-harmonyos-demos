import { fileIo as fs } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { Logger } from '@hw-agconnect/ui-base';
import { BookInfo, FontModel } from 'common';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { SharePicker } from 'aggregated_share';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct ShareBookCard {
  @Param @Require book: BookInfo;
  @Param isShelf?: boolean = false;
  @Param shareImage?: ResourceStr = $r('app.media.ic_share')
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;
  setShareData() {
    const picker: SharePicker = new SharePicker({
      title: this.book.name,
      coverUrl: typeof this.book.coverUrl === 'string' ? $r(this.book.coverUrl) : this.book.coverUrl,
      thumbUrl: $r('app.media.startIcon'),
      landingPageUrl: `https://linking.xiaobingtang.cn/BookRead?id=${this.book.id}`,
    });

    picker.show({
      autoClose: true,
    });
  }

  async aboutToAppear(): Promise<void> {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    const filesDir = context.filesDir;
    let bookUri = `${this.book.id.toString()}.png`
    // 用图片名称获取资源
    let book = this.book.coverUrl?.toString().substring(10)
    let resUri = context.resourceManager.getMediaByNameSync(book)
    let file = fs.openSync(filesDir + `/${bookUri}`, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
    try {
      let writeLen = fs.writeSync(file.fd, (resUri as Uint8Array).buffer);
      Logger.info('write data to file succeed and size is:' + writeLen);
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      hilog.error(0x0000, 'testTag', 'catch error: %{public}d %{public}s', e.code, e.message);
    } finally {
      fs.closeSync(file);
    }
  }

  build() {
    if (this.isShelf) {
      Column({ space: 5 }) {
        Image($r('app.media.ic_share'))
          .height(24)
          .width(24)
          .margin({ top: 5 })

        Text($r('app.string.share'))
          .fontSize(this.fontModel.getFg(12))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Regular)
      }
      .onClick(() => {
        this.setShareData()
      })
    } else {
      Image(this.shareImage)
        .width(35)
        .height(35)
        .onClick(() => {
          this.setShareData()
        })
    }
  }
}