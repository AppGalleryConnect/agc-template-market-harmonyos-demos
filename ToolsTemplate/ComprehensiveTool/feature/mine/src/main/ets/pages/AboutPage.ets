import { CustomContentDialog } from '@kit.ArkUI';
import { Want, common } from '@kit.AbilityKit';
import { AboutPageVM } from '../viewmodel/AboutPageVM';
import { UtilLog as Logger } from '@hw-agconnect/util-log';

@Builder
export function AboutPageBuilder() {
  AboutPage();
}


@ComponentV2
export struct AboutPage {
  vm: AboutPageVM = AboutPageVM.instance;
  updateVersionDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      contentBuilder: () => {
        this.VersionDialogBuilder();
      },
      buttons: [
        {
          value: '以后再说',
          buttonStyle: ButtonStyleMode.TEXTUAL,
        },
        {
          value: '立即更新',
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
            const want: Want = {
              uri: `store://appgallery.huawei.com/app/detail?id=${this.vm.appId}`,
            };
            const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
            context.startAbility(want).then(() => {
              //拉起成功
              Logger.info('The app store is successfully launched.');
              // todo 模拟更新成功
              this.vm.versionInfo.isLatestVersion = true;
            }).catch(() => {
              // 拉起失败
              Logger.error('Failed to open the app store.');
            });
          },
        },
      ],
    }),
    alignment: DialogAlignment.Center,
  });

  @Builder
  VersionDialogBuilder() {
    Column() {
      Text('发现新版本')
        .width('100%')
        .textAlign(TextAlign.Center)
        .fontSize($r('sys.float.Title_S'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .lineHeight(27)
        .margin({ bottom: 15 });

      Column({ space: 4 }) {
        Row({ space: 8 }) {
          Text('应用').commonTextExtend();
          Text('综合应用模版').commonExtend();
        };

        Row({ space: 8 }) {
          Text('版本').commonTextExtend();
          Text(this.vm.currentVersion).commonExtend();
        };

        Row({ space: 8 }) {
          Text('大小').commonTextExtend();
          Text('50MB').commonExtend();
        };

      }.padding({ top: 12, bottom: 12 }).width('100%').alignItems(HorizontalAlign.Start);

      Text('详情').margin({ top: 12, bottom: 12 }).commonExtend();

      Text('1、新增 发布会员功能\n' +
        '2、优化 音频剪辑闪退问题\n' +
        '3、修复 若干bug').commonTextExtend();


    }.width('100%').alignItems(HorizontalAlign.Start);

  }

  build() {
    NavDestination() {
      Column() {
        Column({ space: 8 }) {
          Image($r('app.media.ic_logo')).width(72);
          Text('综合工具模版').commonExtend();
        };

      }.width('100%').height(224).padding(16).justifyContent(FlexAlign.Center);

      Column() {
        Column() {
          Row() {
            Column({ space: 2 }) {
              Row({ space: 8 }) {
                Text('版本信息').commonExtend();
                if (!this.vm.versionInfo.isLatestVersion) {
                  Circle({ width: 6, height: 6 }).fill($r('sys.color.warning'));
                }
              };

              Text(this.vm.currentVersion).secondExtend();
            }.alignItems(HorizontalAlign.Start);

            Row({ space: 4 }) {
              Text(this.vm.versionInfo.isLatestVersion ? '检查更新' : '新版本').secondExtend();
              Image($r('app.media.ic_about_right')).width(12).height(24);

            }.onClick(() => {
              if (this.vm.versionInfo.isLatestVersion) {
                this.vm.checkUpDate(this.getUIContext(), this.updateVersionDialogController);
              } else {
                this.vm.showUpdateDialog(this.getUIContext(), this.updateVersionDialogController);
              }
            });
          }.justifyContent(FlexAlign.SpaceBetween).height(64).width('100%');

          Divider();

          Column({ space: 2 }) {
            Text('客服电话').commonExtend();
            Text(this.vm.phoneNumber).secondExtend();
          }
          .height(64)
          .alignItems(HorizontalAlign.Start)
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.vm.takePhone();
          });

        }
        .backgroundColor($r('sys.color.comp_background_primary'))
        .borderRadius(16)
        .width('100%')
        .padding({
          top: 4,
          bottom: 4,
          left: 12,
          right: 12,
        });

      }.padding(16).layoutWeight(1);

      Column() {
        Text('XXXX备xxxxxxxx号-xxxx')
          .fontColor($r('sys.color.font_emphasize'))
          .fontSize($r('sys.float.Body_S'))
          .fontWeight(FontWeight.Medium);
        Text('华为xx 版权所有 © 2019-2023').labelExtend();
        Text('技术支持：xxxxxxxx').labelExtend();


      }.padding(16);

    }.title('关于')
    .backgroundColor($r('sys.color.background_secondary'));
  }
}

@Extend(Text)
function commonTextExtend() {
  .fontSize($r('sys.float.Body_L')).fontColor($r('sys.color.font_primary')).lineHeight(21);
}

@Extend(Text)
function secondExtend() {
  .fontColor($r('sys.color.font_secondary')).fontSize($r('sys.float.Body_M')).lineHeight(19);
}

@Extend(Text)
function labelExtend() {
  .fontColor($r('sys.color.font_secondary')).fontSize($r('sys.float.Body_S')).lineHeight(16);
}

@Extend(Text)
function commonExtend() {
  .fontColor($r('sys.color.font_primary'))
  .fontSize($r('sys.float.Body_L'))
  .fontWeight(FontWeight.Medium)
  .lineHeight(21);
}
