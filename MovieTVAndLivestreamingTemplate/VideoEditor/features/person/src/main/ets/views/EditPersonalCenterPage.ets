import { PersonalInfoView } from 'collect_personal_info';
import { CommonHeader } from 'common';
import { OHPage, phoneRouterControl } from 'oh_router';
import { EditPersonalVM } from '../viewmodel/EditPersonalVM';

@Builder
export function EditPersonalCenterBuilder() {
  EditPersonalCenter();
}

/**
 * @usage: 用于编辑个人信息的页面，包含头像、姓名、性别、出生日期、手机号码、邮箱和个人简介等信息编辑。
 * 关键数据结构：ObservedInfoItem表单项数据模型，FormGroup表单分组，FormType表单类型枚举。
 * @layout: 页面整体采用垂直布局（Column）。顶部为CommonHeader导航栏，下方为PersonalInfoView表单视图，
 * 表单项按分组纵向排列（左对齐）。
 * @constraints:
 * @zhName: 个人信息编辑页
 * @fileType: page
 * @isGen: true
 * @component: CommonHeader,PersonalInfoView,OHPage
 */
@ComponentV2
export struct EditPersonalCenter {
  vm: EditPersonalVM = new EditPersonalVM();

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      useSafePadding: true,
      isFullScreen: true
    })
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      CommonHeader({
        title: '个人信息',
        onReturnClick: () => {
          phoneRouterControl.popPage();
        },
      })
      Column() {
        PersonalInfoView({
          list: this.vm.list,
          themeColor: $r('sys.color.multi_color_07'),
        })
      }
      .width('100%')
      .height('100%')
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
  }
}

