import { Constant } from 'common';
import { TitleBar } from 'components';
import { getManagementModuleInfo, ManagementInfo } from '../model/ManagementInfo';
import { getOrderTypeInfo, OrderTypeInfo } from '../model/OrderTypeInfo';
import { MineVM } from '../viewmodel/MineVM';

@Builder
export function MineBuilder() {
  MineView();
}

@ComponentV2
export struct MineView {
  vm: MineVM = MineVM.instance;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  @Builder
  HeaderBuilder() {
    Row({ space: 12 }) {
      Image(this.vm.userInfo.avatar)
        .alt($r('app.media.default_avatar'))
        .size({ width: 72, height: 72 })
        .borderRadius(36);

      Text(this.vm.userInfo.nickname ? this.vm.userInfo.nickname : '华为用户').fontSize(18).fontWeight(500);
    }
    .padding(12)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.mainPathStack.pushPathByName('EditPersonalInfo', null);
    })
    .width(Constant.FULL_PERCENT)
    .justifyContent(FlexAlign.Start);
  }

  @Builder
  FunctionBuilder() {
    List({ space: 12 }) {
      ForEach(getManagementModuleInfo(this.mainPathStack), (item: ManagementInfo, index: number) => {
        ListItem() {
          Column() {
            Row() {
              Row({ space: 8 }) {
                Image(item.icon).size({ width: 14, height: 14 });
                Text(item.title).fontSize(12).opacity(0.9);
              };

              Image($r('app.media.chevron_right')).size({ width: 14, height: 14 });
            }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);

            if (index !== 2) {
              Divider().margin({ top: 12 });
            }
          }.onClick(item.click);
        };
      }, (item: ManagementInfo, index: number) => index + '__' + JSON.stringify(item));
    }.padding(12).backgroundColor(Color.White).borderRadius(8);
  }

  @Builder
  OrderBuilder() {
    Column({ space: 16 }) {
      Text('我的订单').fontSize(14).fontWeight(500);

      Row({ space: 28 }) {
        ForEach(getOrderTypeInfo(this.mainPathStack), (item: OrderTypeInfo) => {
          Column({ space: 4 }) {
            Image(item.icon).size({ width: 18, height: 18 });
            Text(item.name).fontSize(12).margin({ top: 8 });
          }.onClick(item.click);
        }, (item: OrderTypeInfo) => item.type.toString());
      };
    }
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .width(Constant.FULL_PERCENT)
    .alignItems(HorizontalAlign.Start)
    .margin({ top: 22, bottom: 12 });
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: false, title: '个人中心', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });

        Column() {
          this.HeaderBuilder();
          this.OrderBuilder();
          this.FunctionBuilder();
        }.padding(12);

      }.backgroundColor('#F1F3F5').height(Constant.FULL_PERCENT).linearGradient({
        direction: GradientDirection.Bottom, // 渐变方向
        repeating: false, // 渐变颜色是否重复
        colors: [['rgba(100, 187, 92, 0.9)', 0.0], ['rgba(100, 187, 92, 0)', 0.5],
          ['rgba(100, 187, 92, 0)', 1]], // 数组末尾元素占比小于1时满足重复着色效果
      });
    };
  }
}