import { AiBarHeight, AppStorageKeys, StatusBarHeight } from '@agctemplate/widgets';
import { AppStorageV2 } from '@kit.ArkUI';
import { photoAccessHelper } from '@kit.MediaLibraryKit';

interface MediaFile {
  uri: string;
  type: 'image' | 'video';
  name: string;
  size: number;
}

const reportType: string[] =
  ['低俗色情', '账号违规', '敏感信息', '暴力恐怖', '造谣诽谤', '侮辱英烈', '谩骂攻击', '民族宗教', '赌博诈骗',
    '危害未成年', '违法违禁品', '其他']

const MAX_DESCRIPTION_LENGTH: number = 500;
const MAX_MATERIAL_COUNT: number = 9;
const MAX_FILE_SIZE: number = 10 * 1024 * 1024;
const ALLOWED_FILE_TYPES: string[] = ['jpg', 'jpeg', 'png', 'mp4'];

@ComponentV2
struct ReportPage {
  @Local aiBarHeight: AiBarHeight = AppStorageV2.connect(AiBarHeight, AppStorageKeys.AI_BAR_HEIGHT,
    () => new AiBarHeight())!;
  @Local statusBarHeight: StatusBarHeight = AppStorageV2.connect(StatusBarHeight, AppStorageKeys.STATUS_BAR_HEIGHT,
    () => new StatusBarHeight())!;
  @Local selectedReportType: string | null = null;
  @Local reportDescription: string = '';
  @Local evidenceMaterials: MediaFile[] = [];
  @Local contactInfo: string = '';
  @Local isSubmitting: boolean = false;
  @Local routerStack: NavPathStack = new NavPathStack();

  onReportTypeClick(type: string): void {
    if (this.selectedReportType === type) {
      this.selectedReportType = null;
    } else {
      this.selectedReportType = type;
    }
  }

  async onAddMaterial(): Promise<void> {
    if (this.evidenceMaterials.length >= MAX_MATERIAL_COUNT) {
      this.getUIContext().getPromptAction().showToast({ message: `最多上传${MAX_MATERIAL_COUNT}个文件` });
      return;
    }
    try {
      const picker = new photoAccessHelper.PhotoViewPicker();
      const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 1;
      const result = await picker.select(photoSelectOptions);
      if (result && result.photoUris && result.photoUris.length > 0) {
        const uri = result.photoUris[0];
        const fileName = uri.split('/').pop() || 'file';
        const ext = fileName.split('.').pop()?.toLowerCase() || '';
        if (!ALLOWED_FILE_TYPES.includes(ext)) {
          this.getUIContext().getPromptAction().showToast({ message: '仅支持jpg、png图片和mp4视频' });
          return;
        }
        const mediaFile: MediaFile = {
          uri: uri,
          type: ext === 'mp4' ? 'video' : 'image',
          name: fileName,
          size: 0
        };
        this.evidenceMaterials.push(mediaFile);
      }
    } catch (e) {
      console.error('select photo failed: ' + JSON.stringify(e));
    }
  }

  onRemoveMaterial(index: number): void {
    this.evidenceMaterials.splice(index, 1);
  }

  validateContactInfo(): boolean {
    const phoneRegex = /^1\d{10}$/;
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (this.contactInfo && !phoneRegex.test(this.contactInfo) && !emailRegex.test(this.contactInfo)) {
      this.getUIContext().getPromptAction().showToast({ message: '手机号或邮箱格式不正确' });
      return false;
    }
    return true;
  }

  validateForm(): boolean {
    if (!this.selectedReportType) {
      this.getUIContext().getPromptAction().showToast({ message: '请选择举报类型' });
      return false;
    }
    if (!this.validateContactInfo()) {
      return false;
    }
    return true;
  }

  async submitReport(): Promise<void> {
    if (!this.validateForm()) {
      return;
    }
    this.isSubmitting = true;
    try {
      this.getUIContext().getPromptAction().showToast({ message: '举报提交成功' });
      this.routerStack?.pop?.();
    } catch (e) {
      this.getUIContext().getPromptAction().showToast({ message: '提交失败，请重试' });
    } finally {
      this.isSubmitting = false;
    }
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          this.subTitle(true, '举报类型')
          Grid() {
            ForEach(reportType, (report: string) => {
              GridItem() {
                Row() {
                  Text(report)
                    .fontSize(14)
                    .fontWeight(this.selectedReportType === report ? 600 : 500)
                    .fontColor(this.selectedReportType === report ? '#E62D2D' : $r('sys.color.font_primary'))
                }
                .justifyContent(FlexAlign.Center)
                .width(104)
                .height(28)
                .borderRadius(14)
                .backgroundColor(
                  this.selectedReportType === report ? '#FFE8E8' : $r('sys.color.comp_background_tertiary'))
              }
              .onClick(() => this.onReportTypeClick(report))
            })
          }
          .columnsTemplate('repeat(auto-stretch, 104)')
          .columnsGap(8)
          .rowsGap(8)

          this.subTitle(true, '举报描述')

          TextArea({ text: this.reportDescription, placeholder: '请输入举报描述' })
            .maxLength(100)
            .showCounter(true)
            .backgroundColor($r('sys.color.comp_background_primary'))
            .width('100%')
            .height(142)
            .borderRadius(16)
            .onChange((value: string) => {
              this.reportDescription = value;
            })

          this.subTitle(false, '证明材料（选择图片或视频）')

          Grid() {
            ForEach(this.evidenceMaterials, (file: MediaFile, index: number) => {
              GridItem() {
                Stack() {
                  Image(file.uri)
                    .width(104)
                    .height(104)
                    .borderRadius(16)
                  Image($r('sys.symbol.xmark'))
                    .width(20)
                    .height(20)
                    .position({ x: 60, y: 0 })
                    .onClick(() => this.onRemoveMaterial(index))
                }
              }
            })
            if (this.evidenceMaterials.length < MAX_MATERIAL_COUNT) {
              GridItem() {
                Column() {
                  SymbolGlyph($r('sys.symbol.plus'))
                    .fontSize(24)
                    .fontColor([$r('sys.color.icon_secondary')])
                }
                .width(104)
                .height(104)
                .borderRadius(16)
                .backgroundColor($r('sys.color.comp_background_primary'))
                .alignItems(HorizontalAlign.Center)
                .justifyContent(FlexAlign.Center)
                .onClick(() => this.onAddMaterial())
              }
            }
          }
          .height(104)
          .columnsTemplate('repeat(auto-stretch, 104)')
          .columnsGap(8)
          .rowsGap(8)

          this.subTitle(false, '联系方式')

          TextInput({ text: this.contactInfo, placeholder: '请输入手机号码或邮箱' })
            .backgroundColor($r('sys.color.comp_background_primary'))
            .onChange((value: string) => {
              this.contactInfo = value;
            })
            .onBlur(() => {
              this.validateContactInfo();
            })

          Button('提交')
            .margin({ top: 24 })
            .width('100%')
            .borderRadius($r('sys.float.corner_radius_level10'))
            .backgroundColor(this.isSubmitting ? '#CCCCCC' : '#E62D2D')
            .enabled(!this.isSubmitting)
            .onClick(() => this.submitReport())
        }
        .padding({ left: 16, right: 16 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
    .title('举报')
    .padding({
      top: `${this.getUIContext().px2vp(this.statusBarHeight.value)}vp`,
      bottom: `${this.getUIContext().px2vp(this.aiBarHeight.value)}vp`
    })
    .onReady((ctx: NavDestinationContext) => {
      this.routerStack = ctx.pathStack;
    })
  }

  @Builder
  subTitle(isRedSpot: boolean, subtitle: string) {
    Row() {
      Text() {
        if (isRedSpot) {
          Span('*')
            .fontColor(Color.Red)
        }
        Span(subtitle)
          .fontColor($r('sys.color.font_secondary'))
      }
    }
    .padding({ top: 19, bottom: 8 })
    .width('100%')
    .justifyContent(FlexAlign.Start)
  }
}

@Builder
export function reportPageBuilder() {
  ReportPage()
}