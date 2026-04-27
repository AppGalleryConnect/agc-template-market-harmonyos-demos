/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { RouterModule } from '@agctemplate/router_module';

@ComponentV2
export struct NavigationDialog {
  @Local alignContent: Alignment = Alignment.Bottom;
  @Param @Require maskBackgroundColor: ResourceColor

  @Builder
  DefaultContentBuilder() {}

  @BuilderParam
  contentBuilderParam: () => void = this.DefaultContentBuilder

  onClose = () => {
    RouterModule.pop();
  }

  build() {
    NavDestination() {
      Stack() {
        Column()
          .height('100%')
          .width('100%')
          .backgroundColor('rgba(0, 0, 0, 0.1)')
          .opacity(0.1)
          .onClick(this.onClose)
        this.contentBuilderParam()
      }
      .height('100%')
      .alignContent(this.alignContent)
    }
    .mode(NavDestinationMode.DIALOG)
    .hideTitleBar(true)
    .expandSafeArea([SafeAreaType.KEYBOARD])
  }
}