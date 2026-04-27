import { PersonalInfoView } from 'collect_personal_info'
import { CommonHeader } from 'common';
import { OHPage, phoneRouterControl } from 'oh_router'
import { EditPersonalVM } from '../viewmodel/EditPersonalVM';

@Builder
export function EditPersonalCenterBuilder() {
  EditPersonalCenter();
}

/**
 * @usage: 个人信息编辑页面，使用 PersonalInfoView 通用组件展示和编辑用户个人资料
 * @layout: 页面采用垂直布局（Column），顶部为通用标题栏（CommonHeader），
 * 下方为个人信息表单区域（PersonalInfoView 组件，内部为列表形式展示）。
 * @constraints: PersonalInfoView 组件的 list 参数由 EditPersonalVM 提供，不可直接修改。CommonHeader 的返回逻辑不可删除。
 * @isGen: true
 * @fileType: page
 * @zhName: 个人信息编辑页面
 * @domain: 绘画
 * @image: screenshots/person/personinfo.jpg
 * @component: PersonalInfoView,CommonHeader,OHPage
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

