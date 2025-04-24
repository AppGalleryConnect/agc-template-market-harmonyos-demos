import HomeViewModel from '../viewmodel/HomeViewModel';
import BannerInfo from '../model/BannerInfo';
import { PatientCardView } from 'patient';
import { CommonWebPageParam, LogUtil, ToastUtil } from 'common';
import { PatientViewModel } from 'patient/src/main/ets/viewmodel/PatientViewModel';
import { AppointmentStatusWidgetViewModel } from '../viewmodel/AppointmentStatusWidgetViewModel';

@ComponentV2
export struct HomePage {
  @Local homeViewModel: HomeViewModel = new HomeViewModel()
  @Local patientViewModel: PatientViewModel = PatientViewModel.getInstance()

  aboutToAppear(): void {
    this.homeViewModel.loadData()
    this.patientViewModel.loadDefaultPatient()
  }

  build() {
    Column() {
      Text('鸿蒙医院')
        .height($r('sys.float.titlebar_default_height'))
        .fontSize($r('sys.float.ohos_id_text_size_dialog_tittle'))
        .fontWeight(800)
        .width('100%')
        .backgroundColor($r('sys.color.ohos_id_color_background'))
        .textAlign(TextAlign.Start)
        .padding({
          left: 18
        })

      Scroll(new Scroller()) {
        Column({ space: 10 }) {
          Image($r('app.media.bg_hospital'))
            .width('100%')
            .height(180)
            .objectFit(ImageFit.Cover)
            .onClick(() => {
              LogUtil.info(JSON.stringify(new AppointmentStatusWidgetViewModel().getFormIdArray()))
            })

          Column({ space: 10 }) {
            PatientCardView({
              patientName: this.patientViewModel.defaultPatient?.patientName,
              patientCardId: this.patientViewModel.defaultPatient?.cardId,
              picUrl: this.patientViewModel.defaultPatient?.picUrl,
              addMode: this.patientViewModel.defaultPatient ? false : true,
              onPatientClick: () => {
                this.patientViewModel.toPatientSelectListPage()
              },
              showSwitch: this.patientViewModel.defaultPatient ? true : false,
            })

            Swiper() {
              Repeat<BannerInfo>(this.homeViewModel.bannerList).each(
                (obj: RepeatItem<BannerInfo>) => {
                  if (obj.item.url) {
                    Image(obj.item.url)
                      .width('100%')
                      .objectFit(ImageFit.Cover)
                  } else {
                    Image($r(obj.item.resource))
                      .objectFit(ImageFit.Cover)
                  }
                }
              )
            }
            .indicator(new DotIndicator()
              .color(Color.White)
              .selectedColor(Color.White))
            .loop(true)
            .height(88)
            .width('100%')
            .autoPlay(true)
            .borderRadius(16)
          }
          .margin({
            left: 16,
            right: 16
          })

          Column() {
            Row() {
              Text('就医服务')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
              Blank()
              Text('更多 >')
                .fontSize(12)
                .onClick(() => {
                  ToastUtil.showToast('敬请期待')
                })
            }
            .width('100%')
            .margin({ top: 3 })

            GridRow({ columns: 2, gutter: 16 }) {
              GridCol() {
                this.FunctionButtonBuilder($r('app.media.bg_appointment'), 'AppointmentEntryPage')
              }

              GridCol() {
                this.FunctionButtonBuilder($r('app.media.bg_report'), 'ReportQueryPage')
              }

              GridCol() {
                this.FunctionButtonBuilder($r('app.media.bg_payment'), 'CommonWebPage', {
                  src: 'https://developer.huawei.com/',
                  title: '自助缴费'
                } as CommonWebPageParam)
              }

              GridCol() {
                this.FunctionButtonBuilder($r('app.media.bg_consultation'), 'CommonWebPage', {
                  src: 'https://developer.huawei.com/',
                  title: '线上诊疗'
                } as CommonWebPageParam)
              }
            }
            .margin({ top: 3 })
          }
          .margin({
            top: 3,
            left: 16,
            right: 16
          })

        }
      }
      .layoutWeight(1)
      .backgroundColor($r('sys.color.ohos_id_color_background'))
      .align(Alignment.TopStart)
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring) // 滚动到边沿后回弹
    }
  }

  @Builder
  FunctionButtonBuilder(imageSource: ResourceStr, routerName: string, param?: object) {
    Image(imageSource)
      .width('100%')
      .height(88)
      .objectFit(ImageFit.Cover)
      .borderRadius(8)
      .onClick(() => {
        this.homeViewModel.toPage(routerName, param)
      })
  }
}