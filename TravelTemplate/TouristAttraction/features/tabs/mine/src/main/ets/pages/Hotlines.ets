import { Constant, triggerForCall } from 'common';
import { TitleBar } from 'components';
import { HOTLINE_DATA, HotlineInfo } from '../model/HotlineInfo';
import { MineVM } from '../viewmodel/MineVM';

@Builder
export function HotlinesBuilder() {
  Hotlines();
}

@ComponentV2
export struct Hotlines {
  vm: MineVM = MineVM.instance;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    this.vm.mapContactInfo();
  }

  build() {
    NavDestination() {
      Column({ space: 12 }) {
        TitleBar({
          isShowBack: true, title: '服务热线', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });

        Column({ space: 12 }) {
          ForEach(HOTLINE_DATA, (item: HotlineInfo) => {
            Row() {
              Column({ space: 2 }) {
                Text(item.phone).fontColor('#64BB5C');
                Text(item.title).fontSize(14).opacity(0.6);
              }.alignItems(HorizontalAlign.Start);
            }
            .padding({
              left: 12,
              right: 12,
              top: 24,
              bottom: 24,
            })
            .backgroundColor(Color.White)
            .borderRadius(8)
            .width(Constant.FULL_PERCENT)
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.Start)
            .onClick(() => {
              triggerForCall(item.phone);
            });
          }, (item: HotlineInfo) => item.title.toString());
        }.padding({ left: 12, right: 12 });
      }.height(Constant.FULL_PERCENT).backgroundColor('#F1F3F5F2');
    }.hideTitleBar(true);
  }
}