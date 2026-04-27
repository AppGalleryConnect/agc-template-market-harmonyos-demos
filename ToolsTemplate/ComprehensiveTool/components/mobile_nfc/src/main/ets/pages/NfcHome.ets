import { display } from '@kit.ArkUI';
import { NFC_CARDS } from '../common/Constant';
import { ACTION_TYPE, NFC_TYPE } from '../common/Enum';
import { getNavPathStack, setNavPathStack } from '../common/Route';
import { ActionModel, CardModule } from '../model/Index';

@Builder
export function NfcHomeBuilder() {
  NfcHome();
}

@ComponentV2
export struct NfcHome {
  // 默认展开
  @Local foldStatus: number = 1;

  build() {
    NavDestination() {
      Column() {
        Row() {
          Row({ space: 8 }) {
            Image($r('app.media.chevron_left')).clip(true).size({ width: 40, height: 40 }).onClick(() => {
              getNavPathStack().pop();
            });
            Text('NFC').fontSize(20).fontWeight(FontWeight.Bold).opacity(0.9);
          };

          Image($r('app.media.ic_tutorial_right')).size({ width: 40, height: 40 }).onClick(() => {
            getNavPathStack().pushPathByName('TutorialPage', null);
          });
        }.width('100%').justifyContent(FlexAlign.SpaceBetween);

        Scroll() {
          Column({ space: 16 }) {
            Stack({ alignContent: Alignment.BottomEnd }) {
              Image(this.foldStatus === 1 ? $r('app.media.read_home_expand') : $r('app.media.read_home'))
                .size({ width: '100%', height: 186 }).borderRadius(16).clip(true);

              Button('立即添加')
                .padding({
                  top: 10,
                  bottom: 10,
                  left: 16,
                  right: 16,
                })
                .margin({ right: 12, bottom: 12 })
                .width(120)
                .height(40)
                .backgroundColor($r('sys.color.comp_background_emphasize'));
            }.onClick(() => {
              getNavPathStack()
                .pushPathByName('ActionPage', new ActionModel(ACTION_TYPE.ACTION_READ, NFC_TYPE.NFC_TYPE_DOOR));
            });

            Column({ space: 12 }) {
              Text('我的卡包')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .opacity(0.9)
                .width('100%')
                .textAlign(TextAlign.Start);

              List({ space: 8 }) {
                ForEach(NFC_CARDS, (item: CardModule) => {
                  ListItem() {
                    Column({ space: 6 }) {
                      Image(item.src).size({ height: 48, width: 48 });
                      Text(item.text).fontWeight(FontWeight.Medium).fontSize(14);
                    }
                    .backgroundColor('rgba(10, 89, 247, 0.05)')
                    .padding({
                      left: 18,
                      right: 18,
                      top: 28,
                      bottom: 12,
                    })
                    .onClick(item.clickEvent)
                    .width('33.3%')
                    .borderRadius(16);
                  };
                }, (item: CardModule) => item.text);
              }.listDirection(Axis.Horizontal).width('100%').scrollBar(BarState.Off);

              Text('若要进行刷公交卡，门禁卡，银行卡操作，可将手机背部触碰其他设备NFC感应区。')
                .fontSize(12)
                .opacity(0.6)
                .lineHeight(16);
            };

            Column({ space: 12 }) {
              Text('克隆卡片')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .opacity(0.9)
                .width('100%')
                .textAlign(TextAlign.Start);

              Row() {
                Row({ space: 12 }) {
                  Image($r('app.media.ic_clone')).size({ width: 16, height: 16 });

                  Text('前往克隆').fontSize(14).opacity(0.9).fontColor($r('sys.color.font_primary'));
                };

                Image($r('app.media.chevron_right')).size({ width: 12, height: 24 });
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .borderRadius(8)
              .padding({
                top: 10,
                bottom: 10,
                left: 12,
                right: 12,
              })
              .backgroundColor('#F9FAFE')
              .onClick(() => {
                getNavPathStack().pushPathByName('CloneCardPage', null);
              });
            };
          };
        }
        .scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring).margin({ top: 16 });
      }
      .onAreaChange(() => {
        this.foldStatus = display.getFoldStatus();
      })
      .padding(16)
      .width('100%')
      .height('100%');
    }.hideTitleBar(true).onReady((ctx) => {
      setNavPathStack(ctx.pathStack);
    });
  }
}