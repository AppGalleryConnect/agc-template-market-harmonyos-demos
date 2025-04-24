import { Classifieds, Constants, InstitutionsItem, startCallDialog, UserState } from 'common'
import { common, Want } from '@kit.AbilityKit'
import { ATag } from './Tag';
import { PersistenceV2 } from '@kit.ArkUI';
import { CallContentBuilder, TitleBuilder } from './CallContentBuilder';

@ComponentV2
export struct InstitutionsCard {
  @Param institutionsItem: InstitutionsItem = new InstitutionsItem()
  @Local isShow: boolean = false
  @Param isReservation?: boolean = false
  @Local userState: UserState = PersistenceV2.connect(UserState, () => new UserState())!;
  @Param isHospital: boolean = false

  @Builder
  tagText(item: Classifieds) {
    Text(item.name).fontColor($r('app.color.institutions_tag_bg')).fontSize(Constants.FONT_SIZE_MINI)
  }

  private context = getContext(this) as common.UIAbilityContext;

  build() {
    Row({ space: Constants.CONTAINER_SPACE_TEN }) {
      Image($r('app.media.hospital'))
        .width($r('app.float.institutions_hospital_width'))
        .height($r('app.float.institutions_hospital_height'))
      Column({ space: Constants.CONTAINER_SPACE_TEN }) {
        Row({ space: Constants.CONTAINER_SPACE_TEN }) {
          Row({ space: Constants.CONTAINER_SPACE_FIVE }) {
            Text(this.institutionsItem.name)
              .fontSize($r('sys.float.Body_L')).fontColor($r('sys.color.font_primary')).fontWeight(FontWeight.Medium)
          }.width(Constants.SIXTY_FIVE_PERCENT_WIDTH).justifyContent(FlexAlign.Start)

          if (!this.isReservation) {
            /*
             * 导航
             * */
            Row() {
              Image($r('app.media.navigating'))
                .width($r('app.float.institutions_call_icon_width'))
                .height($r('app.float.institutions_call_icon_height'))
            }
            .width($r('app.float.institutions_navigation_width'))
            .height($r('app.float.institutions_navigation_height'))
            .backgroundColor($r('app.color.institutions_card_bg'))
            .justifyContent(FlexAlign.Center)
            .borderRadius(Constants.HALF_PERCENT_RADIUS)
            .onClick(() => {
              //   拉起花瓣地图进行导航
              let petalMapWant: Want = {
                bundleName: 'com.huawei.hmos.maps.app',
                uri: 'maps://routes',
                parameters: {
                  linkSource: 'com.other.app',
                  destinationLatitude: this.institutionsItem.location.latitude,
                  destinationLongitude: this.institutionsItem.location.longitude,
                  destinationPoiId: this.institutionsItem.siteId,
                  destinationName: this.institutionsItem.name,
                  vehicleType: 0,
                },
              }
              this.context.startAbility(petalMapWant);
            })

            /*
              * 电话
             * */
            Row() {
              Image($r('app.media.in_call'))
                .width($r('app.float.institutions_call_icon_width'))
                .height($r('app.float.institutions_call_icon_height'))
            }
            .width($r('app.float.institutions_navigation_width'))
            .height($r('app.float.institutions_navigation_height'))
            .backgroundColor('#CCE5FF')
            .justifyContent(FlexAlign.Center)
            .borderRadius(Constants.HALF_PERCENT_RADIUS)
            .onClick(() => {
              this.isShow = !this.isShow
            })
          }
        }.width(Constants.FULL_PERCENT_WIDTH).justifyContent(FlexAlign.Start)

        Flex({ justifyContent: FlexAlign.Start }) {
          ForEach(this.institutionsItem.classifieds, (item: Classifieds) => {
            ATag({
              defaultBuilder: (): void => {
                this.tagText(item)
              },
              backGroundColor: $r('app.color.institutions_card_bg'),
            })
          }, (item: Classifieds) => item.name)
        }

        if (this.isHospital) {
          Row() {
            Text() {
              Span($r('app.string.organization_code'))
              Span(this.institutionsItem.organizationCode)
            }.fontSize($r('sys.float.Body_S')).fontColor($r('sys.color.font_primary')).fontWeight(FontWeight.Regular)
          }
          .width(Constants.FULL_PERCENT_WIDTH)
          .justifyContent(FlexAlign.Start)

          Row() {
            Text() {
              Span($r('app.string.organization_type'))
              Span(this.institutionsItem.organizationType)
            }.fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Regular)
          }.width(Constants.FULL_PERCENT_WIDTH).justifyContent(FlexAlign.Start)
        }
        Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
          Row({ space: Constants.CONTAINER_SPACE_FIVE }) {
            Image($r('app.media.location'))
              .size({
                width: $r('app.float.institutions_location_icon_width'),
                height: $r('app.float.institutions_location_icon_height'),
              })
            Text(this.institutionsItem.address)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .fontSize($r('sys.float.Caption_M'))
              .fontColor($r('sys.color.font_secondary'))
              .fontWeight(FontWeight.Regular)
          }.width(Constants.SIXTY_PERCENT_WIDTH)
        }.width(Constants.FULL_PERCENT_WIDTH).margin({ top: $r('app.float.institution_margin_top') })

        if (!this.isHospital) {
          Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
            Row({ space: Constants.CONTAINER_SPACE_FIVE }) {
              Image($r('app.media.clock_time'))
                .size({
                  width: $r('app.float.institutions_location_icon_width'),
                  height: $r('app.float.institutions_location_icon_height'),
                })
              Text('服务大厅时间：09:00 - 12:00 13:30 - 17:30')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .fontSize($r('sys.float.Caption_M'))
                .fontColor($r('sys.color.font_secondary'))
                .fontWeight(FontWeight.Regular)
            }.width(Constants.SIXTY_PERCENT_WIDTH)
          }.width(Constants.FULL_PERCENT_WIDTH).margin({ top: $r('app.float.institution_margin_top') })
        }
      }
    }
    .width(Constants.FULL_PERCENT_WIDTH)
    .alignItems(VerticalAlign.Top)
    .padding({
      left: $r('app.float.institutions_service_padding_lr'),
      right: $r('app.float.institutions_service_padding_lr'),
      top: $r('app.float.institutions_service_padding_bt'),
      bottom: $r('app.float.institutions_service_padding_bt'),
    })
    .bindSheet($$this.isShow, CallContentBuilder(() => {
      this.isShow = !this.isShow
    }), {
      height: $r('app.float.mine_sheet_height'),
      title: TitleBuilder,
      blurStyle: BlurStyle.COMPONENT_THICK,
      preferType: SheetType.BOTTOM,
    })
  }
}