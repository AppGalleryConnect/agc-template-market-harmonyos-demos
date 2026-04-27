@ComponentV2
export struct ActivityNewsView{
  @Param leftIcon:string | Resource | null = null
  @Param rightIcon:string | Resource | null = null
  @Param @Require content:string
  build() {
    Text(){
      if(this.leftIcon){
        ImageSpan(this.leftIcon)
      }
      Span(this.content)
      if(this.rightIcon){
        ImageSpan(this.rightIcon)
      }
    }
  }
}
