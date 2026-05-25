import {
  BookApi, BookInfo, Constants, GroupBook, NavHeaderBar, TCRouter
} from 'common'
import {
  ColorMetrics,
  LengthMetrics,
  ToolBarV2,
  ToolBarV2Item,
  ToolBarV2ItemImage,
  ToolBarV2ItemText,
  ToolBarV2Modifier
} from '@kit.ArkUI';
import { baseActionSheet, UserInfo } from 'base_common';
import { AggregatedPaymentPicker, ChannelType, MockApi, WxExtraInfo } from 'aggregated_payment';
import { emitter } from '@kit.BasicServicesKit';

@Builder
export function MyDownloadPageBuilder() {
  MyDownloadPage();
}

@ComponentV2
export struct MyDownloadPage {
  @Local downloadBooks: GroupBook[] = [];
  @Local checkedList: boolean[] = [];
  @Local isEdit: boolean = false;
  @Local showCheckbox: boolean = false
  bottomRectHeight: number = AppStorage.get('bottomRectHeight') as number
  @Local toolbarList: ToolBarV2Item[] = [];
  @Local userInfo: UserInfo = AppStorage.get<UserInfo>('userInfo')!
  @Local isMemberShip: boolean = false;
  private toolBarModifier: ToolBarV2Modifier =
    new ToolBarV2Modifier()
      .backgroundColor(ColorMetrics.resourceColor($r('sys.color.comp_background_list_card')))
      .stateEffect(true).padding(LengthMetrics.vp(12))

  async aboutToAppear(): Promise<void> {
    const favRsp = await BookApi.getBooksShelfGroup('favBooks', Constants.API_GET_BOOK_FAVOURITE_PATH, '');
    this.downloadBooks = favRsp.books.filter(book => book.isDownload);
    const notFavBookDL: GroupBook[] | undefined = AppStorage.get('downloadBooks')
    if (notFavBookDL) {
      notFavBookDL.forEach((item: GroupBook) => {
        if (!this.downloadBooks.some(book => book.singleBook?.id === item.singleBook?.id)) {
          this.downloadBooks.push(item)
        }
      })
    }
    this.checkedList = new Array(this.downloadBooks.length).fill(false);
    this.toolbarListTab();
    this.isMemberShip = this.userInfo.isMembership;
    try {
      emitter.on('bookBuy', async () => {
        const favRsp = await BookApi.getBooksShelfGroup('favBooks', Constants.API_GET_BOOK_FAVOURITE_PATH, '');
        this.downloadBooks = favRsp.books.filter(book => book.isDownload);
        const notFavBookDL: GroupBook[] | undefined = AppStorage.get('downloadBooks')
        if (notFavBookDL) {
          notFavBookDL.forEach((item: GroupBook) => {
            if (!this.downloadBooks.some(book => book.singleBook?.id === item.singleBook?.id)) {
              this.downloadBooks.push(item)
            }
          })
        }
      })
    } catch (e) {
      console.error('Failed to emitter on bookBuy. Cause: ' + JSON.stringify(e));
    }
  }

  toolbarListTab() {
    this.toolbarList.push(
      new ToolBarV2Item({
        content: new ToolBarV2ItemText({
          text: '全选',
        }),
        icon: new ToolBarV2ItemImage({
          src: $r('sys.media.ohos_ic_public_select_all'),
        }),
        action: () => {
          const allTrue = this.checkedList.every(Boolean);
          this.checkedList = this.checkedList.map(() => !allTrue);
        },
      }))
    this.toolbarList.push(
      new ToolBarV2Item({
        content: new ToolBarV2ItemText({
          text: '删除',
        }),
        icon: new ToolBarV2ItemImage({
          src: $r('app.media.ic_public_trash'),
        }),
        action: () => {
          // 弹窗 确认删除
          const checkedCount = this.checkedList.filter(Boolean).length;
          if (checkedCount === 0) {
            return;
          }
          this.getUIContext().showAlertDialog({
            message: $r('app.string.delete_confirmation_message', checkedCount),
            buttons: [
              {
                value: $r('app.string.cancel'),
                fontColor: $r('sys.color.font_primary'),
                action: () => {
                }
              },
              {
                value: $r('app.string.delete'),
                fontColor: $r('sys.color.warning'),
                action: () => {
                  this.downloadBooks = this.downloadBooks.map((book, index) => {
                    if (this.checkedList[index]) {
                      book.isDownload = false;
                    }
                    return book;
                  }).filter(book => book.isDownload);
                  this.checkedList = new Array(this.downloadBooks.length).fill(false);
                }
              },
            ],
            cancel: () => {
            }
          });
        },
      }))
  }

  startEdit() {
    this.showCheckbox = true
    this.isEdit = true
  }

  stopEdit() {
    this.isEdit = false
    // 等动画跑完再隐藏checkbox
    setTimeout(() => {
      if (!this.isEdit) {
        this.showCheckbox = false
      }
    }, 300)
  }

  @Builder
  editButton() {
    SymbolGlyph(this.isEdit ? $r('sys.symbol.square_and_pencil_fill') : $r('sys.symbol.square_and_pencil'))
      .fontSize($r('sys.float.Title_M'))
      .fontColor(this.isEdit ? [$r('sys.color.multi_color_08')] : [$r('sys.color.icon_primary')])
      .width(40)
      .height(40)
      .borderRadius(1000)
      .padding(8)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        if (this.isEdit) {
          this.stopEdit();
        } else {
          this.startEdit();
        }
      })
  }

  @Builder
  tipHeader() {
    Row({ space: 8 }) {
      Text($r('app.string.book_downloaded_count', this.downloadBooks.length))
        .fontColor($r('sys.color.font_secondary'))
        .fontSize($r('sys.float.Caption_L'))
        .fontWeight(FontWeight.Regular)
        .lineHeight(16)
      Divider().vertical(true).color($r('sys.color.comp_divider')).strokeWidth('1px').height(16)
      Text($r('app.string.book_total_count', this.downloadBooks.length))
        .fontColor($r('sys.color.font_secondary'))
        .fontSize($r('sys.float.Caption_L'))
        .fontWeight(FontWeight.Regular)
        .lineHeight(16)
    }
    .margin({ bottom: 8 })
  }

  @Builder
  downloadSheet(book?: BookInfo) {
    DownloadDialog({ book: book, bookPrice: 360, needPay: 18.9 }).backgroundColor($r('sys.color.background_secondary'))
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: $r('app.string.my_download'),
          hasBgColor: false,
          editBuilder: () => {
            this.editButton();
          }
        })

        Column() {
          Stack({ alignContent: Alignment.Bottom }) {
            Column() {
              List({ space: 8 }) {
                ListItemGroup({ header: this.tipHeader(), space: 8 }) {
                  ForEach(this.downloadBooks, (item: GroupBook, index: number) => {
                    ListItem() {
                      RelativeContainer() {
                        Checkbox()
                          .select(this.checkedList[index])
                          .selectedColor($r('sys.color.multi_color_08'))
                          .onChange((value: boolean) => {
                            if (this.isEdit) {
                              this.checkedList[index] = value
                            }
                          })
                          .visibility(this.showCheckbox ? Visibility.Visible : Visibility.None)
                          .id('downloadCheckbox')
                          .alignRules({
                            center: { anchor: '__container__', align: VerticalAlign.Center },
                            left: { anchor: '__container__', align: HorizontalAlign.Start }
                          })
                        Image($r(item.singleBook?.coverUrl?.toString()))
                          .width(68)
                          .height(90)
                          .margin({ left: this.isEdit ? 34 : 0 })
                          .borderRadius(8)
                          .id('downloadImg')
                          .alignRules({
                            left: { anchor: '__container__', align: HorizontalAlign.Start },
                            center: { anchor: '__container__', align: VerticalAlign.Center }
                          })
                          .animation({ duration: 300 })
                        Column() {
                          Row() {
                            Text(item.singleBook?.name)
                              .fontSize($r('sys.float.Body_M'))
                              .fontWeight(FontWeight.Medium)
                              .fontColor($r('sys.color.font_primary'))
                          }
                          .width('calc(100% - 30vp)')
                          .justifyContent(FlexAlign.SpaceBetween)

                          Text() {
                            Span(item.singleBook?.category)
                            Span(item.singleBook?.count)
                            Span($r('app.string.ten_thousand_words'))
                          }
                          .fontSize($r('sys.float.Body_S'))
                          .fontWeight(FontWeight.Regular)
                          .fontColor($r('sys.color.font_secondary'))

                          Row({ space: 4 }) {
                            if (item.isDownload) {
                              Row()
                            } else {
                              Text('内存大小')
                                .fontSize($r('sys.float.Body_S'))
                                .fontWeight(FontWeight.Regular)
                                .fontColor($r('sys.color.font_secondary'))
                              Divider()
                                .vertical(true)
                                .color($r('sys.color.comp_divider'))
                                .strokeWidth('1px')
                                .height(16);
                              Text('已下载' + item.singleBook?.downloadProgress + '')
                                .fontSize($r('sys.float.Body_S'))
                                .fontWeight(FontWeight.Regular)
                                .fontColor($r('sys.color.font_secondary'))
                            }
                          }
                          .height(16)

                          if (item.isDownload &&
                            (item.singleBook?.isFree === '0' || item.singleBook?.isBuy || this.isMemberShip)) {
                            Row({ space: 4 }) {
                              Text(item.singleBook?.usageMemory)
                                .fontSize($r('sys.float.Body_S'))
                                .fontWeight(FontWeight.Regular)
                                .fontColor($r('sys.color.font_secondary'))
                              Divider()
                                .vertical(true)
                                .color($r('sys.color.comp_divider'))
                                .strokeWidth('1px')
                                .height(16);
                              Text('已下载')
                                .fontSize($r('sys.float.Body_S'))
                                .fontWeight(FontWeight.Regular)
                                .fontColor($r('sys.color.font_secondary'))
                            }
                          } else {
                            Text('点击购买并下载剩余章节')
                              .fontSize($r('sys.float.Body_S'))
                              .fontWeight(FontWeight.Regular)
                              .fontColor($r('sys.color.multi_color_08'))
                              .onClick(() => {
                                baseActionSheet.show({
                                  id: 'BuyBookSheet',
                                  title: { title: '购买章节' },
                                  height: SheetSize.FIT_CONTENT,
                                  preferType: SheetType.CENTER,
                                  backgroundColor: $r('sys.color.background_secondary'),
                                  customContent: () => {
                                    this.downloadSheet(item?.singleBook)
                                  },
                                })
                              })
                          }
                        }
                        .height('100%')
                        .id('downloadDes')
                        .alignItems(HorizontalAlign.Start)
                        .margin({ left: 12 })
                        .alignRules({
                          left: { anchor: 'downloadImg', align: HorizontalAlign.End },
                          top: { anchor: '__container__', align: VerticalAlign.Top },
                          right: { anchor: '__container__', align: HorizontalAlign.End },
                        })
                        .justifyContent(FlexAlign.SpaceBetween)
                      }
                      .height(122)
                      .padding(15)
                      .borderRadius(16)
                      .backgroundColor($r('sys.color.comp_background_list_card'))
                      .onClick(() => {
                        if (this.isEdit) {
                          this.checkedList[index] = !this.checkedList[index]
                        }
                      })
                    }
                  }, (item: GroupBook) => item.singleBook?.name! + '_' + item.singleBook?.coverUrl!)
                }

                ListItem()
                  .height(this.bottomRectHeight + (this.showCheckbox ? 70 : 0))
              }
              .align(Alignment.Top)
              .scrollBar(BarState.Off)
              .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
              .layoutWeight(1)
            }
            .height('100%')

            if (this.isEdit) {
              Row() {
                ToolBarV2({
                  toolBarModifier: this.toolBarModifier,
                  toolBarList: this.toolbarList,
                })
                  .height(60)
              }
              .width(136)
              .height(56)
              .borderRadius(28)
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Center)
              .clip(true)
              .margin({ bottom: this.bottomRectHeight })
            }
          }
          .layoutWeight(1)
        }
        .layoutWeight(1)
        .padding({ left: 16, right: 16 })

      }
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}

// 下载弹窗
@ComponentV2
export struct DownloadDialog {
  @Param book: BookInfo = new BookInfo();
  @Param needPay: number = 0;
  @Param bookPrice: number = 360;
  @Param coupon: number = 0;
  @Local userInfo: UserInfo = AppStorage.get<UserInfo>('userInfo')!
  bottomRectHeight: number = AppStorage.get('bottomRectHeight') as number
  @Local wxOrderReq: WxExtraInfo = new WxExtraInfo();
  @Local aliOrderStr: string = '';
  @Local hwOrderStr: string = '';
  @Local isShow: boolean = false;

  updateBookCoins(amount: number) {
    try {
      // 更新用户书币余额
      const userInfoFromStorage: UserInfo = AppStorage.get('userInfo') as UserInfo;
      if (userInfoFromStorage) {
        const currentCoins = typeof userInfoFromStorage.bookCoins === 'number' ? userInfoFromStorage.bookCoins : 100;
        userInfoFromStorage.bookCoins = currentCoins + amount;
        AppStorage.setOrCreate('userInfo', userInfoFromStorage);
        AppStorage.setOrCreate('bookCoins', userInfoFromStorage.bookCoins);
      }
      // 触发事件通知其他页面更新余额
      emitter.emit(Constants.LOGIN_CHANGE);
    } catch (e) {
      console.error('Failed to emitter emit login change. Cause: ' + JSON.stringify(e));
    }
  }

  private updateBookCoinsAndSave(price: number): void {
    if (this.userInfo) {
      try {
        this.userInfo.bookCoins -= price;
        AppStorage.set('userInfo', this.userInfo);
        emitter.emit({ eventId: 14 });
      } catch (error) {
        console.error('Failed to emitter emit coins change. Cause: ' + JSON.stringify(error));
      }
    }
  }

  build() {
    Column() {
      Column({ space: 12 }) {
        Row({ space: 12 }) {
          Image($r(this.book?.coverUrl?.toString()))
            .width(68)
            .height(90)
            .borderRadius(8)
          Text(this.book.name)
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Subtitle_M'))
            .fontWeight(FontWeight.Medium)
        }

        Divider().vertical(false).color($r('sys.color.comp_divider')).strokeWidth('1px');

        Row({ space: 8 }) {
          Text($r('app.string.balance_deduction_remaining_payment'))
            .fontColor($r('sys.color.font_secondary'))
            .fontSize($r('sys.float.Caption_L'))
            .fontWeight(FontWeight.Regular)
            .lineHeight(16)

          SymbolGlyph($r('sys.symbol.exclamationmark_circle'))
            .fontSize(16)
            .fontColor([$r('sys.color.icon_secondary')])
        }
        .height(24)

        Row({ space: 4 }) {
          Text('￥')
            .fontSize($r('sys.float.Title_S'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_secondary'))
          Text((this.bookPrice - this.userInfo.bookCoins > 0 ? (this.bookPrice - this.userInfo.bookCoins) / 10 :
            0).toFixed(2))
            .fontSize($r('sys.float.Title_L'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_secondary'))
        }

        Divider().vertical(false).color($r('sys.color.comp_divider')).strokeWidth('1px');

        Row() {
          Text($r('app.string.product_amount'))
            .fontColor($r('sys.color.font_secondary'))
            .fontSize($r('sys.float.Caption_L'))
            .fontWeight(FontWeight.Regular)
            .lineHeight(16)
          Text($r('app.string.read_coin', this.bookPrice))
            .fontColor($r('sys.color.font_secondary'))
            .fontSize($r('sys.float.Caption_L'))
            .fontWeight(FontWeight.Regular)
            .lineHeight(16)
        }
        .height(24)
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Row() {
          Text($r('app.string.balance_deduction'))
            .fontColor($r('sys.color.font_secondary'))
            .fontSize($r('sys.float.Caption_L'))
            .fontWeight(FontWeight.Regular)
            .lineHeight(16)
          Row({ space: 10 }) {
            Text($r('app.string.read_coin',
              this.bookPrice > this.userInfo.bookCoins ? this.userInfo.bookCoins : this.bookPrice))
              .fontColor($r('sys.color.font_secondary'))
              .fontSize($r('sys.float.Caption_L'))
              .fontWeight(FontWeight.Regular)
              .lineHeight(16)
            // 抵扣券待定
            if (this.coupon) {
              Divider().vertical(true).color($r('sys.color.comp_divider')).strokeWidth('1px').height(16);
              Text($r('app.string.voucher_coupon', this.coupon))
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.Caption_L'))
                .fontWeight(FontWeight.Regular)
                .lineHeight(16)
            }
          }
        }
        .height(24)
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('100%')
      .padding({
        left: 12,
        right: 12,
        top: 16,
        bottom: 16
      })
      .borderRadius(16)
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .alignItems(HorizontalAlign.Start)

      Button($r('app.string.membership_promo_message', 29))
        .fontColor($r('sys.color.font_on_primary'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .backgroundColor($r('sys.color.multi_color_08'))
        .width(328)
        .margin({ top: 24, bottom: 12 })
        .onClick(() => {
          baseActionSheet.close('BuyBookSheet');
          TCRouter.pushByLogin(Constants.MEMBER_CENTER_ROUTE);
        })
      Button($r('app.string.purchase_book_unlimited_reading'))
        .fontColor($r('sys.color.multi_color_08'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .width(328)
        .margin({ bottom: 17 + this.bottomRectHeight })
        .onClick(() => {
          if (this.bookPrice - this.userInfo.bookCoins <= 0) {
            const price = this.userInfo.bookCoins - this.bookPrice;
            this.updateBookCoinsAndSave(price);
          } else {
            // 获取各支付方式的预下单信息
            this.wxOrderReq = MockApi.getWxPreOrderInfo();
            this.hwOrderStr = MockApi.getHuaweiOrderInfo();
            MockApi.getAliPreOrderInfo().then((res) => {
              this.aliOrderStr = res;
              this.isShow = true;
            });
            this.updateBookCoinsAndSave(this.userInfo.bookCoins);
          }
          baseActionSheet.close('BuyBookSheet');
        })
    }
    .padding({ left: 16, right: 16 })
    .backgroundColor($r('sys.color.background_secondary'))
    .bindSheet($$this.isShow, this.paymentChannelSheet(), {
      preferType: SheetType.CENTER,
      showClose: false,
      height: '45%',
      onWillDismiss: (dismissSheetAction: DismissSheetAction) => {
        if (dismissSheetAction.reason === DismissReason.TOUCH_OUTSIDE) {
          dismissSheetAction.dismiss()
        }
      }
    })
  }

  @Builder
  paymentChannelSheet() {
    AggregatedPaymentPicker({
      amount: (this.bookPrice - this.userInfo.bookCoins) / 10 || 0.01,
      channelInfo: [{
        channelType: ChannelType.HUAWEI_PAY,
        name: '华为支付',
        icon: $r('app.media.hwpay'),
        preOrderInfo: this.hwOrderStr,
      }, {
        channelType: ChannelType.WECHAT_PAY,
        preOrderInfo: this.wxOrderReq,
        appId: MockApi.WX_APP_ID,
        icon: $r('app.media.wechat'),
        name: '微信支付',
        event: () => {
          this.isShow = false;
        },
      }, {
        channelType: ChannelType.ALI_PAY,
        name: '支付宝支付',
        icon: $r('app.media.alipay'),
        preOrderInfo: this.aliOrderStr,
      }],
      paySuccessEvent: (type: ChannelType) => {
        this.isShow = false;
        this.book.isBuy = true;
        try {
          emitter.emit('bookBuy')
        } catch (e) {
          console.error('Failed to emitter emit bookBuy. Cause: ' + JSON.stringify(e));
        }
        baseActionSheet.close('BuyBookSheet');
      },
    });
  }
}