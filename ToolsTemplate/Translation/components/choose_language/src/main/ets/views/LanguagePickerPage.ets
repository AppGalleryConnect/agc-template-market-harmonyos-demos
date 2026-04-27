import { Language, LanguageType } from '../model/LanguageModel';
import { LanguageViewModel } from '../viewmodel/LanguageViewModel';
import { VipUpgradeDialog } from '../components/VipUpgradeDialog';
import { LanguageListItem } from '../components/LanguageListItem';
import { LanguageListConstants } from '../constants/LanguageConstants';
import { LanguagePickerHeader } from '../components/LanguagePickerHeader';

/**
 * @usage: 语言选择器页面，用于翻译功能中选择源语言和目标语言。支持常用语言列表、VIP语言标识、语言切换功能。
 * 主要数据结构包括LanguageViewModel（语言视图模型）、Language（语言模型）、LanguageType（语言类型枚举）。
 * 包含if逻辑判断VIP弹窗显示、语言选中状态、自动检测语言过滤。
 * @layout: 页面采用Stack堆叠布局。主体Column包含LanguagePickerHeader头部组件、常用语言标题Text、Scroll滚动列表（ForEach渲染LanguageListItem）。
 * 条件渲染显示VipUpgradeDialog弹窗。
 * @constraints: 目标语言不能选择自动检测
 * @fileType: component
 * @isGen: true
 * @zhName: 语言选择器页面
 * @component: LanguagePickerHeader,LanguageListItem,VipUpgradeDialog
 * @image: screenshot/translate/LanguagePickerPage.jpg
 */
@ComponentV2
export struct LanguagePickerPage {
  @Require @Param viewModel: LanguageViewModel = new LanguageViewModel();
  @Param onClose?: () => void = undefined;
  @Param onVipUpgrade?: () => void = undefined;
  @Param routerModule?: NavPathStack = undefined;
  @Param showLanguageSelector: boolean = true; // 是否显示顶部语言选择栏
  @Local showVipDialog: boolean = false;

  build() {
    Stack() {
      // 主内容
      Column() {
        // 头部工具栏
        LanguagePickerHeader({
          onReturnClick: () => {
            if (this.onClose) {
              this.onClose();
            }
          },
          sourceLanguageName: this.viewModel.sourceLanguage.name,
          targetLanguageName: this.viewModel.targetLanguage.name,
          showSourceLanguageSelect: this.showLanguageSelector,
          showTargetLanguageSelect: this.showLanguageSelector,
          showSwapButton: this.showLanguageSelector,
          sourceLanguageHighlight: this.viewModel.editingType === LanguageType.SOURCE,
          targetLanguageHighlight: this.viewModel.editingType === LanguageType.TARGET,
          useUpArrowForTarget: true,
          onSourceLanguageClick: () => {
            this.viewModel.setEditingType(LanguageType.SOURCE);
          },
          onTargetLanguageClick: () => {
            this.viewModel.setEditingType(LanguageType.TARGET);
          },
          onSwapClick: () => {
            if (this.viewModel.canSwap()) {
              this.viewModel.swapLanguages();
            }
          }
        })

        // 常用语言标题
        Text(LanguageListConstants.COMMON_LANGUAGES_TITLE)
          .fontSize(LanguageListConstants.TITLE_FONT_SIZE)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(500)
          .width('100%')
          .margin({
            top: LanguageListConstants.TITLE_TOP_MARGIN,
            bottom: LanguageListConstants.TITLE_BOTTOM_MARGIN
          })
          .padding({ left: LanguageListConstants.TITLE_LEFT_MARGIN })

        // 语言列表
        Scroll() {
          Column({ space: 0 }) {
            ForEach(this.getFilteredCommonLanguages(), (language: Language) => {
              LanguageListItem({
                language: language,
                isSelected: this.isLanguageSelected(language),
                isVipUser: this.viewModel.isVipUser,
                onSelect: (lang: Language) => this.handleLanguageSelect(lang)
              })
            })

            ForEach(this.getFilteredAvailableLanguages(), (language: Language) => {
              LanguageListItem({
                language: language,
                isSelected: this.isLanguageSelected(language),
                isVipUser: this.viewModel.isVipUser,
                onSelect: (lang: Language) => this.handleLanguageSelect(lang)
              })
            })
          }
          .width('100%')
          .padding({
            left: LanguageListConstants.LIST_HORIZONTAL_PADDING,
            right: LanguageListConstants.LIST_HORIZONTAL_PADDING
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.White)

      // VIP升级弹窗
      if (this.showVipDialog) {
        VipUpgradeDialog({
          visible: this.showVipDialog,
          onClose: () => {
            this.showVipDialog = false;
          },
          onUpgrade: () => {
            this.showVipDialog = false;
            if (this.onVipUpgrade) {
              this.onVipUpgrade();
            }
          }
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  private isLanguageSelected(language: Language): boolean {
    if (this.viewModel.editingType === LanguageType.SOURCE) {
      return this.viewModel.sourceLanguage.code === language.code;
    }
    return this.viewModel.targetLanguage.code === language.code;
  }

  // 获取常用语言列表（源语言选择时包含自动检测，目标语言选择时不包含）
  private getFilteredCommonLanguages(): Language[] {
    if (this.viewModel.editingType === LanguageType.SOURCE) {
      // 源语言选择时，显示自动检测
      return this.viewModel.commonLanguages;
    }
    // 目标语言选择时，过滤掉自动检测
    return this.viewModel.commonLanguages.filter(lang => lang.code !== 'auto');
  }

  private getFilteredAvailableLanguages(): Language[] {
    const commonCodes = this.viewModel.commonLanguages.map(lang => lang.code);
    if (this.viewModel.editingType === LanguageType.SOURCE) {
      // 源语言选择时，只过滤常用语言
      return this.viewModel.availableLanguages.filter(lang => !commonCodes.includes(lang.code));
    }
    // 目标语言选择时，过滤自动检测和常用语言
    return this.viewModel.availableLanguages.filter(lang =>
    lang.code !== 'auto' && !commonCodes.includes(lang.code)
    );
  }

  private handleLanguageSelect(language: Language): void {
    if (this.viewModel.isLanguageLocked(language)) {
      // 显示VIP升级弹窗
      this.showVipDialog = true;
      return;
    }

    // 目标语言不能选择自动检测
    if (this.viewModel.editingType === LanguageType.TARGET && language.code === 'auto') {
      return;
    }

    this.viewModel.selectLanguage(language);

    // 关闭弹窗
    if (this.onClose) {
      this.onClose();
    }
  }
}
