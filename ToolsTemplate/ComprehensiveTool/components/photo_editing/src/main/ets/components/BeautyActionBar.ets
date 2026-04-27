import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Constants } from '../constant/Constants';
import { CarouseCutToolBar } from './CarouseCutToolBar';
import { FilterToolBar } from './FilterToolBar';
import { AddTextToolBar } from './AddTextToolBar';
import { BeautyParam, ImageShowModel } from '../model/PageParams';
import { StickerToolBar } from './StickerToolBar';
import { IconAndTextView } from './IconAndTextView';
import { getInstance } from '../util/RouteModule';
import { PhotoBeautificationVM } from '../viewmodel/PhotoBeautificationVM';

@ComponentV2
export struct BeautyActionBar {
  vm: PhotoBeautificationVM = PhotoBeautificationVM.instance;

  build() {
    Row() {
      this.allToolsBuilder();

      CarouseCutToolBar().visibility(this.vm.barIndex === 0 ? Visibility.Visible : Visibility.None);
      AddTextToolBar().visibility(this.vm.barIndex === 1 ? Visibility.Visible : Visibility.None);
      FilterToolBar().visibility(this.vm.barIndex === 2 ? Visibility.Visible : Visibility.None);
      StickerToolBar().visibility(this.vm.barIndex === 3 ? Visibility.Visible : Visibility.None);
    }.height(200).alignItems(VerticalAlign.Bottom).backgroundColor($r('sys.color.background_secondary'));
  }

  @Builder
  allToolsBuilder() {
    Row() {
      ForEach(Constants.BAR_LIST, (item: ImageShowModel, index: number) => {
        IconAndTextView({ barItem: item })
          .onClick(() => {
            this.vm.barIndex = index;
          });
      }, (item: ImageShowModel) => JSON.stringify(item));
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .visibility(this.vm.barIndex === -1 ? Visibility.Visible : Visibility.None);
  }

  choosePicture(barIndex: number) {
    try {
      // 设置图片选择器选项
      const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 1;
      // 创建并实例化图片选择器
      const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
      // 选择图片并获取图片URI
      photoViewPicker.select(photoSelectOptions).then((result: photoAccessHelper.PhotoSelectResult) => {
        if (result.photoUris.length > 0) {
          let param: BeautyParam = {
            uris: result.photoUris,
            barIndex: barIndex,
          };
          getInstance().pushPath({ name: 'pictureBeautification', param: param });
        }
      }).catch((err: BusinessError) => {
        console.error(`PhotoViewPicker.select failed with err: ${err.code}, ${err.message}`);
      });
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      console.error(`PhotoViewPicker failed with err: ${err.code}, ${err.message}`);
    }
  }
}