import { CommonConstants, cancelAuthorization } from 'commonlib';
import { MinePageVM } from '../viewModels/MinePageVM';
import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { promptAction, AlertDialog } from '@kit.ArkUI';

@ComponentV2
export struct Header {
  vm: MinePageVM = MinePageVM.instance;
  dialogControllerConfirm: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      content: '确定要取消关联吗？',
      primaryButton: {
        value: '取消',
        action: () => {
        },
      },
      secondaryButton: {
        value: '确认',
        role: ButtonRole.ERROR,
        action: () => {
          this.vm.cancelPhone();
        },
      },
    }),
  });

  @Builder
  titleInside() {
    Text('个人中心')
      .fontSize(16)
      .fontWeight(700)
      .padding({ left: 16 })
      .height(56)
      .alignSelf(ItemAlign.Start)
      .opacity(1 - 2 * this.vm.titleBgOpacity);
  }

  build() {
    Column() {
      this.titleInside();
      Row({ space: 6 }) {
        Image(this.vm.userInfo.avatar).width(56).height(56).alt($r('app.media.icon_avatar')).borderRadius(28);
        Column({ space: 2 }) {
          Text(this.vm.userInfo.nickname ? this.vm.userInfo.nickname : '华为用户').fontSize(18).fontWeight(500);
          if (this.vm.isBindPhone()) {
            Text('取消关联')
              .fontSize(12)
              .fontColor(CommonConstants.FONT_COLOR_GREEN)
              .fontWeight(FontWeight.Medium)
              .height(20)
              .onClick(() => {
                this.dialogControllerConfirm.open();
              });
          } else {
            FunctionalButton({
              params: {
                openType: functionalButtonComponentManager.OpenType.GET_PHONE_NUMBER,
                label: '关联账号',
                styleOption: {
                  plain: true,
                  styleConfig: new functionalButtonComponentManager
                    .ButtonConfig()
                    .type(ButtonType.Normal)
                    .size({ height: 20 })
                    .borderRadius(0)
                    .padding(0)
                    .fontSize(12)
                    .fontColor(CommonConstants.FONT_COLOR_GREEN)
                    .fontWeight(FontWeight.Medium)
                    .backgroundColor(Color.Transparent)
                },
              },
              controller: new functionalButtonComponentManager.FunctionalButtonController()
                .onGetPhoneNumber((err, data) => {
                  if (err) {
                    if (err.code !== 1001502012) {
                      promptAction.showToast({ message: `获取手机号失败: ${err.message}` });
                    }
                    return;
                  }
                  this.vm.bindPone(data.code);
                  cancelAuthorization();
                }),
            }).id('phoneFunctionalButtonId1');
          }
        }.alignItems(HorizontalAlign.Start);
      }.padding({ left: 16, top: 22, bottom: 38 })
      .width('100%');
    }
    .width('100%')
    .backgroundImage(this.vm.bannerUrl)
    .backgroundImageSize(ImageSize.FILL)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);
  }
}