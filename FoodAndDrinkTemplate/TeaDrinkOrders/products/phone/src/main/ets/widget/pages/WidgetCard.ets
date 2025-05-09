let storageUpdateByMsg = new LocalStorage();

@Entry(storageUpdateByMsg)
@Component
struct WidgetCard {
  @LocalStorageProp('storeName') storeName: ResourceStr = $r('app.string.storeName');
  @LocalStorageProp('orderState') orderState: boolean = false;
  @LocalStorageProp('orderId') orderId: string = '';
  @LocalStorageProp('storeType') storeType: number = 0;
  @LocalStorageProp('orderPickNum') orderPickNum: string = '';
  @LocalStorageProp('makingNum') makingNum: number = 0;
  @LocalStorageProp('makingWaitMin') makingWaitMin: number = 0;
  @LocalStorageProp('deliveryTime') deliveryTime: string = '';
  @LocalStorageProp('distance') distance: string = '';
  /*
   * The display priority value is 1.
   */
  readonly DISPLAY_PRIORITY_ONE: number = 1;
  /*
  /*
   * The flex grow value is 1.
   */
  readonly FLEX_GROW_VALUE: number = 1;
  /*
   * The width or height full percentage setting.
   */
  readonly FULL_PERCENT: string = '100%';
  /*
   * The action type.
   */
  readonly ACTION_TYPE: string = 'router';
  /*
   * The ability name.
  */
  readonly ABILITY_NAME: string = 'EntryAbility';
  /*
   * The order type takeaway.
   */
  readonly TAKEAWAY_DELIVERY: number = 1;

  build() {
    if (this.orderState) {
      this.orderCard();
    } else {
      this.normalCard();
    }
  }

  @Builder
  orderCard() {
    Column() {
      this.storeTitle();
      Column() {
        if (this.storeType === this.TAKEAWAY_DELIVERY) {
          Text($r('app.string.form_title_takeaway'))
            .fontColor('#0C0634')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
          Text() {
            Span($r('app.string.delivery_time')).fontColor('#0C0634')
            Span(this.deliveryTime).fontColor($r('app.color.fontMainColor'))
          }
          .fontSize(10)
          .margin({ top: 4 })

          Text($r('app.string.delivery_distance', this.distance))
            .fontColor('#0C0634')
            .fontSize(8)
            .margin({ top: 8 })
            .lineHeight(20)
        } else {
          Text($r('app.string.order_pick_num'))
            .fontColor('#0C0634')
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium);
          Text(this.orderPickNum)
            .fontColor('#0C0634')
            .fontSize(20)
            .height(30)
            .fontWeight(FontWeight.Medium)
            .margin({ top: 2 })
          Row() {
            Text($r('app.string.form_making_desc1')).fontColor('#0C0634').fontSize(8).fontWeight(FontWeight.Medium)
            Text(this.makingNum.toString())
              .fontColor($r('app.color.fontMainColor'))
              .fontSize(8)
              .fontWeight(FontWeight.Medium)
              .margin({ left: 2, right: 2 })
            Text($r('app.string.form_making_desc2')).fontColor('#0C0634').fontSize(8).fontWeight(FontWeight.Medium)
            Text($r('app.string.form_making_desc3')).fontColor('#0C0634').fontSize(8).fontWeight(FontWeight.Medium)
            Text(this.makingWaitMin.toString())
              .fontColor($r('app.color.fontMainColor'))
              .fontSize(8)
              .fontWeight(FontWeight.Medium)
              .margin({ left: 2, right: 2 })
            Text($r('app.string.form_making_desc4')).fontColor('#0C0634').fontSize(8).fontWeight(FontWeight.Medium)
          }

        }
      }.margin({ top: 8 }).alignItems(HorizontalAlign.Start).width(this.FULL_PERCENT).layoutWeight(1);

      Row() {
        Text($r('app.string.goOrderDetail'))
          .fontSize($r('sys.float.Body_S'))
          .fontWeight(FontWeight.Medium)
          .fontColor('#486602')
          .textAlign(TextAlign.Center)
      }
      .justifyContent(FlexAlign.Center)
      .width(this.FULL_PERCENT)
      .height(28)
      .backgroundColor('#CCFFFFFF')
      .margin({ top: 20 })
      .borderRadius(14)
      .onClick(() => {
        postCardAction(this, {
          action: this.ACTION_TYPE,
          abilityName: this.ABILITY_NAME,
          params: { url: 'OrderDetailPage', params: { orderId: this.orderId } },
        });
      });
    }
    .backgroundImage($r('app.media.card_bg'))
    .backgroundImageSize(ImageSize.Cover)
    .width(this.FULL_PERCENT)
    .height(this.FULL_PERCENT)
    .displayPriority(this.DISPLAY_PRIORITY_ONE)
    .flexGrow(this.FLEX_GROW_VALUE)
    .padding(12)
    .onClick(() => {
      postCardAction(this, {
        action: this.ACTION_TYPE,
        abilityName: this.ABILITY_NAME,
        params: { targetPage: 'funB' },
      });
    });
  }

  @Builder
  normalCard() {
    Column() {
      this.storeTitle();
      List({ space: 8 }) {
        ListItem() {
          Image($r('app.media.ic_card_img1')).width(52).height(52).borderRadius(12);
        };

        ListItem() {
          Image($r('app.media.ic_card_img2')).width(52).height(52).borderRadius(12);
        };

        ListItem() {
          Image($r('app.media.ic_card_img3')).width(52).height(52).borderRadius(12);
        };

        ListItem() {
          Image($r('app.media.ic_card_img4')).width(52).height(52).borderRadius(12);
        };
      }.listDirection(Axis.Horizontal).margin({ top: 12 }).layoutWeight(1).scrollBar(BarState.Off);

      Row() {
        Text($r('app.string.order'))
          .fontSize($r('sys.float.Body_S'))
          .fontWeight(FontWeight.Medium)
          .fontColor('#486602')
      }
      .margin({ top: 14 })
      .justifyContent(FlexAlign.Center)
      .width(this.FULL_PERCENT)
      .height(28)
      .borderRadius(14)
      .backgroundColor('#CCFFFFFF')
      .onClick(() => {
        postCardAction(this, {
          action: this.ACTION_TYPE,
          abilityName: this.ABILITY_NAME,
          params: { targetPage: 'funB' },
        });
      });
    }
    .width(this.FULL_PERCENT)
    .height(this.FULL_PERCENT)
    .backgroundImage($r('app.media.card_bg'))
    .backgroundImageSize(ImageSize.Cover)
    .displayPriority(this.DISPLAY_PRIORITY_ONE)
    .flexGrow(this.FLEX_GROW_VALUE)
    .padding(12)
    .onClick(() => {
      postCardAction(this, {
        action: this.ACTION_TYPE,
        abilityName: this.ABILITY_NAME,
        params: { targetPage: 'funB' },
      });
    });
  }

  @Builder
  storeTitle() {
    Row() {
      Image($r('app.media.card_store_logo')).width(20).height(20).borderRadius(4);
      Text(this.storeName ? this.storeName : $r('app.string.storeName'))
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .lineHeight(20)
        .layoutWeight(1)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ left: 8 });
    }.width(this.FULL_PERCENT);
  }
}