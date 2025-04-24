@Builder
export function PersonalItemBuilder(title: string, type: number) {
  PersonalItem({ title: title, type: type })
}

@ComponentV2
struct Additional {
  @Param @Require type: number

  build() {
    if (this.type === 1) {
      Image('')
    } else {
      Text('')
    }
  }
}

@ComponentV2
export struct PersonalItem {
  @Param @Require title: string
  @Param @Require type: number

  build() {
    Row() {
      Text(this.title)

      Image($r('app.media.chevron_right')).size({ width: 12, height: 12 })
    }
  }
}