/**
 * @usage: 旅游页面，提供跟团游和定制游两种模式，支持城市选择、游玩天数输入，展示热门旅游产品列表
 * @layout: 页面整体采用垂直布局（Column），顶部是背景图和tabs切换卡片，卡片内包含跟团游/定制游切换、城市选择、天数输入、
 * 搜索按钮，下方是旅游产品网格列表
 * @constraints: chooseStatus控制当前模式（PackageTour跟团游、TailorMadeTravel定制游）；mockTourList为旅游产品数据源
 * @isGen: true
 * @fileType: page
 * @zhName: 旅游
 * @domain: 旅游
 * @image: screenshots/homepage/Tour.jpg
 * @subPage: TourListPage,TourDetailPage
 * @component: TourGrid
 */
import { phoneRouterControl } from 'oh_router';
import { BarVM } from 'common'
import { TourChooseStatus, TourGrid, TourModel } from 'common_travel_guide'
import { TourPageVM } from '../viewmodel/TourPageVM'

@Builder
export function TourPageBuilder() {
  TourPage()
}

@ComponentV2
export struct TourPage {
  vm: TourPageVM = new TourPageVM()
  private textInputController: TextInputController = new TextInputController();

  // tabs选项卡 Builder
  @Builder
  TourTabBuilder(label: string, status: TourChooseStatus, imageRes: Resource, isLeft: boolean) {
    Stack({ alignContent: Alignment.Center }) {
      if (this.vm.searchParam.chooseStatus === status) {
        Row() {
          if (isLeft) {
            Blank()
              .flexGrow(1)
              .height('100%')
              .backgroundColor($r('sys.color.background_primary'))
              .borderRadius({ topLeft: isLeft ? 16 : 0, topRight: isLeft ? 0 : 16 })
            Image(imageRes).height('100%').align(Alignment.BottomEnd)
          } else {
            Image(imageRes).height('100%').align(Alignment.BottomEnd).objectFit(ImageFit.Contain)
            Blank()
              .flexGrow(1)
              .height('100%')
              .backgroundColor($r('sys.color.background_primary'))
              .borderRadius({ topRight: 16 })
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      Text(label)
        .width('100%')
        .height('100%')
        .fontSize(16)
        .textAlign(TextAlign.Center)
        .fontColor(this.vm.searchParam.chooseStatus === status ? '#FF333333' : '#80000000')
        .onClick(() => {
          this.vm.searchParam.chooseStatus = status
        })
    }
    .width(this.vm.searchParam.chooseStatus === status ? '55%' : '45%')
  }

  // 选择城市和游玩天数
  @Builder
  ChooseCityDaysBuilder() {
    Column() {
      Row() {
        Text('选择城市')
          .fontSize(16)
          .fontColor('#FF000000')
          .fontWeight(500)
        Row() {
          Text(this.vm.searchParam.keyword ? this.vm.searchParam.keyword : '请选择')
            .fontSize(16)
            .fontColor(this.vm.searchParam.keyword ? '#FF333333' : '#80000000')
          Image($r('app.media.traveler')).width(20).height(20)
        }
        .justifyContent(FlexAlign.End)
        .onClick(() => {
          this.vm.jumpSelectCityPage()
        })
      }
      .width('100%')
      .padding({ top: 18, bottom: 18 })
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Text('游玩天数')
          .fontSize(16)
          .fontColor('#FF000000')
          .fontWeight(500)
        Row() {
          TextInput({ text: this.vm.searchParam.playDays, placeholder: '输入天数' ,controller: this.textInputController})
            .backgroundColor($r('sys.color.background_primary'))
            .onChange((val: string) => {
              this.vm.searchParam.playDays = val
            })
        }
        .flexGrow(1)
        .width(1)
      }
      .width('100%')
      .padding({ top: 18, bottom: 18 })
    }
    .width('100%')
    .backgroundColor($r('sys.color.background_primary'))
    .padding({ left: 16, right: 16 })
  }

  // 页面内容渲染：顶部横幅 + 选项卡 + 列表卡片图片
  @Builder
  render() {
    Column() {
      Stack({ alignContent: Alignment.Top }) {
        // 背景图片
        Image($r('app.media.tour_background_img')).width('100%').objectFit(ImageFit.Contain)
        Column() {
          Image($r('app.media.ic_back_white')).height(40).width(40)
            .onClick(() => {
              this.vm.backPage();
            })
            .margin({ top: BarVM.instance.staBarH, left: 16 })
          // tabs选项卡
          Column() {
            Row() {
              this.TourTabBuilder('跟团游', TourChooseStatus.PackageTour, $r('app.media.tab_active_left_bg'), true)
              this.TourTabBuilder('定制游', TourChooseStatus.TailorMadeTravel, $r('app.media.tab_active_right_bg'),
                false)
            }
            .width('100%')
            .height(44)
            .backgroundColor('rgba(255, 255, 255, 0.8)')
            .borderRadius({ topLeft: 16, topRight: 16 })
            .justifyContent(FlexAlign.SpaceBetween)

            // 选择城市和游玩天数
            this.ChooseCityDaysBuilder()

            Column() {
              Text('搜 索')
                .fontSize(16)
                .fontColor('#FF333333')
                .fontWeight(500)
                .width('100%')
                .height(43)
                .textAlign(TextAlign.Center)
                .backgroundColor('#FFFEE231')
                .borderRadius(24)
                .onClick(() => {
                  // 调用stopEditing()方法关闭键盘
                  this.textInputController.stopEditing();
                  this.vm.jumpTourListPage()
                })
            }
            .width('100%')
            .padding(12)
            .borderRadius({ bottomLeft: 16, bottomRight: 16 })
            .backgroundColor($r('sys.color.background_primary'))
          }
          .margin({ left: 16, right: 16, top: 114 })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(HorizontalAlign.Start)
      }

      // 旅游列表
      Column() {
        TourGrid({
          tourList: this.vm.mockTourList,
          jumpTourDetailPage: (listItem: TourModel) => {
            this.vm.jumpTourDetailPage(listItem)
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({
        left: 16,
        right: 16,
      })
    }
    .width('100%')
    .height('100%')
  }

  build() {
    NavDestination() {
      this.render()
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
    .backgroundColor($r('sys.color.background_secondary'))
  }
}
