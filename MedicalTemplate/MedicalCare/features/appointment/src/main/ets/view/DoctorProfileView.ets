/**
 * 医生头像View
 */
@ComponentV2
export struct DoctorProfileView {
  @Param imageSize: number = 48
  @Param imageUrl: string = ''

  build() {
    Image(this.imageUrl || $r('app.media.ic_default_profile'))
      .alt($r('app.media.ic_doctor_profile'))
      .width(this.imageSize)
      .height(this.imageSize)
      .borderRadius(100)
  }
}