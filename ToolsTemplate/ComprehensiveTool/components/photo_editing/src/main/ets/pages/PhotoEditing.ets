import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { getInstance, setPathStack } from '../util/RouteModule';
import { PRESETS } from '../constant/Presets';
import { CustomFilter } from '../model/CustomFilter';
import { BeautyParam } from '../model/PageParams';

@Builder
export function PhotoEditingBuilder() {
  PhotoEditing();
}

@ComponentV2
export struct PhotoEditing {
  @Local photoSelectOptions: photoAccessHelper.PhotoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
  @Local photoViewPicker: photoAccessHelper.PhotoViewPicker = new photoAccessHelper.PhotoViewPicker();

  aboutToAppear(): void {
    this.photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    this.photoSelectOptions.isEditSupported = false;
    this.photoSelectOptions.maxSelectNumber = 1;
  }

  beautyRouterByIndex(index: number, filterName?: string) {
    try {
      // 选择图片并获取图片URI
      this.photoViewPicker.select(this.photoSelectOptions)
        .then((result: photoAccessHelper.PhotoSelectResult) => {
          if (result.photoUris.length > 0) {
            let param: BeautyParam = {
              uris: result.photoUris,
              barIndex: index,
              filterName: filterName,
            };
            getInstance().pushPathByName('PictureBeautification', param);
          }
        })
        .catch((err: BusinessError) => {
          console.error(`PhotoViewPicker.select failed with err: ${err.code}, ${err.message}`);
        });
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      console.error(`PhotoViewPicker failed with err: ${err.code}, ${err.message}`);
    }
  }

  build() {
    NavDestination() {
      Column({ space: 12 }) {
        Row({ space: 8 }) {
          Image($r('app.media.ic_editing')).size({ height: 48, width: 48 });
          Text('开始修图').fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_on_primary'));
        }
        .onClick(() => {
          this.beautyRouterByIndex(-1);
        })
        .padding(24)
        .borderRadius(16)
        .backgroundColor($r('sys.color.multi_color_aux_01'))
        .width('100%')
        .height(104)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center);

        Row({ space: 8 }) {
          Column({ space: 6 }) {
            Image($r('app.media.ic_camera_beautify')).size({ height: 48, width: 48 });
            Text('相机').fontSize(14).fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_on_primary'));
          }
          .height(104)
          .borderRadius(16)
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .backgroundColor($r('sys.color.multi_color_aux_02'))
          .onClick(() => {
            getInstance().pushPathByName('FilteredCamera', null);
          });

          Column({ space: 6 }) {
            Image($r('app.media.ic_collage')).size({ height: 48, width: 48 });
            Text('拼图').fontSize(14).fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_on_primary'));
          }
          .height(104)
          .borderRadius(16)
          .justifyContent(FlexAlign.Center)
          .layoutWeight(1)
          .backgroundColor($r('sys.color.multi_color_aux_05'))
          .onClick(() => {
            getInstance().pushPathByName('CollagePage', null);
          });

          Column({ space: 6 }) {
            Image($r('app.media.ic_photo_frame')).size({ height: 48, width: 48 });
            Text('相框').fontSize(14).fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_on_primary'));
          }
          .height(104)
          .borderRadius(16)
          .justifyContent(FlexAlign.Center)
          .layoutWeight(1)
          .backgroundColor($r('sys.color.multi_color_aux_07'))
          .onClick(() => {
            try {
              this.photoViewPicker.select(this.photoSelectOptions)
                .then((result: photoAccessHelper.PhotoSelectResult) => {
                  if (result.photoUris.length > 0) {
                    getInstance().pushPathByName('PhotoFramePage', result.photoUris[0]);
                  }
                })
                .catch((err: BusinessError) => {
                  console.error(`PhotoViewPicker.select failed with err: ${err.code}, ${err.message}`);
                });
            } catch (error) {
              let err: BusinessError = error as BusinessError;
              console.error(`PhotoViewPicker failed with err: ${err.code}, ${err.message}`);
            }
          });
        }.width('100%');

        Text('热门滤镜').fontSize(18).fontWeight(FontWeight.Bold).width('100%').textAlign(TextAlign.Start);

        Grid() {
          ForEach(PRESETS.filter(item => item.isHot), (item: CustomFilter) => {
            GridItem() {
              Stack({ alignContent: Alignment.Bottom }) {
                Image(item.image).height(138).width('100%').borderRadius(16);
                Text(item.name)
                  .padding({ bottom: 12 })
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_on_primary'));
              }.onClick(() => {
                this.beautyRouterByIndex(2, item.name);
              });
            };
          }, (item: CustomFilter) => item.name);
        }.columnsTemplate('1fr 1fr 1fr').columnsGap(8).rowsGap(8);
      }.width('100%').height('100%').padding(16);
    }.title('修图神器').onReady((ctx) => {
      setPathStack(ctx.pathStack);
    });
  }
}