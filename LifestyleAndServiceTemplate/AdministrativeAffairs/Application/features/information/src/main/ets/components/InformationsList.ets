import {
  CloudFunction,
  CloudFunctionInformationResult,
  Constants,
  InformationTabsInfo,
  InformationTabsInfoContent,
  LazyDataSource,
  NavigationParams,
} from 'common'

@ComponentV2
export struct InformationsList {
  @Require @Param informationTabsInfo: InformationTabsInfo[]
  @Require @Param currentIndex: number;
  @Local informationsList: LazyDataSource<InformationTabsInfoContent> = new LazyDataSource<InformationTabsInfoContent>()
  @Local refreshing: boolean = false;
  @Local refreshOffset: number = 0;
  @Local refreshState: RefreshStatus = RefreshStatus.Inactive;
  @Local canLoad: boolean = false;
  @Local isLoading: boolean = false;
  @Local loadingText: ResourceStr = $r('app.string.information_loading');
  @Consumer('pageInfos') pageInfos: NavPathStack = new NavPathStack()

  @Monitor('currentIndex')
  onStrChange(monitor: IMonitor) {
    monitor.dirty.forEach((path: string) => {
      let currentIndex = monitor.value(path)?.now as number
      this.queryInformationData(currentIndex)
      console.log(`${path} changed from ${monitor.value(path)?.before} to ${monitor.value(path)?.now}`)
    })
  }

  aboutToAppear(): void {
    this.initInformationData(this.currentIndex)
  }

  initInformationData(currentIndex: number) {
    this.informationTabsInfo[currentIndex].content.forEach((item) => this.informationsList.pushData(item))
  }

  queryInformationData(currentIndex: number, searchType?: string): Promise<string> {
    return new Promise((resolve, reject) => {
      CloudFunction.getInformaticaList(currentIndex, searchType ?? '').then(resp => {
        if ((resp as CloudFunctionInformationResult).result.ret.code === 0) {
          let result: InformationTabsInfo[] =
            (resp as CloudFunctionInformationResult).result.result as InformationTabsInfo[]
          this.informationsList.clearData()
          result[currentIndex].content.forEach((item) => this.informationsList.pushData(item))
          resolve('success')
        } else {
          reject('failed')
        }
      }).catch(() => {
        reject('failed')
      })
    })
  }

  @Builder
  refreshBuilder() {
    Column() {
      if (this.refreshState !== RefreshStatus.Inactive) {
        if ([RefreshStatus.OverDrag, RefreshStatus.Drag].includes(this.refreshState)) {
          Row({ space: Constants.CONTAINER_SPACE_FIVE }) {
            Image($r('app.media.over_drag_refresh'))
              .size({
                width: $r('app.float.information_image_size_width'),
                height: $r('app.float.information_image_size_height'),
              })
            Text($r('app.string.information_release_refresh'))
          }
        } else if (this.refreshState === RefreshStatus.Refresh) {
          Row() {
            LoadingProgress()
              .height($r('app.float.information_progress_height'))
              .width($r('app.float.information_progress_width'))
            Text($r('app.string.information_loading'))
          }
        } else if (this.refreshState === RefreshStatus.Done) {
          Row({ space: Constants.CONTAINER_SPACE_FIVE }) {
            Image($r('app.media.success_refresh')).size({
              width: $r('app.float.information_image_size_width'),
              height: $r('app.float.information_refresh_done_height'),
            })
            Text($r('app.string.information_refresh_success'))
          }
        }
      }
    }
    .clip(true)
    .margin({
      top: $r('app.float.information_service_margin_top'),
      bottom: $r('app.float.information_service_margin_bottom'),
    })
  }

  @Builder
  footer() {
    Row() {
      LoadingProgress()
        .height($r('app.float.information_progress_height'))
        .width($r('app.float.information_progress_width'))
      Text($r('app.string.information_loading'))
    }.width(Constants.FULL_PERCENT_WIDTH)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  newsCard(item: InformationTabsInfoContent) {
    if (item.isHot) {
      Stack() {
        Image(item.cover).borderRadius(Constants.RADIUS_TEN)
          .clip(true)
        Column() {
          Stack() {
            Row()
              .backgroundColor($r('app.color.news_card_bg'))
              .opacity(0.6)
              .width($r('app.float.news_card_width'))
              .height($r('app.float.news_card_height'))
              .borderRadius(8)
            Row({ space: Constants.CONTAINER_SPACE_FIVE }) {
              Image($r('app.media.hot'))
                .width($r('app.float.news_card_hot_width'))
                .height($r('app.float.news_card_hot_height'))
              Text($r('app.string.information_news_hot'))
                .fontColor($r('sys.color.font_on_primary'))
                .fontSize(FontWeight.Medium)
                .fontSize($r('sys.float.Body_M'))
            }
          }

          Stack() {
            Column()
              .width(Constants.FULL_PERCENT_WIDTH)
              .height(Constants.FULL_PERCENT_HEIGHT)
              .backgroundColor($r('sys.color.mask_tertiary'))
              .opacity(0.4)
            Text(item.title)
              .fontColor($r('sys.color.font_on_primary'))
              .fontSize(FontWeight.Medium)
              .fontSize($r('sys.float.Body_L'))
          }
          .width($r('app.float.news_card_content_width'))
          .height($r('app.float.news_card_content_height'))
          .borderRadius(Constants.RADIUS_TEN)
          .clip(true)
        }
        .height(Constants.FULL_PERCENT_HEIGHT)
        .width(Constants.FULL_PERCENT_WIDTH)
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(HorizontalAlign.Start)
        .padding({
          top: $r('app.float.news_card_content_padding_top'),
          left: $r('app.float.news_card_content_padding_left'),
          bottom: $r('app.float.news_card_content_padding_bottom'),
        })
      }
      .width(Constants.FULL_PERCENT_WIDTH)
      .height($r('app.float.news_card_title_width'))
      .margin({ bottom: 24 })
    } else {
      Row() {
        Column() {
          Text(item.title)
            .fontColor($r('sys.color.font_primary'))
            .fontSize(FontWeight.Medium)
            .fontSize($r('sys.float.Body_M'))
          Row({ space: Constants.CONTAINER_SPACE_TWENTY }) {
            Text(item.date)
              .fontColor($r('sys.color.font_secondary'))
              .fontSize(FontWeight.Regular)
              .fontSize($r('sys.float.Caption_M'))
            Text($r('app.string.information_visit_number'))
              .fontColor($r('sys.color.font_secondary'))
              .fontSize(FontWeight.Regular)
              .fontSize($r('sys.float.Caption_M'))
            Text(item.access)
              .fontColor($r('sys.color.font_secondary'))
              .fontSize(FontWeight.Regular)
              .fontSize($r('sys.float.Caption_M'))
          }
          .margin({ top: $r('app.float.news_card_title_margin') })
        }
        .alignItems(HorizontalAlign.Start)
        .width(Constants.SIXTY_PERCENT_WIDTH)

        Row() {
          Image(item.cover).width($r('app.float.news_card_cover_width')).height($r('app.float.news_card_cover_height'))
        }.borderRadius(Constants.RADIUS_EIGHT).clip(true)
      }
      .width(Constants.FULL_PERCENT_WIDTH)
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor($r('sys.color.background_primary'))
    }

  }

  build() {
    Refresh({ refreshing: $$this.refreshing, builder: this.refreshBuilder() }) {
      if (this.informationTabsInfo[this.currentIndex].content.length === 0) {
        Column() {
          Text($r('app.string.information_no_data'))
        }
      } else {
        List({ space: Constants.CONTAINER_SPACE_TEN }) {
          LazyForEach(this.informationsList, (item: InformationTabsInfoContent) => {
            ListItem() {
              this.newsCard(item)
            }
            .margin({
              left: $r('app.float.news_card_cover_padding_left'),
              right: $r('app.float.news_card_cover_padding_right'),
              bottom: $r('app.float.common_margin_ten'),
            })
            .onClick(() => {
              //   跳转到对应的h5页面
              this.pageInfos.pushPathByName('web',
                new NavigationParams(item.title, 'news.html', true))
            })
          }, (item: InformationTabsInfoContent) => item.date)
          if (this.isLoading) {
            ListItem() {
              this.footer();
            }
          }
        }
        .scrollBar(BarState.Off)
        .onScrollIndex((start: number, end: number) => {
          // 当达到列表末尾时，触发新数据加载
          if (this.canLoad && end >= this.informationsList.totalCount() - 1) {
            this.canLoad = false;
            this.isLoading = true;
            this.queryInformationData(this.currentIndex, 'more').then(res => {
              if (res === 'success') {
                this.isLoading = false;
              }
            }).catch(() => {
              this.isLoading = false;
            })
          }
        })
        .onScrollFrameBegin((offset: number, state: ScrollState) => {
          // 只有当向上滑动时触发新数据加载
          if (offset > 5 && !this.isLoading) {
            this.canLoad = true;
          }
          return { offsetRemain: offset };
        })
        .scrollBar(BarState.Off)
        // 开启边缘滑动效果
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .onOffsetChange((offset: number) => {
      this.refreshOffset = offset;
    })
    .onStateChange((state: RefreshStatus) => {
      this.refreshState = state;
      if (this.refreshState === RefreshStatus.Refresh) {
        this.queryInformationData(this.currentIndex, 'refresh').then(res => {
          if (res === 'success') {
            this.refreshState = RefreshStatus.Done
            setTimeout(() => {
              this.refreshing = false;
            }, 2000)
          }
        }).catch(() => {
          this.refreshState = RefreshStatus.Done
        })
      }
    })
    .onRefreshing(() => {
      // 模拟数据刷新
      setTimeout(() => {
        this.refreshing = false;
      }, 2000)
    })
    .layoutWeight(1)
    .margin({ top: $r('app.float.information_list_margin_top') })
  }
}