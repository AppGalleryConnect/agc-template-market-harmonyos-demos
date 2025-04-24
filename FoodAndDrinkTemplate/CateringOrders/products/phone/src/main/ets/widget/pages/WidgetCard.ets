let storageUpdateByMsg = new LocalStorage();

@Entry(storageUpdateByMsg)
@Component
struct WidgetCard {
  @LocalStorageProp('storeName') storeName: ResourceStr = $r('app.string.storeName');
  @LocalStorageProp('orderState') orderState: boolean = false;
  @LocalStorageProp('orderId') orderId: string = '';
  @LocalStorageProp('storeType') storeType: string = '';
  @LocalStorageProp('storeTable') storeTable: string = '';
  @LocalStorageProp('orderPickNum') orderPickNum: string = '';
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
   * The store type scan.
   */
  readonly STORE_TYPE_SCAN: string = '1';

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
        if (this.storeType === this.STORE_TYPE_SCAN) {
          Image($r('app.media.card_store_table')).width(18).height(18);
          Text(this.storeTable)
            .fontColor($r('app.color.store_table_font'))
            .fontSize(20)
            .lineHeight(30)
            .fontWeight(FontWeight.Medium)
            .margin({ top: 2 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
        } else {
          Text($r('app.string.order_pick_num'))
            .fontColor($r('sys.color.font_secondary'))
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium);
          Text(this.orderPickNum)
            .fontColor($r('app.color.store_table_font'))
            .fontSize(20)
            .lineHeight(30)
            .fontWeight(FontWeight.Medium)
            .margin({ top: 2 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
        }
      }.margin({ top: 8 }).alignItems(HorizontalAlign.Start).width(this.FULL_PERCENT).layoutWeight(1);

      Row() {
        Text($r('app.string.goOrderDetail'))
          .fontSize($r('sys.float.Body_S'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.orderBtn'))
      }
      .justifyContent(FlexAlign.Center)
      .width(this.FULL_PERCENT)
      .padding({ top: 4, bottom: 4 })
      .backgroundColor($r('app.color.goOrderDetailBg'))
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
          Image($r('app.media.ic_card_img1')).width(52).height(52).borderRadius(8);
        };

        ListItem() {
          Image($r('app.media.ic_card_img2')).width(52).height(52).borderRadius(8);
        };

        ListItem() {
          Image($r('app.media.ic_card_img3')).width(52).height(52).borderRadius(8);
        };

        ListItem() {
          Image($r('app.media.ic_card_img4')).width(52).height(52).borderRadius(8);
        };
      }.listDirection(Axis.Horizontal).margin({ top: 12 }).layoutWeight(1).scrollBar(BarState.Off);

      Row() {
        Text($r('app.string.order'))
          .fontSize($r('sys.float.Body_S'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.comp_background_list_card'))
      }
      .margin({ top: 14 })
      .padding({
        top: 4,
        bottom: 4,
      })
      .justifyContent(FlexAlign.Center)
      .width(this.FULL_PERCENT)
      .borderRadius(14)
      .linearGradient({
        direction: GradientDirection.Bottom, // 渐变方向,从上向下
        colors: [['#FFBB81', 0], ['#EC710B', 1]], //渐变颜色
      })
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
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ left: 8 });
    }.width(this.FULL_PERCENT);
  }
}