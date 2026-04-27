
import { ListCard } from './ListCard';
import { Constants } from '../common/Constant';
import { PersonalInfo, DataType, SwitchInfo, ApiHandler } from '../common/FormModel';
import { PersonalInfoViewVM } from '../viewmodels/PersonalInfoViewVM';
import { FormGroup } from '../common/FormModel';
import { GridRowColSetting } from '../common/GridRowColSetting';

/**
 * @usage: 个人信息视图组件，提供个人信息收集和管理的界面。关键数据结构包括PersonalInfo个人信息、FormGroup表单组、SwitchInfo开关信息、ApiHandler接口处理器。包含数据绑定和变化回调处理逻辑。
 * @layout: 网格布局，使用GridRow和GridCol实现响应式设计，内部为滚动容器包含多个ListCard表单卡片，支持不同屏幕尺寸的自适应显示。
 * @constraints: list表单列表不能为空，personalInfo个人信息必须包含必要字段，apiInfo接口信息必须有效，themeColor主题色不能为非法值
 * @isGen: true
 * @fileType: component
 * @zhName: 个人信息视图组件
 */
@ComponentV2
export struct PersonalInfoView {
  // 数据列表
  @Param list: FormGroup[] = [];
  // 个人数据
  @Param personalInfo: PersonalInfo = {};
  // 云侧调用接口
  @Param apiInfo: ApiHandler = {};
  // 开关数据
  @Param switchInfo: SwitchInfo = {};
  // 主题色
  @Param themeColor: string | Resource = $r('sys.color.brand');
  // 个人信息变化的回调
  @Event onChange: (type: DataType, data: PersonalInfo) => void = () => {
  };
  @Local vm: PersonalInfoViewVM = new PersonalInfoViewVM();

  aboutToAppear(): void {
    this.vm.assignSwitchInfo(this.switchInfo);
    this.vm.assignPersonalInfo(this.personalInfo);
    this.vm.assignApiInfo(this.apiInfo);
    this.vm.assignExtraInfo(this.themeColor, this.onChange);
    this.vm.collectList();
    this.vm.windowModel.registerWindowBottomPadding();
  }

  aboutToDisappear(): void {
    this.vm.windowModel.unRegisterWindowBottomPadding();
  }

  build() {
    Column() {
      GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
        GridCol({
          span: GridRowColSetting.DEFAULT_CENTER_COL_SPAN,
          offset: GridRowColSetting.DEFAULT_CENTER_COL_OFFSET,
        }) {
          Scroll() {
            Column({ space: Constants.SPACE_M }) {
              ForEach(this.listData, (v: FormGroup) => {
                ListCard({ list: v.list })
              }, (v: FormGroup) => JSON.stringify(v))
            }
          }
          .width(Constants.FULL_PERCENT)
          .height(Constants.FULL_PERCENT)
          .scrollBar(BarState.Off)
          .align(Alignment.Top)
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .layoutWeight(1)
    }
    .width(Constants.FULL_PERCENT)
    .height(Constants.FULL_PERCENT)
  }

  @Computed
  get listData() {
    if (this.list.length) {
      return this.list;
    }
    return [
      {
        list: this.vm.list1,
      },
      {
        list: this.vm.list2,
      },
      {
        list: this.vm.list3,
      },
      {
        list: this.vm.list4,
      },
    ] as FormGroup[];
  }
}