import { ComponentContent } from '@kit.ArkUI';
import { BulletHistory, Hint } from '../model/Index';
import { PromptActionUtil } from '../util/PromptActionUtil';
import { BulletVM } from '../viewmodel/BulletVM';

@Builder
export function HistoryBuilder() {
  History();
}

@Builder
function deleteHint(hint: Hint) {
  Column({ space: 24 }) {
    Text(hint.message)
      .fontColor($r('sys.color.font_primary'))
      .opacity(0.9);
    Row() {
      Text('取消').fontColor($r('sys.color.font_emphasize')).width('50%').textAlign(TextAlign.Center).onClick(() => {
        PromptActionUtil.closeDialog(hintContentNode);
      });
      Text('|').height(36).opacity(0.05);
      Text('删除').fontColor($r('sys.color.warning')).width('50%').textAlign(TextAlign.Center).onClick(() => {
        hint.confirmCallBack();
        PromptActionUtil.closeDialog(hintContentNode);
      });
    };
  }
  .padding(24)
  .borderRadius(32)
  .backgroundColor($r('sys.color.ohos_id_blur_style_component_ultra_thick_color'))
  .width('90%');
}

let getUIContext: UIContext;
let hintContentNode: ComponentContent<Object>;

@ComponentV2
export struct History {
  vm: BulletVM = BulletVM.instance;

  aboutToAppear(): void {
    getUIContext = this.getUIContext();
    hintContentNode =
      new ComponentContent(getUIContext, wrapBuilder<[Hint]>(deleteHint), this.vm.hint);
  }

  @Builder
  deleteHistory(index: number) {
    Image($r('app.media.ic_bullet_delete')).size({ width: 40, height: 40 }).margin({ left: 16 }).onClick(() => {
      this.vm.updateHintDialog(getUIContext, hintContentNode, '是否删除此条历史弹幕？', () => {
        this.vm.deleteBulletByIndex(index);
      });
    });
  }

  build() {
    NavDestination() {
      if (this.vm.bulletHistoryList.list.length) {
        Column({ space: 12 }) {
          List({ space: 16 }) {
            ForEach(this.vm.bulletHistoryList.list, (item: BulletHistory, index: number) => {
              ListItem() {
                Column({ space: 12 }) {
                  Text(item.text).fontWeight(FontWeight.Medium).opacity(0.9);
                  Text(item.createTime).fontSize(14).opacity(0.6);
                }
                .padding(12)
                .borderRadius(16)
                .backgroundColor($r('sys.color.background_primary'))
                .width('100%')
                .alignItems(HorizontalAlign.Start)
                .padding(16)
                .onClick(() => {
                  this.vm.bullet.content = item.text;
                  this.vm.stack.pop();
                  this.vm.homeTabIndex = 0;
                });
              }.swipeAction({ end: this.deleteHistory(index) });
            }, (item: BulletHistory) => item.text);
          }.height('80%').scrollBar(BarState.Off);

          if (this.vm.bulletHistoryList.list.length) {
            Column({ space:12 }) {
              Button('根据弹幕内容去重').width('100%').borderRadius(20).onClick(() => {
                this.vm.updateHintDialog(getUIContext, hintContentNode, '是否删除重复历史弹幕？', () => {
                  this.vm.getUniqueBullet();
                });
              });
              Button('清空历史')
                .width('100%')
                .borderRadius(20)
                .backgroundColor($r('sys.color.comp_background_tertiary'))
                .fontColor($r('sys.color.font_emphasize'))
                .onClick(() => {
                  this.vm.updateHintDialog(getUIContext, hintContentNode, '是否删除全部历史弹幕？', () => {
                    this.vm.clearBullet();
                  });
                });
            }
          }
        }.height('100%').justifyContent(FlexAlign.SpaceBetween).padding(16);
      } else {
        Column() {
          Column() {
            Image($r('app.media.bullet_empty')).size({ width: 120, height: 120 });
            Text('暂无内容').fontSize(14).fontColor($r('sys.color.font_tertiary'));
          };
        }.width('100%').height('100%').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center);
      }
    }.backgroundColor($r('sys.color.background_secondary')).title('历史弹幕');
  }
}