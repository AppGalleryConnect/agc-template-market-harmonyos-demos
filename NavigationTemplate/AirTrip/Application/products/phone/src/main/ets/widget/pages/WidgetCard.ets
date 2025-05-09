@Entry
@Component
struct WidgetCard {
  readonly WIDGET_FONT_SMALL: number = 14;
  readonly WIDGET_FONT_MINI: number = 12;
  readonly WIDGET_ROW_SIZE: number = 24;
  readonly WIDGET_WIDTH: number = 64;
  readonly WIDGET_HEIGHT: number = 72;
  readonly WIDGET_RADIUS: number = 16;
  readonly WIDGET_PADDING: number = 16;
  readonly WIDGET_SPACE: number = 10;
  readonly WIDGET_PADDING_MINI: number = 8
  readonly FULL: string = '100%';
  @State widgetList: Record<string, string>[] = [
    {
      'serviceId': 'book_ticket',
      'name': '机票预订',
      'icon': 'app.media.book_ticket',
    },
    {
      'serviceId': 'my_trip',
      'name': '查看行程',
      'icon': 'app.media.my_trip',
    },
    {
      'serviceId': 'my_order',
      'name': '订单中心',
      'icon': 'app.media.my_order',
    },
  ]

  build() {
    Column() {
      Row({ space: this.WIDGET_SPACE }) {
        Text($r('app.string.app_name')).fontSize(this.WIDGET_FONT_SMALL)
      }
      .padding({top: this.WIDGET_PADDING, bottom: this.WIDGET_FONT_MINI})

      Row({space: this.WIDGET_SPACE}) {
        Image($r('app.media.ic_search')).width(this.WIDGET_RADIUS).height(this.WIDGET_RADIUS)
        Text('查询航班动态').fontSize(this.WIDGET_FONT_MINI).fontColor($r('sys.color.titlebar_subheader_color'))
      }
      .width(this.FULL)
      .padding(this.WIDGET_PADDING_MINI)
      .borderRadius(this.WIDGET_SPACE)
      .backgroundColor($r('sys.color.gray_01'))
      .onClick(() => {
        postCardAction(this, {
          action: 'router',
          abilityName: 'EntryAbility',
          params: { message: 'search_flight', }
        });
      })

      Row() {
        ForEach(this.widgetList, (item: Record<string, string>) => {
          Column({ space: this.WIDGET_SPACE }) {
            Image($r(item.icon)).width(this.WIDGET_ROW_SIZE).height(this.WIDGET_ROW_SIZE)
            Text(item.name)
              .fontWeight(FontWeight.Medium)
              .fontSize(this.WIDGET_FONT_MINI)
          }
          .onClick(() => {
            postCardAction(this, {
              action: 'router',
              abilityName: 'EntryAbility',
              params: { message: item.serviceId, }
            });
          })
        })
      }
      .width(this.FULL)
      .layoutWeight(1)
      .justifyContent(FlexAlign.SpaceAround)
      .borderRadius(8)
    }
    .padding({left: this.WIDGET_PADDING, right: this.WIDGET_PADDING})
    .width(this.FULL)
    .height(this.FULL)
    .alignItems(HorizontalAlign.Start)
  }
}