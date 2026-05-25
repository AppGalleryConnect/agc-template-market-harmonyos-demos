import { GridRowColSetting, MockService } from 'external_interactions';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { CustomContentDialog } from '@kit.ArkUI';
import { TitleBar } from 'module_recharge/src/main/ets/components/TitleBar';
import { ScreenPropStorage , AccountUpdate} from 'external_interactions'
import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';

@Preview
@ComponentV2
export struct MineInfoPage {
  @Local screenPropStorage : ScreenPropStorage = AppStorageV2.connect(ScreenPropStorage, 'ScreenPropStorage', () =>new ScreenPropStorage())!
  @Local accountUpdateStorage : AccountUpdate = AppStorageV2.connect(AccountUpdate, 'AccountUpdate', () =>new AccountUpdate())!
  @Local topRectHeight: number = this.screenPropStorage.topRectHeight;
  @Local bottomRectHeight: number = this.screenPropStorage.bottomRectHeight;
  @Local accountUpdate: boolean = this.accountUpdateStorage.accountUpdate;
  pathStack: NavPathStack = new NavPathStack();
  @Local context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext
  @Local nickname: string = '';
  @Local phone: string = ''
  @Local sex: string = ''
  @Local birthday: string = ''
  @Local avatar: ResourceStr = ''
  @Local inputType: number = 0;
  @Local inputValue: string = ''
  @Monitor('screenPropStorage.topRectHeight', 'screenPropStorage.bottomRectHeight')
  onScreenPropStorage(mon: IMonitor) {
    this.topRectHeight = this.screenPropStorage.topRectHeight;
    this.bottomRectHeight = this.screenPropStorage.bottomRectHeight
  }
  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      primaryTitle: '',
      contentBuilder: () => {
        this.buildContent();
      },
      buttons: [
        {
          value: '取消',
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
          },
        },
        {
          value: '确定',
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
            if (this.inputType === 1) {
              this.nickname = this.inputValue;
            } else {
              this.phone = this.inputValue
            }
            MockService.saveAccountInfo(this.nickname, this.phone, this.sex, this.birthday, this.avatar);
            this.refreshUserInfo()
            this.context.eventHub.emit('refreshUserInfo');
            this.accountUpdate = !this.accountUpdate
          },
        },
      ],
    }),
    backgroundColor: Color.White,
  });

  @Builder
  buildContent() {
    TextInput({ text: this.inputValue })
      .showUnderline(true)
      .onChange((value: string) => {
        this.inputValue = value
      })
      .type(this.inputType === 2 ? InputType.Number : InputType.Normal)
      .maxLines(1)
      .showCounter(true)
      .maxLength(11)
      .backgroundColor(Color.White);
  }

  build() {
    NavDestination() {
      TitleBar({ title: '个人中心',
        onBackClick:()=>{
          this.pathStack.pop()
        }
      })
        .margin({ left: 16, right: 16 })

      GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
        GridCol({
          span: GridRowColSetting.DEFAULT_CENTER_COL_SPAN,
          offset: GridRowColSetting.DEFAULT_CENTER_COL_OFFSET,
        }) {
          Stack() {
            Scroll() {
              Column() {
                Row() {
                  Text('头像')
                    .fontWeight(FontWeight.Medium)
                    .fontSize(16)
                  Row() {
                    Image(this.avatar ? this.avatar : $r('app.media.avatar_no_login'))
                      .width(40)
                      .height(40)
                      .borderRadius(36)
                      .margin({ right: 9 })
                    Image($r('app.media.chevron_right'))
                      .width(18)
                      .height(18)
                      .fillColor(Color.Gray)
                  }.onClick(() => {
                    this.choose()
                  })
                }
                .width('100%')
                .border({ radius: 16 })
                .padding(12)
                .backgroundColor(Color.White)
                .justifyContent(FlexAlign.SpaceBetween)
                .margin({ bottom: 12 })

                Column() {
                  Row() {
                    Text('昵称')
                      .fontWeight(FontWeight.Medium)
                      .fontSize(16)
                    Row() {
                      Text(this.nickname ? this.nickname : '华为用户')
                        .fontWeight(FontWeight.Regular)
                        .fontSize(14)
                        .margin({ right: 9 })
                      Image($r('app.media.chevron_right'))
                        .width(18)
                        .height(18)
                        .fillColor(Color.Gray)
                    }
                  }
                  .height(21)
                  .width('100%')
                  .justifyContent(FlexAlign.SpaceBetween)
                  .alignItems(VerticalAlign.Center)
                  .onClick(() => {
                    this.inputType = 1
                    this.inputValue = this.nickname ? this.nickname : '华为用户'
                    this.dialogController.open()
                  })

                  Divider()
                    .height(1)
                    .margin({ top: 18, bottom: 18 })

                  Row() {
                    Text('电话')
                      .fontWeight(FontWeight.Medium)
                      .fontSize(16)
                    Row() {
                      Text(this.phone)
                        .fontWeight(FontWeight.Regular)
                        .fontSize(14)
                        .margin({ right: 9 })
                      Image($r('app.media.chevron_right'))
                        .width(18)
                        .height(18)
                        .fillColor(Color.Gray)
                    }
                  }
                  .height(21)
                  .width('100%')
                  .justifyContent(FlexAlign.SpaceBetween)
                  .onClick(() => {
                    this.inputType = 2
                    this.inputValue = this.phone
                    this.dialogController.open()
                  })
                }
                .border({ radius: 16 })
                .padding({
                  left: 12,
                  right: 12,
                  top: 19,
                  bottom: 19
                })
                .height(116)
                .width('100%')
                .backgroundColor(Color.White)
              }
              .width('100%')
              .height('100%')
            }
            .scrollBar(BarState.Off)
            .margin({ left: 16, right: 16 })
            .edgeEffect(EdgeEffect.Spring)
          }
          .layoutWeight(1)
          .alignContent(Alignment.Top)
        }
      }
    }
    .hideTitleBar(true)
    .hideToolBar(true)
    .onReady((ctx: NavDestinationContext) => {
      this.pathStack = ctx.pathStack
      this.refreshUserInfo()
    })
    .backgroundColor($r('app.color.main_background_color'))
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight),
      bottom: this.getUIContext().px2vp(this.bottomRectHeight) })
  }

  refreshUserInfo() {
    this.nickname = MockService.account.nickname
    this.phone = MockService.account.phone
    this.sex = MockService.account.sex
    this.birthday = MockService.account.birthday
    this.avatar = MockService.account.avatar
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
      this.avatar = uris.photoUris[0];
      MockService.saveAccountInfo(this.nickname, this.phone, this.sex, this.birthday, this.avatar);
      this.refreshUserInfo()
      this.getUIContext().getHostContext()?.eventHub.emit('refreshUserInfo');
      this.accountUpdate = !this.accountUpdate
    } catch (error) {
    }
  }
}

@Builder
export function MineInfoPageBuilder(): void {
  MineInfoPage()
}
