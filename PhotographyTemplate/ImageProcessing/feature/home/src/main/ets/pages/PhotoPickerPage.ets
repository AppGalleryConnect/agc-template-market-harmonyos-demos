import { PhotoPickerComponent, PickerController, PickerOptions,
  ItemInfo, ClickType, ItemType, ReminderMode,
  SelectMode } from '@kit.MediaLibraryKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BaseTitle } from 'commonlib';
import { PhotoType } from '../common/Constants';
import { PhotoPickerPageVM } from '../viewmodels/PhotoPickerPageVM';


@Builder
export function PhotoPickerPageBuilder() {
  PhotoPickerPage();
}

@ComponentV2
export struct PhotoPickerPage {
  vm: PhotoPickerPageVM = new PhotoPickerPageVM()

  aboutToAppear() {
    this.vm.initOptions();
  }

  build() {
    NavDestination() {
      this.pageHeader()
      Scroll() {
        Column() {
          // 直接嵌入PhotoPickerComponent组件
          PhotoPickerComponent({
            pickerOptions: this.vm.pickerOptions,
            onSelect: (uri: string) => {
              this.vm.onSelect(uri);
            },
            onDeselect: (uri: string) => {
              this.vm.onDeselect(uri);
            },
            onItemClicked: (itemInfo: ItemInfo, clickType: ClickType): boolean => {
              return this.vm.onItemClicked(itemInfo, clickType);
            },
            pickerController: this.vm.pickerController
          })
            .width('100%')
            .layoutWeight(1)

          if (this.vm.photoType === PhotoType.Collage) {
            Row() {
              Button({ type: ButtonType.Normal }) {
                Text('开始拼图').fontSize(12).fontColor(Color.White)
              }
              .borderRadius(8)
              .enabled(this.vm.selectUris.length > 1)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .onClick(() => {
                this.vm.handleCollage()
              })
            }
            .width('100%')
            .height(68)
            .padding({
              left: this.vm.breakPointModel.pagePadding,
              right: this.vm.breakPointModel.pagePadding
            })
            .justifyContent(FlexAlign.End)
            .alignItems(VerticalAlign.Top)
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      .align(Alignment.Top)
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .hideTitleBar(true)
  }

  @Builder
  pageHeader() {
    Row() {
      BaseTitle({
        title: '图片选择',
        showBackBtn: true,
        titleFontSize: $r('sys.float.Title_S'),
      })
    }
    .width('100%')
    .padding({
      left: this.vm.breakPointModel.pagePadding,
      right: this.vm.breakPointModel.pagePadding,
    })
  }
}
