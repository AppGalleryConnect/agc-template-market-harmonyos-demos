import { CourseInfo, CourseTypeMap } from 'commonlib';
import { CommonHeader, CourseList } from 'componentlib';
import { COURSE_TYPE_RADIO_GROUP, COURSE_TYPE_RADIO_LIST } from '../constants/Constants';
import { CourseSortButton, CourseSortTypeMap } from '../constants/Enums';
import { CourseTypeRadio } from '../types/Types';
import { CoursesVM } from '../viewmodels/CoursesVM';

@ComponentV2
export struct CoursesView {
  @Param courseType: CourseTypeMap = CourseTypeMap.ALL;
  vm: CoursesVM = CoursesVM.instance;

  @Monitor('courseType')
  getCourseList() {
    this.vm.getCourseList(this.courseType);
  }

  aboutToAppear(): void {
    this.vm.getCourseList(this.courseType);
  }

  build() {
    Column() {
      CommonHeader({
        title: '课程中心',
      });
      Column() {
        // 搜索栏
        this.searchBarBuilder();
        // 过滤栏
        this.filterBarBuilder();
      }
      .padding({
        left: $r('app.string.margin_l'),
        right: $r('app.string.margin_l'),
        top: $r('app.string.margin_m'),
        bottom: $r('app.string.margin_m'),
      });

      Column() {
        // 排序栏
        this.sortBarBuilder();
        // 课程列表
        CourseList({
          coursesList: this.vm.displayList,
          isLoading: this.vm.isLoading,
          handleClick: (course: CourseInfo) => {
            this.vm.handleClickCourseCard(course);
          },
        })
          .layoutWeight(1);
      }
      .layoutWeight(1)
      .backgroundColor($r('app.color.system_color_background_auxiliary'))
      .padding({
        left: $r('app.string.margin_l'),
        right: $r('app.string.margin_l'),
        top: $r('app.string.margin_m'),
        bottom: $r('app.string.margin_m'),
      });
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Start)
    .backgroundColor($r('app.color.system_color_background_white'))
    .width($r('app.string.width_percent_full'))
    .height($r('app.string.height_percent_full'));

  }

  @Builder
  searchBarBuilder() {
    Row() {
      Image($r('app.media.ic_search'))
        .width($r('app.integer.icon_size_16'))
        .width($r('app.integer.icon_size_16'))
        .margin({ right: $r('app.string.margin_s'), left: $r('app.string.margin_xs') })
        .onClick(() => {
          this.vm.getCourseList(this.vm.courseType);
        });
      TextInput({ text: this.vm.keyword, placeholder: '请输入课程名称' })
        .enterKeyType(EnterKeyType.Search)
        .placeholderColor($r('app.color.font_color_level2'))
        .placeholderFont({ size: $r('app.string.font_size_14') })
        .fontColor($r('app.color.font_color_level1'))
        .fontSize($r('app.string.font_size_14'))
        .backgroundColor($r('app.color.system_color_grey'))
        .margin(0)
        .padding({
          left: $r('app.string.padding_xxs'),
          right: 0,
          top: 0,
          bottom: 0,
        })
        .defaultFocus(false)
        .layoutWeight(1)
        .enableKeyboardOnFocus(false)
        .cancelButton({
          style: CancelButtonStyle.INPUT,
          icon: {
            size: 16,
            src: $r('app.media.ic_delete_circle'),
            color: $r('app.color.icon_color_level3'),
          },
        })
        .onChange((value) => {
          this.vm.keyword = value;
        })
        .onSubmit(() => {
          this.vm.getCourseList(this.vm.courseType);
        });
    }
    .width($r('app.string.width_percent_full'))
    .padding($r('app.string.padding_s'))
    .height(40)
    .margin({ bottom: $r('app.string.margin_m') })
    .borderRadius($r('app.string.border_radius_capsule'))
    .backgroundColor($r('app.color.system_color_grey'));
  }

  @Builder
  filterBarBuilder() {
    Row() {
      ForEach(COURSE_TYPE_RADIO_LIST, (item: CourseTypeRadio) => {
        Row() {
          Radio({ value: item.value, group: COURSE_TYPE_RADIO_GROUP })
            .contentModifier(new MyRadioStyle(item.id))
            .checked(item.id === this.courseType);
        }
        .margin({
          left: $r('app.string.margin_xs'),
          right: $r('app.string.margin_xs'),
        });
      }, (item: CourseTypeRadio) => item.id + item.value);
    }
    .width($r('app.string.width_percent_full'))
    .margin({
      top: $r('app.string.margin_xs'),
      bottom: $r('app.string.margin_xs'),
    })
    .justifyContent(FlexAlign.Start);
  }

  @Builder
  sortBarBuilder() {
    Row({ space: 8 }) {
      Text('默认')
        .sortLabelStyle(this.vm.isSortActive([CourseSortTypeMap.DEFAULT]))
        .onClick(() => {
          this.vm.switchSortType(CourseSortButton.DEFAULT);
        });
      Row() {
        Text('价格')
          .sortLabelStyle(this.vm.isSortActive([CourseSortTypeMap.PRICE_LOW_TO_HIGH,
            CourseSortTypeMap.PRICE_HIGH_TO_LOW]));
        Column() {
          Image($r('app.media.ic_triangle_up'))
            .sortIconStyle(this.vm.isSortActive([CourseSortTypeMap.PRICE_LOW_TO_HIGH]));
          Image($r('app.media.ic_triangle_down'))
            .sortIconStyle(this.vm.isSortActive([CourseSortTypeMap.PRICE_HIGH_TO_LOW]));
        };
      }
      .onClick(() => {
        this.vm.switchSortType(CourseSortButton.PRICE);
      });
    }
    .width($r('app.string.width_percent_full'))
    .margin({
      top: $r('app.string.margin_s'),
      bottom: $r('app.string.margin_l'),
    })
    .justifyContent(FlexAlign.Start);
  }
}

class MyRadioStyle implements ContentModifier<RadioConfiguration> {
  courseType: CourseTypeMap;

  constructor(type: CourseTypeMap) {
    this.courseType = type;
  }

  public applyContent(): WrappedBuilder<[RadioConfiguration]> {
    return wrapBuilder(buildRadio);
  }
}

@Builder
function buildRadio(config: RadioConfiguration) {
  Row() {
    Text(config.value)
      .fontSize($r('app.string.font_size_14'))
      .fontColor(config.checked ? $r('app.color.font_color_level1_invert') : $r('app.color.font_color_level1'));
  }
  .padding({
    top: $r('app.string.padding_xs'),
    bottom: $r('app.string.padding_xs'),
    left: $r('app.string.padding_l'),
    right: $r('app.string.padding_l'),
  })
  .height(36)
  .borderRadius($r('app.string.border_radius_32'))
  .backgroundColor(config.checked ? $r('app.color.system_theme_color') :
  $r('app.color.system_color_background_grey_level2'))
  .onClick(() => {
    if (!config.checked) {
      config.triggerChange(true);
      CoursesVM.instance.switchCourseType((config.contentModifier as MyRadioStyle).courseType);
    }
  });

}

@Extend(Text)
function sortLabelStyle(isActive: boolean) {
  .fontColor(isActive ? $r('app.color.font_color_level1') : $r('app.color.font_color_level3'))
  .fontSize($r('app.string.font_size_14'))
  .margin({ left: $r('app.string.margin_m') });
}

@Extend(Image)
function sortIconStyle(isActive: boolean) {
  .width(12)
  .height(8)
  .fillColor(isActive ? $r('app.color.font_color_level1') : $r('app.color.font_color_level3'));
}

