import { PersonalInfoView } from 'collect_personal_info';
import { CommonHeader } from 'common';
import { OHPage, phoneRouterControl } from 'oh_router';
import { BarVM } from 'common';
import { EditPersonalVM } from '../viewmodel/EditPersonalVM';

@Builder
export function EditPersonalCenterBuilder() {
  EditPersonalCenter();
}

/**
 * @usage: 用于编辑用户个人信息的页面。包含头像、昵称、姓名、性别、生日等个人信息编辑功能。
 * 关键数据结构：userInfo（用户信息对象）、各种ObservedInfoItem（表单项对象，包含头像、昵称、姓名、
 * 性别、生日等）。支持表单验证和数据持久化存储。
 * @layout: 页面采用垂直布局（Column）。顶部为CommonHeader导航栏（标题居中，返回按钮左对齐），
 * 下方为PersonalInfoView表单组件（垂直排列的表单项，每项包含标签和输入控件）。
 * @constraints: 昵称长度限制2-10个字符，姓名长度限制2-20个字符。性别支持男、女、其他三种选项。
 * 生日选择范围为1900年至当前年份。所有修改会实时同步到userInfo对象并持久化存储。
 * @domain: 工具
 * @isGen: true
 * @fileType: page
 * @zhName: 个人信息编辑页面
 * @component: CommonHeader, PersonalInfoView, FormGroup,OHPage
 * @image: screenshots/person/EditPersonalCenter.png
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
      pageBackgroundColor: $r('sys.color.background_secondary')
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
          themeColor: $r('sys.color.comp_background_emphasize'),
        })
      }
      .width('100%')
      .height('100%')
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .width('100%')
    .height('100%')
    .padding({
      top: BarVM.instance.staBarH,
      bottom: BarVM.instance.aiBarH
    })
  }
}

