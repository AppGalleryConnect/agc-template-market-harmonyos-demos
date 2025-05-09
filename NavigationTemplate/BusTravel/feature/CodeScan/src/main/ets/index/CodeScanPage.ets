import image from '@ohos.multimedia.image';
import { RouteEntryVM } from 'common'
import { CardInfoList } from 'common'

@Builder
export function CodeScanPageBuilder() {
  CodeScanPage()
}

@Component
export struct CodeScanPage {
  @State cardInfo: CardInfoList = new CardInfoList()
  @State message: string = ''
  @State inputText: string = '请输入网址'
  @State private refreshInterval: number = 30000; // 30s刷新
  @StorageLink('isLogin') isLogin: boolean = AppStorage.get('isLogin') ?? false;
  @StorageLink('cloudCard') cloudCard: boolean = AppStorage.get('cloudCard') ?? false;
  @StorageLink('nickNameValue') nickNameValue: string = '';
  private intervalId: number | undefined;
  vm: RouteEntryVM = RouteEntryVM.instance;

  // 启动定时器
  private startRefreshInterval() {
    this.intervalId = setInterval(() => {
      this.refreshQrCode();
    }, this.refreshInterval);
  }

  // 停止定时器
  private stopRefreshInterval() {
    if (this.intervalId !== undefined) {
      clearInterval(this.intervalId);
    }
  }

  // 刷新二维码的方法
  async refreshQrCode() {
    this.inputText = this.getNewLink(); // 获取新的链接
  }

  getNewLink(): string {
    // 这里可以添加逻辑生成新的链接
    return '请输入网址' + new Date().getTime(); // 示例：使用当前时间戳
  }

  // 按钮点击事件处理函数
  onRefreshButtonClick() {
    this.refreshQrCode();
    this.stopRefreshInterval();
    this.startRefreshInterval();
  }

  build() {
    NavDestination() {
      Column() {
        this.buildTitle()
        this.buildCard()
        this.buildScan()
      }
      .backgroundColor('#F1F3F5')
      .height('100%')
    }
    .hideTitleBar(true)
  }

  @Builder
  buildTitle() {
    Row(){
      Text('乘车码')
        .fontSize(24)
        .fontWeight(FontWeight.Medium)
    }
    .width('100%')
    .height(70)
    .padding({left:24})
    .justifyContent(FlexAlign.Start)
  }

  @Builder
  buildCard() {
    Column() {
      Row() {
        Image($r('app.media.blank'))
          .height('30vp')
          .width('30vp')
          .margin({ right: '8vp' })
        Text('XX公交')
          .fontColor($r('app.color.font_color_white'))
          .fontSize('12fp')
      }
      .width('100%')
      .margin({ top: '11vp' })

      Text('城市一卡通')
        .fontColor($r('app.color.font_color_white'))
        .fontSize('18fp')
      Row() {
        Column() {
          Text(this.nickNameValue)
            .fontColor($r('app.color.font_color_white'))
            .fontSize('12fp')
          Text(this.cardInfo?.cardID.toString())
            .fontColor($r('app.color.font_color_white'))
            .fontSize('12fp')
        }
        .alignItems(HorizontalAlign.Start)

        Column() {
          Text('余额')
            .fontColor($r('app.color.font_color_white'))
            .fontSize('12fp')
          Text('￥' + this.cardInfo?.accumulatorCost.toString())
            .fontColor($r('app.color.font_color_white'))
            .fontSize('12fp')
        }
        .alignItems(HorizontalAlign.Start)

      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('300vp')
    .height('142vp')
    .backgroundImage($r('app.media.bg_blue'))
    .backgroundImageSize({ width: '300vp', height: '142vp' })
    .padding({ left: '14vp', right: '14vp', bottom: '12vp' })
    .margin({ top: '20vp', bottom: '30vp' })
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  buildScan() {
    Column() {
      Text('乘车码每分钟自动更新，请勿泄露！')
        .fontColor('#9A9A9A')
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin('22vp')
      Stack({ alignContent: Alignment.Center }) {
        Image($r('app.media.green_frame'))
          .height('195.3lpx')
          .width('195.3lpx')
        QRCode(this.inputText).width('160lpx').height('160lpx')
      }.height('195.3lpx')
      .width('195.3lpx')

      Text('点击刷新')
        .fontSize(14)
        .margin(40)
        .onClick(() => this.onRefreshButtonClick())
    }
    .width('300vp')
    .height('360vp')
    .backgroundColor($r('app.color.background_color_white'))
    .borderRadius(20)
  }

  aboutToAppear(): void {
    // 进入时生成二维码
    this.inputText = this.getNewLink()
    this.startRefreshInterval();
    this.cardInfo.cardName=this.nickNameValue;
  }
}