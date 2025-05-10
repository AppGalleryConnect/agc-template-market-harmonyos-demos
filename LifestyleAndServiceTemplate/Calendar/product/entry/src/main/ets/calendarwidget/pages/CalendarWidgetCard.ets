import dayjs from 'dayjs';

@Entry
@Component
struct CalendarWidgetCard {
  /*
   * The title.
   */
  readonly TITLE: string = '日历模板';
  /*
   * The action type.
   */
  readonly ACTION_TYPE: string = 'router';
  /*
   * The ability name.
   */
  readonly ABILITY_NAME: string = 'EntryAbility';
  /*
   * The message.
   */
  readonly MESSAGE: string = 'add detail';
  /*
   * The width percentage setting.
   */
  readonly FULL_WIDTH_PERCENT: string = '100%';
  /*
   * The height percentage setting.
   */
  readonly FULL_HEIGHT_PERCENT: string = '100%';

  build() {
    Column() {
      Row() {
        Text(this.TITLE)
          .fontSize($r('app.float.font_size'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.item_title_font'))
          .fontColor($r('app.color.font_color_white'))
      }
      .width(this.FULL_WIDTH_PERCENT)
      .alignItems(VerticalAlign.Center)
      .padding({ left: 10 })
      .height('20%')

      Column() {
        Text(dayjs(new Date()).format('YYYY-MM-DD'))
          .fontSize(28)
          .letterSpacing(1)
          .fontWeight(700)
          .fontColor($r('app.color.font_color_red'))
          .margin({
            top: 25,
            bottom: 20
          })
          .onClick(() => {
            // 点击卡片其他区域时，发送message事件，触发onFormEvent生命周期回调函数请求最新列表
            postCardAction(this, {
              'action': 'message',
              'params': {
                'message': 'update'
              }
            });
          })
        Blank()
        Flex() {
          Row() {
            Image($r('app.media.ic_yi_str'))
              .width(20)

            Text('打扫 动土 祈福 安床 纳畜 盖屋 安葬 祭祀 修造 起基 入殓 合嵴 破土 求子 上梁 竖柱')
              .fontSize($r('sys.float.Body_L'))
              .padding({ left: 6 })
              .maxLines(1)
              .width('calc(100% - 26vp)')
              .textOverflow({ overflow: TextOverflow.Ellipsis })

          }
          .width('50%')
          .padding({ left: 10 })

          Row() {
            Image($r('app.media.ic_ji_str'))
              .width(20)
            Text('结婚 出行 搬家 搬新房 开业 赴任 诉讼 出火 收养子女 开光')
              .fontSize($r('sys.float.Body_L'))
              .padding({ left: 6 })
              .maxLines(1)
              .width('calc(100% - 26vp)')
              .textOverflow({ overflow: TextOverflow.Ellipsis })

          }
          .width('45%')
        }
        .margin({ bottom: 10 })
      }
      .backgroundColor($r('app.color.background_color_light'))
      .width('100%')
      .height('80%')
      .borderRadius({
        topLeft: 10,
        topRight: 10
      })
    }
    .height(this.FULL_HEIGHT_PERCENT)
    .backgroundColor($r('app.color.font_color_red'))
    .onClick(() => {
      postCardAction(this, {
        action: this.ACTION_TYPE,
        abilityName: this.ABILITY_NAME,
        params: {
          message: this.MESSAGE
        }
      });
    })
  }
}
