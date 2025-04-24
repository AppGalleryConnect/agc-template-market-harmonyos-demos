import { picker } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { filePreview } from '@kit.PreviewKit';
import { GlobalRegister, Logger } from '@ohos_agcit/office_attendance_common_lib';

const TAG: string = 'AttachUpload';

@ComponentV2
export struct AttachUpload {
  scroller: Scroller = new Scroller()
  @Consumer() fullPathImages: Array<string> = [];
  @Event onImageChange: (images: Array<string>) => void = (images: Array<string>) => {
  };
  addImages = (images: Array<string>) => {
    images.forEach((item: string) => {
      if (!this.fullPathImages.includes(item)) {
        this.fullPathImages.push(item);
      }
    })
    this.onImageChange(this.fullPathImages);
  }

  delete(name: string) {
    this.fullPathImages = this.fullPathImages.filter(n => n !== name)
    this.onImageChange(this.fullPathImages);
  }

  getImageName(item: string) {
    return item.substring(item.lastIndexOf('/') + 1);
  }

  addAttach(): void {
    try {
      let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 5;
      let photoPicker = new photoAccessHelper.PhotoViewPicker();
      photoPicker.select(photoSelectOptions).then((photoSelectResult: picker.PhotoSelectResult) => {
        this.addImages(photoSelectResult.photoUris);
      }).catch((err: BusinessError) => {
        Logger.error(TAG, `'PhotoViewPicker.select failed with err: ${JSON.stringify(err)}`);
      });
    } catch (err) {
      Logger.error(TAG, `'PhotoViewPicker failed with err: ${JSON.stringify(err)}`);
    }
  }

  preview(imageUri: string) {
    let uiContext = GlobalRegister.getContext();
    let uri: string = imageUri;
    let displayInfo: filePreview.DisplayInfo = {
      x: 100,
      y: 100,
      width: 800,
      height: 800
    };
    let name = this.getImageName(imageUri);
    let extend: string = name.substring(name.lastIndexOf('.') + 1);
    if (extend === 'jpg') {
      extend = 'jpeg';
    }
    let fileInfo: filePreview.PreviewInfo = {
      title: name,
      uri: uri,
      mimeType: 'image/' + extend
    };
    filePreview.canPreview(uiContext, imageUri).then((result) => {
      console.info(`canPreview result=${result}`);
      if (result) {
        filePreview.openPreview(uiContext, fileInfo, displayInfo).then(() => {
          console.info('Succeeded in opening preview');
        }).catch((err: BusinessError) => {
          console.error(`Failed to open preview, err.code = ${err.code}, err.message = ${err.message}`);
        });
      }
    })
  }

  build() {
    Column() {
      Row() {
        Row() {
          Text($r('app.string.attach')).fontSize(16).fontWeight(FontWeight.Medium)
        }.width('50%')
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Start)

        Row() {
          Text($r('app.string.select_add_attach'))
            .fontColor('#3093FA')
            .fontSize(14)
            .fontWeight(FontWeight.Regular)
            .onClick(() => {
              this.addAttach();
            })
        }
        .layoutWeight(1)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.End)
      }.width('100%')
      .height(48)
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)

      Divider().width('100%').height(1)

      Scroll(this.scroller) {
        List({ space: 8 }) {
          ForEach(this.fullPathImages, (img: string) => {
            ListItem() {
              Row() {
                Row() {
                  Text(this.getImageName(img)).fontSize(16)
                }.justifyContent(FlexAlign.Start)
                .padding({ left: 12 })
                .width('80%')
                .onClick(() => {
                  this.preview(img);
                })

                Row() {
                  Image($r('app.media.ic_delete'))
                    .height(16)
                    .width(16)
                }.justifyContent(FlexAlign.End)
                .padding({ right: 12 })
                .layoutWeight(1)
                .onClick(() => {
                  this.delete(img);
                })
              }
              .width('100%')
              .height(30)
              .justifyContent(FlexAlign.SpaceBetween)
            }.width('100%')
          })
        }.width('100%')
        .constraintSize({ maxHeight: 100 })
      }
    }.width('100%')
    .height(152)
    .backgroundColor(Color.White)
  }
}