import { getBmiNavPathStack, setBmiNavPathStack } from '../common/Route';
import { HeightRulerComponent } from '../components/HeightRulerComponent';
import { WeightRulerComponent } from '../components/WeightRulerComponent';
import { loadRecords, addRecord, deleteRecord, createRecordItem, RecordsModel } from '../common/BmiStorage';
import { HistoryModal } from '../components/BmiHistory';
import { InputModal } from '../viewmodel/BmiInputVM';

@Builder
export function BmiHomeBuilder() {
  BmiHome();
}

@ComponentV2
export struct BmiHome {
  @Provider() heightValue: number = 170.0;
  @Provider() weightValue: number = 65.0;
  @Provider() heightText: string = '';
  @Provider() weightText: string = '';
  @Local bmiResult: number = 0;
  @Local evaluation: string = '';
  @Local calculated: boolean = false;
  @Local showHistoryModal: boolean = false;
  @Local showInputModal: boolean = false;
  @Local showDetailModal: boolean = false;
  @Local modalType: string = '';
  @Local modalUnit: string = '';
  @Local records: RecordsModel = loadRecords();

  @Builder
  buildDetailSheetContent() {
    Column() {
      Column() {
        Column({ space: 4 }) {
          Text('BMI指数')
            .titleTextStyle()
          Text('身体质量指数，全称是Body Mass Index指数，奖惩体脂指数，是国际上常用的衡量人体胖瘦程度以及是否健康的一个标准。')
            .commonTextStyle()
            .textAlign(TextAlign.JUSTIFY)
        }.margin({ bottom: 8 })

        Column({ space: 4 }) {
          Text('计算方式')
            .subtitleTextStyle()
          Text('BMI=体重÷身高的平方。（体重单位：千克；身高单位：米）')
            .commonTextStyle()
            .textAlign(TextAlign.Start)
        }
      }
      .padding(12)
      .backgroundColor('rgba(0, 0, 0, 0.05)')
      .borderRadius(16)
      .margin({ bottom: 16, left: 16, right: 16 })

      Column() {
        Column({ space: 4 }) {
          Text('指数解读')
            .titleTextStyle()
          Text('正常水平：18.5~23.9 kg/m²')
            .commonTextStyle()
            .textAlign(TextAlign.JUSTIFY)
        }.margin({ bottom: 16 })

        Column({ space: 8 }) {
          Row({ space: 52 }) {
            Text('偏瘦').smallTextStyle()
            Text('正常').smallTextStyle()
            Text('偏胖').smallTextStyle()
            Text('肥胖').smallTextStyle()
          }

          Row() {
            Column()
              .height(8)
              .width(76)
              .backgroundColor('#ED6F21')
            Column()
              .height(8)
              .width(76)
              .backgroundColor('#64BB5C')
            Column()
              .height(8)
              .width(76)
              .backgroundColor('#ED6F21')
            Column()
              .height(8)
              .width(76)
              .backgroundColor('#E84026')
          }.justifyContent(FlexAlign.SpaceBetween)

          Row() {
            Text('<18.5')
              .smallGrayTextStyle()
              .margin({ right: 36 })
            Text('18.5~23.9')
              .smallGrayTextStyle()
              .margin({ right: 29 })
            Text('24~27.9')
              .smallGrayTextStyle()
              .margin({ right: 46 })
            Text('≥28')
              .smallGrayTextStyle()
          }
        }
      }
      .padding(12)
      .backgroundColor('rgba(0, 0, 0, 0.05)')
      .borderRadius(16)
      .margin({ left: 16, right: 16, bottom: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  private openInputModal(type: string, initialValue: number, unit: string) {
    this.modalType = type;
    this.modalUnit = unit;
    this.showInputModal = true;
  }

  private closeInputModal() {
    this.showInputModal = false;
  }

  private handleModalConfirm(value: number) {
    if (this.modalType === 'height') {
      this.heightValue = value;
      this.heightText = value % 1 === 0 ? value.toFixed(0) : value.toFixed(1);
    } else if (this.modalType === 'weight') {
      this.weightValue = value;
      this.weightText = value % 1 === 0 ? value.toFixed(0) : value.toFixed(1);
    }
    this.closeInputModal();
  }

  calculateBMI() {
    const heightInMeters = this.heightValue / 100;
    this.bmiResult = this.weightValue / (heightInMeters * heightInMeters);
    this.calculated = true;
    if (this.bmiResult < 18.5) {
      this.evaluation = '偏瘦';
    } else if (this.bmiResult < 24) {
      this.evaluation = '正常';
    } else if (this.bmiResult < 28) {
      this.evaluation = '偏胖';
    } else {
      this.evaluation = '肥胖';
    }
    this.saveRecord();
    getBmiNavPathStack().pushPathByName('BmiResultPage', null);
  }

  private saveRecord() {
    try {
      const record = createRecordItem(this.heightValue, this.weightValue, this.bmiResult, this.evaluation);
      addRecord(record, this.records);
      console.log('记录保存成功:', record);
    } catch (error) {
      console.error('保存记录失败:', error);
    }
  }

  private handleDeleteRecord(id: string) {
    try {
      deleteRecord(id, this.records);
    } catch (error) {
      console.error('删除记录失败:', error);
    }
  }

  openHistoryModal() {
    this.showHistoryModal = true;
  }

  closeHistoryModal() {
    this.showHistoryModal = false;
  }

  openDetailModal() {
    this.showDetailModal = true;
  }

  closeDetailModal() {
    this.showDetailModal = false;
  }

  aboutToAppear() {
    this.heightText = this.heightValue.toFixed(1);
    this.weightText = this.weightValue.toFixed(1);
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Row({ space: 8 }) {
            Image($r('app.media.left_icon_bmi'))
              .size({ width: 40, height: 40 })
              .onClick(() => {
                getBmiNavPathStack().pop();
              });
            Text('BMI计算器')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .opacity(0.9);
          };
          Row({ space: 10 }) {
            Image($r('app.media.detail_icon_bmi'))
              .size({ width: 40, height: 40 })
              .onClick(() => {
                this.openDetailModal();
              });
            Image($r('app.media.history_icon_bmi'))
              .size({ width: 40, height: 40 })
              .onClick(() => {
                this.openHistoryModal();
              });
          };
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 24 });

        Column({ space: 11 }) {
          Text('您的身高')
            .fontSize(20)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Bold)
            .width('100%')
            .textAlign(TextAlign.Center);
          Text('据此计算身体数据，不会对外展示')
            .fontSize(14)
            .fontColor($r('sys.color.font_tertiary'))
            .width('100%')
            .textAlign(TextAlign.Center);
        }
        .margin({ bottom: 24 });

        Column({ space: 16 }) {
          Row({ space: 2 }) {
            Text(`${this.heightValue.toFixed(1)}`)
              .fontSize(20)
              .fontColor('#0BCFB1')
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Center)
              .align(Alignment.Bottom)
              .onClick(() => {
                this.openInputModal('height', this.heightValue, 'cm');
              })
            Text('cm')
              .fontColor('#0BCFB1')
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Center)
              .align(Alignment.Bottom);
          }
          .alignItems(VerticalAlign.Bottom);
          HeightRulerComponent()
        }
        .margin({ bottom: 24 });

        Column({ space: 11 }) {
          Text('您的体重')
            .fontSize(20)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Bold)
            .width('100%')
            .textAlign(TextAlign.Center);
          Text('据此计算身体数据，不会对外展示')
            .fontSize(14)
            .fontColor($r('sys.color.font_tertiary'))
            .width('100%')
            .textAlign(TextAlign.Center);
        }
        .margin({ bottom: 24 });

        Column({ space: 16 }) {
          Row({ space: 2 }) {
            Text(`${this.weightValue.toFixed(1)}`)
              .fontSize(20)
              .fontColor('#0BCFB1')
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Center)
              .align(Alignment.Bottom)
              .onClick(() => {
                this.openInputModal('weight', this.weightValue, 'kg');
              })
            Text('kg')
              .fontColor('#0BCFB1')
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Center)
              .align(Alignment.Bottom);
          }
          .alignItems(VerticalAlign.Bottom);
          WeightRulerComponent()
        }

        Blank()

        Column() {
          Button('计算')
            .width('100%')
            .height(40)
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .backgroundColor('#0BCFB1')
            .position({ bottom: 24 })
            .onClick(() => {
              this.calculateBMI();
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center);
      }
      .width('100%')
      .height('100%')
      .padding(16);

      if (this.showHistoryModal) {
        HistoryModal({
          records: this.records.items,
          onDelete: (id: string) => {
            this.handleDeleteRecord(id);
          },
          onClose: () => {
            this.closeHistoryModal();
          }
        })
      }

      if (this.showInputModal) {
        InputModal({
          title: this.modalType === 'height' ? '修改身高' : '修改体重',
          unit: this.modalUnit,
          isVisible: this.showInputModal,
          onConfirm: (value: number) => {
            this.handleModalConfirm(value);
          },
          onCancel: () => {
            this.closeInputModal();
          }
        })
      }
    }
    .hideTitleBar(true)
    .onReady((ctx: NavDestinationContext) => {
      setBmiNavPathStack(ctx.pathStack);
    })
    .bindSheet(this.showDetailModal, this.buildDetailSheetContent(), {
      height: SheetSize.MEDIUM,
      preferType: SheetType.CENTER,
      backgroundColor: '#FFFFFF',
      title: { title: '' },
      dragBar: true,
      shouldDismiss: () => {
        this.showDetailModal = false;
        return true;
      }
    })
  }
}

@Extend(Text) function commonTextStyle() {
  .fontSize(14)
  .fontColor($r('sys.color.font_primary'))
  .width('100%')
}

@Extend(Text) function titleTextStyle() {
  .fontSize(20)
  .fontColor('#0BCFB1')
  .fontWeight(FontWeight.Bold)
  .width('100%')
  .textAlign(TextAlign.Start)
}

@Extend(Text) function subtitleTextStyle() {
  .fontColor($r('sys.color.font_primary'))
  .fontWeight(FontWeight.Bold)
  .width('100%')
  .textAlign(TextAlign.Start)
}

@Extend(Text) function smallTextStyle() {
  .fontSize(12)
  .fontColor($r('sys.color.font_primary'))
  .textAlign(TextAlign.JUSTIFY)
}

@Extend(Text) function smallGrayTextStyle() {
  .fontSize(12)
  .fontColor($r('sys.color.font_secondary'))
  .textAlign(TextAlign.JUSTIFY)
}
