import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointModel, Constant } from 'common';
import { TitleBar } from 'uicomponents';
import { BulletinInfo } from '../model/BulletinInfo';
import { HomePageVM } from '../viewmodel/HomePageVM';

@Builder
export function BulletinsBuilder() {
  Bulletins();
}

@ComponentV2
export struct Bulletins {
  vm: HomePageVM = HomePageVM.instance;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  @Builder
  BulletinCardBuilder(bulletin: BulletinInfo) {
    Row() {
      Column({ space: 4 }) {
        Text(bulletin.title)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Subtitle_M'));
        Text(`时间：${bulletin.releaseTime}`).fontSize($r('sys.float.Body_S')).fontColor($r('sys.color.font_secondary'));
      }.alignItems(HorizontalAlign.Start).width('100%');
    }
    .width(Constant.FULL_PERCENT)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius(16)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      top: 16,
      bottom: 16,
      left: 12,
      right: 12,
    })
    .onClick(() => {
      this.mainPathStack.pushPathByName('BulletinDetail', bulletin.id);
    });
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: '景区资讯', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });

        List({ space: 12 }) {
          LazyForEach(this.vm.bulletinList, (item: BulletinInfo) => {
            ListItem() {
              this.BulletinCardBuilder(item);
            };
          });
        }
        .align(Alignment.TopStart)
        .padding({ left: this.breakPointModel.pagePadding, right: this.breakPointModel.pagePadding })
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .contentStartOffset(12)
        .contentEndOffset(12);
      };
    }.hideTitleBar(true).backgroundColor($r('sys.color.background_secondary'));
  }
}