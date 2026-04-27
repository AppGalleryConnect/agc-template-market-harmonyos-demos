import { LoadingDialog } from '@kit.ArkUI';
import { NavTitle } from '../components/NavTitle';
import { setPathStack } from '../util/Route';
import { toastUtil } from '../util/ToastUtil';
import { CredentialsPageVM } from '../viewModels/CredentialsPageVM';
import { PhotoTypeItem, PickerItem } from '../model/Index';



@Builder
export function CredentialsPageBuilder() {
  CredentialsPage();
}

@ComponentV2
export struct CredentialsPage {
  loadingController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({
      content: '图片处理中...',
    }),
  });
  private vm: CredentialsPageVM = CredentialsPageVM.instance;
  private uiContext: Context | undefined = this.getUIContext().getHostContext();
  private dialogId: number = -1;

  aboutToAppear(): void {
    this.vm.showLoading = this.showLoading;
    this.vm.closeLoading = this.closeLoading;
  }

  @Builder
  photoTypeBuilder() {
    Column({ space: 16 }) {
      Column() {
        ForEach(this.vm.pickerList, (item: PickerItem, index: number) => {
          Row({ space: 16 }) {
            Image(item.icon).width(24);
            Row() {
              Column() {
                Row() {
                  Text(item.text)
                    .fontColor($r('sys.color.font_primary'))
                    .fontSize($r('sys.float.Subtitle_M'))
                    .fontWeight(FontWeight.Medium);
                  Image($r('app.media.ic_picker_right')).width(12);
                }.width('100%').justifyContent(FlexAlign.Center).height(55).justifyContent(FlexAlign.SpaceBetween);

                Divider();
              }.justifyContent(FlexAlign.SpaceBetween);
            }.layoutWeight(1).onClick(() => {
              if (index === 0) {
                this.vm.selectPhoto();
              } else {
                if (this.uiContext) {
                  this.vm.takePhoto(this.uiContext);
                }
              }
              this.closeDialog();

            });
          };

        }, (item: PickerItem, index: number) => item.text);
      };

      Text('取消')
        .height(40)
        .width(144)
        .textAlign(TextAlign.Center)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Medium)
        .onClick(() => {
          this.closeDialog();
        });

    }
    .padding({
      left: 24,
      right: 24,
      bottom: 16,
      top: 24,
    });
  }

  async openDialog() {
    this.dialogId = await this.getUIContext().getPromptAction().openCustomDialog({
      builder: () => {
        this.photoTypeBuilder();
      },
      alignment: DialogAlignment.Center,
    });
  }

  closeDialog() {
    this.getUIContext().getPromptAction().closeCustomDialog(this.dialogId);
  }

  build() {
    NavDestination() {
      NavTitle({ text: '证件照' });
      Column() {
        Grid() {
          ForEach(this.vm.photoTypeList, (item: PhotoTypeItem, index) => {
            GridItem() {
              Row() {
                Column() {
                  Text(item.label)
                    .fontSize($r('sys.float.Body_M'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'));
                  Text(`${item.size.width}*${item.size.height}mm`)
                    .fontSize($r('sys.float.Body_M'))
                    .fontWeight(FontWeight.Regular)
                    .fontColor($r('sys.color.font_tertiary'));
                }.alignItems(HorizontalAlign.Start).height('100%').justifyContent(FlexAlign.SpaceBetween);

                Image($r('app.media.ic_credentials_photo')).width(48);
              }.padding(16).width('100%').justifyContent(FlexAlign.SpaceBetween);
            }.height(80)
            .borderRadius(16)
            .backgroundColor($r('sys.color.comp_background_primary'))
            .onClick(() => {
              this.openDialog();
              this.vm.photoTypeIndex = index;
            });

          }, (item: PhotoTypeItem, index) => item.label);

        }.layoutWeight(1)
        .columnsTemplate('1fr 1fr')
        .columnsGap(12)
        .rowsGap(24);
      }.layoutWeight(1).width('100%').padding({ left: 16, right: 16, top: 8 });

    }.hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
    .onReady((ctx) => {
      setPathStack(ctx.pathStack);
      toastUtil.setUiContext(this.getUIContext());
    });
  }

  private showLoading = () => {
    this.loadingController.open();
  };
  private closeLoading = () => {
    this.loadingController.close();
  };
}


