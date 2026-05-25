import { CustomContentDialog, window } from '@kit.ArkUI';
import { bookParser, readerCore, ReadPageComponent } from '@kit.ReaderKit';
import { common, ConfigurationConstant } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError, systemDateTime, emitter } from '@kit.BasicServicesKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { Logger } from '@hw-agconnect/ui-base';
import { ReaderToolBar } from 'reader_tool_bar';
import { baseActionSheet, UserInfo } from 'base_common';
import { ReviewDataUtil } from '../utils/ReviewDataUtil';
import {
  BookApi,
  BookInfo,
  BreakpointSystem,
  ColorModeClass,
  Constants,
  EpubUtils,
  GlobalContext,
  ImmersiveListener,
  ReadSet,
  TCRouter,
  WindowUtils
} from 'common';
import { ReaderTopCard } from './ReaderTopCard';
import { BookCoverCard } from './BookCoverCard';

@ComponentV2
export struct ReaderPage {
  @Local userInfo: UserInfo | undefined
  @Local book: BookInfo | undefined = undefined
  @Local catalogItemList: bookParser.CatalogItem[] = [];
  @Local lockedStatus: boolean[] = []
  @Local curChapterId: number = 0
  @Local readerComponentController: readerCore.ReaderComponentController =
    new readerCore.ReaderComponentController();
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  @Local bookParserHandler: bookParser.BookParserHandler | null = null;
  @Local spineList: bookParser.SpineItem[] = []
  private windowClass = this.context.windowStage.getMainWindowSync();
  @Local isLoading: boolean = true;
  @Local startTime: number = 0;
  @Local endTime: number = 0;
  @Local showController: boolean = false;
  @Local price: number = 10
  @Local isShowBuySheet: boolean = false
  @Provider('pageData') pageData: readerCore.PageDataInfo | undefined = undefined
  @Local readSet: ReadSet = AppStorageV2.connect(ReadSet, () => new ReadSet())!
  @Local readerSetting: readerCore.ReaderSetting = this.readSet.readerSetting
  @Local reminderTime: number = 0
  @Local timerId?: number
  @Local isNavigatingToReview: boolean = false;
  @Local isLastPage: boolean = false;
  @Local hasTriggeredReviewNavigation: boolean = false;
  @Local swiperIndex: number = 0
  @Local nightCurrentMode: ColorModeClass = AppStorageV2.connect(ColorModeClass, () => new ColorModeClass())!
  @Provider('nightMode') nightMode: boolean = AppStorage.get<boolean>('bookNightMode') ?? false;
  private lastSwipeTime: number = 0;
  private swipeThreshold: number = 50;
  private swipeStartX: number = 0;
  private hasTriggeredSwipe: boolean = false;
  private lastPageOffset: number = -1;
  private isOnClick: boolean = false;
  windowTopHeight: number = AppStorage.get('windowTopHeight') as number
  bottomRectHeight: number = AppStorage.get('bottomRectHeight') as number
  textClockController: TextClockController = new TextClockController();
  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      contentBuilder: () => {
        this.reminderDialogBuilder();
      },
    }),
    cancel: this.onAccept,
    alignment: DialogAlignment.Center,
    customStyle: false,
    cornerRadius: 32,
    width: 328,
    backgroundColor: Color.White,
  })

  @Monitor('nightCurrentMode.currentMode')
  onColorModeChange() {
    if (this.pageData) {
      this.readerSetting.nightMode =
        this.nightCurrentMode.currentMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK
      this.readerComponentController.setPageConfig(this.readerSetting)
    }
  }

  @Monitor('pageData')
  onPageDataChange() {
    const index = this.pageData?.resourceIndex;
    if (index === undefined || index === null) {
      this.book!.readProgress = '未读';
      return;
    }
    const total = this.spineList.length;
    if (index + 1 === total) {
      this.book!.readProgress = '已读完';
    } else {
      this.book!.readProgress =
        `已读${(((index + 1) / total) * 100).toFixed(2)}%`;
    }
  }

  onWindowsAppear(): void {
    WindowUtils.onWindowSizeChange(() => {
      this.readerSetting.viewPortWidth = WindowUtils.getWindowWidth()
      this.readerSetting.viewPortHeight = WindowUtils.getWindowHeight()
      if (this.swiperIndex > 0) {
        this.readerComponentController.setPageConfig(this.readerSetting)
      }
    })
  }

  aboutToAppear(): void {
    const p = TCRouter.getParams<BookInfo>(Constants.READ_KIT_ROUTER);
    if (p) {
      this.book = p;
      ReviewDataUtil.setCurrentBookInfo(this.book);
      // let context = GlobalContext.getContext();
      // let resourceDir = context.resourceDir
      // let fileName: string = (this.book.coverUrl as string).split('.').pop()!
      // let bookResourceDir = resourceDir + '/' + fileName + '.png';
      ImmersiveListener.immersiveListening(this.book, '')
    }
    this.onWindowsAppear()
  }

  aboutToDisappear(): void {
    ImmersiveListener.immersiveDisablingListening()
  }

  @Builder
  reminderDialogBuilder() {
    Column({ space: 24 }) {
      Image($r('app.media.rest_reminder'))
        .width(220)
        .height(220)
        .objectFit(ImageFit.Contain)
      Row({ space: 4 }) {
        Text('您已经阅读了')
          .fontSize(16)
        Text(this.reminderTime + '分钟')
          .fontSize(16)
          .fontColor('#E84026')
          .fontWeight(FontWeight.Bold)
        Text('休息一下吧~~')
          .fontSize(16)
      }

      Button('我知道了')
        .backgroundColor('#0D000000')
        .fontColor($r('sys.color.warning'))
        .width(Constants.FULL_SIZE)
        .onClick(() => {
          this.onAccept()
        })
    }
    .padding({
      left: 24,
      right: 24
    })
  }

  // 处理书币扣费和更新
  private updateBookCoinsAndSave(price: number): void {
    if (this.userInfo) {
      try {
        this.userInfo.bookCoins -= price;
        AppStorage.set('userInfo', this.userInfo);
        emitter.emit(Constants.COINS_CHANGE);
      } catch (e) {
        console.error('Failed to emitter emit coins change. Cause: ' + JSON.stringify(e));
      }
    }
  }

  @Builder
  buildBuyChapter(index: number) {
    Column({ space: 8 }) {
      Text(`价格：${this.price}书币`)
      Text(`余额：${this.userInfo!.bookCoins}书币`)
      Row() {
        Checkbox()
          .onChange((value) => {
            this.userInfo!.continuousBuy = value
          })
        Text('自动购买下一章')
      }

      Button('购买')
        .onClick(() => {
          if (this.price > this.userInfo!.bookCoins!) {
            this.getUIContext().getPromptAction().showToast({
              message: '余额不足',
              duration: 2000
            });
          } else {
            this.updateBookCoinsAndSave(this.price)
            this.lockedStatus[index] = false
            this.isShowBuySheet = false
            baseActionSheet.close('buyChapter')
          }
        })
        .width('100%')
    }
    .padding({ bottom: this.bottomRectHeight, left: 16, right: 16 })
    .alignItems(HorizontalAlign.Start)
    .width('100%')
  }

  private resourceRequest: bookParser.CallbackRes<string, ArrayBuffer> = (fontName: string): ArrayBuffer => {
    if (this.isFont(fontName)) {
      let res = $rawfile(this.readerSetting.fontPath);
      let context = this.getUIContext().getHostContext();
      if (res && context) {
        try {
          // 获取资源路径下的字体数据
          let value: Uint8Array = context.resourceManager.getRawFileContentSync(this.readerSetting.fontPath);
          hilog.info(0x0000, 'testTag', 'resourceRequest : get success');
          return value.buffer as ArrayBuffer;
        } catch (error) {
          let code = (error as BusinessError).code;
          let message = (error as BusinessError).message;
          hilog.error(0x0000, 'testTag',
            `callback getRawFileContent failed, error code: ${code}, message: ${message}.`);
        }
      }
    }
    return new ArrayBuffer(0);
  }

  private isFont(filePath: string): boolean {
    let options = ['.ttf', '.woff2', '.otf'];
    let path = filePath.toLowerCase();
    let result = path.indexOf(options[0]) !== -1 || path.indexOf(options[1]) !== -1 || path.indexOf(options[2]) !== -1;
    hilog.info(0x0000, 'testTag', 'isFont = ' + result);
    return result;
  }

  async loadBook() {
    this.userInfo = AppStorage.get<UserInfo>('userInfo');
    this.startTime = systemDateTime.getTime(false)

    if (!this.book?.isDownload) {
      this.book!.localPath =
        await EpubUtils.loadEpubFileFromNetwork(this.book!, (this.getUIContext().getHostContext() as Context).cacheDir)
    }
    const hisRsp = await BookApi.getBooksShelfList('historyBooks', Constants.API_GET_BOOK_HISTORY_PATH, '');
    let books = hisRsp.books;
    let index = books.findIndex(book => book.id === this.book!.id)
    if (index !== -1) {
      books.splice(index, 1);
    }
    books.unshift(this.book!);
    AppStorage.set('historyBooks', books);
  }

  private async preprocess() {
    let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    let initPromise: Promise<void> = this.readerComponentController.init(context);
    let defaultHandlerPromise: Promise<bookParser.BookParserHandler> =
      bookParser.getDefaultHandler(this.book?.localPath);
    let result: [bookParser.BookParserHandler, void] = await Promise.all([defaultHandlerPromise, initPromise]);
    this.bookParserHandler = result[0];
    // 获取目录列表
    this.catalogItemList = this.bookParserHandler.getCatalogList() || [];
    // 获取书脊内容列表
    this.spineList = this.bookParserHandler.getSpineList();
    if (AppStorage.has(this.book?.id)) {
      this.pageData = AppStorage.get(this.book?.id) as readerCore.PageDataInfo
    }
    if (this.book?.isFree! === '2') {
      this.lockedStatus = AppStorageV2.connect(Array, 'lockedStatus', () => []) as boolean[]
      // mock付费章节
      if (this.lockedStatus.length === 0) {
        this.lockedStatus.push(false)
        this.lockedStatus.push(false)
        this.lockedStatus.push(false)
        for (let i = 3; i < this.catalogItemList.length; i++) {
          this.lockedStatus.push(true)
        }
      }
      if (this.userInfo?.isMembership) {
        this.lockedStatus = Array(this.catalogItemList.length).fill(false)
      }
    } else {
      for (let i = 0; i < this.catalogItemList.length; i++) {
        this.lockedStatus.push(false)
      }
    }
    try {
      this.readerComponentController.on('resourceRequest', this.resourceRequest);
      this.readerComponentController.on('pageShow', (data: readerCore.PageDataInfo): void => {
        hilog.info(0x0000, 'testTag', 'pageshow: data is: ' + JSON.stringify(data));
        if (data.state === readerCore.PageState.PAGE_ON_SHOW) {
          this.isLoading = false;
          let spineItem = this.spineList[data.resourceIndex]
          let catalogItem = this.catalogItemList.filter(item => item.resourceFile === spineItem.href)
          this.curChapterId = catalogItem[0].catalogId
          this.pageData = data;
          if (this.lockedStatus[this.curChapterId]) {
            if (this.userInfo!.continuousBuy && this.userInfo!.bookCoins > this.price) {
              // 自动购买
              this.updateBookCoinsAndSave(this.price)
              this.lockedStatus[this.curChapterId] = false
            } else {
              if (!this.isShowBuySheet) {
                this.isShowBuySheet = true
                baseActionSheet.show({
                  id: 'buyChapter',
                  title: { title: '购买' },
                  height: SheetSize.FIT_CONTENT,
                  preferType: SheetType.CENTER,
                  customContent: () => {
                    this.buildBuyChapter(this.curChapterId)
                  },
                  onWillDismiss: (dismissSheetAction: DismissSheetAction) => {
                    this.isShowBuySheet = false
                    if (this.lockedStatus[this.curChapterId]) {
                      this.readerComponentController.startPlay(this.pageData!.resourceIndex, this.pageData!.startDomPos)
                      dismissSheetAction.dismiss();
                    }
                  }
                })
              }
            }
          } else {
            this.pageData = data
          }
        } else if (data.state === readerCore.PageState.OPEN_BOOK_FAIL) {
          hilog.info(0x0000, 'testTag', '检测到PAGE_OUT_OF_RANGE状态，跳转到精彩书评页面');
          this.handleSwipeToReview();
        }
      });
    } catch (error) {
      console.error('ReaderPage', ` readerComponentController error = ${JSON.stringify(error)}`)
    }
    this.hasTriggeredReviewNavigation = false;
    hilog.info(0x0000, 'testTag', '阅读器预处理完成，重置跳转标志位');
    this.registerPageShowListener();
  }

  private registerPageShowListener(): void {
    try {
      this.readerComponentController.off('pageShow');
      this.readerComponentController.off('resourceRequest');
      hilog.info(0x0000, 'testTag', '重新注册阅读器事件监听器');
      this.readerComponentController.on('resourceRequest', this.resourceRequest);
      this.readerComponentController.on('pageShow', (data: readerCore.PageDataInfo): void => {
        hilog.info(0x0000, 'testTag', 'pageshow: data is: ' + JSON.stringify(data));
        if (data.state === readerCore.PageState.PAGE_ON_SHOW) {
          console.info(`testTag isonclick:${this.isOnClick}`)
          if (data.pageOffset === this.lastPageOffset && data.pageOffset !== 0 && !this.isOnClick) {
            this.lastPageOffset++;
            hilog.info(0x0000, 'testTag', '检测到OPEN_BOOK_FAIL状态，判断是否为最后一页');
            this.handlePageOutOfRange(data);
          } else {
            this.lastPageOffset = data.pageOffset
            this.isLoading = false;
            let spineItem = this.spineList[data.resourceIndex]
            let catalogItem = this.catalogItemList.filter(item => item.resourceFile === spineItem.href)
            if (catalogItem.length > 0) {
              this.curChapterId = catalogItem[0].catalogId
            }

            // 更新最后一页状态
            this.updateLastPageStatus(data);

            if (this.lockedStatus[this.curChapterId]) {
              if (this.userInfo!.continuousBuy && this.userInfo!.bookCoins > this.price) {
                // 自动购买
                this.updateBookCoinsAndSave(this.price)
                this.lockedStatus[this.curChapterId] = false
              } else {
                if (!this.isShowBuySheet) {
                  this.isShowBuySheet = true
                  baseActionSheet.show({
                    id: 'buyChapter',
                    title: { title: '购买' },
                    height: SheetSize.FIT_CONTENT,
                    preferType: SheetType.CENTER,
                    customContent: () => {
                      this.buildBuyChapter(this.curChapterId)
                    },
                    onWillDismiss: (dismissSheetAction: DismissSheetAction) => {
                      this.isShowBuySheet = false
                      if (this.lockedStatus[this.curChapterId]) {
                        this.readerComponentController.startPlay(this.pageData!.resourceIndex,
                          this.pageData!.startDomPos)
                        dismissSheetAction.dismiss();
                      }
                    }
                  })
                }
              }
            } else {
              this.pageData = data
            }
          }
        } else if (data.state === readerCore.PageState.OPEN_BOOK_FAIL) {
          this.lastPageOffset++;
          hilog.info(0x0000, 'testTag', '检测到OPEN_BOOK_FAIL状态，判断是否为最后一页');
          this.handlePageOutOfRange(data);
        }
      });
    } catch (e) {
      console.error('Failed to readerComponentController. Cause: ' + JSON.stringify(e));
    }
  }

  private updateLastPageStatus(data: readerCore.PageDataInfo): void {
    if (this.spineList && this.spineList.length > 0) {
      // 判断是否在最后一个spine
      this.isLastPage = data.resourceIndex >= this.spineList.length - 1;
      hilog.info(0x0000, 'testTag',
        `当前页面索引: ${data.resourceIndex}, 总页面数: ${this.spineList.length}, 是否最后一页: ${this.isLastPage}`);
    }
  }

  // 处理页面越界
  private handlePageOutOfRange(data: readerCore.PageDataInfo): void {
    if (!this.pageData) {
      hilog.warn(0x0000, 'testTag', '当前页面数据为空，无法判断页面位置');
      return;
    }
    const currentIndex = this.pageData.resourceIndex;
    const totalSpines = this.spineList.length;
    hilog.info(0x0000, 'testTag',
      `页面越界检测: 当前索引=${currentIndex}, 总数=${totalSpines}, 是否已触发跳转=${this.hasTriggeredReviewNavigation}, 是否正在跳转=${this.isNavigatingToReview}`);
    // 最后一页判断：
    if (currentIndex >= totalSpines - 1 && !this.hasTriggeredReviewNavigation && !this.isNavigatingToReview) {
      hilog.info(0x0000, 'testTag', '确认为最后一页左滑，跳转到精彩书评页面');
      this.hasTriggeredReviewNavigation = true;
      this.handleSwipeToReview();
    } else if (currentIndex < totalSpines - 1) {
      hilog.info(0x0000, 'testTag', `非最后一页的OPEN_BOOK_FAIL，当前索引=${currentIndex}，忽略跳转`);
    } else if (this.hasTriggeredReviewNavigation) {
      hilog.info(0x0000, 'testTag', '已经触发过跳转，忽略此次OPEN_BOOK_FAIL');
    } else if (this.isNavigatingToReview) {
      hilog.info(0x0000, 'testTag', '正在跳转过程中，忽略此次OPEN_BOOK_FAIL');
    } else {
      hilog.info(0x0000, 'testTag', '其他原因导致跳转被忽略');
    }
  }

  async startPlay() {
    try {
      this.reminderTime = this.userInfo!.reminderTime
      let spineIndex: number = 0
      let domPos: string = '';
      if (this.pageData) {
        spineIndex = this.pageData.resourceIndex
        domPos = this.pageData.startDomPos
      }
      if (this.bookParserHandler) {
        this.readerSetting.viewPortWidth = WindowUtils.getWindowWidth();
        this.readerSetting.viewPortHeight = WindowUtils.getWindowHeight();
        this.readerSetting.nightMode = AppStorage.get<boolean>('bookNightMode') ??
          this.context.config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
        this.readerSetting.fontColor = this.readerSetting.nightMode ? 'rgba(255,255,255,0.60)' : 'rgba(0,0,0,0.90)'
        this.readerSetting.themeColor = this.readerSetting.nightMode ? '#000000' : 'rgba(251, 240, 219, 1)';
        this.readerComponentController.registerBookParser(this.bookParserHandler);
        this.readerComponentController.setPageConfig(this.readerSetting)
        this.readerComponentController.startPlay(spineIndex, domPos);
      }
    } catch (err) {
      hilog.error(0x0000, 'testTag', `failed to startPlay, Code is ${err.code}, message is ${err.message}`);
    }
  }

  onWillHide(): void {
    try {
      // 删除缓存中的书籍
      EpubUtils.clearEpubFile(this.book!, (this.getUIContext().getHostContext() as Context).cacheDir, 'cache')
      AppStorage.setOrCreate(this.book?.id, this.pageData)
      this.readSet.readerSetting = this.readerSetting
      this.endTime = systemDateTime.getTime(false)
      this.userInfo!.totalReading += Math.ceil((this.endTime - this.startTime) / 60000)
      AppStorage.set('userInfo', this.userInfo)
      this.readerComponentController.off('resourceRequest');
      this.readerComponentController.off('pageShow');

      // 如果是跳转到精彩书评页面，则不释放阅读器实例
      if (!this.isNavigatingToReview) {
        // 退出需要释放阅读器实例
        this.readerComponentController.releaseBook();
      }
      this.notFullScreen()
      // 退出页面需要注销监听
      WindowUtils.onWindowSizeOff()
      // 重新注册外层监听
      const uiContext = this.getUIContext()
      BreakpointSystem.register(uiContext)
    } catch (error) {
      console.error('ReaderPage', ` readerComponentController error = ${JSON.stringify(error)}`)
    }
  }

  setFullScreen() {
    if (this.userInfo?.fullScreen) {
      try {
        this.windowClass.setWindowSystemBarEnable([]);
      } catch (e) {
        console.error('Failed to window setFullScreen. Cause: ' + JSON.stringify(e));
      }
    }
  }

  notFullScreen() {
    try {
      this.windowClass.setWindowSystemBarEnable(['status', 'navigation']);
    } catch (e) {
      console.error('Failed to window notFullScreen. Cause: ' + JSON.stringify(e));
    }
  }

  onAccept() {
    Logger.info('Accepted');
    this.dialogController.close()
    this.initTimer()
  }

  initTimer() {
    if (this.reminderTime > 0) {
      this.timerId = setTimeout((() => {
        this.dialogController.open()
      }), this.reminderTime * 60 * 1000);
      Logger.info('Timer is about to start' + this.timerId)
    }
  }

  clearTimer() {
    Logger.info('Timer has been cleared' + this.timerId)
    clearTimeout(this.timerId);
  }

  private handleSwipeToReview(): void {
    const currentTime = Date.now();
    if (currentTime - this.lastSwipeTime < 1000) {
      return;
    }
    this.lastSwipeTime = currentTime;
    this.isNavigatingToReview = true;
    this.getUIContext().getPromptAction().showToast({
      message: '已到最后一页，为您推荐精彩书评',
      duration: 2000
    });
    TCRouter.push(Constants.WONDERFUL_REVIEW_ROUTE, {
      bookName: this.book?.name || '当前书籍',
      fromCompleted: true
    });
  }

  build() {
    NavDestination() {

      Swiper() {

        if (!AppStorage.has(this.book?.id)) {
          BookCoverCard({ book: this.book })
        }

        Stack() {
          ReadPageComponent({
            controller: this.readerComponentController,
            readerCallback: (err: BusinessError, data: readerCore.ReaderComponentController) => {
              this.readerComponentController = data;
            }
          })
            .onClick(() => {
              this.showController = !this.showController
              this.isOnClick = this.showController
              if (this.showController) {
                this.notFullScreen()
              } else {
                this.setFullScreen()
              }
              this.readerComponentController.setPageConfig(this.readerSetting)
            })
            .gesture(
              PanGesture({ direction: PanDirection.Horizontal })
                .onActionStart((event: GestureEvent) => {
                  this.swipeStartX = event.offsetX;
                  this.hasTriggeredSwipe = false;
                  hilog.info(0x0000, 'testTag', `手势开始: startX=${this.swipeStartX}, isLastPage=${this.isLastPage}`);
                })
                .onActionUpdate((event: GestureEvent) => {
                  const deltaX = event.offsetX - this.swipeStartX;
                  if (deltaX < -this.swipeThreshold && this.isLastPage && !this.hasTriggeredSwipe) {
                    hilog.info(0x0000, 'testTag',
                      `检测到最后一页左滑手势: deltaX=${deltaX}, threshold=${this.swipeThreshold}`);
                    this.hasTriggeredSwipe = true;
                    this.handleSwipeToReview();
                  }
                })
                .onActionEnd((event: GestureEvent) => {
                  hilog.info(0x0000, 'testTag',
                    `手势结束: endX=${event.offsetX}, totalDeltaX=${event.offsetX - this.swipeStartX}`);
                  // 重置状态
                  this.hasTriggeredSwipe = false;
                })
            )

          if (this.showController) {
            Column() {
              ReaderTopCard({ book: this.book })

              Column() {
              }
              .layoutWeight(1)
              .width('100%')
              .hitTestBehavior(HitTestMode.Block)
              .onClick(() => {
                this.showController = false;
                this.isOnClick = this.showController;
              })

              ReaderToolBar({
                spineList: this.spineList,
                catalogItemList: this.catalogItemList,
                readerSetting: this.readerSetting,
                lockedStatus: this.lockedStatus,
                curChapterId: this.curChapterId,
                bookParserHandler: this.bookParserHandler,
                readerComponentController: this.readerComponentController,
              })
            }
            // 透传点击事件
            .hitTestBehavior(HitTestMode.None)
          } else {
            Row() {
              if (!this.userInfo?.noTimeBattery) {
                TextClock({ timeZoneOffset: -8, controller: this.textClockController })
                  .format('hh:mm')
              }
              Text(`${((this.pageData?.resourceIndex! + 1) / this.spineList.length * 100).toFixed(2)}%`)
            }
            .position({ bottom: this.bottomRectHeight })
            .padding({ left: 16, right: 16 })
            .width('100%')
            .justifyContent(this.userInfo?.noTimeBattery ? FlexAlign.End : FlexAlign.SpaceBetween)
          }

          Row() {
            Text('加载中...')
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
          .visibility(this.isLoading ? Visibility.Visible : Visibility.None)
        }
        .width('100%')
        .height('100%')
      }
      .onChange((index) => {
        this.swiperIndex = index
        if (index === 1) {
          this.setFullScreen()
        }
      })
      .indicator(false)
      .loop(false)
    }
    .hideTitleBar(true)
    .onWillAppear(async () => {
      // const p = TCRouter.getParams<BookInfo>(Constants.READ_KIT_ROUTER);
      // if (p) {
      //   this.book = p;
      //   ReviewDataUtil.setCurrentBookInfo(this.book);
      // }
      // this.onWindowsAppear()
    })
    .onWillShow(async () => {
      if (this.isNavigatingToReview) {
        this.isNavigatingToReview = false;
        this.hasTriggeredReviewNavigation = false;

        if (this.bookParserHandler) {
          this.registerPageShowListener();

          if (this.pageData) {
            this.readerComponentController.setPageConfig(this.readerSetting);
            this.readerComponentController.startPlay(this.pageData.resourceIndex, this.pageData.startDomPos);
          }
        }
        return;
      }
      await this.loadBook()
      await this.preprocess()
      await this.startPlay()
      this.initTimer()
    })
    .onWillHide(() => {
      this.onWillHide()
      this.clearTimer()
    })
  }
}