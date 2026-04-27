import { Constant } from '../common/Constant';
import { TextSettingType } from '../common/Enum';
import { AudioInfo, SoundByTag } from '../model/Index';
import { Sticker, StickersByTag } from '../model/Sticker';
import { MusicApis } from '../network/https/apis/Music';
import { SoundApis } from '../network/https/apis/Sound';
import { StickerApis } from '../network/https/apis/Sticker';
import { VideoEditVM } from '../viewmodel/VideoEditVM';

@ComponentV2
export struct OperationComponent {
  vm: VideoEditVM = VideoEditVM.instance;

  @Builder
  FontStyleBuilder() {
    Column() {
      Row() {
        ForEach(Constant.FONT_COLOR_LIST, (item: string) => {
          Stack() {
            Circle({ width: 24, height: 24 })
              .fill(item)
              .stroke(item === '#FFFFFF' ? '#000000' : Color.Transparent);

            Circle({ width: 12, height: 12 })
              .fill(item === '#FFFFFF' ? '#000000' : '#FFFFFF')
              .visibility(this.vm.textInfo.currentColor === item ? Visibility.Visible : Visibility.None);
          }
          .onClick(() => {
            this.vm.textInfo.currentColor = item;
          });
        }, (item: string) => item);
      }
      .justifyContent(FlexAlign.SpaceAround)
      .alignItems(VerticalAlign.Center)
      .width('100%')
      .height(40)
      .margin({ bottom: 12 });

      Row() {
        Text('字号')
          .fontSize(16)
          .margin({ right: 16 });
        Row() {
          Image($r('app.media.minus'))
            .borderRadius(700)
            .backgroundColor('#F1F3F5')
            .height(28)
            .width(28)
            .padding(4)
            .onClick(() => {
              if (this.vm.textInfo.fontSize <= 8) {
                this.getUIContext().getPromptAction().showToast({ message: '字体大小最小不超过8' });
                return;
              }
              this.vm.textInfo.fontSize--;
            });
          Text(this.vm.textInfo.fontSize.toString())
            .fontSize(16)
            .fontWeight(FontWeight.Medium);
          Image($r('app.media.plus'))
            .borderRadius(700)
            .height(28)
            .width(28)
            .padding(4)
            .backgroundColor('#F1F3F5')
            .onClick(() => {
              if (this.vm.textInfo.fontSize >= 32) {
                this.getUIContext().getPromptAction().showToast({ message: '字体大小最大不超过32' });
                return;
              }
              this.vm.textInfo.fontSize++;
            });
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width(120)
        .height(32)
        .border({
          radius: 16,
          color: '#F1F3F5',
          width: 1,
          style: BorderStyle.Solid,
        });
      }.width('100%')
      .justifyContent(FlexAlign.Start);

      Row() {
        Text('透明')
          .fontSize(16)
          .margin({ right: 16 });
        Slider({
          value: this.vm.textInfo.opacity,
          min: 0,
          max: 1,
          step: 0.1,
          style: SliderStyle.OutSet,
        })
          .layoutWeight(1)
          .onChange((value: number) => {
            this.vm.textInfo.opacity = value;
          });
      }
      .margin({ bottom: 12 });

      Row() {
        Image($r('app.media.bold'))
          .width(24)
          .height(24)
          .margin({ left: 8 })
          .onClick(() => {
            this.vm.textInfo.isBold = !this.vm.textInfo.isBold;
          })
          .backgroundColor(this.vm.textInfo.isBold ? Color.White : '#F1F3F5');
        Image($r('app.media.italic'))
          .width(24)
          .height(24)
          .onClick(() => {
            this.vm.textInfo.isItalics = !this.vm.textInfo.isItalics;
          })
          .backgroundColor(this.vm.textInfo.isItalics ? Color.White : '#F1F3F5');
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween);
    }.width('100%').height('100%').justifyContent(FlexAlign.Start);
  }

  @Builder
  TextRecommendBuilder() {
    List({ space: 12 }) {
      ForEach(Constant.RECOMMEND_TEXT_LIST, (item: string) => {
        ListItem() {
          Text(item)
            .fontSize(16)
            .onClick(() => {
              this.vm.textInfo.text = item;
            });
        };
      }, (item: string) => item);
    }.margin({ top: 12 }).width('100%')
    .height('calc(100% - 12vp)')
    .scrollBar(BarState.Off);
  }

  @Builder
  TextPicker() {
    Column({ space: 8 }) {
      TextInput({
        placeholder: this.vm.textInfo.text ? '' : '点击输入文字',
        text: this.vm.textInfo.text,
      }).backgroundColor($r('sys.color.comp_background_tertiary'))
        .borderRadius(20)
        .onChange((value: string) => {
          this.vm.textInfo.text = value;
        });

      Row() {
        Tabs({ barPosition: BarPosition.Start }) {
          TabContent() {
            this.FontStyleBuilder();
          }.tabBar(this.TextTabBar('样式', TextSettingType.STYLE));

          TabContent() {
            this.TextRecommendBuilder();
          }.tabBar(this.TextTabBar('文案', TextSettingType.TEXT));
        }
        .onChange((index: number) => {
          this.vm.textTabIndex = index;
        });
      };
    }
    .padding(16);
  }

  @Builder
  TextTabBar(title: string, index: number) {
    Text(title)
      .fontColor(this.vm.textTabIndex === index ? $r('sys.color.font_emphasize') : $r('sys.color.font_primary'));
  }

  @Builder
  MusicPicker() {
    List({ space: 12 }) {
      ForEach(this.vm.musicList, (item: AudioInfo) => {
        ListItem() {
          Row() {
            Row({ space: 12 }) {
              Image(item.isCached ? $r('app.media.cached_sound') : $r('app.media.music'))
                .size({ width: 16, height: 16 });
              Text(item.name).fontSize(14).fontColor($r('sys.color.font_primary'));
            };

            Row({ space: 12 }) {
              if (item.progress && !item.isCached) {
                Progress({ value: item.progress, total: 100, type: ProgressType.Capsule })
                  .size({ width: 72, height: 28 })
                  .style({
                    borderColor: 'rgba(10, 89, 247, 1)',
                    borderWidth: 1,
                    content: `${item.progress}%`,
                    font: { size: 14, style: FontStyle.Normal },
                    fontColor: $r('sys.color.font_primary'),
                    enableScanEffect: true,
                    showDefaultPercentage: false,
                  });
              } else {
                Button(item.isCached ? '使用' : '下载')
                  .size({ width: 72, height: 28 })
                  .borderRadius(8)
                  .fontColor(item.isCached ? $r('sys.color.font_on_primary') : $r('sys.color.font_primary'))
                  .backgroundColor(item.isCached ? 'rgba(10, 89, 247, 1)' : 'rgba(10, 89, 247, 0.2)')
                  .fontSize(14)
                  .type(ButtonType.Normal)
                  .onClick(async () => {
                    this.vm.applyBgSound(this.getUIContext(),item);
                    if (item.isCached) {
                      this.vm.musicPicker = false;
                    }
                  });
              }
            };
          }.width('100%').justifyContent(FlexAlign.SpaceBetween);
        };
      });
    }.padding({ left: 16, right: 16 });
  }

  @Builder
  SoundPicker() {
    Column({ space: 12 }) {
      Row() {
        ForEach(this.vm.soundList, (item: SoundByTag, index: number) => {
          Text(item.tag)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.vm.soundTabIndex === index ? $r('sys.color.font_emphasize') : $r('sys.color.font_primary'))
            .onClick(() => {
              this.vm.soundTabIndex = index;
              this.vm.selectedSoundList = this.vm.soundList[this.vm.soundTabIndex].sounds;
            });
        });
      }.width('100%').justifyContent(FlexAlign.SpaceEvenly);

      List({ space: 12 }) {
        ForEach(this.vm.selectedSoundList, (item: AudioInfo) => {
          ListItem() {
            Row() {
              Row({ space: 12 }) {
                Image($r('app.media.music')).size({ width: 16, height: 16 });
                Text(item.name).fontSize(14).fontColor($r('sys.color.font_primary'));
              };

              Row({ space: 12 }) {
                Button(item.isCached ? '使用' : '下载')
                  .size({ width: 72, height: 28 })
                  .borderRadius(8)
                  .fontColor(item.isCached ? $r('sys.color.font_on_primary') : $r('sys.color.font_primary'))
                  .fontSize(14)
                  .type(ButtonType.Normal)
                  .backgroundColor(item.isCached ? 'rgba(10, 89, 247, 1)' : 'rgba(10, 89, 247, 0.2)')
                  .onClick(async () => {
                    this.vm.applyBgSound(this.getUIContext(), item);
                    if (item.isCached) {
                      this.vm.soundPicker = false;
                    }
                  });
              };
            }.width('100%').justifyContent(FlexAlign.SpaceBetween);
          };
        });
      };
    }.padding({ left: 16, right: 16 });
  }

  @Builder
  StickerPicker() {
    Column({ space: 12 }) {
      Row({ space: 12 }) {
        ForEach(this.vm.stickerList, (item: StickersByTag, index: number) => {
          Text(item.tag)
            .fontColor(this.vm.stickerTabIndex === index ? $r('sys.color.font_emphasize') :
              $r('sys.color.font_primary'))
            .onClick(() => {
              this.vm.stickerTabIndex = index;
              this.vm.selectedStickerList = item.stickers;
            });
        }, (item: StickersByTag) => item.tag);
      }.width('100%').justifyContent(FlexAlign.SpaceEvenly);

      Grid() {
        ForEach(this.vm.selectedStickerList, (item: Sticker) => {
          GridItem() {
            Stack() {
              Image(item.uri);
            }
            .backgroundColor('#F1F3F5')
            .borderRadius(8)
            .alignContent(Alignment.BottomStart)
            .onClick(() => {
              // 先下载后使用
              this.vm.cacheSticker(item, this.getUIContext());
              this.vm.stickerPicker = false;
            });
          };
        }, (item: Sticker) => item.id);
      }
      .scrollBar(BarState.Off)
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr')
      .rowsGap(12)
      .columnsGap(12);
    }.padding({ left: 16, right: 16 });
  }

  build() {
    if (!this.vm.isAudio) {
      Row() {
        Column({ space: 4 }) {
          Image($r(`app.media.cut`))
            .size({ width: 24, height: 24 })
            .borderRadius(6);

          Text('剪辑').fontSize(14);
        }.onClick(() => {
          this.vm.editTabIndex = 0;
          this.vm.isInCut = !this.vm.isInCut;
        });

        Column({ space: 4 }) {
          Image($r('app.media.stickers'))
            .size({ width: 24, height: 24 })
            .borderRadius(6)
            .onClick(() => {
              this.vm.editTabIndex = 1;
              StickerApis.getStickerList().then((res) => {
                this.vm.handleStickerByTag(this.getUIContext(), res);
                this.vm.stickerPicker = true;
              });
            })
            .bindSheet($$this.vm.stickerPicker, this.StickerPicker(), {
              preferType: SheetType.CENTER,
              title: { title: '选择贴纸' },
              height: '40%',
              onWillDismiss: () => {
                this.vm.stickerTabIndex = 0;
                this.vm.stickerPicker = false;
              },
            });

          Text('贴纸').fontSize(14);
        };

        Column({ space: 4 }) {
          Image($r('app.media.audio'))
            .size({ width: 24, height: 24 })
            .borderRadius(6);
          Text('音频').fontSize(14);
        }.onClick(() => {
          this.vm.editTabIndex = 2;
          this.vm.isAudio = true;
        });

        Column({ space: 4 }) {
          Image($r(`app.media.video_text`))
            .size({ width: 24, height: 24 })
            .borderRadius(6);

          Text('文本').fontSize(14);
        }.onClick(() => {
          this.vm.editTabIndex = 3;
          this.vm.textPicker = true;
        }).bindSheet($$this.vm.textPicker, this.TextPicker(), {
          preferType: SheetType.CENTER,
          title: { title: '添加文本' },
          height: '50%',
          onWillDismiss: () => {
            this.vm.textTabIndex = 0;
            this.vm.textPicker = false;
            this.vm.isFinish = true;
          },
        });
      }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left: 16, right: 16 }).enabled(!this.vm.durationError);
    } else if (this.vm.isAudio) {
      Row() {
        Column({ space: 4 }) {
          Image($r('app.media.ic_video_cancel')).size({ width: 24, height: 24 });
          Text('取消').fontSize(14);
        }.onClick(() => {
          this.vm.isAudio = false;
        });

        Column({ space: 4 }) {
          Image($r('app.media.audio')).size({ width: 24, height: 24 });
          Text('音乐').fontSize(14);
        }.onClick(() => {
          MusicApis.getMusicList().then((res) => {
            this.vm.handleMusicByTag(res);
            this.vm.musicPicker = true;
          });
        }).bindSheet($$this.vm.musicPicker, this.MusicPicker(), {
          preferType: SheetType.CENTER,
          title: { title: '选择音乐' },
          height: '40%',
          onWillDismiss: () => {
            this.vm.musicPicker = false;
          },
        });

        Column({ space: 4 }) {
          Image($r('app.media.audio')).size({ width: 24, height: 24 });
          Text('音效').fontSize(14);
        }.onClick(() => {
          this.vm.soundTabIndex = 0;
          SoundApis.getSoundList().then((res) => {
            this.vm.handleSoundByTag(res);
            this.vm.soundPicker = true;
          });
        }).bindSheet($$this.vm.soundPicker, this.SoundPicker(), {
          preferType: SheetType.CENTER,
          title: { title: '选择音乐' },
          height: '40%',
          onWillDismiss: () => {
            this.vm.soundPicker = false;
          },
        });
      }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left: 16, right: 16 });
    }
  }
}