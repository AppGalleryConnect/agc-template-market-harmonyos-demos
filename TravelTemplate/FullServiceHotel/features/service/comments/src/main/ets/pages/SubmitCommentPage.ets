import { CommonButton, CommonHeader } from 'componentlib';
import { CommentStarRating } from '../components/CommentStarRating';
import { StoreSelectionDialog } from '../components/StoreSelectionDialog';
import { Constants, RatingLayoutType } from '../constants';
import { ArrivalType } from '../types';
import { SubmitCommentPageVM } from '../viewModels/SubmitCommentPageVM';

@Builder
export function submitCommentPageBuilder() {
  SubmitCommentPage()
}

@ComponentV2
export struct SubmitCommentPage {
  vm: SubmitCommentPageVM = SubmitCommentPageVM.instance;
  controller: TextAreaController = new TextAreaController();
  dialogController: CustomDialogController = new CustomDialogController({
    builder: StoreSelectionDialog({
      cancel: () => {
      },
      confirm: (item: string) => {
        this.vm.getCheckedHotel(item);
      },
    }),
    customStyle: true,
    backgroundColor: $r('app.color.font_color_level1_invert'),
    alignment: DialogAlignment.Bottom,
  });

  aboutToAppear(): void {
    this.vm.getHotelList();
    this.vm.resetData();
  }

  build() {
    NavDestination() {
      Column() {
        CommonHeader({
          title: '发表评论',
        })
        Column() {
          Row() {
            Text('*').fontColor($r('app.color.system_color_highlight'));
            Text('门店选择').commonTextStyle().layoutWeight(1)
            if (this.vm.hotelList.length === 1) {
              Row() {
                Text(this.vm.checkedHotel?.name ?? '').commonTextStyle()
              }
            } else {
              Row() {
                Text(this.vm.submitPageModel.location ? this.vm.checkedHotel?.name : '请选择').commonTextStyle()
                Image($r('app.media.ic_right_arrow')).height('24lpx')
              }
              .onClick(() => {
                this.dialogController.open();
              })
            }

          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({
            top: $r('app.string.padding_m'),
            left: $r('app.string.padding_m'),
            right: $r('app.string.padding_m'),
          })

          Divider()
            .strokeWidth('10lpx')
            .color('#f2f2f2')
            .margin({ top: $r('app.string.margin_m'), bottom: $r('app.string.margin_m') })

          CommentStarRating({
            rating: this.vm.submitPageModel.totalRate!!,
            layoutType: RatingLayoutType.VERTICAL,
            starSize: 24,
          })
            .margin({
              bottom: $r('app.string.margin_l'),
            })

          Column({
            space: 10,
          }) {
            CommentStarRating({
              label: '服务周到',
              starSize: 20,
              rating: this.vm.submitPageModel.detailRate.service!!,
            })
            CommentStarRating({
              label: '环境卫生',
              starSize: 20,
              rating: this.vm.submitPageModel.detailRate.environment!!,
            })
            CommentStarRating({
              label: '设施设备',
              starSize: 20,
              rating: this.vm.submitPageModel.detailRate.device!!,
            })
            CommentStarRating({
              label: '综合体验',
              starSize: 20,
              rating: this.vm.submitPageModel.detailRate.experience!!,
            })

            Divider().strokeWidth(1).color('#f2f2f2')
              .margin({
                top: $r('app.string.margin_s'),
                bottom: $r('app.string.margin_m'),
              })

            TextArea({
              text: this.vm.submitPageModel.desc,
              placeholder: '请留下您的宝贵意见吧~',
              controller: this.controller,
            })
              .placeholderFont({ size: $r('app.string.font_size_28') })
              .placeholderColor($r('app.color.font_color_level3'))
              .width('100%')
              .height(150)
              .fontSize($r('app.string.font_size_28'))
              .fontColor('#182431')
              .backgroundColor($r('app.color.system_color_background_white'))
              .borderWidth(1)
              .borderColor('#f2f2f2')
              .maxLength(200)
              .showCounter(true)
              .margin({
                bottom: $r('app.string.margin_s'),
              })
              .borderRadius($r('app.string.border_radius_8'))
              .onChange((value: string) => {
                this.vm.submitPageModel.desc = value;
              })

            // 匿名评论
            Row() {
              Text('匿名评论').margin({ right: $r('app.string.margin_s') }).fontSize($r('app.string.font_size_24'))
              Text('其他用户将无法看到您的头像与昵称')
                .fontSize($r('app.string.font_size_24'))
                .fontColor($r('app.color.font_color_level2'))
            }
            .width('100%')

          }
          .padding($r('app.string.padding_s'))
        }
        .width('100%')

        Blank()

        CommonButton({
          title:this.vm.submitPageModel.isAnonymous ? '匿名提交' : '提交',
          handleClick:()=> {
            this.vm.submitComment();
          },
        })
      }
      .height('100%')
    }
    .hideTitleBar(true)
  }
}

@Extend(Text)
function commonTextStyle() {
  .fontSize($r('app.string.font_size_24'));
}