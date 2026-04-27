@Builder
export function TicketsBuilder() {
  Tickets();
}

@ComponentV2
export struct Tickets {
  build() {
    NavDestination() {
      Column() {
        Text('购票示例页面')
      }
    }.title('购票示例页面')
  }
}