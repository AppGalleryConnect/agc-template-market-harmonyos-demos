import { Constant } from 'common';
import { TitleBar, ViewDetailComponent } from 'components';
import { BulletinInfo } from '../model/BulletinInfo';
import { HomePageVM } from '../viewmodel/HomePageVM';

@Builder
export function BulletinsBuilder() {
  Bulletins();
}

@ComponentV2
export struct Bulletins {
  vm: HomePageVM = HomePageVM.instance;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  @Builder
  BulletinCardBuilder(bulletin: BulletinInfo) {
    Row() {
      Column({ space: 18 }) {
        Text(bulletin.title)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontWeight(500)
          .fontSize(16);
        Text(`时间：${bulletin.releaseTime}`).fontSize(12).opacity(0.6);
      }.alignItems(HorizontalAlign.Start).width('80%');

      ViewDetailComponent();
    }
    .width(Constant.FULL_PERCENT)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding(12)
    .onClick(() => {
      this.mainPathStack.pushPathByName('BulletinDetail', bulletin.id);
    });
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: '公告列表', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });

        List({ space: 12 }) {
          LazyForEach(this.vm.bulletinList, (item: BulletinInfo) => {
            ListItem() {
              this.BulletinCardBuilder(item);
            };
          });
        }.align(Alignment.TopStart).padding({ left: 12, right: 12 }).height('90%').scrollBar(BarState.Off);
      };
    }.hideTitleBar(true).backgroundColor('#F1F3F5F2');
  }
}