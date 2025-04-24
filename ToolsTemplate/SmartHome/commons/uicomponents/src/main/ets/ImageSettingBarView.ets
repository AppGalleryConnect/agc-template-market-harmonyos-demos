import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { SettingBarView } from './SettingBarView';

@ComponentV2
export struct ImageSettingBarView {
  @Require @Param startImage: ResourceStr = '';
  @Require @Param name: string = '';
  @Require @Param value: ResourceStr = '';
  @Require @Param valueChangeCb: (value: ResourceStr) => void;

  @Builder
  BuildValue() {
    Column() {
      Image(this.value)
        .borderRadius(100);
    }
    .height(30)
    .width(30);
  }

  async choose() {
    try {
      // 设置图片选择器选项
      const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      // 限制只能选择一张图片
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 1;
      // 创建并实例化图片选择器
      const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
      // 选择图片并获取图片URI
      let uris: photoAccessHelper.PhotoSelectResult = await photoViewPicker.select(photoSelectOptions);
      if (!uris || uris.photoUris.length === 0) {
        return;
      }
      this.valueChangeCb(uris.photoUris[0]);
    } catch (error) {
    }
  }

  build() {
    SettingBarView({
      startImage: this.startImage,
      name: this.name,
      value: () => {
        this.BuildValue();
      },
    })
      .onClick(() => {
        this.choose();
      });
  }
}