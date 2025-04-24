/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */


@ComponentV2
export struct Avatar {
  @Param avatar: string | Resource = '';
  @Param onFill: (avatar: string) => void = () => {
  };
  @Param onRemove: () => void = () => {
  };

  build() {
    Button({ type: ButtonType.Circle, stateEffect: false })
      .backgroundImage(this.avatar === '' ? $r('app.media.ic_avatar') : this.avatar)
      .backgroundImageSize(ImageSize.Cover)
      .backgroundColor(Color.Transparent)
      .height(50)
      .width(50)
  }
}
