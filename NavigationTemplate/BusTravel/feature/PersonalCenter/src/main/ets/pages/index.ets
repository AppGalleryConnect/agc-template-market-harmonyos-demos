import { MinePage } from './MinePage'

@Builder
export function PersonalCenterBuilder() {
  PersonalCenter()
}

@Component
export struct PersonalCenter {
  build() {
    MinePage()
  }
}