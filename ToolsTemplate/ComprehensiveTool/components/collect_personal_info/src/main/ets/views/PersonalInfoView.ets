import { ListCard } from './ListCard';
import { Constants } from '../common/Constant';
import { PersonalInfo, DataType, SwitchInfo, ApiHandler } from '../common/DataModel';
import { PersonalInfoViewVM } from '../viewmodels/PersonalInfoViewVM';
import { FormGroup } from '../common/FormModel';
import { GridRowColSetting } from '../common/GridRowColSetting';

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