import { AddToBookShelf, BookApi, BookInfo, Constants, NavHeaderBar, TCRouter } from 'common'
import {
  ColorMetrics,
  LengthMetrics,
  ToolBarV2,
  ToolBarV2Item,
  ToolBarV2ItemImage,
  ToolBarV2ItemText,
  ToolBarV2Modifier
} from '@kit.ArkUI';

@Builder
export function ReadHistoryBuilder() {
  ReadHistory();
}

@ComponentV2
export struct ReadHistory {
  @Local historyBooks: BookInfo[] = [];
  @Local checkedList: boolean[] = [];
  @Local isEdit: boolean = false;
  @Local showCheckbox: boolean = false
  bottomRectHeight: number = AppStorage.get('bottomRectHeight') as number
  @Local toolbarList: ToolBarV2Item[] = [];
  private toolBarModifier: ToolBarV2Modifier =
    new ToolBarV2Modifier()
      .backgroundColor(ColorMetrics.resourceColor($r('sys.color.comp_background_list_card')))
      .stateEffect(true).padding(LengthMetrics.vp(12))

  async aboutToAppear(): Promise<void> {
    const hisRsp = await BookApi.getBooksShelfList('historyBooks', Constants.API_GET_BOOK_HISTORY_PATH, '');
    this.historyBooks = hisRsp.books;
    this.checkedList = new Array(this.historyBooks.length).fill(false);
    this.toolbarListTab();
  }

  toolbarListTab() {
    this.toolbarList.push(
      new ToolBarV2Item({
        content: new ToolBarV2ItemText({
          text: $r('app.string.select_all'),
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
          text: $r('app.string.delete'),
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
                  let tmp: BookInfo[] = [];
                  for (let i = 0; i < this.historyBooks.length; i++) {
                    if (!this.checkedList[i]) {
                      tmp.push(this.historyBooks[i]);
                    }
                  }
                  this.historyBooks.length = tmp.length;
                  for (let i = 0; i < tmp.length; i++) {
                    this.historyBooks[i] = tmp[i];
                  }
                  AppStorage.set('historyBooks', tmp);
                  this.checkedList = new Array(this.historyBooks.length).fill(false);
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
    Text('最近七天')
      .fontWeight(FontWeight.Regular)
      .fontSize($r('sys.float.Caption_L'))
      .fontColor($r('sys.color.font_secondary'))
      .alignSelf(ItemAlign.Start)
      .margin({ bottom: 8 })
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: $r('app.string.reading_history'),
          hasBgColor: false,
          editBuilder: () => {
            this.editButton();
          }
        })

        Column() {
          Stack({ alignContent: Alignment.Bottom }) {
            Column() {
              List() {
                ListItemGroup({ header: this.tipHeader(), space: 8 }) {
                  ForEach(this.historyBooks, (item: BookInfo, index: number) => {
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
                          .id('checkbox')
                          .alignRules({
                            center: { anchor: '__container__', align: VerticalAlign.Center },
                            left: { anchor: '__container__', align: HorizontalAlign.Start }
                          })
                        Image($r(item?.coverUrl?.toString()))
                          .width(68)
                          .height(90)
                          .margin({ left: this.isEdit ? 34 : 0 })
                          .borderRadius(8)
                          .id('img')
                          .alignRules({
                            left: { anchor: '__container__', align: HorizontalAlign.Start },
                            center: { anchor: '__container__', align: VerticalAlign.Center }
                          })
                          .animation({ duration: 300 })
                        Column() {
                          Row() {
                            Text(item.name)
                              .fontSize($r('sys.float.Body_M'))
                              .fontWeight(FontWeight.Medium)
                              .fontColor($r('sys.color.font_primary'))
                            Text(item.rate + '分')
                              .fontSize($r('sys.float.Subtitle_M'))
                              .fontWeight(FontWeight.Medium)
                              .fontColor($r('sys.color.font_primary'))
                          }
                          .width('calc(100% - 30vp)')
                          .justifyContent(FlexAlign.SpaceBetween)

                          Text(item.description || $r('app.string.no_briefly'))
                            .fontSize($r('sys.float.Body_S'))
                            .fontWeight(FontWeight.Regular)
                            .fontColor($r('sys.color.font_secondary'))
                            .ellipsisMode(EllipsisMode.END)
                            .textOverflow({ overflow: TextOverflow.Ellipsis })
                            .maxLines(1)
                          Text() {
                            Span(item.category)
                            Span(item.count)
                            Span($r('app.string.ten_thousand_words'))
                          }
                          .fontSize($r('sys.float.Body_S'))
                          .fontWeight(FontWeight.Regular)
                          .fontColor($r('sys.color.font_secondary'))

                          Text(item.readProgress ? item.readProgress :
                            $r('app.string.read_status_unread'))
                            .fontSize($r('sys.float.Body_S'))
                            .fontWeight(FontWeight.Regular)
                            .fontColor($r('sys.color.font_secondary'))
                        }
                        .height('100%')
                        .id('bookDes')
                        .alignItems(HorizontalAlign.Start)
                        .margin({ left: 12 })
                        .alignRules({
                          left: { anchor: 'img', align: HorizontalAlign.End },
                          top: { anchor: '__container__', align: VerticalAlign.Top },
                          right: { anchor: '__container__', align: HorizontalAlign.End },
                        })
                        .justifyContent(FlexAlign.SpaceBetween)

                        Row() {
                          AddToBookShelf({ book: item })
                        }
                        .justifyContent(FlexAlign.Center)
                        .alignRules({
                          bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
                          right: { anchor: '__container__', align: HorizontalAlign.End }
                        })
                        .id('addIcon')
                      }
                      .height(122)
                      .padding(15)
                      .borderRadius(16)
                      .backgroundColor($r('sys.color.comp_background_list_card'))
                      .onClick(() => {
                        if (this.isEdit) {
                          this.checkedList[index] = !this.checkedList[index]
                        } else {
                          TCRouter.pushByLogin(Constants.READ_KIT_ROUTER, item);
                        }
                      })
                    }
                  }, (item: BookInfo) => item.id + '_' + item.name)
                }

                ListItem()
                  .height(this.bottomRectHeight + (this.showCheckbox ? 70 : 0))
              }
              .align(Alignment.Top)
              .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
              .scrollBar(BarState.Off)
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