import { CommonConstants, Title } from '@ohos_agcit/children_education_utils';

@Builder
export function ContactUsBuilder() {
  ContactUs();
}

@ComponentV2
export struct ContactUs {
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Column() {
        Row() {
          Text('如您在使用APP的过程中遇到问题，可在下发添加乐乐陪伴师，获得帮助：')
        }.padding({
          top: 20,
          bottom: 20
        })

        Column() {
          Row({ space: 20 }) {
            Image($r('app.media.qrcode')).width('40%').aspectRatio(1).fillColor('#FFD15D')
            Column({ space: 40 }) {
              Row() {
                SymbolGlyph($r('sys.symbol.star')).backgroundColor('#FFD15D')
                Text('功能问题解答')
              }

              Row() {
                SymbolGlyph($r('sys.symbol.star')).backgroundColor('#FFD15D')
                Text('使用意见反馈')
              }
            }
          }
          .padding({
            top: '30%',
            bottom:'30%'
          })
        }
        .backgroundColor($r('sys.color.white'))
        .width('100%')
        .height(300)
        .margin({
          right: 16,
          left: 16
        })
        .borderRadius(8)
      }
      .padding({ right: 16, left: 16 })
      .backgroundColor('#F1F3F5')
      .height(CommonConstants.FULL_PERCENT);
    }
    .title(Title($r('app.string.contact_us')))
    .onBackPressed(() => {
      this.appPathStack.pop();
      return true;
    });
  }
}