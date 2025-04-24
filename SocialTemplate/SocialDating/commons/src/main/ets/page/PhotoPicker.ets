import {
  PhotoPickerComponent,
  PickerController,
  PickerOptions,
  DataType,
  BaseItemInfo,
  ItemInfo,
  PhotoBrowserInfo,
  ItemType,
  ClickType,
  PhotoBrowserRange
} from '@ohos.file.PhotoPickerComponent';
import { photoAccessHelper } from '@kit.MediaLibraryKit';

@Builder
export function PhotoPickerBuilder() {
  PhotoPicker()
}

@Component
export struct PhotoPicker {
  @Consume('pageStack') pageStack: NavPathStack;
  pickerOptions: PickerOptions = new PickerOptions();
  @State pickerController: PickerController = new PickerController();
  @State selectUris: Array<string> = [];
  @State currentUri: string = '';
  @State isBrowserShow: boolean = false;

  aboutToAppear() {
    this.pickerOptions.maxSelectNumber = 1;
    this.pickerOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_VIDEO_TYPE;
    let params: PhotoPickerPageParam[] = this.pageStack.getParamByName('CommonPhotoPicker') as PhotoPickerPageParam[];
    if (params.length >= 1 && params[0] != null) {
      this.pickerOptions.maxSelectNumber = params[0].maxSelectNumber;
      if (params[0].mimeType !== undefined) {
        this.pickerOptions.MIMEType = params[0].mimeType;
      }
    }
    this.pickerOptions.isSearchSupported = true;
    this.pickerOptions.isPhotoTakingSupported = false;
    this.pickerOptions.checkBoxColor = '#C103A1F5';
  }

  build() {
    NavDestination() {
      Flex({
        direction: FlexDirection.Column,
        justifyContent: FlexAlign.Center,
        alignItems: ItemAlign.Center
      }) {
        PhotoPickerComponent({
          pickerOptions: this.pickerOptions,
          onItemClicked: (itemInfo: ItemInfo, clickType: ClickType): boolean => this.onItemClicked(itemInfo,
            clickType),
          onEnterPhotoBrowser: (photoBrowserInfo: PhotoBrowserInfo): boolean =>
          this.onEnterPhotoBrowser(photoBrowserInfo),
          onExitPhotoBrowser: (photoBrowserInfo: PhotoBrowserInfo): boolean =>
          this.onExitPhotoBrowser(photoBrowserInfo),
          onPickerControllerReady: (): void => this.onPickerControllerReady(),
          onPhotoBrowserChanged: (browserItemInfo: BaseItemInfo): boolean =>
          this.onPhotoBrowserChanged(browserItemInfo),
          pickerController: this.pickerController,
        }).height('60%').width('100%')

        Row() {
          Blank().height('5%')
        }

        if (this.isBrowserShow) {
          Row() {
            ForEach(this.selectUris, (uri: string) => {
              if (uri === this.currentUri) {
                Image(uri)
                  .height('10%')
                  .width('10%')
                  .onClick(() => {
                  })
                  .borderWidth(1)
                  .borderColor('red')
              } else {
                Image(uri).height('10%').width('10%').onClick(() => {
                  this.pickerController.setData(DataType.SET_SELECTED_URIS, this.selectUris);
                  this.pickerController.setPhotoBrowserItem(uri, PhotoBrowserRange.ALL);
                })
              }
            }, (uri: string) => uri)
          }
        } else {
          Row() {
            Button('预览')
              .width('33%')
              .height('5%')
              .backgroundColor($r('app.color.button_background_color'))
              .onClick(() => {
                if (this.selectUris.length > 0) {
                  this.pickerController.setPhotoBrowserItem(this.selectUris[0], PhotoBrowserRange.SELECTED_ONLY);
                }
              })
            Blank().width('20%')
            Button('确定')
              .width('33%')
              .height('5%')
              .backgroundColor($r('app.color.button_background_color'))
              .onClick(() => {
                this.pageStack.pop(this.selectUris, true)
              })
          }
        }
      }
    }.onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack;
    })
  }

  private onItemClicked(itemInfo: ItemInfo, clickType: ClickType): boolean {
    if (!itemInfo) {
      return false;
    }
    let type: ItemType | undefined = itemInfo.itemType;
    let uri: string | undefined = itemInfo.uri;
    if (type === ItemType.CAMERA) {
      // 点击相机item
      return true;
    } else {
      if (clickType === ClickType.SELECTED) {
        if (uri) {
          this.selectUris.push(uri);
          this.pickerOptions.preselectedUris = [...this.selectUris];
        }
        return true;
      } else {
        if (uri) {
          this.selectUris = this.selectUris.filter((item: string) => {
            return item !== uri;
          });
          this.pickerOptions.preselectedUris = [...this.selectUris];
        }
      }
      return true;
    }
  }

  private onEnterPhotoBrowser(photoBrowserInfo: PhotoBrowserInfo): boolean {
    this.isBrowserShow = true;
    return true;
  }

  private onExitPhotoBrowser(photoBrowserInfo: PhotoBrowserInfo): boolean {
    this.isBrowserShow = false;
    return true;
  }

  private onPickerControllerReady(): void {
    // 接收到该回调后，便可通过pickerController相关接口向picker发送数据，在此之前不生效。
  }

  private onPhotoBrowserChanged(browserItemInfo: BaseItemInfo): boolean {
    // 大图左右滑动的回调
    this.currentUri = browserItemInfo.uri ?? '';
    return true;
  }
}

export class PhotoPickerPageParam {
  maxSelectNumber: number
  mimeType?: photoAccessHelper.PhotoViewMIMETypes

  constructor(maxSelectNumber: number, mimeType?: photoAccessHelper.PhotoViewMIMETypes) {
    this.maxSelectNumber = maxSelectNumber;
    if (mimeType !== undefined) {
      this.mimeType = mimeType;
    }
  }
}
