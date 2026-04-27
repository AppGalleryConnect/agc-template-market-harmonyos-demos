@Builder
export function TutorialPageBuilder() {
  TutorialPage();
}

@ComponentV2
struct TutorialPage {
  build() {
    NavDestination() {
      Column() {
        Image($r('app.media.tutorial')).size({ height: 160, width: '60%' }).margin({ bottom: 16 });

        Row() {
          Image($r('app.media.ic_tutorial')).size({ width: 24, height: 24 });
          Text('使用教程').fontSize(18)
            .fontWeight(FontWeight.Bold)
            .opacity(0.9);
        }.width('100%').justifyContent(FlexAlign.Start).margin({ bottom: 12 });

        Column() {
          Column({ space: 8 }) {
            Text() {
              Span('01.').fontWeight(FontWeight.Medium);
              Span('首先').fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_emphasize'));
            }.width('100%').textAlign(TextAlign.Start);

            Text('找到手机桌面系统设置功能图标并打开')
              .fontSize(14)
              .opacity(0.9)
              .width('100%')
              .textAlign(TextAlign.Start);
          }.margin({ bottom: 16 });

          Column({ space: 8 }) {
            Text() {
              Span('02.').fontWeight(FontWeight.Medium);
              Span('然后').fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_emphasize'));
            }.width('100%').textAlign(TextAlign.Start);

            Text('点击进入多设备协同菜单，在多设备协同页面找到NFC设置项')
              .fontSize(14)
              .opacity(0.9)
              .width('100%')
              .textAlign(TextAlign.Start);
          }.margin({ bottom: 16 });

          Column({ space: 8 }) {
            Text() {
              Span('03.').fontWeight(FontWeight.Medium);
              Span('最后').fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_emphasize'));
            }.width('100%').textAlign(TextAlign.Start);

            Text('打开“NFC”功能后，将卡片贴于手机背面上半\n' +
              '部，等待读取成功后，在卡包里即可看到绑定的卡片，就可以手机NFC使用卡片了')
              .fontSize(14)
              .opacity(0.9)
              .width('100%')
              .textAlign(TextAlign.Start);
          };
        }.padding(12).backgroundColor('rgba(10, 89, 247, 0.05)').borderRadius(16);
      }.padding(16);
    }.title('教程');
  }
}