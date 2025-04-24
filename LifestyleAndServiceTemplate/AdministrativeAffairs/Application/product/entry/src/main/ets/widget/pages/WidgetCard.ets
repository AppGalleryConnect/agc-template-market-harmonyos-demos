@Entry
@Component
struct WidgetCard {
  readonly WIDGET_ICON_SIZE: number = 18;
  readonly WIDGET_FONT_SMALL: number = 14;
  readonly WIDGET_FONT_MINI: number = 12;
  readonly WIDGET_ROW_SIZE: number = 24;
  readonly WIDGET_WIDTH: number = 64;
  readonly WIDGET_HEIGHT: number = 72;
  readonly WIDGET_RADIUS: number = 15;
  readonly WIDGET_PADDING: number = 10;
  readonly WIDGET_SPACE: number = 10;
  readonly WIDGET_FULL: string = '100%';
  @State widgetList: Record<string, string>[] = [
    {
      'serviceId': 'qr_code',
      'name': '医保码',
      'icon': 'app.media.qr_code',
    },
    {
      'serviceId': 'insurance_information',
      'name': '参保信息',
      'icon': 'app.media.insurance_Information',
    },
    {
      'serviceId': 'consumption_record',
      'name': '消费记录',
      'icon': 'app.media.consumption_record',
    },
    {
      'serviceId': 'designated_hospital',
      'name': '定点医院',
      'icon': 'app.media.hospital',
    },
  ]

  getWidgetColor(index: number): string {
    let colorList = ['#F2F9E5', '#ECFBFD', '#FFEFEF', '#ECFBFD']
    return colorList[index]
  }

  build() {
    Column() {
      Row() {
        Row({ space: this.WIDGET_SPACE }) {
          Image($r('app.media.logo_about')).width(this.WIDGET_ICON_SIZE).height(this.WIDGET_ICON_SIZE)
          Text($r('app.string.medical_insurance')).fontSize(this.WIDGET_FONT_SMALL)
        }

        Row({ space: this.WIDGET_SPACE }) {
          Text($r('app.string.medical_more')).fontSize(this.WIDGET_FONT_SMALL)
          Image($r('app.media.left_arrow')).width(this.WIDGET_ICON_SIZE).height(this.WIDGET_ICON_SIZE)
        }
        .onClick(() => {
          postCardAction(this, {
            action: 'router',
            abilityName: 'EntryAbility',
            params: {
              message: 'more',
            },
          });
        })
      }
      .width(this.WIDGET_FULL).justifyContent(FlexAlign.SpaceBetween)

      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        ForEach(this.widgetList, (item: Record<string, string>, index: number) => {
          Column({ space: this.WIDGET_SPACE }) {
            Image($r(item.icon)).width(this.WIDGET_ROW_SIZE).height(this.WIDGET_ROW_SIZE)
            Text(item.name).fontSize(this.WIDGET_FONT_MINI)
          }
          .width(this.WIDGET_WIDTH)
          .height(this.WIDGET_HEIGHT)
          .backgroundColor(this.getWidgetColor(index))
          .borderRadius(this.WIDGET_RADIUS)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            postCardAction(this, {
              action: 'router',
              abilityName: 'EntryAbility',
              params: {
                message: item.serviceId,
              },
            });
          })
        },(item: Record<string, string>) => item.name)
      }.height(this.WIDGET_FULL)
    }
    .padding(this.WIDGET_PADDING)
    .justifyContent(FlexAlign.SpaceBetween)
    .height(this.WIDGET_FULL)
  }
}