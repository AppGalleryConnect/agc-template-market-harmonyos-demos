import { OHPage, phoneRouterControl } from 'oh_router';

import { DirectorDetailPageVM } from '../viewmodel/DirectorDetailPageVM';
import { FileListOperationView } from '../components/FileListOperationView';
import { BarVM, FileInfo, HeaderView } from 'common';

/**
 * @usage: 用于展示文件夹详情页面。提供文件夹内文件的管理功能，支持面包屑导航、文件操作等功能。
 * 关键数据结构包括FileInfo（文件信息模型）、DirectorDetailPageVM（文件管理视图模型，包含levelDirectorList层级目录列表、
 * changeToPrelevelDirector切换到上一级目录方法）、FileListSelectViewVM（文件列表选择视图模型）。
 * 页面通过面包屑导航展示当前目录层级，支持点击任意层级快速跳转。
 * @layout: 页面采用Column垂直布局。顶部是HeaderView导航栏（返回按钮），
 * 第二行是面包屑导航List（横向滚动、高度40vp、左右内边距16vp、上内边距12vp），
 * 包含"我的云盘"根目录项和levelDirectorList层级目录项（每项包含目录名称Text和右箭头Image 14x14，
 * 最后一级目录名称显示为蓝色#4B5CC4加粗，其他层级为常规字体），主体是FileListOperationView文件列表操作视图（占满剩余空间）。
 * @constraints: 面包屑导航的levelDirectorList数组由vm管理不可修改；点击"我的云盘"会返回上一页；
 * 点击中间层级会调用changeToPrelevelDirector方法切换到对应层级；最后一级目录名称样式固定为蓝色#4B5CC4加粗；
 * DirectorDetailPageVM在aboutToAppear中初始化并传入fileInfo参数。
 * @isGen: true
 * @fileType: page
 * @subPage: DirectorDetailPage,OpenPrivateSpacePage，VipCenterPage,MoveFileFirstPage
 * @domain: 云存储
 * @zhName: 文件夹详情页面
 * @component: OHPage,HeaderView,FileListOperationView
 * @image: screenshot/file/file_directory.jpg
 */

// 面包屑导航文件页面
@ComponentV2
struct DirectorDetailPage {
  @Require @Param fileInfo: FileInfo;
  vm?: DirectorDetailPageVM

  aboutToAppear(): void {
    this.vm = new DirectorDetailPageVM(this.fileInfo)
  }

  @Builder
  buitdNavTitle(name: string, color: ResourceColor, weight: FontWeight, isShowArrow: boolean) {
    Row() {
      Text(name)
        .fontColor(color)
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(weight)
        .textAlign(TextAlign.Start)
        .margin({ right: $r('app.float.vp_6') })
        .wordBreak(WordBreak.BREAK_ALL)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .constraintSize({ maxWidth: '30%' })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      if (isShowArrow) {
        Image($r('app.media.icon_right'))
          .objectFit(ImageFit.Cover)
          .width($r('app.float.vp_14'))
          .height($r('app.float.vp_14'))
      }
    }.margin({ right: $r('app.float.vp_5') })
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      HeaderView({
        clickBackBtn: () => {
          phoneRouterControl.popPage();
        }
      })

      List() {
        ListItem() {
          Row() {
            Text($r('app.string.myclouddisk'))
              .textAlign(TextAlign.Start)
              .fontColor($r('sys.color.font_primary'))
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Regular)
              .constraintSize({ maxWidth: '30%' })
              .margin({ right: $r('app.float.vp_6') })
              .wordBreak(WordBreak.BREAK_ALL)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(1)
              .onClick(() => {
                phoneRouterControl.popPage();
              })

            Image($r('app.media.icon_right'))
              .height($r('app.float.vp_14'))
              .objectFit(ImageFit.Cover)
              .width($r('app.float.vp_14'))

          }
          .margin({ right: $r('app.float.vp_5') })
        }

        ForEach(this.vm?.levelDirectorList, (item: FileInfo, index: number) => {
          ListItem() {
            Row() {
              Text(item.name)
                .fontSize($r('sys.float.Body_M'))
                .fontColor(this.vm!.levelDirectorList.length - 1 === index ? '#4B5CC4' :
                $r('sys.color.font_primary'))
                .margin({ right: $r('app.float.vp_6') })
                .fontWeight(this.vm!.levelDirectorList.length - 1 === index ? FontWeight.Medium :
                FontWeight.Regular)
                .textAlign(TextAlign.Start)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .wordBreak(WordBreak.BREAK_ALL)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .constraintSize({ maxWidth: '30%' })
                .onClick(() => {
                  this.vm?.changeToPrelevelDirector(index)
                })

              if (this.vm!.levelDirectorList.length - 1 !== index) {
                Image($r('app.media.icon_right'))
                  .height($r('app.float.vp_14'))
                  .objectFit(ImageFit.Cover)
                  .width($r('app.float.vp_14'))
              }
            }
            .margin({ right: $r('app.float.vp_5') })
          }
        }, (item: string, index: number) => JSON.stringify(item) + index.toString());
      }
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .padding({ top: $r('app.float.vp_12'), left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
      .edgeEffect(EdgeEffect.Spring)
      .width('100%')
      .height($r('app.float.vp_40'))

      FileListOperationView({ vm: this.vm })
        .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(Color.White)
    .padding({ top: BarVM.instance.aiBarH })
  }

  build() {
    OHPage({ childBuilder: () => { this.render() } })
  }
}

@Builder
export function DirectorDetailPageBuilder(info: Object) {
  DirectorDetailPage({ fileInfo: info as FileInfo })
}