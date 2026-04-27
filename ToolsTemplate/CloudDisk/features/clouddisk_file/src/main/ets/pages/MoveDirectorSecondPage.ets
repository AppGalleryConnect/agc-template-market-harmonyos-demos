import { FileInfo, TValueType } from 'common';
import { OHPage, phoneRouterControl } from 'oh_router';
import { MoveDirectorListView } from '../components/MoveDirectorListView';
import { MoveDirectorFirstPageVM, moveDirectorRouterName } from '../viewmodel/MoveDirectorFirstPageVM';

/**
 * @usage: 用于展示移动文件选择目标目录的第二级及更深层级页面。提供文件移动目标子目录选择功能，支持面包屑导航和多级目录跳转。
 * 关键数据结构包括MoveDirectorFirstPageVM（移动目录视图模型，包含levelDirectorList层级目录列表、nextList下一级列表、
 * jumpToNextlevelDirector跳转下一级目录方法、changeToPrelevelDirector切换到上一级目录方法、jumpToRoot跳转到根目录方法）。
 * 页面通过面包屑导航展示当前目录层级，支持点击任意层级快速跳转。
 * @layout: 页面采用Column垂直布局。顶部是面包屑导航List（横向滚动、高度40vp、左右内边距16vp、上内边距12vp），
 * 包含"我的云盘"根目录项和levelDirectorList层级目录项（每项包含目录名称Text和右箭头Image 14x14，
 * 最后一级目录名称显示为蓝色#4B5CC4加粗，其他层级为常规字体），主体是MoveDirectorListView文件列表视图（占满剩余空间）。
 * @constraints: 面包屑导航的levelDirectorList数组由vm管理不可修改；点击"我的云盘"会调用jumpToRoot方法并返回上一页；
 * 点击中间层级会调用changeToPrelevelDirector方法切换到对应层级；点击文件项会调用jumpToNextlevelDirector方法进入下一级；
 * 最后一级目录名称样式固定为蓝色#4B5CC4加粗。
 * @isGen: true
 * @fileType: page
 * @subPage:
 * @domain: 云存储
 * @zhName: 移动文件选择目录页面（二级及以下）
 * @component: OHPage,MoveDirectorListView
 * @image: screenshot/file/move_second.jpg
 */

// 选择移动文件弹框二级目录
@ComponentV2
struct MoveDirectorSecondPage {
  @Require @Param vm: MoveDirectorFirstPageVM

  @Builder
  render() {
    Column() {
      List() {
        ListItem() {
          Row() {
            Text($r('app.string.myclouddisk'))
              .constraintSize({ maxWidth: '30%' })
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .textAlign(TextAlign.Start)
              .margin({ right: $r('app.float.vp_6') })
              .wordBreak(WordBreak.BREAK_ALL)
              .fontColor($r('sys.color.font_primary'))
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Regular)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .onClick(() => {
                this.vm.jumpToRoot()
                phoneRouterControl.popPage({ routerName: moveDirectorRouterName });
              })

            Image($r('app.media.icon_right'))
              .width($r('app.float.vp_14'))
              .height($r('app.float.vp_14'))
              .objectFit(ImageFit.Cover)

          }.margin({ right: $r('app.float.vp_5') })
        }

        ForEach(this.vm?.levelDirectorList, (item: FileInfo, idx: number) => {
          ListItem() {
            Row() {
              Text(item.name)
                .textAlign(TextAlign.Start)
                .margin({ right: $r('app.float.vp_6') })
                .fontColor(this.vm!.levelDirectorList.length - 1 === idx ? '#4B5CC4' :
                $r('sys.color.font_primary'))
                .fontSize($r('sys.float.Body_M'))
                .fontWeight(this.vm!.levelDirectorList.length - 1 === idx ? FontWeight.Medium :
                FontWeight.Regular)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .wordBreak(WordBreak.BREAK_ALL)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .constraintSize({ maxWidth: '30%' })
                .onClick(() => {
                  this.vm?.changeToPrelevelDirector(idx)
                })

              if (this.vm!.levelDirectorList.length - 1 !== idx) {
                Image($r('app.media.icon_right'))
                  .width($r('app.float.vp_14'))
                  .height($r('app.float.vp_14'))
                  .objectFit(ImageFit.Cover)
              }
            }.margin({ right: $r('app.float.vp_5') })
          }
        }, (item: string, index: number) => JSON.stringify(item) + index);
      }
      .padding({ top: $r('app.float.vp_12'), left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .listDirection(Axis.Horizontal)
      .height($r('app.float.vp_40'))
      .width('100%')

      MoveDirectorListView({
        fileList: this.vm.nextList, didSelectAction: (index: number) => {
          this.vm.jumpToNextlevelDirector(index)
        }
      })
        .width('100%')
        .layoutWeight(1)

    }
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }

  build() {
    OHPage({ childBuilder: () => { this.render() } })
  }
}


@Builder
export function MoveDirectorSecondPageBuilder(param: TValueType) {
  MoveDirectorSecondPage({ vm: param as MoveDirectorFirstPageVM })
}