import { TouristInfo } from 'module_base';
import { TouristVM } from '../viewmodel/TouristVM';
import { TouristCardComponent } from './TouristCardComponent';

@ComponentV2
export struct Tourists {
  vm: TouristVM = TouristVM.instance;
  @Param @Require touristList: TouristInfo[] = [];
  @Param @Once isInReserve: boolean = false;
  @Local touristId: string = '';
  @Event changeSelectedStatus: (isChecked: boolean, touristId: string) => void;
  @Event setSelectedTourist: () => void;
  @Event changeSheetContent: (isInitialPage: boolean, tourist: TouristInfo) => void;
  @Event closeSheet: () => void;
  // 新增、编辑、删除
  @Event deleteTourist: (touristId: string) => void;
  @Event addOrEditTourist: (tourist: TouristInfo, isEdit: boolean) => void;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Row() {
          Image($r('app.media.icon_add')).size({ height: 22, width: 22 }).margin({ right: 2 });
          Text('添加常用游客').fontSize(18).fontWeight(500).fontColor('#E84026');
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('sys.color.font_on_primary'))
        .borderRadius(8)
        .padding({
          top: 24,
          bottom: 24,
        })
        .onClick(() => {
          this.isInReserve ? this.changeSheetContent(false, new TouristInfo()) :
            this.mainPathStack.pushPathByName('TouristPage', null);
        });

        ForEach(this.touristList, (item: TouristInfo) => {
          TouristCardComponent({
            isInReserve: this.isInReserve,
            tourist: item,
            editTourist: () => {
              this.isInReserve ? this.changeSheetContent(false, item) :
                this.mainPathStack.pushPathByName('TouristPage', item);
            },
            deleteTourist: () => {
              this.deleteTourist(item.id);
            },
            updateCheckStatus: (value: boolean) => {
              this.changeSelectedStatus(value, item.id);
            },
          });
        }, (item: TouristInfo) => item.id);

        if (this.isInReserve) {
          Button('确定')
            .backgroundColor('#64BB5C')
            .fontSize($r('sys.float.Body_M'))
            .width('100%')
            .borderRadius(20)
            .onClick(() => {
              this.setSelectedTourist();
              this.closeSheet();
            });
        }
      }.padding(12);
    }
    .height('90%')
    .align(Alignment.Top)
    .backgroundColor('#F1F3F5F2')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring);
  }
}