export class CommonContext {
  static context: Context
  static setContext(context:	Context){
    CommonContext.context = context
  }

  static getContext(){
    return CommonContext.context
  }
}