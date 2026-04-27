import { UtilLog } from '@hw-agconnect/util-log';
import { ACTION_TYPE } from '../common/Enum';
import { NFC_STATE_NORMAL, NFC_STATE_WAIT, stopNFC, } from '../common/nfc/Nfc';
import { getNavPathStack } from '../common/Route';
import { ActionModel } from '../model/Index';
import { ActionVM } from '../viewmodel/ActionVM';

@Extend(Text)
function readText() {
  .fontSize(12).opacity(0.6).fontColor($r('sys.color.font_secondary'));
}

@Builder
export function ActionPageBuilder() {
  ActionPage();
}

@ComponentV2
struct ActionPage {
  vm: ActionVM = ActionVM.instance;

  aboutToDisappear(): void {
    this.vm.state = NFC_STATE_NORMAL;
    stopNFC();
  }

  @Builder
  ReadCard() {
    Text('读取卡片信息')
      .fontSize(20)
      .opacity(0.9)
      .width('100%')
      .textAlign(TextAlign.Start)
      .margin({ bottom: 12 });
    Row({ space: 12 }) {
      Row({ space: 4 }) {
        Image($r('app.media.ic_step_one')).size({ width: 16, height: 16 });
        Text('读取卡片').readText();
      };

      Row({ space: 4 }) {
        Image($r('app.media.ic_step_second')).size({ width: 16, height: 16 });
        Text('读取详情').readText();
      };

      Row({ space: 4 }) {
        Image($r('app.media.ic_step_third')).size({ width: 16, height: 16 });
        Text('保存到卡包').readText();
      };
    }.width('100%').justifyContent(FlexAlign.Start);
  }

  @Builder
  ReadingCard() {
    Text('读取卡片说明')
      .fontSize(20)
      .opacity(0.9)
      .width('100%')
      .textAlign(TextAlign.Start)
      .margin({ bottom: 12 });
    Column({ space: 12 }) {
      Text('请确保手机已开启NFC功能').readText();
      Text('将卡片贴附于手机背部NFC感应区域，请勿移动卡片').readText();
      Text('若多次尝试仍无法检测到卡片信息').readText();
      Text('则卡片非NFC常规读取卡片，不支持').readText();
    }.alignItems(HorizontalAlign.Start).width('100%');
  }

  @Builder
  CloneCard() {
    Text('复制卡片信息')
      .fontSize(20)
      .opacity(0.9)
      .width('100%')
      .textAlign(TextAlign.Start)
      .margin({ bottom: 12 });
    Row({ space: 12 }) {
      Row({ space: 4 }) {
        Image($r('app.media.ic_step_one')).size({ width: 16, height: 16 });
        Text('数据写入').readText();
      };

      Row({ space: 4 }) {
        Image($r('app.media.ic_step_second')).size({ width: 16, height: 16 });
        Text('复制卡片信息').readText();
      };
    }.width('100%').justifyContent(FlexAlign.Start);
  }

  build() {
    NavDestination() {
      Column() {
        if (this.vm.data.action === ACTION_TYPE.ACTION_READ) {
          if (this.vm.state === NFC_STATE_NORMAL) {
            this.ReadCard();
          } else {
            this.ReadingCard();
          }
        } else if (this.vm.data.action === ACTION_TYPE.ACTION_CLONE) {
          this.CloneCard();
        }

        Image(this.vm.getImgRes(this.vm.state))
          .fitOriginalSize(true)
          .padding(20);

        Row() {
          Text(this.vm.getBtnStr(this.vm.state))
            .fontColor($r('sys.color.font_on_primary'));
          LoadingProgress()
            .width(24)
            .height(24)
            .visibility((this.vm.state === NFC_STATE_NORMAL || this.vm.state === NFC_STATE_WAIT) ? Visibility.None :
              Visibility.Visible);
        }
        .margin({ top:48 ,bottom: 40 })
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .height(40)
        .borderRadius(20)
        .backgroundColor($r('sys.color.background_emphasize'))
        .onClick(() => this.vm.confirm(this.getUIContext()));
      }
      .width('100%')
      .height('100%')
      .padding(16);
    }.title('读取卡片').onReady((ctx) => {
      this.vm.data = ctx.pathInfo.param as ActionModel;
    }).onBackPressed(() => {
      UtilLog.info(0x0000, 'testTag', '%{public}s', 'action type is ' + this.vm.data.action);
      if (this.vm.data.action === ACTION_TYPE.ACTION_READ) {
        let list = getNavPathStack().getIndexByName('CardMyPage')
        list.length ? getNavPathStack().popToName('CardMyPage'): getNavPathStack().pop()
      } else {
        getNavPathStack().popToName('CloneCardPage');
      }
      return true;
    });
  }
}